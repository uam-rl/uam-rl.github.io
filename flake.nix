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
      fixSvgScript = ./fix-svg-fills.py;
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
        ];
      };

      unstable_typstPackages = [
        {
          name = "cetz";
          version = "0.3.4";
          hash = "sha256-5w3UYRUSdi4hCvAjrp9HslzrUw7BhgDdeCiDRHGvqd4=";
        }
        # Required by cetz
        {
          name = "oxifmt";
          version = "0.2.1";
          hash = "sha256-8PNPa9TGFybMZ1uuJwb5ET0WGIInmIgg8h24BmdfxlU=";
        }
      ];

      # Build PDF in sandbox (with html features for html.aside etc)
      build-pdf = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          name = "main.pdf";
          typstCompileCommand = "typst compile --features html";
        });

      # Build HTML in sandbox with SVG fix
      build-html = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          name = "main.html";
          nativeBuildInputs = [ pkgs.python3 ];
          buildPhaseTypstCommand = ''
            typst compile --features html ${commonArgs.typstSource} temp.html
            python3 ${fixSvgScript} temp.html
            mv temp.html "$out"
          '';
        });

      # Build introduccion PDF in sandbox (with html features for html.aside etc)
      build-introduccion-pdf = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "typst-src/introduccion.typ";
          name = "introduccion.pdf";
          typstCompileCommand = "typst compile --features html";
        });

      # Build introduccion HTML in sandbox with SVG fix
      build-introduccion-html = typixLib.buildTypstProject (commonArgs
        // {
          inherit src unstable_typstPackages;
          typstSource = "typst-src/introduccion.typ";
          name = "introduccion.html";
          nativeBuildInputs = [ pkgs.python3 ];
          buildPhaseTypstCommand = ''
            typst compile --features html typst-src/introduccion.typ temp.html
            python3 ${fixSvgScript} temp.html
            mv temp.html "$out"
          '';
        });

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

      # Build both HTML files into a single directory
      build-html-dir = pkgs.runCommand "html-output" {} ''
        mkdir -p $out
        # Copy the built HTML files instead of symlinking so the result
        # directory can be moved or served without depending on /nix/store.
        cp ${build-html} $out/main.html
        cp ${build-introduccion-html} $out/introduccion.html
      '';
    in {
      checks = {
        inherit build-drv build-script watch-script;
      };

      packages = {
        default = build-drv;
        pdf = build-pdf;
        html = build-html;
        introduccion-pdf = build-introduccion-pdf;
        introduccion-html = build-introduccion-html;
        html-dir = build-html-dir;
      };

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
