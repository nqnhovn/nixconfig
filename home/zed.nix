{ ... }:

{
  xdg.configFile."zed/settings.json".text = ''
    {
      "theme": "One Dark",
      "ui_font_size": 16,
      "buffer_font_size": 15,
      "telemetry": { "metrics": false },
      "project_panel": { "dock": "left", "default_width": 280 },
      "assistant": { "enabled": true, "dock": "right", "default_width": 420 },
      "languages": {
        "Go": { "language_servers": ["gopls"] },
        "Vue.js": { "language_servers": ["vue-language-server", "tailwindcss-language-server"] },
        "PHP": { "language_servers": ["intelephense"] },
        "TypeScript": { "language_servers": ["typescript-language-server", "tailwindcss-language-server"] },
        "JavaScript": { "language_servers": ["typescript-language-server"] }
      }
    }
  '';
}
