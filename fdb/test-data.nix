{ pkgs }:

with pkgs;
stdenv.mkDerivation {
  pname = "fdb-test-data";
  version = "2022-12-09-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/fdb/rd.vod.grib";
      sha256 = "sha256-L57r/kUmApqDaKnQUeKlCoKCmt/4UpCppKY2zdY4NFA=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/fdb/rd.vod.grib.md5";
      sha256 = "sha256-BEcwjk1dm0LasDXlAAPMXJhnF5rBmhwLrHtL/Z1gSKI=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/fdb/api/x138-300.grib";
      sha256 = "sha256-s4jbyfEd+/bGy+SBA5xtrW+IYKK4I7O0EyrL31erVbY=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/fdb/api/x138-400.grib";
      sha256 = "sha256-wWj42HLAoesLuSUYE9uEW/sqYkEuzORuc6J63BWZ/i8=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/fdb/api/y138-400.grib";
      sha256 = "sha256-TCm1JboExXqihHVqlWSjAhloS4QkjyHnvFotA+8jyFo=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/regressions/FDB-240/sh.300.grib";
      sha256 = "sha256-atwALXy2F2BbWQYgPNk/NnBMX7Fr/8kC5YPi+VdI1ak=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/fdb5/tests/regressions/FDB-240/sh.300.grib.md5";
      sha256 = "sha256-+BPQ4UQlr0PmM7d3jCdTH3IVxkqwPO/OzHarM/pyRkw=";
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
      x138*|y138*)
        install -Dm444 $src $out/share/fdb/api/$fname
        ;;
      sh.300.grib*)
        install -Dm444 $src $out/share/regressions/FDB-240/$fname
        ;;
      *)
        install -Dm444 $src $out/share/fdb/$fname
        ;;
      esac
    done
  '';
}
