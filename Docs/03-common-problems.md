# Common problems when using `swift-doc`


> I want to exclude certain classes / methods / properties from the generated documentation.

Currently, setting the access level is the only one option to control which symbols will appear in the created documentation. 
You can make a function, class, and so on `public` 
to make it appear in the generated documentation. 
Or you can set the `minimum-access-level` flag 
to also include `internal` symbols in the created documentation.

---

> The generated documentation is empty. `swift-doc` outputs the following warnings:
> ```
> warning: No public API symbols were found at the specified path. No output was written.
> warning: By default, swift-doc only includes public declarations. Maybe you want to use --minimum-access-level to include non-public declarations?
> ```

By default, `swift-doc` only documents functions, classes, and so on which are declared `public`. 
If `swift-doc` can't find any public symbol, 
it doesn't have anything to generate documentation for.

Very often this is the case for apps which use only `internal` declarations.

You can use the `minimum-access-level` flag 
to also include `internal` declarations in the created documentation.

---

> I need to use a feature which is not implemented in `swift-doc`.

We are very happy to hear your feedback! 
Please feel free to 
[open an issue on GitHub with a feature request](https://github.com/SwiftDocOrg/swift-doc/issues). 
Please make sure to use the search first 
and check if there might be some existing or closed issue describing your problem already.
