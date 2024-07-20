{ lib
, stdenv
, fetchFromGitHub
, curl
, ecbuild
, eccodes
, expat
, git
, ksh
, perl
, pkg-config
, proj
, zlib
, withCairo ? true
, fribidi
, libdatrie
, libthai
, libtiff
, pango
, withDoc ? false
, doxygen ? null
, sphinx ? null
, python3Packages ? null
, withEFAS ? false
, withGeoTIFF ? true
, libgeotiff
, withMetview ? true
, qt5
, withMetviewNoQt ? false
, withNetCDF ? true
, netcdf
, withODB ? false
, odc ? null
}:

assert withCairo -> fribidi != null && libdatrie != null && libthai != null && libtiff != null && pango != null;
assert withDoc -> doxygen != null && python3Packages != null && sphinx != null;
assert withGeoTIFF -> libgeotiff != null;
assert ! (withMetview && withMetviewNoQt);
assert withMetview -> qt5 != null;
assert withNetCDF -> netcdf != null;
assert withODB -> odc != null;

stdenv.mkDerivation rec {
  pname = "magics";
  version = "4.15.4";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "magics";
    rev = version;
    sha256 = "sha256-Go0rySTCm9xjlkYY4Vz2MxbnBBPDne8y/Wpnnxmw3i4=";
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
