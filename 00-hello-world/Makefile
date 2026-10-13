# 00-hello-world: Standard Terminal Hello World, in Perl (5.42).
#
# Extends the universal build contract in shared/templates/BASE-MAKEFILE:
#
#   make all | install | uninstall | test | check | lint | format | clean | distclean
#   make test-hidden | grade | help
#
# Layout: src/lib holds the DP::Hello modules, src/bin the extensionless `#!/usr/bin/env perl`
# launcher, src/t the Test::More unit tests (run with prove). dp-hello uses only core modules.
#
# Development tools: cpanfile pins Perl::Critic and Perl::Tidy exactly, and cpanfile.snapshot
# (Carton) locks every transitive dependency. `carton install --deployment` installs them into
# local/ in this directory, on first use by lint/format. local/ is rebuilt automatically when
# the perl that runs make changes (container vs native perl, other architecture or version).
#
# Build: nothing to compile. `make all` leaves src/bin/dp-hello executable, so BIN_DIR is
# src/bin. Lint runs Perl::Critic (.perlcriticrc) and fails unless every file is perltidy-clean
# (.perltidyrc); format applies perltidy in place.
#
# Install: src/{bin,lib} go to $(LIBDIR)/pl/00-hello-world, and a `#!/bin/sh` launcher that runs
# the installed bin/dp-hello with the absolute path of the installing perl goes to
# $(BINDIR)/dp-hello. Uninstall removes both.
#
# Every tool is started as `perl <script>` (never through PATH lookup of a script), so it
# works the same in Git Bash on Windows, where scripts such as prove are .bat wrappers.
#
# Container-first: goals run in the toolchain container built from the repository's
# Containerfile (podman, then docker, then local; override with DP_RUNTIME).

PROJECT := 00-hello-world
TOOLS   := dp-hello

# Path to the sdlc-curriculum checkout (the specs, test suites, and runner live there).
CURRICULUM_ROOT ?= ../sdlc-curriculum

PERL ?= perl

# Directory that contains the built executables after `make all`.
BIN_DIR := src/bin

# Where `make install` puts the payload (see the header).
INSTALL_DIR = $(LIBDIR)/pl/$(PROJECT)

# Perl sources checked by lint and rewritten by format.
PERL_SOURCES = src/bin/dp-hello $(sort $(wildcard src/lib/*.pm src/lib/*/*.pm src/lib/*/*/*.pm)) \
	$(sort $(wildcard src/t/*.t))

# Locked development tools in local/ (see the header). The stamp records the perl they were
# built for; a different perl (container vs native) reinstalls them.
CARTON     = $(PERL) -MCarton::CLI -e 'exit Carton::CLI->new->run(@ARGV)' --
LOCAL_PERL = $(PERL) -Mlib=local/lib/perl5
PERL_ID    = $(shell $(PERL) -MConfig -e 'print "$$Config{archname}-$$Config{version}"')
DEPS_STAMP = local/.dp-deps-$(PERL_ID)
define INSTALL_DEPS
@[ -f "$(DEPS_STAMP)" ] || { rm -rf local && $(CARTON) install --deployment && touch "$(DEPS_STAMP)"; }
endef

DP_BUILD = chmod +x $(BIN_DIR)/dp-hello

DP_UNIT_TEST = $(PERL) -MApp::Prove -e 'my $$p = App::Prove->new; $$p->process_args(@ARGV); \
	exit($$p->run ? 0 : 1)' -- -Isrc/lib src/t

define DP_LINT
$(INSTALL_DEPS)
$(LOCAL_PERL) local/bin/perlcritic $(PERL_SOURCES)
@status=0; for file in $(PERL_SOURCES); do \
	$(LOCAL_PERL) local/bin/perltidy --assert-tidy --standard-output --standard-error-output \
		"$$file" > /dev/null || status=1; \
done; \
[ $$status -eq 0 ] && echo "perltidy: $(words $(PERL_SOURCES)) files are tidy" \
	|| { echo "perltidy: run 'make format'" >&2; exit 1; }
endef

define DP_FORMAT
$(INSTALL_DEPS)
$(LOCAL_PERL) local/bin/perltidy --backup-and-modify-in-place --backup-file-extension=/ \
	$(PERL_SOURCES)
endef

define DP_INSTALL
rm -rf "$(INSTALL_DIR)"
mkdir -p "$(INSTALL_DIR)" "$(BINDIR)"
cp -R src/bin src/lib "$(INSTALL_DIR)/"
printf '#!/bin/sh\nexec %s %s "$$@"\n' "'$$($(PERL) -e 'print $$^X')'" \
	"'$(INSTALL_DIR)/bin/dp-hello'" > "$(BINDIR)/dp-hello"
chmod +x "$(BINDIR)/dp-hello"
"$(BINDIR)/dp-hello" --version
endef

define DP_UNINSTALL
rm -f "$(BINDIR)/dp-hello"
rm -rf "$(INSTALL_DIR)"
rmdir "$(LIBDIR)/pl" "$(LIBDIR)" 2>/dev/null || true
endef

# Nothing is generated except perltidy's leftovers if it is interrupted.
DP_CLEAN = rm -f $(addsuffix .tdy,$(PERL_SOURCES)) $(addsuffix .ERR,$(PERL_SOURCES)) perltidy.LOG

# The locked development tools (Carton's local/ and its .carton state).
DP_DISTCLEAN = rm -rf local .carton

include $(CURRICULUM_ROOT)/shared/templates/BASE-MAKEFILE
