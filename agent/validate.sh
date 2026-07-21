#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/agent/contract.json"
LEDGER="${LEDGER_OVERRIDE:-$ROOT/agent/work.jsonl}"
LEDGER_ONLY=false

[[ "${1:-}" == "--ledger-only" ]] && LEDGER_ONLY=true

fail() {
  printf 'REJECTED: %s\n' "$1" >&2
  exit 1
}

command -v jq >/dev/null 2>&1 || fail "jq is required"
[[ -f "$CONFIG" ]] || fail "missing agent/contract.json"
[[ -f "$LEDGER" ]] || fail "missing ledger"

version="$(jq -r '.version' "$CONFIG")"
events="$(jq -c '.events' "$CONFIG")"
classes="$(jq -c '.classifications' "$CONFIG")"
max_events="$(jq -r '.max_events_per_run' "$CONFIG")"
max_findings="$(jq -r '.max_findings_per_run' "$CONFIG")"
max_issues="$(jq -r '.max_issues_per_run' "$CONFIG")"

all="$(mktemp)"
v2="$(mktemp)"
trap 'rm -f "$all" "$v2"' EXIT

jq -s '.' "$LEDGER" > "$all" || fail "work.jsonl contains invalid JSON"
jq --arg v "$version" '[.[] | select(.contract_version == $v)]' "$all" > "$v2"

jq -e --argjson allowed "$events" \
  'all(.[]; .event as $e | ($allowed | index($e)) != null)' "$v2" >/dev/null \
  || fail "unknown event"

jq -e --argjson allowed "$classes" \
  'all(.[] | select(has("classification"));
    .classification as $c | ($allowed | index($c)) != null)' "$v2" >/dev/null \
  || fail "unknown classification"

jq -e \
  --argjson maxEvents "$max_events" \
  --argjson maxFindings "$max_findings" \
  --argjson maxIssues "$max_issues" '
  group_by(.run_id)
  | all(.[];
      . as $r
      | ($r | length) <= $maxEvents
      and ($r | map(select(.event == "run.started")) | length) == 1
      and ($r | map(select(.event == "run.stopped")) | length) == 1
      and $r[0].event == "run.started"
      and $r[-1].event == "run.stopped"
      and ($r | map(.requirement) | unique | length) == 1
      and ($r | map(select(.event == "finding.recorded")) | length) <= $maxFindings
      and ($r | map(select(.event == "issue.created")) | length) <= $maxIssues
      and ($r | map(select(.event == "run.passed")) | length) <= 1
      and (
        ($r | map(select(.event == "finding.recorded")) | length)
        + ($r | map(select(.event == "run.passed")) | length)
      ) == 1
      and (
        (($r | map(.event) | index("finding.recorded")) // -1) as $i
        | if $i < 0 then true
          else all(range($i + 1; $r | length);
            ($r[.].event == "issue.created" or $r[.].event == "run.stopped"))
          end
      )
      and (
        (($r | map(.event) | index("run.passed")) // -1) as $i
        | if $i < 0 then true
          else all(range($i + 1; $r | length); $r[.].event == "run.stopped")
          end
      )
      and (
        if any($r[]; .event == "finding.recorded" and .classification == "DECISION_REQUIRED")
        then all($r[]; .event != "issue.created")
        else true
        end
      )
    )' "$v2" >/dev/null || fail "run shape or event order invalid"

jq -e --slurpfile c "$CONFIG" '
  ($c[0]) as $cfg
  | all(.[] | select(.event == "finding.recorded");
      (.requirement | tostring) as $r
      | any($cfg.finding_requirement_prefixes[];
          . as $prefix | $r | startswith($prefix)))
  and all(.[] | select(.event == "issue.created");
      (.requirement | tostring) as $r
      | any($cfg.issue_requirement_prefixes[];
          . as $prefix | $r | startswith($prefix))
      and ($cfg.issue_target_by_requirement[$r] != null)
      and (.repository == $cfg.issue_target_by_requirement[$r])
      and (.issue_url | type == "string" and length > 0)
    )' "$v2" >/dev/null || fail "finding or issue target is not ratified"

if [[ "$LEDGER_ONLY" == false ]] && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  changed="$(
    {
      git -C "$ROOT" diff --name-only
      git -C "$ROOT" diff --cached --name-only
      git -C "$ROOT" ls-files --others --exclude-standard
    } | sort -u | sed '/^$/d'
  )"

  if [[ -n "$changed" ]] && [[ "$changed" != "agent/work.jsonl" ]]; then
    printf '%s\n' "$changed" >&2
    fail "agent run changed files outside agent/work.jsonl"
  fi
fi

printf 'OK: contract v%s ledger accepted\n' "$version"
