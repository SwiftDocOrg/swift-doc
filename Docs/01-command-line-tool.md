# Using the command-line tool

`swift-doc` can be used from the command-line on macOS and Linux.

Before you can use `swift-doc`,
you need to install it first.
It's available via Homebrew and as a Docker container.
Alternatively, you can always build it from sources.

## Installation
### Homebrew

[Homebrew](https://brew.sh/)is a free and open-source package management for macOS and Linux. 
If you are using Homebrew,
run the following command to install `swift-doc` using Homebrew:

```terminal
$ brew install swiftdocorg/formulae/swift-doc
```

### Docker

You can run `swift-doc` from the latest [Docker](https://www.docker.com) image with the following commands:

```terminal
$ docker pull swiftdoc/swift-doc:latest
$ docker run -it swiftdoc/swift-doc
```

### Building from source

You can also build `swift-doc` from source. 
It is written in Swift and requires Swift 5.3 or later.
Run the following commands to build and install from sources:

```terminal
$ git clone https://github.com/SwiftDocOrg/swift-doc
$ cd swift-doc
$ make install
```

`swift-doc` has a dependency on [libxml2](https://en.wikipedia.org/wiki/Libxml2).
It also has an optional dependency on
[Graphviz](https://www.graphviz.org/) 
if you want to generate the relationship graphs.

If you're on Linux, 
you may need to first install these prerequisites. 
You can install it on Ubuntu or Debian by running
the following command:

```terminal
$ apt-get update
$ apt-get install -y libxml2-dev graphviz
```

If you're on macOS, 
Graphviz is available via Homebrew:

```terminal
$ brew install graphviz
```

# Build your first documentation

Let's build some documentation, 
now that you have successfully installed `swift-doc`!
You need to provide two arguments 
to build the documentation. 

The first argument is the name of the module 
for which you build the documentation. 
Usually, you will provide a name that matches your package name.
So if your Swift project is called `AwesomeSwiftLibrary`,
you'd provide `AwesomeSwiftLibrary`
as the name of the module.
The module name is provided via the `--module-name` option.

Besides the module name, 
you need to provide paths to directories containing the Swift source files of your project. 
You need to provide at least one path to a directory, 
but you can provide as many as you want 
if your project is split into different directories.
However, you don't need to provide subdirectories 
-- `swift-doc` will walk through all subdirectories in the provided directories
and collect all Swift files from there.

> **Automatically excluded top-level directories**:
> `swift-doc` tries to do the right thing by default 
> and it optimizes for use cases which are the most common in the Swift community. 
> Therefore, some top-level directories are excluded by default
> because most likely you don't want to include those sources in your documentation. 
> Those excluded directories are:
> - `./node-modules/`
> - `./Packages/`
> - `./Pods/`
> - `./Resources/`
> - `./Tests/`
> 
> If you want to include those files in your documentation nevertheless, 
> you can always include a direct path to the directory 
> and they will be included. 
> So let's say you have a document structure like this:
> ```
> MyProject/
> ├── Tests
> └── OtherDirectory
> ```
> Then running 
> `swift-doc --module-name MyProject ./MyProject` 
> will only include the files in the subdirectory `OtherDirectory` 
> and automatically exclude the `Tests` subdirectory.
> But running
> `swift-doc --module-name MyProject ./MyProject ./MyProject/Tests` 
> will also include all files in the `Tests` subdirectory.

Let's run the command in the directory of your project.

```terminal
$ swift-doc generate --module-name AwesomeSwiftLibrary ./Sources/
```

And that's it! 
You successfully created the first documentation of your project.
But where can you find it?

By default, `swift-doc` writes the generated documentation into the directory at `.build/documentation/`.
You can provide a different output directory with the `--output` option:

```terminal
$ swift-doc generate --module-name AwesomeSwiftLibrary ./Sources/ --output some/other/directory
```

## Changing the output format to a rendered website.

If you followed the steps until now 
and checked the documentation which was created, 
you could see that `swift-doc` generated a collection of markdown files as output your documentation.
Those markdown files are build with specific file names
and with a specific folder structure, 
so they can be used for publication to your project's
[GitHub Wiki](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis).

This might be not what you expected. 
Maybe you wanted to generate a website 
which you could publish on the internet as a documentation for the end users of your library?

This option is also provided by `swift-doc`. 
It's called the _output format_ and you can change it by setting the`--format` option. 
In order to generate a website, 
you need to set the option to `html`:

```terminal
$ swift-doc generate --module-name AwesomeSwiftLibrary --format html ./Sources/
```

## Choose which symbols are included by setting the access level

You might have noticed that the generated documentation contained less symbols that your library actually has. 
This is because `swift-doc` only includes public symbols by default 
— as this are also the symbols which are exposed to users of your library.

But if you want to generate documentation for apps and not only for libraries 
or if you want to generate a documentation for developers and not only end users of your library,
then you might want to include additional symbols.

Therefore `swift-doc` also provides the possibility to decide which symbols are included 
by setting the minimum access level from which symbols should be included. 
This is done via the `--minimum-access-level` option. 
Its possible values are:

* `public` (default). 
  This will only include symbols which are declared `public` or `open`. 
  For example, given the following swift source file:
  ```swift
  
  public func publicFunction() { }
  
  func internalFunction() { }
  
  private func privateFunction() { }
  
  public class PublicClass {
      public func publicMethod() { }
  
      open func openMethod() { }
  
      func internalMethod() { }  
  }
  
  internal class InternalClass {
        private func privateMethod() { }
  }
  ```
  
  Then the generated documentation will include the function `publicFunction()` and the class `PublicClass`.
  For the documentation of `PublicClass`, 
  it will only include the methods `publicMethod()` and `openMethod()`.
  
* `internal`. 
  This will include all symbols which are declared `public`, `open`, and `internal`. 
  So in the example above, 
  it will additionally include the function `internalFunction()` and the class `InternalClass`. 
  But for the documentation of `InternalClass`, it will not include the method `privateMethod()`.
  
* `private`.
  This will also include all symbols which are declared `private` and `fileprivate`
  and effectively include symbols.

# Next: Understanding documentation comments

Now you know which symbols appear in the generated documentation. 
[Continue with the guide to understand how to write documentation comments in your source code 
to make the best of your documentation](02-documentation-format.md).
