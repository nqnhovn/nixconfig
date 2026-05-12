# 🛠 Devbox + Direnv — Môi trường phát triển

## Triết lý

Không cài PHP, Go, Node.js system-wide. Mỗi dự án tự khai báo dependency.

## Quy trình khởi tạo dự án mới

```bash
# 1. Tạo thư mục dự án
mkdir my-project && cd my-project

# 2. Khởi tạo devbox
devbox init

# 3. Thêm packages
devbox add php@8.3 composer    # PHP
devbox add go@1.23 gopls       # Golang
devbox add nodejs@22 pnpm      # Vue/Node

# 4. Tạo .envrc
cp ~/.config/nixos/docs/templates/envrc .envrc

# 5. Cho phép direnv
direnv allow

# 6. Vào shell dev
devbox shell
```

## Cấu trúc dự án

```
my-project/
├── devbox.json       # Khai báo dependency
├── devbox.lock       # Khoá phiên bản
├── .envrc            # Auto-load khi cd vào
└── src/
```

## Lệnh thường dùng

```bash
devbox shell              # Vào môi trường dev
devbox run npm run serve  # Chạy script
devbox add package        # Thêm package
devbox rm package         # Gỡ package
devbox update             # Cập nhật packages
devbox list               # Liệt kê packages
devbox generate direnv    # Tạo .envrc tự động
```

## Direnv — auto-load môi trường

Khi `cd` vào thư mục có `.envrc`, direnv tự kích hoạt devbox shell.
Khi `cd` ra ngoài, môi trường tự hủy.

```bash
direnv allow   # Cho phép .envrc (chạy 1 lần)
direnv deny    # Từ chối .envrc
direnv reload  # Load lại sau khi sửa .envrc
```
