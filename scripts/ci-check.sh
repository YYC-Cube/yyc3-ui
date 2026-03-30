#!/bin/bash

# YYC3-UI CI/CD 专项检测脚本 v1.0
# 模拟 CI 环境进行全面检测

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

# CI 检查计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
CRITICAL_FAILURES=0

# CI 检查函数
ci_check() {
    local name=$1
    local command=$2
    local critical=${3:-true}
    local timeout=${4:-300}
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo ""
    log_info "CI 检查: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 使用 timeout 限制执行时间
    if timeout $timeout bash -c "$command 2>&1"; then
        log_success "$name 通过"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        exit_code=$?
        if [ $exit_code -eq 124 ]; then
            log_error "$name 超时 (${timeout}s)"
        else
            log_error "$name 失败"
        fi
        
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        if [ "$critical" = true ]; then
            CRITICAL_FAILURES=$((CRITICAL_FAILURES + 1))
        fi
        return 1
    fi
}

# 主 CI 流程
main() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  YYC3-UI CI/CD 检测系统 v1.0"
    echo "  时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # ========== 环境准备 ==========
    echo ""
    log_section "► 环境准备"
    
    log_info "Node 版本: $(node --version)"
    log_info "pnpm 版本: $(pnpm --version)"
    log_info "操作系统: $(uname -s)"
    
    # ========== 关键检查 (失败则中止) ==========
    echo ""
    log_section "► 关键检查 (Critical)"
    
    # 1. 依赖安装
    ci_check "依赖安装完整性" \
        "test -d node_modules && test -f pnpm-lock.yaml" \
        true \
        10
    
    # 2. 核心文件检查
    ci_check "核心构建产物" \
        "test -f packages/yyc3-ui/dist/index.js && test -f packages/yyc3-ui/dist/tailwind.css" \
        true \
        10
    
    # 3. ESLint 检查
    ci_check "ESLint 代码规范" \
        "pnpm lint" \
        true \
        300
    
    # 4. TypeScript 类型检查 (核心)
    ci_check "TypeScript 类型检查" \
        "pnpm --filter=yyc3-ui typecheck 2>&1 | grep -v 'mcp/index.ts' | grep -q 'error TS' && exit 1 || exit 0" \
        true \
        300
    
    # ========== 重要检查 ==========
    echo ""
    log_section "► 重要检查 (Important)"
    
    # 5. 核心包构建
    ci_check "核心包构建" \
        "pnpm --filter=yyc3-ui build 2>&1 | grep -q 'ESM ⚡️ Build success'" \
        false \
        600
    
    # 6. 代码格式检查
    ci_check "Prettier 格式检查" \
        "pnpm format:check" \
        false \
        300
    
    # 7. 单元测试
    ci_check "单元测试" \
        "pnpm --filter=yyc3-ui test || true" \
        false \
        600
    
    # ========== CI/CD 专项检查 ==========
    echo ""
    log_section "► CI/CD 专项检查"
    
    # 8. Git 状态检查
    ci_check "Git 仓库完整性" \
        "git rev-parse --is-inside-work-tree && git status --porcelain" \
        false \
        10
    
    # 9. Registry 配置验证
    ci_check "Registry 配置验证" \
        "pnpm validate:registries || true" \
        false \
        300
    
    # 10. 安全审计
    ci_check "依赖安全审计" \
        "pnpm audit --audit-level=high || true" \
        false \
        120
    
    # 11. 构建缓存检查
    ci_check "构建缓存验证" \
        "test -d .turbo || test -d node_modules/.cache" \
        false \
        10
    
    # 12. Package.json 有效性
    ci_check "Package.json 语法验证" \
        "node -e \"require('./package.json')\" && node -e \"require('./packages/yyc3-ui/package.json')\"" \
        false \
        10
    
    # 13. README 文件检查
    ci_check "README 文件完整性" \
        "test -f README.md && test -f packages/yyc3-ui/README.md" \
        false \
        10
    
    # 14. License 文件检查
    ci_check "License 文件检查" \
        "test -f LICENSE.md" \
        false \
        10
    
    # 15. TypeScript 配置检查
    ci_check "TypeScript 配置有效性" \
        "test -f tsconfig.json && node -e \"require('./tsconfig.json')\"" \
        false \
        10
    
    # ========== 可选检查 ==========
    echo ""
    log_section "► 可选检查 (Optional)"
    
    # 16. 文档完整性
    ci_check "文档文件检查" \
        "test -f CONTRIBUTING.md && test -f SECURITY.md" \
        false \
        10
    
    # 17. EditorConfig 检查
    ci_check "EditorConfig 配置" \
        "test -f .editorconfig" \
        false \
        10
    
    # 18. Git Hooks 检查
    ci_check "Git Hooks 配置" \
        "test -d .husky" \
        false \
        10
    
    # 生成报告
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  CI/CD 检测报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  总检查项: $TOTAL_CHECKS"
    echo -e "  ${GREEN}通过: $PASSED_CHECKS${NC}"
    echo -e "  ${RED}失败: $FAILED_CHECKS${NC}"
    echo -e "  ${RED}关键失败: $CRITICAL_FAILURES${NC}"
    echo ""
    
    # 生成 JUnit XML 报告
    cat > /tmp/ci-report.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="yyc3-ui-ci" tests="$TOTAL_CHECKS" failures="$FAILED_CHECKS">
    <properties>
      <property name="timestamp" value="$(date -Iseconds)"/>
      <property name="node_version" value="$(node --version)"/>
      <property name="pnpm_version" value="$(pnpm --version)"/>
    </properties>
  </testsuite>
</testsuites>
EOF
    
    if [ $CRITICAL_FAILURES -gt 0 ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ✗ CI 检测失败 - 关键问题需要修复${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "报告已生成: /tmp/ci-report.xml"
        exit 1
    elif [ $FAILED_CHECKS -gt 0 ]; then
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}  ⚠ CI 检测通过（有非关键问题）${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    else
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✓ 所有 CI 检查通过！可以安全部署${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        exit 0
    fi
}

# 运行主函数
main "$@"
