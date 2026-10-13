# Master Test Plan (MTP) — Concatenate & Number Files

| Field | Value |
| :-- | :-- |
| Project | `02-cat` |
| Tools | dp-cat |
| Implementation language | *py / rs / go* |
| Author | *your name* |
| Version / date | *0.1 — YYYY-MM-DD* |
| Standard | Structure adapted from IEEE 829 / ISO/IEC/IEEE 29119-3 |

> **Purpose of this document.** The MTP defines *how* you will build confidence that the tool
> meets the SRS on all three platforms: test levels, techniques, environments, entry and exit
> criteria, and the actual test cases you will write in addition to the supplied black-box
> suite.
>
> Replace every *italic prompt* below. Delete the prompts when you are done.

## 1. Introduction and scope

### 1.1 Objectives
*What does "tested enough" mean for this project? Tie the answer to SRS acceptance criteria.*

### 1.2 In scope / out of scope
| In scope | Out of scope |
| :-- | :-- |
| *every FR/NFR in the SRS, on Linux, macOS, and Windows* | *…* |

## 2. Test items

| Item | Version / location |
| :-- | :-- |
| dp-cat | `assignment/src/<lang>/` at commit *…* |
| Public black-box suite | `tests/public/` (10 tests) |
| Hidden black-box suite | `tests/private/` (10 tests, run by CI) |

## 3. Test levels and approach

| Level | Purpose | Technique(s) | Tooling | Owner |
| :-- | :-- | :-- | :-- | :-- |
| Unit | *verify functions in isolation* | *equivalence partitioning, boundary-value analysis* | *the language's standard unit-test framework* | *you* |
| Integration | *components working together (e.g. parser → core → output)* | *…* | *…* | *you* |
| System (black-box) | *the specified CLI behavior, byte-exact* | *specification-based* | `make test` → `run-tests.py` | *you* |
| Acceptance | *hidden suite passes on all OSes* | *—* | CI `make test-hidden` | *CI* |
| Static analysis | *style, lint, types* | *—* | `make lint` | *you / CI* |

## 4. Test design

### 4.1 Equivalence partitions and boundaries
*For each input (options, operands, stdin, environment, file states), list the valid and
invalid partitions and the boundary values.*

| Input | Valid partitions | Invalid partitions | Boundaries |
| :-- | :-- | :-- | :-- |
| *…* | | | |

### 4.2 Additional test cases (beyond the supplied suite)
*Write at least ten of your own cases. Cover edge cases, error situations, and
platform-specific behavior (Principle 14). Give each one an ID such as `T-01`.*

| ID | Requirement(s) | Preconditions | Steps / command | Expected result | Level |
| :-- | :-- | :-- | :-- | :-- | :-- |
| *T-01* | *FR-…* | *…* | *…* | *…* | *unit* |

### 4.3 Negative and robustness testing
*Cover invalid options, missing files, permission errors, empty input, very large input, and
binary input. Show how each is tested.*

### 4.4 Performance and resource testing
*Give memory and time checks for each NFR (e.g. "a 2 GiB input completes in under 60 s using
under 64 MiB RSS") and say how you measure them.*

## 5. Test environments

| Environment | OS / version | Toolchain | How provisioned |
| :-- | :-- | :-- | :-- |
| Local | *…* | *…* | *…* |
| CI | ubuntu-latest, macos-latest, windows-latest | *…* | `shared/ci/cross-platform-ci.yml` |

## 6. Entry and exit criteria

- **Entry:** *e.g. the HLD/LLD are approved, `make all` succeeds, and `make lint` is clean.*
- **Exit:** *e.g. all public and hidden black-box tests pass on all three OSes, unit-test line
  coverage is at least 80%, there are no open severity-1/2 defects, and the RTM shows every
  requirement as Verified.*
- **Suspension / resumption:** *…*

## 7. Defect management

*Describe how you record a defect (GitHub issue template, severity scale), how you
re-test a fix, and how you prevent regressions (a new unit test for every fixed defect).*

| Severity | Definition |
| :-- | :-- |
| 1 — Critical | *crash, data loss, or wrong output on a mainline path* |
| 2 — Major | *…* |
| 3 — Minor | *…* |

## 8. Schedule and deliverables

| Milestone | Deliverable | Target date |
| :-- | :-- | :-- |
| *Design complete* | *hld.md, lld.md* | |
| *Implementation complete* | *src/, unit tests* | |
| *Verification complete* | *RTM all Verified, CI green* | |

## 9. Risks and contingencies

| Risk | Mitigation |
| :-- | :-- |
| *Windows-only failure discovered late* | *run CI on all OSes from the first commit* |

## 10. Test summary (complete at the end)

| Metric | Value |
| :-- | :-- |
| Unit tests (pass / total) | |
| Coverage (line / branch) | |
| Public black-box (pass / 10) | |
| Hidden black-box (pass / 10, from CI) | |
| Open defects by severity | |
