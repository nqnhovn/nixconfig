# 🐳 Podman + Distrobox — Container & Database

## Podman (thay thế Docker)

Podman đã được cấu hình `dockerCompat = true` → dùng lệnh `docker` như bình thường.

### Database

```bash
# MySQL
podman run -d --name mysql-dev \
  -e MYSQL_ROOT_PASSWORD=root \
  -p 3306:3306 \
  mysql:8

# PostgreSQL
podman run -d --name postgres-dev \
  -e POSTGRES_PASSWORD=root \
  -p 5432:5432 \
  postgres:16

# Quản lý
podman ps          # Liệt kê container đang chạy
podman stop NAME   # Dừng
podman start NAME  # Chạy lại
podman rm NAME     # Xóa
```

### docker-compose với Podman

```bash
podman-compose up -d      # Khởi động
podman-compose down       # Dừng + xóa
```

Có alias: `dco` → `podman-compose`, `d` → `podman`

## Distrobox

Tạo môi trường Linux đầy đủ trong container (có systemd, apt/dnf…).

```bash
# Tạo container Ubuntu
distrobox create --name ubuntu-dev --image ubuntu:24.04

# Vào container
distrobox enter ubuntu-dev

# Cài tool trong container
sudo apt install build-essential

# Xuất app ra host
distrobox-export --app firefox

# Liệt kê
distrobox list

# Xóa
distrobox rm ubuntu-dev
```
