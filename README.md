# ❄️ NixOS Configuration — Snowfall Lib · Multi-Host

**Multi-Host · Multi-Graphics · Multi-Output (ISO/VM/WSL/Docker)**

---

## 🚀 Quick Start

```bash
# Dành cho máy mới cài NixOS:
bash ~/.config/nixos/scripts/nixos-setup.sh   # Post-install wizard
nixos                                             # Mở Dashboard quản lý generations
```

---

## 🗂️ Cấu trúc dự án (Snowfall Lib)

```
~/.config/nixos/
├── flake.nix                    # Entry point (redirect → flake/flake.nix)
├── flake.lock
├── .gitignore
├── README.md
│
├── flake/                       # ❄️ Snowfall Lib core
│   ├── flake.nix                # Main flake: mkHost, mkISO builders
│   ├── lib/default.nix          # Helper library
│   ├── modules/nixos/           # ⚙️ 8 domain modules (generic)
│   │   ├── core/                # User, Nix settings, system packages
│   │   ├── boot/                # Bootloader, kernel, initrd, Plymouth
│   │   ├── graphics/            # 🎨 4 profiles + GNOME desktop
│   │   ├── power/               # 🔋 TLP, thermald, powertop
│   │   ├── network/             # NetworkManager, timezone
│   │   ├── services/            # Bluetooth, PipeWire, Podman, fcitx5
│   │   ├── shell/               # Zsh, Starship, direnv, zoxide
│   │   ├── i18n/                # 🌐 Locale deferral system
│   │   └── installer/           # 📀 ISO profiles (standard/minidev)
│   ├── homes/x86_64-linux/      # 🏠 Home Manager modules
│   ├── systems/x86_64-linux/    # 🖥️ Host-specific configs
│   ├── overlays/
│   └── packages/
│
├── secrets/                     # 🔐 Key management
│   ├── info.example.nix         # User info template (tracked)
│   ├── info.nix                 # User info thật (gitignored)
│   ├── keys.example.nix         # API keys template (tracked)
│   └── keys.nix                 # Key thật (gitignored)
│
├── scripts/                     # 🛠 Tiện ích
│   ├── nixos-setup.sh           # Post-install wizard (5 bước)
│   └── initproject.sh           # Khởi tạo dự án từ template
├── docs/                        # 📚 Tài liệu
└── devenv.nix                   # Dev environment
```

---

## 🎮 Hàng ngày

```bash
nixos               # 🖥️  Dashboard tương tác

# ── nh (nix-helper) shortcuts ─────────────────────────────────
nhs                 # Tìm package (nh search)
nhl                 # Liệt kê generations (nh list)
nhc                 # Dọn tất cả (nh clean all)
nho                 # Switch hệ thống (nh os switch)
nhh                 # Switch Home Manager (nh home switch)
nht                 # Test build (nh os test)
nhb                 # Build boot (nh os boot)

# ── ISO Build ────────────────────────────────────────────
iso-standard        # 🖥️  Build vnixos-standard.iso → ~/isofiles/
iso-minidev         # 🛠️  Build vnixos-minidev.iso → ~/isofiles/
```

## 🖥️ Dashboard (nixos / dashboard)

Dashboard TUI quản lý generations:

- **B/b: Build** — Nhập Label → git add & commit → tạo gen → hỏi pin profile → git push
- **D/d: Delete** — Nhập ID gen → xóa + GC
- **S/s: Switch** — Rollback về gen bất kỳ
- **H/h: Home** — Rebuild Home Manager
- **C/c: Clean** — Xóa tất cả gen, chỉ giữ N gen gần nhất
- **R/r: Reset** — Tạo profile mới, reset gen counter về 1
- **E/e: Exit** — Thoát

---

## 🎨 Graphics Profiles

| Profile        | GPU                               | Dùng cho              |
| -------------- | --------------------------------- | --------------------- |
| `nvidia-prime` | Intel iGPU + NVIDIA PRIME offload | Laptop hybrid         |
| `intel-only`   | Intel UHD / AMD (modesetting)     | Laptop tiết kiệm pin  |
| `vm-guest`     | virtio-gpu                        | QEMU/VirtualBox guest |
| `headless`     | Không GPU                         | VPS, server           |

---

## 📀 ISO Builds

```bash
iso-standard                # 🖥️  Build vnixos-standard.iso → ~/isofiles/
iso-minidev                 # 🛠️  Build vnixos-minidev.iso → ~/isofiles/

# Hoặc dùng nix build trực tiếp:
nix build .#vm-qcow2        # 🖴 QEMU image
nix build .#vm-vbox         # 📦 VirtualBox OVA
nix build .#wsl             # 🪟 WSL image
nix build .#amazon          # ☁️  EC2 image
nix build .#docker          # 🐳 Docker container
```

> 📁 Output ISO: `~/isofiles/vnixos-standard.iso` và `~/isofiles/vnixos-minidev.iso`

### 🚀 Post-install Setup Wizard

Sau khi cài NixOS từ ISO, chạy:

```bash
nixos-setup
```

Wizard 5 bước:

1. 🔍 **Detect GPU** — tự chọn profile + lấy PCI bus IDs chính xác
2. 📦 **Chọn profile** — Standard / Developer / Minimal
3. 🌐 **Chọn locale + input method** — fcitx5-unikey / fcitx5-english / mozc / chinese
4. ⚙️ **Tạo host config + rebuild**
5. 🔑 **Thiết lập GitHub SSH key** (dành cho Developer profile)

---

## 🔋 Pin & Hiệu năng (máy laptop)

| Hạng mục        | Trên sạc      | Trên pin         |
| --------------- | ------------- | ---------------- |
| CPU Governor    | `performance` | `powersave`      |
| CPU Boost       | Bật           | **Tắt**          |
| PCIe ASPM       | `default`     | `powersupersave` |
| NVMe            | Mặc định      | `lowest power`   |
| USB Autosuspend | Tắt           | Bật              |

---

## 🔧 Cấu hình máy mới

1. **Copy secrets:**

   ```bash
   cp secrets/info.example.nix secrets/info.nix   # Điền user info
   cp secrets/keys.example.nix secrets/keys.nix   # Điền API keys
   ```

2. **Chạy setup:**

   ```bash
   bash scripts/nixos-setup.sh
   ```

3. **Build:**
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

---

## 📚 Docs

- [Khái niệm NixOS](docs/nixos-concepts.md)
- [Devenv + Direnv](docs/devenv-direnv.md)
- [Podman + Distrobox](docs/podman-distrobox.md)
- [Aichat AI Setup](docs/aichat-setup.md)
- [Zed AI Agent System](docs/zed-agent-system.md)
- [Templates](docs/templates/)
