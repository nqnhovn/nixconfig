# =====================================================================
# FLAKE.NIX — ROOT ENTRY POINT (REDIRECTS TO FLAKE/FLAKE.NIX)
# =====================================================================
# Snowfall Lib structure: ./flake/ chứa toàn bộ modules, hosts, homes.
# File này giữ inputs + redirect outputs sang ./flake/flake.nix

{
  description = "NixOS Snowfall Configuration — Multi-Host · Multi-Graphics";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv.url = "github:cachix/devenv/latest";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = args:
    let
      flakeOutputs = import ./flake/flake.nix;
    in
    flakeOutputs.outputs args;
}
