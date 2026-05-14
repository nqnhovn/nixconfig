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
    # Thêm dòng này vào đây
    devenv.url = "github:cachix/devenv/latest";
    # Dòng này đảm bảo devenv sử dụng cùng phiên bản nixpkgs với hệ thống của bạn
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nixos-generators, devenv, ... }@inputs:
    let
      system = "x86_64-linux"; # Define system once for consistency
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow unfree packages for the default pkgs set
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
          { home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.nqnhovn = import ./home/default.nix;
          }
        ];
      };
    };

    # Định nghĩa một devShell mặc định cho Flake, sử dụng devenv.nix
    devShells.${system}.default = devenv.lib.mkShell {
      inherit inputs pkgs; # Pass inputs and pkgs directly to mkShell
      modules = [
        (import ./devenv.nix { inherit pkgs inputs; }) # Pass pkgs and inputs explicitly to the imported devenv.nix
      ];
    };

    # Cấu hình tạo file ISO sử dụng bộ cài đồ họa (Calamares) mặc định của NixOS
    packages.x86_64-linux.iso = nixos-generators.nixosGenerate {
      system = "x86_64-linux";
      format = "install-iso";
      modules = [
        # Import profile bộ cài đồ họa mặc định (GNOME/Calamares) của NixOS
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"

        # Tích hợp cấu hình phần cứng và hệ thống cơ bản vào ISO (nếu muốn)
        # ./hosts/lg/default.nix

        ({ lib, ... }: {
          nixpkgs.config.allowUnfree = true;

          # Đảm bảo các tính năng cần thiết cho bộ cài
          isoImage.editionName = lib.mkForce "standard-installer";

          # Cho phép cài đặt thông qua giao diện đồ họa Calamares
          system.stateVersion = "25.11";
        })
      ];
    };
  };
}
