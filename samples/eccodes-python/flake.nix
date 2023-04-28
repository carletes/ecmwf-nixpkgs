{
  description = "A development environment for working with eccodes in Python";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # Declare the ECMWF software Nix flake as an input.
  inputs.ecmwf.url = "github:carletes/ecmwf-nixpkgs";

  # Ensure the ECMWF software Nix flake uses the same versions of the inputs
  # that it shares with us.
  inputs.ecmwf.inputs.nixpkgs.follows = "nixpkgs";
  inputs.ecmwf.inputs.flake-utils.follows = "flake-utils";

  outputs = { self, nixpkgs, flake-utils, ecmwf }:
    (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;

            # Installe the Nix package overlay defined in the ECMWF software
            # Nix flake, so that you may install all packages defined there.
            overlays = [
              ecmwf.overlays.default
            ];
          };
        in
        {
          devShells.default =
            pkgs.mkShell {
              buildInputs = with pkgs; [
                # Install the eccodes Python bindings
                (python3.withPackages
                  (ps: with ps; [
                    eccodes
                  ]))
              ];

              shellHook = ''
                # Ensure the bindings have been installed correctly.
                python3 -m eccodes selfcheck
              '';
            };

        }
      )
    );
}
