{
  description = "Use an old version of eccodes";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # Declare the ECMWF software Nix flake as an input.
  inputs.ecmwf.url = "github:carletes/ecmwf-nixpkgs";

  # Ensure we use the same versions of our inputs as those of the ECMWF
  # software Nix flake.
  inputs.ecmwf.inputs.nixpkgs.follows = "nixpkgs";
  inputs.ecmwf.inputs.flake-utils.follows = "flake-utils";

  outputs = { self, nixpkgs, flake-utils, ecmwf }:
    (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;

            # Installe the Nix package overlay defined in the ECMWF software
            # Nix flake, so that you may install all packages defined there ...
            overlays = [
              ecmwf.overlays.default
            ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # ... like `eccodes`, for instance. Note we're compiling an old
              # version from 2021.
              (eccodes.overrideAttrs (prev: rec {
                version = "2.20.0";
                src = (prev.src.override {
                  rev = version;
                  sha256 = "sha256-dLrcRA35wTXz44S9TZwrbWeK6BWPY+XiKBWgsvbweVI=";
                });
              }))
            ];

            shellHook = ''
              echo "eccodes version:"
              grib_ls -V
            '';
          };
        }
      )
    );
}
