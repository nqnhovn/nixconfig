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

  # ── tuned (không PPD — dùng udev tự chuyển profile) ─────────────────
  services.tuned.enable = true;

  # udev: cắm sạc → balanced, rút sạc → laptop-battery-powersave
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.tuned}/bin/tuned-adm profile balanced"
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.tuned}/bin/tuned-adm profile laptop-battery-powersave"
  '';

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;

  # ── thermald + powertop ───────────────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
}
