# Makefile for REPO-NAME (container-first; see tools/container.mk).
#
#   make                 same as `make check`
#   make check           everything CI checks
#   make dp-info | dp-shell | dp-image
#
# TEMPLATE: add this repository's targets (build, test, lint, …) inside the guard below, make
# `check` run everything CI checks, and document them in this header.
#
# Every goal runs in the toolchain container built from ./Containerfile: podman, then docker,
# then the local system. Override with DP_RUNTIME=podman|docker|local or DP_IMAGE=<image>.

DP_HOST_GOALS += help
include tools/container.mk
ifeq ($(DP_DELEGATE),)

SHELL := /bin/sh
.DEFAULT_GOAL := check
STANDARD_FILES := LICENSE README.md Containerfile Makefile .editorconfig .gitattributes \
	.gitignore .devcontainer/devcontainer.json .github/CODEOWNERS .github/dependabot.yml \
	.github/workflows/ci.yml tools/dp-run tools/container.mk
.PHONY: check check-repository help

check: check-repository

# The standard files exist, and (except in repo-template itself) no template markers remain.
check-repository:
	@status=0; \
	for file in $(STANDARD_FILES); do \
		[ -f "$$file" ] || { echo "missing standard file: $$file"; status=1; }; \
	done; \
	if git config --get remote.origin.url | grep -q 'dialectic-playground/repo-template'; then \
		echo "repo-template: template markers are expected here; skipping the marker check"; \
	else \
		marker="TEMPLATE"; marker="$$marker:"; \
		if grep -rn --exclude-dir=.git --exclude-dir=.github --exclude-dir=tools "$$marker" .; then \
			echo "replace every $$marker marker listed above"; status=1; \
		fi; \
	fi; \
	exit $$status

help:
	@sed -n '3,11p' Makefile | sed 's/^# \{0,1\}//'

endif
