# =====================================================================
# CONFIGURATION.NIX - TỐI ƯU CHO LG GRAM 17 (17U70N)
# Phiên bản: NixOS 25.11 (Xantusia)
# =====================================================================

{ config, pkgs, ... }:

{
  imports = []; # Cấu hình được quản lý thông qua Flake (flake.nix)

  # Kích hoạt các tính năng thử nghiệm cần thiết cho Flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # =====================================================================
  # 1. NGƯỜI DÙNG & GÓI PHẦN MỀM HỆ THỐNG
  # =====================================================================
  users.users.nqnhovn = {
    isNormalUser = true;
    description = "Nguyen Quoc Nho";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  # Cho phép cài đặt các phần mềm không mã nguồn mở (như driver NVIDIA)
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Công cụ Terminal cơ bản
    wget git fzf ripgrep gnumake btop pciutils usbutils
    # Phát triển phần mềm
    devbox direnv starship vim zed-editor
    # Containerization
    podman-compose podman-tui
    # Trình duyệt mặc định
    firefox 
    # Tiện ích giao diện GNOME
    gnomeExtensions.caffeine gnomeExtensions.appindicator
  ];

  # Gỡ bỏ các ứng dụng GNOME mặc định không dùng tới để nhẹ máy
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour epiphany geary totem gnome-music
    gnome-characters gnome-contacts gnome-weather
    tali iagno hitori atomix
  ];

  # =====================================================================
  # 2. VỎ LỆNH (SHELL) & BIẾN MÔI TRƯỜNG
  # =====================================================================
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "fzf" ];
    };
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -alF"; la = "ls -A"; l = "ls -CF";
# Sử dụng: build "Fix-Unikey"
  build = "f() { sudo NIXOS_LABEL=\"$1\" nixos-rebuild switch --flake ~/.config/nixos/#lg; }; f";
  
  # Giữ lại các alias cũ
  update = "sudo nixos-rebuild switch --flake ~/.config/nixos/#lg";
  clean = "sudo nix-collect-garbage -d";
      dco = "podman-compose"; d = "podman"; v = "vim";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;

  # Hỗ trợ chạy Docker thông qua Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # =====================================================================
  # 3. HỆ THỐNG CỐT LÕI & NGỦ ĐÔNG (HIBERNATE)
  # =====================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # UUID phân vùng Swap (Chuẩn xác cho máy anh để kích hoạt Hibernate)
  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

  # Cơ chế bảo vệ pin: Suspend (ngủ tạm) rồi tự động Hibernate (ngủ đông)
  services.logind.lidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min"; # Sau 30 phút Sleep sẽ tự động tắt máy vào Hibernate
  };

  networking.hostName = "lg";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

  # Bộ gõ tiếng Việt Fcitx5 (Unikey) - Đã sửa lỗi cho NixOS 25.11
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ 
      qt6Packages.fcitx5-unikey 
      fcitx5-table-extra 
      fcitx5-gtk
    ];
    fcitx5.waylandFrontend = true;
  };

  # Giao diện GNOME & Wayland
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";
  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; }; # Giúp các app như Chrome/Zed chạy mượt trên Wayland

  # =====================================================================
  # 4. ĐỒ HỌA NVIDIA & TỐI ƯU PIN (TLP)
  # =====================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Tiết kiệm điện: Tắt GPU NVIDIA hoàn toàn khi không xử lý nặng
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      # PCI Bus ID chuẩn của máy LG Gram 17
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  # Tắt trình quản lý mặc định của GNOME để dùng TLP chuyên sâu
  services.power-profiles-daemon.enable = false;

  # Tối ưu hóa Pin chuyên sâu cho Laptop
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # Giới hạn hiệu năng CPU tối đa 70% khi rút sạc để máy luôn mát và bền pin
      CPU_MAX_PERF_ON_BAT = 70; 

      # Tự động quản lý năng lượng các cổng kết nối ngoại vi
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  # =====================================================================
  # 5. ÂM THANH & DỊCH VỤ KHÁC
  # =====================================================================
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  system.stateVersion = "25.11"; # Phiên bản NixOS khởi tạo của hệ thống
}
