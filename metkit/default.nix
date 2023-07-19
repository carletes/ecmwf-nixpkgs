{ lib
, stdenv
, fetchFromGitHub
, bash
, ecbuild
, eckit
, git
, metkit-test-data
, perl
, withBUFR ? true
, eccodes
, withBuildTools ? true
, withExperimental ? false
, withGRIB ? true
, withNetCDF ? true
, netcdf
, withODB ? true
, odc
}:

assert withBUFR || withGRIB -> eccodes != null;
assert withNetCDF -> netcdf != null;
assert withODB -> odc != null;

stdenv.mkDerivation rec {
  pname = "metkit";
  version = "1.11.14";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "metkit";
    rev = version;
    sha256 = "sha256-zPnjmws0gZ1B8rgvn5FDmz8/Lel4yCqgx9rr+C3ysEE=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ];

  propagatedBuildInputs = [
    eckit
  ]
  ++ lib.optional (withBUFR || withGRIB) eccodes
  ++ lib.optional withNetCDF netcdf
  ++ lib.optional withODB odc
  ;

  postPatch = ''
    for t in compare legacy obs simple ; do
      substituteInPlace tests/marsgen/metkit_marsgen_$t.sh.in \
        --replace '#!/bin/bash' '#!${bash}/bin/bash'
    done

    for r in 89 103 ; do
      substituteInPlace tests/regressions/METK-$r/METK-$r.sh.in \
        --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    done
  '';

  cmakeFlags = [
    "-DENABLE_BUFR=${if withBUFR then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_EXPERIMENTAL=${if withExperimental then "ON" else "OFF"}"
    "-DENABLE_GRIB=${if withGRIB then "ON" else "OFF"}"
    "-DENABLE_NETCDF=${if withNetCDF then "ON" else "OFF"}"
    "-DENABLE_ODB=${if withODB then "ON" else "OFF"}"
  ];

  doCheck = true;

  checkInputs = [
    metkit-test-data
  ];

  preCheck = ''
    mkdir -p tests/
    cp -R ${metkit-test-data}/share/* tests/
  '';

  meta = with lib; {
    description = "Toolkit for manipulating and describing meteorological objects";
    homepage = "https://github.com/ecmwf/metkit";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
