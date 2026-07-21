#!/usr/bin/env bash
# work.sh — tiny append-only work ledger (not an agent factory).
# Product truth stays in Sonar / Score / Orders. This file only records task workflow.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LEDGER="${ROOT}/work.jsonl"
NOW() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

die() { printf 'work.sh: %s\n' "$*" >&2; exit 1; }

need_jq() {
  command -v jq >/dev/null 2>&1 || die "jq is required"
}

ensure_ledger() {
  [[ -f "$LEDGER" ]] || : >"$LEDGER"
}

current_state() {
  local run_id="$1"
  [[ -f "$LEDGER" ]] || { printf 'absent\n'; return; }
  local last
  last="$(jq -cr --arg id "$run_id" 'select(.run_id == $id) | .event' "$LEDGER" | tail -n 1 || true)"
  case "$last" in
    "") printf 'absent\n' ;;
    run.queued) printf 'queued\n' ;;
    run.started) printf 'running\n' ;;
    run.blocked) printf 'blocked\n' ;;
    run.completed) printf 'done\n' ;;
    *) die "unknown event in ledger for ${run_id}: ${last}" ;;
  esac
}

assert_transition() {
  local from="$1" event="$2"
  case "${from}:${event}" in
    absent:run.queued) ;;
    queued:run.started) ;;
    running:run.blocked) ;;
    running:run.completed) ;;
    blocked:run.started) ;;
    *) die "illegal transition: ${from} + ${event}" ;;
  esac
}

append_event() {
  need_jq
  ensure_ledger
  local json="$1"
  # Validate JSON before append.
  jq -ce . >/dev/null <<<"$json" || die "refusing to append invalid JSON"
  printf '%s\n' "$json" >>"$LEDGER"
}

cmd_queue() {
  local run_id="${1:-}" owner="${2:-}" task="${3:-}"
  [[ -n "$run_id" && -n "$owner" && -n "$task" ]] || die "usage: queue <run-id> <owner> <task>"
  local state
  state="$(current_state "$run_id")"
  assert_transition "$state" "run.queued"
  append_event "$(jq -nc \
    --arg run_id "$run_id" \
    --arg owner "$owner" \
    --arg task "$task" \
    --arg at "$(NOW)" \
    '{run_id:$run_id,event:"run.queued",owner:$owner,task:$task,at:$at}')"
  printf 'queued %s\n' "$run_id"
}

cmd_start() {
  local run_id="${1:-}"
  [[ -n "$run_id" ]] || die "usage: start <run-id>"
  local state owner
  state="$(current_state "$run_id")"
  assert_transition "$state" "run.started"
  owner="$(jq -cr --arg id "$run_id" 'select(.run_id == $id and .event == "run.queued") | .owner' "$LEDGER" | tail -n 1)"
  [[ -n "$owner" && "$owner" != "null" ]] || die "no queued owner for ${run_id}"
  append_event "$(jq -nc \
    --arg run_id "$run_id" \
    --arg owner "$owner" \
    --arg at "$(NOW)" \
    '{run_id:$run_id,event:"run.started",owner:$owner,at:$at}')"
  printf 'running %s\n' "$run_id"
}

cmd_block() {
  local run_id="${1:-}" classification="${2:-}" proof="${3:-}" next_action="${4:-}"
  [[ -n "$run_id" && -n "$classification" && -n "$proof" && -n "$next_action" ]] \
    || die "usage: block <run-id> <classification> <proof> <next-action>"
  local state owner
  state="$(current_state "$run_id")"
  assert_transition "$state" "run.blocked"
  owner="$(jq -cr --arg id "$run_id" 'select(.run_id == $id) | .owner' "$LEDGER" | tail -n 1)"
  [[ -n "$owner" && "$owner" != "null" ]] || die "no owner for ${run_id}"
  append_event "$(jq -nc \
    --arg run_id "$run_id" \
    --arg owner "$owner" \
    --arg classification "$classification" \
    --arg proof "$proof" \
    --arg next_action "$next_action" \
    --arg at "$(NOW)" \
    '{run_id:$run_id,event:"run.blocked",owner:$owner,classification:$classification,proof:$proof,next_action:$next_action,at:$at}')"
  printf 'blocked %s\n' "$run_id"
}

cmd_complete() {
  local run_id="${1:-}" proof="${2:-}"
  [[ -n "$run_id" && -n "$proof" ]] || die "usage: complete <run-id> <proof>"
  local state owner
  state="$(current_state "$run_id")"
  assert_transition "$state" "run.completed"
  owner="$(jq -cr --arg id "$run_id" 'select(.run_id == $id) | .owner' "$LEDGER" | tail -n 1)"
  [[ -n "$owner" && "$owner" != "null" ]] || die "no owner for ${run_id}"
  append_event "$(jq -nc \
    --arg run_id "$run_id" \
    --arg owner "$owner" \
    --arg proof "$proof" \
    --arg at "$(NOW)" \
    '{run_id:$run_id,event:"run.completed",owner:$owner,proof:$proof,at:$at}')"
  printf 'done %s\n' "$run_id"
}

cmd_show() {
  local run_id="${1:-}"
  [[ -n "$run_id" ]] || die "usage: show <run-id>"
  need_jq
  ensure_ledger
  local state
  state="$(current_state "$run_id")"
  printf 'run_id=%s state=%s\n' "$run_id" "$state"
  jq -c --arg id "$run_id" 'select(.run_id == $id)' "$LEDGER"
}

# Exactly one runnable task: oldest queued, else oldest blocked (re-open candidate).
# Prefer queued over blocked. Never returns more than one.
cmd_next() {
  need_jq
  ensure_ledger
  if [[ ! -s "$LEDGER" ]]; then
    printf 'none\n'
    return 0
  fi

  local next
  next="$(
    jq -cs '
      group_by(.run_id)
      | map({
          run_id: .[0].run_id,
          events: .,
          last: .[-1]
        })
      | map(
          . as $r
          | {
              run_id: $r.run_id,
              last: $r.last,
              owner: $r.last.owner,
              state: (
                if $r.last.event == "run.queued" then "queued"
                elif $r.last.event == "run.started" then "running"
                elif $r.last.event == "run.blocked" then "blocked"
                elif $r.last.event == "run.completed" then "done"
                else "unknown" end
              ),
              queued_at: (($r.events | map(select(.event == "run.queued")) | .[0].at) // null),
              task: (($r.events | map(select(.event == "run.queued" and .task != null)) | .[-1].task) // null),
              next_action: ($r.last.next_action // null),
              classification: ($r.last.classification // null),
              proof: ($r.last.proof // null)
            }
        )
      | map(select(.state == "queued" or .state == "blocked"))
      | sort_by(
          (if .state == "queued" then 0 else 1 end),
          (.queued_at // "9999")
        )
      | (.[0] // null)
    ' "$LEDGER"
  )"

  if [[ "$next" == "null" || -z "$next" ]]; then
    printf 'none\n'
    return 0
  fi

  jq -r '
    "run_id=\(.run_id)",
    "state=\(.state)",
    "owner=\(.owner)",
    "task=\(.task // "")",
    (if .state == "blocked" then "classification=\(.classification // "")" else empty end),
    (if .state == "blocked" then "proof=\(.proof // "")" else empty end),
    (if .next_action != null then "next_action=\(.next_action)" else empty end)
  ' <<<"$next"
}

usage() {
  cat <<'EOF'
usage:
  ./work.sh queue <run-id> <owner> <task>
  ./work.sh start <run-id>
  ./work.sh block <run-id> <classification> <proof> <next-action>
  ./work.sh complete <run-id> <proof>
  ./work.sh show <run-id>
  ./work.sh next

states: queued → running → blocked|done ; blocked → running
ledger: work.jsonl (append-only facts; not product truth)
EOF
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    queue) cmd_queue "$@" ;;
    start) cmd_start "$@" ;;
    block) cmd_block "$@" ;;
    complete) cmd_complete "$@" ;;
    show) cmd_show "$@" ;;
    next) cmd_next "$@" ;;
    -h|--help|help|"") usage ;;
    *) die "unknown command: ${cmd}" ;;
  esac
}

main "$@"
