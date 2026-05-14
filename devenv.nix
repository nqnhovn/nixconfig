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
  # ── Scripts quản lý NixOS ──────────────────────────────────────────
  # Các script này được gọi trực tiếp trong môi trường devenv
  scripts = {
    # Quản lý hệ thống
    switch.exec = "sudo nixos-rebuild switch --flake .#lg";
    build.exec = "sudo nixos-rebuild boot --flake .#lg";  # Build but don't switch
    gc.exec = "sudo nix-collect-garbage -d";
    update.exec = "nix flake update"; # Cập nhật flake.lock
    fmt.exec = "nixpkgs-fmt *.nix modules/**/*.nix home/**/*.nix hosts/**/*.nix";
    check.exec = "shellcheck initial.sh";
    list.exec = "sudo nix-env --list-generations -p /nix/var/nix/profiles/system";
    clean.exec = "sudo nix-collect-garbage -d && sudo nix-env --list-generations -p /nix/var/nix/profiles/system";

    # Alias cho devenv (dùng trong môi trường devenv)
    dev.exec = "devenv";
    devup.exec = "devenv up";
    devdown.exec = "devenv down";
    devstart.exec = "devenv start";
    devstop.exec = "devenv stop";
    devrestart.exec = "devenv restart";
    devupdate.exec = "devenv update"; # Cập nhật devenv lock file
    devgc.exec = "devenv gc";
    devshell.exec = "devenv shell"; # Mặc dù đang ở trong shell, nhưng có thể cần thiết

  }; # Kết thúc block scripts

  enterShell = "";
}
