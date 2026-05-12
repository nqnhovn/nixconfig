# 🔬 Khái niệm cốt lõi NixOS

## Derivation (.drv)
Đơn vị build cơ bản. Mỗi package, config file, service đều là một derivation. Nix build derivation → tạo ra output trong `/nix/store/`.

## Nix Store (`/nix/store/`)
Thư mục bất biến chứa MỌI THỨ. Mỗi file có hash SHA256 trong tên:
```
/nix/store/abc123...-firefox-135.0/
```
Hai phiên bản khác nhau → hai path khác nhau → không xung đột.

## Generation (Thế hệ)
Mỗi lần `nixos-rebuild switch`, NixOS tạo một generation mới:
- Boot entry mới trong systemd-boot
- Symlink `/run/current-system` → generation mới
- Rollback: chọn generation cũ khi boot

```bash
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
```

## Profile
Tập hợp các generation được đặt tên. Cho phép ghim cấu hình ổn định:
```bash
sudo nixos-rebuild switch --profile-name stable
```

## Garbage Collection (GC)
Xóa generations cũ + dọn /nix/store:
```bash
sudo nix-collect-garbage -d    # Xóa mọi generation không dùng
sudo nix-collect-garbage --delete-older-than 7d  # Giữ 7 ngày
```

## Flake
Cơ chế quản lý dependency hiện đại:
- `flake.nix`: khai báo inputs + outputs
- `flake.lock`: ghim phiên bản chính xác (như package-lock.json)
- Reproducible: cùng lock file → cùng kết quả build

## Home Manager
Quản lý dotfiles & user config như NixOS module:
- `programs.git.enable = true` → tự sinh `~/.config/git/config`
- `dconf.settings` → tự cấu hình GNOME
- Mỗi lần `home-manager switch` tạo một generation riêng
