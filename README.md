# ❄️ NixOS Configuration — LG Gram 17 (17U70N)

**NixOS 25.11 · GNOME 49 + Wayland · Intel i5-10210U + NVIDIA GTX 1650**

---

## 🚀 Quick Start

```bash
# Clone (hoặc tải ZIP) → extract vào ~/.config/nixos/
sudo bash ~/.config/nixos/initial.sh   # Bootstrap: detect hardware + tạo host + cài git
make switch                             # Build & áp dụng
```

`initial.sh` tự động quét phần cứng (`lspci -nn`, `lsblk`, `findmnt`) → tạo `hardware.nix` + `Hardware.md`.

---

## 🎮 Hàng ngày

```bash
make              # Dashboard tương tác (xem generations, chọn, xóa, reboot)
switch            # devenv script: rebuild + git sync + push
home              # devenv script: rebuild user config
gc                # Dọn rác
fmt               # Format code Nix
```

## ⌨️ Zsh Aliases

| Alias | Chức năng |
|-------|-----------|
| `build "msg"` | git add/commit (label=slug+git-hash) → rebuild → push |
| `sysupdate` | Auto-commit nếu dirty → rebuild → push |
| `appupdate` | Auto-commit nếu dirty → rebuild user config |
| `clean` | Liệt kê generations → chọn xóa → GC |
| `d` / `dco` | `podman` / `podman-compose` |
| `g` / `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | Git shortcuts |
| `dev` / `nrs` / `nrd` / `nrw` | `devenv` / `npm run …` |
| `z` | `zoxide` (cd thông minh) |
| `..` / `...` | `cd ..` / `cd ../..` |

---

## 🗂️ Cấu trúc dự án

```
~/.config/nixos/
├── flake.nix              # Entry point
├── devenv.nix             # Dev environment + scripts
├── Makefile               # Dashboard tương tác
├── initial.sh             # Bootstrap + auto hardware detect
├── .envrc                 # Direnv (PATH_add)
├── README.md
├── docs/                  # 📚 Tài liệu + templates
│   ├── devenv-direnv.md   # Devenv workflow
│   ├── podman-distrobox.md
│   ├── nixos-concepts.md
│   └── templates/         # devenv.nix + .envrc cho PHP/Go/Vue
├── hosts/lg/              # 🖥️  Per-machine
│   ├── default.nix
│   ├── hardware.nix       # Auto-generated
│   └── Hardware.md        # Hardware report
├── modules/system/        # ⚙️  7 modules
└── home/                  # 🏠  6 Home Manager modules
```

---

## 🔋 Pin & Hiệu năng

| Hạng mục | Trên sạc | Trên pin |
|----------|----------|----------|
| CPU Governor | `performance` | `powersave` |
| CPU Boost | Bật | **Tắt** |
| CPU Max | 100% | **60%** |
| Intel GPU | Mặc định | **300-650MHz** |
| NVMe | Mặc định | **lowest power** |
| PCIe ASPM | `default` | `powersupersave` |
| WiFi / USB / Sound | Tắt | Powersave ON |

- **NVIDIA**: PRIME offload — GPU tắt khi không dùng
- **Bluetooth**: KHÔNG tự bật khi khởi động
- **Boot**: systemd-boot + systemd initrd + Plymouth (logo LG)
- **Ngủ**: **Hibernate** (không suspend) — fix bàn phím LG Gram
- **Âm thanh**: Legacy HDA (SOF driver blacklisted)

---

## 🛠 Dev với Devenv

Không cài PHP/Go/Node system-wide. Mỗi dự án có `devenv.nix`:

```bash
mkdir my-project && cd my-project
cp ~/.config/nixos/docs/templates/devenv-php.nix devenv.nix
cp ~/.config/nixos/docs/templates/envrc .envrc
devenv up      # Khởi động MySQL/Postgres
```

Templates có sẵn: [PHP/Laravel](docs/templates/devenv-php.nix) · [Golang](docs/templates/devenv-go.nix) · [Vue 3](docs/templates/devenv-vue.nix)

---

## 🐛 Sự cố thường gặp

| Vấn đề | Giải pháp |
|--------|-----------|
| Bàn phím không hoạt động sau hibernate | Đã fix: `i8042` unbind/rebind |
| Không có âm thanh | Đã fix: blacklist SOF → legacy HDA |
| `nixd` lỗi trong Zed | `make home` để cài `nixd` |
| Build thất bại | `sudo nixos-rebuild switch --rollback` |

---

## 📚 Docs

- [Khái niệm NixOS](docs/nixos-concepts.md)
- [Devenv + Direnv](docs/devenv-direnv.md)
- [Podman + Distrobox](docs/podman-distrobox.md)
- [Templates](docs/templates/)
