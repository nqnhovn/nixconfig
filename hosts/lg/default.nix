# =====================================================================
# HOSTS/LG/DEFAULT.NIX — LG GRAM 17 (17U70N) MACHINE CONFIG
# =====================================================================

{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/core.nix
    ../../modules/system/boot.nix
    ../../modules/system/power.nix
    ../../modules/system/display.nix
    ../../modules/system/network.nix
    ../../modules/system/services.nix
    ../../modules/system/shell.nix
  ];
}
