# Low-Level Design (LLD) — Line-by-Line File Comparison

| Field | Value |
| :-- | :-- |
| Project | `07-diff-lite` |
| Tools | dp-diff |
| Implementation language | *py / rs / go* |
| Author | *your name* |
| Version / date | *0.1 — YYYY-MM-DD* |
| Status | *Draft / In review / Approved* |
| Inputs | `assignment/hld.md`, `specs/SRS.md`, `shared/CLI-CONVENTIONS.md` |

> **Purpose of this document.** The LLD refines every HLD component down to modules, data types,
> function signatures, algorithms, and error cases. Another engineer should be able to implement
> the tool from this document *and get the same structure you did*.
>
> Replace every *italic prompt* below. Delete the prompts when you are done.

## 1. Source layout

*Show the directory and file tree under `assignment/src/<lang>/` and give the purpose of each
file.*

```text
src/<lang>/
└── …
```

## 2. Data types

*Define each significant type: a struct, class, enum, or record. Give its fields, the
invariants it maintains, and which requirement it supports.*

### 2.1 `Config` *(example)*
| Field | Type | Default | Constraint / invariant | SRS |
| :-- | :-- | :-- | :-- | :-- |
| *number_lines* | *bool* | *false* | *—* | *FR-…* |

### 2.2 Error type
*List every error variant and give, for each, the exact diagnostic text and exit status it
produces (CONV-13, CONV-16, and the SRS).*

| Variant | Diagnostic (stderr) | Exit status |
| :-- | :-- | :-- |
| *Usage(msg)* | `<tool>: <msg>` + `Try '<tool> --help' …` | 2 |

## 3. Module and function specifications

*Repeat this block for every public function, and for every private function that is not
trivial.*

### 3.x `function_name`
- **Signature:** *`fn parse_args(args: &[String]) -> Result<Config, UsageError>`*
- **Responsibility:** *one sentence*
- **Preconditions:** *…*
- **Postconditions / return value:** *…*
- **Errors:** *which variants it returns, and when*
- **Algorithm:** *numbered steps or pseudocode*
- **Complexity:** *time O(…), memory O(…)*
- **Satisfies:** *FR-…, CONV-…*
- **Unit tests:** *the test names in your unit-test file*

## 4. Algorithms

*Describe each non-trivial algorithm in detail, for example line numbering, backward seeking,
regex matching, LCS, or file locking. Include pseudocode and edge cases, and say why you chose
it over the alternatives.*

## 5. Platform-specific details

*Note each API call that behaves differently on Linux, macOS, or Windows, and how your code
handles the difference. Examples: binary stdout, path separators, process spawning, file
locking, and performance counters.*

| Concern | Linux | macOS | Windows | Abstraction |
| :-- | :-- | :-- | :-- | :-- |
| *…* | | | | |

## 6. Resource management

*Explain how file handles, buffers, child processes, sockets, and locks are acquired and
released on every path, including error paths. Give buffer sizes and memory bounds.*

## 7. Sequence of one invocation

*Trace a representative command, for example the first public test, step by step through your
functions.*

## 8. Design-to-code checklist

| HLD component | LLD section | Source file(s) | Unit-test file(s) |
| :-- | :-- | :-- | :-- |
| *cli* | *§3.1* | *…* | *…* |
