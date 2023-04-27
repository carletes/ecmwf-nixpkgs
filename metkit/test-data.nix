{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "metkit-test-data";
  version = "2022-12-09-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/latlon.grib";
      sha256 = "sha256-Ouaw/pAP6kYSP7tMiPqeu0S2/VJ8CoepSKzP/OxPuIk=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/latlon.grib.md5";
      sha256 = "sha256-hnsAgepaCVuDzjmroTSvjYLVe/o/us23FGzsRIaqlOI=";
    })
  ];

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    for src in $srcs ; do
      fname="$(stripHash $src)"
      case "$fname" in
      latlon.grib*)
        install -Dm444 $src $out/share/$fname
        ;;
      esac
    done
  '';
}
