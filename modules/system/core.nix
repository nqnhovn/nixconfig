# =====================================================================
# MODULES/SYSTEM/CORE.NIX — NGƯỜI DÙNG, NIX, GÓI HỆ THỐNG, MÔI TRƯỜNG
# =====================================================================

{ pkgs, ... }:

{
  # ── User ─────────────────────────────────────────────────────────────
  # Cho phép chạy file nhị phân Linux thông thường (balena-etcher, AppImage...)
  programs.nix-ld = {
    enable = true;
    # Thư viện cần cho Electron apps + GUI + AppImage
    libraries = with pkgs; [
      glib
      gtk3
      pango
      cairo
      freetype # GUI core
      libnotify
      libappindicator-gtk3 # Notification tray
      libdrm
      mesa
      libgbm
      expat
      at-spi2-core # GPU + X11
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
      atk # Electron/Chrome
      cups
      dbus
      openssl
      systemd # Printing + IPC
      util-linux
      zlib
      fontconfig
      libpng
      pkgs."alsa-lib" # System
      stdenv.cc.cc.lib # libstdc++.so.6
    ];
  };

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
    devenv # Cài đặt devenv ở cấp độ hệ thống
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
