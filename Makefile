SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

.DEFAULT_GOAL = all

.PHONY: all
all: swift-doc

swift-doc: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

.PHONY: install
install: swift-doc
	@install -d "$(bindir)"
	@install "$(BUILDDIR)/release/swift-doc" "$(bindir)"
	@install "$(BUILDDIR)/release/swift-dcov" "$(bindir)"
	@install "$(BUILDDIR)/release/swift-api-inventory" "$(bindir)"
	@install "$(BUILDDIR)/release/swift-api-diagram" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/swift-doc"
	@rm -rf "$(bindir)/swift-api-diagram"
	@rm -rf "$(bindir)/swift-api-inventory"
	@rm -rf "$(bindir)/swift-dcov"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean: distclean
	@rm -rf $(BUILDDIR)
