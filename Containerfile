# Toolchain image for REPO-NAME (container-first; see tools/dp-run).
#
# TEMPLATE: replace the base image with the official image for this repository's toolchain,
# pinned by its multi-architecture index digest (FROM image:tag@sha256:...), and add only
# what that image lacks. Keep `make` and the final ENV line. Dependabot (docker) keeps the
# pin current.
FROM docker.io/library/debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f

RUN apt-get update \
    && apt-get install -y --no-install-recommends make git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV DP_IN_CONTAINER=1
