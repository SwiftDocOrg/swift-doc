import SwiftDoc
import HypertextLiteral
import Foundation

func layout(_ page: Page & HTMLRenderable, with generator: HTMLGenerator) throws -> HTML {
    let html = try page.render(with: generator)

    return #"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>\#(generator.options.moduleName) - \#(page.title)</title>
        \#(generator.options.inlineCSS ? "" :
    #"<link rel="stylesheet" type="text/css" href="\#(generator.options.baseURL.appendingPathComponent("all.css"))" media="all" />"#
        )
    </head>
    <body>
        <header>
            <a href="\#(generator.options.baseURL)">
                <strong>
                    \#(generator.options.moduleName)
                </strong>
                <span>Documentation</span>
            </a>
            <sup>Beta</sup>
        </header>

        <!--
        <form class="search">
            <input type="search" placeholder="Search" />
        </form>
        -->

        <nav>
            <div class="wrapper">
                <h2>On This Page</h2>
                \#(unsafeUnescaped: sidebar(for: html.description))
            </div>
        </nav>

        <main>
            <article>
                \#(html)
            </article>
        </main>

        <footer>
            \#(FooterPage().render(with: generator))
        </footer>
    </body>
    </html>

    """#
}
