{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, pythonOlder
, substituteAll
, magics
, qt5
, numpy
}:

buildPythonPackage rec {
  pname = "Magics";
  version = "1.5.8";

  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ffQkGAL7VS7gUtoYGQpSZqj6/3/uzHB3nLXhgJYl+5A=";
  };

  buildInputs = [
    qt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = [
    magics

    numpy
  ];

  patches = [
    (substituteAll {
      src = ./001-findlibs.patch;
      libmagplus = "${magics}/lib/libMagPlus${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  # As of 1.5.8 the bundled tests consist of just importing the module.
  doCheck = false;

  pythonImportsCheck = [
    "Magics"
    "Magics.macro"
  ];

  meta = with lib; {
    description = "Python interface to plot meteorological data in GRIB, NetCDF and BUFR";
    license = licenses.asl20;
    homepage = "https://github.com/ecmwf/magics-python";
  };
}
