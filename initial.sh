#!/usr/bin/env bash
# =============================================================================
# INITIAL.SH — NIXOS BOOTSTRAP (MULTI-HOST + AUTO HARDWARE DETECTION)
# =============================================================================
# Cách dùng:
#   sudo bash ~/.config/nixos/initial.sh
#
# Kịch bản: Máy NixOS mới cài, chưa có git, chưa có gì.
# Tải repo này về (ZIP), extract vào ~/.config/nixos/, chạy script này.
# Script sẽ hỏi hostname → detect hardware → tạo config → cài git.
# =============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Quyền root ─────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Chạy với sudo:${NC} sudo bash ~/.config/nixos/initial.sh"
  exit 1
fi

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")
CONFIG_DIR="$REAL_HOME/.config/nixos"

clear
echo -e "${BLUE}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║       NIXOS BOOTSTRAP — MULTI-HOST SETUP            ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  User: ${GREEN}$REAL_USER${NC}  |  Config: ${GREEN}$CONFIG_DIR${NC}"
echo ""

# ===========================================================================
# HÀM: detect_hardware — Quét toàn bộ phần cứng, trả về biến môi trường
# ===========================================================================
detect_hardware() {
  local HOST="$1"
  local HOST_DIR="$2"

  echo -e "  ${CYAN}🔍 Quét phần cứng (lspci -nn + nixos-generate-config)...${NC}"

  # ── Chạy nixos-generate-config để có kernel modules chuẩn ──────────
  nixos-generate-config --root / 2>/dev/null || true
  BASE_HW="/etc/nixos/hardware-configuration.nix"

  # ── CPU ─────────────────────────────────────────────────────────────
  CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2- | xargs || echo "Unknown")
  CPU_VENDOR=$(lscpu | grep "Vendor ID" | cut -d':' -f2 | xargs || echo "Unknown")
  CPU_CORES=$(lscpu | grep "^CPU(s):" | cut -d':' -f2 | xargs || echo "1")
  CPU_GEN="unknown"
  [[ "$CPU_MODEL" =~ i([0-9]+)- ]] && CPU_GEN="${BASH_REMATCH[1]}th Gen"
  [[ "$CPU_MODEL" =~ Core.*Ultra ]] && CPU_GEN="Core Ultra"
  RAM_TOTAL=$(free -h | awk '/^Mem:/{print $2}' || echo "unknown")

  # ── GPU với Hardware ID (lspci -nn) ─────────────────────────────────
  INTEL_GPU=""; NVIDIA_GPU=""; AMD_GPU=""
  INTEL_BUS=""; NVIDIA_BUS=""; AMD_BUS=""
  INTEL_ID=""; NVIDIA_ID=""; AMD_ID=""
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    BUS=$(echo "$line" | awk '{print $1}')
    HW_ID=$(echo "$line" | grep -oP '\[([0-9a-fA-F]{4}:[0-9a-fA-F]{4})\]' | tail -1 | tr -d '[]')
    DESC=$(echo "$line" | sed 's/.*]: //' | sed 's/ (rev.*//')
    if echo "$line" | grep -qi "Intel"; then
      INTEL_GPU="$DESC"; INTEL_BUS="$BUS"; INTEL_ID="$HW_ID"
    elif echo "$line" | grep -qi "NVIDIA"; then
      NVIDIA_GPU="$DESC"; NVIDIA_BUS="$BUS"; NVIDIA_ID="$HW_ID"
    elif echo "$line" | grep -qiE "AMD|Radeon"; then
      AMD_GPU="$DESC"; AMD_BUS="$BUS"; AMD_ID="$HW_ID"
    fi
  done < <(lspci -nn | grep -iE "VGA|3D|Display" 2>/dev/null || true)

  # ── Storage ─────────────────────────────────────────────────────────
  ROOT_UUID=$(findmnt -n -o UUID / 2>/dev/null || echo "unknown")
  BOOT_UUID=$(findmnt -n -o UUID /boot 2>/dev/null || echo "unknown")
  SWAP_UUID=$(lsblk -no UUID,MOUNTPOINT 2>/dev/null | grep -i swap | awk '{print $1}' || echo "unknown")
  DISK_TYPE="SSD/HDD"; lsblk -d -o name,model 2>/dev/null | grep -qi "nvme" && DISK_TYPE="NVMe"
  DISK_MODEL=$(lsblk -d -o model 2>/dev/null | tail -1 | xargs || echo "unknown")

  # ── Kernel modules từ nixos-generate-config (chuẩn nhất) ───────────
  KERNEL_MODULES="xhci_pci nvme usb_storage sd_mod"
  if [[ -f "$BASE_HW" ]]; then
    KERNEL_MODULES=$(grep "availableKernelModules" "$BASE_HW" | grep -oP '\[.*?\]' | tr -d '[]"' | xargs || echo "$KERNEL_MODULES")
  fi

  # ── Network ─────────────────────────────────────────────────────────
  WIFI_CHIP=$(lspci -nn | grep -iE "Network controller" | sed 's/.*]: //' | sed 's/ (rev.*//' | xargs 2>/dev/null || echo "")
  ETH_CHIP=$(lspci -nn | grep -iE "Ethernet controller" | sed 's/.*]: //' | sed 's/ (rev.*//' | xargs 2>/dev/null || echo "")
  AUDIO_CHIP=$(lspci -nn | grep -iE "Audio" | head -1 | sed 's/.*]: //' | sed 's/ (rev.*//' | xargs 2>/dev/null || echo "unknown")

  # ── Input ───────────────────────────────────────────────────────────
  KEYBOARD_TYPE="USB"
  cat /sys/class/input/input*/name 2>/dev/null | grep -qiE "AT Translated|i8042" && KEYBOARD_TYPE="PS/2 (i8042)"
  TOUCHPAD_INFO=$(cat /sys/class/input/input*/name 2>/dev/null | grep -iE "touchpad|trackpad|elan|synaptics" | head -1 | xargs || echo "unknown")

  echo -e "  ${GREEN}✅ Hardware detected: CPU=$CPU_GEN, GPU Intel=${INTEL_ID:-none} NVIDIA=${NVIDIA_ID:-none}${NC}"

  # ── Xuất biến ──────────────────────────────────────────────────────
  HW_HOSTNAME="$HOST"
  HW_ROOT_UUID="$ROOT_UUID"; HW_BOOT_UUID="$BOOT_UUID"; HW_SWAP_UUID="$SWAP_UUID"
  HW_HAS_NVIDIA="$([ -n "$NVIDIA_GPU" ] && echo "true" || echo "false")"
  HW_NVIDIA_BUS="$NVIDIA_BUS"; HW_INTEL_BUS="$INTEL_BUS"
  HW_KEYBOARD_TYPE="$KEYBOARD_TYPE"
  HW_KERNEL_MODULES="$KERNEL_MODULES"
  HW_CPU_MODEL="$CPU_MODEL"; HW_CPU_GEN="$CPU_GEN"; HW_CPU_VENDOR="$CPU_VENDOR"; HW_CPU_CORES="$CPU_CORES"
  HW_RAM_TOTAL="$RAM_TOTAL"; HW_DISK_TYPE="$DISK_TYPE"; HW_DISK_MODEL="$DISK_MODEL"
  HW_INTEL_ID="$INTEL_ID"; HW_NVIDIA_ID="$NVIDIA_ID"; HW_AMD_ID="$AMD_ID"
  HW_INTEL_GPU="$INTEL_GPU"; HW_NVIDIA_GPU="$NVIDIA_GPU"; HW_AMD_GPU="$AMD_GPU"
  HW_AMD_BUS="$AMD_BUS"
  HW_WIFI_CHIP="$WIFI_CHIP"; HW_ETH_CHIP="$ETH_CHIP"; HW_AUDIO_CHIP="$AUDIO_CHIP"
  HW_TOUCHPAD_INFO="$TOUCHPAD_INFO"
}

generate_hardware_nix() {
  local HOST_DIR="$1"

  convert_bus() {
    local bus="$1"
    if [[ "$bus" =~ ^([0-9a-fA-F]{2}):([0-9a-fA-F]{2})\.([0-9])$ ]]; then
      printf "PCI:%d:%d:%d" "$((16#${BASH_REMATCH[1]}))" "$((16#${BASH_REMATCH[2]}))" "${BASH_REMATCH[3]}"
    else
      echo "PCI:0:2:0"
    fi
  }

  INTEL_NIX_BUS=$(convert_bus "${HW_INTEL_BUS:-00:02.0}")
  NVIDIA_NIX_BUS=$(convert_bus "${HW_NVIDIA_BUS:-00:00.0}")

  NVIDIA_BLOCK=""
  if [[ "$HW_HAS_NVIDIA" == "true" ]]; then
    NVIDIA_BLOCK="
  services.xserver.videoDrivers = [ \"nvidia\" ];
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
      intelBusId = \"$INTEL_NIX_BUS\";
      nvidiaBusId = \"$NVIDIA_NIX_BUS\";
    };
  };"
  fi

  cat > "$HOST_DIR/hardware.nix" << NIXEOF
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ${HW_KERNEL_MODULES} ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems.\"/\" = {
    device = \"/dev/disk/by-uuid/$HW_ROOT_UUID\";
    fsType = \"ext4\";
  };

  fileSystems.\"/boot\" = {
    device = \"/dev/disk/by-uuid/$HW_BOOT_UUID\";
    fsType = \"vfat\";
    options = [ \"fmask=0077\" \"dmask=0077\" ];
  };

  swapDevices = [{ device = \"/dev/disk/by-uuid/$HW_SWAP_UUID\"; }];

  nixpkgs.hostPlatform = lib.mkDefault \"x86_64-linux\";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
$NVIDIA_BLOCK
}
NIXEOF

  echo -e "  ${GREEN}✅ Đã tạo hardware.nix (Kernel modules: ${HW_KERNEL_MODULES})${NC}"
}

generate_hardware_nix() {
  local HOST_DIR="$1"

  # Chuyển PCI Bus từ dạng "00:02.0" → "PCI:0:2:0"
  convert_bus() {
    local bus="$1"
    if [[ "$bus" =~ ^([0-9a-fA-F]{2}):([0-9a-fA-F]{2})\.([0-9])$ ]]; then
      local d1=$((16#${BASH_REMATCH[1]}))
      local d2=$((16#${BASH_REMATCH[2]}))
      local d3=${BASH_REMATCH[3]}
      echo "PCI:$d1:$d2:$d3"
    else
      echo "PCI:0:2:0"  # fallback
    fi
  }

  INTEL_NIX_BUS=$(convert_bus "${HW_INTEL_BUS:-00:02.0}")
  NVIDIA_NIX_BUS=$(convert_bus "${HW_NVIDIA_BUS:-00:00.0}")

  # NVIDIA block
  NVIDIA_BLOCK=""
  if [[ "$HW_HAS_NVIDIA" == "true" ]]; then
    NVIDIA_BLOCK="
  services.xserver.videoDrivers = [ \"nvidia\" ];
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
      intelBusId = \"$INTEL_NIX_BUS\";
      nvidiaBusId = \"$NVIDIA_NIX_BUS\";
    };
  };"
  fi

  # Keyboard fix block
  KEYBOARD_FIX=""
  if [[ "$HW_KEYBOARD_TYPE" == "PS/2 (i8042)" ]]; then
    KEYBOARD_FIX='
  # Fix bàn phím PS/2 sau hibernate (LG Gram & similar)
  powerManagement.resumeCommands = '\'\'''\'\''\'\'\'\''echo -n "i8042" > /sys/bus/platform/drivers/i8042/unbind\'\'''\''\n    echo -n "i8042" > /sys/bus/platform/drivers/i8042/bind\'\'''\''\n  '\'\'''\'\''\;\n'
  fi

  cat > "$HOST_DIR/hardware.nix" << NIXEOF
# =====================================================================
# HOSTS/$HW_HOSTNAME/HARDWARE.NIX — AUTO-GENERATED BY INITIAL.SH
# =====================================================================
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems.\"/\" = {
    device = \"/dev/disk/by-uuid/$HW_ROOT_UUID\";
    fsType = \"ext4\";
  };

  fileSystems.\"/boot\" = {
    device = \"/dev/disk/by-uuid/$HW_BOOT_UUID\";
    fsType = \"vfat\";
    options = [ \"fmask=0077\" \"dmask=0077\" ];
  };

  swapDevices = [{
    device = \"/dev/disk/by-uuid/$HW_SWAP_UUID\";
  }];

  nixpkgs.hostPlatform = lib.mkDefault \"x86_64-linux\";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
$NVIDIA_BLOCK
}
NIXEOF

  echo -e "  ${GREEN}✅ Đã tạo hardware.nix với GPU${NC}"
}

# ===========================================================================
# MAIN
# ===========================================================================

# ── Step 0: Chọn hoặc tạo host ────────────────────────────────────────────
echo -e "${BOLD}[0/6] Chọn host...${NC}"
echo ""

EXISTING_HOSTS=()
if [[ -d "$CONFIG_DIR/hosts" ]]; then
  for d in "$CONFIG_DIR/hosts"/*/; do
    if [[ -d "$d" ]] && [[ -f "${d}default.nix" ]]; then
      EXISTING_HOSTS+=("$(basename "$d")")
    fi
  done
fi

if [[ ${#EXISTING_HOSTS[@]} -gt 0 ]]; then
  echo -e "  ${CYAN}Host hiện có:${NC}"
  for i in "${!EXISTING_HOSTS[@]}"; do
    echo -e "    ${GREEN}$((i+1))${NC}. ${EXISTING_HOSTS[$i]}"
  done
  echo -e "    ${GREEN}n${NC}. Tạo host mới (tự động detect hardware)"
  echo ""
  echo -ne "  ${YELLOW}Chọn host [1]:${NC} "
  read -r host_choice
  host_choice="${host_choice:-1}"

  if [[ "$host_choice" == "n" || "$host_choice" == "N" ]]; then
    HOSTNAME=""
  elif [[ "$host_choice" =~ ^[0-9]+$ ]] && [[ "$host_choice" -le ${#EXISTING_HOSTS[@]} ]]; then
    HOSTNAME="${EXISTING_HOSTS[$((host_choice-1))]}"
    echo -e "  ${GREEN}Dùng host: $HOSTNAME${NC}"
  else
    HOSTNAME="${EXISTING_HOSTS[0]}"
    echo -e "  ${GREEN}Dùng host mặc định: $HOSTNAME${NC}"
  fi
else
  echo -e "  ${YELLOW}Chưa có host nào — sẽ tạo mới.${NC}"
fi

CREATE_NEW=false
if [[ -z "${HOSTNAME:-}" ]]; then
  CREATE_NEW=true
  CURRENT_HOST=$(hostname 2>/dev/null || echo "lg")
  echo ""
  echo -e "${BOLD}── TẠO HOST MỚI (Auto Hardware Detection) ──${NC}"
  echo -ne "  ${CYAN}Tên host [$CURRENT_HOST]:${NC} "
  read -r INPUT_HOST
  HOSTNAME="${INPUT_HOST:-$CURRENT_HOST}"

  if [[ ! "$HOSTNAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
    echo -e "  ${RED}Tên host không hợp lệ. Dùng 'lg'.${NC}"
    HOSTNAME="lg"
  fi

  HOST_DIR="$CONFIG_DIR/hosts/$HOSTNAME"
  mkdir -p "$HOST_DIR"

  # Copy default.nix từ host mẫu
  if [[ -f "$CONFIG_DIR/hosts/lg/default.nix" ]]; then
    cp "$CONFIG_DIR/hosts/lg/default.nix" "$HOST_DIR/default.nix"
  else
    cat > "$HOST_DIR/default.nix" << 'NIXEOF'
{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/system/core.nix
    ../../modules/system/boot.nix
    ../../modules/system/power.nix
    ../../modules/system/display.nix
    ../../modules/system/network.nix
    ../../modules/system/services.nix
    ../../modules/system/shell.nix
  ];
}
NIXEOF
  fi
  echo -e "  ${GREEN}Đã tạo hosts/$HOSTNAME/default.nix${NC}"

  # ── Detect + Generate hardware ────────────────────────────────────────
  echo ""
  echo -e "${BOLD}[1/6] Quét & tạo hardware config...${NC}"
  detect_hardware "$HOSTNAME" "$HOST_DIR"
  generate_hardware_nix "$HOST_DIR"

  # Cập nhật hostname trong network.nix
  if [[ -f "$CONFIG_DIR/modules/system/network.nix" ]]; then
    sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_DIR/modules/system/network.nix"
    echo -e "  ${GREEN}Đã cập nhật hostname → $HOSTNAME${NC}"
  fi
else
  HOST_DIR="$CONFIG_DIR/hosts/$HOSTNAME"
  echo -e "${BOLD}[1/6] Kiểm tra hardware-config...${NC}"
fi

# ── Step 1: Tạo hardware-config nếu host cũ chưa có ───────────────────────
if [[ "$CREATE_NEW" != "true" ]]; then
  if [[ ! -f "$HOST_DIR/hardware.nix" ]]; then
    detect_hardware "$HOSTNAME" "$HOST_DIR"
    generate_hardware_nix "$HOST_DIR"
  else
    echo -e "  ${GREEN}Đã có hardware.nix${NC}"
  fi
fi

# Dọn /etc/nixos/ cũ
if [[ -f /etc/nixos/configuration.nix ]]; then
  rm -f /etc/nixos/configuration.nix /etc/nixos/hardware-configuration.nix 2>/dev/null
  echo -e "  ${GREEN}Đã dọn /etc/nixos/${NC}"
fi

# ── Step 2: Cập nhật flake.nix ────────────────────────────────────────────
echo ""
echo -e "${BOLD}[2/6] Cập nhật flake.nix...${NC}"
FLAKE_FILE="$CONFIG_DIR/flake.nix"
if [[ -f "$FLAKE_FILE" ]]; then
  sed -i "s|./hosts/[^/]*/default.nix|./hosts/$HOSTNAME/default.nix|g" "$FLAKE_FILE"
  echo -e "  ${GREEN}flake.nix → hosts/$HOSTNAME/default.nix${NC}"
fi

# ── Step 3: Cài git + make ────────────────────────────────────────────────
echo ""
echo -e "${BOLD}[3/6] Cài đặt công cụ cơ bản...${NC}"
if ! command -v git &>/dev/null; then
  echo -e "  ${YELLOW}Đang cài git...${NC}"
  nix profile install nixpkgs#git 2>/dev/null || nix-env -iA nixos.git 2>/dev/null || true
fi
command -v git &>/dev/null && echo -e "  ${GREEN}git: OK${NC}" || echo -e "  ${YELLOW}git: sẽ dùng từ nix-shell${NC}"

# ── Step 4: Git init ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}[4/6] Khởi tạo git repository...${NC}"
if [[ ! -d "$CONFIG_DIR/.git" ]]; then
  cd "$CONFIG_DIR"
  git init && git add . && git commit -m "Initial: NixOS config for $HOSTNAME" --quiet
  echo -e "  ${GREEN}Đã git init + commit lần đầu${NC}"
else
  echo -e "  ${GREEN}Git repo đã tồn tại${NC}"
fi

# ── Step 5: Cập nhật alias ────────────────────────────────────────────────
SHELL_FILE="$CONFIG_DIR/modules/system/shell.nix"
if [[ -f "$SHELL_FILE" ]]; then
  sed -i "s|--flake .\\\\#lg|--flake .\\\\#$HOSTNAME|g" "$SHELL_FILE"
  echo -e "  ${GREEN}Đã cập nhật alias → --flake .#$HOSTNAME${NC}"
fi

# ── Step 6: Sửa quyền + chạy Makefile ─────────────────────────────────────
echo ""
echo -e "${BOLD}[6/6] Chuẩn bị & chạy Makefile...${NC}"
chown -R "$REAL_USER:users" "$CONFIG_DIR" 2>/dev/null || true
chmod +x "$CONFIG_DIR/initial.sh" "$CONFIG_DIR/search.py" 2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅ Bootstrap hoàn tất — Host: $HOSTNAME${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Các file đã tạo cho host '$HOSTNAME':"
echo -e "    ${CYAN}hosts/$HOSTNAME/default.nix${NC}   — Machine config"
echo -e "    ${CYAN}hosts/$HOSTNAME/hardware.nix${NC}   — Hardware (auto-detected)"
echo -e "    ${CYAN}hosts/$HOSTNAME/Hardware.md${NC}    — Hardware report"
echo ""
echo -e "  Build ngay:"
echo -e "  ${BOLD}cd ~/.config/nixos && make switch${NC}"
echo ""

echo -ne "${CYAN}Mở Makefile Dashboard? [Y/n]: ${NC}"
read -r answer
if [[ "$answer" =~ ^[Yy]?$ ]]; then
  cd "$CONFIG_DIR"
  sudo -u "$REAL_USER" make list 2>/dev/null || make list 2>/dev/null || {
    echo -e "${YELLOW}Không chạy được make. Hãy chạy thủ công:${NC}"
    echo -e "  cd ~/.config/nixos && make"
  }
fi
