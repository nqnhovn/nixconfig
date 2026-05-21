# =====================================================================
# SYSTEMS/X86_64-LINUX/VM — MÁY ẢO DEV (QEMU/VIRTUALBOX)
# =====================================================================

{ lib, ... }:

{
  imports = [
    ../../modules/nixos
  ];

  networking.hostName = lib.mkDefault "nixos-vm";
  flake.graphicsProfile = "vm-guest";

  flake.i18n = {
    enableDeferral = false;
    targetLocale = "en_US.UTF-8";
  };

  system.stateVersion = "25.11";
}
