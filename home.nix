# =====================================================================
# HOME.NIX — CẤU HÌNH CÁ NHÂN QUA HOME MANAGER
#
# 🔍 CÁCH TÌM ĐÚNG TÊN GÓI ĐỂ THÊM VÀO:
#    1. Truy cập: https://search.nixos.org/packages
#    2. Gõ tên ứng dụng (vd: "firefox", "vlc", "obsidian")
#    3. Chọn kênh "unstable" (khớp với flake.nix)
#    4. Copy tên gói từ cột "Attribute name" (vd: "firefox", "vlc", "obsidian")
#    5. Thêm vào `home.packages` hoặc `environment.systemPackages`
#
#    📦 home.packages         → chỉ cài cho user hiện tại, không cần sudo
#    📦 environment.systemPackages (trong configuration.nix) → cài toàn hệ thống
#
#    🔎 Dùng terminal: nix-search tên-ứng-dụng (nếu đã cài nix-search)
#    🔎 Hoặc: nix-env -qaP | grep -i tên-ứng-dụng
# =====================================================================

{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  # =====================================================================
  # 📦 ỨNG DỤNG CÀI RIÊNG CHO USER
  # =====================================================================
  home.packages = with pkgs; [
    btop            # Task manager
    devbox          # Dev environment
    gh              # GitHub CLI
    vim             # Text editor
    zed-editor      # Code editor
    podman-compose  # Docker Compose cho Podman
    podman-tui      # Podman TUI
    distrobox       # Container Linux subsystem

    # ══ MẪU (bỏ # để kích hoạt) ══
    # bat
    # eza
    # fd
    # jq
    # lazygit
    # obsidian
    # vlc
  ];

  # =====================================================================
  # Git
  # =====================================================================
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
  # 🦊 Firefox — Tối ưu pin, tốc độ, bảo mật & lập trình
  # =====================================================================
  programs.firefox = {
    enable = true;

    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      PasswordManagerEnabled = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://cloudflare-dns.com/dns-query";
        Locked = false;
      };
    };

    profiles.nqnhovn = {
      id = 0;
      name = "nqnhovn";
      isDefault = true;
      settings = {
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.sessionhistory.max_total_viewers" = 0;
        "accessibility.force_disabled" = 1;
        "browser.download.animateNotifications" = false;
        "toolkit.cosmeticAnimations.enabled" = false;
        "network.dns.disablePrefetch" = false;
        "network.prefetch-next" = true;
        "gfx.webrender.all" = true;
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.cache.memory.capacity" = 256000;
        "network.http.max-connections" = 256;
        "network.http.max-persistent-connections-per-server" = 16;
        "network.http.pipelining" = true;
        "browser.urlbar.suggest.quicksuggest" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.safebrowsing.malware.enabled" = true;
        "browser.safebrowsing.phishing.enabled" = true;
        "browser.send_pings" = false;
        "dom.battery.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "browser.contentblocking.category" = "strict";
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
        "devtools.inspector.showAllAnonymousContent" = true;
        "devtools.theme" = "dark";
        "browser.tabs.warnOnClose" = false;
        "browser.tabs.warnOnCloseOtherTabs" = false;
      };
    };
  };

  # =====================================================================
  # Zed Editor
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
  # GNOME Desktop
  # =====================================================================
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
      # Tự động hibernate sau 10 phút không dùng (Caffeine chặn nếu đang bật)
      sleep-inactive-ac-timeout = 600;
      sleep-inactive-ac-type = "hibernate";
      sleep-inactive-battery-timeout = 600;
      sleep-inactive-battery-type = "hibernate";
    };
  };
}
