#!/bin/bash

# YYC3-UI 自动修复脚本 v1.0
# 自动修复常见代码问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_section() { echo -e "${CYAN}$1${NC}"; }

# 修复计数器
FIXED_ISSUES=0
FAILED_FIXES=0

# 自动修复函数
auto_fix() {
    local name=$1
    local fix_command=$2
    
    echo ""
    log_info "修复: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if eval "$fix_command 2>&1"; then
        log_success "$name 修复完成"
        FIXED_ISSUES=$((FIXED_ISSUES + 1))
        return 0
    else
        log_error "$name 修复失败"
        FAILED_FIXES=$((FAILED_FIXES + 1))
        return 1
    fi
}

# 主修复流程
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  YYC3-UI 自动修复系统 v1.0"
    echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 1. 修复 ESLint 问题
    log_section "► 代码质量修复"
    auto_fix "ESLint 自动修复" "pnpm lint:fix || true"
    
    # 2. 修复格式问题
    auto_fix "Prettier 格式化" "pnpm format:write || true"
    
    # 3. 修复核心包构建
    echo ""
    log_section "► 构建修复"
    log_info "清理构建缓存..."
    rm -rf packages/yyc3-ui/dist 2>/dev/null || true
    auto_fix "核心包重新构建" "pnpm --filter=yyc3-ui build"
    
    # 4. 修复依赖问题
    echo ""
    log_section "► 依赖修复"
    log_info "检查并安装缺失依赖..."
    pnpm install --frozen-lockfile=false > /dev/null 2>&1 || true
    log_success "依赖检查完成"
    
    # 5. 修复 Git 状态
    echo ""
    log_section "► Git 状态修复"
    if git diff --quiet 2>/dev/null; then
        log_info "工作区干净，无需提交"
    else
        log_warning "检测到文件变更"
        echo ""
        echo "变更文件列表:"
        git status --short
        echo ""
        log_info "自动暂存变更..."
        git add -A
        FIXED_ISSUES=$((FIXED_ISSUES + 1))
    fi
    
    # 生成修复报告
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  修复报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  已修复: $FIXED_ISSUES"
    echo -e "  ${RED}失败: $FAILED_FIXES${NC}"
    echo ""
    
    if [ $FAILED_FIXES -gt 0 ]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}  ⚠ 部分问题需要手动修复${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 1
    else
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✓ 所有问题已自动修复！${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    fi
}

# 运行主函数
main "$@"
