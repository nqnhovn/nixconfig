# ❄️ NixOS Configuration — Snowfall Lib · Multi-Host

**NixOS 26.05 · GNOME 49 + Wayland · Intel i5-10210U + NVIDIA GTX 1650**

---

## 🚀 Quick Start

```bash
# Clone (hoặc tải ZIP) → extract vào ~/.config/nixos/
sudo bash ~/.config/nixos/initial.sh   # Bootstrap: detect hardware + tạo host + cài git
nixos                                     # Mở Dashboard quản lý generations
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
│   ├── modules/nixos/           # ⚙️ 8 domain modules
│   │   ├── core/                # User, Nix settings, system packages
│   │   ├── boot/                # Bootloader, kernel, initrd, Plymouth
│   │   ├── graphics/            # 🎨 4 profiles + GNOME desktop
│   │   │   ├── profiles/        # intel-only, nvidia-prime, vm-guest, headless
│   │   │   └── desktop/gnome.nix
│   │   ├── power/               # 🔋 TLP, thermald, hibernate
│   │   ├── network/             # NetworkManager, timezone
│   │   ├── services/            # Bluetooth, PipeWire, Podman, fcitx5
│   │   ├── shell/               # Zsh, Starship, direnv, zoxide + nh aliases
│   │   ├── i18n/                # 🌐 Locale deferral system
│   │   └── installer/           # 📀 ISO profiles (standard/minimal)
│   ├── homes/x86_64-linux/      # 🏠 8 Home Manager modules
│   ├── systems/x86_64-linux/    # 🖥️ 3 hosts
│   │   ├── lg/                  # LG Gram 17 (nvidia-prime)
│   │   ├── vm/                  # VM dev (vm-guest)
│   │   └── vps/                 # VPS (headless)
│   ├── overlays/
│   └── packages/
│
├── secrets/                     # 🔐 Key management
│   ├── keys.example.nix         # Template (tracked)
│   └── keys.nix                 # Key thật (gitignored)
│
├── docs/                        # 📚 Tài liệu
│   ├── zed-agents/
│   │   ├── plan/                # 📋 Scrum templates
├── scripts/                     # 🛠 Tiện ích
├── devenv.nix                   # Dev environment
└── initial.sh                   # Bootstrap
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

# ── Legacy ────────────────────────────────────────────────────
switch            # devenv script: nixos-rebuild switch
boot              # devenv script: build (không switch)
home              # devenv script: rebuild user config
gc                # Dọn rác nix store
fmt               # Format code Nix
```

## 🖥️ Dashboard (nixos / dashboard)

Dashboard TUI chuyên nghiệp quản lý generations:

- **B/b: Build** — Nhập Label → git add & commit → tạo gen → hỏi pin profile → git push
- **D/d: Delete** — Nhập ID gen → xóa + GC
- **S/s: Switch** — Rollback về gen bất kỳ + git checkout commit tương ứng
- **H/h: Home** — Rebuild Home Manager
- **C/c: Clean** — Xóa tất cả gen, chỉ giữ N gen gần nhất
- **R/r: Reset** — Tạo profile mới, reset gen counter về 1
- **E/e: Exit** — Thoát

---

## 🎨 Graphics Profiles

| Profile        | GPU                              | Dùng cho                   |
| -------------- | -------------------------------- | -------------------------- |
| `nvidia-prime` | Intel UHD + NVIDIA PRIME offload | LG Gram, laptop hybrid     |
| `intel-only`   | Intel UHD (tiết kiệm pin)        | Laptop trên pin, ultrabook |
| `vm-guest`     | virtio-gpu                       | QEMU/VirtualBox guest      |
| `headless`     | Không GPU                        | VPS, server                |

---

## 📀 ISO Builds

```bash
nix build .#iso-standard    # 🖥️  GNOME + Calamares + nh + App Store
nix build .#iso-minimal     # ⚡ Server/headless
nix build .#vm-qcow2        # 🖴 QEMU image
nix build .#vm-vbox         # 📦 VirtualBox OVA
nix build .#wsl             # 🪟 WSL image
nix build .#amazon          # ☁️  EC2 image
nix build .#docker          # 🐳 Docker container
```

---

## 🔋 Pin & Hiệu năng

| Hạng mục           | Trên sạc      | Trên pin         |
| ------------------ | ------------- | ---------------- |
| CPU Governor       | `performance` | `powersave`      |
| CPU Boost          | Bật           | **Tắt**          |
| CPU Max            | 100%          | **60%**          |
| Intel GPU          | Mặc định      | **300-650MHz**   |
| NVMe               | Mặc định      | **lowest power** |
| PCIe ASPM          | `default`     | `powersupersave` |
| WiFi / USB / Sound | Tắt           | Powersave ON     |

- **NVIDIA**: PRIME offload — GPU tắt khi không dùng
- **Bluetooth**: KHÔNG tự bật khi khởi động
- **Boot**: systemd-boot + systemd initrd + Plymouth (logo LG)
- **Ngủ**: **Hibernate** (không suspend) — fix bàn phím LG Gram
- **Âm thanh**: PipeWire + Legacy HDA (SOF driver blacklisted)

---

## 🤖 AI & LLM

### Aichat

Chat CLI đa năng, hỗ trợ 20+ provider:

| Provider          | Model               | Dùng cho                    |
| ----------------- | ------------------- | --------------------------- |
| **DeepSeek**      | `deepseek-chat`     | Chat hàng ngày, code review |
| **DeepSeek**      | `deepseek-reasoner` | Suy luận phức tạp           |
| **Google Gemini** | `gemini-2.5-flash`  | Nhanh, context 1M token     |
| **Google Gemini** | `gemini-2.5-pro`    | Mạnh nhất của Google        |
| **OpenAI**        | `gpt-4o`            | Nhận diện hình ảnh          |
| **Groq**          | `llama-4-maverick`  | Inference siêu nhanh        |
| **Ollama**        | `qwen3:14b`         | Local LLM offline           |

```bash
aichat                                 # Chat CLI - mặc định Gemini
aichat -m deepseek:deepseek-chat       # Dùng DeepSeek
aichat -f code.py                      # Chat về file code
aichat --list-models                   # Danh sách model
```

---

## 🛠 Dev với Devenv

Không cài PHP/Go/Node system-wide. Mỗi dự án có `devenv.nix`:

```bash
mkdir my-project && cd my-project
cp ~/.config/nixos/docs/templates/devenv-php.nix devenv.nix
cp ~/.config/nixos/docs/templates/envrc .envrc
devenv up      # Khởi động MySQL/Postgres
```

Templates: [PHP/Laravel](docs/templates/devenv-php.nix) · [Golang](docs/templates/devenv-go.nix) · [Vue 3](docs/templates/devenv-vue.nix)

---

## 🐛 Sự cố thường gặp

| Vấn đề                                 | Giải pháp                                   |
| -------------------------------------- | ------------------------------------------- |
| Bàn phím không hoạt động sau hibernate | Đã fix: `i8042` unbind/rebind               |
| Không có âm thanh                      | Đã fix: blacklist SOF → legacy HDA          |
| `nixd` lỗi trong Zed                   | `home` để cài `nixd`                        |
| Build thất bại                         | `sudo nixos-rebuild switch --rollback`      |
| Locale build lâu                       | Đã fix: locale deferral (en_US → vi_VN sau) |

---

## 📚 Docs

- [Khái niệm NixOS](docs/nixos-concepts.md)
- [Devenv + Direnv](docs/devenv-direnv.md)
- [Podman + Distrobox](docs/podman-distrobox.md)
- [Templates](docs/templates/)
