{
  description = "A development environment for working with Magics in Python";

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
              # ... like `magics`, for instance.
              magics

              # See below.
              stdenv.cc.cc.lib

              # We'll also install Python.
              python3Full
            ];

            # We need to set the `LD_LIBRARY_PATH` env variable, so that our
            # Python dependencies are able to load the shared objects they need.
            LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
              # Magics shared library is loaded by the `findlibs` Python package,
              # which does not know how to load it under Nix.
              magics

              # Numpy depends on `libstc++`.
              stdenv.cc.cc.lib
            ];

            shellHook = ''
              # If you plan on creating a Python virtualenv to install Python
              # packages from PyPI, it is helpful to create it here, and
              # activate it here too.
              python3 -m venv .venv
              source .venv/bin/activate

              # At this point you should be able to install `Magics` yourself,
              # and any other package you might need --- which is what we do
              # here for ilustration purposes: What follows is _not_ needed in
              # the shell environment!
              python3 -m pip install Magics requests

              # Ensure the package has been installed correctly.
              python3 -m Magics selfcheck
            '';
          };
        }
      )
    );
}
