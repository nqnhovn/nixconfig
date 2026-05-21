# =====================================================================
# MODULES/NIXOS/BOOT — BOOTLOADER, KERNEL, INITRD, PLYMOUTH
# =====================================================================
# Module chung — generic cho mọi host.
# Các tuỳ chỉnh dành riêng cho máy (resumeDevice, kernel params)
# được đặt trong systems/<host>/default.nix.

{ lib, pkgs, ... }:

{
  # ── Bootloader ────────────────────────────────────────────────────────
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
    editor = false;
    memtest86.enable = false;
    consoleMode = "auto";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 3;

  # ── Kernel mới nhất ───────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── systemd initrd ────────────────────────────────────────────────────
  boot.initrd.systemd = {
    enable = true;
    emergencyAccess = lib.mkDefault false;
    tpm2.enable = false;
  };

  # ── Early KMS — load Intel GPU trong initrd ───────────────────────────
  boot.initrd.kernelModules = [ "i915" ];
  hardware.enableRedistributableFirmware = true;

  # ── Plymouth splash ───────────────────────────────────────────────────
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };

  # ── Kernel params chung ──────────────────────────────────────────────
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "nowatchdog"
  ];

  # ── Timeout nhanh hơn ─────────────────────────────────────────────────
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "10s";
    DefaultDeviceTimeoutSec = "10s";
  };
}
