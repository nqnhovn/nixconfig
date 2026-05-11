{ config, pkgs, ... }:

{
  # Nếu anh dùng Flake và đã khai báo modules ở flake.nix thì có thể để trống imports.
  # Nếu không, hãy giữ lại ./hardware-configuration.nix
  imports = [];

  # =====================================================================
  # KÍCH HOẠT FLAKES
  # =====================================================================
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # =====================================================================
  # USER ACCOUNT & SYSTEM PACKAGES
  # =====================================================================
  users.users.nqnhovn = {
    isNormalUser = true;
    description = "Nguyen Quoc Nho";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Công cụ hệ thống & Terminal
    wget git fzf ripgrep gnumake btop
    
    # Công cụ quản lý môi trường Dev
    devbox direnv
    
    # Custom shell prompt & editor
    starship vim zed-editor
    
    # Podman (Container)
    podman-compose podman-tui

    # GNOME Extensions
    gnomeExtensions.caffeine gnomeExtensions.appindicator
  ];

  # =====================================================================
  # SHELL & DEV TOOLS SERVICES
  # =====================================================================
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "fzf" ]; # Đã bỏ "golang" vì dùng devbox
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alF"; la = "ls -A"; l = "ls -CF";
      update = "sudo nixos-rebuild switch --flake /etc/nixos/#lg"; # Cập nhật alias theo host mới
      clean = "sudo nix-collect-garbage -d";
      dco = "podman-compose"; d = "podman"; v = "vim";
    };
  };

  # Kích hoạt Direnv ở cấp hệ thống để tích hợp liền mạch với Zsh và Devbox
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # =====================================================================
  # SYSTEM CORE & HARDWARE
  # =====================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Đổi Hostname theo yêu cầu
  networking.hostName = "lg";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

  # Cấu hình gõ tiếng Việt Fcitx5 (Đã chuẩn hóa cho GNOME Wayland)
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ 
      fcitx5-unikey 
      fcitx5-table-extra 
      fcitx5-gtk # Rất quan trọng để gõ không bị lỗi trên môi trường GNOME
    ];
    fcitx5.waylandFrontend = true;
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  # NVIDIA Prime Offload (Cấu hình theo đúng Bus ID đã kiểm tra)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";  
      nvidiaBusId = "PCI:2:0:0"; 
    };
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.11";
}
