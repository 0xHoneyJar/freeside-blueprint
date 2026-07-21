# Freeside Blueprints

A tiny surface for understanding Freeside.

## Files

- `SYSTEM.mmd` — the current human-approved system map
- `work.jsonl` — append-only agent observations
- GitHub issues — problems that require implementation

## Rule

Humans change the system map.

Agents observe reality, record proof, create one issue, and stop.

## Read order

1. Open `SYSTEM.mmd`
2. Read the latest relevant entries in `work.jsonl`
3. Open the linked GitHub issue
4. Inspect only the repository named as the current owner

## Boundaries

This repository does not:

- run production
- implement fixes
- own product state
- replace source repositories
- contain an orchestration framework
