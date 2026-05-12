{ ... }:

{
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "caffeine@patapon.info"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
      sleep-button-action = "hibernate";
      sleep-inactive-ac-timeout = 600;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = 600;
      sleep-inactive-battery-type = "hibernate";
    };
  };
}
