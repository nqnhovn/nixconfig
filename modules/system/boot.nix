# =====================================================================
# MODULES/SYSTEM/BOOT.NIX — BOOTLOADER, KERNEL, INITRD, PLYMOUTH
# =====================================================================

{ ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = false;
    tpm2.enable = false;
  };

  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

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

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultDeviceTimeoutSec = "10s";
  };
}
