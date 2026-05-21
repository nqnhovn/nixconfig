# =====================================================================
# MODULES/NIXOS/POWER — HIBERNATE, TLP, THERMALD, POWERTOP
# LG GRAM 17 (i5-10210U Comet Lake + NVIDIA GTX 1650)
# =====================================================================

{ pkgs, ... }:

{
  # ── Hibernate + Keyboard fix ──────────────────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandlePowerKey = "suspend-then-hibernate";
    IdleAction = "suspend-then-hibernate";
    IdleActionSec = "10min";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "5min";
  };

  # ── Power source aware idle adjustment ────────────────────────────────
  systemd.user.services.power-idle-adjust = {
    description = "Adjust logind IdleActionSec based on power source";
    script = ''
      export XDG_RUNTIME_DIR=/run/user/$UID
      if grep -q "Discharging" /sys/class/power_supply/BAT?/status 2>/dev/null; then
        ${pkgs.systemd}/bin/loginctl set-idle-action-delay 5min
      else
        ${pkgs.systemd}/bin/loginctl set-idle-action-delay 10min
      fi
    '';
    wantedBy = [ "default.target" ];
    path = with pkgs; [ systemd gnugrep ];
  };

  systemd.user.timers.power-idle-adjust = {
    description = "Run power-idle-adjust service periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnStartupSec = "10s";
      OnUnitActiveSec = "1min";
    };
  };

  # ── Keyboard fix after resume ─────────────────────────────────────────
  powerManagement.resumeCommands = ''
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind
  '';

  # ── Suspend mode ──────────────────────────────────────────────────────
  boot.kernelParams = [ "mem_sleep_default=s2idle" ];

  # ── TLP ───────────────────────────────────────────────────────────────
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
      WIFI_PWR_ON_AC = "on";
      WIFI_PWR_ON_BAT = "off";
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
