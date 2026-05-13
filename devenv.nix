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

  # ── Scripts quản lý NixOS ──────────────────────────────────────────
  scripts.switch.exec = "sudo nixos-rebuild switch --flake .#lg";
  scripts.build.exec = "sudo nixos-rebuild boot --flake .#lg";  # Build but don't switch
  scripts.gc.exec = "sudo nix-collect-garbage -d";
  scripts.update.exec = "nix flake update";
  scripts.fmt.exec = "nixpkgs-fmt *.nix modules/**/*.nix home/**/*.nix hosts/**/*.nix";
  scripts.check.exec = "shellcheck initial.sh";
  scripts.list.exec = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
  scripts.clean.exec = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

  enterShell = ''
    echo "❄️  NixOS Config — devenv $(devenv version 2>/dev/null || echo '?')"
    echo ""
    echo "  Scripts:"
    echo "    switch   → rebuild + apply (tương đương update alias)"
    echo "    build    → build boot (không switch ngay)"
    echo "    gc       → dọn rác hệ thống (garbage collect)"
    echo "    update   → cập nhật flake.lock"
    echo "    fmt      → format code .nix"
    echo "    check    → kiểm tra lỗi script initial.sh"
    echo "    list     → liệt kê các thế hệ (generations)"
    echo "    clean    → dọn rác + liệt kê generations"
    echo ""
  '';
}
