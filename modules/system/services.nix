# =====================================================================
# MODULES/SYSTEM/SERVICES.NIX — BLUETOOTH, ÂM THANH, PODMAN, FCITX5
# =====================================================================

{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-unikey
      fcitx5-table-extra
      fcitx5-gtk
    ];
    fcitx5.waylandFrontend = true;
  };

}
