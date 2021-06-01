# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0-rc.1]

### Added

- Added support for generating documentation for
  private symbols.
  #266 by @Lukas-Stuehrk.
- Added anchor links to documentation entries for symbols.
  #275 by @Lukas-Stuehrk.

### Fixed

- Fixed links to type declarations.
  #277 by @Lukas-Stuehrk.
- Fixed bug that caused operator implementations to appear in the documentation
  although they should be omitted because of their lower access level.
  #264 by @Lukas-Stuehrk
- Fixed bug that caused prefix and postfix operators to be omitted
  from generated documentation.
  #262 by @Lukas-Stuehrk.
- Fixed layout of HTML output on large displays.
  #251 by @Lukas-Stuehrk and @mattt.

### Changed

- Changed date formatters to use `en_US_POSIX` locale instead of current locale.
  #289 by @mattt.

### Removed

- Removed <sup>Beta</sup> from header in HTML output.
  #291 by @mattt.

## [1.0.0-beta.6] - 2021-04-24

### Added

- Added support for generating documentation for
  extensions to external types.
  #230 by @Lukas-Stuehrk and @mattt.
- Added support for generating documentation for operators.
  #228 by @Lukas-Stuehrk and @mattt.
- Added end-to-end tests for command-line interface.
  #199 by @MaxDesiatov and @mattt.
- Added `--minimum-access-level` option to `generate` and `coverage` commands.
  #219 by @Lukas-Stuehrk.
- Added support for documenting default implementations.
  #221 by @Lukas-Stuehrk.
- Added `sourceRange` property to `Symbol`.
  #237 by @mattt.

### Fixed

- Fixed public extensions exposing nested code of all access levels.
  #195 by @Tunous.
- Fixed broken links in the relationship graph.
  #226 by @Lukas-Stuehrk.

### Changed

- **Breaking Change**
  Changed minimum Swift version requirements to 5.3 or later.
  #252 by @mattt.
- Changed display of code declarations in HTML.
  #204 by @mattt.
- Changed serialization of `Symbol` to encode and decode `sourceRange` key
  instead of `sourceLocation` key.
  #237 by @mattt.
- Changed commands to warn when invalid paths are passed.
  #242 by @Lukas-Stuehrk.

### Deprecated

- Deprecated `Symbol.sourceLocation` property.
  Use `Symbol.sourceRange.start` instead.
  #237 by @mattt.
- Changed the `generate` command to skip hidden files
  and top-level `Tests` directories.
  #229 by @mattt.

## [1.0.0-beta.5] - 2020-09-29

### Added

- Added support for Swift 5.3.
  #183 by @MaxDesiatov and @mattt.

### Fixed

- Fixed missing GraphViz dependency in Dockerfile.
  #180 by @MaxDesiatov.
- Fixed listing of function parameters, when generating CommonMark documentation.
  #170 by @domcorvasce.
- Fixed version number for swift-doc command.
  #159 by @mattt.
- Fixed relationship diagram to prevent linking to unknown symbols.
  #178 by @MattKiazyk.
- Fixed problems in CommonMark output related to escaping emoji shortcode.
  #167 by @mattt.

### Changed

- Changed GitHub Action to use prebuilt Docker image.
  #185 by @mattt and @MaxDesiatov.

## [1.0.0-beta.4] - 2020-07-31

### Added

- Added icon for associated type symbols.
  #145 by @mattt.

### Changed

- Changed HTML output to show scrollbars only when necessary.
  #132 by @andrewchang-bird.

### Fixed

- Fixed runtime error related to networking and processes on Ubuntu Linux.
  #140 by @JaapWijnen.
- Fixed whitespace of code listings.
  #144 by @mbrandonw.
- Fixed crash when attempting to generate paths with no base URL specified.
  #127 by @mattpolzin, @kareman, and @mattt.
- Fixed display of sidebar icons.
  #145 by @mattt.
- Fixed inclusion of non-public subclasses of public superclasses.
  #131 by @MattKiazyk. #116 by @ApolloZhu.
- Fixed display of bullet list items in documentation discussion parts.
  #130 by @mattt.
- Fixed file and directory unexpected permissions.
  #146 by @niw.
- Fixed declarations for properties without explicit type annotations.
  #150 by @mattt.
- Fixed visual regression for adjacent linked tokens in code block.
  #152 by @mattt.
- Fixed regression that caused nodes in relationships graph
  to not have links to their corresponding symbol documentation.
  #153 by @mattt.
- Fixed markup for parameter descriptions in HTML output.
  #156 by @mattt.

## [1.0.0-beta.3] - 2020-05-19

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
- Fixed indentation of code examples in HTML output.
  #114 by @samsymons
- Fixed icons for symbols in HTML output.
  #115 by @samsymons

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

[unreleased]: https://github.com/SwiftDocOrg/swift-doc/compare/1.0.0-rc.1...master
[1.0.0-rc.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-rc.1
[1.0.0-beta.6]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.6
[1.0.0-beta.5]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.5
[1.0.0-beta.4]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.4
[1.0.0-beta.3]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.3
[1.0.0-beta.2]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.2
[1.0.0-beta.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0-beta.1
[0.1.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.1.1
[0.1.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.1.0
[0.0.4]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.4
[0.0.3]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.3
[0.0.2]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.2
[0.0.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/0.0.1
