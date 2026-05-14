# =====================================================================
# MODULES/SYSTEM/POWER.NIX — HIBERNATE, TLP, THERMALD, POWERTOP
# LG GRAM 17 (i5-10210U Comet Lake + NVIDIA GTX 1650)
# =====================================================================

{ config, pkgs, lib, ... }:

{
  # ── Hibernate + Keyboard fix ──────────────────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend"; # Suspend when lid is closed
    HandlePowerKey = "suspend";  # Suspend when power key is pressed
    IdleAction = "suspend";    # Suspend when idle
    IdleActionSec = "10min";   # Default idle time (for AC)
  };

  # ── Systemd user service to adjust IdleActionSec based on power source ──
  systemd.user.services.power-idle-adjust = {
    description = "Adjust logind IdleActionSec based on power source";
    script = ''
      export XDG_RUNTIME_DIR=/run/user/$UID # Required for systemctl --user
      if /bin/grep -q "Discharging" /sys/class/power_supply/BAT?/status 2>/dev/null; then
        ${pkgs.systemd}/bin/loginctl set-idle-action-delay 5min # On battery, suspend after 5 min
      else
        ${pkgs.systemd}/bin/loginctl set-idle-action-delay 10min # On AC, suspend after 10 min
      fi
    ''; # Corrected syntax: removed extra backslashes and single quotes.
    wantedBy = [ "default.target" ];
    path = with pkgs; [ systemd ]; # Ensure loginctl is in PATH
  };

  # Run the service on startup and whenever power supply status changes
  systemd.user.timers.power-idle-adjust = {
    description = "Run power-idle-adjust service periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "10s";
      OnUnitActiveSec = "1min"; # Check every minute
    };
  };

  # Script to run when resuming from any suspend state (suspend/hibernate)
  powerManagement.resumeCommands = ''
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind
  '';

  # ── Tối ưu Suspend không sâu (s2idle) ──────────────────────────────────
  # Ưu tiên chế độ suspend s2idle (sleep không sâu) để cải thiện khả năng đánh thức bàn phím
  boot.kernelParams = [ "mem_sleep_default=s2idle" ]; # Thiết lập mem_sleep_default=s2idle

  # Đảm bảo các driver cần thiết không bị tắt quá sâu khi suspend
  # (nếu vẫn gặp vấn đề, có thể thêm các driver khác vào đây)
  # Lưu ý: powerOffModules chỉ áp dụng cho khi hệ thống tắt, không phải suspend.
  # Thay vào đó, chúng ta sẽ dựa vào các tinh chỉnh của TLP hoặc các giải pháp khác.
  # powerManagement.powerOffModules = [ "xhci_hcd" ]; # USB controller driver (bị loại bỏ vì không phù hợp với suspend)

  # ── TLP: tối ưu pin toàn diện cho Comet Lake ─────────────────────────
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    pd.enable = true;
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_MIN_PERF_ON_BAT = 0;
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      WIFI_PWR_ON_AC = "on";  # Set to 'on' for full performance when on AC
      WIFI_PWR_ON_BAT = "off"; # Set to 'off' for power saving when on battery
      USB_AUTOSUSPEND = 1;
      USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
      USB_DENYLIST = "046d:c318 046d:c52b";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me nvidia";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 650;
      INTEL_GPU_BOOST_FREQ_ON_BAT = 900;
      NVME_PS_MODE = "lowest";
    };
  };

  # ── thermald + powertop + sysctl ──────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 3;
    "kernel.numa_balancing" = 0;
  };
}
