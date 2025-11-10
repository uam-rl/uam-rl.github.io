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
            name = "${baseName}-html";
            value = mkChapterHtml chapter;
          }
        ]
      ) chapters));

      # Convenience aliases for the first chapter (main)
      build-pdf = chapterBuilds.main-pdf;
      build-html = chapterBuilds.main-html;

      # Compile a Typst project, *without* copying the result
      # to the current directory
      build-drv = build-pdf;

      # Compile a Typst project, and then copy the result
      # to the current directory
      build-script = typixLib.buildTypstProjectLocal (commonArgs
        // {
          inherit src unstable_typstPackages;
        });

      # Watch a project and recompile on changes
      watch-script = typixLib.watchTypstProject commonArgs;

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

      # Build all PDFs and HTMLs for deployment
      build-all = pkgs.runCommand "deploy-output" {} (''
        mkdir -p $out
        # Copy all PDFs and HTMLs from chapters
      '' + lib.concatMapStringsSep "\n" (chapter:
        let
          baseName = lib.removeSuffix ".typ" chapter.file;
          pdfBuild = chapterBuilds."${baseName}-pdf";
          htmlBuild = chapterBuilds."${baseName}-html";
        in ''
          cp ${pdfBuild} $out/${baseName}.pdf
          cp ${htmlBuild} $out/${baseName}.html
        ''
      ) chapters + ''
        # Copy main.html to index.html for GitHub Pages
        cp $out/main.html $out/index.html
      '');
    in {
      checks = {
        inherit build-drv build-script watch-script;
      };

      packages = {
        default = build-drv;
        pdf = build-pdf;
        html = build-html;
        html-dir = build-html-dir;
        all = build-all;
      } // chapterBuilds;

      apps = rec {
        default = watch;
        build = flake-utils.lib.mkApp {
          drv = build-script;
        };
        watch = flake-utils.lib.mkApp {
          drv = watch-script;
        };
      };

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
