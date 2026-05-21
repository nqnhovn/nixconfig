# =====================================================================
# GRAPHICS PROFILE: INTEL-ONLY (TIẾT KIỆM PIN TỐI ĐA)
# =====================================================================
# Chỉ dùng Intel UHD Graphics, tắt NVIDIA hoàn toàn.
# Dùng cho: laptop trên pin, máy không có NVIDIA, ultrabook.

{ config, lib, ... }:

let
  cfg = config.flake.graphics.intelOnly;
in
{
  options.flake.graphics.intelOnly = {
    enable = lib.mkEnableOption "Intel-only graphics (power saving)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "modesetting" ];
    hardware.graphics.enable = true;

    # Tắt NVIDIA hoàn toàn nếu có
    hardware.nvidia.prime.offload.enable = lib.mkForce false;

    # Tối ưu Intel GPU
    environment.sessionVariables = {
      DRI_PRIME = "0";
      __GLX_VENDOR_LIBRARY_NAME = "mesa";
      LIBVA_DRIVER_NAME = "iHD";
    };

    boot.kernelParams = [
      "i915.enable_psr=1"
      "i915.enable_fbc=1"
      "i915.fastboot=1"
    ];
  };
}
