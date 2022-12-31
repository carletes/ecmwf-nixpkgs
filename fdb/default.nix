{ pkgs
, withBuildTools ? true
, withExperimental ? false
, withLustre ? false
, withPmem ? false
, withRADOS ? false
, withRemote ? true
, withSandbox ? false
, withTOC ? true
}:

with pkgs;
stdenv.mkDerivation rec {
  pname = "fdb";
  version = "5.10.8";

  src = fetchFromGitHub {
    owner = "ecmwf";
    repo = "fdb";
    rev = version;
    sha256 = "sha256-YSjG5j/eF8baY7ylRzPAdPFbK04T3zCHoDeug3VYkME=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ];

  propagatedBuildInputs = [
    eccodes
    eckit
    metkit
  ]
  ++ lib.optional withPmem pmdk
  ;

  cmakeFlags = [
    "-DENABLE_BUILD_TOOLS=${if withBuildTools then "ON" else "OFF"}"
    "-DENABLE_EXPERIMENTAL=${if withExperimental then "ON" else "OFF"}"
    "-DENABLE_FDB_REMOTE=${if withRemote then "ON" else "OFF"}"
    "-DENABLE_LUSTRE=${if withLustre then "ON" else "OFF"}"
    "-DENABLE_PMEMFDB=${if withPmem then "ON" else "OFF"}"
    "-DENABLE_RADOSFDB=${if withRADOS then "ON" else "OFF"}"
    "-DENABLE_SANDBOX=${if withSandbox then "ON" else "OFF"}"
    "-DENABLE_TOCFDB=${if withTOC then "ON" else "OFF"}"
  ];

  postPatch = ''
    for r in 238 239 240 241 243 251 260 264 266 267 268 271 275 276 282 291 292 ; do
      substituteInPlace tests/regressions/FDB-$r/FDB-$r.sh.in \
        --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
    done

    substituteInPlace tests/fdb/tools/fdb_info.sh.in \
      --replace '#!/usr/bin/env bash' '#!${bash}/bin/bash'
  '';

  doCheck = true;

  checkInputs = [
    fdb-test-data
  ];

  preCheck = ''
    mkdir -p tests
    cp -R ${pkgs.fdb-test-data}/share/* tests/
  '';

  meta = with lib; {
    description = "Domain-specific object store for meteorological objects";
    homepage = "https://github.com/ecmwf/fdb";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}

