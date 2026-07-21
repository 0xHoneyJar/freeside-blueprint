# Access Audits

## Labels

| ID | Meaning |
|---|---|
| `I` | Input supplied to the audit |
| `E` | Evidence required from the system |
| `P` | Human-approved policy |
| `A` | Answer returned by the audit |

## Inputs

| ID | Input |
|---|---|
| `I1` | Chain |
| `I2` | Contract address |
| `I3` | Reference date |
| `I4` | Optional gating rule |

## Evidence

| ID | Evidence | Owner |
|---|---|---|
| `E1` | Ownership at the reference date | Sonar |
| `E2` | Ownership now | Sonar |
| `E3` | Score at the reference date | Score |
| `E4` | Score now, without catalog admission | Score |
| `E5` | Current Discord role snapshot | Unresolved |
| `E6` | Verified Discord-to-wallet links | Identity |

## Policies

| ID | Human decision |
|---|---|
| `P1` | Eligibility rule |
| `P2` | Reference-date interpretation |
| `P3` | Concentration and risk thresholds |
| `P4` | Role-review policy |

# Gate Leak Report

**Question:** How much holder-gated access may now be wrong?

| ID | Answer | Needs |
|---|---|---|
| `A1` | Holder turnover | `E1`, `E2`, `P2` |
| `A2` | Sold or lapsed wallet count | `E1`, `E2`, `E3`, `E4`, `P1`, `P2` |
| `A3` | Newly eligible wallet count | `E1`, `E2`, `E3`, `E4`, `P1`, `P2` |
| `A4` | Whale and concentration notes | `E2`, `P3` |
| `A5` | Stale-access risk estimate | `E1`, `E2`, `E3`, `E4`, `P1`, `P2`, `P3` |
| `A6` | “Map this to Discord roles with a no-install Shadow Access Audit.” | — |

Rules:

- Discord is not required.
- `A5` is an estimate. It does not identify Discord members.
- Missing required evidence returns `NOT_COMPUTABLE`.
- Running the audit does not register or activate a Score community.

# Shadow Access Audit

**Question:** Which current Discord members should be reviewed?

It reuses current eligibility from the Gate Leak core and adds `E5`, `E6`, and `P4`.

| ID | Answer | Needs |
|---|---|---|
| `A7` | Role members who remain eligible | `E2`, `E4`, `E5`, `E6`, `P1` |
| `A8` | Role members who are no longer eligible | `E2`, `E4`, `E5`, `E6`, `P1` |
| `A9` | Eligible members missing the role | `E2`, `E4`, `E5`, `E6`, `P1` |
| `A10` | Unresolved Discord members | `E5`, `E6` |
| `A11` | Review candidates | `A8`, `A10`, `P4` |

Rules:

- Discord is read-only.
- The audit never adds or removes roles.
- Unlinked members remain unresolved.
- Role-member count minus holder count is not proof of stale access.
- Multiple wallets for one person are resolved before people are counted.

## Example

At the reference date:

- Alice was eligible.
- Bob was eligible.

Now:

- Bob is eligible.
- Carol is eligible.

Gate Leak Report:

- lapsed: Alice
- newly eligible: Carol
- unchanged: Bob

Discord currently gives Alice and Bob the holder role.

Shadow Access Audit:

- review: Alice
- still eligible: Bob
- missing role: Carol
