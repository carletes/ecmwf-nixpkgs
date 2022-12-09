{
  description = "Experimental overlay for ECMWF software";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default =
        (
          final: prev: {
            ecbuild = prev.callPackage ./ecbuild/default.nix { pkgs = prev; };
            eccodes = prev.callPackage ./eccodes/default.nix { pkgs = final; };
            eckit = prev.callPackage ./eckit/default.nix { pkgs = final; };
            eckit-test-data = prev.callPackage ./eckit/test-data.nix { pkgs = final; };
            fdb = prev.callPackage ./fdb/default.nix { pkgs = final; };
            fdb-test-data = prev.callPackage ./fdb/test-data.nix { pkgs = final; };
            magics = prev.callPackage ./magics/default.nix { pkgs = final; };
            metkit = prev.callPackage ./metkit/default.nix { pkgs = final; };
            odc = prev.callPackage ./odc/default.nix { pkgs = final; };
            odc-test-data = prev.callPackage ./odc/test-data.nix { pkgs = final; };
          }
        );
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
