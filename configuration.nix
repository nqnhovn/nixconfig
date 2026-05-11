{ config, pkgs, ... }:

{
  imports = [];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.nqnhovn = {
    isNormalUser = true;
    description = "Nguyen Quoc Nho";
    extraGroups = [ "networkmanager" "wheel" "docker" "podman" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget git fzf ripgrep gnumake btop
    devbox direnv
    starship vim zed-editor
    podman-compose podman-tui
    gnomeExtensions.caffeine gnomeExtensions.appindicator
  ];

  # =====================================================================
  # GỠ BỎ ỨNG DỤNG MẶC ĐỊNH KHÔNG CẦN THIẾT
  # =====================================================================
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany # Trình duyệt web mặc định của GNOME
    geary    # Ứng dụng email
    totem    # Trình xem video
    gnome-music
    gnome-characters
    gnome-contacts
    gnome-weather
    tali iagno hitori atomix # Các game mặc định
  ];

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

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# =====================================================================
  # CẤU HÌNH NGỦ ĐÔNG (HIBERNATE) VÀ SWAP
  # =====================================================================
  
  # Khai báo UUID của phân vùng Swap để hệ thống biết nơi lấy dữ liệu khi thức dậy
  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

  # =====================================================================
 # =====================================================================
  # THIẾT LẬP NGỦ ĐÔNG (CẬP NHẬT CHO NIXOS 25.11)
  # =====================================================================
  
  services.logind.lidSwitch = "suspend-then-hibernate";
  
  # Cấu trúc mới thay thế cho extraConfig
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };
  
  networking.hostName = "lg";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";

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

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  # =====================================================================
  # CẤU HÌNH ĐỒ HỌA & TỐI ƯU PIN (NVIDIA + TLP)
  # =====================================================================
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Bật quản lý năng lượng Fine-grained để tắt hoàn toàn GPU khi không dùng
    powerManagement.enable = true;
    powerManagement.finegrained = true; 

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";  
      nvidiaBusId = "PCI:2:0:0"; 
    };
  };

  # Vô hiệu hóa trình quản lý pin mặc định của GNOME để tránh xung đột với TLP
  services.power-profiles-daemon.enable = false;

  # Kích hoạt TLP quản lý pin chuyên sâu
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      
      # Giới hạn mức độ tiêu thụ CPU khi dùng pin (để máy luôn mát mẻ)
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 70; # Khống chế xung nhịp tối đa ở mức 70% khi rút sạc

      # Tối ưu hóa cổng kết nối
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Quản lý nhiệt độ CPU Intel và tự động điều chỉnh các thiết bị ngoại vi
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  # =====================================================================
  # SOUND & PRINTING
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

  system.stateVersion = "25.11";
}
