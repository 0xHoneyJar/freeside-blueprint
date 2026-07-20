# Freeside active system

> Generated view. Non-authoritative.

## Product

**contract-access-risk-audit** — A visitor submits a chain-qualified contract, sees honest progress, and receives reusable access-risk data without authenticating first.

Artifact: `access-risk-audit.v1` (data), owned by `ordering`; presentation owned by `dashboard`.

## Golden path

1. **audit_order_committed** — owner: `ordering`; proof: `audit_id`
2. **contract_resolved** — owner: `ordering`; proof: `canonical_subject`
3. **ownership_prepared** — owner: `sonar`; proof: `ownership.ready`
4. **score_snapshot_acquired** — owner: `score`; proof: `score_snapshot_ref`
5. **artifact_produced** — owner: `ordering`; proof: `artifact_id`
6. **artifact_observed** — owner: `dashboard`; proof: `dashboard_read_receipt`

## Buildings

| Building | Purpose | Durable nouns |
|---|---|---|
| Dashboard | Present requests, progress, artifacts, and onboarding projections. | none |
| Identity | Create/link user accounts after report delivery. | user_identity, credentials, session |
| Ordering | Own audit demand, lifecycle, computation run, and data artifact for the MVP. | audit_order, audit_run, audit_artifact |
| Score | Own scoring projections and supply versioned access-risk inputs. | scoring_projection, score_catalog |
| Sonar | Resolve and prepare chain-qualified ownership data and expose attributable snapshots. | preparation_job, ownership_snapshot, ownership_readiness |

## Product actors

| Actor | Owner | Identity | Owns |
|---|---|---|---|
| audit order | ordering | audit_id | canonical_input, public_status, preparation_ref, score_snapshot_ref, artifact_ref, failure_reason |
| audit run | ordering | run_id | input_snapshot_refs, computation_status, artifact_data, provenance |
| preparation job | sonar | physical_job_id | preparation_status, readiness_evidence, preparation_failure |

## Active transport

`http-pull`

Deferred: `nats-jetstream`.

## Never

- require authentication before creating the audit order
- map Sonar ownership readiness to Score catalog active
- map audit/order progress to Registry Scoring
- require Worlds for audit generation
- require Discord role access for the first report
- expose internal service topology as user-facing product state
