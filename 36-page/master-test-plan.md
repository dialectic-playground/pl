<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Master Test Plan (MTP) — Stream Text Pagination Utility](#master-test-plan-mtp--stream-text-pagination-utility)
  - [1. Introduction and scope](#1-introduction-and-scope)
    - [1.1 Objectives](#11-objectives)
    - [1.2 In scope / out of scope](#12-in-scope--out-of-scope)
  - [2. Test items](#2-test-items)
  - [3. Test levels and approach](#3-test-levels-and-approach)
  - [4. Test design](#4-test-design)
    - [4.1 Equivalence partitions and boundaries](#41-equivalence-partitions-and-boundaries)
    - [4.2 Additional test cases (beyond the supplied suite)](#42-additional-test-cases-beyond-the-supplied-suite)
    - [4.3 Negative and robustness testing](#43-negative-and-robustness-testing)
    - [4.4 Performance and resource testing](#44-performance-and-resource-testing)
  - [5. Test environments](#5-test-environments)
  - [6. Entry and exit criteria](#6-entry-and-exit-criteria)
  - [7. Defect management](#7-defect-management)
  - [8. Schedule and deliverables](#8-schedule-and-deliverables)
  - [9. Risks and contingencies](#9-risks-and-contingencies)
  - [10. Test summary (complete at the end)](#10-test-summary-complete-at-the-end)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Master Test Plan (MTP) — Stream Text Pagination Utility

| Field                   | Value                                                  |
| :---------------------- | :----------------------------------------------------- |
| Project                 | `36-page`                                              |
| Tools                   | dp-page                                                |
| Implementation language | _py / rs / go_                                         |
| Author                  | _your name_                                            |
| Version / date          | _0.1 — YYYY-MM-DD_                                     |
| Standard                | Structure adapted from IEEE 829 / ISO/IEC/IEEE 29119-3 |

> **Purpose of this document.** The MTP defines _how_ you will build confidence that the tool
> meets the SRS on all three platforms: test levels, techniques, environments, entry and exit
> criteria, and the actual test cases you will write in addition to the supplied black-box
> suite.
>
> Replace every _italic prompt_ below. Delete the prompts when you are done.

## 1. Introduction and scope

### 1.1 Objectives

_What does "tested enough" mean for this project? Tie the answer to SRS acceptance criteria._

### 1.2 In scope / out of scope

| In scope                                                | Out of scope |
| :------------------------------------------------------ | :----------- |
| _every FR/NFR in the SRS, on Linux, macOS, and Windows_ | _…_          |

## 2. Test items

| Item                   | Version / location                     |
| :--------------------- | :------------------------------------- |
| dp-page                | `assignment/src/<lang>/` at commit _…_ |
| Public black-box suite | `tests/public/` (10 tests)             |
| Hidden black-box suite | `tests/private/` (10 tests, run by CI) |

## 3. Test levels and approach

| Level              | Purpose                                                     | Technique(s)                                        | Tooling                                       | Owner      |
| :----------------- | :---------------------------------------------------------- | :-------------------------------------------------- | :-------------------------------------------- | :--------- |
| Unit               | _verify functions in isolation_                             | _equivalence partitioning, boundary-value analysis_ | _the language's standard unit-test framework_ | _you_      |
| Integration        | _components working together (e.g. parser → core → output)_ | _…_                                                 | _…_                                           | _you_      |
| System (black-box) | _the specified CLI behavior, byte-exact_                    | _specification-based_                               | `make test` → `run-tests.py`                  | _you_      |
| Acceptance         | _hidden suite passes on all OSes_                           | _—_                                                 | CI `make test-hidden`                         | _CI_       |
| Static analysis    | _style, lint, types_                                        | _—_                                                 | `make lint`                                   | _you / CI_ |

## 4. Test design

### 4.1 Equivalence partitions and boundaries

_For each input (options, operands, stdin, environment, file states), list the valid and
invalid partitions and the boundary values._

| Input | Valid partitions | Invalid partitions | Boundaries |
| :---- | :--------------- | :----------------- | :--------- |
| _…_   |                  |                    |            |

### 4.2 Additional test cases (beyond the supplied suite)

_Write at least ten of your own cases. Cover edge cases, error situations, and
platform-specific behavior (Principle 14). Give each one an ID such as `T-01`._

| ID     | Requirement(s) | Preconditions | Steps / command | Expected result | Level  |
| :----- | :------------- | :------------ | :-------------- | :-------------- | :----- |
| _T-01_ | _FR-…_         | _…_           | _…_             | _…_             | _unit_ |

### 4.3 Negative and robustness testing

_Cover invalid options, missing files, permission errors, empty input, very large input, and
binary input. Show how each is tested._

### 4.4 Performance and resource testing

_Give memory and time checks for each NFR (e.g. "a 2 GiB input completes in under 60 s using
under 64 MiB RSS") and say how you measure them._

## 5. Test environments

| Environment | OS / version                                | Toolchain | How provisioned                   |
| :---------- | :------------------------------------------ | :-------- | :-------------------------------- |
| Local       | _…_                                         | _…_       | _…_                               |
| CI          | ubuntu-latest, macos-latest, windows-latest | _…_       | `shared/ci/cross-platform-ci.yml` |

## 6. Entry and exit criteria

- **Entry:** _e.g. the HLD/LLD are approved, `make all` succeeds, and `make lint` is clean._
- **Exit:** _e.g. all public and hidden black-box tests pass on all three OSes, unit-test line
  coverage is at least 80%, there are no open severity-1/2 defects, and the RTM shows every
  requirement as Verified._
- **Suspension / resumption:** _…_

## 7. Defect management

_Describe how you record a defect (GitHub issue template, severity scale), how you
re-test a fix, and how you prevent regressions (a new unit test for every fixed defect)._

| Severity     | Definition                                             |
| :----------- | :----------------------------------------------------- |
| 1 — Critical | _crash, data loss, or wrong output on a mainline path_ |
| 2 — Major    | _…_                                                    |
| 3 — Minor    | _…_                                                    |

## 8. Schedule and deliverables

| Milestone                 | Deliverable                  | Target date |
| :------------------------ | :--------------------------- | :---------- |
| _Design complete_         | _hld.md, lld.md_             |             |
| _Implementation complete_ | _src/, unit tests_           |             |
| _Verification complete_   | _RTM all Verified, CI green_ |             |

## 9. Risks and contingencies

| Risk                                   | Mitigation                                 |
| :------------------------------------- | :----------------------------------------- |
| _Windows-only failure discovered late_ | _run CI on all OSes from the first commit_ |

## 10. Test summary (complete at the end)

| Metric                                | Value |
| :------------------------------------ | :---- |
| Unit tests (pass / total)             |       |
| Coverage (line / branch)              |       |
| Public black-box (pass / 10)          |       |
| Hidden black-box (pass / 10, from CI) |       |
| Open defects by severity              |       |
