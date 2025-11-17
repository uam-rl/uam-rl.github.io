{
  description = "A Typst project that uses Typst packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    # Example of downloading icons from a non-flake source
    # font-awesome = {
    #   url = "github:FortAwesome/Font-Awesome";
    #   flake = false;
    # };
  };

  outputs = inputs @ {
    nixpkgs,
    typix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib;

      typixLib = typix.lib.${system};

      src = typixLib.cleanTypstSource ./.;

      # Python script for post-processing HTML
      fixSvgScript = ./typst-src/fix-svg-fills.py;

      # Load chapter configuration from TOML
      chaptersData = builtins.fromTOML (builtins.readFile ./typst-src/chapters.toml);
      chapters = chaptersData.chapters;
      commonArgs = {
        typstSource = "typst-src/main.typ";

        fontPaths = [
          # Add paths to fonts here
          # "${pkgs.roboto}/share/fonts/truetype"
        ];

        virtualPaths = [
          # Add paths that must be locally accessible to typst here
          # {
          #   dest = "icons";
          #   src = "${inputs.font-awesome}/svgs/regular";
          # }
          {
            dest = "typst-src/chapters.toml";
            src = "${./typst-src/chapters.toml}";
          }
          {
            dest = "typst-src/github.svg";
            src = "${./typst-src/github.svg}";
          }
          {
            dest = "typst-src/project-icon.png";
            src = "${./typst-src/project-icon.png}";
          }
        ];
      };

      unstable_typstPackages = [
        {
          name = "cetz";
          version = "0.4.2";
          hash = "sha256-qBIEHqtiMSG/WoXHPC/rQ9VkestSvVNlUwTmAMX1wAs=";
        }
        # Required by cetz
        {
          name = "oxifmt";
          version = "1.0.0";
          hash = "sha256-edTDK5F2xFYWypGpR0dWxwM7IiBd8hKGQ0KArkbpHvI=";
        }
      ];

      # Helper functions to build chapters
      mkChapterPdf = chapter: typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "typst-src/${chapter.file}";
          name = lib.replaceStrings [".typ"] [".pdf"] chapter.file;
          typstCompileCommand = "typst compile --features html";
        });

      mkChapterPdfDark = chapter: typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "typst-src/${chapter.file}";
          name = lib.replaceStrings [".typ"] ["-dark.pdf"] chapter.file;
          typstCompileCommand = "typst compile --features html --input theme=dark";
        });

      mkChapterHtml = chapter: typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "typst-src/${chapter.file}";
          name = lib.replaceStrings [".typ"] [".html"] chapter.file;
          nativeBuildInputs = [ pkgs.python3 ];
          buildPhaseTypstCommand = ''
            typst compile --features html typst-src/${chapter.file} temp.html
            python3 ${fixSvgScript} temp.html
            mv temp.html "$out"
          '';
        });

      # Generate builds for all chapters dynamically
      chapterBuilds = lib.listToAttrs (lib.flatten (map (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
        in [
          {
            name = "${baseName}-pdf";
            value = mkChapterPdf chapter;
          }
          {
            name = "${baseName}-pdf-dark";
            value = mkChapterPdfDark chapter;
          }
          {
            name = "${baseName}-html";
            value = mkChapterHtml chapter;
          }
        ]
      ) chapters));

      # Convenience aliases for the first chapter (main)
      build-html = chapterBuilds.main-html;

      # Compile a Typst project, *without* copying the result
      # to the current directory
      build-drv = chapterBuilds.main-pdf;

      # Compile a Typst project, and then copy the result
      # to the current directory
      build-script = typixLib.buildTypstProjectLocal (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstCompileCommand = "typst compile --features html";
        });

      # Watch a project and recompile on changes
      watch-script = typixLib.watchTypstProject (commonArgs
        // {
          typstWatchCommand = "typst watch --features html";
        });

      # Helper to create watch scripts for each chapter
      mkChapterWatch = chapter: typixLib.watchTypstProject (commonArgs
        // {
          typstSource = "typst-src/${chapter.file}";
          typstWatchCommand = "typst watch --features html";
        });

      # Generate watch scripts for all chapters dynamically
      chapterWatchScripts = lib.listToAttrs (map (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
        in {
          name = "watch-${baseName}";
          value = mkChapterWatch chapter;
        }
      ) chapters);

      # Build all HTML files into a single directory
      build-html-dir = pkgs.runCommand "html-output" {} (''
        mkdir -p $out
        # Copy all HTML files from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          htmlBuild = chapterBuilds."${baseName}-html";
        in
          "cp ${htmlBuild} $out/${baseName}.html"
      ) chapters);

      # Build all light PDFs
      build-light-pdf = pkgs.runCommand "light-pdfs" {} (''
        mkdir -p $out
        # Copy all light PDFs from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          pdfBuild = chapterBuilds."${baseName}-pdf";
        in ''
          cp ${pdfBuild} $out/${baseName}.pdf
        ''
      ) chapters);

      # Build all dark PDFs
      build-dark-pdf = pkgs.runCommand "dark-pdfs" {} (''
        mkdir -p $out
        # Copy all dark PDFs from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          pdfDarkBuild = chapterBuilds."${baseName}-pdf-dark";
        in ''
          cp ${pdfDarkBuild} $out/${baseName}-dark.pdf
        ''
      ) chapters);

      # Build all PDFs (both light and dark)
      build-pdf = pkgs.runCommand "all-pdfs" {} (''
        mkdir -p $out
        # Copy all PDFs (light and dark) from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          pdfBuild = chapterBuilds."${baseName}-pdf";
          pdfDarkBuild = chapterBuilds."${baseName}-pdf-dark";
        in ''
          cp ${pdfBuild} $out/${baseName}.pdf
          cp ${pdfDarkBuild} $out/${baseName}-dark.pdf
        ''
      ) chapters);

      # Build everything: light PDFs, dark PDFs, and HTMLs
      build-all = pkgs.runCommand "deploy-output-all" {} (''
        mkdir -p $out
        # Copy all PDFs (light and dark) and HTMLs from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          pdfBuild = chapterBuilds."${baseName}-pdf";
          pdfDarkBuild = chapterBuilds."${baseName}-pdf-dark";
          htmlBuild = chapterBuilds."${baseName}-html";
        in ''
          cp ${pdfBuild} $out/${baseName}.pdf
          cp ${pdfDarkBuild} $out/${baseName}-dark.pdf
          cp ${htmlBuild} $out/${baseName}.html
        ''
      ) chapters + ''
        # Copy main.html to index.html for GitHub Pages
        cp $out/main.html $out/index.html
        # Copy static assets referenced by the HTML pages
        cp ${./typst-src/project-icon.png} $out/project-icon.png
      '');

      # Generate apps for chapter watch scripts
      chapterWatchApps = lib.mapAttrs (name: drv: flake-utils.lib.mkApp { inherit drv; }) chapterWatchScripts;
    in {
      checks = {
        inherit build-drv build-script watch-script;
      };

      packages = {
        default = build-drv;
        pdf = build-pdf;           # All PDFs (light and dark)
        light-pdf = build-light-pdf;  # All light PDFs
        dark-pdf = build-dark-pdf;    # All dark PDFs
        html = build-html;
        html-dir = build-html-dir;
        all = build-all;           # Everything: light PDFs, dark PDFs, HTMLs
      } // chapterBuilds;

      apps = rec {
        default = watch;
        build = flake-utils.lib.mkApp {
          drv = build-script;
        };
        watch = flake-utils.lib.mkApp {
          drv = watch-script;
        };
      } // chapterWatchApps;

      devShells.default = typixLib.devShell {
        inherit (commonArgs) fontPaths virtualPaths;
        packages = [
          # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
          # See https://github.com/loqusion/typix/issues/2
          # build-script
          watch-script
          # More packages can be added here, like typstfmt
          # pkgs.typstfmt
        ];
      };
    });
}
