{ stdenv
, fetchurl
}:

stdenv.mkDerivation {
  pname = "eccodes-test-data";
  version = "2024-07-16-001";

  srcs = [
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eccodes/eccodes_test_data.tar.gz";
      sha256 = "sha256-rSFBgWyccZryOusCzkYU9525dukInzO2Z0o5BpRpLi4=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eccodes/data/ccsds_szip.grib2";
      sha256 = "sha256-rQPHm8luMSq60qOWcw0Iq5FYpO/jKkVI/mwHsjVzobU=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eccodes/data/boustrophedonic.grib1";
      sha256 = "sha256-GBHq9eludE5Nec6YxGAtb2eqIZlP51WBmivKkllfSo8=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eccodes/data/reduced_gaussian_sub_area.legacy.grib1";
      sha256 = "sha256-2WVSSthUWLSYl5nqi4piBJGmprSlgMEuU7PSJRjRboA=";
    })
    (fetchurl {
      url = "https://get.ecmwf.int/repository/test-data/eccodes/data/run_length_packing.grib2";
      sha256 = "sha256-ycKYHuR5v3idoAwMah+GiSKNW0EBPnrmBvKOklFKUv0=";
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
