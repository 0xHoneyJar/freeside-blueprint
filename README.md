# freeside-blueprint

One contract. One generic state reducer. One proof command.

```bash
go run .
go test ./...
```

- `blueprint.json` is the only authored system model.
- `main.go` validates the model and executes table-driven scenarios.
- No service, database, queue, renderer, probe framework, or runtime authority.
- Agents read `blueprint.json`, then inspect source repositories at exact refs supplied by the task.

The next earned feature is a separate staging golden-path test after the real order/artifact HTTP contract is fixed.
