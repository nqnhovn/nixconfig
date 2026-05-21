# =====================================================================
# FLAKE/FLAKE.NIX — SNOWFALL-POWERED NIXOS CONFIGURATION
# =====================================================================
# Multi-host · Multi-graphics-profile · Multi-output (ISO/VM/WSL)
#
# Hosts:   lg (laptop), vm (dev VM), vps (server)
# Graphics: intel-only, nvidia-prime, vm-guest, headless
# Outputs:  nixosConfigurations, homeConfigurations, packages (iso/vm)

{
  description = "NixOS Snowfall Configuration — Multi-Host · Multi-Graphics";

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

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nixos-generators
    , devenv
    , ...
    }@inputs:
    let
      # ── System architecture ──────────────────────────────────────
      system = "x86_64-linux";

      # ── Extended lib ─────────────────────────────────────────────
      lib = nixpkgs.lib.extend (final: prev: {
        flake = import ./lib/default.nix { lib = prev; };
      });

      # ── Pkgs ─────────────────────────────────────────────────────
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # ── User config ──────────────────────────────────────────────
      user = {
        name = "nqnhovn";
        home = "/home/nqnhovn";
      };

      # ── Home Manager module ──────────────────────────────────────
      homeModule = {
        home = {
          username = user.name;
          homeDirectory = user.home;
          stateVersion = "25.11";
        };
        imports = [ ./homes/${system} ];
      };

      # ── Host builder ─────────────────────────────────────────────
      mkHost = hostname: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          (./systems/${system}/${hostname})
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${user.name} = { ... }: {
              imports = [
                (./homes/${system})
                { home.stateVersion = "25.11"; }
              ];
            };
            system.configurationRevision = self.rev or "dirty";
          }
        ] ++ extraModules;
      };

      # ── ISO builder ──────────────────────────────────────────────
      mkISO = hostname: format: extraModules:
        nixos-generators.nixosGenerate {
          inherit system;
          format = format;
          modules = [
            (./systems/${system}/${hostname})
            ({ lib, ... }: {
              nixpkgs.config.allowUnfree = true;
              system.stateVersion = "25.11";
            })
          ] ++ extraModules;
        };

    in
    {
      # ── NixOS Configurations ─────────────────────────────────────
      nixosConfigurations = {
        lg = mkHost "lg" [ ];
        vm = mkHost "vm" [ ];
        vps = mkHost "vps" [ ];
      };

      # ── Home Manager Configurations ──────────────────────────────
      homeConfigurations = {
        lg = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ homeModule ];
          extraSpecialArgs = { inherit inputs; };
        };
      };

      # ── Dev Shell ────────────────────────────────────────────────
      devShells.${system}.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ ... }: { devenv.root = toString ./..; })
          (import ../devenv.nix { inherit pkgs inputs; })
        ];
      };

      # ── Packages: ISO / VM images ────────────────────────────────
      packages.${system} = {
        # Installer ISO với GNOME + Calamares (full installer)
        iso-installer = mkISO "lg" "install-iso" [
          ("${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix")
          ({ lib, ... }: {
            isoImage.editionName = lib.mkForce "nixos-gnome-installer";
          })
        ];

        # ISO tối thiểu (không GUI, cho server/VPS)
        iso-minimal = mkISO "vps" "iso" [ ];

        # VM image (qcow2 cho QEMU)
        vm-qcow2 = mkISO "vm" "vm" [ ];

        # VM image (VirtualBox)
        vm-vbox = mkISO "vm" "virtualbox" [ ];

        # WSL image
        wsl = mkISO "vps" "wsl" [ ];
      };
    };
}
