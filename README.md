<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [pl](#pl)
  - [Perl at a glance](#perl-at-a-glance)
  - [Toolchain](#toolchain)
  - [Layout](#layout)
  - [Development](#development)
  - [Implementing a project](#implementing-a-project)
  - [Contributing](#contributing)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/pl/dist/logo-dark.svg">
    <img alt="dialectic playground / pl" src="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/pl/dist/logo.svg" height="96">
  </picture>
</p>

# pl

Perl implementation of the Dialectic Playground SDLC curriculum.

📖 **Documentation:** <https://dialectic-playground.github.io/docs/reference/languages/pl/>

This repository implements the eleven projects of the
[SDLC curriculum](https://github.com/dialectic-playground/sdlc-curriculum) in Perl. Each project is
specified to the byte by the curriculum and verified by its black-box tests on Linux, macOS,
and Windows.

**Status:** Implemented projects: 00-hello-world.

## Perl at a glance

| Aspect                  | Perl                                                            |
| :---------------------- | :-------------------------------------------------------------- |
| File extension          | `.pl`                                                           |
| CLI classification      | Included                                                        |
| Image category          | First-Class                                                     |
| Access to OS primitives | Absolute & Direct (original Unix stream system wrapper)         |
| Entry-point mechanism   | Interpreter maps argument arrays into structural @ARGV variable |

## Toolchain

|                      |                                                                              |
| :------------------- | :--------------------------------------------------------------------------- |
| Release line         | Perl 5.42 (the newest line available on Linux, macOS, and Windows)           |
| Build / package tool | cpanm (cpanfile)                                                             |
| Container image      | `perl:5.42-slim-trixie`, pinned by digest ([`Containerfile`](Containerfile)) |
| Native CI            | shogo82148/actions-setup-perl (5.42, includes cpanm)                         |

`make toolchain` verifies that the container and native toolchains are on this release line.

| Tool                     | Where it comes from                                                                                                                                              |
| :----------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Test::More, prove        | Perl core (unit tests in each project's `src/t/`)                                                                                                                |
| Carton 1.0.35            | Container image; native CI installs the same version with cpanm                                                                                                  |
| Perl::Critic, Perl::Tidy | Each project's `cpanfile` (exact versions) and `cpanfile.snapshot` (Carton lockfile), installed into the project's `local/` on first `make lint` / `make format` |
| gcc, libc6-dev           | Container image (XS dependencies of Perl::Critic); native: the platform's compiler                                                                               |

The tools themselves use only core modules. Dependabot has no Perl ecosystem, so the
snapshot is updated deliberately (`carton update` in the container).

**Windows:** run the tools and `make` from Git Bash or MSYS2, which honor `#!` lines. Git Bash
puts its own `/usr/bin/perl` (an older Perl) first on `PATH`; put your Perl 5.42 ahead of it
(CI does this with `BASH_ENV`, see `.github/workflows/ci.yml`). Command-line arguments reach
perl.exe in the ANSI code page; dp-hello converts them to UTF-8, so characters outside that
code page (for example CJK on a cp1252 system) cannot be represented.

## Layout

| Path                                  | Contents                                                                                                          |
| :------------------------------------ | :---------------------------------------------------------------------------------------------------------------- |
| `00-hello-world/` … `10-sys-monitor/` | One workspace per curriculum project: `Makefile` (with `DP_*` hooks), HLD, LLD, RTM, master test plan, and `src/` |
| `sdlc-curriculum/`                    | The curriculum, as a git submodule pinned to a release tag                                                        |
| `Makefile`                            | `make check` (repository, toolchain, implemented projects), `toolchain`, `projects`, `roundtrip`                  |
| `Containerfile`, `.devcontainer/`     | The toolchain image and the matching dev container                                                                |
| `tools/dp-run`, `tools/container.mk`  | Shared container tooling (copies of the canonical files in `dialectic-playground/.github`)                        |
| `.github/workflows/ci.yml`            | CI: container and native (Linux, macOS, Windows) `make` targets, shared-tooling check, DCO                        |

## Development

Container-first: `make` targets and `tools/dp-run <command>` run in the toolchain container
via Podman, then Docker, then the local system. `DP_RUNTIME=podman|docker|local` overrides
the choice.

```sh
git clone --recurse-submodules https://github.com/dialectic-playground/pl.git
cd pl
make check                    # repository, toolchain, and every implemented project
DP_RUNTIME=local make check   # the same with your native toolchain
make -C 00-hello-world help   # a project's configuration and hooks
```

## Implementing a project

1. Complete the project's `hld.md` and `lld.md` before writing code.
2. Write the implementation and its unit tests under the project's `src/`, add the
   repository's cpanm (cpanfile) configuration, and fill in `BIN_DIR` and the `DP_*` hooks in
   the project's `Makefile`.
3. Pass `make -C <project> test` (container) and `DP_RUNTIME=local make -C <project> test`.
4. Add the project directory to `IMPLEMENTED` in the root `Makefile`. CI then builds, lints,
   and tests it in the container and natively on all three operating systems.
5. Keep `rtm.md` and `master-test-plan.md` current.

Specifications: [curriculum reference](https://dialectic-playground.github.io/docs/reference/curriculum/). Language setup:
[Set up a language repository](https://dialectic-playground.github.io/docs/how-to/set-up-a-language-repository/).

## Contributing

See the [organization contributing guide](https://github.com/dialectic-playground/.github/blob/main/CONTRIBUTING.md).
Pull requests are squash-merged, titles follow Conventional Commits, and every commit needs a
DCO sign-off.

## License

[MIT](LICENSE)
