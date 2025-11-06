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

// Sidebar function for HTML
#let sidebar() = context {
  if sys.inputs.at("target", default: "pdf") == "html" {
    html.aside()[
      #for chapter in chapters [
        #link(chapter.file.replace(".typ", ".html"))[#chapter.title] \
      ]
    ]
  }
}
