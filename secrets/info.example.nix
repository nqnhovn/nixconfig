# =====================================================================
# SECRETS/INFO.EXAMPLE.NIX — MẪU THÔNG TIN NGƯỜI DÙNG (TRACKED)
# =====================================================================
# 📋 Đây là template — được git tracked, chứa placeholder
#
# Cách dùng:
#   1. Copy file này thành info.nix:
#        cp secrets/info.example.nix secrets/info.nix
#   2. Điền thông tin thật của bạn vào info.nix
#   3. Hoặc chạy post-install wizard (nixos-setup.sh) để tự động tạo
#
# ⚠️  secrets/info.nix ĐÃ ĐƯỢC GITIGNORE — KHÔNG BAO GIỜ BỊ COMMIT!
# =====================================================================

{
  # ── User hệ thống ───────────────────────────────────────────────
  # Tên user và thông tin cá nhân cho NixOS + Home Manager
  user = "your-username";              # Tên user system (vd: nqnhovn)
  fullName = "Your Full Name";         # Tên đầy đủ (vd: Nguyen Quoc Nho)
  email = "your-email@example.com";    # Email chính (vd: nqnho.vn@gmail.com)
  home = "/home/your-username";        # Home directory

  # ── Git ─────────────────────────────────────────────────────────
  gitUser = "your-github-username";    # GitHub username
  gitEmail = "your-email@example.com"; # GitHub email
}
