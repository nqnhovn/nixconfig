# =====================================================================
# MODULES/SYSTEM/POWER.NIX — HIBERNATE, TUNED, THERMALD, POWERTOP
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

  # ── tuned (thay TLP) — quản lý năng lượng hiện đại ──────────────────
  services.tuned = {
    enable = true;
    ppdSupport = true;  # Tích hợp GNOME Power Panel
  };

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;
  services.upower.enable = true;

  # ── thermald + powertop (bổ trợ tuned) ────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

}
