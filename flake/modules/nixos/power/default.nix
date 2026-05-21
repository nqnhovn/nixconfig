# =====================================================================
# MODULES/NIXOS/POWER — TLP, THERMALD, POWERTOP, SYSCTL
# =====================================================================
# Module chung — generic cho mọi host (laptop/desktop).
# Các tuỳ chỉnh dành riêng cho từng máy (hibernate, i8042 fix, s2idle)
# được đặt trong systems/<host>/default.nix.

{ pkgs, ... }:

{
  # ── TLP (tiết kiệm pin) ──────────────────────────────────────────────
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
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      WIFI_PWR_ON_AC = "on";
      WIFI_PWR_ON_BAT = "off";
      USB_AUTOSUSPEND = 1;
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      NVME_PS_MODE = "lowest";
    };
  };

  # ── thermald + powertop ──────────────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  # ── sysctl ────────────────────────────────────────────────────────────
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 3;
    "kernel.numa_balancing" = 0;
  };
}
