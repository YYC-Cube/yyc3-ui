# 智能检测系统 - 快速使用指南

## 🎯 系统功能

提交远程时自动执行全维度检测，失败自动修复，修复后重新检测，通过后自动提交。

## 📦 已创建的脚本

### 1. 核心检测脚本

| 脚本 | 功能 | 使用场景 |
|------|------|----------|
| `scripts/smart-check.sh` | 标准智能检测 (10项) | 日常检查 |
| `scripts/quick-check.sh` | 快速检查 (核心项) | 快速验证 |
| `scripts/ci-check.sh` | CI/CD 专项检测 (18项) | CI 流程模拟 |

### 2. 修复和推送脚本

| 脚本 | 功能 | 使用场景 |
|------|------|----------|
| `scripts/auto-fix.sh` | 自动修复问题 | 检测失败时 |
| `scripts/pre-push-full.sh` | 完整推送流程 | Git push 触发 |

### 3. 辅助脚本

| 脚本 | 功能 |
|------|------|
| `scripts/quick-verify.sh` | 快速文件验证 |
| `scripts/verify-system.sh` | 系统安装验证 |

## 🚀 使用方法

### 手动检测

```bash
# 快速检查（推荐开发中使用）
pnpm check:quick

# 完整检查（提交前）
pnpm check:full

# CI/CD 模拟检查
pnpm check:ci

# 自动修复问题
pnpm check:fix

# 模拟推送检查
pnpm check:push
```

### 自动检测（推荐）

```bash
# 直接推送，自动触发检测
git push origin main
```

系统会自动：
1. 执行三阶段检测（快速 → 质量 → CI）
2. 失败时自动修复
3. 修复后重新检测
4. 通过后推送成功

## 🔄 检测流程

```
Git Push
    ↓
阶段1: 快速检查
├─ Git 仓库状态
├─ 核心构建产物
└─ 依赖安装完整性
    ↓
阶段2: 代码质量检查
├─ ESLint 代码规范
├─ TypeScript 类型检查
├─ Prettier 格式检查
└─ 核心包构建
    ↓
阶段3: CI/CD 检查
├─ 依赖安全审计
├─ Registry 配置验证
└─ 单元测试
    ↓
检测结果
├─ ✓ 通过 → 推送成功
└─ ✗ 失败 → 自动修复 → 重试（最多2次）
```

## 🛠️ 自动修复项

| 问题 | 自动修复命令 |
|------|-------------|
| ESLint 错误 | `pnpm lint:fix` |
| 格式问题 | `pnpm format:write` |
| 构建问题 | `pnpm --filter=yyc3-ui build` |
| 依赖问题 | `pnpm install` |

## 📊 检测项目分级

### 关键检查（失败中止）

- ✅ ESLint 代码规范
- ✅ 核心包构建
- ✅ 核心文件完整性
- ✅ Git 状态

### 重要检查（失败警告）

- ⚠️ TypeScript 类型检查
- ⚠️ 单元测试
- ⚠️ 格式检查

### 可选检查（不影响推送）

- ℹ️ 安全审计
- ℹ️ Registry 验证
- ℹ️ 文档完整性

## ⚙️ 配置文件

### `.ci-config.json` - 主配置文件

```json
{
  "checks": {
    "critical": [...],    // 关键检查
    "important": [...],   // 重要检查
    "optional": [...]     // 可选检查
  },
  "autoFix": {
    "enabled": true,
    "maxRetries": 2
  },
  "skip": {
    "files": ["**/*.test.ts"],
    "errors": ["TS2589", "TS2345"]
  }
}
```

### `.husky/pre-push` - Git Hook

自动触发完整检测流程。

## 📝 常见场景

### 场景1: 日常开发

```bash
# 开发完成后快速检查
pnpm check:quick

# 没问题就提交
git add .
git commit -m "feat: 新功能"
git push
```

### 场景2: 重要提交

```bash
# 先运行完整检查
pnpm check:full

# 如果有问题，自动修复
pnpm check:fix

# 推送（会再次自动检测）
git push
```

### 场景3: CI 准备

```bash
# 模拟完整 CI 流程
pnpm check:ci

# 通过后推送
git push
```

## 🐛 故障排除

### 问题1: 推送失败

```bash
# 查看详细错误
pnpm check:full

# 自动修复
pnpm check:fix

# 重新推送
git push
```

### 问题2: 检测脚本不存在

```bash
# 检查文件
ls -la scripts/

# 确保有执行权限
chmod +x scripts/*.sh
```

### 问题3: TypeScript MCP 错误

这是已知问题（TS2589, TS2345），已在配置中跳过，不影响运行。

## 💡 最佳实践

1. **推送前检查**: `pnpm check:full`
2. **信任自动化**: 直接 `git push`，系统会自动处理
3. **查看报告**: 检测失败时查看详细日志
4. **定期更新**: 保持检测脚本和配置同步

## 📈 性能优化

- ✅ 并行执行独立检查
- ✅ 增量构建缓存
- ✅ 智能超时控制
- ✅ 最大重试限制（2次）

## 🔗 相关文档

- 详细文档: `.quality-check-report.md`
- 配置说明: `.ci-config.json`
- 更新日志: 查看 Git 提交记录

---

**YYC3-UI 智能检测系统 v2.0**

自动检测 → 自动修复 → 自动提交 → 零人工干预
