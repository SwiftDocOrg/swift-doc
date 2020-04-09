import HypertextLiteral
import Foundation

func layout(_ page: Page, baseURL: String) -> HTML {
    let html = page.html

    return #"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>\#(page.module.name) - \#(page.title)</title>
        <base href="\#(baseURL)"/>
        <link rel="stylesheet" type="text/css" href="all.css" media="all" />
    </head>
    <body>
        <header>
            <a href="\#(baseURL)">
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
            \#(FooterPage().html)
        </footer>
    </body>
    </html>

    """#
}
