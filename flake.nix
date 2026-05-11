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
      # Tên cấu hình 'lg' khớp với lệnh build anh đang sử dụng
      lg = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        # Truyền inputs vào trong các module để có thể sử dụng (nếu cần)
        specialArgs = { inherit inputs; };
        
        modules = [
          # Import các file cấu hình hệ thống
          ./hardware-configuration.nix
          ./configuration.nix
          
          # Cấu hình Home Manager như một NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            # Khai báo cấu hình cá nhân cho user nqnhovn
            home-manager.users.nqnhovn = import ./home.nix;
          }
        ];
      };
    };
  };
}
