{
  description = "A development environment for working with ecFlow";

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

            # Install the Nix package overlay defined in the ECMWF software
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
                # Install `ecflow` (this comes from the ECMWF software Nix flake).
                ecflow

                ksh
                python3Full
              ];

              shellHook = ''
                # The following command ensures that the `ecflow` Python module is
                # available.
                python3 -c 'import ecflow; print("Loaded `ecflow` from", ecflow.__file__)'
              '';
            };
        }
      )
    );
}
