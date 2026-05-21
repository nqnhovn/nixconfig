# =====================================================================
# HOME/ZED.NIX — ZED EDITOR CONFIG + NIXD LSP
# =====================================================================

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd              # Nix Language Server
  ];

  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    # ── LSP ──────────────────────────────────────────────────────
    lsp = {
      nixd.settings = {
        formatting.command = [ "nixpkgs-fmt" ];
      };
    };

    # ── Editor ───────────────────────────────────────────────────
    buffer_font_size = 14;
    tab_size = 2;
    soft_wrap = "editor_width";
    format_on_save = "on";
    autosave = "on_focus_change";
    restore_on_startup = "last_session";
    confirm_quit = false;

    # ── Project Panel ────────────────────────────────────────────
    project_panel = {
      dock = "left";
      default_width = 280;
      confirm_file_delete = false;
    };

    # ── AI Assistant ─────────────────────────────────────────────
    assistant = {
      enabled = true;
      dock = "right";
      default_width = 420;
      default_model = {
        provider = "zed.dev";
        model = "claude-sonnet-4";
      };
    };

    # ── File exclusions ──────────────────────────────────────────
    file_scan_exclusions = [
      "**/.git"
      "**/.devenv"
      "**/result"
      "**/result-*"
    ];

    # ── Theme ────────────────────────────────────────────────────
    theme = "One Dark";
  };
}
