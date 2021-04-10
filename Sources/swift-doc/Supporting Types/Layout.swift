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
        <script src="\#(path(for: "all.js", with: page.baseURL))"></script>
    </head>
    <body>
        <header>
            <div class="title-container">
                <a href="\#(page.baseURL)">
                    <strong>
                        \#(page.module.name)
                    </strong>
                    <span>Documentation</span>
                </a>
                <sup>Beta</sup>
            </div>
            <span class="spacer"></span>
            <div class="theme-select-container">
                <label for="theme-switcher">Theme:</label>
                <select name="theme" id="theme-switcher">
                    <option id="theme-option-auto" value="auto">Auto (light)</option>
                    <option value="light">Light</option>
                    <option value="dark">Dark</option>
                </select>
            </div>
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
            \#(FooterPage(baseURL: page.baseURL).html)
        </footer>
    </body>
    </html>

    """#
}
