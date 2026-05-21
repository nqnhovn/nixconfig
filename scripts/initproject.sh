#!/usr/bin/env bash
# =====================================================================
# SCRIPTS/INITPROJECT.SH — KHỞI TẠO DỰ ÁN MỚI TỪ TEMPLATE
# =====================================================================
# Cách dùng:
#   initproject <tên-dự-án> [đường-dẫn]
#
# Ví dụ:
#   initproject my-webapp              # Tạo ~/projects/my-webapp
#   initproject my-api ~/work/         # Tạo ~/work/my-api
# =====================================================================
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
TEMPLATE_DIR="$HOME/.config/nixos/docs/zed-agents/plan"

# ── Validate ─────────────────────────────────────────────────────
if [ $# -lt 1 ]; then
  echo "Usage: initproject <project-name> [target-dir]"
  echo "Example: initproject my-webapp"
  exit 1
fi

PROJECT_NAME="$1"
TARGET_BASE="${2:-$HOME/projects}"
TARGET_DIR="$TARGET_BASE/$PROJECT_NAME"

# ── Check template exists ───────────────────────────────────────
if [ ! -d "$TEMPLATE_DIR" ]; then
  echo -e "${YELLOW}⚠️  Template not found at $TEMPLATE_DIR${NC}"
  exit 1
fi

# ── Check target doesn't exist ──────────────────────────────────
if [ -d "$TARGET_DIR" ]; then
  echo -e "${YELLOW}⚠️  $TARGET_DIR already exists!${NC}"
  exit 1
fi

# ── Create & copy ────────────────────────────────────────────────
echo -e "${CYAN}🚀 Initializing project: ${PROJECT_NAME}${NC}"
mkdir -p "$TARGET_DIR"
cp -r "$TEMPLATE_DIR"/* "$TARGET_DIR/"
cp -r "$TEMPLATE_DIR"/.template "$TARGET_DIR/" 2>/dev/null || true

# ── Git init ─────────────────────────────────────────────────────
cd "$TARGET_DIR"
git init
git add .
git commit -m "chore(init): initialize project from Scrum template"

echo ""
echo -e "${GREEN}✅ Done! Project created at:${NC}"
echo -e "  ${CYAN}$TARGET_DIR${NC}"
echo ""
echo "📋 Next steps:"
echo "  1. cd $TARGET_DIR"
echo "  2. Điền thông tin dự án vào các file trong plan/"
echo "  3. Bắt đầu: 'Bắt đầu dự án $PROJECT_NAME' (với AI Agent)"
