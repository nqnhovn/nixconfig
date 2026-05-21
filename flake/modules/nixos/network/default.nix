# =====================================================================
# MODULES/NIXOS/NETWORK — NETWORK, TIMEZONE, LOCALE
# =====================================================================

{ ... }:

{
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n.defaultLocale = "en_US.UTF-8";
}
