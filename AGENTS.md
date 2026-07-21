# Agent Instructions

## Purpose

Trace one expected edge in `SYSTEM.mmd`.

Record what production actually does.

Stop at the first unexpected state.

## Allowed

You may:

- read `SYSTEM.mmd`
- read source repositories
- probe live systems
- append to `work.jsonl`
- create or update one GitHub issue

## Forbidden

You may not:

- edit `SYSTEM.mmd`
- modify production code
- repair production state
- register or activate subjects
- create multiple issues for one finding
- continue past the first unexpected state
- rewrite existing JSONL lines

## Run events

Use only:

- `run.started`
- `proof.recorded`
- `finding.recorded`
- `issue.created`
- `run.passed`
- `run.stopped`

## Finding classifications

Use only:

- `INPUT_ERROR`
- `UPSTREAM_FAILURE`
- `MISSING_CAPABILITY`
- `BOUNDARY_VIOLATION`
- `INCONSISTENT_STATE`

## Run order

```text
run.started
→ proof.recorded*
→ run.passed
  or
→ finding.recorded
→ issue.created
→ run.stopped
```

A run cannot both pass and record a finding.

## JSONL example

```json
{"run_id":"audit-902d","event":"run.started","owner":"Sonar","at":"2026-07-21T03:00:00Z"}
{"run_id":"audit-902d","event":"proof.recorded","owner":"Sonar","proof":{"holders":2947,"ownership_ready":true},"at":"2026-07-21T03:37:35Z"}
{"run_id":"audit-902d","event":"finding.recorded","owner":"Score","classification":"MISSING_CAPABILITY","finding":"Score cannot evaluate an unregistered subject","at":"2026-07-21T04:00:00Z"}
{"run_id":"audit-902d","event":"issue.created","owner":"Score","issue_url":"https://github.com/...","at":"2026-07-21T04:05:00Z"}
{"run_id":"audit-902d","event":"run.stopped","reason":"first unexpected state surfaced","at":"2026-07-21T04:05:01Z"}
```

## Issue contents

Every issue must state:

- expected behavior
- observed behavior
- classification
- proof
- smallest required change
- completion proof

Do not propose a new service, queue, database, or framework unless the issue proves the existing path cannot own the behavior.
