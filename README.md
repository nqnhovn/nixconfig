# ❄️ NixOS Configuration — LG Gram 17 (17U70N)

**NixOS 26.05 · GNOME 49 + Wayland · Intel i5-10210U + NVIDIA GTX 1650**

---

## 🚀 Quick Start

```bash
# Clone (hoặc tải ZIP) → extract vào ~/.config/nixos/
sudo bash ~/.config/nixos/initial.sh   # Bootstrap: detect hardware + tạo host + cài git
mgr                                     # Mở Dashboard quản lý generations
```

`initial.sh` tự động quét phần cứng (`lspci -nn`, `lsblk`, `findmnt`) → tạo `hardware.nix` + `Hardware.md`.

---

## 🎮 Hàng ngày

```bash
mgr               # 🖥️  Dashboard tương tác (Build, Delete, Switch, Home, Exit)
switch            # devenv script: nixos-rebuild switch
boot              # devenv script: build (không switch)
home              # devenv script: rebuild user config
gc                # Dọn rác nix store
fmt               # Format code Nix
```

## 🖥️ Dashboard (mgr / dashboard)

Dashboard TUI chuyên nghiệp quản lý generations:

- **B/b: Build** — Nhập Label → git add & commit → tạo gen → hỏi pin profile → git push
- **D/d: Delete** — Nhập ID gen → xóa + GC
- **S/s: Switch** — Rollback về gen bất kỳ
- **H/h: Home** — Rebuild Home Manager
- **E/e: Exit** — Thoát

---

## ⌨️ Zsh Aliases

| Alias | Chức năng |
|-------|-----------|
| `mgr` | Mở Dashboard quản lý generations |
| `build "msg"` | Quick rebuild với label (non-interactive) |
| `sysupdate` | Auto-commit nếu dirty → rebuild → push |
| `appupdate` | Auto-commit nếu dirty → rebuild user config |
| `gen` | Liệt kê generations |
| `clean` | GC + liệt kê generations |
| `d` / `dco` | `podman` / `podman-compose` |
| `g` / `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | Git shortcuts |
| `dev` / `devup` / `devdown` | `devenv` shortcuts |
| `z` | `zoxide` (cd thông minh) |
| `..` / `...` | `cd ..` / `cd ../..` |

---

## 🤖 AI & LLM

| Công cụ | Vai trò | Mô hình |
|---------|---------|---------|
| **Aichat** | Chat CLI với DeepSeek + Gemini | `deepseek-chat`, `gemini-2.5-flash` |
| **Ollama** | LLM local (CUDA accelerated) | `tinyllama`, `llama3.2:1b` |

Ollama chạy nhẹ trên laptop: 1 model loaded, keep-alive 5 phút, GPU NVIDIA GTX 1650.

```bash
aichat                        # Chat với AI (CLI)
ollama run tinyllama           # Chạy model local
ollama list                    # Danh sách model đã tải
```

---

## 🗂️ Cấu trúc dự án

```
~/.config/nixos/
├── flake.nix              # Entry point
├── devenv.nix             # Dev environment + scripts + Dashboard
├── initial.sh             # Bootstrap + auto hardware detect
├── .envrc                 # Direnv (PATH_add)
├── .gitignore
├── README.md
├── docs/                  # 📚 Tài liệu + templates
│   ├── nixos-concepts.md  # Khái niệm NixOS
│   ├── devenv-direnv.md   # Devenv workflow
│   ├── podman-distrobox.md
│   └── templates/         # devenv.nix + .envrc cho PHP/Go/Vue
├── hosts/lg/              # 🖥️  Per-machine
│   ├── default.nix
│   ├── hardware.nix       # Auto-generated
│   └── Hardware.md        # Hardware report
├── modules/system/        # ⚙️  7 modules
└── home/                  # 🏠  7 Home Manager modules
    ├── aichat.nix         # 🤖 Aichat config (DeepSeek + Gemini)
    ├── packages.nix
    ├── git.nix
    ├── firefox.nix
    ├── gnome.nix
    └── zed.nix
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

- **NVIDIA**: PRIME offload — GPU tắt khi không dùng (Ollama dùng CUDA khi cần)
- **Bluetooth**: KHÔNG tự bật khi khởi động
- **Boot**: systemd-boot + systemd initrd + Plymouth (logo LG)
- **Ngủ**: **Hibernate** (không suspend) — fix bàn phím LG Gram
- **Âm thanh**: PipeWire + Legacy HDA (SOF driver blacklisted)

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
| `nixd` lỗi trong Zed | `home` để cài `nixd` |
| Build thất bại | `sudo nixos-rebuild switch --rollback` |
| Ollama không có GPU | Kiểm tra `nvidia-smi`, service ollama |

---

## 📚 Docs

- [Khái niệm NixOS](docs/nixos-concepts.md)
- [Devenv + Direnv](docs/devenv-direnv.md)
- [Podman + Distrobox](docs/podman-distrobox.md)
- [Templates](docs/templates/)
