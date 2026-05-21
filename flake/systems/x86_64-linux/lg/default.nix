# =====================================================================
# SYSTEMS/X86_64-LINUX/LG — LG GRAM 17 (17U70N)
# =====================================================================
# i5-10210U · Intel UHD + NVIDIA GTX 1650 (PRIME) · GNOME 49 + Wayland

{ config, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../../../modules/nixos
  ];

  # ── Host identity ─────────────────────────────────────────────────
  networking.hostName = lib.mkDefault "lg";
  flake.graphicsProfile = "nvidia-prime";

  # ── Locale: cài en_US trước, thêm tiếng Việt sau ────────────────
  flake.i18n = {
    enableDeferral = true;
    targetLocale = "vi_VN.UTF-8";
    extraLocales = [ ];
  };

  system.stateVersion = "25.11";
}
