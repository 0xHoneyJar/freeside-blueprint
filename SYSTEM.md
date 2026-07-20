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
%%{init: {
  "flowchart": {
    "curve": "linear",
    "nodeSpacing": 40,
    "rankSpacing": 65
  }
}}%%

flowchart LR
    V[Visitor]
    D[Dashboard<br/>presents requests and results]
    O[Orders<br/>owns audit orders and artifacts]
    S[Sonar<br/>owns ownership preparation]
    C[Score<br/>owns scoring data]
    I[Identity<br/>owns accounts and communities]

    V --> D
    D -->|Place audit order| O

    O -->|Prepare collection| S
    S -->|Ownership snapshot| O

    O -->|Read score snapshot| C
    C -->|Score snapshot| O

    O -->|Audit artifact| D
    D -.->|Claim audit after value| I
```
