{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  # Cấu hình Git (Cú pháp mới theo nhánh unstable)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nqnhovn";
        email = "nqnho.vn@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Cấu hình Zed Editor cho lập trình
  xdg.configFile."zed/settings.json".text = ''
    {
      "theme": "One Dark",
      "ui_font_size": 16,
      "buffer_font_size": 15,
      "telemetry": { "metrics": false },
      "languages": {
        "Go": { "language_servers": ["gopls"] },
        "Vue.js": { "language_servers": ["vue-language-server"] },
        "PHP": { "language_servers": ["intelephense"] }
      }
    }
  '';

  # GNOME Fractional Scaling và Extensions
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "caffeine@patapon.info" ];
    };
  };
}
