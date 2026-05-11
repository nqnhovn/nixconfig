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
  #    Chỉ user nqnhovn mới thấy — không ảnh hưởng hệ thống
  #    direnv, starship, zoxide, firefox: được cài tự động qua programs.*
  # =====================================================================
  home.packages = with pkgs; [
    # ── Terminal & Monitoring ──
    btop            # Task manager đẹp trên terminal
    # ── Dev Tools ──
    devbox          # Tạo môi trường dev biệt lập theo dự án
    vim             # Text editor
    zed-editor      # Code editor chính
    # ── Container ──
    podman-compose  # Docker Compose cho Podman
    podman-tui      # Giao diện quản lý Podman trên terminal
    distrobox       # Container Linux subsystem

    # ═══════════════════════════════════════════════════════════
    # 📋 MẪU THÊM ỨNG DỤNG (bỏ # để kích hoạt)
    # ═══════════════════════════════════════════════════════════
    # bat             # cat có syntax highlighting + line number
    # eza             # ls hiện đại, có icon, màu sắc
    # fd              # find nhanh hơn, cú pháp thân thiện
    # jq              # Xử lý JSON trên command line
    # yq              # Xử lý YAML trên command line
    # lazygit         # Git TUI
    # lazydocker      # Docker TUI
    gh              # GitHub CLI
    # glab            # GitLab CLI
    # obsidian        # Ứng dụng ghi chú
    # vlc             # Trình phát video/audio
    # gimp            # Chỉnh sửa ảnh
    # inkscape        # Đồ họa vector
    # slack           # Ứng dụng chat
    # telegram-desktop # Ứng dụng nhắn tin
    # zoom-us         # Họp trực tuyến
    # remmina         # Remote desktop client
    # virt-manager    # Quản lý máy ảo QEMU/KVM
    # bottles         # Chạy ứng dụng Windows trên Linux
    # bruno           # API client (thay Postman)
  ];

  # =====================================================================
  # Cấu hình Git
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
  # 🦊 FIREFOX — Tối ưu pin, tốc độ, bảo mật & lập trình
  # =====================================================================
  programs.firefox = {
    enable = true;

    # ── Chính sách (Enterprise Policies) ──
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = true;
      PasswordManagerEnabled = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      # DNS over HTTPS — tăng tốc độ phân giải tên miền
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = "https://cloudflare-dns.com/dns-query";
        Locked = false;
      };
    };

    # ── about:config Preferences ──
    preferences = {
      # === TỐI ƯU PIN ===
      "browser.tabs.unloadOnLowMemory" = true;
      "browser.sessionhistory.max_total_viewers" = 0;
      "accessibility.force_disabled" = 1;
      "browser.download.animateNotifications" = false;
      "toolkit.cosmeticAnimations.enabled" = false;
      "widget.content.gtk-theme-override" = "Adwaita:light";

      # === TỐC ĐỘ LƯỚT WEB ===
      "network.dns.disablePrefetch" = false;
      "network.prefetch-next" = true;
      "gfx.webrender.all" = true;               # GPU render
      "browser.cache.disk.enable" = true;
      "browser.cache.memory.enable" = true;
      "browser.cache.memory.capacity" = 256000;  # 256MB memory cache
      "network.http.max-connections" = 256;
      "network.http.max-persistent-connections-per-server" = 16;
      "network.http.pipelining" = true;
      "browser.urlbar.suggest.quicksuggest" = false;  # Tắt sponsored
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.snippets" = false;
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

      # === BẢO MẬT ===
      "browser.safebrowsing.malware.enabled" = true;
      "browser.safebrowsing.phishing.enabled" = true;
      "browser.send_pings" = false;
      "dom.battery.enabled" = false;
      "privacy.trackingprotection.enabled" = true;
      "privacy.donottrackheader.enabled" = true;
      "browser.contentblocking.category" = "strict";

      # === LẬP TRÌNH (Dev Tools) ===
      "devtools.chrome.enabled" = true;
      "devtools.debugger.remote-enabled" = true;
      "devtools.inspector.showAllAnonymousContent" = true;
      "devtools.theme" = "dark";
      "browser.tabs.warnOnClose" = false;
      "browser.tabs.warnOnCloseOtherTabs" = false;
      "browser.ctrlTab.recentlyUsedOrder" = false;

      # === TẢI XUỐNG ===
      "browser.download.dir" = "/home/nqnhovn/Downloads";
      "browser.download.folderList" = 2;
      "browser.download.useDownloadDir" = true;
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
  # - Nút Minimize, Maximize, Close trên cửa sổ
  # - Extensions tự động bật khi khởi động
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
  };
}
