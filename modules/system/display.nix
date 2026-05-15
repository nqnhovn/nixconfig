# =====================================================================
# MODULES/SYSTEM/DISPLAY.NIX — NVIDIA, GNOME, GDM
# =====================================================================

{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };

  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # ── GDM: hiện ô mật khẩu ngay, không cần click chọn user ──────
  # GDM chạy dưới user "gdm", cần dconf profile riêng.
  # File dconf này khiến màn hình login focus vào ô password luôn.
  environment.etc = {
    "dconf/profile/gdm".text = ''
      user-db:user
      system-db:gdm
    '';
    "dconf/db/gdm.d/00-login-screen".text = ''
      [org/gnome/login-screen]
      enable-password-authentication=true
      banner-message-enable=false

      [org/gnome/desktop/session]
      idle-delay=uint32 0

      [org/gnome/desktop/screensaver]
      lock-enabled=false
    '';
  };
}
