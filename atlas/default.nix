{ lib
, stdenv
, fetchFromGitHub
, bash
, boost
, cgal_5
, ecbuild
, eckit
, eigen
, fckit
, fftw
, git
, gmp
, mpfr
, pkg-config
, perl
, proj
, qhull
, withFortran ? true
, gfortran
}:

assert withFortran -> fckit != null;
assert withFortran -> gfortran != null;

stdenv.mkDerivation
rec {
  pname = "atlas";
  version = "0.38.1";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "atlas";
    rev = version;
    sha256 = "sha256-U4eSPNYtJEvzgrbRxFe12GysOEHldVS+SrVQq+glvzY=";
  };

  postPatch = ''
    for f in doc/example-projects/build_hello_world_fortran.sh doc/example-projects/build_hello_world.sh ; do
      substituteInPlace $f --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    done

    substituteInPlace tools/atlas-run \
      --replace '#!/bin/bash' '#!${bash}/bin/bash'
  '';

  nativeBuildInputs = [
    bash
    ecbuild
    git
    pkg-config
    perl
  ] ++ lib.optional withFortran gfortran;

  buildInputs = [
    boost
    boost.dev
    cgal_5
  ];

  propagatedBuildInputs = [
    eckit
    eigen
    fckit
    fftw
    gmp
    mpfr
    proj
    qhull
  ];

  cmakeFlags = [
    "-DENABLE_ACCEPTANCE_TESTS=OFF"
    "-DENABLE_EIGEN=ON"
    "-DENABLE_EXPORT_TESTS=ON"
    "-DENABLE_FFTW=ON"
    "-DENABLE_FORTRAN=${if withFortran then "ON" else "OFF"}"
    "-DENABLE_PKGCONFIG=ON"
    "-DENABLE_PROJ=ON"
    "-DENABLE_TESSELATION=ON"
    "-DENABLE_TESTS=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Parallel data-structures supporting unstructured grids and function spaces";
    homepage = "https://confluence.ecmwf.int/display/ATLAS";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
