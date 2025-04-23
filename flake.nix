{
  description = "A simple hello c program built with Nix";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
  };

  outputs = { self, nixpkgs }:
  let
    # System types to support
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    # Helper function to generate an attrset
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in
  {
    # Define packages for each system
    packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.stdenv.mkDerivation {
          pname = "nix-c-hello";
          version = "0.1.0";

          src = ./.;

          buildInputs = [ pkgs.gcc ];

          buildPhase = ''
            $CC -o hello ./src/hello.c
          '';

          installPhase = ''
            mkdir -p $out/bin/
            cp hello $out/bin/
          '';
        };
      }
    );

    # Development shells for each system
    devShells = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.mkShell {
          buildInputs = [ pkgs.gcc ];
        };
      }
    );
  };
}
