# Toolchain image for dialectic-playground/pl: Perl (container-first; see tools/dp-run).
#
# Perl 5.42 (the newest line available on Linux, macOS, and Windows); build and package tool: cpanm (cpanfile).
# Official base image pinned by multi-architecture index digest, plus make and python3 (for the
# curriculum's black-box runner). Dependabot (docker) refreshes the digest; moving to a new
# release line is a deliberate change (keep `make toolchain` and the native CI in step).
FROM docker.io/library/perl:5.42-slim-trixie@sha256:ae140b241337000207acd7da4676bb10e5d31865c5901d0f3b091d5df4775ab4

RUN apt-get update \
    && apt-get install -y --no-install-recommends make python3 \
    && rm -rf /var/lib/apt/lists/*

ENV PERL_CPANM_HOME=/dp-cache/cpanm \
    DP_IN_CONTAINER=1
