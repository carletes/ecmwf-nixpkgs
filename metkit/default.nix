{ pkgs
, withBUFR ? true
, withBuildTools ? true
, withExperimental ? false
, withGRIB ? true
, withNetCDF ? true
, withODB ? true
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "metkit";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "metkit";
    rev = version;
    sha256 = "sha256-7q6UxjoYFPExIVccTY2GrZHK1+XwoiNJVYsUONYlzAc=";
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
    for r in 89 ; do
      substituteInPlace tests/regressions/METK-$r/METK-$r.sh.in \
        --replace '#!/usr/bin/env bash' '${bash}/bin/bash'
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
    cp -R ${pkgs.metkit-test-data}/share/* tests/
  '';

  meta = with lib; {
    description = "Toolkit for manipulating and describing meteorological objects";
    homepage = "https://github.com/ecmwf/metkit";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
