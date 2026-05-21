# =====================================================================
# SECRETS/KEYS.EXAMPLE.NIX — MẪU KEY TẬP TRUNG (KHÔNG CHỨA KEY THẬT)
# =====================================================================
# 🔐 Đây là template — được git tracked, chứa placeholder
#
# Cách dùng:
#   1. Copy file này thành keys.nix:
#        cp secrets/keys.example.nix secrets/keys.nix
#   2. Điền key thật của bạn vào keys.nix
#   3. Hoặc chạy initial.sh để tự động tạo:
#        sudo bash initial.sh
#
# ⚠️  secrets/keys.nix ĐÃ ĐƯỢC GITIGNORE — KHÔNG BAO GIỜ BỊ COMMIT!
# =====================================================================

{
  # ── AI / LLM Providers ──────────────────────────────────────────
  # Dùng cho aichat, Zed AI Panel, code review, agents
  deepseek.key  = "sk-your-deepseek-api-key";        # https://platform.deepseek.com
  gemini.key    = "your-gemini-api-key";             # https://aistudio.google.com/apikey
  openai.key    = "sk-your-openai-api-key";          # https://platform.openai.com
  claude.key    = "sk-ant-your-claude-api-key";      # https://console.anthropic.com
  groq.key      = "gsk_your-groq-api-key";           # https://console.groq.com (LPU inference)
  ollama.url    = "http://localhost:11434";           # Local LLM (không cần key)
  ollama.model  = "qwen3:14b";                       # Model local mặc định

  # ── Git / Forge ──────────────────────────────────────────────────
  github.user   = "your-github-username";            # GitHub username
  github.email  = "your-email@example.com";          # Email GitHub
  github.token  = "ghp_your-github-token";           # https://github.com/settings/tokens (repo+workflow)
  github.sshKey = ''
    -----BEGIN OPENSSH PRIVATE KEY-----
    YOUR_GITHUB_SSH_PRIVATE_KEY_HERE
    -----END OPENSSH PRIVATE KEY-----
  '';                                                # ~/.ssh/id_ed25519 nội dung (cho initial.sh)
  gitlab.token  = "glpat-your-gitlab-token";         # https://gitlab.com/-/profile/personal_access_tokens

  # ── Binary Cache ─────────────────────────────────────────────────
  cachix.name   = "your-cachix-cache-name";          # Tên binary cache của bạn
  cachix.token  = "your-cachix-auth-token";          # https://app.cachix.org/personal-auth-token

  # ── Network / VPN / Remote ───────────────────────────────────────
  tailscale.key = "tskey-auth-your-tailscale-key";   # https://login.tailscale.com/admin/settings/keys
  wireguard.privateKey = "your-wg-private-key";      # WireGuard private key (wg genkey)
  wireguard.publicKey  = "your-wg-public-key";       # WireGuard public key

  # ── VPS / SSH ────────────────────────────────────────────────────
  vps.host      = "your-vps-ip-or-domain";           # Địa chỉ VPS
  vps.user      = "root";                            # SSH user
  vps.port      = 22;                                # SSH port
  vps.sshKey    = ''
    -----BEGIN OPENSSH PRIVATE KEY-----
    YOUR_VPS_SSH_PRIVATE_KEY_HERE
    -----END OPENSSH PRIVATE KEY-----
  '';                                                # SSH key cho VPS deploy

  # ── Database / Services (local dev) ──────────────────────────────
  postgres.pass = "your-postgres-password";          # PostgreSQL local dev
  mysql.pass    = "your-mysql-password";             # MySQL local dev

  # ── Khác ─────────────────────────────────────────────────────────
  # Thêm key tùy chỉnh của bạn ở đây...
}
