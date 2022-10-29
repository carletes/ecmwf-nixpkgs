{ pkgs
, enableCairo ? true
, enableDoc ? false
, enableEFAS ? false
, enableGeoTIFF ? true
, enableMetview ? true
, enableMetviewNoQt ? false
, enableNetCDF ? true
, enableODB ? false
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "magics";
  version = "4.12.1";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "magics";
    rev = version;
    sha256 = "sha256-ngozEYVal5k5sD/Ovg+FQ6DSkRxn6r3O5MEmvbFNZd4=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
    pkg-config
  ]
  ++ lib.optionals enableDoc [ doxygen python3Packages.breathe sphinx python3Packages.sphinx-rtd-theme ]
  ;

  buildInputs = [
    eccodes
    expat
    proj
    zlib
  ]
  ++ lib.optional enableCairo pango
  ++ lib.optionals enableGeoTIFF [ libgeotiff.dev libtiff ]
  ++ lib.optional enableMetview qt5.full
  ++ lib.optional enableNetCDF netcdf
    # TODO: ODB
  ;

  propagatedBuildInputs = [
    ksh
  ];

  cmakeFlags = [
    "-DENABLE_CAIRO=${if enableCairo then "ON" else "OFF"}"
    "-DENABLE_DOCUMENTATION=${if enableDoc then "ON" else "OFF"}"
    "-DENABLE_EFAS=${if enableEFAS then "ON" else "OFF"}"
    "-DENABLE_GEOTIFF=${if enableGeoTIFF then "ON" else "OFF"}"
    "-DENABLE_METVIEW=${if enableMetview then "ON" else "OFF"}"
    "-DENABLE_METVIEW_NO_QT=${if enableMetviewNoQt then "ON" else "OFF"}"
    "-DENABLE_NETCDF=${if enableNetCDF then "ON" else "OFF"}"
    "-DENABLE_ODB=${if enableODB then "ON" else "OFF"}"
    "-DGEOTIFF_DIR=${libgeotiff.dev}"
    "-DGEOTIFF_PATH=${libgeotiff.dev}"
  ];

  meta = with lib; {
    description = "Software to visualise meteorological data in GRIB, NetCDF, BUFR and ODB format";
    homepage = "https://confluence.ecmwf.int/display/MAGP/Magics";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
