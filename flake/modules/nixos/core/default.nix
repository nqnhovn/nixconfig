# =====================================================================
# MODULES/NIXOS/CORE — USER, NIX SETTINGS, SYSTEM PACKAGES
# =====================================================================

{ pkgs, lib, ... }:

let
  # Đọc thông tin user từ secrets (fallback: example → mặc định)
  userInfoPath = ../../../../secrets/info.nix;
  userInfoExamplePath = ../../../../secrets/info.example.nix;
  userInfo = if builtins.pathExists userInfoPath
    then import userInfoPath
    else if builtins.pathExists userInfoExamplePath
    then import userInfoExamplePath
    else { };

  userName = lib.toLower (userInfo.user or "nixos");
  fullName = userInfo.fullName or "NixOS User";
in
{
  # ── User ─────────────────────────────────────────────────────────────
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      glib
      gtk3
      pango
      cairo
      freetype
      libnotify
      libappindicator-gtk3
      libdrm
      mesa
      libgbm
      expat
      at-spi2-core
      libxkbcommon
      libX11
      libxcb
      libXcomposite
      libXdamage
      libXrandr
      libXcursor
      libXfixes
      libXi
      libXtst
      libXinerama
      libXext
      libXt
      libXrender
      libXScrnSaver
      libXxf86vm
      libXau
      libXdmcp
      libxshmfence
      libICE
      libSM
      libpciaccess
      libGL
      nss
      nspr
      at-spi2-atk
      atk
      cups
      dbus
      openssl
      systemd
      util-linux
      zlib
      fontconfig
      libpng
      pkgs."alsa-lib"
      stdenv.cc.cc.lib
    ];
  };

  users.users.${userName} = {
    isNormalUser = true;
    description = fullName;
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  # ── Nix settings ──────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [ "root" userName ];
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ── System packages ───────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    wget
    git
    fzf
    ripgrep
    gnumake
    pciutils
    usbutils
    python3
    home-manager
    zsh-completions
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    devenv
    nh  # nix-helper: quản lý generations, clean, search
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    totem
    gnome-music
    gnome-characters
    gnome-contacts
    gnome-weather
    tali
    iagno
    hitori
    atomix
  ];

  # ── Session variables ─────────────────────────────────────────────────
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
