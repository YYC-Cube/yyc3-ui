#!/bin/bash

# 临时解决 GitHub OAuth 权限问题
# OAuth App 没有 workflow 权限，无法推送 .github/workflows/ 文件

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}  🔧 修复 GitHub Workflow 推送问题${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${YELLOW}问题原因:${NC}"
echo "  GitHub OAuth App 没有 workflow 权限"
echo "  无法推送 .github/workflows/ 目录下的文件"
echo ""

echo -e "${BLUE}解决方案:${NC}"
echo ""
echo "方案 1: 临时跳过 workflow 文件（推荐）"
echo "  - 从 Git 中移除 workflow 文件"
echo "  - 推送其他代码"
echo "  - 稍后通过 GitHub Web 界面添加 workflow"
echo ""
echo "方案 2: 使用 Personal Access Token"
echo "  - 创建 PAT with workflow scope"
echo "  - 更新远程仓库 URL"
echo ""
echo "方案 3: 通过 GitHub Web 界面"
echo "  - 在 GitHub 网页上直接编辑 workflow 文件"
echo ""

read -p "选择方案 (1/2/3): " choice

case $choice in
  1)
    echo ""
    echo -e "${BLUE}执行方案 1: 临时跳过 workflow 文件${NC}"
    echo ""
    
    # 备份 workflow 文件
    echo "📦 备份 workflow 文件到 .github/workflows-backup/"
    mkdir -p .github/workflows-backup
    cp -r .github/workflows/*.yml .github/workflows-backup/ 2>/dev/null || true
    
    # 从 Git 中移除 workflow 文件（保留本地文件）
    echo "🗑️  从 Git 中移除 workflow 文件..."
    git rm --cached .github/workflows/*.yml 2>/dev/null || true
    
    # 更新 .gitignore
    echo "📝 更新 .gitignore..."
    if ! grep -q ".github/workflows/" .gitignore 2>/dev/null; then
      echo "" >> .gitignore
      echo "# Temporary ignore workflows (OAuth permission issue)" >> .gitignore
      echo ".github/workflows/*.yml" >> .gitignore
    fi
    
    # 提交更改
    echo "💾 提交更改..."
    git add .gitignore
    git commit -m "chore: temporarily ignore workflow files (OAuth permission issue)" || true
    
    echo ""
    echo -e "${GREEN}✓ 准备完成！${NC}"
    echo ""
    echo "现在可以推送其他代码了:"
    echo "  git push origin main"
    echo ""
    echo "Workflow 文件已备份到: .github/workflows-backup/"
    echo "稍后可以通过以下方式添加 workflow:"
    echo "  1. GitHub Web 界面直接编辑"
    echo "  2. 使用 Personal Access Token"
    echo ""
    ;;
    
  2)
    echo ""
    echo -e "${BLUE}执行方案 2: 使用 Personal Access Token${NC}"
    echo ""
    echo "步骤:"
    echo "  1. 访问: https://github.com/settings/tokens"
    echo "  2. 创建新 Token，选择 'workflow' 权限"
    echo "  3. 复制生成的 Token"
    echo "  4. 运行以下命令更新远程仓库 URL:"
    echo ""
    echo "     git remote set-url origin https://<TOKEN>@github.com/YYC-Cube/yyc3-ui.git"
    echo ""
    echo "  5. 重新推送: git push origin main"
    echo ""
    ;;
    
  3)
    echo ""
    echo -e "${BLUE}执行方案 3: GitHub Web 界面${NC}"
    echo ""
    echo "步骤:"
    echo "  1. 先从 Git 中移除 workflow 文件:"
    echo "     git rm --cached .github/workflows/*.yml"
    echo "     git commit -m 'chore: remove workflow files'"
    echo "     git push origin main"
    echo ""
    echo "  2. 访问 GitHub 仓库: https://github.com/YYC-Cube/yyc3-ui"
    echo "  3. 创建 .github/workflows 目录"
    echo "  4. 通过 Web 界面添加 workflow 文件"
    echo ""
    ;;
    
  *)
    echo -e "${YELLOW}无效选择，退出${NC}"
    exit 1
    ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
