# 27-line-wrap: Greedy Word-Wrapping Text Formatter
#
# Project Makefile template. It extends the universal build contract in
# shared/templates/BASE-MAKEFILE, which defines the standard targets:
#
#   make all | install | uninstall | test | check | lint | format | clean | distclean
#   make test-hidden | grade | help
#
# A language implementation repository copies this file next to its sources, sets BIN_DIR,
# fills in each DP_* hook with its toolchain's commands, and points CURRICULUM_ROOT at its
# checkout of sdlc-curriculum (for example a git submodule). Hooks that are left empty make
# their target fail with an explanation. `make help` shows which hooks are defined.
#
# Container-first: goals run in the toolchain container built from the repository's
# Containerfile (podman, then docker, then local; override with DP_RUNTIME). The image needs
# the language toolchain, make, and python3 >= 3.11. Use DP_RUNTIME=local for native builds.

PROJECT := 27-line-wrap
TOOLS   := dp-wrap

# Path to the sdlc-curriculum checkout (the specs, test suites, and runner live there).
CURRICULUM_ROOT ?= ../sdlc-curriculum

# Directory that contains the built executables after `make all`, e.g. build/bin.
BIN_DIR :=

# Language-specific commands. Use $(TOOLS), $(EXE), $(PREFIX), and $(BINDIR) as needed.
DP_BUILD     =
DP_INSTALL   =
DP_UNINSTALL =
DP_UNIT_TEST =
DP_LINT      =
DP_FORMAT    =
DP_CLEAN     =
DP_DISTCLEAN =

include $(CURRICULUM_ROOT)/shared/templates/BASE-MAKEFILE
