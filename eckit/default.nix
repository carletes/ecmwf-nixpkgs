{ pkgs
, enableAEC ? true
, enableAIO ? true
, enableArmadillo ? false
, enableBuildTools ? true
, enableBzip2 ? true
, enableCurl ? true
, enableEckitCmd ? true
, enableEigen ? true
, enableExperimental ? false
, enableJemalloc ? false
, enableLZ4 ? true
, enableOpenMP ? false
, enableSandbox ? false
, enableSnappy ? true
, enableSQL ? true
, enableSSL ? true
, enableUnicode ? true
, enableXxHash ? true

  # Things I don't know how to handle:

  # , enableCUDA ? false
  # , enableLAPACK ? true
  # , enableMKL ? false
  # , enableMPI ? true
  # , enableRADOS ? true
  # , enableRsync ? true
  # , enableViennaCL ? false
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "eckit";
  version = "1.20.2";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "eckit";
    rev = version;
    sha256 = "sha256-7kWBT5uOowCjMFymnhzQqgHl6ifCdo7SI7DnaLMWq/Q=";
  };

  postPatch = ''
    substituteInPlace regressions/ECKIT-166.sh.in \
      --replace '#!/usr/bin/env bash' '${bash}/bin/bash'
    substituteInPlace regressions/ECKIT-175.sh.in \
      --replace '#!/usr/bin/env bash' '${bash}/bin/bash'
    substituteInPlace regressions/ECKIT-221.sh.in \
      --replace '#!/usr/bin/env bash' '${bash}/bin/bash'
  '';

  nativeBuildInputs = [
    bison
    ecbuild
    flex
    git
    perl
    pkg-config
  ];

  buildInputs = [
  ]
  ++ lib.optional enableAEC libaec
  ++ lib.optional enableArmadillo armadillo
  ++ lib.optional enableBzip2 bzip2.dev
  ++ lib.optional enableCurl curl
  ++ lib.optional enableEckitCmd ncurses
  ++ lib.optional enableEigen eigen
  ++ lib.optional enableJemalloc jemalloc
  ++ lib.optional enableLZ4 lz4
  ++ lib.optional enableSnappy snappy
  ++ lib.optional enableSSL openssl
  ++ lib.optional enableXxHash xxHash
  ;

  cmakeFlags = [
    "-DENABLE_AEC=${if enableAEC then "ON" else "OFF"}"
    "-DENABLE_AIO=${if enableAIO then "ON" else "OFF"}"
    "-DENABLE_ARMADILLO=${if enableArmadillo then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if enableBuildTools then "ON" else "OFF"}"
    "-DENABLE_BZIP2=${if enableBzip2 then "ON" else "OFF"}"
    "-DENABLE_CURL=${if enableCurl then "ON" else "OFF"}"
    "-DENABLE_ECKIT_CMD=${if enableEckitCmd then "ON" else "OFF"}"
    "-DENABLE_ECKIT_SQL=${if enableSQL then "ON" else "OFF"}"
    "-DENABLE_EIGEN=${if enableEigen then "ON" else "OFF"}"
    "-DENABLE_EXPERIMENTAL=${if enableExperimental then "ON" else "OFF"}"
    "-DENABLE_JEMALLOC=${if enableJemalloc then "ON" else "OFF"}"
    "-DENABLE_LZ4=${if enableLZ4 then "ON" else "OFF"}"
    "-DENABLE_OMP=${if enableOpenMP then "ON" else "OFF"}"
    "-DENABLE_SANDBOX=${if enableSandbox then "ON" else "OFF"}"
    "-DENABLE_SNAPPY=${if enableSnappy then "ON" else "OFF"}"
    "-DENABLE_SSL=${if enableSSL then "ON" else "OFF"}"
    "-DENABLE_UNICODE=${if enableUnicode then "ON" else "OFF"}"
    "-DENABLE_XXHASH=${if enableXxHash then "ON" else "OFF"}"

    # Test data needed for the extra tests, which we cannot download while building.
    # TODO: Find a way of prefetching the data and enable this.
    "-DENABLE_EXTRA_TESTS=OFF"

    # Things I don't know how to handle.
    "-DENABLE_CUDA=OFF"
    "-DENABLE_LAPACK=OFF"
    "-DENABLE_MKL=OFF"
    "-DENABLE_MPI=OFF"
    "-DENABLE_RADOS=OFF"
    "-DENABLE_RSYNC=OFF"
    "-DENABLE_VIENNACL=OFF"
  ];

  doCheck = true;

  meta = with lib; {
    description = "C++ toolkit that supports development of tools and applications at ECMWF";
    homepage = "https://confluence.ecmwf.int/display/eckit";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
