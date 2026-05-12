# =====================================================================
# MODULES/SYSTEM/CORE.NIX — NGƯỜI DÙNG, NIX, GÓI HỆ THỐNG, MÔI TRƯỜNG
# =====================================================================

{ config, pkgs, ... }:

{
  # ── User (Rust-based userborn thay thế useradd) ───────────────────────
  services.userborn.enable = true;

  users.users.nqnhovn = {
    isNormalUser = true;
    description = "Nguyễn Quốc Nho";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  # ── Nix settings ──────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;

  # Auto GC hàng tuần — xóa generations > 7 ngày
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ── System packages ───────────────────────────────────────────────────
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

  # ── Session variables (ép GPU Intel cho desktop) ──────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
    DRI_PRIME = "0";
  };

  # ── Touchpad ──────────────────────────────────────────────────────────
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      disableWhileTyping = true;
      clickMethod = "clickfinger";
    };
  };

  system.stateVersion = "25.11";
}
