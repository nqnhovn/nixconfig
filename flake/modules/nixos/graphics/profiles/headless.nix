# =====================================================================
# GRAPHICS PROFILE: HEADLESS (KHÔNG GPU — VPS/SERVER)
# =====================================================================
# Dùng cho: VPS, server, container. Không GUI, không display manager.

{ config, lib, ... }:

let
  cfg = config.flake.graphics.headless;
in
{
  options.flake.graphics.headless = {
    enable = lib.mkEnableOption "Headless mode (no GPU, no GUI)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = lib.mkForce false;
    services.displayManager.gdm.enable = lib.mkForce false;
    services.desktopManager.gnome.enable = lib.mkForce false;
    hardware.graphics.enable = lib.mkForce false;
  };

  # Default: headless không cần enable gì thêm (tắt hết)
  config = {
    flake.graphics.headless.enable = true;
  };
}
