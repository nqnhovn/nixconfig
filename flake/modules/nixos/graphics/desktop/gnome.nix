# =====================================================================
# GRAPHICS/DESKTOP/GNOME — GNOME 49 + GDM (WAYLAND)
# =====================================================================

{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # ── GDM: hiện ô mật khẩu ngay, không cần click chọn user ──────
  systemd.services.gdm-dconf = {
    description = "Setup GDM dconf for instant password prompt";
    wantedBy = [ "display-manager.service" ];
    before = [ "display-manager.service" ];
    script = ''
      mkdir -p /etc/dconf/db/gdm.d /etc/dconf/profile
      cat > /etc/dconf/profile/gdm << 'DCONF'
      user-db:user
      system-db:gdm
      DCONF
      cat > /etc/dconf/db/gdm.d/00-login-screen << 'DCONF'
      [org/gnome/login-screen]
      enable-password-authentication=true
      banner-message-enable=false

      [org/gnome/desktop/session]
      idle-delay=uint32 0

      [org/gnome/desktop/screensaver]
      lock-enabled=false
      DCONF
      ${pkgs.dconf}/bin/dconf update
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
