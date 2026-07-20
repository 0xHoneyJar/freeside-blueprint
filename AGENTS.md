# Agent contract

1. Run `go run .` and `go test ./...`.
2. Read `blueprint.json` as operator intent, not repository reality.
3. Inspect only the target source repository at its exact commit.
4. Report intent, observation, contradiction, and the smallest deletion-first change.
5. Do not add a service, queue, fallback, state machine, or abstraction unless it removes an existing path.
