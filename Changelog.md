# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `--base-url` option.
  #65 by @kean and #93 by @mattt.
- Added asset pipeline for CSS assets.
  #49 by @kaishin.
- Add `swift-doc` version number to command and generated output.
  #94 by @mattt.

### Changed

- Changed Home page to display globals for HTML format.
  #81 by @kean.
- Changed README to clarify use of `swift-doc` vs. `swift doc`
  on the command line.
  #89 by @mattt.
- Changed the `generate` command to emit a warning if no source
  files are found.
  #92 by @heckj
- Changed CommonMark format output of Home page
  to include summaries alongside top-level symbols, when available.
  #97 by @mattt.
- Changed logging behavior to better communicate errors encountered
  when generating relationship graphs using GraphViz.
  #100 by @mattt.
- Changed HTML format output of Home page
  to move enumeration cases under initializers.
  #103 by @mattt.

### Fixed

- Fixed relationship handling for members of nested types.
  #62 by @victor-pavlychko.
- Fixed rendering of type relationships section when no graph data is available.
  #62 by @victor-pavlychko.
- Fixed rendering of protocol requirements in the HTML version.
  #76 by @victor-pavlychko.
- Fixed default location of sources reference in README
  #92 by @heckj
- Fixed indentation of code examples.
  #114 by @samsymons

## [1.0.0-beta.2] - 2020-04-08

### Changed

- **Breaking Change**
  Changed the SwiftDoc GitHub Action to require a secret named
  `GH_PERSONAL_ACCESS_TOKEN` (previously `GITHUB_PERSONAL_ACCESS_TOKEN`).
  According to the GitHub Help article
  ["Creating and storing encrypted secrets"](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#creating-encrypted-secrets):
  > Secret names cannot include any spaces or start with the `GITHUB_` prefix.
  > 8837d82 by @mattt.
- **Breaking Change**
  Changed the SwiftDoc GitHub Action to require a `module-name` parameter
  and accepts a `format` parameter.
  b231c07 by @mattt.
- Changed output for CommonMark format to omit Home page
  for output with only a single page.
  #55 by @mattt.
- Changed output for CommonMark format to nest sections in Members component.
  #55 by @mattt.
- Changed output for CommonMark format to remove initializer clauses
  from variable and enumeration case declarations.
  #55 by @mattt.
- Changed CI tests to build and run with a `release` configuration
  for consistency with the executable built with `make install`.
  #51 by @mattt.
- Changed use of `print` statements,
  replacing them with a formal logging infrastructure.
  #52 by @mattt.

### Fixed

- Fixed bug in `SourceFile.Visitor` that caused incorrect results
  when determining the context of symbols parsed from Swift source files.
  #51 by @mattt.
- Fixed SwiftDoc GitHub action to build against latest version of `swift-doc`.
  5c0e4e0 by @mattt
- Fixed output for CommonMark format to escape GitHub Emoji shortcodes
  #55 by @mattt.
- Fixed output for CommonMark format to remove duplicate headings
  for global symbol pages.
  #55 by @mattt.
- Fixed documentation for SwiftDoc GitHub Action
  to clarify that only a single path can be specified for the `input` parameter.
  c34ccc1 by @mattt (#19).
- Fixed `coverage` subcommand description.
  #16 by @rastersize.

## [1.0.0-beta.1] - 2020-04-01

### Added

- Added HTML output format.
  #21 by @mattt.

### Changed

- **Breaking Change**
  Changed minimum Swift version requirements to 5.2 or later.
  #21 by @mattt.
- Changed command-line interface to provide functionality through subcommands.
  #21 by @mattt.
- Changed `Package.swift` to add `swift-doc` executable and `SwiftDoc` library
  to the list of package products.
  #21 by @mattt.

## [0.1.1] - 2020-03-30

### Changed

- Changed documentation workflow to use `github-wiki-publish-action@v1`.
  4525b8e by @mattt.

## [0.1.0] - 2020-03-28

### Added

- Added initial test suite for `SwiftDoc` target.
  #17 by @mattt.

### Changed

- Changed command-line interface to use `swift-argument-parser`.
  #20 by @mattt.

### Fixed

- Fixed treatment of members of public protocol to be considered public symbols.
  #17 by @mattt.

### Removed

- Removed `api-inventory` subcommand.
  (This functionality can now be found in its own repository:
  https://github.com/SwiftDocOrg/swift-api-inventory)
  #17 by @mattt.

## [0.0.4] - 2020-03-10

### Changed

- Changed `Package.swift` to include `SwiftDoc` library product in manifest.
  f852a14 by @mattt.
- Changed documentation workflow to generate docs for `SwiftDoc` sources only.
  da04436 by @mattt.

### Fixed

- Fixed generation to return symbols in consistent order.
  97b2347 by @mattt.
- Fixed how enumeration cases are considered to have public access level.
  774faf6 by @mattt.

## [0.0.3] - 2020-02-13

### Added

- Added CI workflow.
  ce40367 by @mattt.
- Added documentation workflow.
  a47f178 by @mattt.

### Changed

- Changed documentation generation to filter non-public symbols.
  3af57a6 by @mattt.

## [0.0.2] - 2020-02-06

### Added

- Added "Installation" section to README.
  7784bef by @mattt.
- Added experimental `swift-api-diagram` executable.
  017e920 by @mattt.

### Fixed

- Fixed division by zero when calculating documentation coverage.
  #5 by @mattt.
- Fixed treatment of directories with `.swift` suffix.
  #14 by @mattt.
- Fixed errors in README.
  #4 by @Dinsen.
  #6 by @HeEAaD.
  #10 by @morqon

## [0.0.1] - 2020-01-27

Initial release.

[unreleased]: https://github.com/SwiftDocOrg/swift-doc/compare/1.0.0-beta.1...master
[1.0.0-beta.2]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.2
[1.0.0-beta.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.1
[0.1.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.1.1
[0.1.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.1.0
[0.0.4]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.4
[0.0.3]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.3
[0.0.2]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.2
[0.0.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.1
