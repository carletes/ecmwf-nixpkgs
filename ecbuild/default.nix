{ pkgs }:

with pkgs;
stdenv.mkDerivation rec {
  pname = "ecbuild";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "ecbuild";
    rev = "${version}";
    sha256 = "sha256-JFQP7ObvOom3Ta6gonOJfEAHNSTZUi5kP5H+uTluktU=";
  };

  buildInputs = [
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
