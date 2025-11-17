# Souce for uam-rl's website

This is the source for the website of the [uam-rl](https://github.com/uam-rl)
organization.

We build a webside using a one of a kind generation method, using typst native
html export, and a custom python scripts for (pre|post)-processing. The idea is
to have a single source of truth and for it to be a high quality academic
document.


## Building

### With nix


#### Building the entire project

From the root of the project, run
```sh
nix build .#all
ls result
```
the result should in in `./result`, this includes all HTML files, light PDFs, and dark PDFs.

```
index.html  introduccion.html  introduccion.pdf  introduccion-dark.pdf  main.html  main.pdf  main-dark.pdf
```

To build all PDFs (both light and dark):
```sh
nix build .#pdf
```

To build only light PDFs:
```sh
nix build .#light-pdf
```

To build only dark PDFs:
```sh
nix build .#dark-pdf
```

#### Building a single page or file

```sh
# Build single chapter PDF:

nix build .#main-pdf           # Build main.pdf
nix build .#introduccion-pdf   # Build introduccion.pdf

# Build dark theme PDFs:

nix build .#main-pdf-dark           # Build main-dark.pdf
nix build .#introduccion-pdf-dark   # Build introduccion-dark.pdf

# Build single chapter HTML:

nix build .#main-html           # Build main.html
nix build .#introduccion-html   # Build introduccion.html
```

after building, the result will be in `./result` as before.

**Note:** Dark theme PDFs have a dark background and light text, ideal for night reading.

### Without nix

1. From the repo root, compile any chapter with Typst (both HTML and PDF builds
   need the `html` feature because the templates gate some logic on `target()`):
   ```sh
   typst compile --features html typst-src/main.typ build/main.html
   typst compile --features html typst-src/main.typ build/main.pdf

   # For dark theme PDFs, add --input theme=dark:
   typst compile --features html --input theme=dark typst-src/main.typ build/main-dark.pdf
   ```
   Replace `main.typ` with any chapter listed in `typst-src/chapters.toml`.

2. (Optional but recommended for HTML outputs) run the post-processing step that
   adjusts SVG fills so Dark Reader and similar dark-mode tools render equations
   correctly:
   ```sh
   python3 typst-src/fix-svg-fills.py build/main.html
   ```

3. Repeat for other chapters (e.g., `introduccion.typ`) and copy/symlink the
   resulting files wherever you host them (`index.html` should point to `main.html`).


## Development

### With nix

You can use
```sh
nix run .#watch-{chapter-title}
```
to watch the changes in `./typst-src/{chapter-title}.typ`.

To build the project, use
```sh
nix build .#all
```
along the commands of the previous section.

To add a new chapter, you should modify `./typst-src/chapters.toml`, the
reasoning behind storing this in a toml file is for nix and typst to be able to
parse it.

Each chapter `.typ` file has the following structure:
for example, for a filed called `filename.typ`:
```typst
#import "template.typ" as tp
#show: tp.cool-web-page.with(
  current-file: "filename.typ",
)
```

To add files typst needs at compile time, ...
place them in `typst-src/` and add an entry under `commonArgs.virtualPaths`
in `flake.nix`. Each entry maps a build-time destination (what Typst sees)
to the real file in the repo, for example:

```nix
{
  dest = "typst-src/project-icon.png";
  src = "${./typst-src/project-icon.png}";
}
```

This ensures `typst compile` can read the asset inside the sandbox, and any
HTML/PDF outputs referencing it will work both locally and in CI. Add a
similar copy step in the `build-all` derivation if the resulting HTML needs
the asset alongside it (see the favicon entry for reference).

The reasoning behind saving everything that can interact with the typst
compilation in the `typst-src/` directory is to make it easier to use the
github actions to know when they should rebuild the project.



## Key ideas

### Reproducible builds
The file `flake.nix` is the main entry point for the project, it defines the
inputs and outputs of the project. It uses `typix`, which is a wrapper around
typst, to build the project while maintaining purity by checking hashes of the
inputs, and isolating the build environment from the network and external files.




## Project sturucture

```
.
├── flake.nix           # Nix inputs/outputs and build logic
├── flake.lock          # Pinned dependency versions
└── typst-src/          # All Typst sources, assets, and helpers
    ├── chapters.toml   # Chapter metadata loaded by Typst/Nix
    ├── main.typ        # Main chapter entry point
    └── template.typ    # Shared layout/theme
```
