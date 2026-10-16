<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [High-Level Design (HLD) — Standard Terminal Hello World](#high-level-design-hld--standard-terminal-hello-world)
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

# High-Level Design (HLD) — Standard Terminal Hello World

| Field                   | Value                                                                               |
| :---------------------- | :---------------------------------------------------------------------------------- |
| Project                 | `00-hello-world`                                                                    |
| Tools                   | dp-hello                                                                            |
| Implementation language | pl (Perl 5.42, Carton)                                                              |
| Author                  | Brandon Perkins                                                                     |
| Version / date          | 1.0 — 2026-10-13                                                                    |
| Status                  | In review                                                                           |
| Inputs                  | `specs/URD.md`, `specs/SRS.md`, `specs/user-manual.md`, `shared/CLI-CONVENTIONS.md` |

## 1. Introduction

### 1.1 Scope

`dp-hello` writes the greeting `Hello, NAME!` (default `World`) COUNT times (1–1000, default 1)
to standard output, prints help and version text, and reports usage errors with the exact
CONV-13 diagnostics and exit status 2. It reads no input, files, or environment variables,
takes no operands, and runs no subprocesses (SRS §1.2, NFR-07).

### 1.2 Definitions and acronyms

| Term         | Meaning                                                                                         |
| :----------- | :---------------------------------------------------------------------------------------------- |
| Byte string  | A Perl string holding raw bytes (no UTF-8 flag); every argument and output is one               |
| Parse result | The hash returned by the parser: an action, recorded option values, operands, or a syntax error |
| Usage error  | A hash `{ kind => ..., details }` mapped to a CONV-13 message in one place                      |
| ACP          | The Windows ANSI code page (for example 1252), in which perl.exe receives `@ARGV`               |
| `:raw`       | The PerlIO layer with no CRLF translation and no encoding                                       |

### 1.3 References

- SRS §3 (interfaces), §4 (FR-01 … FR-11), §5 (NFR-01 … NFR-07), §6 (diagnostics)
- CLI-CONV §2 (CONV-03, CONV-05), §3 (CONV-07 … CONV-12), §4 (CONV-13 … CONV-15), §8 (CONV-24 … CONV-26, CONV-31)
- User manual, "Help output"

## 2. Requirements summary

| Area                       | SRS requirements                                     | Architectural impact                                                                                     |
| :------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------- |
| Option parsing             | FR-02, FR-06, FR-07, FR-08, FR-10, CONV-07 … CONV-12 | A hand-written scanner (`DP::Hello::Options`) that only records values and stops at `--help`/`--version` |
| Validation                 | FR-03, FR-04, FR-05, FR-09, FR-11                    | A separate post-scan step (`DP::Hello::Validation`), so value and operand errors never beat `--help`     |
| Greeting                   | FR-01, FR-02, FR-04, NFR-05                          | A pure function (`DP::Hello::Greeting`)                                                                  |
| Diagnostics, help, version | FR-07, FR-08, CONV-02, CONV-13 … CONV-15, CONV-23    | One module of fixed texts and the single error-to-message mapping (`DP::Hello::Messages`)                |
| Byte-exact output          | NFR-01, CONV-03, CONV-05, CONV-25                    | `:raw` streams (`DP::Hello::Output`) and UTF-8 arguments on every OS (`DP::Hello::Platform`)             |
| Robustness, testability    | NFR-03, NFR-04, NFR-05                               | A pure core `run(@args) -> (stdout, stderr, status)` with a thin I/O shell `main`                        |
| Build                      | NFR-06                                               | Makefile hooks around `perl`, prove, Carton, Perl::Critic, perltidy                                      |

## 3. Architectural overview

### 3.1 Context diagram

```text
                  ┌──────────────────────────────┐
   argv ────────▶ │ dp-hello (perl, src/bin)     │ ──▶ stdout (greeting / help / version)
   (UTF-8 bytes;  │   DP::Hello::main            │ ──▶ stderr (CONV-13 diagnostic)
    Windows: ACP) └──────────────────────────────┘ ──▶ exit status 0 / 2
   stdin, files, environment, network, subprocesses: not used (NFR-07, CONV-26)
```

### 3.2 Component (module) decomposition

| Component               | Responsibility                                                                        | Depends on                            |
| :---------------------- | :------------------------------------------------------------------------------------ | :------------------------------------ |
| `src/bin/dp-hello`      | Launcher: put `../lib` on `@INC`, call `DP::Hello::main(@ARGV)`, exit with its status | `DP::Hello`                           |
| `DP::Hello`             | Wire the units: pure `run`, I/O shell `main`                                          | all below                             |
| `DP::Hello::Options`    | Scan the arguments into a parse result or a syntax error (CONV-07 … CONV-12)          | —                                     |
| `DP::Hello::Validation` | Turn a parse result into `{ name, count }` or a usage error (FR-03, FR-05, FR-09)     | —                                     |
| `DP::Hello::Greeting`   | Build the greeting text (pure)                                                        | —                                     |
| `DP::Hello::Messages`   | Help text, version line, usage error → two diagnostic lines                           | —                                     |
| `DP::Hello::Output`     | Binary streams; write and flush bytes, reporting failure                              | —                                     |
| `DP::Hello::Platform`   | Arguments as UTF-8 bytes (Windows: ACP → UTF-8)                                       | core `Encode`, `Win32` (Windows only) |

### 3.3 Data flow

1. `main` switches STDOUT/STDERR to `:raw` and converts `@ARGV` to UTF-8 byte strings (`Platform`).
2. `run` calls `parse_args`. A syntax error becomes a diagnostic (status 2); `help`/`version`
   return the fixed text (status 0).
3. Otherwise `validate` checks operands, then the winning `--name`, then the winning `--count`;
   an error becomes a diagnostic (status 2).
4. `greeting_text(name, count)` builds the output (status 0).
5. `main` writes stdout (or stderr) in one `print`, flushes, and returns the status.

## 4. Key design decisions

| #   | Decision                                                             | Alternatives considered                             | Rationale                                                                                                         |
| :-- | :------------------------------------------------------------------- | :-------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------- |
| D1  | Hand-written parser                                                  | Getopt::Long, Getopt::Std                           | Required by the brief; Getopt::Long abbreviates long options and words diagnostics differently (CONV-08, CONV-13) |
| D2  | Parse, then validate                                                 | Validate while scanning                             | CONV-12: value and operand errors must never beat a later `--help`                                                |
| D3  | Errors are data (`{ kind, ... }`), messages built in `Messages` only | `die` with strings at the detection site            | One mapping place (Principle 13); no exceptions, so no stack traces (CONV-24)                                     |
| D4  | Pure `run` returning `(stdout, stderr, status)`                      | Printing from deep inside                           | End-to-end unit tests without capturing streams; output is all-or-nothing (FR-11)                                 |
| D5  | Work on byte strings, never decode to characters                     | `use utf8` / `-CA` / `:encoding(UTF-8)` layers      | Echoes the user's bytes exactly, including invalid UTF-8 (CONV-05); no locale influence (CONV-06)                 |
| D6  | Buffer the whole output, one `print`                                 | Print line by line                                  | At most 1000 × (9 + name) bytes; simpler error handling (EPIPE once)                                              |
| D7  | Windows: decode `@ARGV` from the ACP with core `Encode`              | Win32::API + GetCommandLineW (not core)             | Core-only and dependency-free; see §8 for the limitation                                                          |
| D8  | Dev tools locked with Carton into `local/`                           | Global cpanm installs, exact cpanfile versions only | `cpanfile.snapshot` locks transitive versions; same Perl::Tidy everywhere, so formatting never drifts             |

## 5. Cross-platform strategy

- **Line endings (CONV-03):** `DP::Hello::Output::binary_streams` sets `:raw` on STDOUT and
  STDERR, removing Windows' `:crlf` layer; all texts contain `\n` only.
- **Arguments (CONV-05):** `DP::Hello::Platform` isolates the difference. POSIX arguments are
  bytes and pass through. On Windows the C runtime hands perl.exe the arguments in the ANSI code
  page; they are decoded with `Encode` (`cp<ACP>`) and re-encoded as UTF-8 (unchanged if the
  ACP is 65001).
- **Paths (CONV-19 … CONV-21):** not applicable; no paths are used.
- **Launching:** the `#!/usr/bin/env perl` launcher locates its library with `FindBin`; the
  black-box runner starts `perl` itself on Windows. Make recipes invoke every tool as
  `perl <script>` or `perl -M<module>` so `.bat` wrappers and Git Bash's own perl are irrelevant.

## 6. Error handling and diagnostics

Parser and validator return error hashes (`invalid_option`, `unrecognized_option`,
`short_requires_argument`, `long_requires_argument`, `no_argument_allowed`, `invalid_argument`,
`extra_operand`). `DP::Hello::run` passes them to `DP::Hello::Messages::usage_diagnostic`, the
only place that produces CONV-13 text plus the CONV-14 hint, and returns status 2 with empty
stdout. dp-hello has no runtime errors (CONV-16 does not apply); a failed stdout write (EPIPE)
ends the process quietly (CONV-25).

## 7. Non-functional design

| Quality attribute           | SRS reference   | How the design achieves it                                                                                                                                                                               |
| :-------------------------- | :-------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Performance / memory        | NFR-02, CONV-31 | Only core modules are loaded; output ≤ ~1 MiB is built once. Measured on Linux (perl 5.42.3): 20–30 ms for `-c 1000`, peak RSS 8.9 MiB against a 5.1 MiB `perl -e 1` baseline (≈ 3.8 MiB above baseline) |
| Portability                 | NFR-01          | `:raw` output, byte strings, UTF-8 arguments on Windows (§5); CI on three OSes                                                                                                                           |
| Security / input validation | NFR-07          | Strict digit-only count check before numeric conversion; no files, environment, or subprocesses                                                                                                          |
| Maintainability             | NFR-04          | One module per responsibility (§3.2); Perl::Critic severity 3 and perltidy enforced by `make lint`                                                                                                       |

## 8. Risks and open issues

| Risk / issue                                                                                  | Likelihood            | Impact        | Mitigation                                                                                                                                       |
| :-------------------------------------------------------------------------------------------- | :-------------------- | :------------ | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| Windows: characters outside the ACP are replaced (`?`) by the C runtime before perl sees them | M (non-Western names) | M             | Documented limitation; `Zoë` and all cp1252 names work on the default runners. A wide command line would need a non-core FFI module (Win32::API) |
| Git Bash's `/usr/bin/perl` shadows the intended Perl on Windows                               | H                     | H             | CI prepends the actions-setup-perl directory via `BASH_ENV`; README tells users to put their Perl first on PATH                                  |
| CPAN removes a locked distribution                                                            | L                     | L (lint only) | Carton fetches from BackPAN-backed mirrors; update the snapshot deliberately                                                                     |

## 9. Approval

| Role     | Name            | Date       | Decision  |
| :------- | :-------------- | :--------- | :-------- |
| Author   | Brandon Perkins | 2026-10-13 | Submitted |
| Reviewer |                 |            |           |
