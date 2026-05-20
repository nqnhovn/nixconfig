# =====================================================================
# HOME/ZED.NIX — ZED EDITOR CONFIG + NIXD LSP
# =====================================================================

{ pkgs, ... }:

{
  # Settings do Zed tự quản lý — không ghi đè để Zed lưu được AI preferences
  # Các file rules được deploy qua home/rules.nix → ~/.config/zed/rules/

  home.packages = with pkgs; [
    nixd              # Nix Language Server
  ];

  # Cấu hình cơ bản qua XDG (không xung đột với Zed tự quản lý)
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # LSP
    lsp = {
      nixd.settings = {
        formatting.command = [ "nixpkgs-fmt" ];
      };
    };

    # Editor preferences
    buffer_font_size = 14;
    tab_size = 2;
    soft_wrap = "editor_width";
    format_on_save = "on";

    # File exclusions
    file_scan_exclusions = [
      "**/.git"
      "**/.devenv"
      "**/result"
      "**/result-*"
    ];

    # Theme
    theme = "One Dark";
  };
}
