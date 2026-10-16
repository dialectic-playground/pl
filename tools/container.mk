# container.mk: container-first execution for make.
#
# Canonical source: https://github.com/dialectic-playground/.github/blob/main/tools/container.mk
# Every repository carries a byte-identical copy at tools/container.mk; CI checks for drift.
#
# Include this file at the TOP of a Makefile and wrap the rest of the Makefile in a guard:
#
#     include tools/container.mk
#     ifeq ($(DP_DELEGATE),)
#     ...variables and targets...
#     endif
#
# When the runtime resolves to a container engine (DP_RUNTIME, default "auto": podman, then
# docker, then local), the requested goals are re-run inside the repository's toolchain
# container, as `make <goals> <command-line variables>` through tools/dp-run. Inside the
# container DP_IN_CONTAINER=1, so the same Makefile then runs the goals natively. With
# DP_RUNTIME=local, or when no container engine is available, goals run on the host directly.
#
# Variables (environment or command line):
#   DP_RUNTIME, DP_IMAGE, DP_PLATFORM, DP_RUN_ARGS, DP_QUIET   see tools/dp-run
#   DP_HOST_GOALS          goals that always run on the host (extend with +=)
#   DP_RUN_FLAGS_<goal>    extra dp-run options when <goal> is delegated, e.g. --port 8000
#
# Targets provided on the host:
#   dp-info    show the resolved runtime, image, and mounts
#   dp-shell   open an interactive shell in the toolchain environment
#   dp-image   build (if needed) and print the toolchain image

DP_TOOLS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
DP_RUN := $(DP_TOOLS_DIR)dp-run
DP_HOST_GOALS += dp-info dp-shell dp-image
export DP_RUNTIME DP_IMAGE DP_PLATFORM DP_RUN_ARGS DP_QUIET

ifeq ($(DP_IN_CONTAINER),)
	DP_RESOLVED := $(shell $(DP_RUN) --resolve)
else
	DP_RESOLVED := local
endif

DP_DELEGATE :=
ifneq ($(DP_RESOLVED),local)
	ifneq ($(filter-out $(DP_HOST_GOALS),$(or $(MAKECMDGOALS),.default)),)
		DP_DELEGATE := 1
	endif
endif

.PHONY: dp-info dp-shell dp-image
dp-info:
	@$(DP_RUN) --info
dp-shell:
	@$(DP_RUN) --shell
dp-image:
	@$(DP_RUN) --image-ref
# Keep the including Makefile's first target as its default goal.
.DEFAULT_GOAL :=

ifeq ($(DP_DELEGATE),1)
.DEFAULT_GOAL := dp-delegate
.PHONY: dp-delegate $(MAKECMDGOALS)
dp-delegate:
	@$(DP_RUN) $(foreach goal,$(MAKECMDGOALS),$(DP_RUN_FLAGS_$(goal))) -- \
		make $(MAKECMDGOALS) $(MAKEOVERRIDES)
$(filter-out dp-delegate,$(MAKECMDGOALS)): dp-delegate
	@:
endif
