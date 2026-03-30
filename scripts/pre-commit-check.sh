#!/bin/bash

# YYC3-UI 提交前智能检查脚本 v1.0
# 在 git commit 前自动执行检查，失败则自动修复

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

# 检查计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# 最大重试次数
MAX_RETRIES=2
RETRY_COUNT=0

# 运行检查函数
run_check() {
    local name=$1
    local command=$2
    local critical=${3:-true}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo ""
    log_info "检查: $name"
    
    if eval "$command 2>&1"; then
        log_success "$name 通过"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        if [ "$critical" = true ]; then
            log_error "$name 失败"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            return 1
        else
            log_warning "$name 失败（非关键）"
            return 0
        fi
    fi
}

# 自动修复函数
auto_fix() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  ⚠ 检测到问题，启动自动修复...${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 1. 修复 ESLint 问题
    log_section "► 修复 ESLint 问题"
    if pnpm lint:fix > /dev/null 2>&1; then
        log_success "ESLint 问题已修复"
    else
        log_warning "ESLint 修复有警告"
    fi
    
    # 2. 修复格式问题
    log_section "► 修复格式问题"
    if pnpm format:write > /dev/null 2>&1; then
        log_success "格式问题已修复"
    else
        log_warning "格式修复有警告"
    fi
    
    # 3. 暂存修复后的文件
    if ! git diff --quiet 2>/dev/null; then
        log_info "暂存修复后的文件..."
        git add -A
        log_success "修复文件已暂存"
    fi
    
    echo ""
    log_success "自动修复完成"
}

# 主检测流程
main() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  YYC3-UI 提交前智能检查 v1.0${NC}"
    echo -e "${CYAN}  时间: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # ========== 快速检查阶段 ==========
    echo ""
    log_section "► 快速检查阶段"
    
    # 1. ESLint 检查（关键）
    run_check "ESLint 代码规范" \
        "pnpm lint > /dev/null 2>&1" \
        true
    
    # 2. Prettier 格式检查（关键）
    run_check "Prettier 格式检查" \
        "pnpm format:check > /dev/null 2>&1" \
        true
    
    # 3. TypeScript 类型检查（重要）
    run_check "TypeScript 类型检查" \
        "pnpm --filter=yyc3-ui typecheck > /dev/null 2>&1" \
        false
    
    # 生成报告
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  检查报告${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  总检查项: $TOTAL_CHECKS"
    echo -e "  ${GREEN}通过: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}失败: $FAILED_CHECKS${NC}"
    echo ""
    
    if [ $FAILED_CHECKS -gt 0 ]; then
        # 尝试自动修复
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            RETRY_COUNT=$((RETRY_COUNT + 1))
            echo -e "${YELLOW}重试次数: $RETRY_COUNT/$MAX_RETRIES${NC}"
            auto_fix
            
            # 重新检查
            echo ""
            log_info "重新检查..."
            TOTAL_CHECKS=0
            PASSED_CHECKS=0
            FAILED_CHECKS=0
            main
            return $?
        else
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}  ✗ 提交被阻止${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "已尝试自动修复 $MAX_RETRIES 次，仍有问题需要手动修复"
            echo ""
            echo "建议操作："
            echo "  1. 运行 'pnpm lint' 查看详细错误"
            echo "  2. 运行 'pnpm typecheck' 查看类型错误"
            echo "  3. 手动修复后重新提交"
            exit 1
        fi
    else
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✓ 所有检查通过，允许提交${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    fi
}

# 运行主函数
main "$@"
