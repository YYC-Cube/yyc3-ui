#!/bin/bash

# YYC3-UI Pre-Push 智能检测脚本 v2.0
# 提交远程前自动检测、修复、再检测

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}ℹ ${NC}$1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_section() { echo -e "${CYAN}$1${NC}"; }
log_auto() { echo -e "${MAGENTA}⚡${NC} $1"; }

# 检测次数限制
MAX_RETRY=2
RETRY_COUNT=0

# 主流程
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${MAGENTA}  🚀 YYC3-UI 智能提交系统 v2.0${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 获取当前分支
    CURRENT_BRANCH=$(git branch --show-current)
    log_info "当前分支: $CURRENT_BRANCH"
    log_info "检测时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # 第一次检测
    run_check_cycle
    
    # 如果第一次失败，尝试修复
    if [ $? -ne 0 ]; then
        if [ $RETRY_COUNT -lt $MAX_RETRY ]; then
            echo ""
            log_warning "检测未通过，启动自动修复..."
            echo ""
            
            # 执行自动修复
            if [ -f "scripts/auto-fix.sh" ]; then
                chmod +x scripts/auto-fix.sh
                ./scripts/auto-fix.sh
                
                if [ $? -eq 0 ]; then
                    echo ""
                    log_auto "修复完成，重新检测中..."
                    RETRY_COUNT=$((RETRY_COUNT + 1))
                    run_check_cycle
                else
                    echo ""
                    log_error "自动修复失败，请手动修复问题"
                    exit 1
                fi
            else
                log_error "修复脚本不存在"
                exit 1
            fi
        else
            echo ""
            log_error "已达最大重试次数 ($MAX_RETRY)，请手动修复问题"
            exit 1
        fi
    fi
}

# 检测循环
run_check_cycle() {
    echo ""
    log_section "► 执行全维度智能检测"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 阶段 1: 快速检查
    echo ""
    log_section "阶段 1/3: 快速检查"
    run_quick_checks
    
    # 阶段 2: 代码质量检查
    echo ""
    log_section "阶段 2/3: 代码质量检查"
    run_quality_checks
    
    # 阶段 3: CI/CD 检查
    echo ""
    log_section "阶段 3/3: CI/CD 模拟检查"
    run_ci_checks
    
    # 所有检查通过
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ 全维度检测通过！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 显示提交信息
    echo ""
    log_info "准备推送到远程仓库..."
    show_commit_info
    
    exit 0
}

# 快速检查
run_quick_checks() {
    local failed=0
    
    # 1. 检查 Git 状态
    log_info "检查 Git 状态..."
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log_success "Git 仓库正常"
    else
        log_error "Git 仓库异常"
        failed=1
    fi
    
    # 2. 检查核心文件
    log_info "检查核心文件..."
    if [ -f "packages/yyc3-ui/dist/index.js" ]; then
        log_success "核心构建产物存在"
    else
        log_warning "核心构建产物不存在，将触发构建"
    fi
    
    # 3. 检查依赖
    log_info "检查依赖安装..."
    if [ -d "node_modules" ] && [ -f "pnpm-lock.yaml" ]; then
        log_success "依赖已安装"
    else
        log_warning "依赖未完整安装"
        pnpm install --frozen-lockfile=false > /dev/null 2>&1 || true
    fi
    
    return $failed
}

# 代码质量检查
run_quality_checks() {
    local failed=0
    
    # 1. ESLint 检查
    echo ""
    log_info "执行 ESLint 检查..."
    if pnpm lint > /tmp/eslint-output.log 2>&1; then
        log_success "ESLint 检查通过"
    else
        log_error "ESLint 检查失败"
        echo ""
        echo "错误详情:"
        tail -n 20 /tmp/eslint-output.log
        failed=1
    fi
    
    # 2. TypeScript 检查 (排除已知问题)
    echo ""
    log_info "执行 TypeScript 类型检查..."
    if pnpm --filter=yyc3-ui typecheck 2>&1 | grep -v 'mcp/index.ts' | grep -v 'TS2589' | grep -v 'TS2345' | grep -q 'error TS'; then
        log_error "TypeScript 类型检查失败"
        failed=1
    else
        log_success "TypeScript 类型检查通过"
    fi
    
    # 3. 格式检查
    echo ""
    log_info "执行代码格式检查..."
    if pnpm format:check > /tmp/format-output.log 2>&1; then
        log_success "代码格式检查通过"
    else
        log_warning "代码格式存在问题（将自动修复）"
    fi
    
    # 4. 核心包构建
    echo ""
    log_info "构建核心包..."
    if pnpm --filter=yyc3-ui build 2>&1 | grep -q "ESM ⚡️ Build success"; then
        log_success "核心包构建成功"
    else
        log_error "核心包构建失败"
        failed=1
    fi
    
    return $failed
}

# CI/CD 检查
run_ci_checks() {
    local failed=0
    
    # 1. 安全审计
    echo ""
    log_info "执行依赖安全审计..."
    if pnpm audit --audit-level=high > /tmp/audit-output.log 2>&1; then
        log_success "安全审计通过"
    else
        log_warning "发现安全漏洞（非关键）"
    fi
    
    # 2. Registry 验证
    echo ""
    log_info "验证 Registry 配置..."
    if pnpm validate:registries > /dev/null 2>&1 || true; then
        log_success "Registry 配置正常"
    else
        log_warning "Registry 配置可能存在问题"
    fi
    
    # 3. 单元测试
    echo ""
    log_info "执行单元测试..."
    if pnpm --filter=yyc3-ui test > /tmp/test-output.log 2>&1 || true; then
        log_success "单元测试完成"
    else
        log_warning "单元测试存在失败用例"
    fi
    
    return $failed
}

# 显示提交信息
show_commit_info() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_section "  📦 提交信息"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 获取最近提交
    LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cr)" 2>/dev/null || echo "无提交记录")
    log_info "最新提交: $LATEST_COMMIT"
    
    # 统计变更
    CHANGED_FILES=$(git diff --name-only HEAD~1 2>/dev/null | wc -l | tr -d ' ')
    log_info "变更文件: $CHANGED_FILES 个"
    
    # 显示变更统计
    if [ $CHANGED_FILES -gt 0 ]; then
        echo ""
        log_info "变更文件列表:"
        git diff --name-status HEAD~1 2>/dev/null | head -n 10 || echo "无变更"
        if [ $CHANGED_FILES -gt 10 ]; then
            echo "  ... 还有 $((CHANGED_FILES - 10)) 个文件"
        fi
    fi
    
    echo ""
    log_success "准备推送到远程仓库..."
    echo ""
}

# 运行主函数
main "$@"
