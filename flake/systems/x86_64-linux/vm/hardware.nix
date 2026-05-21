# =====================================================================
# SYSTEMS/VM/HARDWARE.NIX — VM GUEST HARDWARE STUB
# =====================================================================

{ ... }:

{
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "virtio_blk" "xhci_pci" ];
}
