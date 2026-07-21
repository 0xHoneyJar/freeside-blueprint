#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEDGER="$ROOT/agent/work.jsonl"
PAYLOAD="${1:?usage: ./agent/append.sh '<json object>'}"

command -v jq >/dev/null 2>&1 || {
  echo "jq is required" >&2
  exit 1
}

line="$(jq -ce '. + {contract_version:"2"}' <<<"$PAYLOAD")"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

cat "$LEDGER" > "$tmp"
printf '%s\n' "$line" >> "$tmp"

LEDGER_OVERRIDE="$tmp" "$ROOT/agent/validate.sh" --ledger-only >/dev/null
mv "$tmp" "$LEDGER"
trap - EXIT

printf '%s\n' "$line"
