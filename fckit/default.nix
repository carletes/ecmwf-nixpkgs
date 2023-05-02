{ lib
, stdenv
, fetchFromGitHub

, bash
, ecbuild
, eckit
, git
, perl
, python3Full
, withFortran ? true
, gfortran
}:

let
  # I cannot get the Fortran bindings to build on Darwin. The build error looks like:
  #
  # -- Performing Test eccodes_Fortran_FLAG_TEST_1 - Failed
  # CMake Error at /nix/store/9wd2cbjd7qi81arqiq2246f5890ylvcb-ecbuild-3.7.0/share/ecbuild/cmake/ecbuild_log.cmake:190 (message):
  #   CRITICAL - Fortran compiler
  #   /nix/store/p4npag17lbpskv5qli4ph0p7409nzk1x-gfortran-wrapper-11.3.0/bin/gfortran
  #   does not recognise Fortran flag '-fallow-argument-mismatch'
  fortranEnabled = withFortran && (! stdenv.isDarwin);
in
stdenv.mkDerivation
rec {
  pname = "fckit";
  version = "0.10.1";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "fckit";
    rev = version;
    sha256 = "sha256-w8zIHwzR3PN3vK3yRMj8OzfRXnV5Sab5K9xnB5lsDes=";
  };

  postPatch = ''
    for d in src/tests/test_downstream_fctest src/tests/test_downstream_fypp ; do
      substituteInPlace $d/test-downstream.sh.in \
        --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    done

    substituteInPlace tools/fckit-eval.sh \
      --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'

    substituteInPlace tools/fckit-fypp.py \
      --replace '#!/usr/bin/env python' '#!${python3Full}/bin/python3'
  '';

  nativeBuildInputs = [
    bash
    ecbuild
    git
    perl
    python3Full
  ] ++ lib.optional fortranEnabled gfortran;

  propagatedBuildInputs = [
    eckit
  ];

  cmakeFlags = [
    "-DENABLE_ECKIT=ON"
    "-DENABLE_FINAL=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Fortran toolkit for interoperating Fortran with C/C++ `";
    homepage = "https://confluence.ecmwf.int/display/fckit";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
