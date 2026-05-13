# =====================================================================
# MODULES/SYSTEM/BOOT.NIX — BOOTLOADER, KERNEL, INITRD, PLYMOUTH
# =====================================================================

{ lib, pkgs, ... }:

{
  # ── Bootloader ────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3; # Chỉ giữ 3 generation gần nhất
    editor = false;
    memtest86.enable = false;
    consoleMode = "auto";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 3; # Chỉ đợi 3 giây khi boot

  # ── Kernel mới nhất ───────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── systemd initrd (nhanh hơn bash initrd ~40%) ──────────────────────
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = lib.mkDefault false;
    tpm2.enable = false;
  };

  # ── Early KMS — load Intel GPU trong initrd ───────────────────────────
  boot.initrd.kernelModules = [ "i915" ];
  hardware.enableRedistributableFirmware = true;

  # ── Plymouth splash (logo LG, không chữ) ─────────────────────────────
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  # ── Hibernate ─────────────────────────────────────────────────────────
  boot.resumeDevice = "/dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393";

  # ── Kernel params ─────────────────────────────────────────────────────
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "snd-intel-dspcfg.dsp_driver=1"
    "nowatchdog"
    "modprobe.blacklist=iTCO_wdt"
    "modprobe.blacklist=snd_sof_pci_intel_cnl"
    "i8042.nopnp=1"
    "i8042.dumbkbd=1"
    "i915.min_freq=300"
    "i915.max_freq=650"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # ── Timeout nhanh hơn ─────────────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultDeviceTimeoutSec = "10s";
  };
}
