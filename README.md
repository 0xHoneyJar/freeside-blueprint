# Freeside Blueprint

A small, non-runtime repository for making Freeside understandable.

It separates four things that must not silently merge:

1. **Operator intent** — what the product and buildings should mean.
2. **Repository observation** — what exact source revisions currently implement.
3. **Decisions** — explicit reconciliations between intent and observation.
4. **Generated views** — diagrams and summaries for humans and agents.

This repository does **not** run production. It has no database, API, queue, agent runtime, deployment, or implementation authority.

## First product

**Freeside Contract Access-Risk Audit**

A visitor submits a chain and contract address, optionally chooses a reference date and gating rule, sees honest progress, and receives a reusable data artifact containing:

- holder turnover;
- sold/lapsed wallet count;
- newly eligible wallet count;
- whale/concentration notes;
- stale-access risk estimate;
- a CTA to run a no-install Shadow Access Audit against Discord roles.

The minimal backend requires **Sonar + Score**. Presentation is intentionally deferred: the artifact is versioned data that the Dashboard may later render in any shape.

## Active mental model

```text
Dashboard
  -> Ordering / AuditOrder
  -> Sonar preparation + ownership snapshot
  -> Score access-risk snapshot
  -> Ordering audit engine
  -> AuditArtifact
  -> Dashboard
```

There is one active coordination path for the MVP: **HTTP commands/queries plus polling over durable state**. Message-bus fan-out remains deferred until a second live consumer or independent availability requirement exists.

## Rules

- One durable fact has one owner.
- A building is not a repository, runtime, Railway project, or database.
- A logical module does not require a new service.
- Intent and observation never merge silently.
- Product actors appear in the default map; reliability machinery is collapsed by default.
- Unknown is valid and must stay explicit.
- The Dashboard owns presentation only.
- Sonar readiness never activates Score catalog state.
- Order progress never becomes Registry Scoring.
- Generated files are views, never authority.

## Use

```bash
npm install
npm run check
npm run render
npm test
```

Generated views appear under `generated/`.

## Repository layout

```text
intent/       operator-authored target meaning
observed/     source-repository observations pinned to commits
decisions/    explicit reconciliation records
src/          tiny checker and Mermaid/Markdown renderer
generated/    non-authoritative views
```
