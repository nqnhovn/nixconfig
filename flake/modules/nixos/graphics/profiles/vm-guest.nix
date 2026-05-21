# =====================================================================
# GRAPHICS PROFILE: VM-GUEST (QEMU/VIRTUALBOX)
# =====================================================================
# Dùng cho máy ảo: virtio-gpu, không cần driver NVIDIA/Intel thật.

{ config, lib, ... }:

let
  cfg = config.flake.graphics.vmGuest;
in
{
  options.flake.graphics.vmGuest = {
    enable = lib.mkEnableOption "VM guest graphics (virtio-gpu)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "modesetting" ];
    hardware.graphics.enable = true;

    # Không dùng NVIDIA trong VM
    hardware.nvidia.prime.offload.enable = lib.mkForce false;

    # Tối ưu cho VM
    services.xserver.displayManager.gdm.autoSuspend = false;

    boot.kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
    ];

    environment.sessionVariables.DRI_PRIME = "0";
  };
}
