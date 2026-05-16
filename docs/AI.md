# 🤖 Hệ thống AI — Aichat + RAG + Agent

**Version:** 1.0 · **Date:** 2026-05-16

---

## Tổng quan

Hệ thống AI cá nhân tích hợp trong NixOS, gồm 3 lớp:

| Lớp | Công nghệ | Vai trò |
|------|-----------|---------|
| **Client** | [Aichat](https://github.com/sigoden/aichat) v0.30 | Chat CLI đa năng, 20+ provider |
| **RAG** ×3 | Document indexing | Kiến thức cá nhân, lập trình, sản xuất |
| **Agent** ×3 | Role + RAG + Prompt | Trợ lý chuyên biệt từng lĩnh vực |

### Provider

| Provider | Model | Loại | Dùng cho |
|----------|-------|------|----------|
| **Google Gemini** | `gemini-2.5-flash` | Free, nhanh | Chat hàng ngày, câu đơn giản |
| **Google Gemini** | `gemini-2.5-pro` | Mạnh nhất | Phân tích phức tạp |
| **DeepSeek** | `deepseek-chat` | Rẻ, tốt | Code, review, kỹ thuật |
| **DeepSeek** | `deepseek-reasoner` | Suy luận | Bài toán khó, logic |

---

## 🚀 Cách dùng hàng ngày

### Lệnh cơ bản

```bash
aichat                              # REPL — Gemini Flash (free)
aichat "câu hỏi"                    # Hỏi 1 lần
aichat -m deepseek:deepseek-chat    # Đổi model
aichat -f code.py                   # Chat về file
aichat --list-models                # Xem danh sách model
```

### Auto-route thông minh

```bash
ask "cách cài package NixOS?"       # → agent general + RAG
ask "viết hàm sort nhanh python"    # → deepseek-chat (code)
ask "kiến trúc MES cho nhà máy"     # → deepseek-reasoner (dài)
ask "hello"                         # → gemini flash (ngắn)
```

**Cơ chế tự động chọn model:**

| Điều kiện | Model được chọn |
|-----------|----------------|
| Câu < 200 ký tự, thông thường | `gemini:gemini-2.5-flash` |
| Chứa `code/fix/error/nix/python/bash/go/vue/debug` | `deepseek:deepseek-chat` |
| Dài > 200 ký tự | `deepseek:deepseek-reasoner` |
| Chứa `system/config/máy/laptop/generat/switch/boot/nixos` | Agent `general` + RAG |
| Model chính lỗi (hết tiền, timeout) | Fallback → `gemini:gemini-2.5-flash` |

### Gọi nhanh Agent

```bash
a general       # Trợ lý tổng hợp — tra RAG general
a coding        # Chuyên gia lập trình — tra RAG coding
a mes-erp       # Chuyên gia MES/ERP — tra RAG mes-erp
```

> `a` là alias của `aichat -a` (viết tắt của `--agent`)

---

## 📚 3 Bộ tri thức (RAG)

### 1. `general` — Kiến thức tổng hợp

```
~/.config/aichat/rags/general/
└── about.md    # Hệ thống, công cụ, thông tin cá nhân
```

**Nội dung:** Cấu hình NixOS, phần cứng LG Gram, công cụ hàng ngày, thông tin cá nhân.

**Dùng khi:** Hỏi về hệ thống, cấu hình máy, công cụ đang dùng.

### 2. `coding` — Kiến thức lập trình

```
~/.config/aichat/rags/coding/
├── patterns.md   # Best practices Nix/Python/Go/Vue/Bash
└── templates.md  # Devenv templates PHP/Go/Vue
```

**Dùng khi:** Code review, tạo dự án mới, hỏi về patterns, syntax.

### 3. `mes-erp` — Quản lý sản xuất

```
~/.config/aichat/rags/mes-erp/
└── overview.md   # MES + ERP concepts, integration
```

**Nội dung:**
- MES: Production Order, WIP Tracking, QC, OEE, Traceability
- ERP: Finance, Procurement, Inventory, Sales, HR, Planning
- Tích hợp MES-ERP: BOM, Routing, Work Center
- Công nghệ: PostgreSQL, Go/Python/C#, React/Vue, RabbitMQ/Kafka, OPC-UA/MQTT

**Dùng khi:** Tư vấn kiến trúc hệ thống sản xuất, tích hợp MES-ERP.

---

## 🤖 3 Agent

Mỗi Agent = Role (prompt) + RAG (kiến thức) + Model (mặc định).

### Agent `general`

```yaml
Model:  gemini:gemini-2.5-flash
RAG:    general
Alias:  a general
```

Trợ lý tổng hợp, hiểu rõ hệ thống và thói quen của Nho.

### Agent `coding`

```yaml
Model:  deepseek:deepseek-chat
RAG:    coding
Alias:  a coding
```

Chuyên gia lập trình, tra cứu patterns và templates từ RAG.

### Agent `mes-erp`

```yaml
Model:  deepseek:deepseek-chat
RAG:    mes-erp
Alias:  a mes-erp
```

Chuyên gia MES/ERP, tư vấn kiến trúc hệ thống sản xuất.

---

## 🔧 Cập nhật RAG

Thêm tài liệu mới vào thư mục RAG tương ứng, sau đó rebuild:

```bash
# Thêm file mới
cp new-doc.md ~/.config/aichat/rags/general/

# Rebuild RAG
aichat --rebuild-rag general
```

---

## 🗂️ Cấu trúc file

```
~/.config/aichat/
├── config.yaml              # Config chính (quản lý bởi home-manager)
├── models-override.yaml     # Models synced từ GitHub
├── agents/
│   ├── general.md           # Agent tổng hợp
│   ├── coding.md            # Agent lập trình
│   └── mes-erp.md           # Agent MES/ERP
├── rags/
│   ├── general/about.md
│   ├── coding/patterns.md
│   ├── coding/templates.md
│   └── mes-erp/overview.md
└── sessions/                # Lịch sử hội thoại
```

File Nix cấu hình: [`~/.config/nixos/home/aichat.nix`](../home/aichat.nix)

---

## 🐛 Sự cố thường gặp

| Vấn đề | Giải pháp |
|--------|-----------|
| `Unknown chat model` | `home-manager switch --flake .#lg` để cập nhật config |
| Model không hiện trong list | `aichat --sync-models` để đồng bộ models.yaml |
| DeepSeek hết tiền | `ask` tự fallback về Gemini, hoặc `aichat -m gemini:gemini-2.5-flash` |
| RAG không tìm thấy | `aichat --rebuild-rag <tên>` |
| Agent không hoạt động | Kiểm tra `~/.config/aichat/agents/` có file `.md` không |
