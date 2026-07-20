# Claude CLI bootstrap prompt

You are working inside the `freeside-blueprint` repository.

## Mission

Turn the supplied operator intent and pinned repository observations into the smallest honest, visual model of the Freeside Contract Access-Risk Audit.

Do not implement production behavior. Do not modify any upstream repository. Do not introduce a new runtime.

## Product intent — load-bearing

The first product is a public, anonymous **Freeside Contract Access-Risk Audit**.

Inputs:
- chain;
- contract address;
- snapshot/reference date;
- optional gating rule.

Outputs as reusable versioned data:
- holder turnover;
- sold/lapsed wallet count;
- newly eligible wallet count;
- whale/concentration notes;
- stale-access risk estimate;
- CTA: “Map this to Discord roles with a no-install Shadow Access Audit.”

Required backend capabilities:
- Sonar ownership/history and preparation readiness;
- Score-derived access-risk/scoring signals.

Presentation is intentionally not fixed. The Dashboard may render the data in any later form.

Post-value onboarding means:
- create or link an account;
- create/onboard the community;
- attach the report to that community;
- allow the admin to invite members later.

That onboarding lane is optional and must not block the first report. The owner of invitations/community membership is unresolved and must not be invented.

Score catalog activation may be performed by an authorized human or agent, with actor identity and an audit receipt. Sonar readiness alone is never sufficient.

## Foundational model

Keep these distinct:

- Building: capability and durable-fact owner.
- Actor: durable stateful entity hosted by a building.
- State machine: legal transitions for an actor.
- Runtime: deployed process.
- Command: request to an owner; may be rejected.
- Fact: immutable statement about committed state.
- Query: read-only observation.
- Projection: derived view.

Use actor discipline without adding an actor framework:

`state + message -> next state + facts + effects`

Postgres rows, transactions, idempotency, and outboxes are acceptable implementations.

## Minimal target

The default product view contains only:

- Dashboard — presentation/BFF only;
- Ordering — owns AuditOrder, AuditRun, AuditArtifact for MVP;
- Sonar — owns PreparationJob and ownership snapshots;
- Score — owns scoring projections and supplies an access-risk snapshot.

The audit engine is a module co-located with Ordering. It is not a new service or building for the MVP.

Identity and Discord role snapshots are optional post-report lanes. Worlds is out of scope.

Use one active coordination path:

- HTTP commands/queries;
- durable Postgres state;
- Dashboard polling;
- no product-bus dependency for the MVP.

## Required work

1. Read `README.md`, `AGENTS.md`, `ARCHITECTURE.md`, all files under `intent/`, `observed/summary/`, and `decisions/`.
2. Preserve the raw census files under `observed/raw/` byte-for-byte.
3. Run `npm install`, `npm run check`, `npm run render`, and `npm test`.
4. Review the generated diagrams for these invariants:
   - one owner per durable noun;
   - Dashboard owns no durable domain state;
   - Sonar readiness cannot activate Score;
   - order progress cannot become Registry Scoring;
   - the artifact is data-first and presentation-neutral;
   - Shadow Access Audit is optional after the first report;
   - Worlds, MCP, NATS, and Identity are not required by the first report.
5. Reconcile observations against intent in a new decision file only when evidence requires it.
6. Surface, but do not silently resolve, these open questions:
   - Which current Score API can supply the required access-risk snapshot?
   - Where does the Discord role snapshot capability currently live?
   - Which building owns community membership/invitations after report claim?
   - Does current Ordering require shared-preparation/capacity machinery for the MVP, or can it be hidden/disabled?
7. Keep the implementation minimal. A change that adds a concept must identify what concept it removes or collapses.

## Output

Return:

- files changed;
- checker/test results;
- the current and target system diagrams;
- a short drift table with `CODE_DEBT`, `DOC_DRIFT`, or `OPERATOR_DECISION`;
- no implementation plan for upstream product code unless explicitly commissioned later.
