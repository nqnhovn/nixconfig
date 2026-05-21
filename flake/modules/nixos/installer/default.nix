# =====================================================================
# MODULES/NIXOS/INSTALLER — ISO INSTALLER PROFILES
# =====================================================================
# 2 ISO variants:
#   - standard: Desktop (GNOME + Calamares + WPS Office + Input Method)
#   - minidev:  Developer (GNOME + Calamares + Dev tools + Container)
#
# NVIDIA GPU: ISO boots with modesetting (nouveau fallback).
#   Post-install script detects GPU and configures nvidia-prime profile.

{ config, lib, pkgs, ... }:

let
  cfg = config.flake.installer;
in
{
  options.flake.installer = {
    variant = lib.mkOption {
      type = lib.types.enum [ "standard" "minidev" ];
      default = "standard";
      description = "ISO installer variant";
    };

    # ── Desktop Apps (standard) ──────────────────────────────────
    includeWPS = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Cài WPS Office (chỉ standard)";
    };

    # ── Dev Tools (minidev) ──────────────────────────────────────
    includeDevTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Cài dev tools (Go, Node, Python, Podman)";
    };

    # ── Input Method ─────────────────────────────────────────────
    inputMethod = lib.mkOption {
      type = lib.types.enum [ "fcitx5-unikey" "fcitx5-mozc" "fcitx5-chinese" "none" ];
      default = "fcitx5-unikey";
      description = "Bộ gõ mặc định trên ISO";
    };

    # ── Common ───────────────────────────────────────────────────
    includeNixHelper = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    includeAppStore = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkMerge [
    # ═════════════════════════════════════════════════════════════
    # COMMON: TẤT CẢ VARIANT
    # ═════════════════════════════════════════════════════════════
    {
      nixpkgs.config.allowUnfree = true;

      # Locale: en_US trước (nhanh), target locale build sau
      flake.i18n = {
        enableDeferral = true;
        targetLocale = "en_US.UTF-8";
      };

      # Core packages
      environment.systemPackages = with pkgs; [
        git vim curl wget firefox
      ] ++ lib.optionals cfg.includeNixHelper [
        nh
      ] ++ lib.optionals cfg.includeAppStore [
        gnome-software
      ];

      # GPU: modesetting (nouveau fallback cho NVIDIA, Intel dùng i915)
      services.xserver.videoDrivers = [ "modesetting" ];
      hardware.graphics.enable = true;

      # Không cài NVIDIA driver trong ISO (giữ ISO nhỏ)
      # Post-install script sẽ detect và cấu hình sau
      hardware.nvidia.prime.offload.enable = lib.mkForce false;

      # Boot params: nomodeset fallback cho máy NVIDIA cứng đầu
      boot.kernelParams = [ "modprobe.blacklist=nouveau" ];

      # NetworkManager + WiFi
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      # ── Input Method (fcitx5) ───────────────────────────────
      i18n.inputMethod = lib.mkIf (cfg.inputMethod != "none") {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
        fcitx5.addons = with pkgs;
          (if cfg.inputMethod == "fcitx5-unikey" then [ qt6Packages.fcitx5-unikey ]
           else if cfg.inputMethod == "fcitx5-mozc" then [ fcitx5-mozc ]
           else if cfg.inputMethod == "fcitx5-chinese" then [ fcitx5-chinese-addons ]
           else [ ])
          ++ [ fcitx5-gtk fcitx5-table-extra ];
      };
    }

    # ═════════════════════════════════════════════════════════════
    # STANDARD: Desktop + WPS Office + Input Method
    # ═════════════════════════════════════════════════════════════
    (lib.mkIf (cfg.variant == "standard") {
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      services.gnome.gnome-software.enable = true;

      flake.installer.includeWPS = lib.mkDefault true;
      flake.installer.inputMethod = lib.mkDefault "fcitx5-unikey";

      environment.systemPackages = with pkgs;
        lib.optionals cfg.includeWPS [
          wpsoffice  # WPS Office
        ];

      # Fonts cho WPS + tiếng Việt
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        liberation_ttf
      ];
    })

    # ═════════════════════════════════════════════════════════════
    # MINIDEV: Developer tools + Container + Database
    # ═════════════════════════════════════════════════════════════
    (lib.mkIf (cfg.variant == "minidev") {
      services.xserver.enable = true;
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;
      services.gnome.gnome-software.enable = true;

      flake.installer.includeDevTools = lib.mkDefault true;
      flake.installer.inputMethod = lib.mkDefault "fcitx5-unikey";

      # Dev tools
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };

      environment.systemPackages = with pkgs;
        lib.optionals cfg.includeDevTools [
          # Languages
          go gopls golangci-lint
          nodejs_22 pnpm
          python3 python3Packages.pip
          # Databases
          postgresql mariadb sqlite
          # Tools
          lazygit gh delta tig
          postman
          # Container
          podman-compose distrobox
          # Nix
          nixpkgs-fmt nil nixd
          # Shell
          fzf ripgrep fd bat eza jq yq-go xh
          # VSCode-like
          zed-editor
        ];

      # PostgreSQL service cho dev
      services.postgresql = {
        enable = true;
        authentication = ''
          local all all trust
          host all all 127.0.0.1/32 trust
        '';
      };
    })
  ];
}
