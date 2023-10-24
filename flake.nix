{
  description = "LaTeX Document on Regular Languages and Automata";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex =
          pkgs.texlive.combine { inherit (pkgs.texlive) scheme-full latexmk; };
      in rec {
        packages = {
          document = pkgs.stdenvNoCC.mkDerivation rec {
            name = "latex-regular-automata";
            src = self;
            buildInputs = [ pkgs.coreutils tex ];
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath buildInputs}";
              mkdir -p .cache/texmf-var
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                report.tex
              env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                presentation.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp report.pdf presentation.pdf $out/
            '';
          };
        };
        defaultPackage = packages.document;
      });
}

