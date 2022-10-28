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
          };
        }));
}
