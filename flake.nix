{
  description = "LaTeX templates for reproducible documents";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    pre-commit-hooks,
  }:
    with flake-utils.lib;
      eachSystem defaultSystems (system: let
        pkgs = import nixpkgs {inherit system;};
      in rec {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              alejandra.enable = true;
              commitizen.enable = true;
              deadnix.enable = true;
              editorconfig-checker.enable = true;
              markdownlint.enable = true;
              prettier.enable = true;
              statix.enable = true;
              typos.enable = true;
            };
          };
        };
        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      })
      // {
        templates = {
          full-phiso = {
            path = ./full-phiso;
            description = ''
              Featureful LaTeX document build with φso package
            '';
          };
        };
      };
}
