# =====================================================================
# SECRETS/AICHAT-KEYS.EXAMPLE.NIX — MẪU API KEYS (KHÔNG CHỨA KEY THẬT)
# =====================================================================
# Copy file này thành aichat-keys.nix và điền key thực của bạn:
#   cp secrets/aichat-keys.example.nix secrets/aichat-keys.nix
#
# ⚠️  secrets/aichat-keys.nix đã được gitignore — KHÔNG BAO GIỜ bị commit!
# =====================================================================

{
  deepseek.key = "sk-your-deepseek-api-key-here";
  gemini.key = "your-gemini-api-key-here";
}
