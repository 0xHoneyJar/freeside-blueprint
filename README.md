# freeside-blueprint

Operator map for one product journey: one chain-qualified contract becomes one Contract Access-Risk Audit artifact.

## Read

| Path | Role |
|---|---|
| [SYSTEM.md](SYSTEM.md) | Current intended active system |
| [work.jsonl](work.jsonl) | Append-only work ledger (workflow facts + probe proof) |
| [work.sh](work.sh) | Tiny command surface over the ledger |

## Rules

Read `SYSTEM.md` first.

Open source repositories only for the current owner of the first unexpected state.

`work.jsonl` records workflow state. It is not product truth. Sonar/Score/Orders remain runtime authority; ledger completions require referenced proof.

## Work ledger

```bash
./work.sh next
./work.sh queue <run-id> <owner> <task>
./work.sh start <run-id>
./work.sh block <run-id> <classification> <proof> <next-action>
./work.sh complete <run-id> <proof>
./work.sh show <run-id>
```

States only: `queued` → `running` → `blocked` | `done` (and `blocked` → `running`).

`next` returns exactly one runnable task.

## Agent operating loop

1. Read `SYSTEM.md`.
2. Run `./work.sh next`.
3. Work only on the named owner and task.
4. Produce proof.
5. Append completed or blocked.
6. Stop.
