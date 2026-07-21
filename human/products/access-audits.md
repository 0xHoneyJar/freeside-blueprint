# Access Audits

## Labels

| Label | Meaning |
|---|---|
| `I` | Input supplied to the audit |
| `E` | Evidence observed from the system |
| `P` | Policy: a decision rule under a named authority |
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
| `E5` | Current Discord role snapshot | Identity |
| `E6` | Verified Discord-to-wallet links | Identity |

## Policies

| ID | Policy | Authority | Override |
|---|---|---|---|
| `P1` | Eligibility rule | Community administrator | Supplied as `I4`; defaults to current holder when omitted |
| `P2` | Concentration and risk thresholds | Freeside product | Community administrator may configure |
| `P3` | Unresolved members are not classified as stale; linked wallets count as one person | Freeside safety policy | Fixed |
| `P4` | Discord role or roles included in the audit | Community administrator | Configurable |

No policy is valid without a named authority.

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
- `A5` is an estimate. It does not identify Discord members.
- Missing required evidence returns `NOT_COMPUTABLE`.
- Running the audit does not register or activate a Score community.

# Shadow Access Audit

**Question:** Which current Discord members should be reviewed?

It reuses current eligibility from the Gate Leak Report and adds Discord evidence.

| ID | Answer | Needs |
|---|---|---|
| `A7` | Role members who remain eligible | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A8` | Role members who are no longer eligible | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A9` | Eligible members missing the role | `E2`, `E4`, `E5`, `E6`, `P1`, `P4` |
| `A10` | Members unresolved to a verified wallet | `E5`, `E6`, `P3` |
| `A11` | Review candidates | `A8`, `A10`, `P3` |

## Discord evidence intake

Identity owns `E5` and `E6`.

`E5` is intaken from a Discord role snapshot the end user shares. Prefer **no install** — the integration path depends on their incumbent Discord tooling and is not fixed here.

Identity turns that shared snapshot into audit-ready role membership evidence. It does not require Freeside to be installed as a Discord bot for the MVP path unless a later human decision says otherwise.

Rules:

- Discord is read-only.
- The audit never adds or removes roles.
- Unlinked members remain unresolved.
- Discord member count minus holder count is not proof of stale access.
- Multiple wallets linked to one person are counted once.
- Without `E5`, return `NOT_COMPUTABLE`.
- With partial `E6`, return resolved answers plus `A10`.

## Example

At the reference date:

- Alice was eligible.
- Bob was eligible.

Now:

- Bob is eligible.
- Carol is eligible.

Gate Leak Report:

- Alice lapsed.
- Carol became newly eligible.
- Bob stayed eligible.

Discord currently gives Alice and Bob the holder role.

Shadow Access Audit:

- Alice is a review candidate.
- Bob remains eligible.
- Carol is eligible but missing the role.
