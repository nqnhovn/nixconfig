{ config, pkgs, ... }:

{
  # Aichat configuration with DeepSeek and Google Gemini APIs
  xdg.configFile."aichat/config.yaml" = {
    text = ''
      # Aichat Configuration - DeepSeek + Google Gemini
      model: deepseek-chat
      temperature: 0.7
      top_p: 1.0
      save_session: true
      save: true
      highlight: true
      auto_copy: true
      keybindings: vi
      prelude: []
      clients:
        - name: deepseek
          type: openai_compatible
          api_base: https://api.deepseek.com/v1
          api_key: sk-739376dce72f49ad832167488671b396
          models:
            - name: deepseek-chat
              max_input_tokens: 65536
            - name: deepseek-reasoner
              max_input_tokens: 65536
          extra:
            {
              "OPENAI_API_KEY": "sk-739376dce72f49ad832167488671b396",
            }

        - name: gemini
          type: gemini
          api_key: AIzaSyBLoFoiKneKAJvQnVIfRyc9hYmTpiC-48o
          models:
            - name: gemini-2.5-flash
              max_input_tokens: 1048576
            - name: gemini-2.5-pro
              max_input_tokens: 1048576
    '';
  };

  # Add aichat to home packages
  home.packages = with pkgs; [
    aichat
  ];
}
