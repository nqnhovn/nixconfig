#!/usr/bin/env bash
# =============================================================================
# INITIAL.SH — BOOTSTRAP NIXOS CONFIGURATION CHO LG GRAM 17 (17U70N)
# =============================================================================
# Kịch bản:
#   1. Cài NixOS mới (chưa có git, chưa có gì)
#   2. Tải repo này về dạng ZIP từ GitHub, extract vào ~/.config/nixos/
#   3. Chạy: bash ~/.config/nixos/initial.sh
#   4. Script sẽ thu thập thông tin, cấu hình & build hệ thống
# =============================================================================
set -euo pipefail

# ── Màu sắc & biểu tượng ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
ICON_OK="✅"; ICON_WARN="⚠️"; ICON_ERR="❌"; ICON_INFO="ℹ️"
ICON_ASK="❓"; ICON_ROCKET="🚀"; ICON_BOX="📦"; ICON_KEY="🔑"
ICON_GIT="🔀"; ICON_CHECK="✔️"; ICON_HOURGLASS="⏳"

# ── Banner ─────────────────────────────────────────────────────────────────
clear
echo -e "${BLUE}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║          NIXOS BOOTSTRAP — LG GRAM 17 (17U70N)          ║"
echo "  ║          NixOS 25.11 · GNOME · Wayland                  ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Kiểm tra quyền root ───────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo -e "${ICON_ERR} ${RED}Script này cần chạy với sudo.${NC}"
  echo -e "   Hãy chạy: ${BOLD}sudo bash ~/.config/nixos/initial.sh${NC}"
  exit 1
fi

# Lấy user thực đang chạy sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~$REAL_USER")
CONFIG_DIR="$REAL_HOME/.config/nixos"
NIXOS_VERSION=$(nixos-version 2>/dev/null || echo "unknown")

echo -e "${ICON_INFO} ${CYAN}User thực:${NC}    $REAL_USER"
echo -e "${ICON_INFO} ${CYAN}Home:${NC}         $REAL_HOME"
echo -e "${ICON_INFO} ${CYAN}Config dir:${NC}   $CONFIG_DIR"
echo -e "${ICON_INFO} ${CYAN}NixOS phiên bản:${NC} $NIXOS_VERSION"
echo ""

# ── SECTION 1: Kiểm tra môi trường ────────────────────────────────────────
echo -e "${BOLD}━━━ SECTION 1: KIỂM TRA MÔI TRƯỜNG ━━━${NC}"
echo ""

# Kiểm tra config dir tồn tại
if [[ ! -d "$CONFIG_DIR" ]]; then
  echo -e "${ICON_ERR} ${RED}Thư mục $CONFIG_DIR không tồn tại.${NC}"
  echo -e "   Hãy extract file ZIP từ GitHub vào ${BOLD}~/.config/nixos/${NC} trước."
  exit 1
fi

# Kiểm tra các file cần thiết
REQUIRED_FILES=("flake.nix" "configuration.nix" "home.nix")
MISSING=()
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$CONFIG_DIR/$f" ]]; then
    MISSING+=("$f")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo -e "${ICON_ERR} ${RED}Thiếu file bắt buộc:${NC} ${MISSING[*]}"
  echo -e "   Hãy đảm bảo bạn đã extract ${BOLD}toàn bộ${NC} file từ repo."
  exit 1
fi
echo -e "${ICON_OK} ${GREEN}Tất cả file cấu hình đều có mặt.${NC}"

# Kiểm tra hardware-configuration.nix
if [[ ! -f /etc/nixos/hardware-configuration.nix ]] && [[ ! -f "$CONFIG_DIR/hardware-configuration.nix" ]]; then
  echo -e "${ICON_WARN} ${YELLOW}Chưa có hardware-configuration.nix. Đang tạo...${NC}"
  nixos-generate-config --root / 2>/dev/null || nixos-generate-config
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    cp /etc/nixos/hardware-configuration.nix "$CONFIG_DIR/hardware-configuration.nix"
    echo -e "${ICON_OK} ${GREEN}Đã tạo & copy hardware-configuration.nix.${NC}"
  else
    echo -e "${ICON_ERR} ${RED}Không thể tạo hardware-configuration.nix. Thoát.${NC}"
    exit 1
  fi
else
  echo -e "${ICON_OK} ${GREEN}hardware-configuration.nix đã có.${NC}"
fi

echo ""

# ── SECTION 2: Thu thập thông tin ─────────────────────────────────────────
echo -e "${BOLD}━━━ SECTION 2: THU THẬP THÔNG TIN ━━━${NC}"
echo ""

# Hostname
CURRENT_HOSTNAME=$(hostname 2>/dev/null || echo "lg")
echo -ne "${ICON_ASK} ${CYAN}Tên máy (hostname) [$CURRENT_HOSTNAME]:${NC} "
read -r INPUT_HOSTNAME
HOSTNAME="${INPUT_HOSTNAME:-$CURRENT_HOSTNAME}"

# Git user name
echo -ne "${ICON_ASK} ${CYAN}Tên Git user [nqnhovn]:${NC} "
read -r INPUT_GIT_NAME
GIT_NAME="${INPUT_GIT_NAME:-nqnhovn}"

# Git email
echo -ne "${ICON_ASK} ${CYAN}Email Git [nqnho.vn@gmail.com]:${NC} "
read -r INPUT_GIT_EMAIL
GIT_EMAIL="${INPUT_GIT_EMAIL:-nqnho.vn@gmail.com}"

# Timezone
echo -ne "${ICON_ASK} ${CYAN}Timezone [Asia/Ho_Chi_Minh]:${NC} "
read -r INPUT_TZ
TIMEZONE="${INPUT_TZ:-Asia/Ho_Chi_Minh}"

echo ""
echo -e "${BOLD}── Thông tin đã nhập ──${NC}"
echo -e "  Hostname : ${GREEN}$HOSTNAME${NC}"
echo -e "  Git name : ${GREEN}$GIT_NAME${NC}"
echo -e "  Git email: ${GREEN}$GIT_EMAIL${NC}"
echo -e "  Timezone : ${GREEN}$TIMEZONE${NC}"
echo ""

# ── SECTION 3: Cập nhật cấu hình với thông tin đã nhập ───────────────────
echo -e "${BOLD}━━━ SECTION 3: CẬP NHẬT CẤU HÌNH ━━━${NC}"
echo ""

# Cập nhật hostname trong configuration.nix
sed -i "s/networking.hostName = \".*\";/networking.hostName = \"$HOSTNAME\";/" "$CONFIG_DIR/configuration.nix"
echo -e "${ICON_OK} ${GREEN}Đã cập nhật hostname → $HOSTNAME${NC}"

# Cập nhật git user trong home.nix
sed -i "s/name = \".*\";/name = \"$GIT_NAME\";/" "$CONFIG_DIR/home.nix"
sed -i "s/email = \".*\";/email = \"$GIT_EMAIL\";/" "$CONFIG_DIR/home.nix"
echo -e "${ICON_OK} ${GREEN}Đã cập nhật Git user → $GIT_NAME <$GIT_EMAIL>${NC}"

# Cập nhật timezone
sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$TIMEZONE\";|" "$CONFIG_DIR/configuration.nix"
echo -e "${ICON_OK} ${GREEN}Đã cập nhật timezone → $TIMEZONE${NC}"

echo ""

# ── SECTION 4: Cài đặt git & công cụ cơ bản ───────────────────────────────
echo -e "${BOLD}━━━ SECTION 4: CÀI ĐẶT CÔNG CỤ CƠ BẢN ━━━${NC}"
echo ""

if command -v git &>/dev/null; then
  echo -e "${ICON_OK} ${GREEN}Git đã được cài đặt.${NC}"
else
  echo -e "${ICON_HOURGLASS} ${YELLOW}Đang cài git...${NC}"
  nix-env -iA nixos.git 2>/dev/null || nix profile install nixpkgs#git 2>/dev/null || {
    echo -e "${ICON_WARN} ${YELLOW}Không thể cài git qua nix. Thử dùng nix-shell tạm.${NC}"
  }
fi

# Khởi tạo git repo nếu chưa có
if [[ ! -d "$CONFIG_DIR/.git" ]]; then
  echo -e "${ICON_HOURGLASS} ${YELLOW}Đang khởi tạo git repo trong $CONFIG_DIR...${NC}"
  cd "$CONFIG_DIR"
  git init
  git add .
  git commit -m "Initial commit: NixOS configuration for LG Gram 17"
  echo -e "${ICON_OK} ${GREEN}Đã khởi tạo git repo & commit lần đầu.${NC}"
else
  echo -e "${ICON_OK} ${GREEN}Git repo đã tồn tại.${NC}"
fi

echo ""

# ── SECTION 5: Thiết lập SSH cho GitHub ───────────────────────────────────
echo -e "${BOLD}━━━ SECTION 5: THIẾT LẬP SSH CHO GITHUB ━━━${NC}"
echo ""

SSH_KEY="$REAL_HOME/.ssh/id_ed25519"

echo -ne "${ICON_ASK} ${CYAN}Bạn có muốn tạo SSH key cho GitHub không? [Y/n]:${NC} "
read -r SETUP_SSH
SETUP_SSH="${SETUP_SSH:-y}"

if [[ "$SETUP_SSH" =~ ^[Yy]$ ]]; then
  if [[ ! -f "$SSH_KEY" ]]; then
    echo -e "${ICON_HOURGLASS} ${YELLOW}Đang tạo SSH key ed25519...${NC}"
    sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.ssh"
    sudo -u "$REAL_USER" ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N "" 2>/dev/null
    echo -e "${ICON_OK} ${GREEN}Đã tạo SSH key tại $SSH_KEY${NC}"
  else
    echo -e "${ICON_OK} ${GREEN}SSH key đã tồn tại.${NC}"
  fi

  echo ""
  echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  PUBLIC KEY — Copy key này vào GitHub:${NC}"
  echo -e "${BOLD}  Settings → SSH and GPG keys → New SSH key${NC}"
  echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  cat "${SSH_KEY}.pub"
  echo ""
  echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  # Cấu hình ~/.ssh/config
  SSH_CONFIG="$REAL_HOME/.ssh/config"
  if [[ ! -f "$SSH_CONFIG" ]] || ! grep -q "github.com" "$SSH_CONFIG" 2>/dev/null; then
    sudo -u "$REAL_USER" bash -c "cat >> $SSH_CONFIG << 'SSHEOF'

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
SSHEOF"
    echo -e "${ICON_OK} ${GREEN}Đã cấu hình ~/.ssh/config cho GitHub.${NC}"
  fi

  echo ""
  echo -e "${ICON_WARN} ${YELLOW}Sau khi thêm key vào GitHub, chạy lệnh này để kiểm tra:${NC}"
  echo -e "  ${BOLD}ssh -T git@github.com${NC}"
else
  echo -e "${ICON_INFO} Bỏ qua thiết lập SSH."
fi

echo ""

# ── SECTION 6: XÁC NHẬN & BUILD ───────────────────────────────────────────
echo -e "${BOLD}━━━ SECTION 6: XÁC NHẬN CUỐI CÙNG ━━━${NC}"
echo ""

echo -e "${BOLD}── Tóm tắt cấu hình trước khi build ──${NC}"
echo -e "  • Hostname        : $HOSTNAME"
echo -e "  • User            : $REAL_USER"
echo -e "  • Git             : $GIT_NAME <$GIT_EMAIL>"
echo -e "  • Timezone        : $TIMEZONE"
echo -e "  • SSH key         : ${SSH_KEY}.pub"
echo -e "  • Desktop         : GNOME 49 + Wayland"
echo -e "  • GPU             : Intel UHD + NVIDIA GTX 1650 (PRIME offload)"
echo -e "  • Boot            : systemd-boot + Plymouth (LG logo, không chữ)"
echo -e "  • Sleep           : Hibernate (KHÔNG suspend — fix bàn phím LG Gram)"
echo -e "  • Bluetooth       : KHÔNG tự bật khi khởi động"
echo -e "  • Pin             : TLP tối ưu (CPU 60%, ASPM, USB autosuspend)"
echo -e "  • Shell           : Zsh + Starship (không oh-my-zsh)"
echo -e "  • Dev tools       : devbox + direnv + distrobox + podman"
echo -e "  • Editor          : Zed + Vim"
echo -e "  • Browser         : Firefox (tối ưu pin + bảo mật)"
echo ""
echo -e "${BOLD}${YELLOW}⚠️  LƯU Ý QUAN TRỌNG TRƯỚC KHI BUILD:${NC}"
echo -e "  1. Đảm bảo ${BOLD}hardware-configuration.nix${NC} đúng với máy của bạn"
echo -e "  2. Kiểm tra UUID phân vùng swap trong configuration.nix"
echo -e "     Hiện tại: /dev/disk/by-uuid/4b931d72-02dd-4925-b788-042205a0e393"
echo -e "  3. Nếu UUID khác, sửa dòng ${BOLD}boot.resumeDevice${NC} trong configuration.nix"
echo ""

echo -ne "${ICON_ASK} ${CYAN}${BOLD}Bắt đầu build hệ thống ngay bây giờ? [Y/n]:${NC} "
read -r START_BUILD
START_BUILD="${START_BUILD:-y}"

if [[ ! "$START_BUILD" =~ ^[Yy]$ ]]; then
  echo -e "${ICON_INFO} Đã hủy. Bạn có thể build sau bằng lệnh:"
  echo -e "  ${BOLD}sudo nixos-rebuild switch --flake $CONFIG_DIR/#lg${NC}"
  echo -e "${ICON_OK} ${GREEN}Hoàn tất thiết lập!${NC}"
  exit 0
fi

# ── SECTION 7: BUILD HỆ THỐNG ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━ SECTION 7: BUILD HỆ THỐNG ━━━${NC}"
echo ""
echo -e "${ICON_ROCKET} ${CYAN}${BOLD}Đang build NixOS... Lần đầu có thể mất 10-30 phút.${NC}"
echo -e "   (Các lần sau sẽ nhanh hơn nhờ cache)"
echo ""

# Chạy build với label
BUILD_LABEL="initial-bootstrap-$(date +%Y%m%d-%H%M%S)"
echo -e "${ICON_HOURGLASS} Đang chạy nixos-rebuild switch..."
if sudo NIXOS_LABEL="$BUILD_LABEL" nixos-rebuild switch --flake "$CONFIG_DIR/#$HOSTNAME" 2>&1; then
  echo ""
  echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${GREEN}  ✅ BUILD THÀNH CÔNG!${NC}"
  echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BOLD}── Các bước tiếp theo ──${NC}"
  echo -e "  1. ${BOLD}Reboot${NC} để áp dụng toàn bộ thay đổi:"
  echo -e "     ${CYAN}sudo reboot${NC}"
  echo -e ""
  echo -e "  2. Sau reboot, nếu có SSH key, đẩy lên GitHub:"
  echo -e "     ${CYAN}cd ~/.config/nixos${NC}"
  echo -e "     ${CYAN}gh auth login${NC}"
  echo -e "     ${CYAN}gh repo create nixos-config --public --source=. --remote=origin --push${NC}"
  echo -e ""
  echo -e "  3. Các alias hữu ích sau reboot:"
  echo -e "     ${CYAN}update${NC}  → rebuild hệ thống"
  echo -e "     ${CYAN}build \"message\"${NC} → git commit + rebuild"
  echo -e "     ${CYAN}clean${NC}   → dọn garbage collection"
  echo -e ""
  echo -e "  4. Xem README.md để biết thêm chi tiết:"
  echo -e "     ${CYAN}less ~/.config/nixos/README.md${NC}"
else
  echo ""
  echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${RED}  ❌ BUILD THẤT BẠI${NC}"
  echo -e "${BOLD}${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${YELLOW}  Gợi ý khắc phục:${NC}"
  echo -e "  • Kiểm tra hardware-configuration.nix đã đúng chưa"
  echo -e "  • Chạy ${BOLD}sudo nixos-rebuild switch --show-trace${NC} để xem lỗi chi tiết"
  echo -e "  • Rollback nếu cần: ${BOLD}sudo nixos-rebuild switch --rollback${NC}"
  exit 1
fi
