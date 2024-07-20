{ lib
, stdenv
, fetchFromGitHub
, bash
, ecbuild
, eckit
, git
, odc-test-data
, perl
, withFortran ? false
, gfortran ? null
}:

assert withFortran -> gfortran != null;

stdenv.mkDerivation rec {
  pname = "odc";
  version = "1.5.2";

  src = lib.makeOverridable fetchFromGitHub {
    owner = "ecmwf";
    repo = "odc";
    rev = version;
    sha256 = "sha256-eBzpnrK0OXD1WWrG/+4jvLFAxPn5Jhot7Rfku6iZB4w=";
  };

  nativeBuildInputs = [
    ecbuild
    git
    perl
  ]
  ++ lib.optional withFortran gfortran
  ;

  propagatedBuildInputs = [
    eckit
  ];

  postPatch = ''
    for r in ODB-374 ODB-387-and-388 ODB-463 ODB-529 SD-45315 SD-45479 ; do
      substituteInPlace regressions/$r.sh \
        --replace '#!/bin/bash' '#!${bash}/bin/bash'
    done

    for f in api/usage_examples.sh c_api/usage_examples.sh ; do
      substituteInPlace tests/$f \
        --replace '#!/bin/bash' '#!${bash}/bin/bash'
    done

    for t in exit_codes header import split sql_bitfields sql_format sql_like sql_split sql_variables ; do
      substituteInPlace tests/tools/test_odb_$t.sh \
        --replace '#!/bin/bash' '#!${bash}/bin/bash'
    done
  '';

  cmakeFlags = [
    "-DENABLE_FORTRAN=${if withFortran then "ON" else "OFF"}"
    "-DENABLE_TESTS=ON"
  ];

  doCheck = true;

  checkInputs = [
    odc-test-data
  ];

  preCheck = ''
    mkdir -p regressions tests
    cp -R ${odc-test-data}/share/regressions/* regressions/
    cp -R ${odc-test-data}/share/tests/* tests/
  '';

  meta = with lib; {
    description = "Package to read/write ODB data";
    homepage = "https://confluence.ecmwf.int/display/ODC/ODC+Home";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
