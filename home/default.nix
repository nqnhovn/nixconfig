# =====================================================================
# HOME/DEFAULT.NIX — HOME MANAGER ENTRY POINT
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
  ];
}
