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
      mkISO = hostname: format: variant: extraModules:
        nixos-generators.nixosGenerate {
          inherit system;
          format = format;
          modules = [
            ./modules/nixos/installer
            ./modules/nixos/i18n
            {
              flake.installer.variant = variant;
              networking.hostName = lib.mkDefault "nixos-installer";
              fileSystems."/" = {
                device = "/dev/root";
                fsType = "tmpfs";
              };
              system.stateVersion = "25.11";
            }
            # isoImage chỉ cho ISO formats (không VM/WSL/Docker)
            (lib.mkIf (format == "install-iso" || format == "iso") {
              isoImage = {
                edition = if variant == "standard" then "gnome" else "minimal";
                makeEfiBootable = true;
                makeUsbBootable = true;
              };
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
        # 🖥️  Installer ISO GNOME + Calamares + nh + App Store
        iso-standard = mkISO "lg" "install-iso" "standard" [
          ("${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix")
        ];

        # ⚡ ISO tối thiểu (server/headless, không GUI)
        iso-minimal = mkISO "vps" "iso" "minimal" [
          ("${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
        ];

        # 🖴 VM image (qcow2 cho QEMU/libvirt)
        vm-qcow2 = mkISO "vm" "vm" "standard" [ ];

        # 📦 VM image (OVA cho VirtualBox)
        vm-vbox = mkISO "vm" "virtualbox" "standard" [ ];

        # 🪟 WSL image
        wsl = mkISO "vps" "wsl" "minimal" [ ];

        # ☁️  Amazon EC2 image
        amazon = mkISO "vps" "amazon" "minimal" [ ];

        # 🐳 Docker / OCI container
        docker = mkISO "vps" "docker" "minimal" [ ];
      };
    };
}
