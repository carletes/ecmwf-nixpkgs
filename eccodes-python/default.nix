{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, pythonOlder
, substituteAll
, eccodes
, attrs
, cffi
, numpy
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "eccodes";
  version = "1.6.0";

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WTkwQLz4nYBIEnQQkmWCqv/GiOF0vr1GRxkwe7xdnhU=";
  };

  propagatedBuildInputs = [
    eccodes

    attrs
    cffi
    numpy
  ];

  patches = [
    (substituteAll {
      src = ./001-findlibs.patch;
      eccodes_h = "${eccodes}/include/eccodes.h";
      grib_api_h = "${eccodes}/include/grib_api.h";
      libeccodes = "${eccodes}/lib/libeccodes${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  doCheck = true;

  pythonImportsCheck = [
    "eccodes"
  ];

  checkInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Python interface to the ecCodes GRIB/BUFR decoder/encoder";
    license = licenses.asl20;
    homepage = "https://github.com/ecmwf/eccodes-python";
  };
}
