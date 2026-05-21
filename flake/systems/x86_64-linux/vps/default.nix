# =====================================================================
# SYSTEMS/X86_64-LINUX/VPS — VPS SERVER (HEADLESS)
# =====================================================================

{ lib, ... }:

{
  imports = [
    ../../../modules/nixos
  ];

  networking.hostName = lib.mkDefault "nixos-vps";
  flake.graphicsProfile = "headless";

  flake.i18n = {
    enableDeferral = false;
    targetLocale = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
}
