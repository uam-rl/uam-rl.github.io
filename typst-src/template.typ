#import "@preview/oxifmt:1.0.0": strfmt
#let theme = (
  colors: (
    primary:   rgb("#667eea"),
    secondary: rgb("#764ba2"),
    text:      rgb("#1d1d1d"),
  ),
  light: (
    bg:        rgb("#ffffff"),
    text:      rgb("#1d1d1d"),
    sidebar:   rgb("#f8f9fa"),
    border:    rgb("#667eea"),
    code-bg:   rgb("#f5f5f5"),
  ),
  dark: (
    bg:        rgb("#1a1a1a"),
    text:      rgb("#e0e0e0"),
    sidebar:   rgb("#2d2d2d"),
    border:    rgb("#8b9cff"),
    code-bg:   rgb("#2a2a2a"),
  )
)

// Central chapter configuration - loaded from chapters.toml
#let chapters = toml("chapters.toml").chapters

#let favicon = html.link(
  rel: "icon",
  href: "project-icon.png",
  type: "image/svg+xml"
)

// Theme toggle JavaScript
#let inject-theme-js() = context {
  if target() == "html" {
    // Inline script to load theme before page renders (avoid flash)
    html.elem("script", "
      (function() {
        const savedTheme = localStorage.getItem('theme');
        const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        const shouldBeDark = savedTheme === 'dark' || (savedTheme === null && systemPrefersDark);

        const savedSidebar = localStorage.getItem('sidebar');
        const html = document.documentElement;

        if (shouldBeDark) {
          html.classList.add('dark-theme');
        }
        if (savedSidebar === 'collapsed') {
          html.classList.add('sidebar-collapsed');
        }
      })();
    ")

    // Main theme toggle functionality
    html.elem("script", "
      function toggleTheme() {
        const html = document.documentElement;
        const isDark = html.classList.toggle('dark-theme');
        localStorage.setItem('theme', isDark ? 'dark' : 'light');

        const btn = document.getElementById('theme-toggle');
        if (btn) btn.textContent = isDark ? '☀️' : '🌙';
      }

      function updateSidebarToggle() {
        const html = document.documentElement;
        const collapsed = html.classList.contains('sidebar-collapsed');
        const btn = document.getElementById('sidebar-toggle');
        if (btn) {
          btn.textContent = collapsed ? '☰' : '✕';
          btn.setAttribute('aria-expanded', String(!collapsed));
          btn.setAttribute('aria-label', collapsed ? 'Open navigation menu' : 'Close navigation menu');
        }
        const sidebar = document.querySelector('.site-sidebar');
        if (sidebar) sidebar.setAttribute('aria-hidden', collapsed ? 'true' : 'false');
      }

      function toggleSidebar() {
        const html = document.documentElement;
        const collapsed = html.classList.toggle('sidebar-collapsed');
        localStorage.setItem('sidebar', collapsed ? 'collapsed' : 'expanded');
        updateSidebarToggle();
      }

      window.addEventListener('DOMContentLoaded', () => {
        const html = document.documentElement;
        const isDark = html.classList.contains('dark-theme');
        const btn = document.getElementById('theme-toggle');
        if (btn) btn.textContent = isDark ? '☀️' : '🌙';
        html.classList.add('theme-transition');
        updateSidebarToggle();
      });
    ")
  }
}

// Centralized CSS for all HTML pages
#let inject-all-css() = context {
  if target() == "html" {
    html.elem("style", strfmt("
      /* Web fonts */
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-sans@5.0.0/400.css');
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-sans@5.0.0/700.css');
      @import url('https://cdn.jsdelivr.net/npm/@fontsource/dejavu-mono@5.0.0/index.css');

      /* Body and layout */
      body {{
        font-family: 'DejaVu Sans', 'Verdana', sans-serif;
        max-width: 65ch;
        margin: 0 auto;
        padding: 2rem;
        /* Center content in the space remaining after sidebar */
        margin-left: calc((100vw + 11.25rem - 65ch) / 2);
        background-color: {light-bg};
        color: {light-text};
      }}

      .sidebar-collapsed body {{
        margin-left: auto;
      }}

      .theme-transition body {{
        transition: background-color 0.3s, color 0.3s, margin-left 0.3s;
      }}

      /* Dark theme styles */
      .dark-theme body {{
        background-color: {dark-bg};
        color: {dark-text};
      }}

      .dark-theme .site-sidebar {{
        background-color: {dark-sidebar};
        border-right-color: {dark-border};
      }}

      /* Code blocks */
      code, pre {{
        font-family: 'DejaVu Mono', 'DejaVu Sans Mono', 'Consolas', monospace;
      }}

      /* Headings */
      h1, h2, h3 {{
        color: {primary};
        font-weight: 700;
      }}

      /* Bold text */
      strong, b {{
        font-weight: 700;
      }}

      /* SVG styling */
      svg {{
        margin: 1.5em auto;
        display: block;
        border-radius: 0.5rem;
      }}

      span svg {{
        margin: 0;
        display: inline-block;
        vertical-align: middle;
      }}

      /* Links */
      a {{
        color: {primary};
        text-decoration: none;
      }}

      a:hover {{
        color: {secondary};
      }}

      /* Sidebar */
      .site-sidebar {{
        position: fixed;
        left: 0;
        top: 0;
        width: 11.25rem;
        height: 100vh;
        border-right: 0.125rem solid {primary};
        padding: 2rem 1rem;
        overflow-y: auto;
        box-sizing: border-box;
        display: flex;
        flex-direction: column;
        transition: transform 0.3s ease;
      }}

      .sidebar-collapsed .site-sidebar {{
        transform: translateX(-100%);
      }}

      .site-sidebar .sidebar-header {{
        text-align: center;
        padding-bottom: 1.5rem;
        margin-bottom: 1.5rem;
        border-bottom: 0.125rem solid {primary};
      }}

      .site-sidebar .sidebar-header img {{
        width: 70%;
        max-width: 100%;
        height: auto;
      }}

      /* Theme toggle button */
      #theme-toggle {{
        background: none;
        border: none;
        font-size: 1.5em;
        cursor: pointer;
        padding: 0.5em;
        margin-bottom: 0.5em;
        transition: transform 0.2s;
      }}

      #theme-toggle:hover {{
        transform: scale(1.2);
      }}

      #sidebar-toggle {{
        position: fixed;
        top: 1rem;
        left: calc(11.25rem + 0.75rem);
        z-index: 1000;
        background-color: {light-bg};
        color: {primary};
        border: 0.125rem solid {primary};
        border-radius: 999px;
        padding: 0.35rem 0.9rem;
        font-size: 1rem;
        cursor: pointer;
        box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.15);
        transition: background-color 0.2s, color 0.2s, transform 0.2s, left 0.3s ease;
      }}

      #sidebar-toggle:hover {{
        transform: translateY(-1px);
      }}

      .dark-theme #sidebar-toggle {{
        background-color: {dark-sidebar};
        color: {dark-text};
        border-color: {dark-border};
      }}

      .sidebar-collapsed #sidebar-toggle {{
        left: 1rem;
      }}

      .site-sidebar .sidebar-footer {{
        margin-top: auto;
        text-align: center;
        padding-top: 2rem;
      }}

      /* Remove list markers and default spacing */
      .site-sidebar ul {{
        list-style: none;
        padding: 0;
        margin: 0;
      }}

      .site-sidebar li {{
        margin-bottom: 2rem;
      }}

      .site-sidebar a {{
        display: block;
      }}

      /* Chapter navigation */
      nav.chapter-nav {{
        display: flex;
        justify-content: space-between;
        margin-top: 4rem;
        padding-top: 2rem;
        border-top: 0.125rem solid {primary};
      }}

      nav.chapter-nav a {{
        display: flex;
        flex-direction: column;
        padding: 1rem;
        border: 0.125rem solid {primary};
        border-radius: 0.5rem;
        transition: background-color 0.2s;
        min-width: 10rem;
      }}

      nav.chapter-nav a:hover {{
        background-color: {primary-100};
      }}

      nav.chapter-nav .nav-label {{
        font-size: 0.875rem;
        opacity: 0.7;
        margin-bottom: 0.25rem;
      }}

      nav.chapter-nav .nav-title {{
        font-weight: 700;
      }}

      nav.chapter-nav .nav-prev {{
        text-align: left;
      }}

      nav.chapter-nav .nav-next {{
        text-align: right;
        margin-left: auto;
      }}
    ",
    primary:     theme.colors.primary.to-hex(),
    secondary:   theme.colors.secondary.to-hex(),
    primary-100: theme.colors.primary.transparentize(90%).to-hex(),
    // Light theme colors
    light-bg:       theme.light.bg.to-hex(),
    light-text:     theme.light.text.to-hex(),
    light-sidebar:  theme.light.sidebar.to-hex(),
    light-border:   theme.light.border.to-hex(),
    light-code-bg:  theme.light.code-bg.to-hex(),
    // Dark theme colors
    dark-bg:        theme.dark.bg.to-hex(),
    dark-text:      theme.dark.text.to-hex(),
    dark-sidebar:   theme.dark.sidebar.to-hex(),
    dark-border:    theme.dark.border.to-hex(),
    dark-code-bg:   theme.dark.code-bg.to-hex(),
    ))
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

#let sidebar-toggle-button = html.elem("button", attrs: (
  id: "sidebar-toggle",
  type: "button",
  onclick: "toggleSidebar()",
  aria-label: "Close navigation menu",
  aria-expanded: "true"
))[☰];

#let sidebar = html.aside(
  class: "site-sidebar",
  aria-label: "Primary navigation",
)[
  #html.div(class: "sidebar-header")[
    // Note: html.button() doesn't support onclick or id attributes.
    // We use html.elem() with attrs dictionary to add custom HTML attributes.
    // See references/html-elem.md for documentation.
    #html.elem("button", attrs: (
      id: "theme-toggle",
      onclick: "toggleTheme()",
      type: "button",
      aria-label: "Toggle dark mode"
    ))[🌙]

    #html.img(
      src: "project-icon.png",
      alt: "UAM RL Project Icon"
    )
  ]

  #list(
    ..chapters.map(chapter =>
      link(chapter.file.replace(".typ", ".html"), [#chapter.title])
    )
  )

  #html.div(class: "sidebar-footer")[
    #link("https://github.com/uam-rl/uam-rl.github.io")[
      #box(image("github.svg", width: 1.5em), baseline: 0.1em)
      Source
    ]
  ]
];

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

#let cool-web-page(
  body,
  current-file: none,
) = {
  context {
    if target() == "html" {
      favicon
     }
  }
  inject-all-css()
  inject-theme-js()

  // Determine theme for PDFs from sys.inputs (defaults to "light")
  let pdf-theme = sys.inputs.at("theme", default: "light")
  let use-dark = pdf-theme == "dark"

  // Apply theme colors to PDFs
  // Note: set/show rules inside conditionals (if/else blocks) don't work at the
  // function scope level. Instead, use conditional expressions inside the set/show
  // rules themselves. This ensures the rules are always active with dynamically
  // computed values.
  // Page configuration only applies to PDFs (not allowed in HTML), so we use a
  // show rule to conditionally apply it based on target()
  show: it => context {
    if target() != "html" {
      set page(fill: if use-dark { theme.dark.bg } else { white })
      it
    } else {
      it
    }
  }

  set text(
    fill: if use-dark { theme.dark.text } else { black },
    font: "New Computer Modern",
    size: 11pt
  )
  set heading(numbering: "1.")

  // Use theme-appropriate colors for headings - conditional inside show rules
  show heading.where(level: 1): set text(
    size: 2.25em,
    weight: 700,
    fill: if use-dark { theme.dark.border } else { theme.colors.primary }
  )
  show heading.where(level: 2): set text(
    size: 1.5em,
    weight: 600,
    fill: if use-dark { theme.dark.border } else { theme.colors.primary }
  )
  show link: set text(fill: if use-dark { theme.dark.border } else { theme.colors.primary })

  show math.equation: fix-math
  context {
    if target() == "html" {
      sidebar-toggle-button
      sidebar
    }
  }
  body

  chapter-nav(current-file)

  // GitHub logo at bottom for PDFs
  context {
    if target() != "html" {
      v(2em)
      align(center)[
        #link("https://github.com/uam-rl/uam-rl.github.io")[
          #box(image("github.svg", width: 1em), baseline: 0.1em)
          github.com/uam-rl/uam-rl.github.io
        ]
      ]
    }
  }
}
