{ lib
, stdenv
, fetchFromGitHub
, boost
, ecbuild
, openssl
, perl
, pkg-config
, python3Full
, qt6
}:

let
  _python = python3Full;
  _boost = boost.override {
    enablePython = true;
    python = _python;
  };
in
stdenv.mkDerivation rec {
  pname = "ecflow";
  version = "5.13.2";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "ecflow";
    rev = version;
    sha256 = "sha256-w4BevIUw0ICAn7d7IHXYHkKS8pNkmDnvFG8cg9HcGew=";
  };

  nativeBuildInputs = [
    ecbuild
    perl
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    _boost
    _boost.dev
    _python
    openssl
    qt6.qt5compat
    qt6.qtbase
    qt6.qtcharts
    qt6.qtsvg
  ];

  cmakeFlags = [
    "-DENABLE_DOCS=OFF"
    "-DENABLE_HTTP=ON"
    "-DENABLE_PYTHON=ON"
    "-DENABLE_PYTHON_PTR_REGISTER=OFF"
    "-DENABLE_PYTHON_UNDEF_LOOKUP=OFF"
    "-DENABLE_SERVER=ON"
    "-DENABLE_SSL=ON"
    "-DENABLE_STATIC_BOOST_LIBS=OFF"
    "-DENABLE_UDP=ON"
    "-DENABLE_UI_BACKTRACE=OFF"
    "-DENABLE_UI=ON"
    "-DENABLE_UI_USAGE_LOG=OFF"

    # XXX Fix
    "-DENABLE_ALL_TESTS=OFF"
    # "--trace-expand"
  ];

  # XXX Fix
  doCheck = false;

  meta = with lib; {
    description = "Workflow manager";
    homepage = "https://ecflow.readthedocs.io/en/latest/";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
