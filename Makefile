# Makefile for dialectic-playground/pl: Perl implementations of the SDLC curriculum.
#
#   make                 same as `make check`
#   make check           everything CI checks: repository, toolchain, every implemented project
#   make toolchain       print and verify the toolchain versions
#   make projects        `make all lint test test-hidden` in every implemented project
#   make roundtrip       install/uninstall round trip for every implemented project (host)
#   make dp-info | dp-shell | dp-image
#
# Every goal runs in the toolchain container built from ./Containerfile: podman, then docker,
# then the local system. Override with DP_RUNTIME=podman|docker|local or DP_IMAGE=<image>.
# roundtrip and help act on the host, so they always run locally.

# Project directories whose implementation is complete enough to build and test, in
# curriculum order (for example: 00-hello-world 01-echo). CI covers exactly these.
IMPLEMENTED :=

DP_HOST_GOALS += help roundtrip
include tools/container.mk
ifeq ($(DP_DELEGATE),)

SHELL := /bin/sh
.DEFAULT_GOAL := check
CURRICULUM_ROOT := sdlc-curriculum
STANDARD_FILES := LICENSE README.md Containerfile Makefile .editorconfig .gitattributes \
	.gitignore .gitmodules .devcontainer/devcontainer.json .github/CODEOWNERS \
	.github/dependabot.yml .github/workflows/ci.yml tools/dp-run tools/container.mk \
	$(CURRICULUM_ROOT)/curriculum.toml
.PHONY: check check-repository toolchain projects roundtrip help

check: check-repository toolchain projects

# Standard files present, the curriculum submodule checked out, a workspace for every
# curriculum project, and no unfinished template markers.
check-repository:
	@status=0; \
	for file in $(STANDARD_FILES); do \
		[ -f "$$file" ] || { echo "missing: $$file (submodule: git submodule update --init)"; status=1; }; \
	done; \
	for slug in $$(sed -n 's/^slug = "\(.*\)"/\1/p' $(CURRICULUM_ROOT)/curriculum.toml 2>/dev/null); do \
		[ -f "$$slug/Makefile" ] || { echo "missing project workspace: $$slug/Makefile"; status=1; }; \
	done; \
	marker="TEMPLATE"; marker="$$marker:"; \
	if grep -rn --exclude-dir=.git --exclude-dir=.github --exclude-dir=tools \
	        --exclude-dir=$(CURRICULUM_ROOT) "$$marker" .; then \
		echo "replace every $$marker marker listed above"; status=1; \
	fi; \
	[ $$status -eq 0 ] && echo "repository: standard files, $(CURRICULUM_ROOT), and project workspaces present"; \
	exit $$status

# Prints each tool's version and fails unless it is on the repository's release line
# (Perl 5.44), so the container image and the native CI toolchains stay in step.
toolchain:
	python3 --version || python --version
	make --version | head -1
	@version="$$(perl -e 'print "$$^V\n"')"; echo "$$version"; echo "$$version" | grep -q '^v5\.44\.' \
		|| { echo 'toolchain: expected a version matching ^v5\.44\.' >&2; exit 1; }
	cpanm --version | head -1

projects:
	@[ -n "$(strip $(IMPLEMENTED))" ] || echo "projects: none implemented yet (IMPLEMENTED is empty)"
	@for project in $(IMPLEMENTED); do \
		$(MAKE) --no-print-directory -C "$$project" all lint test test-hidden || exit 1; \
	done

roundtrip:
	@prefix="$${RUNNER_TEMP:-$${TMPDIR:-/tmp}}/dp-roundtrip"; \
	for project in $(IMPLEMENTED); do \
		$(MAKE) --no-print-directory -C "$$project" install PREFIX="$$prefix" \
			&& $(MAKE) --no-print-directory -C "$$project" uninstall PREFIX="$$prefix" || exit 1; \
	done; echo "roundtrip: $(words $(IMPLEMENTED)) project(s)"

help:
	@sed -n '4,13p' Makefile | sed 's/^# \{0,1\}//'

endif
