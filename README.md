# 🐧 NixOS Configuration — LG Gram 17 (17U70N)

**NixOS 25.11 (Xantusia)** · **GNOME 49 + Wayland** · **Intel i5-10210U + NVIDIA GTX 1650**

---

## 📁 Cấu trúc dự án

```
~/.config/nixos/
├── flake.nix                  # 🔗 Trung tâm điều phối — Flake entry point
├── flake.lock                 # 🔒 Khoá phiên bản các input (nixpkgs, home-manager)
├── configuration.nix          # ⚙️  Cấu hình hệ thống (kernel, driver, services, TLP…)
├── hardware-configuration.nix # 🖥️  Cấu hình phần cứng (auto-generated, KHÔNG sửa tay)
├── home.nix                   # 🏠  Cấu hình cá nhân qua Home Manager (Git, Zed, GNOME…)
├── Hardware.md                # 📋  Thông tin phần cứng chi tiết
└── README.md                  # 📖  File này
```

---

## 🧠 Kiến trúc & cách vận hành

### Flake — trung tâm điều phối

`flake.nix` là **entry point duy nhất** của toàn bộ hệ thống. Nó:

1. **Ghim phiên bản** `nixpkgs` (nhánh `nixos-unstable`) và `home-manager`
2. **Tổ hợp các module** (`configuration.nix` + `hardware-configuration.nix` + `home.nix`) thành một system configuration duy nhất tên là `lg`
3. Mỗi lần chạy `nixos-rebuild switch --flake .#lg`, NixOS đọc flake, giải toàn bộ dependency, build và áp dụng atomically

```
flake.nix
  ├── inputs: nixpkgs (unstable) + home-manager
  └── outputs:
        └── nixosConfigurations.lg
              ├── hardware-configuration.nix  (phần cứng)
              ├── configuration.nix           (hệ thống + packages)
              └── home-manager → home.nix     (cấu hình user)
```

---

### Home Manager — cấu hình cá nhân (hướng dẫn chi tiết)

Home Manager (HM) quản lý **mọi thứ trong `$HOME`** dưới dạng Nix module: dotfiles, GNOME settings, user services, user packages. Được nhúng vào flake nên **mỗi lần rebuild hệ thống là HM cũng được áp dụng đồng thời**.

#### Cấu trúc `home.nix` hiện tại

| Section | Cơ chế HM | Quản lý cái gì |
|---------|-----------|----------------|
| `programs.git` | Module có sẵn | `~/.config/git/config` |
| `xdg.configFile."zed/settings.json"` | File thô | `~/.config/zed/settings.json` |
| `dconf.settings` | Giao diện GNOME | `dconf` database (nhị phân) |

#### 🛠 Ví dụ 1 – Thêm công cụ dòng lệnh cho riêng user

Muốn thêm `bat` (cat đẹp) và `eza` (ls hiện đại) **chỉ cho user, không cài system-wide**:

```nix
# home.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    bat          # cat with syntax highlighting
    eza          # ls replacement with icons
    fd           # find replacement
    jq           # JSON processor
  ];
}
```

Sau rebuild, `bat`, `eza`, `fd`, `jq` có sẵn trong terminal của user `nqnhovn`.

#### 🛠 Ví dụ 2 – Thêm dotfile (`~/.vimrc`, `~/.tmux.conf`)

Dùng `xdg.configFile` hoặc `home.file`:

```nix
# home.nix
{
  # Cách 1: File trong XDG_CONFIG_HOME (~/.config)
  xdg.configFile."nvim/init.lua".text = ''
    vim.opt.number = true
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
  '';

  # Cách 2: File ở vị trí bất kỳ trong $HOME
  home.file.".tmux.conf".text = ''
    set -g default-terminal "screen-256color"
    set -g mouse on
    set -g history-limit 50000
  '';

  # Cách 3: Copy nguyên file từ thư mục config
  home.file.".my-secret".source = ./secret-file;
}
```

> 💡 Dùng `''` (2 dấu nháy đơn) để viết multi-line string không cần escape `"` hay `\n`.

#### 🛠 Ví dụ 3 – Đổi theme/setting GNOME qua dconf

```nix
# home.nix
dconf.settings = {
  # Đổi theme sang dark
  "org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Adwaita-dark";
  };

  # Tắt animation để nhẹ máy
  "org/gnome/desktop/interface" = {
    enable-animations = false;
  };

  # Thêm phím tắt mở terminal
  "org/gnome/settings-daemon/plugins/media-keys" = {
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    ];
  };
}
```

> 🔍 **Mẹo tra cứu key dconf:** Mở terminal chạy `dconf watch /`, sau đó thay đổi setting qua GUI — key sẽ hiện ra ngay lập tức. Copy key đó vào `home.nix`.

#### 🛠 Ví dụ 4 – Thêm user service (systemd)

```nix
# home.nix
{
  systemd.user.services.syncthing = {
    Unit.Description = "Syncthing file sync";
    Service.ExecStart = "${pkgs.syncthing}/bin/syncthing -no-browser";
    Install.WantedBy = [ "default.target" ];
  };
}
```

Sau rebuild, service chạy dưới quyền user:

```bash
systemctl --user status syncthing
systemctl --user restart syncthing
```

#### 🛠 Ví dụ 5 – Cấu hình một program có module sẵn

Nhiều chương trình phổ biến đã có HM module. Tra cứu tại [home-manager-options](https://home-manager-options.nix-community.org/):

```nix
# home.nix
{
  programs = {
    ssh.enable = true;             # Tự sinh ~/.ssh/config
    firefox.enable = true;         # Quản lý Firefox profile
    vscode.enable = true;          # Quản lý VS Code settings
    fzf.enable = true;             # Fuzzy finder
    zoxide.enable = true;          # z replacement, smarter cd
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
```

#### 🔄 Luồng rebuild khi sửa `home.nix`

```
Sửa home.nix → git add . → sudo nixos-rebuild switch --flake .#lg
                                                    ↓
                              NixOS build toàn bộ hệ thống
                                                    ↓
                         Home Manager activation chạy
                                                    ↓
                    ️Dotfiles được symlink, dconf được ghi
                                                    ↓
                          Có hiệu lực ngay lập tức
```

#### ⚡ Test nhanh không cần rebuild toàn bộ

```bash
# Chỉ build và kích hoạt riêng Home Manager
home-manager switch --flake ~/.config/nixos/#lg
```

> ⚠️ Lệnh này chỉ áp dụng cấu hình user, không đụng đến hệ thống (kernel, services…).

#### 🔍 Kiểm tra Home Manager đã sinh ra gì

```bash
# Xem tất cả thế hệ HM đã kích hoạt
home-manager generations

# Xem activation script đã chạy gì (log)
journalctl -u home-manager-nqnhovn.service

# Kiểm tra file cụ thể được HM quản lý (sẽ là symlink vào /nix/store)
readlink ~/.config/git/config
readlink ~/.config/zed/settings.json
```

---

### Devbox + Direnv — môi trường phát triển theo dự án

**Triết lý:** Không cài PHP, Go, Node.js system-wide. Mỗi dự án tự khai báo dependency riêng.

```
Dự án PHP (Laravel)           Dự án Go                   Dự án Vue 3
├── devbox.json                ├── devbox.json             ├── devbox.json
│   ├── php 8.3               │   ├── go 1.23            │   ├── nodejs 22
│   ├── composer              │   └── gopls              │   ├── pnpm
│   └── mysql-client          │                           │   └── vue-language-server
├── .envrc                     ├── .envrc                  ├── .envrc
│   (direnv auto-load)        │   (direnv auto-load)     │   (direnv auto-load)
```

**Luồng hoạt động:**

1. `cd` vào thư mục dự án → direnv tự phát hiện `.envrc`
2. `.envrc` gọi `devbox shell` hoặc `use devbox`
3. Devbox tạo shell riêng với đúng phiên bản PHP/Go/Node đã khai báo
4. Rời khỏi thư mục → môi trường tự hủy, shell về trạng thái gốc

### Distrobox — container Linux cho toolchain đặc thù

Khi cần môi trường **full Linux distro** (ví dụ: cần `apt`, legacy toolchain, hoặc test trên Ubuntu):

```bash
distrobox create --name ubuntu-dev --image ubuntu:24.04
distrobox enter ubuntu-dev
```

### Podman — database & container runtime

Podman thay thế Docker, hỗ trợ `docker-compose` qua alias `podman-compose`. Dùng cho MySQL, PostgreSQL:

```bash
# Chạy MySQL
podman run -d --name mysql-dev -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8

# Hoặc dùng compose
podman-compose up -d
```

---

## ⌨️ Zsh Aliases

### Điều hướng
| Alias | Lệnh |
|-------|------|
| `ll` | `ls -alF` |
| `la` | `ls -A` |
| `l` | `ls -CF` |
| `..` | `cd ..` |
| `...` | `cd ../..` |

### NixOS
| Alias | Lệnh |
|-------|------|
| `update` | `noglob sudo nixos-rebuild switch --flake ~/.config/nixos/#lg` |
| `build "message"` | `git add . && git commit -m "message" && sudo NIXOS_LABEL="slug" nixos-rebuild switch` |
| `clean` | `sudo nix-collect-garbage -d` |

### Git
| Alias | Lệnh |
|-------|------|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc "msg"` | `git commit -m "msg"` |
| `gp` | `git push` |
| `gl` | `git log --oneline --graph --all` |
| `gd` | `git diff` |

### Container
| Alias | Lệnh |
|-------|------|
| `d` | `podman` |
| `dco` | `podman-compose` |

### Dev
| Alias | Lệnh |
|-------|------|
| `dev` | `devbox` |
| `nrs` | `npm run serve` |
| `nrd` | `npm run dev` |
| `nrw` | `npm run watch` |
| `v` | `vim` |

### Oh-My-Zsh Plugins
| Plugin | Chức năng |
|--------|-----------|
| `git` | Aliases + completions Git |
| `sudo` | `Esc` `Esc` để thêm `sudo` vào đầu dòng |
| `docker` / `docker-compose` | Completions cho Podman/Docker |
| `fzf` | Tìm kiếm fuzzy (`Ctrl+T`, `Ctrl+R`) |
| `z` | Nhảy thư mục theo tần suất truy cập |
| `extract` | `x file.zip` — giải nén mọi định dạng |
| `composer` / `npm` / `golang` / `pip` | Aliases & completions cho từng ngôn ngữ |
| `history-substring-search` | Gõ một phần lệnh cũ → `↑` để tìm |

---

## 🔋 Tối ưu pin

### Kernel
| Tham số | Tác dụng |
|---------|----------|
| `i915.enable_fbc=1` | Intel Framebuffer Compression — tiết kiệm ~0.5W |
| `i915.enable_psr=1` | Panel Self Refresh — tắt refresh khi màn hình tĩnh |

### TLP (15+ thiết lập)

| Hạng mục | Trên sạc | Trên pin |
|----------|----------|----------|
| CPU Governor | `performance` | `powersave` |
| CPU Energy Policy | `balance_performance` | `power` |
| CPU Boost | Bật | **Tắt** |
| CPU Max Perf | 100% | **60%** |
| PCIe ASPM | `default` | `powersupersave` |
| Wi-Fi Power Save | Tắt | Bật |
| USB Autosuspend | — | Bật |
| Sound Power Save | Tắt | Bật |
| Intel GPU Freq | Mặc định | 300–900 MHz |
| NVMe PS Mode | — | `lowest` |

### NVIDIA
- GPU NVIDIA **tắt hoàn toàn** khi không dùng (PRIME offload)
- Chỉ bật khi chạy ứng dụng với `__NV_PRIME_RENDER_OFFLOAD=1`

### Tiết kiệm khác
- **Bluetooth**: KHÔNG tự bật khi khởi động
- **thermald**: Giảm nhiệt, giảm quạt, giảm tiêu thụ
- **powertop**: Auto-tune thiết bị khi khởi động
- **Suspend-then-Hibernate**: Gập máy → ngủ 30 phút → tự động ngủ đông

---

## 🪟 GNOME Desktop

| Tính năng | Cấu hình |
|-----------|----------|
| Nút cửa sổ | `appmenu:minimize,maximize,close` |
| Fractional Scaling | Bật (HiDPI) |
| Extensions | Caffeine (giữ màn hình sáng), AppIndicator (tray icon) |
| Ứng dụng đã gỡ | GNOME Tour, Epiphany, Geary, Totem, GNOME Music, Games… |

---

## 📝 Zed Editor

```
┌────────────────────┬──────────────────────┐
│                    │                      │
│   Project Panel    │    Editor Area       │
│   (File Explorer)  │                      │
│   DOCK: LEFT       │                      │
│   Width: 280px     │                      │
│                    │                      │
│                    │                      │
└────────────────────┴──────────────────────┘
                                          ┌──────────────────────┐
                                          │   AI Assistant       │
                                          │   (Agent Panel)      │
                                          │   DOCK: RIGHT        │
                                          │   Width: 420px       │
                                          └──────────────────────┘
```

Language servers được cấu hình sẵn:
- **Go**: `gopls`
- **Vue.js**: `vue-language-server` + `tailwindcss-language-server`
- **PHP**: `intelephense`
- **TypeScript/JavaScript**: `typescript-language-server` + `tailwindcss-language-server`

> ⚠️ Language servers cần được cài trong từng dự án qua **devbox**, không cài system-wide.

---

## 🚀 Lệnh thường dùng

```bash
# Cập nhật toàn bộ hệ thống
update

# Build: git add . → git commit → nixos-rebuild (label từ commit message)
build "Add new config"  # commit="Add new config", label="add-new-config"

# Dọn rác Nix (giải phóng disk)
clean

# Cập nhật flake.lock lên phiên bản mới nhất
cd ~/.config/nixos && nix flake update && update

# Xem các thế hệ (generation) đã build
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Quay về thế hệ trước nếu lỗi
noglob sudo nixos-rebuild switch --rollback

# Chỉ rebuild Home Manager (test nhanh, không đụng hệ thống)
home-manager switch --flake ~/.config/nixos/#lg

# Kiểm tra trạng thái pin
sudo tlp-stat -b
sudo powertop

# Chạy app bằng GPU NVIDIA
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia tên_app

# Kiểm tra GPU nào đang dùng
glxinfo | grep "OpenGL renderer"
```

---

## 🐛 Khắc phục sự cố

| Vấn đề | Giải pháp |
|--------|-----------|
| `zsh: bad pattern: …#lg` | Đã sửa bằng `noglob` trong alias — rebuild lại là được |
| `cp: cannot create …/_docker: Permission denied` | `sudo chown -R nqnhovn:users ~/.cache/oh-my-zsh` |
| Treo bàn phím sau suspend | Đã gỡ `pcie_aspm=force`, `mem_sleep_default=deep`, `nvme.noacpi=1` khỏi kernel params |
| `nodePackages has been removed` | Không dùng `nodePackages.*` nữa — language server cài qua devbox |
| Build báo `Git tree is dirty` | `cd ~/.config/nixos && git add .` trước khi rebuild |
| Không vào được GNOME sau rebuild | `noglob sudo nixos-rebuild switch --rollback` |

---

## 📐 Sơ đồ tổng thể

```
┌─────────────────────────────────────────────────────────────┐
│                        flake.nix                            │
│                  (Entry Point duy nhất)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────┐  ┌──────────────────────────────┐ │
│  │ hardware-config.nix │  │   configuration.nix          │ │
│  │ (phần cứng - auto)  │  │   • systemPackages           │ │
│  │ • partition         │  │   • zsh + oh-my-zsh          │ │
│  │ • kernel modules    │  │   • podman                   │ │
│  └─────────────────────┘  │   • TLP + thermald + pwr-top │ │
│                            │   • NVIDIA PRIME offload     │ │
│  ┌─────────────────────┐  │   • GNOME + GDM + Wayland    │ │
│  │     home.nix        │  │   • Bluetooth (off at boot)  │ │
│  │  (Home Manager)     │  │   • Fcitx5 + Unikey          │ │
│  │  • Git config       │  └──────────────────────────────┘ │
│  │  • Zed Editor       │                                    │
│  │  • GNOME dconf      │                                    │
│  │  • User packages    │                                    │
│  │  • User services    │                                    │
│  └─────────────────────┘                                    │
│                                                             │
│  Dev Tools (per-project qua devbox + direnv):               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───────────┐  │
│  │ PHP 8.3  │  │ Go 1.23  │  │ Node 22  │  │ Distrobox │  │
│  │ Composer │  │ gopls    │  │ pnpm     │  │ (full OS) │  │
│  └──────────┘  └──────────┘  └──────────┘  └───────────┘  │
│                                                             │
│  Databases (qua Podman):                                    │
│  ┌──────────┐  ┌────────────┐                              │
│  │ MySQL 8  │  │ PostgreSQL │                              │
│  └──────────┘  └────────────┘                              │
└─────────────────────────────────────────────────────────────┘
```
