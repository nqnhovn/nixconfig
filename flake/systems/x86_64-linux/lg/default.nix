# =====================================================================
# SYSTEMS/X86_64-LINUX/LG — LG GRAM 17 (17U70N)
# =====================================================================
# i5-10210U · Intel UHD + NVIDIA GTX 1650 (PRIME) · GNOME 49 + Wayland

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../../modules/nixos
  ];

  networking.hostName = lib.mkDefault "lg";
  flake.graphicsProfile = "nvidia-prime";

  # ── Locale: cài en_US trước, thêm tiếng Việt sau ────────────────
  flake.i18n = {
    enableDeferral = true;
    targetLocale = "vi_VN.UTF-8";
    extraLocales = [ ];
  };

  # ── Hibernate (LG Gram specific UUID) ─────────────────────────────
  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

  # ── Kernel params (LG Gram + NVIDIA optimizations) ────────────────
  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"
    "modprobe.blacklist=iTCO_wdt"
    "modprobe.blacklist=snd_sof_pci_intel_cnl"
    "i8042.nopnp=1"
    "i8042.dumbkbd=1"
    "i915.min_freq=300"
    "i915.max_freq=650"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "mem_sleep_default=s2idle"
  ];

  # ── Power: lid close → hibernate after delay ─────────────────────
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

  # ── Power-aware idle adjustment ───────────────────────────────────
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

  # ── Keyboard fix after resume (PS/2 i8042) ────────────────────────
  powerManagement.resumeCommands = ''
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind
    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind
  '';

  # ── TLP: LG Gram specific overrides ───────────────────────────────
  services.tlp.settings = {
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 60;
    CPU_MIN_PERF_ON_BAT = 0;
    USB_AUTOSUSPEND_DISABLE_ON_SHUTDOWN = 1;
    USB_DENYLIST = "046d:c318 046d:c52b";
    RUNTIME_PM_DRIVER_DENYLIST = "mei_me nvidia";
    INTEL_GPU_MIN_FREQ_ON_BAT = 300;
    INTEL_GPU_MAX_FREQ_ON_BAT = 650;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 900;
  };

  system.stateVersion = "25.11";
}
