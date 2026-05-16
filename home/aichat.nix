# =====================================================================
# HOME/AICHAT.NIX — AICHAT CONFIG (DEEPSEEK + GEMINI)
# 🔗 https://github.com/sigoden/aichat
# =====================================================================

{ pkgs, ... }:

{
  # Aichat configuration with DeepSeek + Google Gemini APIs
  xdg.configFile."aichat/config.yaml" = {
    text = ''
      model: deepseek:deepseek-chat
      temperature: 0.7
      save_session: true
      save: true
      highlight: true
      auto_copy: true
      keybindings: vi
      clients:
        - name: deepseek
          type: openai_compatible
          api_base: https://api.deepseek.com/v1
          api_key: sk-739376dce72f49ad832167488671b396
          models:
            - name: deepseek-chat
            - name: deepseek-reasoner
        - name: gemini
          type: gemini
          api_key: AIzaSyBLoFoiKneKAJvQnVIfRyc9hYmTpiC-48o
    '';
  };

  home.packages = with pkgs; [ aichat ];
}
