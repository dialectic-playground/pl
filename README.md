<!--
TEMPLATE: This README is the standard skeleton for Dialectic Playground repositories.
Replace every line marked "TEMPLATE:" and delete this comment. CI fails in any repository
created from this template until no "TEMPLATE:" markers remain.
Full checklist: https://dialectic-playground.github.io/docs/how-to/add-a-repository/
-->
<p align="center">
  <picture>
    <!-- TEMPLATE: replace REPO-SLUG with this repository's asset set in .github/assets/ (e.g. py). -->
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/REPO-SLUG/dist/logo-dark.svg">
    <img alt="dialectic playground / REPO-NAME" src="https://raw.githubusercontent.com/dialectic-playground/.github/main/assets/REPO-SLUG/dist/logo.svg" height="96">
  </picture>
</p>

# REPO-NAME <!-- TEMPLATE: repository name -->

ONE-LINE DESCRIPTION. <!-- TEMPLATE: the canonical description, identical to the GitHub "About" text -->

📖 **Documentation:** <https://dialectic-playground.github.io/docs/>

## Layout

<!-- TEMPLATE: describe the top-level files and directories. -->

| Path | Contents |
| :--- | :--- |
| `Makefile` | Container-first entry point: `make check` runs everything CI checks |
| `Containerfile` | The toolchain image: an official image pinned by digest |
| `.devcontainer/` | Dev container using the same image |
| `tools/dp-run`, `tools/container.mk` | Shared container tooling (copies of the canonical files in `dialectic-playground/.github`) |
| `.github/workflows/ci.yml` | CI (workflow **CI**): container and native `make check`, shared-tooling check, DCO, and the required **CI result** check |

## Development

Container-first: `make` targets and `tools/dp-run <command>` run in the toolchain container
via Podman, then Docker, then the local system. `DP_RUNTIME=podman|docker|local` overrides the
choice. See
[Container-first development](https://dialectic-playground.github.io/docs/explanation/container-first-development/).

```sh
make check                    # everything CI checks
DP_RUNTIME=local make check   # the same, natively
```

## Contributing

See the [organization contributing guide](https://github.com/dialectic-playground/.github/blob/main/CONTRIBUTING.md).
Pull requests are squash-merged, titles follow Conventional Commits, and every commit needs a
DCO sign-off.

## License

[MIT](LICENSE)
