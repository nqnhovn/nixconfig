{
  description = "NixOS Flake Configuration for LG Gram 17";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/latest";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, devenv, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        lg = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/lg/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.nqnhovn = import ./home/default.nix;
              system.configurationRevision = self.rev or "dirty";
            }
          ];
        };
      };

      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ ... }: { devenv.root = toString ./.; })
          (import ./devenv.nix { inherit pkgs inputs; })
        ];
      };

      packages.x86_64-linux.iso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        format = "install-iso";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
          ({ lib, ... }: {
            nixpkgs.config.allowUnfree = true;
            isoImage.editionName = lib.mkForce "standard-installer";
            system.stateVersion = "25.11";
          })
        ];
      };
    };
}
