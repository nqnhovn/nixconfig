# =====================================================================
# HOME/AICHAT.NIX — AICHAT CONFIG (DEEPSEEK + GEMINI + RAG ×3)
# 🔗 https://github.com/sigoden/aichat
# API keys được import từ secrets/aichat-keys.nix (đã gitignore)
# =====================================================================

{ pkgs, ... }:

let
  keys = import ../secrets/aichat-keys.nix;
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

  # ── Agent: general (tổng hợp) ───────────────────────────────────
  xdg.configFile."aichat/agents/general.md".text = ''
    ---
    model: gemini:gemini-2.5-flash
    rag: general
    description: Trợ lý tổng hợp — hệ thống, công cụ, thông tin cá nhân
    ---
    Bạn là trợ lý tổng hợp. Dùng RAG `general` để tra cứu thông tin cá nhân, hệ thống, công cụ.
    Trả lời ngắn gọn, tập trung giải pháp. Dùng tiếng Việt khi được hỏi tiếng Việt.
  '';

  # ── Agent: coding (lập trình) ───────────────────────────────────
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

  # ── Agent: mes-erp (quản lý sản xuất) ───────────────────────────
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

  home.packages = with pkgs; [ aichat ];
}
