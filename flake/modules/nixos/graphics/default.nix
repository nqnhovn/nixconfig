# =====================================================================
# MODULES/NIXOS/GRAPHICS — AUTO-SELECT PROFILE THEO HOST CONFIG
# =====================================================================
# Mỗi host chọn 1 graphicsProfile trong: intel-only, nvidia-prime, vm-guest, headless
# Nếu không chọn → mặc định headless (an toàn nhất)

{ config, lib, ... }:

let
  inherit (lib) types mkOption mkDefault;
in
{
  options.flake.graphicsProfile = mkOption {
    type = types.enum [ "intel-only" "nvidia-prime" "vm-guest" "headless" ];
    default = "headless";
    description = "Chọn profile đồ họa cho host này";
  };

  imports = [
    ./profiles/intel-only.nix
    ./profiles/nvidia-prime.nix
    ./profiles/vm-guest.nix
    ./profiles/headless.nix
    ./desktop/gnome.nix
  ];

  config = lib.mkMerge [
    # Enable profile tương ứng dựa trên lựa chọn
    (lib.mkIf (config.flake.graphicsProfile == "intel-only") {
      flake.graphics.intelOnly.enable = true;
    })
    (lib.mkIf (config.flake.graphicsProfile == "nvidia-prime") {
      flake.graphics.nvidiaPrime.enable = true;
    })
    (lib.mkIf (config.flake.graphicsProfile == "vm-guest") {
      flake.graphics.vmGuest.enable = true;
    })
    # headless = default, không enable gì
  ];
}
