<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Source workspace: 02-cat](#source-workspace-02-cat)
  - [Implementation contract](#implementation-contract)
  - [Layout in a language repository](#layout-in-a-language-repository)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Source workspace: 02-cat

This directory is intentionally language-neutral. The curriculum supplies the specifications,
tests, and document templates. **Implementations live in separate language repositories**
(for example `dialectic-playground/py`, `dialectic-playground/rs`, `dialectic-playground/go`).

## Implementation contract

An implementation of `02-cat` is complete when, from its project directory:

1. `make all` builds these executables into `BIN_DIR`: **dp-cat**. Each is a native
   executable (with an `.exe` suffix on Windows) or a script that starts with a `#!` line,
   which works on every OS, including Windows (see `shared/templates/BASE-MAKEFILE`).
   `make install` puts the executable, or a launcher, into `$(BINDIR)`. Script payloads go
   under `$(LIBDIR)/<repository>/<project>/`, and `make uninstall` removes everything it
   installed.
2. Every standard target in `shared/templates/BASE-MAKEFILE` works (`all install uninstall
test check lint format clean distclean`), implemented with that language's usual tools.
3. `make test` runs the language's unit tests, then passes all 10 public black-box tests.
4. `make test-hidden` passes all 10 hidden black-box tests on Linux, macOS, and Windows, as
   run by `shared/ci/cross-platform-ci.yml`.
5. The behavior matches `../../sdlc-curriculum/projects/02-cat/specs/SRS.md` and `shared/CLI-CONVENTIONS.md` byte-for-byte,
   and the help text matches `../../sdlc-curriculum/projects/02-cat/specs/user-manual.md`.
6. The white-box deliverables in `../` (`hld.md`, `lld.md`, `rtm.md`,
   `master-test-plan.md`) are completed for that implementation.
7. The code follows the 20 engineering principles in the curriculum's root `README.md`.
8. The repository's `Containerfile` provides the toolchain (the language's official image,
   pinned by digest, plus `make` and `python3` ≥ 3.11), so every target works container-first
   (`make test`) as well as natively (`DP_RUNTIME=local make test`).

## Layout in a language repository

See [`shared/templates/language/`](https://github.com/dialectic-playground/sdlc-curriculum/blob/main/shared/templates/language/README.md) for the full
skeleton.

```text
<language-repo>/
├── Containerfile             # toolchain image: official language image + make + python3
├── sdlc-curriculum/          # git submodule of dialectic-playground/sdlc-curriculum
└── 02-cat/
    ├── Makefile              # copied from assignment/Makefile, with hooks filled in
    ├── hld.md lld.md rtm.md master-test-plan.md
    └── src/ …                # language-specific sources and unit tests
```

with `CURRICULUM_ROOT := ../sdlc-curriculum` in that Makefile.
