# =====================================================================
# FLAKE/LIB/DEFAULT.NIX — THƯ VIỆN NỘI BỘ
# =====================================================================
# Helper functions dùng chung cho toàn bộ flake.

{ lib }:

let
  inherit (lib) types mkOption mkEnableOption;
in
rec {
  # ── Import tất cả .nix files trong thư mục ──────────────────────
  importDir = dir:
    let
      files = builtins.attrNames (builtins.readDir dir);
      nixFiles = builtins.filter (f: lib.hasSuffix ".nix" f && f != "default.nix") files;
      fullPaths = map (f: dir + "/${f}") nixFiles;
    in
    fullPaths;

  # ── Import tất cả default.nix trong thư mục con ─────────────────
  importSubdirs = dir:
    let
      entries = builtins.attrNames (builtins.readDir dir);
      subdirs = builtins.filter (e: builtins.readDir (dir + "/${e}") != { } || true) entries;
      defaults = builtins.filter (d: builtins.pathExists (dir + "/${d}/default.nix")) subdirs;
      fullPaths = map (d: dir + "/${d}") defaults;
    in
    fullPaths;

  # ── Hợp nhất nhiều attrset ──────────────────────────────────────
  mergeAttrs = builtins.foldl' (acc: x: acc // x) { };

  # ── Graphics profile type ────────────────────────────────────────
  graphicsProfileType = types.enum [
    "intel-only"    # Chỉ Intel UHD (tiết kiệm pin tối đa)
    "nvidia-prime"  # Intel + NVIDIA PRIME offload (hybrid)
    "vm-guest"      # QEMU/VirtualBox guest (virtio-gpu)
    "headless"      # Không GPU (VPS/server)
  ];

  # ── Host platform type ───────────────────────────────────────────
  hostType = types.enum [
    "laptop"
    "desktop"
    "vm"
    "vps"
    "wsl"
  ];
}
