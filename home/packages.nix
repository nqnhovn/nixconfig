{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    devbox
    gh
    vim
    zed-editor
    podman-compose
    podman-tui
    distrobox
  ];
}
