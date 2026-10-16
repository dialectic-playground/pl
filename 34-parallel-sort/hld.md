<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [High-Level Design (HLD) — Distributed Parallel Sorting & Stream Merging](#high-level-design-hld--distributed-parallel-sorting--stream-merging)
  - [1. Introduction](#1-introduction)
    - [1.1 Scope](#11-scope)
    - [1.2 Definitions and acronyms](#12-definitions-and-acronyms)
    - [1.3 References](#13-references)
  - [2. Requirements summary](#2-requirements-summary)
  - [3. Architectural overview](#3-architectural-overview)
    - [3.1 Context diagram](#31-context-diagram)
    - [3.2 Component (module) decomposition](#32-component-module-decomposition)
    - [3.3 Data flow](#33-data-flow)
  - [4. Key design decisions](#4-key-design-decisions)
  - [5. Cross-platform strategy](#5-cross-platform-strategy)
  - [6. Error handling and diagnostics](#6-error-handling-and-diagnostics)
  - [7. Non-functional design](#7-non-functional-design)
  - [8. Risks and open issues](#8-risks-and-open-issues)
  - [9. Approval](#9-approval)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# High-Level Design (HLD) — Distributed Parallel Sorting & Stream Merging

| Field                   | Value                                                                               |
| :---------------------- | :---------------------------------------------------------------------------------- |
| Project                 | `34-parallel-sort`                                                                  |
| Tools                   | dp-sort-host dp-sort-child                                                          |
| Implementation language | _py / rs / go_                                                                      |
| Author                  | _your name_                                                                         |
| Version / date          | _0.1 — YYYY-MM-DD_                                                                  |
| Status                  | _Draft / In review / Approved_                                                      |
| Inputs                  | `specs/URD.md`, `specs/SRS.md`, `specs/user-manual.md`, `shared/CLI-CONVENTIONS.md` |

> **Purpose of this document.** The HLD explains _what_ the system's major parts are and _how
> they cooperate_ to satisfy the SRS, without going down to function signatures (that belongs
> in the LLD). A reviewer should be able to judge from this document alone whether the design
> can meet every functional and non-functional requirement.
>
> Replace every _italic prompt_ below. Delete the prompts when you are done.

## 1. Introduction

### 1.1 Scope

_One paragraph: what the tool does, and what it explicitly does not do, quoting the SRS scope._

### 1.2 Definitions and acronyms

| Term   | Meaning      |
| :----- | :----------- |
| _term_ | _definition_ |

### 1.3 References

- _SRS section numbers you rely on most heavily_

## 2. Requirements summary

_Summarize the main functional areas (group the SRS FR-IDs) and the non-functional requirements
that drive the architecture, for example streaming memory limits, cross-platform behavior, and
exit-status rules._

| Area                  | SRS requirements                   | Architectural impact                     |
| :-------------------- | :--------------------------------- | :--------------------------------------- |
| _e.g. Option parsing_ | _FR-01 … FR-05, CONV-07 … CONV-15_ | _a dedicated argument-parsing component_ |

## 3. Architectural overview

### 3.1 Context diagram

_Show the tool and everything it talks to: the user or shell, stdin, stdout, stderr, the file
system, child processes, the network, and OS APIs. ASCII art or Mermaid is fine._

```text
          argv ──▶ ┌───────────┐ ──▶ stdout
         stdin ──▶ │  dp-sort-host dp-sort-child │ ──▶ stderr
    filesystem ◀──▶└───────────┘ ──▶ exit status
```

### 3.2 Component (module) decomposition

_List each component with one responsibility (SRP). Typical components are a CLI parser, a
configuration model, core logic, I/O adapters, a platform abstraction, and diagnostics._

| Component | Responsibility                                        | Depends on |
| :-------- | :---------------------------------------------------- | :--------- |
| _cli_     | _turn argv into a validated Config, or a usage error_ | _—_        |

### 3.3 Data flow

_Describe, or draw, how one invocation flows through the components, from argv to the exit
status._

## 4. Key design decisions

_Record each significant decision in ADR style: context, the options considered, the decision,
and its consequences. Cover at least the following: streaming vs. buffering, error-propagation
strategy, platform abstraction, and data structures._

| #   | Decision | Alternatives considered | Rationale |
| :-- | :------- | :---------------------- | :-------- |
| D1  | _…_      | _…_                     | _…_       |

## 5. Cross-platform strategy

_Explain how the design satisfies the Linux, macOS, and Windows requirements. Cover line
endings (CONV-03), binary-mode output, path handling (CONV-19 … CONV-21), and any
OS-specific APIs. Name the module that isolates platform differences._

## 6. Error handling and diagnostics

_Show how errors are represented internally, how they map to the CONV-13/CONV-16 messages and
the exit statuses in the SRS, and where that mapping happens. It should happen in exactly one
place._

## 7. Non-functional design

| Quality attribute           | SRS reference | How the design achieves it |
| :-------------------------- | :------------ | :------------------------- |
| Performance / memory        | _NFR-…_       | _…_                        |
| Portability                 | _NFR-…_       | _…_                        |
| Security / input validation | _NFR-…_       | _…_                        |
| Maintainability             | _NFR-…_       | _…_                        |

## 8. Risks and open issues

| Risk / issue | Likelihood | Impact  | Mitigation |
| :----------- | :--------- | :------ | :--------- |
| _…_          | _L/M/H_    | _L/M/H_ | _…_        |

## 9. Approval

| Role     | Name | Date | Decision |
| :------- | :--- | :--- | :------- |
| Author   |      |      |          |
| Reviewer |      |      |          |
