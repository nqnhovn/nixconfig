{ pkgs, ... }:

{
  home.packages = with pkgs; [
    btop
    devenv
    gh
    vim
    zed-editor
    podman-compose
    podman-tui
    distrobox
    bat               # cat có syntax highlighting + line number
    fd                # find nhanh hơn
    nixd              # Nix Language Server cho Zed
    # appflowy
    # reno
    # gnote
  ];
}
