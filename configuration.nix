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

  # 📦 Gói hệ thống — chỉ giữ những gì cần cho toàn bộ OS
  #    Ứng dụng cá nhân → chuyển sang home.packages trong home.nix
  environment.systemPackages = with pkgs; [
    # Công cụ CLI thiết yếu
    wget git fzf ripgrep gnumake pciutils usbutils
    # Python cho AI Agent scripts
    python3
    # Zsh completions
    zsh-completions
    # GNOME Extensions (cần system-wide để hoạt động)
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

    # ── Không dùng oh-my-zsh để tránh lỗi cache ──
    # Mọi tính năng được thay thế bằng native Zsh + plugin riêng

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 10000;
    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FIND_NO_DUPS"
      "HIST_IGNORE_SPACE"
    ];

    # ── Khởi tạo: fzf keybindings + sudo shortcut + extract function ──
    interactiveShellInit = ''
      # FZF keybindings (thay oh-my-zsh fzf plugin)
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh

      # Esc-Esc để thêm sudo (thay oh-my-zsh sudo plugin)
      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
        zle end-of-line
      }
      zle -N sudo-command-line
      bindkey "^[^[" sudo-command-line

      # Extract mọi định dạng nén (thay oh-my-zsh extract plugin)
      extract() {
        if [ -f $1 ]; then
          case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz)  tar xzf $1 ;;
            *.bz2)     bunzip2 $1 ;;
            *.rar)     unrar x $1 ;;
            *.gz)      gunzip $1 ;;
            *.tar)     tar xf $1 ;;
            *.tbz2)    tar xjf $1 ;;
            *.tgz)     tar xzf $1 ;;
            *.zip)     unzip $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1 ;;
            *)         echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
    '';

    shellAliases = {
      # ── Điều hướng ──
      ll = "ls -alF";
      la = "ls -A";
      l  = "ls -CF";
      ".."  = "cd ..";
      "..." = "cd ../..";

      # ── NixOS ──
      # build "Add new config" → git add . && git commit && rebuild với label
      build  = "noglob f() { cd ~/.config/nixos && git add . && git commit -m \"$1\" && sudo NIXOS_LABEL=\"$(echo \"$1\" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')\" nixos-rebuild switch --flake .#lg; }; f";
      update = "noglob sudo nixos-rebuild switch --flake ~/.config/nixos/#lg";
      clean  = "sudo nix-collect-garbage -d";

      # ── Podman / Docker ──
      dco = "podman-compose";
      d   = "podman";

      # ── Editor ──
      v = "vim";

      # ── Git ──
      g  = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --all";
      gd = "git diff";

      # ── Dev shortcuts (dùng với devbox) ──
      dev = "devbox";
      nrs = "npm run serve";
      nrd = "npm run dev";
      nrw = "npm run watch";

      # ── zoxide (thay oh-my-zsh z plugin) ──
      z = "zoxide";
    };
  };

  programs.zoxide.enable = true;

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
  # 3. HỆ THỐNG CỐT LÕI & NGỦ ĐÔNG (HIBERNATE) — TỐI ƯU KHỞI ĐỘNG
  # =====================================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # systemd initrd — thay thế bash initrd, khởi động nhanh hơn ~40%
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = false;
    tpm2.enable = false;
  };

  # Plymouth splash — không chữ, chỉ logo LG
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  # UUID phân vùng Swap
  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

  # Tham số kernel: yên lặng + tiết kiệm pin + tắt watchdog
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "nowatchdog"
    "modprobe.blacklist=iTCO_wdt"
    "i915.enable_fbc=1"
    "i8042.reset"
    "i8042.nomux=1"
    "atkbd.reset=1"
    "i915.enable_psr=1"
  ];

  # Cơ chế bảo vệ pin: Hibernate trực tiếp
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandlePowerKey = "hibernate";
  };
  # Tắt suspend hoàn toàn — chỉ dùng Hibernate
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "yes";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # Unbind/rebind driver i8042 sau resume - fix triet de ban phim LG Gram
  powerManagement.resumeCommands = ''
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind
  '';

  # Giảm timeout systemd (mặc định 90s -> 10s)
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultDeviceTimeoutSec = "10s";
  };

  systemd.services.NetworkManager-wait-online.enable = false;

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
      # --- CPU & Governor ---
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      # Giới hạn hiệu năng CPU khi rút sạc (xung nhịp tối đa = 60%)
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_MIN_PERF_ON_BAT = 0;

      # --- PCIe ASPM (Active State Power Management) ---
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # --- Wi-Fi Power Saving ---
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # --- USB Autosuspend ---
      USB_AUTOSUSPEND = 1;
      USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
      USB_DENYLIST = "046d:c318 046d:c52b";  # Giữ chuột/bàn phím ngoài luôn hoạt động

      # --- Runtime PM cho thiết bị ngoại vi ---
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me nvidia";

      # --- Âm thanh: Tự động tắt chip âm thanh khi không dùng ---
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      # --- Nền tảng Intel ---
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 650;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 900;

      # --- NVMe Power Management ---
      NVME_PS_MODE = "lowest";
    };
  };

  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  # =====================================================================
  # 5. BLUETOOTH, ÂM THANH & DỊCH VỤ KHÁC
  # =====================================================================
  # Bluetooth: luôn có sẵn nhưng KHÔNG tự bật khi khởi động để tiết kiệm pin
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
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

  system.stateVersion = "25.11"; # Phiên bản NixOS khởi tạo của hệ thống
}
