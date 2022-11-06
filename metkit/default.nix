{ pkgs
, withBufr ? true
, withBuildTools ? true
, withExperimental ? false
, withGrib ? true
, withNetcdf ? true
, withODB ? true
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "metkit";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "metkit";
    rev = version;
    sha256 = "sha256-7q6UxjoYFPExIVccTY2GrZHK1+XwoiNJVYsUONYlzAc=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ];

  propagatedBuildInputs = [
    eckit
  ]
  ++ lib.optional (withBufr || withGrib) eccodes
  ++ lib.optional withNetcdf netcdf
  ++ lib.optional withODB odc
  ;

  cmakeFlags = [
    "-DENABLE_BUFR=${if withBufr then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_EXPERIMENTAL=${if withExperimental then "ON" else "OFF"}"
    "-DENABLE_GRIB=${if withGrib then "ON" else "OFF"}"
    "-DENABLE_NETCDF=${if withNetcdf then "ON" else "OFF"}"
    "-DENABLE_ODB=${if withODB then "ON" else "OFF"}"
  ];

  # Some tests require access to network for downloading data.
  # TODO: Fetch test data before build.
  doCheck = false;

  meta = with lib; {
    description = "Toolkit for manipulating and describing meteorological objects";
    homepage = "https://github.com/ecmwf/metkit";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
