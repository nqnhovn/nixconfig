{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  # =====================================================================
  # Sửa triệt để lỗi quyền cache oh-my-zsh
  # Chạy mỗi lần kích hoạt Home Manager, đảm bảo thư mục thuộc về user
  # =====================================================================
  home.activation.fixOhMyZshCache = ''
    CACHE_DIR="$HOME/.cache/oh-my-zsh"
    if [ -d "$CACHE_DIR" ]; then
      chown -R $(whoami):users "$CACHE_DIR" 2>/dev/null || true
    fi
    mkdir -p "$CACHE_DIR/completions"
    chown $(whoami):users "$CACHE_DIR" "$CACHE_DIR/completions" 2>/dev/null || true
  '';

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

  # =====================================================================
  # Cấu hình Zed Editor cho lập trình
  # - Agent Panel (AI Assistant) bên phải
  # - File Explorer (Project Panel) bên trái
  # =====================================================================
  xdg.configFile."zed/settings.json".text = ''
    {
      "theme": "One Dark",
      "ui_font_size": 16,
      "buffer_font_size": 15,
      "telemetry": { "metrics": false },
      "project_panel": {
        "dock": "left",
        "default_width": 280
      },
      "assistant": {
        "enabled": true,
        "dock": "right",
        "default_width": 420
      },
      "languages": {
        "Go": { "language_servers": ["gopls"] },
        "Vue.js": { "language_servers": ["vue-language-server", "tailwindcss-language-server"] },
        "PHP": { "language_servers": ["intelephense"] },
        "TypeScript": { "language_servers": ["typescript-language-server", "tailwindcss-language-server"] },
        "JavaScript": { "language_servers": ["typescript-language-server"] }
      }
    }
  '';

  # =====================================================================
  # Cấu hình GNOME Desktop
  # - Fractional Scaling (HiDPI)
  # - Menu nút Minimize, Maximize, Close trên cửa sổ
  # =====================================================================
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [ "caffeine@patapon.info" ];
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };
  };
}
