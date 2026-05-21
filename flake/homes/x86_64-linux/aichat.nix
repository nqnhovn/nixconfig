# =====================================================================
# HOME/AICHAT.NIX — AICHAT CONFIG (DEEPSEEK + GEMINI + RAG ×3)
# 🔗 https://github.com/sigoden/aichat
# =====================================================================

{ pkgs, ... }:

let
  keys = import ../../../secrets/keys.nix;
in
{
  xdg.configFile."aichat/config.yaml" = {
    text = ''
      # ╔══════════════════════════════════════════════════════════════╗
      # ║  🤖 AICHAT — TRỢ LÝ AI CÁ NHÂN                              ║
      # ║  Model mặc định: gemini-2.5-flash (free)                    ║
      # ║  Alias: ask → auto-route | aichat -a → agent                ║
      # ╚══════════════════════════════════════════════════════════════╝

      model: gemini:gemini-2.5-flash
      temperature: 0.7
      save_session: true
      save: true
      highlight: true
      auto_copy: true
      keybindings: vi

      # ── Clients ─────────────────────────────────────────────────
      clients:
        - name: openai
          type: openai
          api_base: https://api.openai.com/v1
          api_key: ${keys.openai.key or ""}
          models:
            - name: gpt-4o
            - name: gpt-4o-mini
            - name: o1-preview
        - name: deepseek
          type: openai
          api_base: https://api.deepseek.com/v1
          api_key: ${keys.deepseek.key}
          models:
            - name: deepseek-chat
            - name: deepseek-reasoner
        - name: gemini
          type: gemini
          api_key: ${keys.gemini.key}
        - name: groq
          type: openai
          api_base: https://api.groq.com/openai/v1
          api_key: ${keys.groq.key or ""}
          models:
            - name: llama-4-maverick-17b-128e-instruct
            - name: mixtral-8x7b-32768
        - name: ollama
          type: ollama
          api_base: ${keys.ollama.url or "http://localhost:11434"}
          models:
            - name: ${keys.ollama.model or "qwen3:14b"}

      # ── RAG: 3 bộ tri thức ──────────────────────────────────────
      rags:
        general:
          model: gemini:gemini-2.5-flash
          top_k: 5
          documents:
            - ~/.config/aichat/rags/general/about.md
        coding:
          model: deepseek:deepseek-chat
          top_k: 5
          documents:
            - ~/.config/aichat/rags/coding/patterns.md
            - ~/.config/aichat/rags/coding/templates.md
        mes-erp:
          model: deepseek:deepseek-chat
          top_k: 5
          documents:
            - ~/.config/aichat/rags/mes-erp/overview.md
    '';
  };

  # ── Agent: general ──────────────────────────────────────────────
  xdg.configFile."aichat/agents/general.md".text = ''
    ---
    model: gemini:gemini-2.5-flash
    rag: general
    description: Trợ lý tổng hợp — hệ thống, công cụ, thông tin cá nhân
    ---
    Bạn là trợ lý tổng hợp. Dùng RAG `general` để tra cứu thông tin cá nhân, hệ thống, công cụ.
    Trả lời ngắn gọn, tập trung giải pháp. Dùng tiếng Việt khi được hỏi tiếng Việt.
  '';

  # ── Agent: coding ───────────────────────────────────────────────
  xdg.configFile."aichat/agents/coding.md".text = ''
    ---
    model: deepseek:deepseek-chat
    rag: coding
    description: Trợ lý lập trình — Nix, Python, Go, Vue, Bash
    ---
    Bạn là chuyên gia lập trình. Dùng RAG `coding` để tra cứu patterns, templates, best practices.
    Ưu tiên Nix/Python/Bash/Go/Vue. Code sạch, có comment, tối ưu.
    Nếu cần tạo dự án mới → gợi ý template từ RAG.
  '';

  # ── Agent: mes-erp ──────────────────────────────────────────────
  xdg.configFile."aichat/agents/mes-erp.md".text = ''
    ---
    model: deepseek:deepseek-chat
    rag: mes-erp
    description: Chuyên gia MES + ERP — quản lý sản xuất, tích hợp hệ thống
    ---
    Bạn là chuyên gia MES/ERP. Dùng RAG `mes-erp` để tra cứu kiến thức sản xuất.
    Am hiểu: MES (real-time tracking, OEE, QC, traceability), ERP (tài chính, kho, mua hàng, nhân sự).
    Công nghệ: PostgreSQL, Go/Python/C#, React/Vue, RabbitMQ/Kafka, OPC-UA/MQTT.
    Tư vấn kiến trúc, tích hợp, và best practices cho hệ thống sản xuất.
  '';

  # ── RAG Content: general/about.md ───────────────────────────────
  xdg.configFile."aichat/rags/general/about.md".text = ''
    # Thông tin hệ thống — NixOS LG Gram 17

    ## Phần cứng
    - **Máy**: LG Gram 17 (17U70N)
    - **CPU**: Intel i5-10210U (Comet Lake, 4C/8T)
    - **GPU**: Intel UHD Graphics + NVIDIA GTX 1650 (PRIME offload)
    - **RAM**: 16GB DDR4
    - **SSD**: NVMe

    ## Phần mềm
    - **OS**: NixOS 26.05 (Yarara)
    - **DE**: GNOME 49 + Wayland
    - **Editor**: Zed
    - **Shell**: Zsh + Starship
    - **Container**: Podman + Distrobox
    - **Dev env**: Devenv + Direnv

    ## AI Agent System
    - **Orchestrator**: Tự động chọn Agent dựa trên giai đoạn dự án
    - **5 Agent**: PlanAgent, DevAgent, DocAgent, TechAgent, CicdAgent
    - **Aichat**: DeepSeek + Gemini, 3 RAG sets
  '';

  # ── RAG Content: coding/patterns.md ─────────────────────────────
  xdg.configFile."aichat/rags/coding/patterns.md".text = ''
    # Coding Patterns & Best Practices

    ## Nix
    - Dùng `builtins.readFile` thay vì inline string dài
    - Module hóa: mỗi file < 100 dòng, mỗi module 1 trách nhiệm
    - Format bằng `nixpkgs-fmt`

    ## Git Workflow
    - Branch: `feature/`, `fix/`, `refactor/`, `docs/`, `chore/`
    - Commit: `<type>(<scope>): <subject>`
    - Pre-commit hooks: format + lint + secrets check

    ## Clean Code (Solo Coder)
    - Hàm < 30 dòng, File < 300 dòng
    - Đặt tên rõ ràng, không viết tắt
    - Comment "tại sao", không phải "cái gì"

    ## Shell Scripts
    - Luôn `set -euo pipefail`
    - Dùng `shellcheck`
    - Ưu tiên `[[` thay vì `[`
  '';

  home.packages = with pkgs; [ aichat ];
}
