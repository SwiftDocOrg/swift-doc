# Documentation format

In general, `swift-doc` uses [Xcode's markup formatting](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/MarkupSyntax.html)
and does not add any additional syntax. 
Therefore, all the rules which apply to writing documentation for Xcode's quick help feature also apply for writing documentation for `swift-doc`.

## Documentation comments

Swift has various ways how you can add comments to source code. 
`swift-doc` will pick up so called _documentation comments_. 
Documentation comments need to either start with three slashes `///` for single-line comments 
or with an extra asterisk `/**` for multiline comments. 
The documentation comments need to precede the symbol they are documenting,
but there can be additional whitespace between the documentation comment and its symbol:

```swift
// This is a regular comment and will not appear in the documentation.
public func someUndocumentedFunction() { }

/*
 This is a regular multiline comment and will not appear in the documentation. 
 */
public func alsoUndocumentedFunction() {
    
}

/// This is a documentation comment.
public func someDocumentedFunction() { }

/// The documentation comment can
/// also span multiple lines. Every line
/// needs to start with three slashes.
public func anotherDocumentedFunction() { }

/**
 This is a multiline documentation comments. Note the extra asterisk.
 */
public func alsoDocumentedFunction() { }


/// This document comment has additional whitespace between the comment and the symbol declaration. This works.

public func alsoDocumentedEvenWithWhitespace() { }
```

## Markup format

There are many guides how you can write documentation comments for Swift. 
There's a 
[guide from Apple](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/SymbolDocumentation.html)
and also an [introduction from NSHipster](https://nshipster.com/swift-documentation/).

Nevertheless, here are also the most important rules in order to write documentation.


### Documenting parameters

Let's start by documenting parameters of functions and methods. 
Start a line in a documentation comment with `-Parameter nameOfTheParameter:` 
where `nameOfTheParamater` is the name of the parameter you want to document:

```swift
/// - Parameter singleArgument:
func singleArgumentFunction(singleArgument: String) { }
```

Many functions have more than one parameter 
and repeating `- Parameter ` all over again can add a lot of visual noise.
Luckily, you can also document parameters as bulleted list:

```swift
/// This is the text of the documentation.
/// 
/// - Parameters:
///   - firstArgument: This is the documentation which explains the first argument.
///   - secondArgument: This is the documentation which explains the second argument.
func generateSomeShit(firstArgument: String, secondArgument: Int) {
    
}
```
 
Functions in Swift can have two different names for parameters: 
An argument label and a parameter name. 
The argument label is used when calling the function. 
The parameter name is used inside the body of the function. 
If no extra argument name is given,
the argument label is the same as the parameter name.

To create documentation for parameters, 
you need to use the name of the parameter (the second, internal name) and not the name of the label.

```swift
/// - Parameters:
///   - argumentName: The documentation which explains the argument.
func functionWithLabelAndArgumentName(externalLabel argumentName: String) {
    print(argumentName)
}
```

### Documenting return values

Documenting return values is very similar to documenting parameters.

Start a line in a documentation comment with `- Returns:` to document the return value of a method or a value:

```swift
/// A function to create the sum of two numbers.
///
/// - Returns: The sum of the two given numbers.
func sum(firstNumber: Int, secondNumber: Int) -> Int {
    return firstNumber + secondNumber
}
```

## Continue

Now you understand how you can write documentation comments to produce a good documentation. 
You're all set to build good and beautiful documentation for users of your software.
However, we also know that all beginnings are difficult.
That's why we also [collected a list of common problems when using swift-doc](03-common-problems.md) 
to provide some guidance for the first problems you might encounter while building your documentation.
