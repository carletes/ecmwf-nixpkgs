{ pkgs
, enableAEC ? true
, enableBUFR ? true
, enableBuildTools ? true
, enableExamples ? false
, enableFortran ? true
, enableGRIB ? true
, enableJPG ? true
, enableNetCDF ? true
, enablePNG ? true
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

  postPatch = lib.optionalString enableJPG ''
    substituteInPlace cmake/FindOpenJPEG.cmake --replace openjpeg-2.1 ${openjpeg.incDir}
  '';

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ] ++ lib.optional enableFortran gfortran;

  buildInputs = [ ]
    ++ lib.optional enableAEC libaec
    ++ lib.optional enableJPG openjpeg
    ++ lib.optional enableNetCDF netcdf
    ++ lib.optional enablePNG libpng
  ;

  cmakeFlags = [
    "-DENABLE_AEC=${if enableAEC then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if enableBuildTools then "ON" else "OFF"}"
    "-DENABLE_EXAMPLES=${if enableExamples then "ON" else "OFF"}"
    "-DENABLE_EXTRA_TESTS=OFF"
    "-DENABLE_FORTRAN=${if enableFortran then "ON" else "OFF"}"
    "-DENABLE_JPG=${if enableJPG then "ON" else "OFF"}"
    "-DENABLE_JPG_LIBJASPER=OFF"
    "-DENABLE_NETCDF=${if enableNetCDF then "ON" else "OFF"}"
    "-DENABLE_PNG=${if enablePNG then "ON" else "OFF"}"
    "-DENABLE_PRODUCT_BUFR=${if enableGRIB then "ON" else "OFF"}"
    "-DENABLE_PRODUCT_GRIB=${if enableGRIB then "ON" else "OFF"}"
    "-DENABLE_PYTHON2=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Software for encoding and decoding GRIB, BUFR and GTS abbreviated header messages";
    homepage = "https://confluence.ecmwf.int/display/ECC/";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
