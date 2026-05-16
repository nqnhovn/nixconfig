# =====================================================================
# HOME/AICHAT.NIX — AICHAT CONFIG (DEEPSEEK + GEMINI)
# 🔗 https://github.com/sigoden/aichat
# =====================================================================

{ pkgs, ... }:

{
  # Aichat configuration with DeepSeek + Google Gemini APIs
  xdg.configFile."aichat/config.yaml" = {
    text = ''
      # Aichat Configuration - DeepSeek + Gemini
      model: deepseek:deepseek-chat
      temperature: 0.7
      top_p: 1.0
      save_session: true
      save: true
      highlight: true
      auto_copy: true
      keybindings: vi
      clients:
        - name: deepseek
          type: openai_compatible
          api_key: sk-739376dce72f49ad832167488671b396
        - name: gemini
          type: gemini
          api_key: AIzaSyBLoFoiKneKAJvQnVIfRyc9hYmTpiC-48o
    '';
  };

  # Add aichat to home packages
  home.packages = with pkgs; [
    aichat
  ];
}
