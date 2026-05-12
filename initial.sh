#!/usr/bin/env bash
# =============================================================================
# INITIAL.SH — NIXOS BOOTSTRAP CHO LG GRAM 17
# =============================================================================
# Cách dùng:
#   sudo bash ~/.config/nixos/initial.sh
#
# Kịch bản: Máy NixOS mới cài, chưa có git, chưa có gì.
# Tải repo này về (ZIP), extract vào ~/.config/nixos/, chạy script này.
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
echo "  ║       NIXOS BOOTSTRAP — LG GRAM 17 (17U70N)         ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  User: ${GREEN}$REAL_USER${NC}  |  Config: ${GREEN}$CONFIG_DIR${NC}"
echo ""

# ── Step 1: Tạo hardware-config nếu chưa có ───────────────────────────────
echo -e "${BOLD}[1/4] Kiểm tra hardware-config...${NC}"
if [[ ! -f "$CONFIG_DIR/hosts/lg/hardware.nix" ]]; then
  echo -e "  ${YELLOW}Đang tạo hardware-configuration.nix...${NC}"
  nixos-generate-config --root / 2>/dev/null || nixos-generate-config
  if [[ -f /etc/nixos/hardware-configuration.nix ]]; then
    cp /etc/nixos/hardware-configuration.nix "$CONFIG_DIR/hosts/lg/hardware.nix"
    echo -e "  ${GREEN}Đã tạo hosts/lg/hardware.nix${NC}"
  fi
else
  echo -e "  ${GREEN}Đã có hardware.nix${NC}"
fi

# ── Step 2: Cài git nếu chưa có ───────────────────────────────────────────
echo -e "${BOLD}[2/4] Cài đặt công cụ cơ bản...${NC}"
if ! command -v git &>/dev/null; then
  echo -e "  ${YELLOW}Đang cài git...${NC}"
  nix profile install nixpkgs#git 2>/dev/null || nix-env -iA nixos.git 2>/dev/null || true
fi
command -v git &>/dev/null && echo -e "  ${GREEN}git: OK${NC}" || echo -e "  ${YELLOW}git: sẽ dùng từ nix-shell${NC}"

if ! command -v gnumake &>/dev/null && ! command -v make &>/dev/null; then
  echo -e "  ${YELLOW}Đang cài gnumake...${NC}"
  nix profile install nixpkgs#gnumake 2>/dev/null || nix-env -iA nixos.gnumake 2>/dev/null || true
fi
command -v make &>/dev/null && echo -e "  ${GREEN}make: OK${NC}" || echo -e "  ${YELLOW}make: sẽ dùng từ nix-shell${NC}"

# ── Step 3: Khởi tạo git repo ─────────────────────────────────────────────
echo -e "${BOLD}[3/4] Khởi tạo git repository...${NC}"
if [[ ! -d "$CONFIG_DIR/.git" ]]; then
  cd "$CONFIG_DIR"
  git init && git add . && git commit -m "Initial: NixOS config for LG Gram 17" --quiet
  echo -e "  ${GREEN}Đã git init + commit lần đầu${NC}"
else
  echo -e "  ${GREEN}Git repo đã tồn tại${NC}"
fi

# ── Step 4: Sửa quyền sở hữu + chạy Makefile ──────────────────────────────
echo -e "${BOLD}[4/4] Chuẩn bị & chạy Makefile...${NC}"
chown -R "$REAL_USER:users" "$CONFIG_DIR" 2>/dev/null || true
chmod +x "$CONFIG_DIR/initial.sh" "$CONFIG_DIR/search.py" 2>/dev/null || true

echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅ Bootstrap hoàn tất!                          ${NC}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Bây giờ chạy:"
echo -e "  ${BOLD}cd ~/.config/nixos && make${NC}"
echo ""
echo -e "  Hoặc build ngay:"
echo -e "  ${BOLD}cd ~/.config/nixos && make switch${NC}"
echo ""

echo -ne "${CYAN}Bạn có muốn mở Makefile Dashboard ngay bây giờ? [Y/n]: ${NC}"
read -r answer
if [[ "$answer" =~ ^[Yy]?$ ]]; then
  cd "$CONFIG_DIR"
  sudo -u "$REAL_USER" make list 2>/dev/null || make list 2>/dev/null || {
    echo -e "${YELLOW}Không chạy được make. Hãy chạy thủ công:${NC}"
    echo -e "  cd ~/.config/nixos && make"
  }
fi
