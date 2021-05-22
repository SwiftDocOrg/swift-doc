import SwiftDoc
import HypertextLiteral
import Foundation

func layout(_ page: Page) -> HTML {
    let html = page.html

    return #"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>\#(page.module.name) - \#(page.title)</title>
        <link rel="stylesheet" type="text/css" href="\#(path(for: "all.css", with: page.baseURL))" media="all" />
    </head>
    <body>
        <header>
            <a href="\#(page.baseURL)">
                <strong>
                    \#(page.module.name)
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
            \#(FooterPage(baseURL: page.baseURL, datesLocale: page.datesLocale).html)
        </footer>
    </body>
    </html>

    """#
}
