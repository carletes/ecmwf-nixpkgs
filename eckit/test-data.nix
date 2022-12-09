{ pkgs }:

with pkgs;
stdenv.mkDerivation {
  pname = "eckit-test-data";
  version = "2022-12-09-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/io/t.grib";
      sha256 = "sha256-d4QKz3LlZ8Ol6xnQHn2s8BWx6Ri4Gv9PUgjBgg0U0FQ=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/utils/2t_sfc.grib";
      sha256 = "sha256-wzZhvMXIixUZx/LGNBCmS9EJUtot1vlZM/pPbqfoV18=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/utils/2t_sfc_regrid.grib";
      sha256 = "sha256-OFQqtRwNYOooydVabn5q9VqJChgM6qMjg3ku7d7ex/k=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/utils/q_6ml_regrid.grib";
      sha256 = "sha256-EXeeHa1dtziiaaMdcro+jAHs96M92+fuhOA/Jqt7jEc=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/utils/u-v_6ml.grib";
      sha256 = "sha256-0qw/nkW7Z3SOYlEAftQrP5JAu8Ge2Zx65EbikpC9hfs=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eckit/tests/utils/vo-d_6ml.grib";
      sha256 = "sha256-3k4xCGjzmw1kiQ6e/kPz0uyP9Z50OBvIG/ofzJ6PWKM=";
    })
  ];

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    for src in $srcs ; do
      fname="$(stripHash $src)"
      if [ "$fname" = "t.grib" ] ; then
        install -Dm444 $src $out/share/io/$fname
      else
        install -Dm444 $src $out/share/utils/$fname
      fi
    done
  '';
}
