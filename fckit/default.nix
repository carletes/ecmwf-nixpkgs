{ lib
, stdenv
, fetchFromGitHub

, bash
, ecbuild
, eckit
, git
, perl
, python3Full
, gfortran
}:

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
    gfortran
    perl
    python3Full
  ];

  propagatedBuildInputs = [
    eckit
  ];

  FC = "${gfortran}/bin/g77";

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
