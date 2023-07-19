{ stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "metkit-test-data";
  version = "2024-07-20-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/latlon.grib";
      sha256 = "sha256-Ouaw/pAP6kYSP7tMiPqeu0S2/VJ8CoepSKzP/OxPuIk=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/latlon.grib.md5";
      sha256 = "sha256-hnsAgepaCVuDzjmroTSvjYLVe/o/us23FGzsRIaqlOI=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/synthetic_2msgs.grib";
      sha256 = "sha256-ZKmWLzFeiSAP5guJzj6BpKs+N+dGIoXDf3vDmbLC++c=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/grib_api/data/synthetic_2msgs.grib.md5";
      sha256 = "sha256-FCO/UDiCwTDd0Skh7l6JwKEYJbGU+aBdPxM8t5yPSfs=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/metkit/tests/multiodb.odb";
      sha256 = "sha256-64o104chaoHppozr6V++/TQpXVs5TX5qio0nBcuVQM0=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/metkit/tests/multiodb.odb.md5";
      sha256 = "sha256-CcfC9Kg2ez8lkKgjMHxlytBlhj9DYxdVEVJaMY406i8=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/metkit/tests/multiodb2.odb";
      sha256 = "sha256-N9M84oGZuVLLWzQyD3td0jP1WgDf/djzibTPbr1C8NY=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/metkit/tests/multiodb2.odb.md5";
      sha256 = "sha256-MH/H4cC2bbUvqSHgDXs9oVGxkCn+xpW5OJ0inhVN7sM=";
    })
  ];

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    for src in $srcs ; do
      fname="$(stripHash $src)"
      install -Dm444 $src $out/share/$fname
    done
  '';
}
