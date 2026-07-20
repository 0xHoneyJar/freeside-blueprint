# Freeside

One request becomes one stored audit by combining a Sonar ownership
snapshot with a Score snapshot.

Rules:
- Orders owns the order and artifact.
- Sonar owns ownership preparation.
- Score owns scoring data.
- Dashboard only presents.
- Identity begins after value.
- Everything else is parked.

```mermaid
flowchart LR
    U[Visitor]
    D[Dashboard]
    O[Orders<br/>owns AuditOrder + AuditArtifact]
    S[Sonar<br/>owns ownership preparation]
    C[Score<br/>owns scoring data]
    I[Identity<br/>account + community after value]

    U --> D
    D -->|PlaceAuditOrder| O
    O -->|PrepareCollection| S
    S -->|ownership snapshot| O
    O -->|GetScoreSnapshot| C
    C -->|score snapshot| O
    O -->|AuditArtifact| D
    D -->|ClaimAudit| I
```
