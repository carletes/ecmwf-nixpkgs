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

  patches = [
    ./patches/001-tiff.patch
  ];

  nativeBuildInputs = [
    ecbuild
    git
    perl
    pkg-config
  ]
  ++ lib.optional withMetview qt5.wrapQtAppsHook
  ++ lib.optionals withDoc [ doxygen python3Packages.breathe sphinx python3Packages.sphinx-rtd-theme ]
  ;

  propagatedBuildInputs = [
    curl.dev
    eccodes
    expat
    ksh
    proj
    zlib
  ]
  ++ lib.optionals withCairo [ fribidi libdatrie libthai libtiff pango ]
  ++ lib.optionals withGeoTIFF [ libgeotiff.dev ]
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
  ]
  ++ lib.optionals withGeoTIFF [
    "-DGEOTIFF_DIR=${libgeotiff.dev}"
    "-DGEOTIFF_PATH=${libgeotiff.dev}"
  ]
  ;

  doCheck = true;

  meta = with lib; {
    description = "Software to visualise meteorological data in GRIB, NetCDF, BUFR and ODB format";
    homepage = "https://confluence.ecmwf.int/display/MAGP/Magics";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
