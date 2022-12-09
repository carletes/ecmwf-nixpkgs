{ pkgs }:

with pkgs;
stdenv.mkDerivation {
  pname = "odc-test-data";
  version = "2022-12-09-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/odb_387_mdset.odb";
      sha256 = "sha256-h1SjqpZRuL3XYZHNe5Gky0t5Tkq6HCHd9AyVliOvlg8=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/odb_463.odb";
      sha256 = "sha256-seiX+q1wg+NyAnZmzM7FiKFkBRDebB07xYw/xedmCjg=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/sd_45315-reduced.odb";
      sha256 = "sha256-KHwQWldCoPXoUbiYb7YoYDUOsBAHwejlUYDaQT+xFpk=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/sd_45315.odb";
      sha256 = "sha256-tWkR2+5GLTzRbQMoEmogEL2smSwQVYK3Vuk6/63an0s=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/sd_45479_compare.odb";
      sha256 = "sha256-yEKhabbWHZHkmc7TryrVkxStmnJmybBzJMM3lQtTu8o=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/regressions/sd_45479_source.odb";
      sha256 = "sha256-ug7MeMzFuX4rUDVtCUqA03DDD8c3LZDlnxetqLqlF34=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/tests/2000010106-reduced.odb";
      sha256 = "sha256-HUu/M8jInXQbQAL4z5UEQtj7rhziLLWLlifD5dRcVrc=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/tests/core/odb_533_1.odb";
      sha256 = "sha256-PM3SnYBqLXLfut4pbFDfjRrubC4r3EVahHo1AFsUeGE=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/odc/tests/core/odb_533_2.odb";
      sha256 = "sha256-iHBoqI1DwtP8jIVFr1i8SWVoWWp6p0DJB5X0jcDh3Jo=";
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
      odb_387*|odb_463*|sd_45315*|sd_45479*)
        install -Dm444 $src $out/share/regressions/$fname
        ;;
      2000*)
        install -Dm444 $src $out/share/tests/$fname
        ;;
      odb_533*)
        install -Dm444 $src $out/share/tests/core/$fname
        ;;
      esac
    done
  '';
}
