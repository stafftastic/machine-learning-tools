{
  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      eachSystem = f: lib.genAttrs systems (system: f (argsFor system));
      argsFor = system: {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            cudaCapabilities = [ "6.1" ];
          };
        };
      };
    in
    {
      packages = eachSystem (
        { system, pkgs, ... }:
        {
          default = self.packages.${system}.all;
          all = pkgs.symlinkJoin {
            name = "all-packages";
            paths = lib.attrValues self.legacyPackages.${system}.python3Packages;
          };
        }
      );

      legacyPackages = eachSystem (
        { pkgs, ... }:
        {
          python3Packages = {
            inherit (pkgs.python3Packages)
              scipy
              numpy
              pandas
              ipykernel
              torch
              tensorflow
              sentence-transformers
              scikit-learn
              keras
              ;
          };
        }
      );
      formatter = eachSystem ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
