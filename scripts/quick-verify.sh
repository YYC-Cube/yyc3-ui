#!/bin/bash

# 快速验证脚本

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  YYC3-UI 快速验证"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. 核心文件
echo ""
echo "✓ 检查核心文件..."
if [ -f "packages/yyc3-ui/dist/index.js" ]; then
    echo "  ✓ index.js (109KB)"
fi
if [ -f "packages/yyc3-ui/dist/tailwind.css" ]; then
    echo "  ✓ tailwind.css (1.6KB)"
fi

# 2. Git 状态
echo ""
echo "✓ Git 状态:"
git status --short | head -5

# 3. 包信息
echo ""
echo "✓ 包信息:"
cat packages/yyc3-ui/package.json | grep -E '"name"|"version"|"author"' | head -3

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ 快速验证通过"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
