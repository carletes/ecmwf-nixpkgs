{ pkgs
, withCairo ? true
, withDoc ? false
, withEFAS ? false
, withGeoTIFF ? true
, withMetview ? true
, withMetviewNoQt ? false
, withNetCDF ? true
, withODB ? false
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
    qt5.wrapQtAppsHook
  ]
  ++ lib.optionals withDoc [ doxygen python3Packages.breathe sphinx python3Packages.sphinx-rtd-theme ]
  ;

  propagatedBuildInputs = [
    eccodes
    expat
    ksh
    proj
    zlib
  ]
  ++ lib.optional withCairo pango
  ++ lib.optionals withGeoTIFF [ libgeotiff.dev libtiff ]
  ++ lib.optional withMetview qt5.qtbase
  ++ lib.optional withNetCDF netcdf
  ++ lib.optional withODB odc
  ;

  cmakeFlags = [
    "-DENABLE_CAIRO=${if withCairo then "ON" else "OFF"}"
    "-DENABLE_DOCUMENTATION=${if withDoc then "ON" else "OFF"}"
    "-DENABLE_EFAS=${if withEFAS then "ON" else "OFF"}"
    "-DENABLE_GEOTIFF=${if withGeoTIFF then "ON" else "OFF"}"
    "-DENABLE_METVIEW=${if withMetview then "ON" else "OFF"}"
    "-DENABLE_METVIEW_NO_QT=${if withMetviewNoQt then "ON" else "OFF"}"
    "-DENABLE_NETCDF=${if withNetCDF then "ON" else "OFF"}"
    "-DENABLE_ODB=${if withODB then "ON" else "OFF"}"
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
