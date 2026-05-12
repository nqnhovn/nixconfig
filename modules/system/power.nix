# =====================================================================
# MODULES/SYSTEM/POWER.NIX — HIBERNATE, TUNED, THERMALD, POWERTOP
# LG GRAM 17 (i5-10210U Comet Lake + NVIDIA GTX 1650)
# =====================================================================

{ config, pkgs, ... }:

{
  # ── Hibernate + Keyboard fix ──────────────────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandlePowerKey = "hibernate";
    IdleAction = "ignore";
    IdleActionSec = "5min";
  };

  powerManagement.resumeCommands = ''
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind
  '';

  # ── tuned 2.27 — quản lý năng lượng chuyên sâu ──────────────────────
  services.tuned = {
    enable = true;
    ppdSupport = true;

    # PPD → Tuned profile mapping
    ppdSettings = {
      main = {
        default = "balanced";
        battery_detection = true;
      };
      profiles = {
        power-saver = "laptop-battery-powersave";
        balanced = "balanced";
        performance = "throughput-performance";
      };
      battery = {
        # Khi rút sạc → tự động chuyển sang powersave
        balanced = "laptop-battery-powersave";
        performance = "balanced";
      };
    };

    # Custom profile: tối ưu riêng cho LG Gram Comet Lake
    profiles.lg-gram-powersave = {
      main.include = "laptop-battery-powersave";

      # sysctl kernel tuning
      sysctl = {
        type = "sysctl";
        replace = true;
        # Giảm swap tendency (có 16GB RAM)
        "vm.swappiness" = 10;
        # Giảm writeback xuống disk
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 3;
        # Tối ưu network buffer
        "net.core.rmem_default" = 262144;
        "net.core.wmem_default" = 262144;
        # Tiết kiệm năng lượng scheduler
        "kernel.numa_balancing" = 0;
        "kernel.sched_energy_aware" = 1;
      };

      # CPU governor + energy settings
      cpu = {
        type = "cpu";
        replace = true;
        # Comet Lake: dùng intel_pstate powersave
        governor = "powersave";
        energy_perf_bias = "power";
        # Giới hạn max freq (60% hiệu năng = ~2.4GHz)
        min_perf_pct = 0;
        max_perf_pct = 60;
        no_turbo = true;
      };

      # Disk tuning
      disk = {
        type = "disk";
        devices = "nvme0n1";
        # NVMe: APM không hỗ trợ, dùng readahead thấp
        readahead = 256;
        spindown = 0;
      };

      # USB autosuspend
      usb = {
        type = "usb";
        autosuspend = 1;
      };

      # Audio powersave
      audio = {
        type = "audio";
        timeout = 1;
        reset_controller = true;
      };

      # WiFi powersave
      wifi = {
        type = "wifi";
        powersave = true;
      };

      # Scheduler
      scheduler = {
        type = "scheduler";
        runtime = 0;
        autogroup = true;
      };

      # Video (GPU) power saving
      video = {
        type = "video";
        radeon_powersave = "auto";
      };
    };
  };

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;
  services.upower.enable = true;

  # ── thermald + powertop (bổ trợ tuned) ────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
}
