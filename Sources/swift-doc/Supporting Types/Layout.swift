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
        <style type="text/css">
        \#(unsafeUnescaped: css)
        </style>
    </head>
    <body>
        <header>
            <strong>
                <a href="/">\#(page.module.name)</a>
            </strong>
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
