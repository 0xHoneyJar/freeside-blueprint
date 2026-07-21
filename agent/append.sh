#!/usr/bin/env bash
set -euo pipefail

payload="${1:?usage: ./agent/append.sh '<json object>'}"
jq -e 'type == "object" and has("run_id") and has("event")' <<<"$payload" >/dev/null
printf '%s\n' "$(jq -c . <<<"$payload")" >> "$(dirname "$0")/work.jsonl"
