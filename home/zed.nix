{ ... }:

{
  xdg.configFile."zed/settings.json".text = ''
    {
      "theme": "One Dark",
      "ui_font_size": 16,
      "buffer_font_size": 15,
      "telemetry": { "metrics": false },

      "autosave": "on_focus_change",
      "restore_on_startup": "last_session",
      "confirm_quit": false,

      "project_panel": {
        "dock": "left",
        "default_width": 280,
        "confirm_file_delete": false
      },

      "assistant": {
        "enabled": true,
        "dock": "right",
        "default_width": 420,
        "default_model": {
          "provider": "zed.dev",
          "model": "claude-sonnet-4"
        }
      },

      "inline_completions": {
        "enabled": true
      },


      "terminal": {
        "font_size": 14.0,
        "blinking": "off"
      },

      "cursor_blink": false,
      "scrollbar": { "show": "always" },
      "tabs": { "close_on_delete": true },
      "tab_bar": { "show": true },

      "languages": {
        "Go": { "language_servers": ["gopls"], "tab_size": 4 },
        "Vue.js": { "language_servers": ["vue-language-server", "tailwindcss-language-server"], "tab_size": 2 },
        "PHP": { "language_servers": ["intelephense"], "tab_size": 4 },
        "TypeScript": { "language_servers": ["typescript-language-server", "tailwindcss-language-server"], "tab_size": 2 },
        "JavaScript": { "language_servers": ["typescript-language-server"], "tab_size": 2 },
        "Nix": { "language_servers": ["nixd"], "tab_size": 2 },
        "Python": { "language_servers": ["pyright"], "tab_size": 4 },
        "JSON": { "tab_size": 2 },
        "Markdown": { "tab_size": 2 }
      }
    }
  '';
}
