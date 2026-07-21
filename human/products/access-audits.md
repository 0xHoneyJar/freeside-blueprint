# Access Audits

## Labels

| Label | Meaning |
|---|---|
| `I` | Input supplied to the audit |
| `E` | Evidence required from the system |
| `P` | Policy under a named authority |
| `A` | Answer returned to the user |

## Inputs

| ID | Input |
|---|---|
| `I1` | Chain |
| `I2` | Contract address |
| `I3` | Reference date |
| `I4` | Optional gating rule |

## Evidence

| ID | Evidence |
|---|---|
| `E1` | Ownership at the reference date |
| `E2` | Ownership now |
| `E3` | Score at the reference date |
| `E4` | Score now without catalog admission |
| `E5` | Current Discord role snapshot |
| `E6` | Verified Discord-to-wallet links |

## Policies

| ID | Policy | Authority |
|---|---|---|
| `P1` | Eligibility rule | Community administrator |
| `P2` | Concentration and risk thresholds | Freeside product |
| `P3` | Unresolved members are not classified as stale | Freeside safety |
| `P4` | Discord roles included in the audit | Community administrator |

A missing required input, evidence item, or policy returns `NOT_COMPUTABLE`.

# Gate Leak Report

**Question:** How much holder-gated access may now be wrong?

| ID | Answer | Needs |
|---|---|---|
| `A1` | Holder turnover | `E1`, `E2` |
| `A2` | Sold or lapsed wallet count | `E1`, `E2`, `E3`, `E4`, `P1` |
| `A3` | Newly eligible wallet count | `E1`, `E2`, `E3`, `E4`, `P1` |
| `A4` | Whale and concentration notes | `E2`, `P2` |
| `A5` | Stale-access risk estimate | `E1`, `E2`, `E3`, `E4`, `P1`, `P2` |
| `A6` | “Map this to Discord roles with a no-install Shadow Access Audit.” | — |

Rules:

- Discord is not required.
- `A5` is an estimate, not a Discord member list.
- Running the audit does not register or activate a Score community.

# Shadow Access Audit

**Question:** Which current Discord members should be reviewed?

It reuses current eligibility and adds `E5`, `E6`, `P3`, and `P4`.

| ID | Answer | Needs |
|---|---|---|
| `A7` | Role members who remain eligible | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A8` | Role members who are no longer eligible | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A9` | Eligible members missing the role | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A10` | Members unresolved to a verified wallet | `E5`, `E6`, `P3` |
| `A11` | Review candidates | `A8`, `A10`, `P3` |

Rules:

- Discord is read-only.
- The audit never adds or removes roles.
- Unlinked members remain unresolved.
- Discord member count minus holder count is not proof of stale access.
- Multiple wallets linked to one person are counted once.
