{
  description = "Node.js + Yarn dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs
            pkgs.yarn
          ];

          shellHook = ''
            echo "Node.js version: $(node -v)"
            echo "Yarn version: $(yarn -v)"
          '';
        };
      }
    );
}
