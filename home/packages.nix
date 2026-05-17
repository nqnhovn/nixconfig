{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    # devenv
    gh
    vim
    zed-editor
    podman-compose
    podman-tui
    distrobox
    bat               # cat có syntax highlighting + line number
    glow              # Markdown viewer CLI (cho AI Panel doc)
    mdcat             # cat for markdown (cho AI Panel doc)
    fd                # find nhanh hơn
    nixd              # Nix Language Server cho Zed
    # appflowy
    # reno
    # gnote
  ];
}
