# =====================================================================
# MODULES/NIXOS/INSTALLER — ISO INSTALLER PROFILES
# =====================================================================
# Cấu hình cho nixos-generators ISO outputs.
# 2 profile: standard (GNOME + Calamares + app store), minimal (server)

{ config, lib, pkgs, ... }:

let
  cfg = config.flake.installer;
in
{
  options.flake.installer = {
    variant = lib.mkOption {
      type = lib.types.enum [ "standard" "minimal" ];
      default = "standard";
      description = "ISO installer variant";
    };

    includeNixHelper = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Thêm nh (nix-helper) CLI vào ISO";
    };

    includeAppStore = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Thêm Nix Software Center vào ISO (chỉ standard)";
    };
  };

  config = lib.mkMerge [
    # ── Common: tất cả variant ─────────────────────────────────
    {
      # Locale deferral: dùng en_US khi cài, target locale build sau
      flake.i18n = {
        enableDeferral = true;
        targetLocale = "en_US.UTF-8";
      };

      # Cho phép unfree (driver NVIDIA, Steam, v.v.)
      nixpkgs.config.allowUnfree = true;

      # System packages cốt lõi cho installer
      environment.systemPackages = with pkgs; [
        git
        vim
        curl
        wget
      ] ++ lib.optionals cfg.includeNixHelper [
        nh  # nix-helper CLI
      ] ++ lib.optionals (cfg.variant == "standard" && cfg.includeAppStore) [
        gnome-software  # Nix Software Center (GNOME Software + nix backend)
      ];
    }

    # ── Standard: GNOME + Calamares + App Store ────────────────
    (lib.mkIf (cfg.variant == "standard") {
      services.xserver = {
        enable = true;
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };

      # GNOME Software với nix backend
      services.gnome.gnome-software.enable = true;

      # Locale tiếng Việt cho installer
      flake.i18n.targetLocale = "vi_VN.UTF-8";
      flake.i18n.extraLocales = [ ];

      # Calamares installer
      services.calamares.enable = true;

      # NetworkManager cho WiFi trong installer
      networking.networkmanager.enable = true;
      networking.wireless.enable = lib.mkForce false;

      # ISO metadata
      isoImage = {
        edition = "gnome";
        volumeID = lib.mkForce "NIXOS_GNOME";
        makeEfiBootable = true;
        makeUsbBootable = true;
      };
    })

    # ── Minimal: server / headless ─────────────────────────────
    (lib.mkIf (cfg.variant == "minimal") {
      services.xserver.enable = false;
      isoImage = {
        edition = "minimal";
        volumeID = lib.mkForce "NIXOS_MINIMAL";
        makeEfiBootable = true;
        makeUsbBootable = true;
      };
    })
  ];
}
