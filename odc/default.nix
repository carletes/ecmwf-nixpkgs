{ pkgs
, withFortran ? false
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "odc";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "odc";
    rev = version;
    sha256 = "sha256-Qrw+AwRG8HgCzywTEkX6c12+vmlGHm9avrs0Wn8qbDg=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ]
  ++ lib.optional withFortran gfortran
  ;

  propagatedBuildInputs = [
    eckit
  ];

  cmakeFlags = [
    "-DENABLE_FORTRAN=${if withFortran then "ON" else "OFF"}"

    # Tests need to download data, which we cannot do at build-time.
    # TODO: Find a way of downloading test data and enable tests.
    "-DENABLE_TESTS=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Package to read/write ODB data";
    homepage = "https://confluence.ecmwf.int/display/ODC/ODC+Home";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
