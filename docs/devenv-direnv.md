# 🛠 Devenv + Direnv — Môi trường phát triển

## Triết lý

Không cài PHP, Go, Node.js system-wide. Mỗi dự án có `devenv.nix` riêng, tự động kích hoạt qua direnv khi `cd` vào.

## Quy trình khởi tạo dự án mới

```bash
# 1. Tạo thư mục
mkdir my-project && cd my-project

# 2. Copy template
cp ~/.config/nixos/docs/templates/devenv-php.nix devenv.nix
cp ~/.config/nixos/docs/templates/envrc .envrc

# 3. Cho phép direnv (1 lần)
direnv allow

# 4. Khởi động services (MySQL, Postgres)
devenv up
```

## Cấu trúc dự án

```
my-project/
├── devenv.nix       # Khai báo languages + services + scripts
├── devenv.lock      # Khoá phiên bản (tự sinh)
├── .envrc           # Auto-load khi cd vào
└── src/
```

## Devenv scripts

Scripts khai báo trong `devenv.nix` tự động có trong PATH:

```nix
scripts.serve.exec = "php artisan serve";
scripts.test.exec = "go test ./...";
scripts.dev.exec = "pnpm dev";
```

```bash
serve       # Chạy web server
test        # Chạy test
dev         # Dev server
```

## Services (Database)

Devenv quản lý database trực tiếp, không cần container:

```nix
services.mysql.enable = true;
services.postgres.enable = true;
```

```bash
devenv up          # Khởi động tất cả services
devenv up -d       # Background mode
devenv up --detach
```

## Direnv — auto-load môi trường

Khi `cd` vào thư mục có `.envrc`, direnv tự kích hoạt.  
Khi `cd` ra ngoài, môi trường tự hủy.

```bash
direnv allow   # Cho phép .envrc (chạy 1 lần)
direnv reload  # Load lại sau khi sửa devenv.nix
```

## Templates có sẵn

| Template | Stack |
|----------|-------|
| `devenv-php.nix` | PHP 8.3 + Composer + MySQL + Node.js |
| `devenv-go.nix` | Go 1.23 + gopls + golangci-lint + PostgreSQL |
| `devenv-vue.nix` | Node 22 + pnpm + TypeScript + PostgreSQL |
