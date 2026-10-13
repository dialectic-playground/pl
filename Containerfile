# Toolchain image for dialectic-playground/pl: Perl (container-first; see tools/dp-run).
#
# Perl 5.44; build and package tool: cpanm (cpanfile).
# Official base image pinned by multi-architecture index digest, plus make and python3 (for the
# curriculum's black-box runner). Dependabot (docker) refreshes the digest; moving to a new
# release line is a deliberate change (keep `make toolchain` and the native CI in step).
FROM docker.io/library/perl:5.44-slim-trixie@sha256:1d24df79a36b5a02b3811b85c9afe481e2739fc0d76e71568aaa954f56d00930

RUN apt-get update \
    && apt-get install -y --no-install-recommends make python3 \
    && rm -rf /var/lib/apt/lists/*

ENV PERL_CPANM_HOME=/dp-cache/cpanm \
    DP_IN_CONTAINER=1
