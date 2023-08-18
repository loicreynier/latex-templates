{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    phiso.url = "github:loicreynier/phiso";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    phiso,
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      pkgName = "latex-documents"; # Set package build name
      pkgVersion = "0.1"; # Set package version
      fontPkgs = with pkgs; [
        # Add custom fonts package here
      ];
      fontPath = pkgs.buildEnv {
        name = "fonts";
        paths = fontPkgs;
      };
      buildPackages = with pkgs;
        [
          bash
          coreutils
          gnumake
          openjdk19 # Required for bibg2gls
          perl536Packages.PerlTidy
          phiso.packages.${pkgs.system}.texlive-phiso
        ]
        ++ fontPkgs;
      lastModified = builtins.toString self.lastModified;
    in rec {
      packages.default = pkgs.stdenvNoCC.mkDerivation rec {
        pname = pkgName;
        version = pkgVersion;
        src = self;
        buildInputs = buildPackages;
        phases = ["unpackPhase" "buildPhase" "installPhase"];
        buildPhase = ''
          export PATH="${pkgs.lib.makeBinPath buildInputs}"
          export SOURCE_DATE_EPOCH="${lastModified}"
          echo "$SOURCE_DATE_EPOCH"
          TMPDIR=$(mktemp -d)
          mkdir -p "$TMPDIR/texmf-var"
          mkdir "build"
          ln -sf ../{bib,data,tex} -t "build"
          env TEXMFHOME="$TMPDIR" \
              TEXMFVAR="$TMPDIR/texmf-var" \
              OSFONTDIR="${fontPath}/share/fonts" \
            latexmk
          rm -rf "$TMPDIR"
        '';
        installPhase = ''
          mkdir -p $out
          cp build/*.pdf $out/
          rm -rf build
        '';
      };
      devShells.default = pkgs.mkShell {
        buildInputs = buildPackages;
        shellHook = ''
          mkdir -p ".cache/texmf-var"
          export TEXMFHOME=".cache"
          export TEXMFVAR=".cache/texmf-var"
          export SOURCE_DATE_EPOCH="${lastModified}"
          export OSFONTDIR="${fontPath}/share/fonts"
        '';
      };
    });
}
