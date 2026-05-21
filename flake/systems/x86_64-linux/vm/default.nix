# =====================================================================
# SYSTEMS/X86_64-LINUX/VM — MÁY ẢO DEV (QEMU/VIRTUALBOX)
# =====================================================================

{ lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../../modules/nixos
  ];
  flake.graphicsProfile = "vm-guest";

  flake.i18n = {
    enableDeferral = false;
    targetLocale = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
}
