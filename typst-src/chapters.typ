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
        margin-bottom: 2rem;
      }

      aside a {
        display: block;
      }

      /* SVG elements inherit fill for Dark Reader compatibility */
      svg path, svg use {
        fill: inherit;
      }

      /* Math equations: ensure they use currentColor for dark mode */
      .dark-reader-fix-text svg {
        color: inherit;
      }

      /* Override the #0a090b fill from Typst with currentColor */
      .dark-reader-fix-text svg *[fill='#0a090b'] {
        fill: currentColor;
      }

      /* Chapter navigation */
      nav.chapter-nav {
        display: flex;
        justify-content: space-between;
        margin-top: 4rem;
        padding-top: 2rem;
        border-top: 0.125rem solid #667eea;
      }

      nav.chapter-nav a {
        display: flex;
        flex-direction: column;
        padding: 1rem;
        border: 0.125rem solid #667eea;
        border-radius: 0.5rem;
        transition: background-color 0.2s;
        min-width: 10rem;
      }

      nav.chapter-nav a:hover {
        background-color: rgba(102, 126, 234, 0.1);
      }

      nav.chapter-nav .nav-label {
        font-size: 0.875rem;
        opacity: 0.7;
        margin-bottom: 0.25rem;
      }

      nav.chapter-nav .nav-title {
        font-weight: 700;
      }

      nav.chapter-nav .nav-prev {
        text-align: left;
      }

      nav.chapter-nav .nav-next {
        text-align: right;
        margin-left: auto;
      }
    ")
  }
}


#let fix-math(eq) = context {
  // Target is the only thing here that needs a context block, This is the
  // modern approach, but requires compilation with the html feature enabled
  if target() == "html" {
    // Use uncommon near-black color for HTML SVG generation
    // #0a090b is visually identical to black but uncommon enough for post-processing
    set text(fill: rgb("#0a090b"))
    if eq.block {
      html.div(class: ("math", "block", "dark-reader-fix-text"),
        html.frame(eq)
      )           // Block: div wraps SVG
    } else {
      box(html.span(class: ("inline-math", "dark-reader-fix-text"),
        html.frame(eq)
      ))      // Inline: box wraps span wraps SVG
    }
  } else {
    eq                         // PDF: native math (uses default color)
  }
}

#let sidebar = html.aside(list(
  ..chapters.map(chapter =>
    link(chapter.file.replace(".typ", ".html"), [#chapter.title])
  )
))

// Chapter navigation (previous/next)
#let chapter-nav(current-file) = context {
  if target() == "html" {
    // Find current chapter index
    let current-idx = none
    for (i, chapter) in chapters.enumerate() {
      if chapter.file == current-file {
        current-idx = i
        break
      }
    }

    if current-idx != none {
      let nav-content = ()

      // Previous chapter
      if current-idx > 0 {
        let prev = chapters.at(current-idx - 1)
        nav-content.push(
          html.a(
            href: prev.file.replace(".typ", ".html"),
            class: "nav-prev",
          )[
            #html.div(class: "nav-label")[$<-$ Previous]
            #html.div(class: "nav-title")[#prev.title]
          ]
        )
      }

      // Next chapter
      if current-idx < chapters.len() - 1 {
        let next = chapters.at(current-idx + 1)
        nav-content.push(
          html.a(
            href: next.file.replace(".typ", ".html"),
            class: "nav-next",
          )[
            #html.div(class: "nav-label")[Next $->$]
            #html.div(class: "nav-title")[#next.title]
          ]
        )
      }

      // Return navigation if there are any links
      if nav-content.len() > 0 {
        html.nav(class: "chapter-nav")[#nav-content.join()]
      }
    }
  }
}
