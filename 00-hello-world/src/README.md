# Source workspace: 00-hello-world

This directory is intentionally language-neutral. The curriculum supplies the specifications,
tests, and document templates. **Implementations live in separate language repositories**
(for example `dialectic-playground/py`, `dialectic-playground/rs`, `dialectic-playground/go`).

## Implementation contract

An implementation of `00-hello-world` is complete when, from its project directory:

1. `make all` builds these executables into `BIN_DIR`: **dp-hello**. On Windows they may
   have an `.exe` suffix.
2. Every standard target in `shared/templates/BASE-MAKEFILE` works (`all install uninstall
   test check lint format clean distclean`), implemented with that language's usual tools.
3. `make test` runs the language's unit tests, then passes all 10 public black-box tests.
4. `make test-hidden` passes all 10 hidden black-box tests on Linux, macOS, and Windows, as
   run by `shared/ci/cross-platform-ci.yml`.
5. The behavior matches `../../sdlc-curriculum/projects/00-hello-world/specs/SRS.md` and `shared/CLI-CONVENTIONS.md` byte-for-byte,
   and the help text matches `../../sdlc-curriculum/projects/00-hello-world/specs/user-manual.md`.
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
└── 00-hello-world/
    ├── Makefile              # copied from assignment/Makefile, with hooks filled in
    ├── hld.md lld.md rtm.md master-test-plan.md
    └── src/ …                # language-specific sources and unit tests
```

with `CURRICULUM_ROOT := ../sdlc-curriculum` in that Makefile.
