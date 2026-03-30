#!/bin/bash

# 快速检查脚本（跳过耗时操作）
# 用于快速验证代码质量

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  快速代码质量检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FAILED=0

# 1. TypeScript 类型检查
echo ""
log_info "检查 TypeScript 类型..."
if pnpm --filter=yyc3-ui typecheck 2>&1 | grep -q "error TS"; then
    log_error "TypeScript 类型错误"
    FAILED=1
else
    log_success "TypeScript 类型检查通过"
fi

# 2. ESLint 检查
echo ""
log_info "检查代码规范..."
if pnpm lint 2>&1 | grep -E "(error|Error)" | grep -v "0 errors"; then
    log_error "ESLint 检查失败"
    FAILED=1
else
    log_success "代码规范检查通过"
fi

# 3. 核心文件存在性检查
echo ""
log_info "检查核心文件..."
if [ -f "packages/yyc3-ui/dist/index.js" ] && [ -f "packages/yyc3-ui/dist/tailwind.css" ]; then
    log_success "核心文件存在"
else
    log_error "核心文件缺失，请先构建"
    FAILED=1
fi

# 4. Git 状态检查
echo ""
log_info "检查 Git 状态..."
if git diff-index --quiet HEAD --; then
    log_success "工作目录干净"
else
    log_info "有未提交的更改"
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ 快速检查通过${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ✗ 快速检查失败${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi
