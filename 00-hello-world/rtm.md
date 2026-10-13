# Requirements Traceability Matrix (RTM) — Standard Terminal Hello World

| Field | Value |
| :-- | :-- |
| Project | `00-hello-world` |
| Tools | dp-hello |
| Author | Brandon Perkins |
| Version / date | 1.0 — 2026-10-13 |

Code paths are relative to `src/lib/DP/` (`Hello.pm` and `Hello/*.pm`); unit tests are in
`src/t/` (`file::subtest or test name`). Public black-box tests are `P01` … `P10`
(`tests/public` of the curriculum). The hidden suite runs in CI on Linux, macOS, and Windows and
is not cited.

## 1. User requirements to system requirements

| User requirement (URD) | Derived system requirements (SRS) |
| :-- | :-- |
| UR-01 | FR-01 |
| UR-02 | FR-02 |
| UR-03 | FR-04 |
| UR-04 | FR-07 |
| UR-05 | FR-08 |
| UR-06 | FR-03, FR-05, FR-09, FR-10, FR-11 |
| UR-07 | FR-01, SRS §3.7 |
| UR-08 | NFR-01, CONV-03 |
| UR-09 | FR-02, CONV-05 |
| UR-10 | FR-06, FR-10, CONV-07 … CONV-15 |
| UR-11 | NFR-02 |
| UR-12 | NFR-06 |

## 2. Forward traceability

| Req. ID | Summary | Design (HLD/LLD) | Code (file::function) | Verification (unit / black-box) | Status |
| :-- | :-- | :-- | :-- | :-- | :-- |
| UR-01 … UR-12 | User needs | HLD §2 | via the FR/NFR rows below | via the FR/NFR rows below; P01–P10 | Verified |
| FR-01 | Default greeting | HLD §3.3, LLD §3.2, §3.3 | `Hello/Validation.pm::validate`, `Hello/Greeting.pm::greeting_line` | `validation.t::defaults`, `greeting.t::default greeting`, `run.t::FR-01 default greeting`, `launcher.t::default greeting, LF only`, P01 | Verified |
| FR-02 | Named greeting, verbatim, UTF-8 | HLD §5, LLD §3.1, §3.3, §3.5 | `Hello/Options.pm::parse_args`, `Hello/Greeting.pm::greeting_line`, `Hello/Platform.pm::command_line_arguments` | `options.t::name forms`, `options.t::values beginning with a dash`, `greeting.t::UTF-8 bytes preserved`, `run.t::FR-02 UTF-8 name`, `launcher.t::a non-ASCII name is printed as UTF-8`, P02, P03, P04 | Verified |
| FR-03 | Empty name rejected | LLD §3.2 | `Hello/Validation.pm::validate_name` | `validation.t::name`, `run.t::FR-03 empty --name`, `run.t::FR-03 empty -n` | Verified |
| FR-04 | Repetition 1–1000, leading zeros | LLD §3.2, §3.3, §4.2 | `Hello/Validation.pm::validate_count`, `Hello/Greeting.pm::greeting_text` | `validation.t::count boundaries`, `greeting.t::three lines`, `greeting.t::1000 lines`, `run.t::FR-04 leading zeros`, P05, P06 | Verified |
| FR-05 | Invalid count rejected | LLD §3.2, §4.2 | `Hello/Validation.pm::validate_count` | `validation.t::count boundaries`, `run.t::FR-05 zero`, `run.t::FR-05 non-digits`, `run.t::FR-05 too large` | Verified |
| FR-06 | Last occurrence wins; only the winner is validated | LLD §3.1, §3.2 | `Hello/Options.pm::parse_args` | `options.t::last occurrence wins (CONV-11)`, `run.t::FR-06 last wins`, `run.t::FR-06 only the winner is validated` | Verified |
| FR-07 | Help, scan order | LLD §3.1, §3.4 | `Hello/Messages.pm::help_text`, `Hello/Options.pm::parse_args` | `messages.t::help text matches the user manual byte for byte`, `options.t::help and version (CONV-12)`, `run.t::FR-07 help before errors`, `run.t::FR-07 help beats operands`, P07 | Verified |
| FR-08 | Version line | LLD §3.4 | `Hello/Messages.pm::version_text` | `messages.t::version line`, `run.t::FR-08 version`, P08 | Verified |
| FR-09 | Operands rejected after the scan | LLD §3.2 | `Hello/Validation.pm::validate` | `validation.t::operands are rejected first`, `run.t::FR-09 operand`, `run.t::FR-09 after --`, P10 | Verified |
| FR-10 | Unknown / malformed options | LLD §2.4, §3.1 | `Hello/Options.pm::_parse_long`, `_parse_short` | `options.t::syntax errors (CONV-13)`, `run.t::FR-10 unknown short`, `FR-10 unknown long`, `FR-10 missing value`, `FR-10 =value`, P09 | Verified |
| FR-11 | Nothing on stdout on error | HLD D4, LLD §3.7 | `Hello.pm::run` | `run.t` (every `fails` case checks empty stdout), `launcher.t::usage error on stderr, LF only, exit 2`, P09, P10 | Verified |
| NFR-01 | Byte-identical, LF only | HLD §5, LLD §5 | `Hello/Output.pm::binary_streams`, `Hello/Platform.pm` | `launcher.t` (all), `greeting.t::LF only`, `messages.t::help is LF only`; P01–P10 on three OSes in CI | Verified |
| NFR-02 | ≤ 300 ms interpreted; ≤ 32 MiB above baseline | HLD §7, MTP §4.4 | whole program (core modules only) | Measurement: 20–30 ms, ≈ 3.8 MiB above the perl baseline (MTP §4.4) | Verified |
| NFR-03 | No crash / stack trace | HLD D3, §6 | `Hello.pm::run` (errors are data, no `die`) | `options.t`, `validation.t::count boundaries` (hostile values), `run.t` | Verified |
| NFR-04 | Separate units | HLD §3.2 | `Hello/{Options,Validation,Greeting,Output}.pm` | Design review (LLD §8) | Verified |
| NFR-05 | Pure, unit-tested greeting | LLD §3.3 | `Hello/Greeting.pm::greeting_line`, `greeting_text` | `greeting.t` | Verified |
| NFR-06 | Every BASE-MAKEFILE target works | HLD §2 | `Makefile` hooks | `make check` (container), `make check roundtrip` (native CI, three OSes) | Verified |
| NFR-07 | No files, environment, subprocesses | HLD §1.1 | whole program | Inspection: no `open`, `%ENV`, `system`, or backticks in `src/lib` | Verified |
| CONV-01 | Canonical name | LLD §3.4 | `Hello/Messages.pm` (`$TOOL`) | `messages.t`, P07–P10 | Verified |
| CONV-02 | Version format | LLD §3.4 | `Hello/Messages.pm::version_text` | `messages.t::version line`, P08 | Verified |
| CONV-03 | LF only, binary mode | HLD §5 | `Hello/Output.pm::binary_streams` | `launcher.t` (all), P01–P10 | Verified |
| CONV-05 | UTF-8 arguments | HLD §5, LLD §3.5 | `Hello/Platform.pm::command_line_arguments`, `from_code_page`; `Hello/Options.pm` (`$CHARACTER`) | `platform.t` (all), `options.t::syntax errors (CONV-13)` (non-ASCII letter), `launcher.t::a non-ASCII name is printed as UTF-8` | Verified |
| CONV-06 | Locale-independent, no colors | HLD D5 | byte strings throughout; no `locale`, no `%ENV` | Inspection; P01–P10 under the minimal CI environment | Verified |
| CONV-07 | Short options, bundling | LLD §4.1 | `Hello/Options.pm::_parse_short` | `options.t::bundling (CONV-07)`, `options.t::name forms`, P06 | Verified |
| CONV-08 | Long options, no abbreviation | LLD §4.1 | `Hello/Options.pm::_parse_long` | `options.t::syntax errors (CONV-13)` (`--nam`), `options.t::name forms`, P04 | Verified |
| CONV-09 | `--` terminator | LLD §4.1 | `Hello/Options.pm::parse_args` | `options.t::operands and terminator (CONV-09, CONV-10)`, `run.t::FR-09 after --` | Verified |
| CONV-10 | Operands, `-` | LLD §4.1 | `Hello/Options.pm::parse_args` | `options.t::operands and terminator (CONV-09, CONV-10)`, P10 | Verified |
| CONV-11 | Last occurrence wins | LLD §3.1 | `Hello/Options.pm::_parse_long`, `_parse_short` | `options.t::last occurrence wins (CONV-11)` | Verified |
| CONV-12 | Scan order | HLD D2, LLD §4.1 | `Hello/Options.pm::parse_args`, `Hello.pm::run` | `options.t::help and version (CONV-12)`, `run.t::CONV-12 help beats value errors`, `run.t::CONV-12 syntax error first` | Verified |
| CONV-13 | Exact diagnostics | LLD §2.4 | `Hello/Messages.pm::usage_diagnostic` | `messages.t` (every variant), `run.t` (`fails` cases), P09, P10 | Verified |
| CONV-14 | Hint line, exit 2 | LLD §2.4 | `Hello/Messages.pm::usage_diagnostic`, `Hello.pm::run` | `messages.t`, `run.t`, P09, P10 | Verified |
| CONV-15 | Values verbatim, `''` | LLD §2.4 | `Hello/Messages.pm::usage_diagnostic` | `messages.t::invalid argument '' for '--name'`, `messages.t::invalid argument 'it's' for '-c'` | Verified |
| CONV-22 | `--help` / `--version` accepted, no argument | LLD §3.1 | `Hello/Options.pm::_parse_long` | `options.t::help and version (CONV-12)`, `options.t::syntax errors (CONV-13)` | Verified |
| CONV-23 | Help text verbatim | LLD §3.4 | `Hello/Messages.pm::help_text` | `messages.t::help text matches the user manual byte for byte`, P07 | Verified |
| CONV-24 | No crash | HLD §6 | `Hello.pm::run` | as NFR-03 | Verified |
| CONV-25 | EPIPE: terminate quietly | LLD §3.6 | `Hello/Output.pm::write_bytes`, `Hello.pm::main` | Inspection (SIGPIPE default on POSIX; `print` result checked on Windows) | Implemented |
| CONV-26 | stdin not read | HLD §3.1 | whole program | Inspection: no `STDIN` / `<>` in `src/lib` | Verified |
| CONV-31 | Memory above runtime baseline | HLD §7 | — | MTP §4.4 measurement | Verified |

CONV-04 and CONV-16 … CONV-21 do not apply (no input data, no files, no paths). CONV-27 …
CONV-30 describe the test harness and are satisfied by running under it (P01–P10).

## 3. Backward traceability (test → requirement)

| Test | Type | Requirement(s) verified |
| :-- | :-- | :-- |
| P01 | black-box, public | FR-01, CONV-03 |
| P02, P03, P04 | black-box, public | FR-02, CONV-07, CONV-08 |
| P05, P06 | black-box, public | FR-04, CONV-07 |
| P07 | black-box, public | FR-07, CONV-23 |
| P08 | black-box, public | FR-08, CONV-02 |
| P09 | black-box, public | FR-10, FR-11, CONV-13, CONV-14 |
| P10 | black-box, public | FR-09, FR-11, CONV-10, CONV-13 |
| `options.t` (9 subtests) | unit | FR-02, FR-06, FR-07, FR-08, FR-10, CONV-05, CONV-07 … CONV-12, CONV-22 |
| `validation.t` (6 subtests) | unit | FR-01, FR-03, FR-04, FR-05, FR-06, FR-09 |
| `greeting.t` | unit | FR-01, FR-02, FR-04, NFR-05 |
| `messages.t` | unit | FR-07, FR-08, CONV-01, CONV-02, CONV-13 … CONV-15, CONV-23 |
| `platform.t` | unit | CONV-05 |
| `run.t` | unit (end-to-end, pure core) | FR-01 … FR-11, CONV-12 … CONV-14 |
| `launcher.t` | unit (process level) | NFR-01, CONV-03, CONV-05, FR-11 |

## 4. Coverage summary

| Category | Total | Designed | Implemented | Verified |
| :-- | :-- | :-- | :-- | :-- |
| User requirements (UR) | 12 | 12 | 12 | 12 |
| Functional (FR) | 11 | 11 | 11 | 11 |
| Non-functional (NFR) | 7 | 7 | 7 | 7 |
| Conventions (CONV, applicable) | 20 | 20 | 20 | 19 |

## 5. Gaps and justifications
- **CONV-25** (EPIPE) is verified by inspection only: on POSIX the default SIGPIPE action ends
  the process silently, and on Windows a failed `print` makes `main` return without a
  diagnostic. A reliable automated broken-pipe test across three OSes is out of proportion for
  this project; revisit when a streaming tool (02-cat) needs one.
- **CONV-05 on Windows** is verified for code-page characters (cp1252 on the CI runners).
  Characters outside the ANSI code page are replaced by Windows before perl starts (HLD §8).
