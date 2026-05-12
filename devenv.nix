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

  scripts.fmt.exec = "nixpkgs-fmt *.nix modules/**/*.nix home/**/*.nix hosts/**/*.nix";
  scripts.check.exec = "shellcheck initial.sh";
  scripts.build.exec = "sudo nixos-rebuild switch --flake .#lg";

  enterShell = ''
    echo "❄️  NixOS Config Dev Environment"
    echo "   devenv up   → start services"
    echo "   fmt         → format .nix files"
    echo "   check       → lint .sh files"
  '';
}
