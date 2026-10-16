<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Low-Level Design (LLD) — Standard Terminal Hello World](#low-level-design-lld--standard-terminal-hello-world)
  - [1. Source layout](#1-source-layout)
  - [2. Data types](#2-data-types)
    - [2.1 Option value](#21-option-value)
    - [2.2 Parse result (returned by `parse_args`)](#22-parse-result-returned-by-parse_args)
    - [2.3 Config (returned by `validate`)](#23-config-returned-by-validate)
    - [2.4 Error type](#24-error-type)
  - [3. Module and function specifications](#3-module-and-function-specifications)
    - [3.1 `DP::Hello::Options::parse_args`](#31-dphellooptionsparse_args)
    - [3.2 `DP::Hello::Validation::validate`, `validate_name`, `validate_count`](#32-dphellovalidationvalidate-validate_name-validate_count)
    - [3.3 `DP::Hello::Greeting::greeting_line`, `greeting_text`](#33-dphellogreetinggreeting_line-greeting_text)
    - [3.4 `DP::Hello::Messages::help_text`, `version_text`, `usage_diagnostic`](#34-dphellomessageshelp_text-version_text-usage_diagnostic)
    - [3.5 `DP::Hello::Platform::command_line_arguments`, `from_code_page`](#35-dphelloplatformcommand_line_arguments-from_code_page)
    - [3.6 `DP::Hello::Output::binary_streams`, `write_bytes`](#36-dphellooutputbinary_streams-write_bytes)
    - [3.7 `DP::Hello::run`, `DP::Hello::main`](#37-dphellorun-dphellomain)
  - [4. Algorithms](#4-algorithms)
    - [4.1 Argument scan](#41-argument-scan)
    - [4.2 Count validation](#42-count-validation)
  - [5. Platform-specific details](#5-platform-specific-details)
  - [6. Resource management](#6-resource-management)
  - [7. Sequence of one invocation](#7-sequence-of-one-invocation)
  - [8. Design-to-code checklist](#8-design-to-code-checklist)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Low-Level Design (LLD) — Standard Terminal Hello World

| Field                   | Value                                                 |
| :---------------------- | :---------------------------------------------------- |
| Project                 | `00-hello-world`                                      |
| Tools                   | dp-hello                                              |
| Implementation language | pl (Perl 5.42, Carton)                                |
| Author                  | Brandon Perkins                                       |
| Version / date          | 1.0 — 2026-10-13                                      |
| Status                  | In review                                             |
| Inputs                  | `hld.md`, `specs/SRS.md`, `shared/CLI-CONVENTIONS.md` |

## 1. Source layout

```text
00-hello-world/
├── Makefile                 # BASE-MAKEFILE hooks (prove, Carton, Perl::Critic, perltidy)
├── cpanfile                 # develop deps, exact versions (Perl::Critic, Perl::Tidy)
├── cpanfile.snapshot        # Carton lockfile (all transitive versions)
├── .perlcriticrc .perltidyrc
└── src/
    ├── bin/dp-hello         # #!/usr/bin/env perl launcher (BIN_DIR)
    ├── lib/DP/Hello.pm      # run (pure core), main (I/O shell)
    ├── lib/DP/Hello/
    │   ├── Options.pm       # parse_args: the CONV-07 … CONV-12 scanner
    │   ├── Validation.pm    # validate, validate_name, validate_count
    │   ├── Greeting.pm      # greeting_line, greeting_text (pure)
    │   ├── Messages.pm      # help_text, version_text, usage_diagnostic
    │   ├── Output.pm        # binary_streams, write_bytes
    │   └── Platform.pm      # command_line_arguments, from_code_page
    └── t/                   # Test::More: options, validation, greeting, messages,
                             # platform, run, launcher (.t)
```

## 2. Data types

All values are plain Perl hashes of byte strings; nothing is decoded to characters.

### 2.1 Option value

| Field    | Type        | Constraint / invariant                              | SRS            |
| :------- | :---------- | :-------------------------------------------------- | :------------- |
| `value`  | byte string | exactly as given (may be empty, may start with `-`) | FR-02, CONV-15 |
| `option` | string      | the spelling used: `-n`, `--name`, `-c`, `--count`  | FR-03, CONV-13 |

### 2.2 Parse result (returned by `parse_args`)

| Shape                                                               | Meaning                                                  |
| :------------------------------------------------------------------ | :------------------------------------------------------- |
| `{ action => 'help' }` / `{ action => 'version' }`                  | the scan reached `--help` / `--version` first            |
| `{ error => \%error }`                                              | an option syntax error came first                        |
| `{ action => 'greet', name => $v, count => $v, operands => \@ops }` | `$v` is an option value or `undef`; last occurrence wins |

### 2.3 Config (returned by `validate`)

| Field   | Type        | Default | Constraint / invariant | SRS           |
| :------ | :---------- | :------ | :--------------------- | :------------ |
| `name`  | byte string | `World` | non-empty              | FR-01 … FR-03 |
| `count` | integer     | 1       | 1 ≤ count ≤ 1000       | FR-04, FR-05  |

### 2.4 Error type

Each error is `{ kind => ..., details }`; `DP::Hello::Messages::usage_diagnostic` appends the
CONV-14 line `Try 'dp-hello --help' for more information.` Every variant exits with status 2.

| Variant (`kind`)          | Details                | Diagnostic first line (stderr)                        |
| :------------------------ | :--------------------- | :---------------------------------------------------- |
| `invalid_option`          | `letter`               | `dp-hello: invalid option -- 'x'`                     |
| `unrecognized_option`     | `option` (whole token) | `dp-hello: unrecognized option '--nme=Ada'`           |
| `short_requires_argument` | `letter`               | `dp-hello: option requires an argument -- 'n'`        |
| `long_requires_argument`  | `option`               | `dp-hello: option '--name' requires an argument`      |
| `no_argument_allowed`     | `option`               | `dp-hello: option '--help' doesn't allow an argument` |
| `invalid_argument`        | `value`, `option`      | `dp-hello: invalid argument '0' for '--count'`        |
| `extra_operand`           | `operand`              | `dp-hello: extra operand 'extra'`                     |

## 3. Module and function specifications

### 3.1 `DP::Hello::Options::parse_args`

- **Signature:** `parse_args(@args) -> \%parse_result`
- **Responsibility:** recognize option syntax, left to right, recording values only.
- **Preconditions:** `@args` are byte strings without the program name.
- **Postconditions / return value:** a parse result (§2.2).
- **Errors:** `invalid_option`, `unrecognized_option`, `short_requires_argument`,
  `long_requires_argument`, `no_argument_allowed`.
- **Algorithm:** see §4.1.
- **Complexity:** O(total argument length) time and memory.
- **Satisfies:** FR-02, FR-06, FR-07, FR-08, FR-10, CONV-07 … CONV-12, CONV-22.
- **Unit tests:** `options.t`: `no arguments`, `name forms`, `values beginning with a dash`,
  `bundling (CONV-07)`, `count forms`, `last occurrence wins (CONV-11)`,
  `operands and terminator (CONV-09, CONV-10)`, `help and version (CONV-12)`,
  `syntax errors (CONV-13)`.

### 3.2 `DP::Hello::Validation::validate`, `validate_name`, `validate_count`

- **Signatures:** `validate(\%parsed) -> (\%config, undef) | (undef, \%error)`;
  `validate_name(\%value)` / `validate_count(\%value) -> ($v, undef) | (undef, \%error)`.
- **Responsibility:** post-scan checks in a fixed order: first operand → `extra_operand`; the
  winning name must be non-empty; the winning count must match `\A[0-9]+\z`, and after removing
  leading zeros have at most 4 digits and a value in 1–1000. Errors are `invalid_argument` with
  the value and the option as written.
- **Complexity:** O(length of the values).
- **Satisfies:** FR-01, FR-03, FR-04, FR-05, FR-06, FR-09.
- **Unit tests:** `validation.t`: `defaults`, `name`, `count boundaries`,
  `operands are rejected first`, `name is checked before count`, `valid configuration`.

### 3.3 `DP::Hello::Greeting::greeting_line`, `greeting_text`

- **Signatures:** `greeting_line($name) -> "Hello, $name!\n"`;
  `greeting_text($name, $count) -> greeting_line($name) x $count` (empty for `$count <= 0`).
- **Responsibility:** pure greeting construction; no I/O, no globals.
- **Satisfies:** FR-01, FR-02, FR-04, NFR-05.
- **Unit tests:** `greeting.t` (default greeting, spaces, UTF-8 bytes, leading dash, 1/3/0/1000
  lines, LF only).

### 3.4 `DP::Hello::Messages::help_text`, `version_text`, `usage_diagnostic`

- **Responsibility:** fixed help text (heredoc, byte-for-byte the user manual), version line,
  and the only error → message mapping (a table of closures keyed by `kind`).
- **Satisfies:** FR-07, FR-08, CONV-02, CONV-13 … CONV-15, CONV-23.
- **Unit tests:** `messages.t` (version line, help text byte for byte, LF only, every variant).

### 3.5 `DP::Hello::Platform::command_line_arguments`, `from_code_page`

- **Signatures:** `command_line_arguments(@ARGV) -> @utf8_args`;
  `from_code_page($code_page, @args) -> @utf8_args`.
- **Responsibility:** on POSIX return the arguments unchanged; on Windows obtain the ACP with
  `Win32::GetACP()` (inside `eval`, so a failure leaves the arguments unchanged) and convert
  with `from_code_page`: unchanged for 65001 or an unknown code page, otherwise
  `encode('UTF-8', find_encoding("cp$cp")->decode($arg))`.
- **Satisfies:** CONV-05, FR-02.
- **Unit tests:** `platform.t` (cp1252 and cp1251 conversion, 65001, unknown code page, POSIX
  pass-through); `launcher.t` (`a non-ASCII name is printed as UTF-8`, through the ACP on Windows).

### 3.6 `DP::Hello::Output::binary_streams`, `write_bytes`

- **Responsibility:** `binmode STDOUT/STDERR, ':raw'`; `write_bytes($fh, $bytes)` prints and
  flushes, returning false on failure (EPIPE on Windows; SIGPIPE ends the process on POSIX).
- **Satisfies:** CONV-03, CONV-25, NFR-01.
- **Unit tests:** `launcher.t` (exact bytes, no CR, from a separate process).

### 3.7 `DP::Hello::run`, `DP::Hello::main`

- **Signatures:** `run(@args) -> ($stdout, $stderr, $status)`; `main(@ARGV) -> $status`.
- **Algorithm (`run`):** parse; error → `('', usage_diagnostic, 2)`; help/version →
  `(text, '', 0)`; validate; error → `('', usage_diagnostic, 2)`; else
  `(greeting_text(name, count), '', 0)`.
- **Algorithm (`main`):** `binary_streams`; `run(command_line_arguments(@ARGV))`; write stdout
  (return 1 if that fails, CONV-25), write stderr, return the status. The launcher `exit`s with it.
- **Satisfies:** FR-01 … FR-11, NFR-03, NFR-04, CONV-12, CONV-14, CONV-24.
- **Unit tests:** `run.t` (every FR acceptance criterion, CONV-12 precedence), `launcher.t`.

## 4. Algorithms

### 4.1 Argument scan

```text
values := {}; operands := []
while args not empty:
    token := shift args
    if token == "--":            operands += args; stop                     (CONV-09)
    elif token starts with "--": split at the first "=" into name[, inline]
        name in {help, version}: inline given → no_argument_allowed; else return action
        name in {name, count}:   value := inline, else shift args, else long_requires_argument
                                 values[name] := {value, "--name"}          (CONV-11)
        otherwise:               unrecognized_option(token)                 (CONV-08)
    elif token matches "-" + one character:
        letter := next UTF-8 character (a whole sequence, else one byte)
        letter not in {n, c}:    invalid_option(letter)
        value := rest of token, else shift args, else short_requires_argument
    else:                        operands += token                          (CONV-10)
return greet(values, operands)
```

Both short options take a value, so a bundle such as `-c2` or `-cn` always ends at the first
letter (CONV-07). A separate value is consumed even if it starts with `-` (`-n --help` greets
`--help`), as getopt does. Long options must match exactly; no abbreviation (CONV-08).

### 4.2 Count validation

Digits only (`\A[0-9]+\z`; `\z`, not `$`, so a trailing newline is rejected); strip leading
zeros but keep one digit; more than 4 digits → invalid without numeric conversion (no
overflow or floating point for huge inputs); then 1 ≤ n ≤ 1000.

## 5. Platform-specific details

| Concern            | Linux                                  | macOS | Windows                                           | Abstraction                        |
| :----------------- | :------------------------------------- | :---- | :------------------------------------------------ | :--------------------------------- |
| Output newline     | `:unix:perlio`, no translation         | same  | default `:crlf` removed by `:raw`                 | `Output::binary_streams`           |
| Argument bytes     | UTF-8 bytes as given                   | same  | ANSI code page → decoded, re-encoded as UTF-8     | `Platform::command_line_arguments` |
| Broken pipe        | SIGPIPE terminates quietly             | same  | `print` fails → exit 1 quietly                    | `Output::write_bytes`, `main`      |
| Launch             | `#!/usr/bin/env perl`                  | same  | runner starts `perl` itself; Git Bash honors `#!` | `src/bin/dp-hello`                 |
| Installed launcher | `#!/bin/sh` exec of the absolute `$^X` | same  | same, Windows path single-quoted                  | `Makefile` `DP_INSTALL`            |

## 6. Resource management

No files, sockets, or child processes are opened by the tool. The only buffer is the output
string: at most 1000 × (`Hello,` + name + `!\n`) bytes, built once and written with one
`print` followed by a flush. Memory is O(count × name length); peak RSS is ≈ 3.8 MiB above the
perl baseline (CONV-31, see HLD §7).

## 7. Sequence of one invocation

P06, `dp-hello -c2 -n Ken`:

1. `perl src/bin/dp-hello -c2 -n Ken`; the launcher adds `src/lib` to `@INC`, calls `main`.
2. `main` → `binary_streams`; `command_line_arguments` returns `('-c2', '-n', 'Ken')` unchanged.
3. `run` → `parse_args`: `-c2` → count `{2, -c}`; `-n` takes `Ken` → name `{Ken, -n}`; result
   `greet`, no operands.
4. `validate` → no operands; `validate_name` → `Ken`; `validate_count` → 2.
5. `greeting_text('Ken', 2)` → `"Hello, Ken!\nHello, Ken!\n"`; status 0.
6. `write_bytes(STDOUT, ...)` succeeds; stderr is empty; `exit 0`.

## 8. Design-to-code checklist

| HLD component  | LLD section | Source file(s)                            | Unit-test file(s)                      |
| :------------- | :---------- | :---------------------------------------- | :------------------------------------- |
| Options        | §3.1, §4.1  | `src/lib/DP/Hello/Options.pm`             | `src/t/options.t`                      |
| Validation     | §3.2, §4.2  | `src/lib/DP/Hello/Validation.pm`          | `src/t/validation.t`                   |
| Greeting       | §3.3        | `src/lib/DP/Hello/Greeting.pm`            | `src/t/greeting.t`                     |
| Messages       | §3.4        | `src/lib/DP/Hello/Messages.pm`            | `src/t/messages.t`                     |
| Platform       | §3.5        | `src/lib/DP/Hello/Platform.pm`            | `src/t/platform.t`, `src/t/launcher.t` |
| Output         | §3.6        | `src/lib/DP/Hello/Output.pm`              | `src/t/launcher.t`                     |
| Core and shell | §3.7        | `src/lib/DP/Hello.pm`, `src/bin/dp-hello` | `src/t/run.t`, `src/t/launcher.t`      |
