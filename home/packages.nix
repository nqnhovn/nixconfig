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
    bat               # cat có syntax highlighting + line number
    fd                # find nhanh hơn
  ];
}
