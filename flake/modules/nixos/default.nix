# =====================================================================
# FLAKE/MODULES/NIXOS/DEFAULT.NIX — AUTO-IMPORT TẤT CẢ NIXOS MODULES
# =====================================================================
# Snowfall pattern: mỗi thư mục con là 1 domain module.
# Domain modules được tự động load, host chỉ cần enable domain cần dùng.

{ lib, ... }:

let
  # Tự động import tất cả thư mục con có default.nix
  domainModules = [
    ./core
    ./boot
    ./graphics
    ./power
    ./network
    ./services
    ./shell
    ./i18n
  ];
in
{
  imports = domainModules;
}
