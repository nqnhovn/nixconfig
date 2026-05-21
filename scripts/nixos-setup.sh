#!/usr/bin/env bash
# =============================================================================
# SCRIPTS/NIXOS-SETUP.SH — POST-INSTALL SETUP WIZARD
# =============================================================================
# Chạy sau khi cài NixOS xong từ ISO.
# Hỏi người dùng chọn profile → cấu hình GPU → cài thêm packages.
#
# Cách dùng:
#   bash /etc/nixos-setup.sh
#   # hoặc từ ISO live environment:
#   bash ~/.config/nixos/scripts/nixos-setup.sh
# =============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; MAGENTA='\033[1;35m'; NC='\033[0m'

CONFIG_DIR="${NIXOS_CONFIG_DIR:-$HOME/.config/nixos}"

clear
echo -e "${BLUE}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║        🚀 NIXOS POST-INSTALL SETUP WIZARD           ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ===========================================================================
# STEP 1: Detect GPU
# ===========================================================================
echo -e "${BOLD}[1/4] Phát hiện GPU...${NC}"

HAS_NVIDIA=false
HAS_INTEL=false
HAS_AMD=false

if lspci -nn | grep -qi "NVIDIA"; then
  HAS_NVIDIA=true
  NVIDIA_ID=$(lspci -nn | grep -i "NVIDIA" | grep -oP '\[([0-9a-fA-F]{4}:[0-9a-fA-F]{4})\]' | head -1 | tr -d '[]')
  echo -e "  ${GREEN}✅ NVIDIA GPU detected: ${NVIDIA_ID}${NC}"
fi

if lspci -nn | grep -qiE "Intel.*(VGA|Display|3D)"; then
  HAS_INTEL=true
  echo -e "  ${GREEN}✅ Intel iGPU detected${NC}"
fi

if lspci -nn | grep -qiE "AMD|Radeon"; then
  HAS_AMD=true
  echo -e "  ${GREEN}✅ AMD GPU detected${NC}"
fi

# Quyết định graphics profile
if $HAS_NVIDIA && $HAS_INTEL; then
  GPU_PROFILE="nvidia-prime"
  echo -e "  ${CYAN}🎨 Graphics profile: nvidia-prime (hybrid)${NC}"
elif $HAS_NVIDIA; then
  GPU_PROFILE="nvidia-prime"
  echo -e "  ${CYAN}🎨 Graphics profile: nvidia-prime${NC}"
elif $HAS_AMD || $HAS_INTEL; then
  GPU_PROFILE="intel-only"
  echo -e "  ${CYAN}🎨 Graphics profile: intel-only (modesetting)${NC}"
else
  GPU_PROFILE="headless"
  echo -e "  ${CYAN}🎨 Graphics profile: headless${NC}"
fi

echo ""

# ===========================================================================
# STEP 2: Chọn profile
# ===========================================================================
echo -e "${BOLD}[2/4] Chọn profile sử dụng...${NC}"
echo ""
echo -e "  ${GREEN}1${NC}. ${CYAN}Standard${NC}     — Desktop cơ bản (GNOME + WPS Office)"
echo -e "  ${GREEN}2${NC}. ${CYAN}Developer${NC}    — Dev tools (Go, Node, Python, Podman, Zed)"
echo -e "  ${GREEN}3${NC}. ${CYAN}Office${NC}       — Standard + LibreOffice + OnlyOffice"
echo -e "  ${GREEN}4${NC}. ${CYAN}Gaming${NC}       — Standard + Steam + NVIDIA driver tối ưu"
echo -e "  ${GREEN}5${NC}. ${CYAN}Minimal${NC}      — Server, không GUI"
echo -e "  ${GREEN}6${NC}. ${CYAN}Custom${NC}       — Tự chọn từng thành phần"
echo ""
echo -ne "  ${YELLOW}Chọn [1-6]: ${NC}"
read -r PROFILE_CHOICE
PROFILE_CHOICE="${PROFILE_CHOICE:-1}"

case "$PROFILE_CHOICE" in
  1) PROFILE="standard" ;;
  2) PROFILE="developer" ;;
  3) PROFILE="office" ;;
  4) PROFILE="gaming" ;;
  5) PROFILE="minimal" ;;
  6) PROFILE="custom" ;;
  *) PROFILE="standard" ;;
esac
echo -e "  ${GREEN}✅ Profile: $PROFILE${NC}"
echo ""

# ===========================================================================
# STEP 3: Locale & Input Method
# ===========================================================================
echo -e "${BOLD}[3/4] Ngôn ngữ & bộ gõ...${NC}"
echo ""
echo -e "  ${CYAN}Chọn locale chính:${NC}"
echo -e "  ${GREEN}1${NC}. en_US.UTF-8 (English)"
echo -e "  ${GREEN}2${NC}. vi_VN.UTF-8 (Tiếng Việt)"
echo -e "  ${GREEN}3${NC}. ja_JP.UTF-8 (日本語)"
echo -e "  ${GREEN}4${NC}. zh_CN.UTF-8 (中文)"
echo ""
echo -ne "  ${YELLOW}Chọn [2]: ${NC}"
read -r LOCALE_CHOICE
LOCALE_CHOICE="${LOCALE_CHOICE:-2}"

case "$LOCALE_CHOICE" in
  1) TARGET_LOCALE="en_US.UTF-8"; INPUT_METHOD="none" ;;
  2) TARGET_LOCALE="vi_VN.UTF-8"; INPUT_METHOD="fcitx5-unikey" ;;
  3) TARGET_LOCALE="ja_JP.UTF-8"; INPUT_METHOD="fcitx5-mozc" ;;
  4) TARGET_LOCALE="zh_CN.UTF-8"; INPUT_METHOD="fcitx5-chinese" ;;
  *) TARGET_LOCALE="vi_VN.UTF-8"; INPUT_METHOD="fcitx5-unikey" ;;
esac
echo -e "  ${GREEN}✅ Locale: $TARGET_LOCALE | Input: $INPUT_METHOD${NC}"
echo ""

# ===========================================================================
# STEP 4: Generate host config & Rebuild
# ===========================================================================
echo -e "${BOLD}[4/4] Tạo cấu hình & rebuild...${NC}"

HOSTNAME=$(hostname)
HOST_DIR="$CONFIG_DIR/flake/systems/x86_64-linux/$HOSTNAME"
mkdir -p "$HOST_DIR"

# ── Tạo host default.nix ──────────────────────────────────────────
cat > "$HOST_DIR/default.nix" << HOSTEOF
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../../modules/nixos
  ];

  networking.hostName = lib.mkDefault "$HOSTNAME";
  flake.graphicsProfile = "$GPU_PROFILE";

  flake.i18n = {
    enableDeferral = false;
    targetLocale = "$TARGET_LOCALE";
  };

  flake.installer.inputMethod = "$INPUT_METHOD";

  system.stateVersion = "25.11";
}
HOSTEOF

echo -e "  ${GREEN}✅ Đã tạo $HOST_DIR/default.nix${NC}"

# ── Sinh hardware.nix ────────────────────────────────────────────
if [ ! -f "$HOST_DIR/hardware.nix" ]; then
  nixos-generate-config --root / --dir "$HOST_DIR" 2>/dev/null || true
  echo -e "  ${GREEN}✅ Đã tạo hardware.nix${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅ Setup hoàn tất!${NC}"
echo ""
echo -e "  Profile:     ${CYAN}$PROFILE${NC}"
echo -e "  GPU:         ${CYAN}$GPU_PROFILE${NC}"
echo -e "  Locale:      ${CYAN}$TARGET_LOCALE${NC}"
echo -e "  Input:       ${CYAN}$INPUT_METHOD${NC}"
echo ""
echo -e "  Chạy lệnh sau để build:"
echo -e "  ${BOLD}cd $CONFIG_DIR && sudo nixos-rebuild switch --flake .#$HOSTNAME${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -ne "  ${CYAN}Build ngay bây giờ? [Y/n]: ${NC}"
read -r BUILD_NOW
if [[ "$BUILD_NOW" =~ ^[Yy]?$ ]]; then
  cd "$CONFIG_DIR"
  sudo nixos-rebuild switch --flake ".#$HOSTNAME"
fi
