{ pkgs, ... }:

{
  # Removed xdg.configFile."zed/settings.json" to allow Zed to manage its own settings.json
  # This enables Zed to save AI agent preferences and other settings directly.

  # You can still install nixd for Zed as a system package
  home.packages = with pkgs; [
    nixd
  ];
}
