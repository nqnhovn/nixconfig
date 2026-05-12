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

  # systemd service: tự động chuyển tuned profile khi cắm/rút sạc
  systemd.services.tuned-ac-switch = {
    description = "Switch tuned profile on AC plug/unplug";
    path = [ pkgs.tuned ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ "$(cat /sys/class/power_supply/AC*/online 2>/dev/null)" = "1" ]; then
        tuned-adm profile balanced
      else
        tuned-adm profile laptop-battery-powersave
      fi
    '';
  };

  # udev rule kích hoạt service
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.systemd}/bin/systemctl start tuned-ac-switch"
  '';

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;

  # ── thermald + powertop ───────────────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
}
