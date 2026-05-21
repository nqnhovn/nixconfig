# =====================================================================
# SYSTEMS/VPS/HARDWARE.NIX — VPS HARDWARE STUB
# =====================================================================

{ ... }:

{
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "virtio_blk" ];
}
