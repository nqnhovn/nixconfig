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
    # Dev tools (AI Agent workflow)
    lazygit           # Git TUI
    git-delta         # Beautiful git diff
    xh                # HTTP client (Rust)
    yq-go             # YAML processor
    tig               # Git text-mode browser
    marksman          # Markdown LSP (cho Zed)
    # appflowy
    # reno
    # gnote
  ];
}
