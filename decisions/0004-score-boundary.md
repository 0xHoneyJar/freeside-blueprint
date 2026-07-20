# 0004 — Score is required for the artifact, not automatically mutated

Status: proposed

The report requires a Score-derived access-risk snapshot.

Report fulfillment may query or request computation from Score. Sonar readiness may not activate Score catalog state. Catalog activation is a separate authorized command and may be performed by a human or agent only with an auditable actor identity and receipt.

Open question: identify the current Score route/tool/job that can produce `access-risk-audit.v1` inputs without inventing a new API.
