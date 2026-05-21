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
      power-button-action = "suspend";
      sleep-button-action = "suspend";
      sleep-inactive-ac-timeout = 600; # 10 minutes (matching logind for AC)
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-timeout = 300; # 5 minutes (matching logind for Battery)
      sleep-inactive-battery-type = "suspend";
    };
    "org/gnome/desktop/session" = {
      idle-delay = 300; # Blank screen after 5 minutes of inactivity
    };
    "org/gnome/desktop/interface" = {
      idle-dim = true; # Dim screen when idle
    };
  };
}
