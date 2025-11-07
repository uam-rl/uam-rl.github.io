// Central chapter configuration
#let chapters = (
  (
    title: "UAM RL",
    file: "main.typ",
  ),
  (
    title: "Introducción",
    file: "introduccion.typ",
  ),
)

// Centralized CSS for all HTML pages
#let inject-all-css() = context {
  if target() == "html" {
    html.elem("style", "
      /* Web fonts */
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-sans@5.0.0/400.css');
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-sans@5.0.0/700.css');
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-mono@5.0.0/index.css');

      /* Body and layout */
      body {
        font-family: 'DejaVu Sans', 'Verdana', sans-serif;
        max-width: 65ch;
        margin: 0 auto;
        padding: 2rem;
        /* Center content in the space remaining after sidebar */
        margin-left: calc((100vw + 11.25rem - 65ch) / 2);
      }

      /* Code blocks */
      code, pre {
        font-family: 'DejaVu Mono', 'DejaVu Sans Mono', 'Consolas', monospace;
      }

      /* Headings */
      h1, h2, h3 {
        color: #667eea;
        font-weight: 700;
      }

      /* Bold text */
      strong, b {
        font-weight: 700;
      }

      /* SVG styling */
      svg {
        margin: 1.5em auto;
        display: block;
        border-radius: 0.5rem;
      }

      span svg {
        margin: 0;
        display: inline-block;
        vertical-align: middle;
      }

      /* Links */
      a {
        color: #667eea;
        text-decoration: none;
      }

      a:hover {
        color: #764ba2;
      }

      /* Sidebar */
      aside {
        position: fixed;
        left: 0;
        top: 0;
        width: 11.25rem;
        height: 100vh;
        border-right: 0.125rem solid #667eea;
        padding: 2rem 1rem;
        overflow-y: auto;
        box-sizing: border-box;
      }

      /* Remove list markers and default spacing */
      aside ul {
        list-style: none;
        padding: 0;
        margin: 0;
      }

      aside li {
        margin-bottom: 1rem;
      }

      aside a {
        display: block;
      }
    ")
  }
}

#let sidebar = html.aside(list(
  ..chapters.map(chapter =>
    link(chapter.file.replace(".typ", ".html"), [#chapter.title])
  )
))
