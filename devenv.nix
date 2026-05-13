{ pkgs, ... }:

{
  packages = with pkgs; [
    nixpkgs-fmt
    nil
    shellcheck
    bat
    eza
    fd
    jq
  ];

  # ── Scripts thay thế Makefile ──────────────────────────────────────
  scripts.switch.exec = "sudo nixos-rebuild switch --flake .#lg";
  scripts.build.exec = "sudo nixos-rebuild switch --flake .#lg";
  scripts.home.exec = "sudo nixos-rebuild switch --flake .#lg";
  scripts.gc.exec = "sudo nix-collect-garbage -d";
  scripts.update.exec = "nix flake update";
  scripts.fmt.exec = "nixpkgs-fmt *.nix modules/**/*.nix home/**/*.nix hosts/**/*.nix";
  scripts.check.exec = "shellcheck initial.sh";
  scripts.list.exec = "make list 2>/dev/null || echo 'Run: make list'";
  scripts.clean.exec = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

  enterShell = ''
    echo "❄️  NixOS Config — devenv $(devenv version 2>/dev/null || echo '?')"
    echo ""
    echo "  Scripts (thay Makefile):"
    echo "    switch   → rebuild + apply"
    echo "    home     → rebuild user config"
    echo "    gc       → garbage collect"
    echo "    update   → nix flake update"
    echo "    fmt      → format all .nix"
    echo "    check    → lint initial.sh"
    echo "    list     → generation dashboard"
    echo ""
  '';
}
