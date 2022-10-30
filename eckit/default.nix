{ pkgs
, withAEC ? true
, withAIO ? true
, withArmadillo ? false
, withBuildTools ? true
, withBzip2 ? true
, withCurl ? true
, withEckitCmd ? true
, withEigen ? true
, withExperimental ? false
, withJemalloc ? false
, withLZ4 ? true
, withOpenMP ? false
, withSandbox ? false
, withSnappy ? true
, withSQL ? true
, withSSL ? true
, withUnicode ? true
, withXxHash ? true

  # Things I don't know how to handle:

  # , withCUDA ? false
  # , withLAPACK ? true
  # , withMKL ? false
  # , withMPI ? true
  # , withRADOS ? true
  # , withRsync ? true
  # , withViennaCL ? false
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

  propagatedBuildInputs = [
  ]
  ++ lib.optional withAEC libaec
  ++ lib.optional withArmadillo armadillo
  ++ lib.optional withBzip2 bzip2.dev
  ++ lib.optional withCurl curl
  ++ lib.optional withEckitCmd ncurses
  ++ lib.optional withEigen eigen
  ++ lib.optional withJemalloc jemalloc
  ++ lib.optional withLZ4 lz4
  ++ lib.optional withSnappy snappy
  ++ lib.optional withSSL openssl
  ++ lib.optional withXxHash xxHash
  ;

  cmakeFlags = [
    "-DENABLE_AEC=${if withAEC then "ON" else "OFF"}"
    "-DENABLE_AIO=${if withAIO then "ON" else "OFF"}"
    "-DENABLE_ARMADILLO=${if withArmadillo then "ON" else "OFF"}"
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_BZIP2=${if withBzip2 then "ON" else "OFF"}"
    "-DENABLE_CURL=${if withCurl then "ON" else "OFF"}"
    "-DENABLE_ECKIT_CMD=${if withEckitCmd then "ON" else "OFF"}"
    "-DENABLE_ECKIT_SQL=${if withSQL then "ON" else "OFF"}"
    "-DENABLE_EIGEN=${if withEigen then "ON" else "OFF"}"
    "-DENABLE_EXPERIMENTAL=${if withExperimental then "ON" else "OFF"}"
    "-DENABLE_JEMALLOC=${if withJemalloc then "ON" else "OFF"}"
    "-DENABLE_LZ4=${if withLZ4 then "ON" else "OFF"}"
    "-DENABLE_OMP=${if withOpenMP then "ON" else "OFF"}"
    "-DENABLE_SANDBOX=${if withSandbox then "ON" else "OFF"}"
    "-DENABLE_SNAPPY=${if withSnappy then "ON" else "OFF"}"
    "-DENABLE_SSL=${if withSSL then "ON" else "OFF"}"
    "-DENABLE_UNICODE=${if withUnicode then "ON" else "OFF"}"
    "-DENABLE_XXHASH=${if withXxHash then "ON" else "OFF"}"

    # Test data needed for the extra tests, which we cannot download while building.
    # TODO: Find a way of prefetching the data and with this.
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
