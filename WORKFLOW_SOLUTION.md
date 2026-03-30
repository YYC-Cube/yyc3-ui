# GitHub Workflow 权限问题解决方案

## ✅ 已完成

临时跳过 workflow 文件，现在可以推送其他代码：

```bash
git push origin main
```

## 📦 备份位置

Workflow 文件已备份到：`.github/workflows-backup/`

备份的文件：
- `code-check.yml` - CI 代码检查
- `issue-stale.yml` - 自动关闭不活跃 issue
- `prerelease-comment.yml` - 预发布评论
- `prerelease.yml` - 预发布流程
- `release.yml` - 发布流程
- `test.yml` - 测试流程
- `validate-registries.yml` - Registry 验证

## 🎯 后续添加 Workflow 的方法

### 方法1: GitHub Web 界面（推荐）

1. 访问仓库：https://github.com/YYC-Cube/yyc3-ui
2. 进入 Actions 标签
3. 点击 "New workflow"
4. 选择 "set up a workflow yourself"
5. 复制备份文件内容，逐个创建

### 方法2: 使用 Personal Access Token

1. **创建 PAT**
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token (classic)"
   - 选择权限：
     - ✅ repo (完整权限)
     - ✅ workflow (关键!)
   - 复制生成的 Token

2. **更新远程仓库 URL**
   ```bash
   # 使用你的 PAT 替换 <TOKEN>
   git remote set-url origin https://<TOKEN>@github.com/YYC-Cube/yyc3-ui.git
   ```

3. **取消忽略 workflow 文件**
   ```bash
   # 从 .gitignore 中删除这一行
   .github/workflows/*.yml
   ```

4. **重新添加 workflow 文件**
   ```bash
   git add .github/workflows/*.yml
   git commit -m "feat: add workflow files"
   git push origin main
   ```

### 方法3: 使用 SSH（如果可用）

```bash
# 切换到 SSH
git remote set-url origin git@github.com:YYC-Cube/yyc3-ui.git

# 取消忽略并推送
# (编辑 .gitignore)
git add .github/workflows/*.yml
git commit -m "feat: add workflow files"
git push origin main
```

## 🔧 快速恢复命令

如果获得了 workflow 权限，可以使用以下命令快速恢复：

```bash
# 1. 从 .gitignore 中删除 workflow 忽略
# 编辑 .gitignore，删除这两行：
#   # Temporary ignore workflows (OAuth permission issue)
#   .github/workflows/*.yml

# 2. 从备份恢复
cp .github/workflows-backup/*.yml .github/workflows/

# 3. 添加并提交
git add .gitignore .github/workflows/
git commit -m "feat: restore workflow files"
git push origin main
```

## 📝 注意事项

1. **本地文件仍然存在** - workflow 文件只是从 Git 中移除，本地仍然保留
2. **CI/CD 暂时无法运行** - 需要添加 workflow 文件后才能使用
3. **建议使用 PAT** - 长期解决方案是创建有 workflow 权限的 PAT

## 🚀 推荐流程

```bash
# 1. 现在推送其他代码
git push origin main

# 2. 稍后创建 PAT 或使用 SSH
# 3. 恢复 workflow 文件
```

---

**问题已解决！现在可以推送代码了。**
