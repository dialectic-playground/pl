<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Requirements Traceability Matrix (RTM) — Interactive Accumulator Calculator](#requirements-traceability-matrix-rtm--interactive-accumulator-calculator)
  - [1. User requirements to system requirements](#1-user-requirements-to-system-requirements)
  - [2. Forward traceability](#2-forward-traceability)
  - [3. Backward traceability (test → requirement)](#3-backward-traceability-test-%E2%86%92-requirement)
  - [4. Coverage summary](#4-coverage-summary)
  - [5. Gaps and justifications](#5-gaps-and-justifications)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Requirements Traceability Matrix (RTM) — Interactive Accumulator Calculator

| Field          | Value              |
| :------------- | :----------------- |
| Project        | `37-calc`          |
| Tools          | dp-calc            |
| Author         | _your name_        |
| Version / date | _0.1 — YYYY-MM-DD_ |

> **Purpose of this document.** This lightweight RTM shows that every requirement is
> _designed_, _implemented_, and _verified_, and that nothing was built without a requirement.
> Keep it current. A requirement with an empty cell is a gap.
>
> **How to fill it in.** Create one row for every `UR-` requirement (URD), every `FR-` and
> `NFR-` requirement (SRS), and every `CONV-` requirement the SRS incorporates. Under _Design_,
> cite HLD/LLD sections. Under _Code_, cite files and functions. Under _Verification_, cite
> unit-test names and black-box test IDs (public tests `P01` … `P10`; hidden tests are verified
> by CI and must not be cited). Set _Status_ to one of `Not started`, `Designed`,
> `Implemented`, `Verified`.

## 1. User requirements to system requirements

| User requirement (URD) | Derived system requirements (SRS) |
| :--------------------- | :-------------------------------- |
| _UR-01_                | _FR-01, FR-02, NFR-03_            |

## 2. Forward traceability

| Req. ID   | Summary                  | Design (HLD/LLD)     | Code (file::function) | Verification (unit / black-box)   | Status     |
| :-------- | :----------------------- | :------------------- | :-------------------- | :-------------------------------- | :--------- |
| _FR-01_   | _…_                      | _HLD §3.2, LLD §3.1_ | _`src/…::parse_args`_ | _`test_parse_bundled_flags`, P02_ | _Verified_ |
| _CONV-03_ | _LF output, binary mode_ | _HLD §5_             | _…_                   | _P01–P10_                         | _…_        |

## 3. Backward traceability (test → requirement)

| Test       | Type                | Requirement(s) verified |
| :--------- | :------------------ | :---------------------- |
| _P01_      | _black-box, public_ | _FR-…_                  |
| _`test_…`_ | _unit_              | _FR-…_                  |

## 4. Coverage summary

| Category               | Total | Designed | Implemented | Verified |
| :--------------------- | :---- | :------- | :---------- | :------- |
| User requirements (UR) |       |          |             |          |
| Functional (FR)        |       |          |             |          |
| Non-functional (NFR)   |       |          |             |          |
| Conventions (CONV)     |       |          |             |          |

## 5. Gaps and justifications

_List every requirement that is not verified, with the reason and the plan to close the gap._
