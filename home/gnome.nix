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
      sleep-inactive-ac-timeout = 300;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 300;
      sleep-inactive-battery-type = "nothing";
    };
  };
}
