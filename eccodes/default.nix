{ pkgs
, withAEC ? true
, withBUFR ? true
, withBuildTools ? true
, withExamples ? false
, withFortran ? true
, withGRIB ? true
, withJPG ? true
, withNetCDF ? true
, withPNG ? true
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "eccodes";
  version = "2.27.0";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "eccodes";
    rev = "${version}";
    sha256 = "sha256-gWBKMfIwJq4BP0SCDelRNtl3cZ8Ic+xaPqeSZyKlpME=";
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
  ] ++ lib.optional withFortran gfortran;

  propagatedBuildInputs = [ ]
    ++ lib.optional withAEC libaec
    ++ lib.optional withJPG openjpeg
    ++ lib.optional withNetCDF netcdf
    ++ lib.optional withPNG libpng
  ;

  cmakeFlags = [
    "-DENABLE_AEC=${if withAEC then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_EXAMPLES=${if withExamples then "ON" else "OFF"}"
    "-DENABLE_EXTRA_TESTS=ON"
    "-DENABLE_FORTRAN=${if withFortran then "ON" else "OFF"}"
    "-DENABLE_JPG=${if withJPG then "ON" else "OFF"}"
    "-DENABLE_JPG_LIBJASPER=OFF"
    "-DENABLE_NETCDF=${if withNetCDF then "ON" else "OFF"}"
    "-DENABLE_PNG=${if withPNG then "ON" else "OFF"}"
    "-DENABLE_PRODUCT_BUFR=${if withGRIB then "ON" else "OFF"}"
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
