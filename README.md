# swift-doc

![CI][ci badge]

A package for generating documentation for Swift projects.

Given a directory of Swift files,
`swift-doc` generates HTML or CommonMark (Markdown) files
for each class, structure, enumeration, and protocol
as well as top-level type aliases, functions, and variables.

**Example Output**

- [HTML][swiftsemantics html]
- [CommonMark / GitHub Wiki][alamofire wiki]

## Requirements

- Swift 5.3+
- [libxml2][libxml2]
- [GraphViz][graphviz] _(optional)_

## Command-Line Utility

`swift-doc` can be used from the command-line on macOS and Linux.

### Installation

#### Homebrew

Run the following command to install using [Homebrew](https://brew.sh/):

```console
$ brew install swiftdocorg/formulae/swift-doc
```

If you already have `swift-doc` installed,
run the following command to upgrade your installation:

```console
$ brew upgrade swift-doc
```

If installing or upgrading fails with the message
*Error: Failed to download resource "swift-doc"*,
try resetting your installation with the following commands:

```console
$ brew uninstall swift-doc
$ brew untap swiftdocorg/formulae
$ brew install swiftdocorg/formulae/swift-doc
```

#### Docker

You can run `swift-doc` from the latest [Docker][docker] image
with the following commands:

```terminal
$ docker pull swiftdoc/swift-doc:latest
$ docker run -it swiftdoc/swift-doc
```

#### Manually

Run the following commands to build and install manually:

```terminal
$ git clone https://github.com/SwiftDocOrg/swift-doc
$ cd swift-doc
$ make install
```

If you're on Ubuntu Linux,
you may need to first install the prerequisites
by running the following command:

```terminal
$ apt-get update
$ apt-get install -y libxml2-dev graphviz
```

### Usage

    OVERVIEW: A utility for generating documentation for Swift code.
    
    USAGE: swift doc <subcommand>
    
    OPTIONS:
      --version               Show the version.
      -h, --help              Show help information.
    
    SUBCOMMANDS:
      generate                Generates Swift documentation
      coverage                Generates documentation coverage statistics for Swift
                              files
      diagram                 Generates diagram of Swift symbol relationships

> **Note**:
> The `swift` driver provides extensibility through subcommands.
> If you type an unknown subcommand like `swift foo`,
> the system looks for a command called `swift-foo` in your `PATH`.
> This mechanism allows `swift-doc` to be run either directly or as `swift doc`.

#### swift-doc generate

    OVERVIEW: Generates Swift documentation

    USAGE: swift doc generate [<inputs> ...] --module-name <module-name> [--output <output>] [--format <format>] [--base-url <base-url>]

    ARGUMENTS:
      <inputs>                One or more paths to a directory containing Swift files. 

    OPTIONS:
      -n, --module-name <module-name>
                              The name of the module 
      -o, --output <output>   The path for generated output (default:
                              .build/documentation)
      -f, --format <format>   The output format (default: commonmark)
      --base-url <base-url>   The base URL used for all relative URLs in generated
                              documents. (default: /)
      --minimum-access-level <minimum-access-level>
                              The minimum access level of the symbols which should
                              be included. (default: public)
      -h, --help              Show help information.

The `generate` subcommand
takes one or more paths and enumerates them recursively,
collecting all Swift files into a single "module"
and generating documentation accordingly.
Any hidden directories are skipped,
including `.git` and other directories with paths starting with a dot (`.`).
Top-level `Tests` directories are skipped as well.

```terminal
$ swift doc generate path/to/SwiftProject --module-name SwiftProject
$ tree .build/documentation
$ documentation/
├── Home
├── (...)
├── _Footer.md
└── _Sidebar.md
```

By default,
output files are written to `.build/documentation`
in CommonMark / GitHub Wiki format,
but you can change that with the `--output` and `--format` option flags.

```terminal
$ swift doc generate path/to/SwiftProject/Sources --module-name SwiftProject --output Documentation --format html
$ Documentation/
├── (...)
└── index.html
```

By default,
`swift-doc` includes only symbols declared as `public` or `open`
in the generated documentation.
To include `internal` or `private` declarations,
pass the `--minimum-access-level` flag with the specified access level.

#### swift-doc coverage

    OVERVIEW: Generates documentation coverage statistics for Swift files

    USAGE: swift doc coverage [<inputs> ...] [--output <output>]

    ARGUMENTS:
      <inputs>                One or more paths to a directory containing Swift files.

    OPTIONS:
      -o, --output <output>   The path for generated report 
      --minimum-access-level <minimum-access-level>
                              The minimum access level of the symbols which should
                              be included. (default: public)
      -h, --help              Show help information.

The `coverage` subcommand
generates documentation coverage statistics for Swift files.

```terminal
$ git clone https://github.com/SwiftDocOrg/SwiftSemantics.git

$ swift run swift-doc coverage SwiftSemantics/Sources --output "dcov.json"
$ cat dcov.json | jq ".data.totals"
{
  "count": 207,
  "documented": 199,
  "percent": 96.1352657004831
}

$ cat dcov.json | jq ".data.symbols[] | select(.documented == false)"
{
  "file": "SwiftSemantics/Supporting Types/GenericRequirement.swift",
  "line": 67,
  "column": 6,
  "name": "GenericRequirement.init?(_:)",
  "type": "Initializer",
  "documented": false
}
...
```

While there are plenty of tools for assessing test coverage for code,
we weren't able to find anything analogous for documentation coverage.
To this end,
we've contrived a simple JSON format
[inspired by llvm-cov](https://reviews.llvm.org/D22651#change-xdePaVfBugps).

If you know of an existing standard
that you think might be better suited for this purpose,
please reach out by [opening an Issue][open an issue]!

#### swift-doc diagram

    OVERVIEW: Generates diagram of Swift symbol relationships

    USAGE: swift doc diagram [<inputs> ...]

    ARGUMENTS:
      <inputs>                One or more paths to a directory containing Swift files.

    OPTIONS:
      --minimum-access-level <minimum-access-level>
                              The minimum access level of the symbols which should
                              be included. (default: public)
      -h, --help              Show help information.

The `diagram` subcommand
generates a graph of APIs in [DOT format][dot]
that can be rendered by [GraphViz][graphviz] into a diagram.

```terminal
$ swift run swift-doc diagram Alamofire/Source > Alamofire.gv
$ head Alamofire.gv
digraph Anonymous {
  "Session" [shape=box];
  "NetworkReachabilityManager" [shape=box];
  "URLEncodedFormEncoder" [shape=box,peripheries=2];
  "ServerTrustManager" [shape=box];
  "MultipartFormData" [shape=box];

  subgraph cluster_Request {
    "DataRequest" [shape=box];
    "Request" [shape=box];

$ dot -T svg Alamofire.gv > Alamofire.svg
```

Here's an excerpt of the graph generated for Alamofire:

![Excerpt of swift-doc-api Diagram for Alamofire](https://user-images.githubusercontent.com/7659/73189318-0db0e880-40d9-11ea-8895-341a75ce873c.png)

## GitHub Action

This repository also hosts a [GitHub Action][github actions]
that you can incorporate into your project's workflow.

The CommonMark files generated by `swift-doc`
are formatted for publication to your project's [GitHub Wiki][github wiki],
which you can do with
[github-wiki-publish-action][github-wiki-publish-action].
Alternatively,
you could specify HTML format to publish documentation to
[GitHub Pages](https://pages.github.com)
or bundle them into a release artifact.

### Inputs

- `inputs`:
  A path to a directory containing Swift (`.swift`) files in your workspace.
  (Default: `"./Sources"`)
- `format`:
  The output format (`"commonmark"` or `"html"`)
  (Default: `"commonmark"`)
- `module-name`:
  The name of the module.
- `base-url`:
  The base URL for all relative URLs generated in documents.
  (Default: `"/"`)
- `output`:
  The path for generated output.
  (Default: `"./.build/documentation"`)

### Example Workflow

```yml
# .github/workflows/documentation.yml
name: Documentation

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1
      - name: Generate Documentation
        uses: SwiftDocOrg/swift-doc@master
        with:
          inputs: "Sources"
          module-name: MyLibrary
          output: "Documentation"
      - name: Upload Documentation to Wiki
        uses: SwiftDocOrg/github-wiki-publish-action@v1
        with:
          path: "Documentation"
        env:
          GH_PERSONAL_ACCESS_TOKEN: ${{ secrets.GH_PERSONAL_ACCESS_TOKEN }}
```

## Development

### Web Assets

CSS assets used by the HTML output format
are processed and generated by [PostCSS](https://postcss.org).
To make changes to these assets,
you'll need to have [Node.js](https://nodejs.org/en/)
and a package manager, such as [`npm`](https://www.npmjs.com),
installed on your machine.

Navigate to the `.node` directory
and run `npm install` to download the required tools and libraries.

```terminal
$ cd .node
$ npm install
```

> **Note**:
> `package.json` is located at a hidden `.node` subdirectory
> to prevent Xcode from displaying or indexing the contents of `node_modules`
> when opening the main project.

From the `.node` directory,
run the `watch` script
to start watching for changes to files in the `Assets` folder.
Whenever an asset source file is added, removed, or updated,
its corresponding (unoptimized) product is automatically generated
in the `Sources/swift-doc/Generated` folder.

```terminal
$ npm run watch
```

When you're happy with the results,
commit any changes to the source files in `Assets`
as well as the generated files in `Sources/swift-doc/Generated`.

```terminal
$ git add Assets Sources/swift-doc/Generated
$ git commit
```

## Release Process

> The following information is primarily for the benefit of project maintainers.
> That said, if you have any suggestions for how to improve this process,
> please let us know by [opening an issue][open an issue].

Follow these steps to release a new version of `swift-doc`:

- [x] Verify that the latest commit
      [passed all CI checks](https://github.com/SwiftDocOrg/swift-doc/actions?query=workflow%3ACI).
- [x] Update the Changelog by creating a new heading for the release
      and modifying the last path component for the `unreleased` link reference.
- [x] Update the [`version` constant](https://github.com/SwiftDocOrg/swift-doc/blob/master/Sources/swift-doc/main.swift#L25)
      in the command-line executable.
- [x] Create a new commit with the message "Bump version to `$VERSION`",
      where `$VERSION` is a [SemVer]-compatible version number.
- [x] Tag that commit with the tag name "`$VERSION`"
- [x] Run the command `git push origin master --tags`
- [x] Create a new [release](https://github.com/SwiftDocOrg/swift-doc/releases)
      that corresponds to the new tag.

## Known Issues

- Xcode cannot run unit tests (<kbd>⌘</kbd><kbd>U</kbd>)
  when opening the swift-doc package directly,
  as opposed first to generating an Xcode project file with
  `swift package generate-xcodeproj`.
  (The reported error is:
  `Library not loaded: @rpath/lib_InternalSwiftSyntaxParser.dylib`).
  As a workaround,
  you can [install the latest toolchain](https://swift.org/download/)
  and enable it in "Xcode > Preferences > Components > Toolchains".
  Alternatively,
  you can run unit tests from the command line
  with `swift test`.

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[ci badge]: https://github.com/SwiftDocOrg/swift-doc/workflows/CI/badge.svg
[alamofire wiki]: https://github.com/SwiftDocOrg/Alamofire/wiki
[swiftsemantics html]: https://swift-doc-preview.netlify.app
[github wiki]: https://help.github.com/en/github/building-a-strong-community/about-wikis
[github actions]: https://github.com/features/actions
[swiftsyntax]: https://github.com/apple/swift-syntax
[swiftsemantics]: https://github.com/SwiftDocOrg/SwiftSemantics
[swiftmarkup]: https://github.com/SwiftDocOrg/SwiftMarkup
[commonmark]: https://github.com/SwiftDocOrg/CommonMark
[github-wiki-publish-action]: https://github.com/SwiftDocOrg/github-wiki-publish-action
[open an issue]: https://github.com/SwiftDocOrg/swift-doc/issues/new
[jazzy]: https://github.com/realm/jazzy
[swift number protocols diagram]: https://nshipster.com/propertywrapper/#swift-number-protocols
[protocol-oriented programming]: https://asciiwwdc.com/2015/sessions/408
[apple documentation]: https://developer.apple.com/documentation
[se-0195]: https://github.com/apple/swift-evolution/blob/master/proposals/0195-dynamic-member-lookup.md
[se-o258]: https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md
[se-xxxx]: https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md
[swiftdoc.org]: https://swiftdoc.org
[jazzy swiftsemantics]: https://swift-semantics-jazzy.netlify.com
[swift-doc swiftsemantics]: https://github.com/SwiftDocOrg/SwiftSemantics/wiki
[@natecook1000]: https://github.com/natecook1000
[nshipster]: https://nshipster.com
[dependency hell]: https://github.com/apple/swift-package-manager/tree/master/Documentation#dependency-hell
[pcre]: https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions
[dot]: https://en.wikipedia.org/wiki/DOT_(graph_description_language)
[graphviz]: https://www.graphviz.org
[libxml2]: https://en.wikipedia.org/wiki/Libxml2
[docker]: https://www.docker.com
[semver]: https://semver.org
