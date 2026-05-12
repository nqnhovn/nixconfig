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

  # ── tuned 2.27 + PPD ─────────────────────────────────────────────────
  # udev rule: tự động chuyển profile khi cắm/rút sạc
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.tuned}/bin/tuned-adm profile laptop-ac-powersave"
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.tuned}/bin/tuned-adm profile laptop-battery-powersave"
  '';
  services.tuned = {
    enable = true;
    ppdSupport = true;

    ppdSettings = {
      main = {
        default = "balanced";
        battery_detection = true;
      };
      # PPD profile → tuned profile
      profiles = {
        power-saver = "laptop-battery-powersave";
        balanced = "balanced";
        performance = "throughput-performance";
      };
    };

    # Custom LG Gram powersave profile
    profiles.lg-gram-powersave = {
      main.include = "laptop-battery-powersave";

      sysctl = {
        type = "sysctl";
        replace = true;
        "vm.swappiness" = 10;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 3;
        "kernel.numa_balancing" = 0;
        "kernel.sched_energy_aware" = 1;
      };

      cpu = {
        type = "cpu";
        replace = true;
        governor = "powersave";
        energy_perf_bias = "power";
        min_perf_pct = 0;
        max_perf_pct = 60;
        no_turbo = true;
      };

      disk = {
        type = "disk";
        devices = "nvme0n1";
        readahead = 256;
      };

      usb = {
        type = "usb";
        autosuspend = 1;
      };

      audio = {
        type = "audio";
        timeout = 1;
        reset_controller = true;
      };

      wifi = {
        type = "wifi";
        powersave = true;
      };

      scheduler = {
        type = "scheduler";
        runtime = 0;
        autogroup = true;
      };

      video = {
        type = "video";
        radeon_powersave = "auto";
      };
    };
  };

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;
  services.upower.enable = true;

  # ── thermald + powertop ───────────────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
}
