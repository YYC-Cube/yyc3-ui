#!/bin/bash

# 智能推送并跟进 CI/CD 脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${CYAN}  🚀 YYC3-UI 智能推送系统${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 推送前检查
echo -e "${BLUE}► 推送前检查${NC}"
echo ""

# 检查未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠ 发现有未提交的更改${NC}"
    echo ""
    git status --short
    echo ""
    read -p "是否提交这些更改? (y/n): " commit_choice
    if [ "$commit_choice" = "y" ]; then
        git add -A
        git commit -m "chore: update files before push"
        echo -e "${GREEN}✓ 更改已提交${NC}"
    fi
fi

# 检查当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}当前分支:${NC} $CURRENT_BRANCH"

# 检查远程状态
echo -e "${BLUE}检查远程状态...${NC}"
git fetch origin 2>/dev/null || true

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/$CURRENT_BRANCH 2>/dev/null || echo "")

if [ "$LOCAL" = "$REMOTE" ]; then
    echo -e "${GREEN}✓ 本地与远程同步${NC}"
else
    AHEAD=$(git rev-list --count origin/$CURRENT_BRANCH..HEAD 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count HEAD..origin/$CURRENT_BRANCH 2>/dev/null || echo "0")

    if [ "$AHEAD" != "0" ]; then
        echo -e "${GREEN}✓ 本地领先 $AHEAD 个提交${NC}"
    fi
    if [ "$BEHIND" != "0" ]; then
        echo -e "${YELLOW}⚠ 本地落后 $BEHIND 个提交${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 2. 执行推送
echo ""
echo -e "${CYAN}► 执行推送${NC}"
echo ""

echo "推送命令:"
echo "  git push origin $CURRENT_BRANCH"
echo ""

read -p "确认推送? (y/n): " push_confirm

if [ "$push_confirm" = "y" ]; then
    echo ""
    echo -e "${BLUE}正在推送...${NC}"

    if git push origin $CURRENT_BRANCH 2>&1; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}  ✓ 推送成功！${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

        # 3. 获取推送信息
        echo ""
        COMMIT_SHA=$(git rev-parse HEAD)
        COMMIT_MSG=$(git log -1 --pretty=format:"%s")
        REPO_URL=$(git remote get-url origin | sed 's/\.git$//')

        echo -e "${BLUE}推送信息:${NC}"
        echo "  Commit: ${COMMIT_SHA:0:7}"
        echo "  消息: $COMMIT_MSG"
        echo "  分支: $CURRENT_BRANCH"
        echo ""

        # 4. 提供 CI/CD 监控链接
        echo -e "${CYAN}► CI/CD 监控${NC}"
        echo ""

        echo "GitHub Actions:"
        echo "  ${REPO_URL}/actions"
        echo ""

        echo "本次提交的 CI 运行:"
        echo "  ${REPO_URL}/commit/${COMMIT_SHA}"
        echo ""

        # 5. 检查是否有 workflow（虽然我们暂时跳过了）
        if [ -d ".github/workflows" ] && [ "$(ls -A .github/workflows/*.yml 2>/dev/null)" ]; then
            echo -e "${BLUE}注意:${NC} 检测到 workflow 文件存在"
            echo "  如果 CI 未运行，请检查 workflow 是否已推送到远程"
        else
            echo -e "${YELLOW}提示:${NC} Workflow 文件已临时跳过"
            echo "  需要通过 GitHub Web 界面或 PAT 添加"
            echo "  详见: WORKFLOW_SOLUTION.md"
        fi

        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        # 6. 提供后续跟进命令
        echo ""
        echo -e "${CYAN}后续跟进命令:${NC}"
        echo ""
        echo "  # 查看 GitHub Actions 状态"
        echo "  gh run list --limit 5"
        echo ""
        echo "  # 查看特定运行的详细信息"
        echo "  gh run view"
        echo ""
        echo "  # 查看运行日志"
        echo "  gh run watch"
        echo ""
        echo "  # 或直接访问:"
        echo "  open ${REPO_URL}/actions"
        echo ""

    else
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}  ✗ 推送失败${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "可能的原因:"
        echo "  1. 网络连接问题"
        echo "  2. 权限问题"
        echo "  3. 远程仓库拒绝（如 workflow 权限）"
        echo ""
        echo "解决方法:"
        echo "  - 检查网络连接"
        echo "  - 验证 Git 凭据"
        echo "  - 查看 WORKFLOW_SOLUTION.md"
        echo ""
        exit 1
    fi
else
    echo ""
    echo -e "${YELLOW}推送已取消${NC}"
    exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
