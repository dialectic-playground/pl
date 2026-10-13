# Requirements Traceability Matrix (RTM) — Concatenate & Number Files

| Field | Value |
| :-- | :-- |
| Project | `02-cat` |
| Tools | dp-cat |
| Author | *your name* |
| Version / date | *0.1 — YYYY-MM-DD* |

> **Purpose of this document.** This lightweight RTM shows that every requirement is
> *designed*, *implemented*, and *verified*, and that nothing was built without a requirement.
> Keep it current. A requirement with an empty cell is a gap.
>
> **How to fill it in.** Create one row for every `UR-` requirement (URD), every `FR-` and
> `NFR-` requirement (SRS), and every `CONV-` requirement the SRS incorporates. Under *Design*,
> cite HLD/LLD sections. Under *Code*, cite files and functions. Under *Verification*, cite
> unit-test names and black-box test IDs (public tests `P01` … `P10`; hidden tests are verified
> by CI and must not be cited). Set *Status* to one of `Not started`, `Designed`,
> `Implemented`, `Verified`.

## 1. User requirements to system requirements

| User requirement (URD) | Derived system requirements (SRS) |
| :-- | :-- |
| *UR-01* | *FR-01, FR-02, NFR-03* |

## 2. Forward traceability

| Req. ID | Summary | Design (HLD/LLD) | Code (file::function) | Verification (unit / black-box) | Status |
| :-- | :-- | :-- | :-- | :-- | :-- |
| *FR-01* | *…* | *HLD §3.2, LLD §3.1* | *`src/…::parse_args`* | *`test_parse_bundled_flags`, P02* | *Verified* |
| *CONV-03* | *LF output, binary mode* | *HLD §5* | *…* | *P01–P10* | *…* |

## 3. Backward traceability (test → requirement)

| Test | Type | Requirement(s) verified |
| :-- | :-- | :-- |
| *P01* | *black-box, public* | *FR-…* |
| *`test_…`* | *unit* | *FR-…* |

## 4. Coverage summary

| Category | Total | Designed | Implemented | Verified |
| :-- | :-- | :-- | :-- | :-- |
| User requirements (UR) | | | | |
| Functional (FR) | | | | |
| Non-functional (NFR) | | | | |
| Conventions (CONV) | | | | |

## 5. Gaps and justifications

*List every requirement that is not verified, with the reason and the plan to close the gap.*
