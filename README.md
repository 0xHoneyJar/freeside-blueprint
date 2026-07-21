# freeside-blueprint

Two surfaces:

| File | Owner | Role |
|---|---|---|
| [SYSTEM.mmd](SYSTEM.mmd) | Human | Current accepted system map |
| [work.jsonl](work.jsonl) | Agent | Append-only observations |

Issues change code. Decisions change the diagram.

## Agent authority

May: read `SYSTEM.mmd`, read production repos, probe live systems, append `work.jsonl`, create or update one GitHub issue, stop.

May not: edit `SYSTEM.mmd`, change product intent, implement fixes, modify production repos, register communities, ack jobs, apply SCALE, repair state, open competing issues, continue past the first unexpected state.

## Loop

1. Read `SYSTEM.mmd`.
2. Select one expected edge.
3. Observe reality.
4. Append evidence to `work.jsonl`.
5. Stop at the first contradiction.
6. Create one issue in the owning repository.
7. Append the issue reference.
8. Stop.
