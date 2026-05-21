# =====================================================================
# GRAPHICS PROFILE: NVIDIA-PRIME (INTEL + NVIDIA HYBRID)
# =====================================================================
# Dùng cho laptop có Intel iGPU + NVIDIA dGPU (PRIME offload)
# Intel render desktop → tiết kiệm pin, NVIDIA on-demand cho game/CUDA

{ config, lib, pkgs, ... }:

let
  cfg = config.flake.graphics.nvidiaPrime;
in
{
  options.flake.graphics.nvidiaPrime = {
    enable = lib.mkEnableOption "NVIDIA PRIME hybrid graphics";
    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:0:2:0";
      description = "Intel GPU PCI bus ID (NixOS format)";
    };
    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:2:0:0";
      description = "NVIDIA GPU PCI bus ID (NixOS format)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;

    hardware.nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = cfg.intelBusId;
        nvidiaBusId = cfg.nvidiaBusId;
      };
    };

    # Đảm bảo Intel GPU dùng cho desktop
    environment.sessionVariables.DRI_PRIME = "0";
    environment.sessionVariables.__GLX_VENDOR_LIBRARY_NAME = "mesa";
  };
}
