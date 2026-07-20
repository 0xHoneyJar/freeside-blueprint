# Agent rules for Freeside Blueprint

This repository is a clarity instrument, not a production runtime.

Before changing anything, answer:

1. Who owns the state?
2. Is the thing a command, fact, query, projection, actor, or runtime?
3. Is the statement operator intent or repository observation?
4. Which existing concept becomes unnecessary?
5. What generated proof will reveal drift?

Hard constraints:

- Do not add a service, API, database, queue, broker, orchestrator, plugin system, or web UI.
- Do not edit upstream repositories from this repo.
- Do not infer operator intent from code.
- Do not mark generated views authoritative.
- Do not introduce a second active coordination path.
- Do not model reliability mechanisms as top-level product actors unless the operator explicitly promotes them.
- Do not activate Score catalog state from Sonar readiness.
- Do not require Identity, Worlds, Discord, MCP, or NATS for the first anonymous report.
- Use exact repository commit SHAs for observed claims.
- Unknown values remain `null` or `unknown`.

The reference implementation may validate and render declarations. It may not implement Freeside product behavior.
