SHELL = /bin/bash

prefix ?= /usr/local
bindir ?= $(prefix)/bin
srcdir = Sources

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
SOURCES = $(wildcard $(srcdir)/**/*.swift)

$(BUILDDIR)/release/swift-doc: $(SOURCES)
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"

swift-doc: $(BUILDDIR)/release/swift-doc
	@cp $< $@

.PHONY: install
install: $(BUILDDIR)/release/swift-doc
	@install -d "$(bindir)"
	@install "$(BUILDDIR)/release/swift-doc" "$(bindir)"
	@cp -R "$(BUILDDIR)/release/swift-doc_swift-doc.bundle" "$(bindir)"

.PHONY: uninstall
uninstall:
	@rm -rf "$(bindir)/swift-doc"
	@rm -rf "$(bindir)/swift-doc_swift-doc.bundle"

.PHONY: clean
distclean:
	@rm -f $(BUILDDIR)/release

.PHONY: clean
clean:
	@rm -rf $(BUILDDIR)
