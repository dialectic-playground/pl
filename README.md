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

**Status:** repository and toolchain ready; no projects implemented yet.

## Perl at a glance

| Aspect | Perl |
| :-- | :-- |
| File extension | `.pl` |
| CLI classification | Included |
| Image category | First-Class |
| Access to OS primitives | Absolute & Direct (original Unix stream system wrapper) |
| Entry-point mechanism | Interpreter maps argument arrays into structural @ARGV variable |

## Toolchain

| | |
| :-- | :-- |
| Release line | Perl 5.42 (the newest line available on Linux, macOS, and Windows) |
| Build / package tool | cpanm (cpanfile) |
| Container image | `perl:5.42-slim-trixie`, pinned by digest ([`Containerfile`](Containerfile)) |
| Native CI | shogo82148/actions-setup-perl (5.42, includes cpanm) |

`make toolchain` verifies that the container and native toolchains are on this release line.

## Layout

| Path | Contents |
| :--- | :--- |
| `00-hello-world/` … `10-sys-monitor/` | One workspace per curriculum project: `Makefile` (with `DP_*` hooks), HLD, LLD, RTM, master test plan, and `src/` |
| `sdlc-curriculum/` | The curriculum, as a git submodule pinned to a release tag |
| `Makefile` | `make check` (repository, toolchain, implemented projects), `toolchain`, `projects`, `roundtrip` |
| `Containerfile`, `.devcontainer/` | The toolchain image and the matching dev container |
| `tools/dp-run`, `tools/container.mk` | Shared container tooling (copies of the canonical files in `dialectic-playground/.github`) |
| `.github/workflows/ci.yml` | CI: container and native (Linux, macOS, Windows) `make` targets, shared-tooling check, DCO |

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
