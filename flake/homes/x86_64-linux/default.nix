# =====================================================================
# FLAKE/HOMES/X86_64-LINUX/DEFAULT.NIX — HOME MANAGER ENTRY POINT
# =====================================================================

{ ... }:

{
  home.stateVersion = "25.11";

  imports = [
    ./packages.nix
    ./git.nix
    ./firefox.nix
    ./zed.nix
    ./gnome.nix
    ./aichat.nix
    ./rules.nix
  ];
}
