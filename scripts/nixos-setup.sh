#!/usr/bin/env bash
# =============================================================================
# SCRIPTS/NIXOS-SETUP.SH — POST-INSTALL SETUP WIZARD
# =============================================================================
# Chạy sau khi cài NixOS xong từ ISO.
# Hỏi người dùng chọn profile → detect GPU chính xác → cấu hình host →
# thiết lập máy in → GitHub SSH key.
#
# Cách dùng:
#   bash /etc/nixos-setup.sh
#   # hoặc từ ISO live environment:
#   bash ~/.config/nixos/scripts/nixos-setup.sh
# =============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; MAGENTA='\033[1;35m'; DIM='\033[2m'; NC='\033[0m'

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
echo -e "${BOLD}[1/6] Phát hiện GPU (lspci -nn)...${NC}"

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
echo -e "${BOLD}[2/6] Chọn profile sử dụng...${NC}"
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
# STEP 3: Locale & Input Method
# ======================================================================
echo -e "${BOLD}[3/6] Ngôn ngữ & bộ gõ...${NC}"
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
echo -e "${BOLD}[4/6] Tạo cấu hình host...${NC}"

HOSTNAME=$(hostname)
HOST_DIR="$CONFIG_DIR/flake/systems/x86_64-linux/$HOSTNAME"
mkdir -p "$HOST_DIR"

# ── Tạo host default.nix (có placeholder PRINTER_BLOCK) ──────────
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

  # ── Máy in (sẽ được thêm ở Step 5 nếu có) ────────────────────────
  __PRINTER_BLOCK__

  system.stateVersion = "25.11";
}
HOSTEOF
echo -e "  ${GREEN}✅ Đã tạo $HOST_DIR/default.nix${NC}"

# ── Sinh hardware.nix ────────────────────────────────────────────
if [ ! -f "$HOST_DIR/hardware.nix" ]; then
  nixos-generate-config --root / --dir "$HOST_DIR" 2>/dev/null || true
  echo -e "  ${GREEN}✅ Đã tạo hardware.nix${NC}"
fi

# ── Lưu GPU bus IDs ──────────────────────────────────────────────
if [ "$GPU_PROFILE" = "nvidia-prime" ]; then
  echo -e "  ${CYAN}📌 GPU bus IDs cho nvidia-prime:${NC}"
  echo -e "     intelBusId = \"$INTEL_NIX_BUS\""
  echo -e "     nvidiaBusId = \"$NVIDIA_NIX_BUS\""
fi

echo ""

# ======================================================================
# STEP 5: THIẾT LẬP MÁY IN (dành cho Standard & Developer profile)
# ======================================================================
echo -e "${BOLD}[5/6] Thiết lập máy in...${NC}"
echo ""

# Chỉ hỏi cho Standard/Developer (có GUI)
if [ "$VARIANT" = "minidev" ] && [ "$PROFILE" = "minimal" ]; then
  echo -e "  ${CYAN}ℹ️  Bỏ qua (Minimal profile — không GUI).${NC}"
  echo ""
else
  echo -ne "  ${CYAN}Bạn có muốn thiết lập máy in? [y/N]: ${NC}"
  read -r setup_printer
  if [[ "$setup_printer" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "  ${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "  ${BOLD}  Danh sách hãng máy in phổ biến ở Việt Nam${NC}"
    echo -e "  ${CYAN}══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${GREEN} 1${NC}. ${BOLD}HP${NC}         — LaserJet, DeskJet, Smart Tank"
    echo -e "  ${GREEN} 2${NC}. ${BOLD}Canon${NC}      — Pixma, LBP, Lide (InkJet + Laser)"
    echo -e "  ${GREEN} 3${NC}. ${BOLD}Epson${NC}      — EcoTank (L-series), WorkForce"
    echo -e "  ${GREEN} 4${NC}. ${BOLD}Brother${NC}    — HL, DCP, MFC (Laser phổ biến)"
    echo -e "  ${GREEN} 5${NC}. ${BOLD}Panasonic${NC}  — KX series (máy văn phòng)"
    echo -e "  ${GREEN} 6${NC}. ${BOLD}Xerox${NC}      — Máy in văn phòng, đa năng"
    echo -e "  ${GREEN} 7${NC}. ${BOLD}Samsung${NC}    — ML, SL series (cũ, đã ngừng SX)"
    echo -e "  ${GREEN} 8${NC}. ${BOLD}Kyocera${NC}    — ECOSYS, FS series (văn phòng)"
    echo -e "  ${GREEN} 9${NC}. ${BOLD}Ricoh${NC}      — SP, IM series (văn phòng)"
    echo -e "  ${GREEN}10${NC}. ${BOLD}OKI${NC}        — C, MC series (màu LED)"
    echo -e "  ${GREEN}11${NC}. ${BOLD}Khác${NC}       — Tự thêm driver thủ công sau"
    echo ""
    echo -ne "  ${YELLOW}Chọn hãng [1-11]: ${NC}"
    read -r PRINTER_CHOICE
    PRINTER_CHOICE="${PRINTER_CHOICE:-1}"
    echo ""

    # Map printer brand → driver packages
    PRINTER_DRIVERS=""
    PRINTER_BRAND=""
    case "$PRINTER_CHOICE" in
      1)
        PRINTER_BRAND="HP"
        PRINTER_DRIVERS="pkgs.hplip"
        echo -e "  ${GREEN}✅ HP:${NC} hplip (hỗ trợ hầu hết LaserJet, DeskJet, Smart Tank)"
        echo -e "  ${DIM}     Lưu ý: Một số HP LaserJet cực kỳ mới cần plugin riêng (hplip-plugin)${NC}"
        ;;
      2)
        PRINTER_BRAND="Canon"
        PRINTER_DRIVERS="pkgs.cnijfilter2 pkgs.cups-bjnp pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Canon:${NC} cnijfilter2 + cups-bjnp (Pixma, LBP) + gutenprint"
        ;;
      3)
        PRINTER_BRAND="Epson"
        PRINTER_DRIVERS="pkgs.epson-inkjet-printer-escpr pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Epson:${NC} epson-inkjet-printer-escpr (EcoTank) + gutenprint"
        echo -e "  ${DIM}     Lưu ý: Epson L-series phổ biến ở Việt Nam dùng ESC/P-R driver${NC}"
        ;;
      4)
        PRINTER_BRAND="Brother"
        PRINTER_DRIVERS="pkgs.brlaser pkgs.brgenml1 pkgs.brgenml1l pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Brother:${NC} brlaser + brgenml1 (HL, DCP, MFC)"
        echo -e "  ${DIM}     Một số dòng Brother cần driver riêng, kiểm tra thêm sau${NC}"
        ;;
      5)
        PRINTER_BRAND="Panasonic"
        PRINTER_DRIVERS="pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Panasonic:${NC} gutenprint (KX series dùng PCL/PostScript)"
        echo -e "  ${DIM}     Hầu hết Panasonic KX hoạt động qua PCL6/PostScript generic${NC}"
        ;;
      6)
        PRINTER_BRAND="Xerox"
        PRINTER_DRIVERS="pkgs.cups-kyocera pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Xerox:${NC} cups-kyocera + gutenprint"
        echo -e "  ${DIM}     Xerox thường dùng PostScript, driver Kyocera tương thích${NC}"
        ;;
      7)
        PRINTER_BRAND="Samsung"
        PRINTER_DRIVERS="pkgs.samsung-unified-linux-driver pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Samsung:${NC} samsung-unified-linux-driver + gutenprint"
        echo -e "  ${DIM}     Samsung ngừng sản xuất máy in 2020, HP tiếp quản. Thử hplip nếu không được${NC}"
        ;;
      8)
        PRINTER_BRAND="Kyocera"
        PRINTER_DRIVERS="pkgs.cups-kyocera pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Kyocera:${NC} cups-kyocera + gutenprint"
        echo -e "  ${DIM}     ECOSYS, FS series dùng driver Kyocera riêng${NC}"
        ;;
      9)
        PRINTER_BRAND="Ricoh"
        PRINTER_DRIVERS="pkgs.cups-ricoh pkgs.gutenprint"
        echo -e "  ${GREEN}✅ Ricoh:${NC} cups-ricoh + gutenprint"
        echo -e "  ${DIM}     SP, IM series dùng PostScript generic hoặc driver Ricoh${NC}"
        ;;
      10)
        PRINTER_BRAND="OKI"
        PRINTER_DRIVERS="pkgs.cups-oki pkgs.gutenprint"
        echo -e "  ${GREEN}✅ OKI:${NC} cups-oki + gutenprint"
        echo -e "  ${DIM}     OKI dùng công nghệ LED, driver OKI riêng${NC}"
        ;;
      11|*)
        PRINTER_BRAND="Khác (tự cấu hình)"
        PRINTER_DRIVERS="pkgs.gutenprint"
        echo -e "  ${YELLOW}ℹ️  Đã thêm gutenprint (driver generic). Cấu hình thủ công sau qua CUPS:${NC}"
        echo -e "     ${BOLD}http://localhost:631${NC}"
        ;;
    esac
    echo ""

    # Hỏi thêm model cụ thể (tuỳ chọn)
    echo -ne "  ${CYAN}Nhập model cụ thể (Enter để bỏ qua, vd: \"HP LaserJet M404dn\"): ${NC}"
    read -r PRINTER_MODEL

    # Thêm printer drivers vào host config (trước __PRINTER_BLOCK__)
    if [ -n "$PRINTER_DRIVERS" ]; then
      # Tạo block printer config
      PRINTER_BLOCK="
  # ── Máy in ($PRINTER_BRAND${PRINTER_MODEL:+ - $PRINTER_MODEL}) ────────────
  services.printing = {
    enable = true;
    drivers = [ $PRINTER_DRIVERS ];
  };
"
      # Xoá placeholder, chèn printer block trước system.stateVersion
      sed -i '/__PRINTER_BLOCK__/d' "$HOST_DIR/default.nix"
      # Dùng awk chèn block trước dòng "system.stateVersion"
      awk -v block="$PRINTER_BLOCK" '
        /system.stateVersion/ { print block; print; next }
        { print }
      ' "$HOST_DIR/default.nix" > "${HOST_DIR}/default.nix.tmp" && mv "${HOST_DIR}/default.nix.tmp" "$HOST_DIR/default.nix"

      echo -e "  ${GREEN}✅ Đã thêm driver máy in $PRINTER_BRAND vào host config${NC}"
      echo -e "  ${CYAN}📌 Để cấu hình thêm: http://localhost:631 (CUPS Web UI)${NC}"
    fi
  else
    # Xoá placeholder nếu không chọn máy in
    sed -i '/__PRINTER_BLOCK__/d' "$HOST_DIR/default.nix"
    echo -e "  ${CYAN}ℹ️  Bỏ qua máy in. Có thể cấu hình sau qua CUPS: http://localhost:631${NC}"
  fi
fi

echo ""

# ======================================================================
# STEP 6: GitHub SSH Key Setup (cho minidev / developer)
# ======================================================================
echo -e "${BOLD}[6/6] Thiết lập GitHub SSH key...${NC}"
echo ""

if [ "$VARIANT" != "minidev" ]; then
  echo -e "  ${CYAN}ℹ️  Bỏ qua (chỉ dành cho Developer profile).${NC}"
  echo ""
else
  echo -ne "  ${CYAN}Bạn có muốn thiết lập GitHub SSH key ngay? [y/N]: ${NC}"
  read -r setup_ssh
  if [[ "$setup_ssh" =~ ^[Yy]$ ]]; then
    KEYS_FILE="$CONFIG_DIR/secrets/keys.nix"
    KEYS_EXAMPLE="$CONFIG_DIR/secrets/keys.example.nix"

    if [ ! -f "$KEYS_FILE" ] && [ -f "$KEYS_EXAMPLE" ]; then
      cp "$KEYS_EXAMPLE" "$KEYS_FILE"
      echo -e "  ${GREEN}✅ Đã tạo secrets/keys.nix từ template${NC}"
    fi

    if [ -f "$KEYS_FILE" ]; then
      echo -e "  ${CYAN}Nhập đường dẫn tới SSH private key (Enter để bỏ qua):${NC}"
      echo -ne "  ${YELLOW}  [~/.ssh/id_ed25519]: ${NC}"
      read -r ssh_key_path
      ssh_key_path="${ssh_key_path:-$HOME/.ssh/id_ed25519}"
      ssh_key_path="${ssh_key_path/#\~/$HOME}"

      if [ -f "$ssh_key_path" ]; then
        SSH_KEY_CONTENT=$(cat "$ssh_key_path")
        sed -i '/github.sshKey/d' "$KEYS_FILE"
        sed -i '/^  '';/d' "$KEYS_FILE" 2>/dev/null || true
        sed -i '$i\  github.sshKey = '"'"''"'"'\'"$SSH_KEY_CONTENT"''"'"'  '"'"';' "$KEYS_FILE"
        echo -e "  ${GREEN}✅ Đã chèn GitHub SSH key vào secrets/keys.nix${NC}"

        echo -ne "  ${CYAN}GitHub username [nqnhovn]: ${NC}"
        read -r gh_user
        gh_user="${gh_user:-nqnhovn}"
        sed -i "s/github.user   = \"[^\"]*\"/github.user   = \"$gh_user\"/" "$KEYS_FILE" 2>/dev/null || \
          sed -i '$i\  github.user   = "'"$gh_user"'";' "$KEYS_FILE"

        echo -ne "  ${CYAN}GitHub email [nqnho.vn@gmail.com]: ${NC}"
        read -r gh_email
        gh_email="${gh_email:-nqnho.vn@gmail.com}"
        sed -i "s/github.email  = \"[^\"]*\"/github.email  = \"$gh_email\"/" "$KEYS_FILE" 2>/dev/null || \
          sed -i '$i\  github.email  = "'"$gh_email"'";' "$KEYS_FILE"

        chmod 600 "$ssh_key_path" 2>/dev/null || true

        echo -e "  ${CYAN}🔍 Kiểm tra kết nối GitHub...${NC}"
        if ssh -T -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -qi "successfully"; then
          echo -e "  ${GREEN}✅ GitHub SSH key hoạt động!${NC}"
        else
          echo -e "  ${YELLOW}⚠️  Không thể xác thực GitHub ngay. Kiểm tra lại sau.${NC}"
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
