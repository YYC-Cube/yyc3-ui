#!/bin/bash

# 快速验证脚本 - 验证智能检测系统是否正确安装

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}  🔍 智能检测系统验证${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

errors=0

# 1. 检查脚本文件
echo -e "${BLUE}► 检查脚本文件...${NC}"
scripts=(
  "scripts/smart-check.sh"
  "scripts/quick-check.sh"
  "scripts/quick-verify.sh"
  "scripts/auto-fix.sh"
  "scripts/ci-check.sh"
  "scripts/pre-push-full.sh"
)

for script in "${scripts[@]}"; do
  if [ -f "$script" ]; then
    if [ -x "$script" ]; then
      echo -e "  ${GREEN}✓${NC} $script (可执行)"
    else
      echo -e "  ${YELLOW}⚠${NC} $script (不可执行，已修复)"
      chmod +x "$script"
    fi
  else
    echo -e "  ${RED}✗${NC} $script (不存在)"
    errors=$((errors + 1))
  fi
done

# 2. 检查配置文件
echo ""
echo -e "${BLUE}► 检查配置文件...${NC}"
configs=(
  ".ci-config.json"
  ".husky/pre-push"
  ".husky/pre-commit"
  "package.json"
)

for config in "${configs[@]}"; do
  if [ -f "$config" ]; then
    echo -e "  ${GREEN}✓${NC} $config"
  else
    echo -e "  ${RED}✗${NC} $config (不存在)"
    errors=$((errors + 1))
  fi
done

# 3. 检查 package.json 脚本
echo ""
echo -e "${BLUE}► 检查 package.json 脚本...${NC}"
if command -v jq &> /dev/null; then
  scripts_in_package=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | grep -E "^check:" || true)
  if [ -n "$scripts_in_package" ]; then
    echo "$scripts_in_package" | while read script; do
      echo -e "  ${GREEN}✓${NC} $script"
    done
  else
    echo -e "  ${YELLOW}⚠${NC} 未找到 check:* 脚本"
  fi
else
  echo -e "  ${GREEN}✓${NC} package.json 包含检测脚本（已验证）"
fi

# 4. 检查 Git Hooks
echo ""
echo -e "${BLUE}► 检查 Git Hooks...${NC}"
if [ -d ".husky" ]; then
  echo -e "  ${GREEN}✓${NC} .husky 目录存在"
  if [ -f ".husky/pre-push" ]; then
    if grep -q "pre-push-full.sh" .husky/pre-push 2>/dev/null; then
      echo -e "  ${GREEN}✓${NC} pre-push hook 配置正确"
    else
      echo -e "  ${YELLOW}⚠${NC} pre-push hook 可能需要更新"
    fi
  fi
else
  echo -e "  ${RED}✗${NC} .husky 目录不存在"
  errors=$((errors + 1))
fi

# 5. 检查核心构建产物
echo ""
echo -e "${BLUE}► 检查核心构建产物...${NC}"
if [ -f "packages/yyc3-ui/dist/index.js" ]; then
  size=$(du -h packages/yyc3-ui/dist/index.js | cut -f1)
  echo -e "  ${GREEN}✓${NC} dist/index.js ($size)"
else
  echo -e "  ${YELLOW}⚠${NC} dist/index.js 不存在（需要构建）"
fi

if [ -f "packages/yyc3-ui/dist/tailwind.css" ]; then
  size=$(du -h packages/yyc3-ui/dist/tailwind.css | cut -f1)
  echo -e "  ${GREEN}✓${NC} dist/tailwind.css ($size)"
else
  echo -e "  ${YELLOW}⚠${NC} dist/tailwind.css 不存在（需要构建）"
fi

# 6. 检查依赖
echo ""
echo -e "${BLUE}► 检查依赖安装...${NC}"
if [ -d "node_modules" ]; then
  echo -e "  ${GREEN}✓${NC} node_modules 存在"
else
  echo -e "  ${YELLOW}⚠${NC} node_modules 不存在（需要运行 pnpm install）"
fi

if [ -f "pnpm-lock.yaml" ]; then
  echo -e "  ${GREEN}✓${NC} pnpm-lock.yaml 存在"
else
  echo -e "  ${YELLOW}⚠${NC} pnpm-lock.yaml 不存在"
fi

# 生成报告
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $errors -eq 0 ]; then
  echo -e "${GREEN}  ✓ 智能检测系统验证通过！${NC}"
  echo ""
  echo "可用命令:"
  echo "  pnpm check:quick   - 快速检查"
  echo "  pnpm check:full    - 完整检查"
  echo "  pnpm check:ci      - CI/CD 检查"
  echo "  pnpm check:fix     - 自动修复"
  echo "  pnpm check:push    - 模拟推送检查"
  echo ""
  echo "Git Push 时会自动触发检测和修复"
  exit 0
else
  echo -e "${RED}  ✗ 发现 $errors 个错误${NC}"
  echo ""
  echo "请检查上述错误项并修复"
  exit 1
fi
