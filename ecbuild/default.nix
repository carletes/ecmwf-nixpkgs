{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "ecbuild";
  version = "3.8.5";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "ecbuild";
    rev = version;
    sha256 = "sha256-P2DmlEfejhDrj3ZAJWCVnJF/VcNE9J2hg3sr34gouzs=";
  };

  patches = [
    ./patches/001-install-dirs.patch
  ];

  propagatedBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = ''
      A CMake-based build system, consisting of a collection of CMake macros
      and functions that ease the managing of software build systems.
    '';
    homepage = "https://github.com/ecmwf/ecbuild";
    license = licenses.asl20;
    mainProgram = "ecbuild";
    platforms = platforms.all;
  };
}
