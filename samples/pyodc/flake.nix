{
  description = "A development environment for working with ODB-2 files in Python";

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
            let
              libraryPath = with pkgs; lib.makeLibraryPath [
                # The ODC shared library is loaded by the `cffi` Python package,
                # which does not know how to load it under Nix.
                odc
              ];
            in
            pkgs.mkShell {
              buildInputs = with pkgs; [
                # Install `odc` (this comes from the ECMWF software Nix flake).
                odc

                # We'll also install Python.
                python3Full
              ];

              shellHook = ''
                # If you plan on creating a Python virtualenv to install Python
                # packages from PyPI, it is helpful to create it here, and
                # activate it here too.
                python3 -m venv .venv
                source .venv/bin/activate

                # At this point you should be able to install `pyodc` yourself,
                # and any other package you might need --- which is what we do
                # here for ilustration purposes: What follows is _not_ needed in
                # the shell environment!
                python3 -m pip install pyodc

                # We need to set the `LD_LIBRARY_PATH` (Linux) or the
                # `DYLD_LIBRARY_PATH` (Mac) env variable, so that our Python
                # dependencies are able to load the shared objects they need.
                export LD_LIBRARY_PATH="${libraryPath}"
                export DYLD_LIBRARY_PATH="${libraryPath}"

                # Ensure we may import the Python module.
                python3 -c 'import codc'
              '';
            };
        }
      )
    );
}
