{
  description = "NixOS Flake Configuration for LG Gram 17";

  inputs = {
    # Sử dụng nhánh unstable cho NixOS 25.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Tích hợp Home Manager đồng bộ với nhánh của nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # "nixos" chính là hostname của máy anh
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          
          # Cấu hình Home Manager như một NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nqnhovn = import ./home.nix; # Tách riêng file home.nix cho gọn
          }
        ];
      };
    };
  };
}
