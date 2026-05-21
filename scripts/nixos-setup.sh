#!/usr/bin/env bash
# =============================================================================
# SCRIPTS/NIXOS-SETUP.SH — POST-INSTALL SETUP WIZARD
# =============================================================================
# Chạy sau khi cài NixOS xong từ ISO.
# Hỏi người dùng chọn profile → detect GPU chính xác → cấu hình host → GitHub SSH.
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

# ======================================================================
# HÀM: Chuyển PCI bus từ dạng "00:02.0" → "PCI:0:2:0"
# ======================================================================
convert_bus() {
  local bus="$1"
  if [[ "$bus" =~ ^([0-9a-fA-F]{2}):([0-9a-fA-F]{2})\.([0-9])$ ]]; then
    printf "PCI:%d:%d:%d" "$((16#${BASH_REMATCH[1]}))" "$((16#${BASH_REMATCH[2]}))" "${BASH_REMATCH[3]}"
  else
    echo "PCI:0:2:0"  # fallback
  fi
}

# ======================================================================
# STEP 1: Detect GPU chính xác (PCI IDs + Bus IDs)
# ======================================================================
echo -e "${BOLD}[1/5] Phát hiện GPU (lspci -nn)...${NC}"

HAS_NVIDIA=false
HAS_INTEL=false
HAS_AMD=false
INTEL_BUS=""; NVIDIA_BUS=""; AMD_BUS=""
INTEL_ID=""; NVIDIA_ID=""; AMD_ID=""

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  BUS=$(echo "$line" | awk '{print $1}')
  HW_ID=$(echo "$line" | grep -oP '\[([0-9a-fA-F]{4}:[0-9a-fA-F]{4})\]' | tail -1 | tr -d '[]')
  DESC=$(echo "$line" | sed 's/.*]: //' | sed 's/ (rev.*//')
  if echo "$line" | grep -qi "NVIDIA"; then
    HAS_NVIDIA=true; NVIDIA_BUS="$BUS"; NVIDIA_ID="$HW_ID"
    echo -e "  ${GREEN}✅ NVIDIA:${NC} $DESC  ${DIM}($HW_ID @ $BUS)${NC}"
  elif echo "$line" | grep -qiE "Intel.*(VGA|Display|3D)"; then
    HAS_INTEL=true; INTEL_BUS="$BUS"; INTEL_ID="$HW_ID"
    echo -e "  ${GREEN}✅ Intel:${NC}  $DESC  ${DIM}($HW_ID @ $BUS)${NC}"
  elif echo "$line" | grep -qiE "AMD|Radeon"; then
    HAS_AMD=true; AMD_BUS="$BUS"; AMD_ID="$HW_ID"
    echo -e "  ${GREEN}✅ AMD:${NC}    $DESC  ${DIM}($HW_ID @ $BUS)${NC}"
  fi
done < <(lspci -nn | grep -iE "VGA|3D|Display" 2>/dev/null || true)

# Chuyển bus IDs sang NixOS format (PCI:x:y:z)
INTEL_NIX_BUS=$(convert_bus "${INTEL_BUS:-00:02.0}")
NVIDIA_NIX_BUS=$(convert_bus "${NVIDIA_BUS:-00:00.0}")
AMD_NIX_BUS=$(convert_bus "${AMD_BUS:-00:00.0}")

# Quyết định graphics profile
if $HAS_NVIDIA && $HAS_INTEL; then
  GPU_PROFILE="nvidia-prime"
  echo -e "  ${CYAN}🎨 Profile: nvidia-prime${NC}"
  echo -e "     Intel Bus: ${BOLD}$INTEL_NIX_BUS${NC}  |  NVIDIA Bus: ${BOLD}$NVIDIA_NIX_BUS${NC}"
elif $HAS_NVIDIA; then
  GPU_PROFILE="nvidia-prime"
  echo -e "  ${CYAN}🎨 Profile: nvidia-prime${NC}"
  echo -e "     NVIDIA Bus: ${BOLD}$NVIDIA_NIX_BUS${NC}"
elif $HAS_AMD || $HAS_INTEL; then
  GPU_PROFILE="intel-only"
  echo -e "  ${CYAN}🎨 Profile: intel-only${NC}"
else
  GPU_PROFILE="headless"
  echo -e "  ${CYAN}🎨 Profile: headless${NC}"
fi
echo ""

# ======================================================================
# STEP 2: Chọn profile sử dụng
# ======================================================================
echo -e "${BOLD}[2/5] Chọn profile sử dụng...${NC}"
echo ""
echo -e "  ${GREEN}1${NC}. ${CYAN}Standard${NC}     — Desktop cơ bản (GNOME + WPS Office)"
echo -e "  ${GREEN}2${NC}. ${CYAN}Developer${NC}    — Dev tools (Go, Node, Python, Podman, Zed)"
echo -e "  ${GREEN}3${NC}. ${CYAN}Minimal${NC}      — Server, không GUI"
echo ""
echo -ne "  ${YELLOW}Chọn [1]: ${NC}"
read -r PROFILE_CHOICE
PROFILE_CHOICE="${PROFILE_CHOICE:-1}"

case "$PROFILE_CHOICE" in
  1) PROFILE="standard"; VARIANT="standard" ;;
  2) PROFILE="developer"; VARIANT="minidev" ;;
  3) PROFILE="minimal"; VARIANT="minidev" ;;
  *) PROFILE="standard"; VARIANT="standard" ;;
esac
echo -e "  ${GREEN}✅ Profile: $PROFILE (variant: $VARIANT)${NC}"
echo ""

# ======================================================================
# STEP 3: Locale & Input Method (thêm fcitx5-english)
# ======================================================================
echo -e "${BOLD}[3/5] Ngôn ngữ & bộ gõ...${NC}"
echo ""
echo -e "  ${CYAN}Chọn locale & input method:${NC}"
echo -e "  ${GREEN}1${NC}. en_US.UTF-8  — Không bộ gõ"
echo -e "  ${GREEN}2${NC}. vi_VN.UTF-8  — ${BOLD}fcitx5-unikey${NC} (mặc định)"
echo -e "  ${GREEN}3${NC}. en_US.UTF-8  — ${BOLD}fcitx5-english${NC}"
echo -e "  ${GREEN}4${NC}. ja_JP.UTF-8  — fcitx5-mozc"
echo -e "  ${GREEN}5${NC}. zh_CN.UTF-8  — fcitx5-chinese"
echo ""
echo -ne "  ${YELLOW}Chọn [2]: ${NC}"
read -r LOCALE_CHOICE
LOCALE_CHOICE="${LOCALE_CHOICE:-2}"

case "$LOCALE_CHOICE" in
  1) TARGET_LOCALE="en_US.UTF-8"; INPUT_METHOD="none" ;;
  2) TARGET_LOCALE="vi_VN.UTF-8"; INPUT_METHOD="fcitx5-unikey" ;;
  3) TARGET_LOCALE="en_US.UTF-8"; INPUT_METHOD="fcitx5-english" ;;
  4) TARGET_LOCALE="ja_JP.UTF-8"; INPUT_METHOD="fcitx5-mozc" ;;
  5) TARGET_LOCALE="zh_CN.UTF-8"; INPUT_METHOD="fcitx5-chinese" ;;
  *) TARGET_LOCALE="vi_VN.UTF-8"; INPUT_METHOD="fcitx5-unikey" ;;
esac
echo -e "  ${GREEN}✅ Locale: $TARGET_LOCALE | Input: $INPUT_METHOD${NC}"
echo ""

# ======================================================================
# STEP 4: Generate host config (với PCI bus IDs chính xác)
# ======================================================================
echo -e "${BOLD}[4/5] Tạo cấu hình host...${NC}"

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

# ── Lưu GPU config cho nvidia-prime ────────────────────────────────
# (graphics profile sẽ dùng các bus ID này nếu cần)
if [ "$GPU_PROFILE" = "nvidia-prime" ]; then
  echo -e "  ${CYAN}📌 GPU bus IDs cho nvidia-prime:${NC}"
  echo -e "     intelBusId = \"$INTEL_NIX_BUS\""
  echo -e "     nvidiaBusId = \"$NVIDIA_NIX_BUS\""
  echo -e "  ${YELLOW}⚠️  Hãy kiểm tra và cập nhật trong hardware.nix nếu cần${NC}"
fi

echo ""

# ======================================================================
# STEP 5: GitHub SSH Key Setup (cho minidev / developer)
# ======================================================================
echo -e "${BOLD}[5/5] Thiết lập GitHub SSH key...${NC}"
echo ""

# Chỉ hỏi cho Developer profile
if [ "$VARIANT" != "minidev" ]; then
  echo -e "  ${CYAN}ℹ️  Bỏ qua (chỉ dành cho Developer profile).${NC}"
  echo ""
else
  echo -ne "  ${CYAN}Bạn có muốn thiết lập GitHub SSH key ngay? [y/N]: ${NC}"
  read -r setup_ssh
  if [[ "$setup_ssh" =~ ^[Yy]$ ]]; then
    KEYS_FILE="$CONFIG_DIR/secrets/keys.nix"
    KEYS_EXAMPLE="$CONFIG_DIR/secrets/keys.example.nix"

    # Tạo keys.nix từ example nếu chưa có
    if [ ! -f "$KEYS_FILE" ] && [ -f "$KEYS_EXAMPLE" ]; then
      cp "$KEYS_EXAMPLE" "$KEYS_FILE"
      echo -e "  ${GREEN}✅ Đã tạo secrets/keys.nix từ template${NC}"
    fi

    if [ -f "$KEYS_FILE" ]; then
      # Hỏi đường dẫn SSH key
      echo -e "  ${CYAN}Nhập đường dẫn tới SSH private key (Enter để bỏ qua):${NC}"
      echo -ne "  ${YELLOW}  [~/.ssh/id_ed25519]: ${NC}"
      read -r ssh_key_path
      ssh_key_path="${ssh_key_path:-$HOME/.ssh/id_ed25519}"
      ssh_key_path="${ssh_key_path/#\~/$HOME}"

      if [ -f "$ssh_key_path" ]; then
        SSH_KEY_CONTENT=$(cat "$ssh_key_path")
        # Cập nhật keys.nix với SSH key
        sed -i '/github.sshKey/d' "$KEYS_FILE"
        sed -i '/^  '';/d' "$KEYS_FILE" 2>/dev/null || true
        # Chèn trước dòng cuối cùng
        sed -i '$i\  github.sshKey = '"'"''"'"'\'"$SSH_KEY_CONTENT"''"'"'  '"'"';' "$KEYS_FILE"
        echo -e "  ${GREEN}✅ Đã chèn GitHub SSH key vào secrets/keys.nix${NC}"

        # Hỏi GitHub username
        echo -ne "  ${CYAN}GitHub username [nqnhovn]: ${NC}"
        read -r gh_user
        gh_user="${gh_user:-nqnhovn}"
        sed -i "s/github.user   = \"[^\"]*\"/github.user   = \"$gh_user\"/" "$KEYS_FILE" 2>/dev/null || \
          sed -i '$i\  github.user   = "'"$gh_user"'";' "$KEYS_FILE"

        # Hỏi GitHub email
        echo -ne "  ${CYAN}GitHub email [nqnho.vn@gmail.com]: ${NC}"
        read -r gh_email
        gh_email="${gh_email:-nqnho.vn@gmail.com}"
        sed -i "s/github.email  = \"[^\"]*\"/github.email  = \"$gh_email\"/" "$KEYS_FILE" 2>/dev/null || \
          sed -i '$i\  github.email  = "'"$gh_email"'";' "$KEYS_FILE"

        # Phân quyền SSH key
        chmod 600 "$ssh_key_path" 2>/dev/null || true

        # Kiểm tra SSH key
        echo -e "  ${CYAN}🔍 Kiểm tra kết nối GitHub...${NC}"
        if ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -qi "successfully"; then
          echo -e "  ${GREEN}✅ GitHub SSH key hoạt động!${NC}"
        else
          echo -e "  ${YELLOW}⚠️  Không thể xác thực GitHub
 ngay. Kiểm tra lại sau.${NC}"
        fi
      else
        echo -e "  ${YELLOW}⚠️  Không tìm thấy SSH key tại: $ssh_key_path${NC}"
        echo -e "  ${CYAN}Bạn có thể tạo key mới không? [y/N]: ${NC}"
        read -r create_key
        if [[ "$create_key" =~ ^[Yy]$ ]]; then
          ssh-keygen -t ed25519 -C "$gh_email" -f "$ssh_key_path" -N ""
          echo -e "  ${GREEN}✅ Đã tạo SSH key: $ssh_key_path${NC}"
          echo -e "  ${YELLOW}📋 Public key (thêm vào GitHub):${NC}"
          cat "${ssh_key_path}.pub"
        fi
      fi
    else
      echo -e "  ${YELLOW}⚠️  Không tìm thấy secrets/keys.example.nix. Bỏ qua.${NC}"
    fi
  fi
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
