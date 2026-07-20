# Freeside

One request becomes one stored audit by combining a Sonar ownership
snapshot with a Score snapshot.

Rules:
- Ordering owns the order and artifact.
- Sonar owns ownership preparation.
- Score owns scoring data.
- Dashboard only presents.
- Identity begins after value.
- Everything else is parked.

```mermaid
flowchart LR
    U[Visitor<br/>chain + contract + date + optional rule]

    D[Dashboard<br/>shows progress and result]

    O[Ordering<br/>owns AuditOrder<br/>and AuditArtifact]

    S[Sonar<br/>resolves contract<br/>indexes ownership<br/>produces ownership snapshot]

    C[Score<br/>produces scoring snapshot]

    I[Identity<br/>account + community<br/>after value]

    U -->|request audit| D
    D -->|place order| O

    O -->|prepare collection| S
    S -->|ownership ready<br/>snapshot ref| O

    O -->|read score data| C
    C -->|score snapshot ref| O

    O -->|stored audit data| D
    D -->|optional claim| I

    W[Parked<br/>Worlds · NATS · MCP federation<br/>render formats · Discord mutation]

    classDef parked stroke-dasharray: 5 5;
    class W parked;
```
