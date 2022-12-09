{ pkgs }:

with pkgs;
stdenv.mkDerivation {
  pname = "eccodes-test-data";
  version = "2022-12-09-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/eccodes_test_data.tar.gz";
      sha256 = "sha256-cac35Y+4J5327NsbqscqhkPKeE4ts9EUQY5VTIbw2Zc=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/ccsds_szip.grib2";
      sha256 = "sha256-rQPHm8luMSq60qOWcw0Iq5FYpO/jKkVI/mwHsjVzobU=";
    })
  ];

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    for src in $srcs ; do
      fname="$(stripHash $src)"
      case "$fname" in
      *.tar.gz)
        tar xzf $src
        ;;
      *)
        mkdir -p data
        cp $src data/$fname
        ;;
      esac
    done
  '';

  installPhase = ''
    mkdir -p $out/share/
    cp -Rp data/* $out/share/
  '';
}
