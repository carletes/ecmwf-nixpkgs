{
  description = "A development environment for working with eccodes in Python";

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
            # Nix flake, so that you may install all packages defined there.
            overlays = [
              ecmwf.overlays.default
            ];
          };
        in
        {
          devShells.default =
            let
              libraryPath = with pkgs; lib.makeLibraryPath [
                # Numpy needs to load the zlib shared library.
                zlib

                # Package `eccodes-python` needs to load the eccodes share library.
                eccodes
              ];
            in
            pkgs.mkShell {
              buildInputs = with pkgs; [
                # Install `eccodes` (this comes from the ECMWF software Nix flake).
                eccodes

                # We'll also install Python ...
                python3Full

                # ... and `zlib`, because Numpy (installed via `python3 -m pip eccodes-python`)
                # needs this
                zlib
              ];

              shellHook = ''
                # If you plan on creating a Python virtualenv to install Python
                # packages from PyPI, it is helpful to create it here, and
                # activate it here too.
                python3 -m venv .venv
                source .venv/bin/activate

                # At this point you should be able to install `eccodes-python`
                # yourself --- which is what we do here for ilustration purposes:
                # What follows is _not_ needed in the shell environment!
                python3 -m pip install eccodes-python

                # We need to set the `LD_LIBRARY_PATH` (Linux) or the
                # `DYLD_LIBRARY_PATH` (Mac) env variable, so that our Python
                # dependencies are able to load the shared objects they need.
                export LD_LIBRARY_PATH="${libraryPath}"
                export DYLD_LIBRARY_PATH="${libraryPath}"

                # Ensure the package has been installed correctly.
                python3 -m eccodes selfcheck
              '';
            };
        }
      )
    );
}
