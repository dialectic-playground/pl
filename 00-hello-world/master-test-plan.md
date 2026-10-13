# Master Test Plan (MTP) — Standard Terminal Hello World

| Field | Value |
| :-- | :-- |
| Project | `00-hello-world` |
| Tools | dp-hello |
| Implementation language | pl (Perl 5.42, Carton) |
| Author | Brandon Perkins |
| Version / date | 1.0 — 2026-10-13 |
| Standard | Structure adapted from IEEE 829 / ISO/IEC/IEEE 29119-3 |

## 1. Introduction and scope

### 1.1 Objectives
"Tested enough" means: every SRS acceptance criterion (FR-01 … FR-11) is exercised by a unit
test of the pure core `DP::Hello::run` and passes black-box on Linux, macOS, and Windows; every
parser branch and validation boundary has a unit test; `make lint` is clean; and the RTM shows
every applicable requirement as Verified or justifies the gap.

### 1.2 In scope / out of scope
| In scope | Out of scope |
| :-- | :-- |
| Every FR/NFR in the SRS and the applicable CONV rules, on Linux, macOS, and Windows | Localization, terminals' rendering of UTF-8 |
| Windows argument conversion for ANSI-code-page characters | Characters outside the Windows ANSI code page (HLD §8) |
| Build, install, and uninstall through the Makefile | Packaging for CPAN |

## 2. Test items

| Item | Version / location |
| :-- | :-- |
| dp-hello | `00-hello-world/src/` on branch `feat/00-hello-world` |
| Public black-box suite | `tests/public/` (10 tests) |
| Hidden black-box suite | `tests/private/` (10 tests, run by CI) |

## 3. Test levels and approach

| Level | Purpose | Technique(s) | Tooling | Owner |
| :-- | :-- | :-- | :-- | :-- |
| Unit | Parser, validation, greeting, messages, platform conversion in isolation | Equivalence partitioning, boundary-value analysis | Test::More via prove (`make test-unit`) | Implementer |
| Integration | `run` wires parse → validate → greet → messages; `launcher.t` runs the real script | Specification-based (one case per acceptance criterion) | Test::More, IPC::Open3 with `:raw` capture | Implementer |
| System (black-box) | The specified CLI behavior, byte-exact | Specification-based | `make test` → `run-tests.py` | Implementer |
| Acceptance | Hidden suite passes on all OSes | — | CI `make check` (`test-hidden`) | CI |
| Static analysis | Style and lint | — | `make lint` (Perl::Critic severity 3, perltidy `--assert-tidy`) | Implementer / CI |

## 4. Test design

### 4.1 Equivalence partitions and boundaries

| Input | Valid partitions | Invalid partitions | Boundaries |
| :-- | :-- | :-- | :-- |
| NAME | non-empty: ASCII, spaces, UTF-8, leading `-`, contains `=` | empty | `''` vs `' '` |
| COUNT | ASCII digits with value 1–1000, leading zeros | empty, non-digits, sign, spaces, trailing LF, Arabic-Indic digit, 0, > 1000, huge | 0, 1, 1000, 1001, `007`, `0001000`, 23 digits |
| Short options | `-n`/`-c` with attached or separate value, bundles | unknown letter (ASCII, non-ASCII), missing value | `-n` as the last token |
| Long options | `--name`/`--count` with `=` or separate value; `--help`, `--version` | unknown, abbreviated, `---`, missing value, `--help=`/`--version=1` | `--name=` (empty), `--version=` |
| Operands | none | any word, `-`, anything after `--` | `--` alone (valid), `-- --` |
| Order | help/version first, value errors and operands before help | syntax error before help | `-x --help`, `extra --help`, `--count 0 --help` |
| Arguments (Windows) | code page 1252 (runners), 65001 | — | unknown code page left unchanged |

### 4.2 Additional test cases (beyond the supplied suite)

| ID | Requirement(s) | Preconditions | Steps / command | Expected result | Level |
| :-- | :-- | :-- | :-- | :-- | :-- |
| T-01 | FR-02, CONV-05 | — | `run('-n', "Zo\xC3\xAB")` | `Hello, Zoë!` + LF as UTF-8 bytes | unit (`run.t`) |
| T-02 | CONV-05 | Windows, ACP 1252 | launch with `-n "Zo\xEB"` (ANSI) | UTF-8 `Hello, Zoë!` + LF | process (`launcher.t`) |
| T-03 | FR-02 | — | `parse_args('-n-x')`, `('--name', '-x')`, `('-n', '--help')` | value `-x` / `--help`, no error | unit (`options.t`) |
| T-04 | FR-03 | — | `run('-n', '')` | `invalid argument '' for '-n'`, exit 2 | unit (`run.t`) |
| T-05 | FR-04 | — | `validate_count` of `007`, `0001000`, `1000` | 7, 1000, 1000 | unit (`validation.t`) |
| T-06 | FR-05 | — | `validate_count` of `0`, `1001`, `+1`, `"1\n"`, 23 digits | `invalid_argument` with the value verbatim | unit (`validation.t`) |
| T-07 | FR-06 | — | `run('-n', '', '-n', 'B')` | `Hello, B!` (only the winner is validated) | unit (`run.t`) |
| T-08 | CONV-12 | — | `run('--count', '0', '--help')`, `run('extra', '--help')` | help, exit 0 | unit (`run.t`) |
| T-09 | CONV-12 | — | `run('-x', '--help')` | `invalid option -- 'x'`, exit 2 | unit (`run.t`) |
| T-10 | CONV-13, CONV-05 | — | `parse_args("-\xC3\xAB")` | `invalid_option` with the whole character `ë` | unit (`options.t`) |
| T-11 | CONV-13 | — | `parse_args('--nme=Ada')`, `('--nam')` | `unrecognized option` with the full token | unit (`options.t`) |
| T-12 | CONV-03 | any OS | launch `-c 2 -n Ada`, capture `:raw` | exactly `Hello, Ada!\n` × 2, no CR | process (`launcher.t`) |
| T-13 | FR-09 | — | `validate` with operands and an empty name | `extra operand 'a'` (operands first) | unit (`validation.t`) |

### 4.3 Negative and robustness testing
All syntax-error kinds and hostile values (huge, signed, whitespace, trailing newline,
non-ASCII digits, invalid UTF-8 bytes on POSIX) are unit-tested; none raises an exception,
because errors are returned as data and the count is checked textually before conversion.
Files, permissions, stdin, and binary input do not apply: dp-hello reads none of them
(CONV-26, NFR-07). Broken pipes are covered by inspection (RTM §5).

### 4.4 Performance and resource testing
NFR-02 / CONV-31, measured with `/usr/bin/time -f '%e s %M KiB'` on Fedora 44 (perl 5.42.3):

| Command | Wall time | Peak RSS | Above `perl -e 1` baseline (5.1 MiB) |
| :-- | :-- | :-- | :-- |
| `dp-hello -c 1000 -n Ada` | 0.02–0.03 s | 8.9 MiB | ≈ 3.8 MiB |
| `dp-hello --help` | 0.02 s | 8.9 MiB | ≈ 3.8 MiB |

Both are far within 300 ms (interpreted) and 32 MiB above baseline.

## 5. Test environments

| Environment | OS / version | Toolchain | How provisioned |
| :-- | :-- | :-- | :-- |
| Local container | Debian trixie (podman) | perl 5.42 (`perl:5.42-slim-trixie`), Carton 1.0.35, gcc | `Containerfile`, `make check` |
| Local native | Fedora 44 | perl 5.42.3 (system) | `DP_RUNTIME=local make -C 00-hello-world test` |
| CI | ubuntu-latest, macos-latest, windows-latest | perl 5.42 (shogo82148/actions-setup-perl), Carton 1.0.35, Python 3.12 | `.github/workflows/ci.yml` |

## 6. Entry and exit criteria

- **Entry:** HLD/LLD drafted, `make all` succeeds, `make lint` is clean.
- **Exit:** all unit tests and all public and hidden black-box tests pass on all three OSes
  (CI green), `make format` leaves no diff, `make roundtrip` passes natively, and the RTM shows
  every applicable requirement Verified or justified.
- **Suspension / resumption:** suspend when the toolchain (container image or a native CI
  runner) is unavailable or changes release line; resume after `make toolchain` passes again.

## 7. Defect management
Defects are GitHub issues in `dialectic-playground/pl` with the failing command, the expected
and actual bytes, and the OS. Every fix adds a unit test that reproduces the defect (in
`run.t` for behavior, or the module's own test file) before the code change; CI must pass on
all three OSes before merge.

| Severity | Definition |
| :-- | :-- |
| 1 — Critical | Crash, stack trace, or wrong stdout bytes / exit status on a mainline path |
| 2 — Major | A wrong diagnostic, or behavior wrong on one OS only |
| 3 — Minor | Documentation, lint, or build-ergonomics issue with no behavior change |

## 8. Schedule and deliverables

| Milestone | Deliverable | Target date |
| :-- | :-- | :-- |
| Design complete | hld.md, lld.md | 2026-10-13 |
| Implementation complete | src/, unit tests, Makefile hooks | 2026-10-13 |
| Verification complete | RTM Verified, CI green | 2026-10-13 |

## 9. Risks and contingencies

| Risk | Mitigation |
| :-- | :-- |
| Windows-only failure discovered late | CI runs on all OSes from the first commit; `launcher.t` runs the real script on Windows |
| Git Bash's own perl shadows the intended Perl on Windows | CI prepends the actions-setup-perl directory via `BASH_ENV`; `make toolchain` checks the version |
| Formatter drift between environments | Perl::Tidy is locked in `cpanfile.snapshot` and installed per project |

## 10. Test summary (complete at the end)

| Metric | Value |
| :-- | :-- |
| Unit tests (pass / total) | 69 / 69 (7 test files) |
| Coverage (line / branch) | Not measured (Devel::Cover is not in the toolchain); every branch of `Options.pm` and `Validation.pm` has a named test |
| Public black-box (pass / 10) | 10 / 10 (container, Linux, macOS, Windows) |
| Hidden black-box (pass / 10, from CI) | 10 / 10 |
| Open defects by severity | 0 / 0 / 0 |
