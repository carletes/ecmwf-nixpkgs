{
  description = "eccodes with minimal dependencies";

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
            # Nix flake, so that you may install all packages defined there ...
            overlays = [
              ecmwf.overlays.default
            ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # ... like `eccodes`, for instance. Note we're compiling eccodes
              # with the minimum set of options and dependencies.
              (pkgs.eccodes.override {
                withAEC = false;
                withBUFR = false;
                withBuildTools = false;
                withFortran = false;
                withJPG = false;
                withNetCDF = false;
                withPNG = false;
              })

              # Install pkg-config for the shell hook sanity check.
              pkg-config
            ];

            shellHook = ''
              # Ensure we got what we wanted.
              for v in HAVE_AEC HAVE_FORTRAN HAVE_JPEG HAVE_NETCDF HAVE_HAVE_PNG ; do
                if [ "$(pkg-config --variable=$v eccodes)" = "1" ] ; then
                  echo "*** Unexpected $v=1"
                fi
              done
            '';
          };
        }
      )
    );
}
