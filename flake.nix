{
  inputs.nixpkgs.url = "nixpkgs/nixos-25.05";

  nixConfig = {
    extra-substituters = "https://nix-community.cachix.org";
    extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    extra-experimental-features = "nix-command flakes";
  };

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
              ipykernel
              keras
              numpy
              pandas
              scikit-learn
              scipy
              sentence-transformers
              tensorflow
              torch
              transformers
              ;
          };
        }
      );

      formatter = eachSystem ({ pkgs, ... }: pkgs.nixfmt-tree);
    };
}
