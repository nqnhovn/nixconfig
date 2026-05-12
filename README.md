# ❄️ NixOS Configuration — LG Gram 17 (17U70N)

**NixOS 25.11 · GNOME 49 + Wayland · Intel i5-10210U + NVIDIA GTX 1650**

---

## 🚀 Quick Start

```bash
# Clone (hoặc tải ZIP) → extract vào ~/.config/nixos/
sudo bash ~/.config/nixos/initial.sh   # Bootstrap
make switch                             # Build & áp dụng
```

`initial.sh` sẽ cài git/make → khởi tạo repo → tạo hardware.nix → mở Dashboard.

---

## 🎮 Makefile

```bash
make              # Dashboard tương tác
make switch       # Rebuild toàn bộ hệ thống + git sync + push
make home         # Chỉ rebuild Home Manager
make gc           # Dọn rác Nix store
make update       # Cập nhật flake.lock
make storage      # Xem dung lượng
```

## ⌨️ Zsh Aliases

| Alias | Chức năng |
|-------|-----------|
| `build "msg"` | git add/commit → rebuild → push |
| `sysupdate` | Auto-commit nếu dirty → rebuild → push |
| `appupdate` | Auto-commit nếu dirty → home-manager switch |
| `clean` | Liệt kê generations → chọn xóa → GC |
| `d` / `dco` | `podman` / `podman-compose` |
| `g` / `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | Git shortcuts |
| `dev` / `nrs` / `nrd` / `nrw` | `devbox` / `npm run …` |
| `z` | `zoxide` (cd thông minh) |
| `v` | `vim` |
| `..` / `...` | `cd ..` / `cd ../..` |

| Phím tắt | Chức năng |
|----------|-----------|
| `Esc` `Esc` | Thêm `sudo` vào đầu dòng |
| `Ctrl+T` | FZF tìm file |
| `Ctrl+R` | FZF tìm lịch sử |

---

## 🗂️ Cấu trúc dự án

```
~/.config/nixos/
├── Makefile              # Build system + Dashboard
├── initial.sh            # Bootstrap script
├── flake.nix             # Entry point
├── README.md
├── docs/                 # 📚 Tài liệu
│   ├── nixos-concepts.md
│   ├── devbox-direnv.md
│   ├── podman-distrobox.md
│   └── templates/        # .envrc, devbox.json
├── hosts/lg/             # 🖥️  Per-machine
│   ├── default.nix
│   └── hardware.nix
├── modules/system/       # ⚙️  7 system modules
└── home/                 # 🏠  6 home-manager modules
```

---

## 🔋 Tính năng chính

| Hạng mục | Chi tiết |
|----------|----------|
| **Pin** | TLP 16+ thiết lập, CPU max 60% on bat, PCIe powersupersave |
| **Boot** | systemd-boot + systemd initrd + Plymouth (logo LG, không chữ) |
| **Ngủ** | **Chỉ Hibernate** (không suspend) — fix bàn phím LG Gram |
| **GPU** | NVIDIA PRIME offload — GPU tắt khi không dùng, chỉ 3W idle |
| **Bluetooth** | KHÔNG tự bật khi khởi động |
| **Shell** | Zsh + Starship + Autosuggestions + Syntax Highlighting |
| **Dev** | Devbox + Direnv + Distrobox + Podman |
| **Editor** | Zed (Agent right, Files left) + Vim |
| **Browser** | Firefox — tối ưu pin + bảo mật + DNS-over-HTTPS |
| **Tiếng Việt** | Fcitx5 + Unikey |

---

## 📦 Dev Workflow

Không cài PHP/Go/Node system-wide. Mỗi dự án có `devbox.json` + `.envrc` riêng:

```bash
cd my-laravel-project   # direnv tự kích hoạt devbox shell
php artisan serve       # PHP 8.3, Composer đã sẵn sàng
cd ..                   # Môi trường tự hủy
```

Database qua Podman:
```bash
podman run -d --name mysql -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 mysql:8
```

→ Xem chi tiết: [docs/devbox-direnv.md](docs/devbox-direnv.md), [docs/podman-distrobox.md](docs/podman-distrobox.md)

---

## 🔧 Khắc phục sự cố

| Vấn đề | Giải pháp |
|--------|-----------|
| Bàn phím không hoạt động sau hibernate | Đã fix: `i8042.reset` + unbind/rebind driver |
| `zsh: bad pattern` | Đã fix: `noglob` trong alias |
| Lỗi build | `sudo nixos-rebuild switch --rollback` |
| `Git tree is dirty` | `git add .` hoặc dùng `sysupdate` |

---

## 📚 Tài liệu

- [Khái niệm NixOS](docs/nixos-concepts.md)
- [Devbox + Direnv](docs/devbox-direnv.md)
- [Podman + Distrobox](docs/podman-distrobox.md)
- [Templates](docs/templates/)
