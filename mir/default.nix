{ lib
, stdenv
, fetchFromGitHub
, bash
, ecbuild
, eccodes
, eckit
, git
, perl

, withAtlas ? true
, atlas
, withBuildTools ? true
, withMirDownloadMasks ? false  # XXX Fixme
, withNetCDF ? true
, netcdf
, withPNG ? true
, libpng
}:

assert withAtlas -> atlas != null;
assert withNetCDF -> netcdf != null;
assert withPNG -> libpng != null;

stdenv.mkDerivation rec {
  pname = "ecmwf-mir"; # Package `mir` is already taken.
  version = "1.16.5";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "mir";
    rev = version;
    sha256 = "sha256-mk/DqS4hevEPRIBCNw9SCwoY2veNKwUbmk9pBPA7KOo=";
  };

  postPatch = ''
    for d in tests/assertions tests/tool tests/plans ; do
      substituteInPlace $d/mir-test.sh.in \
        --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    done
  '';

  nativeBuildInputs = [
    bash
    ecbuild
    git
    perl
  ];

  propagatedBuildInputs = [
    atlas
    eccodes
    eckit
  ]
  ++ lib.optional withNetCDF netcdf
  ++ lib.optional withPNG libpng
  ;

  cmakeFlags = [
    "-DENABLE_ATLAS=${if withAtlas then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_MIR_DOWNLOAD_MASKS=${if withMirDownloadMasks then "ON" else "OFF"}"
    "-DENABLE_NETCDF=${if withNetCDF then "ON" else "OFF"}"
    "-DENABLE_OMP=OFF"
    "-DENABLE_PNG=${if withPNG then "ON" else "OFF"}"
  ];

  doCheck = true;

  # checkInputs = [
  #   eccodes-test-data
  # ];

  # preCheck = ''
  #   mkdir -p data
  #   cp -Rp ${eccodes-test-data}/share/* data/
  #
  #   # Some tests write into these directories.
  #   chmod 0755 data data/bufr data/gts data/metar data/tigge
  #
  #   # One test overwrites this file.
  #   chmod 0644 data/tigge_ecmwf.grib2
  # '';

  meta = with lib; {
    description = "ECMWF's interpolation package";
    homepage = "https://www.ecmwf.int/en/newsletter/152/computing/new-ecmwf-interpolation-package-mir";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
