# =====================================================================
# MODULES/SYSTEM/CORE.NIX — NGƯỜI DÙNG, NIX, GÓI HỆ THỐNG, MÔI TRƯỜNG
# =====================================================================

{ config, pkgs, ... }:

{
  users.users.nqnhovn = {
    isNormalUser = true;
    description = "Nguyen Quoc Nho";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget git fzf ripgrep gnumake pciutils usbutils
    python3
    home-manager
    zsh-completions
    gnomeExtensions.caffeine gnomeExtensions.appindicator
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour epiphany geary totem gnome-music
    gnome-characters gnome-contacts gnome-weather
    tali iagno hitori atomix
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    DRI_PRIME = "0";
  };

  system.stateVersion = "25.11";
}
