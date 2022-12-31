{
  description = "Experimental overlay for ECMWF software";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default =
        final: prev: {
          ecbuild = prev.callPackage ./ecbuild { pkgs = prev; };
          eccodes = prev.callPackage ./eccodes { pkgs = final; };
          eccodes-test-data = prev.callPackage ./eccodes/test-data.nix { pkgs = final; };
          eckit = prev.callPackage ./eckit { pkgs = final; };
          eckit-test-data = prev.callPackage ./eckit/test-data.nix { pkgs = final; };
          fdb = prev.callPackage ./fdb { pkgs = final; };
          fdb-test-data = prev.callPackage ./fdb/test-data.nix { pkgs = final; };
          magics = prev.callPackage ./magics { pkgs = final; };
          metkit = prev.callPackage ./metkit { pkgs = final; };
          metkit-test-data = prev.callPackage ./metkit/test-data.nix { pkgs = final; };
          odc = prev.callPackage ./odc { pkgs = final; };
          odc-test-data = prev.callPackage ./odc/test-data.nix { pkgs = final; };
        }
      ;
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in
        {
          packages = {
            ecbuild = pkgs.ecbuild;
            eccodes = pkgs.eccodes;
            eckit = pkgs.eckit;
            fdb = pkgs.fdb;
            magics = pkgs.magics;
            metkit = pkgs.metkit;
            odc = pkgs.odc;
          };
        }));
}
