{
  description = "Experimental overlay for ECMWF software";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default =
        final: prev: {
          atlas = prev.callPackage ./atlas {
            inherit (final)
              lib stdenv fetchFromGitHub
              bash
              boost
              cgal_5
              ecbuild
              eckit
              eigen
              fckit
              fftw
              gfortran
              git
              gmp
              mpfr
              perl
              qhull;
          };
          ecbuild = prev.callPackage ./ecbuild {
            inherit (prev)
              lib stdenv fetchFromGitHub
              cmake;
          };
          eccodes = prev.callPackage ./eccodes {
            inherit (final)
              lib stdenv fetchFromGitHub
              ecbuild eccodes-test-data gfortran git libaec libpng netcdf openjpeg perl time;
          };
          eccodes-test-data = prev.callPackage ./eccodes/test-data.nix {
            inherit (final)
              stdenv fetchurl;
          };
          ecflow = prev.callPackage ./ecflow {
            inherit (final)
              lib stdenv fetchFromGitHub
              boost
              ecbuild
              perl
              pkg-config
              python3Full
              qt6
              ;
          };
          eckit = prev.callPackage ./eckit {
            inherit (final)
              lib stdenv fetchFromGitHub
              armadillo
              bash
              bison
              bzip2
              curl
              ecbuild
              eckit-test-data
              eigen
              flex
              git
              jemalloc
              libaec
              lz4
              ncurses
              openssl
              perl
              pkg-config
              python3
              snappy
              xxHash;
          };
          eckit-test-data = prev.callPackage ./eckit/test-data.nix {
            inherit (final)
              stdenv fetchurl;
          };
          fckit = prev.callPackage ./fckit {
            inherit (final)
              lib stdenv fetchFromGitHub
              bash
              ecbuild
              eckit
              gfortran
              git
              perl
              python3Full
              ;
          };
          ecmwf-mir = prev.callPackage ./mir {
            inherit (final)
              lib stdenv fetchFromGitHub
              atlas
              bash
              ecbuild
              eccodes
              eckit
              git
              libpng
              netcdf
              perl;
          };
          fdb = prev.callPackage ./fdb {
            inherit (final)
              lib stdenv fetchFromGitHub
              bash
              ecbuild
              eccodes
              eckit
              fdb-test-data
              git
              metkit
              perl;
          };
          fdb-test-data = prev.callPackage ./fdb/test-data.nix {
            inherit (final)
              stdenv fetchurl;
          };
          magics = prev.callPackage ./magics {
            inherit (final)
              lib stdenv fetchFromGitHub
              doxygen
              curl
              ecbuild
              eccodes
              expat
              fribidi
              git
              ksh
              libdatrie
              libgeotiff
              libthai
              libtiff
              netcdf
              odc
              pango
              perl
              pkg-config
              proj
              python3Packages
              qt5
              sphinx
              zlib;
          };
          metkit = prev.callPackage ./metkit {
            inherit (final)
              lib stdenv fetchFromGitHub
              bash
              ecbuild
              eccodes
              eckit
              git
              metkit-test-data
              netcdf
              odc
              perl
              ;
          };
          metkit-test-data = prev.callPackage ./metkit/test-data.nix {
            inherit (final)
              stdenv fetchurl;
          };
          odc = prev.callPackage ./odc {
            inherit (final)
              lib stdenv fetchFromGitHub
              bash
              ecbuild
              eckit
              gfortran
              git
              odc-test-data
              perl;
          };
          odc-test-data = prev.callPackage ./odc/test-data.nix {
            inherit (final)
              stdenv fetchurl;
          };

          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (
              python-final: python-prev: {
                Magics = prev.callPackage ./magics-python
                  {
                    inherit (final)
                      lib stdenv
                      substituteAll
                      magics
                      qt5
                      ;
                    # inherit (final.python3.pkgs)
                    inherit (python-final)
                      buildPythonPackage
                      fetchPypi
                      pythonOlder
                      numpy
                      ;
                  };
                eccodes = prev.callPackage ./eccodes-python {
                  inherit (final)
                    lib stdenv
                    substituteAll
                    eccodes
                    ;
                  # inherit (final.python3.pkgs)
                  inherit (python-final)
                    buildPythonPackage
                    fetchPypi
                    pythonOlder
                    attrs
                    cffi
                    numpy
                    pytestCheckHook
                    ;
                };
              }
            )
          ];
        }
      ;
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in
        {
          packages = {
            inherit (pkgs)
              atlas
              ecbuild
              eccodes
              ecflow
              eckit
              fckit
              ecmwf-mir
              fdb
              magics
              metkit
              odc;
          };
        }));
}
