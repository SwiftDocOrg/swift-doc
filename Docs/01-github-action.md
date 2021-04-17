# Building documentation via the GitHub Action

We assume that you already have a 
[basic knowledge of GitHub actions](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions)
and understand how they work.

## Creating documentation with a GitHub action

Let's create a GitHub action which first checks out the source code of your project 
and then it builds the documentation for your Project. 
We assume that your awesome project has its Swift source files at the path `Sources/AwesomeProject` in your repository.

Add the file `.github/workflows/documentation.yml` to your repository:

# Setting a 
```yaml
name: Documentation

on:
  push:
    branches:
      - main
    paths:
      - .github/workflows/documentation.yml
      - Sources/AwesomeProject/**.swift

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Generate Documentation
        uses: SwiftDocOrg/swift-doc@master
        with:
          inputs: "Sources/SwiftDoc"
          output: "Documentation"
```

Then the next time you push a commit to your `main` branch, 
the workflow is triggered 
and builds the documentation.  

Now, building the documentation is already the first step. 
But very likely you also want to publish the generated documentation somewhere. 
That's why we also provide another GitHub action to automatically upload your documentation
to your project's [GitHub Wiki](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis).

### Automatically upload the generated documentation to your project's GitHub wiki.

The [Github Wiki Publish Action](https://github.com/SwiftDocOrg/github-wiki-publish-action) 
publishes the contents of a directory to your project's wiki from a GitHub action workflow
and is the ideal addition to the `swift-doc` action.

We will extend the example from above and check out the project's source code in a first step, 
then build the documentation in a second step 
and then upload the created documentation to your project's wiki in a third step.

```yaml

name: Documentation

on:
  push:
    branches:
      - main
    paths:
      - .github/workflows/documentation.yml
      - Sources/SwiftDoc/**.swift

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v1
      - name: Generate Documentation
        uses: SwiftDocOrg/swift-doc@master
        with:
          inputs: "Sources/SwiftDoc"
          output: "Documentation"
      - name: Upload Documentation to Wiki
        uses: SwiftDocOrg/github-wiki-publish-action@v1
        with:
          path: "Documentation"
        env:
          GH_PERSONAL_ACCESS_TOKEN: ${{ secrets.GH_PERSONAL_ACCESS_TOKEN }}
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


## Next: Understand documentation comments

Now you know which symbols appear in the generated documentation. 
[Continue with the guide to understand how to write documentation comments in your source code 
to make the best of your documentation](02-documentation-format.md).
