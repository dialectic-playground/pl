<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Low-Level Design (LLD) — System Resource Telemetry Daemonic CLI](#low-level-design-lld--system-resource-telemetry-daemonic-cli)
  - [1. Source layout](#1-source-layout)
  - [2. Data types](#2-data-types)
    - [2.1 `Config` _(example)_](#21-config-example)
    - [2.2 Error type](#22-error-type)
  - [3. Module and function specifications](#3-module-and-function-specifications)
    - [3.x `function_name`](#3x-function_name)
  - [4. Algorithms](#4-algorithms)
  - [5. Platform-specific details](#5-platform-specific-details)
  - [6. Resource management](#6-resource-management)
  - [7. Sequence of one invocation](#7-sequence-of-one-invocation)
  - [8. Design-to-code checklist](#8-design-to-code-checklist)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Low-Level Design (LLD) — System Resource Telemetry Daemonic CLI

| Field                   | Value                                                            |
| :---------------------- | :--------------------------------------------------------------- |
| Project                 | `10-sys-monitor`                                                 |
| Tools                   | dp-sysmon                                                        |
| Implementation language | _py / rs / go_                                                   |
| Author                  | _your name_                                                      |
| Version / date          | _0.1 — YYYY-MM-DD_                                               |
| Status                  | _Draft / In review / Approved_                                   |
| Inputs                  | `assignment/hld.md`, `specs/SRS.md`, `shared/CLI-CONVENTIONS.md` |

> **Purpose of this document.** The LLD refines every HLD component down to modules, data types,
> function signatures, algorithms, and error cases. Another engineer should be able to implement
> the tool from this document _and get the same structure you did_.
>
> Replace every _italic prompt_ below. Delete the prompts when you are done.

## 1. Source layout

_Show the directory and file tree under `assignment/src/<lang>/` and give the purpose of each
file._

```text
src/<lang>/
└── …
```

## 2. Data types

_Define each significant type: a struct, class, enum, or record. Give its fields, the
invariants it maintains, and which requirement it supports._

### 2.1 `Config` _(example)_

| Field          | Type   | Default | Constraint / invariant | SRS    |
| :------------- | :----- | :------ | :--------------------- | :----- |
| _number_lines_ | _bool_ | _false_ | _—_                    | _FR-…_ |

### 2.2 Error type

_List every error variant and give, for each, the exact diagnostic text and exit status it
produces (CONV-13, CONV-16, and the SRS)._

| Variant      | Diagnostic (stderr)                       | Exit status |
| :----------- | :---------------------------------------- | :---------- |
| _Usage(msg)_ | `<tool>: <msg>` + `Try '<tool> --help' …` | 2           |

## 3. Module and function specifications

_Repeat this block for every public function, and for every private function that is not
trivial._

### 3.x `function_name`

- **Signature:** _`fn parse_args(args: &[String]) -> Result<Config, UsageError>`_
- **Responsibility:** _one sentence_
- **Preconditions:** _…_
- **Postconditions / return value:** _…_
- **Errors:** _which variants it returns, and when_
- **Algorithm:** _numbered steps or pseudocode_
- **Complexity:** _time O(…), memory O(…)_
- **Satisfies:** _FR-…, CONV-…_
- **Unit tests:** _the test names in your unit-test file_

## 4. Algorithms

_Describe each non-trivial algorithm in detail, for example line numbering, backward seeking,
regex matching, LCS, or file locking. Include pseudocode and edge cases, and say why you chose
it over the alternatives._

## 5. Platform-specific details

_Note each API call that behaves differently on Linux, macOS, or Windows, and how your code
handles the difference. Examples: binary stdout, path separators, process spawning, file
locking, and performance counters._

| Concern | Linux | macOS | Windows | Abstraction |
| :------ | :---- | :---- | :------ | :---------- |
| _…_     |       |       |         |             |

## 6. Resource management

_Explain how file handles, buffers, child processes, sockets, and locks are acquired and
released on every path, including error paths. Give buffer sizes and memory bounds._

## 7. Sequence of one invocation

_Trace a representative command, for example the first public test, step by step through your
functions._

## 8. Design-to-code checklist

| HLD component | LLD section | Source file(s) | Unit-test file(s) |
| :------------ | :---------- | :------------- | :---------------- |
| _cli_         | _§3.1_      | _…_            | _…_               |
