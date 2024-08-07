{ lib
, stdenv
, fetchFromGitHub
, ecbuild
, eccodes-test-data
, git
, perl
, time
, withAEC ? true
, libaec
, withBUFR ? true
, withBuildTools ? true
, withExamples ? false
, withFortran ? true
, gfortran
, withGRIB ? true
, withJPG ? true
, openjpeg
, withNetCDF ? true
, netcdf
, withPNG ? true
, libpng
, withThreads ? true
}:

assert withAEC -> libaec != null;
assert withJPG -> openjpeg != null;
assert withNetCDF -> netcdf != null;
assert withPNG -> libpng != null;

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
  pname = "eccodes";
  version = "2.36.0";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "eccodes";
    rev = version;
    sha256 = "sha256-Y0nsVCi25wWzRhLc9c0GZ7veJ/0kSvjgcs/R41W3CeM=";
  };

  postPatch = lib.optionalString withJPG ''
    substituteInPlace cmake/FindOpenJPEG.cmake \
      --replace openjpeg-2.1 ${openjpeg.incDir}

    substituteInPlace definitions/check_grib_defs.pl \
      --replace '#!/usr/bin/env perl' '#!${perl}/bin/perl'
  '';

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ]
  ++ lib.optional fortranEnabled gfortran
  ++ lib.optional withThreads time;

  propagatedBuildInputs = [ ]
    ++ lib.optional withAEC libaec
    ++ lib.optional withJPG openjpeg
    ++ lib.optional withNetCDF netcdf
    ++ lib.optional withPNG libpng
  ;

  cmakeFlags = [
    "-DENABLE_AEC=${if withAEC then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_ECCODES_THREADS=ON"
    "-DENABLE_EXAMPLES=${if withExamples then "ON" else "OFF"}"
    "-DENABLE_ECCODES_THREADS=${if withThreads then "ON" else "OFF"}"
    "-DENABLE_EXTRA_TESTS=ON"
    "-DENABLE_FORTRAN=${if fortranEnabled then "ON" else "OFF"}"
    "-DENABLE_JPG=${if withJPG then "ON" else "OFF"}"
    "-DENABLE_JPG_LIBJASPER=OFF"
    "-DENABLE_NETCDF=${if withNetCDF then "ON" else "OFF"}"
    "-DENABLE_PNG=${if withPNG then "ON" else "OFF"}"
    "-DENABLE_PRODUCT_BUFR=${if withBUFR then "ON" else "OFF"}"
    "-DENABLE_PRODUCT_GRIB=${if withGRIB then "ON" else "OFF"}"
    "-DENABLE_PYTHON2=OFF"
  ];

  doCheck = true;

  checkInputs = [
    eccodes-test-data
  ];

  preCheck = ''
    mkdir -p data
    cp -Rp ${eccodes-test-data}/share/* data/

    # Some tests write into these directories.
    chmod 0755 data data/bufr data/gts data/metar data/tigge

    # One test overwrites this file.
    chmod 0644 data/tigge_ecmwf.grib2
  '';

  meta = with lib; {
    description = "Software for encoding and decoding GRIB, BUFR and GTS abbreviated header messages";
    homepage = "https://confluence.ecmwf.int/display/ECC/";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
