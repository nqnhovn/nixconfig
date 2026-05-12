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

  # ── tuned (tự chuyển profile qua systemd oneshot + udev) ─────────────
  services.tuned.enable = true;

  # systemd service: chuyển profile khi AC thay đổi, có chống loop
  systemd.services.tuned-ac-switch = {
    description = "Switch tuned profile on AC plug/unplug";
    path = [ pkgs.tuned pkgs.gawk ];
    serviceConfig.Type = "oneshot";
    script = ''
      CURRENT=$(tuned-adm active 2>/dev/null | awk -F': ' '{print $2}')
      ONLINE=$(cat /sys/class/power_supply/AC*/online 2>/dev/null | head -1)
      if [ "$ONLINE" = "1" ] && [ "$CURRENT" != "balanced" ]; then
        tuned-adm profile balanced
      elif [ "$ONLINE" = "0" ] && [ "$CURRENT" != "laptop-battery-powersave" ]; then
        tuned-adm profile laptop-battery-powersave
      fi
    '';
  };

  # udev: kích hoạt service khi online attribute thay đổi (--no-block tránh loop)
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="?*", RUN+="${pkgs.systemd}/bin/systemctl start --no-block tuned-ac-switch"
  '';

  services.power-profiles-daemon.enable = false;
  security.polkit.enable = true;

  # ── thermald + powertop ───────────────────────────────────────────────
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;
}
