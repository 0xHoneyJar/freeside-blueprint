# Agents

## Purpose

Read `human/SYSTEM.mmd` and `human/products/access-audits.md`.

Trace one requirement ID.

Record what production actually provided.

Stop at the first unexpected result.

## Allowed

You may:

- read `human/SYSTEM.mmd`
- read `human/products/access-audits.md`
- read source repositories
- probe live systems
- append to `agent/work.jsonl` (via `agent/append.sh` when available)
- create or update one GitHub issue in the owning repository

## Forbidden

You may not:

- edit `human/`
- modify production code
- repair production state
- register or activate subjects
- create multiple issues for one finding
- continue past the first unexpected result
- rewrite existing JSONL lines
- implement fixes from this repository

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

Append `issue.created` only after a real GitHub issue exists.

If the evidence owner is `Unresolved`, record the finding and stop. Do not invent an owning repository.

## JSONL example

```json
{"run_id":"gate-leak-example","product":"Gate Leak Report","event":"run.started","subject":"eip155:1:0x…","at":"2026-07-21T03:00:00Z"}
{"run_id":"gate-leak-example","product":"Gate Leak Report","requirement":"E2","event":"proof.recorded","owner":"Sonar","proof":{"holders":2947},"at":"2026-07-21T03:37:35Z"}
{"run_id":"gate-leak-example","product":"Gate Leak Report","requirement":"E4","event":"finding.recorded","owner":"Score","classification":"MISSING_CAPABILITY","finding":"Score cannot evaluate an unregistered subject","at":"2026-07-21T04:00:00Z"}
{"run_id":"gate-leak-example","product":"Gate Leak Report","requirement":"E4","event":"issue.created","owner":"Score","issue_url":"https://github.com/…","at":"2026-07-21T04:05:00Z"}
{"run_id":"gate-leak-example","product":"Gate Leak Report","event":"run.stopped","reason":"first unexpected requirement E4","at":"2026-07-21T04:05:01Z"}
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
