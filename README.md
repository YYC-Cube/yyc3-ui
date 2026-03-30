# YYC3-UI

[![Code check](https://github.com/YYC-Cube/yyc3-ui/workflows/Code%20check/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/code-check.yml)
[![Test](https://github.com/YYC-Cube/yyc3-ui/workflows/Test/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/test.yml)
[![Release](https://github.com/YYC-Cube/yyc3-ui/workflows/Release/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/release.yml)
[![npm version](https://badge.fury.io/js/yyc3-ui.svg)](https://badge.fury.io/js/yyc3-ui)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

🚀 **YYC3-UI** - 基于 shadcn/ui 的高质量 React 组件库，配备智能检测系统和自动化 CI/CD。

## ✨ 特性

- 🎨 **精美组件** - 基于 Radix UI 和 Tailwind CSS 的高质量组件
- 🔧 **高度可定制** - 支持主题定制、样式覆盖
- 📦 **开箱即用** - 零配置即可开始使用
- 🤖 **智能检测** - 自动代码质量检测和修复
- 🚀 **CI/CD 集成** - 自动化测试、构建和发布
- 📝 **TypeScript** - 完整的类型支持
- 🎯 **Tree Shaking** - 按需加载，优化包体积

## 🏗️ 项目架构

```
yyc3-ui/
├── 📁 apps/                    # 应用程序
│   └── v4/                     # 文档和示例站点
│       ├── app/                # Next.js 应用
│       ├── content/            # 文档内容
│       ├── examples/           # 组件示例
│       └── public/r/           # Registry 配置
│
├── 📁 packages/                # 包
│   └── yyc3-ui/                # 核心组件库
│       ├── src/                # 源代码
│       │   ├── commands/       # CLI 命令
│       │   ├── icons/          # 图标库
│       │   └── mcp/            # MCP 服务器
│       ├── test/               # 测试文件
│       └── dist/               # 构建产物
│
├── 📁 scripts/                 # 脚本工具
│   ├── smart-check.sh          # 智能检测
│   ├── ci-check.sh             # CI/CD 检测
│   ├── auto-fix.sh             # 自动修复
│   └── pre-push-full.sh        # 推送检测
│
├── 📁 .github/                 # GitHub 配置
│   └── workflows/              # CI/CD 工作流
│       ├── code-check.yml      # 代码检查
│       ├── test.yml            # 自动测试
│       ├── release.yml         # 自动发布
│       └── validate-registries.yml
│
├── 📁 .husky/                  # Git Hooks
│   └── pre-push                # 推送前检测
│
└── 📄 配置文件
    ├── .ci-config.json         # CI 配置
    ├── package.json            # 项目配置
    ├── tsconfig.json           # TypeScript 配置
    └── turbo.json              # Turborepo 配置
```

## 🚀 快速开始

### 安装

```bash
# 使用 pnpm（推荐）
pnpm add yyc3-ui

# 使用 npm
npm install yyc3-ui

# 使用 yarn
yarn add yyc3-ui
```

### 使用

```tsx
import { Button, Card, Input } from 'yyc3-ui'

export default function App() {
  return (
    <Card>
      <Input placeholder="输入内容..." />
      <Button>提交</Button>
    </Card>
  )
}
```

## 🤖 智能检测系统

YYC3-UI 配备了完整的智能检测系统，在提交前自动执行质量检查：

### 自动检测流程

```
Git Push 触发
    ↓
阶段1: 快速检查
├─ Git 仓库状态
├─ 核心构建产物
└─ 依赖完整性
    ↓
阶段2: 代码质量检查
├─ ESLint 代码规范
├─ TypeScript 类型检查
├─ Prettier 格式检查
└─ 核心包构建
    ↓
阶段3: CI/CD 检查
├─ 依赖安全审计
├─ Registry 验证
└─ 单元测试
    ↓
检测结果
├─ ✓ 通过 → 自动推送
└─ ✗ 失败 → 自动修复 → 重试
```

### 手动检测命令

```bash
# 快速检查
pnpm check:quick

# 完整检查（推荐）
pnpm check:full

# CI/CD 模拟检查
pnpm check:ci

# 自动修复问题
pnpm check:fix

# 模拟推送检查
pnpm check:push
```

## 🔄 CI/CD 状态

### 自动化工作流

| 工作流 | 状态 | 说明 |
|--------|------|------|
| **Code Check** | [![CI](https://github.com/YYC-Cube/yyc3-ui/workflows/CI/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/code-check.yml) | 代码质量检查（ESLint、TypeScript、格式） |
| **Test** | [![Test](https://github.com/YYC-Cube/yyc3-ui/workflows/Test/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/test.yml) | 自动化测试 |
| **Release** | [![Release](https://github.com/YYC-Cube/yyc3-ui/workflows/Release/badge.svg)](https://github.com/YYC-Cube/yyc3-ui/actions/workflows/release.yml) | 自动发布到 npm |
| **Validate Registries** | ![Validate](https://github.com/YYC-Cube/yyc3-ui/workflows/Validate%20Registries/badge.svg) | Registry 配置验证 |

### 查看运行状态

```bash
# 使用 GitHub CLI
gh run list --limit 5

# 或访问
open https://github.com/YYC-Cube/yyc3-ui/actions
```

## 📚 开发者文档

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/YYC-Cube/yyc3-ui.git
cd yyc3-ui

# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 构建核心包
pnpm build

# 运行测试
pnpm test

# 代码检查
pnpm lint
```

### 项目脚本

```bash
# 开发
pnpm dev                  # 启动开发服务器
pnpm build                # 构建所有包
pnpm preview              # 预览构建结果

# 质量检查
pnpm lint                 # ESLint 检查
pnpm lint:fix             # ESLint 自动修复
pnpm typecheck            # TypeScript 类型检查
pnpm format:check         # 格式检查
pnpm format:write         # 格式化代码

# 智能检测
pnpm check:quick          # 快速检查
pnpm check:full           # 完整检查
pnpm check:ci             # CI/CD 检查
pnpm check:fix            # 自动修复

# 测试
pnpm test                 # 运行测试
pnpm test:dev             # 开发模式测试

# 发布
pnpm release              # 创建发布版本
pnpm pub:beta             # 发布 beta 版本
pnpm pub:release          # 发布正式版本
```

### 技术栈

- **框架**: React 18+
- **语言**: TypeScript 5+
- **样式**: Tailwind CSS 3+
- **构建**: Vite 7+, Turborepo
- **测试**: Vitest
- **代码规范**: ESLint, Prettier
- **包管理**: pnpm 9+
- **CI/CD**: GitHub Actions

## 📦 核心组件

### 基础组件
- Button, Input, Label, Select
- Card, Dialog, Sheet, Table
- Alert, Toast, Tooltip
- Avatar, Badge, Separator

### 表单组件
- Form, Checkbox, Radio, Switch
- DatePicker, Select, Slider

### 数据展示
- Chart, Data Table, Tree
- Calendar, Timeline

### 导航
- Navigation Menu, Tabs, Breadcrumb

[查看所有组件 →](https://yyc3-ui.dev/docs)

## 🎨 主题定制

```tsx
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'hsl(var(--primary))',
        secondary: 'hsl(var(--secondary))',
        // ...
      }
    }
  }
}
```

## 🔧 配置

### yyc3-ui.config.ts

```typescript
import { defineConfig } from 'yyc3-ui'

export default defineConfig({
  style: 'default',
  rsc: true,
  tsx: true,
  tailwind: {
    config: 'tailwind.config.js',
    css: 'app/globals.css',
    baseColor: 'slate',
    cssVariables: true,
  },
  aliases: {
    components: '@/components',
    utils: '@/lib/utils',
  },
})
```

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 开发规范

- ✅ 遵循 ESLint 规则
- ✅ 编写单元测试
- ✅ 更新相关文档
- ✅ 通过所有 CI 检查

详细指南请查看 [CONTRIBUTING.md](./CONTRIBUTING.md)

## 📄 许可证

本项目基于 [MIT](./LICENSE.md) 许可证开源。

## 🙏 致谢

- [shadcn/ui](https://github.com/shadcn-ui/ui) - 原始项目
- [Radix UI](https://www.radix-ui.com/) - 无障碍组件库
- [Tailwind CSS](https://tailwindcss.com/) - CSS 框架
- [Vercel](https://vercel.com/) - 部署平台

## 📮 联系方式

- **GitHub**: [@YYC-Cube](https://github.com/YYC-Cube)
- **Issues**: [提交问题](https://github.com/YYC-Cube/yyc3-ui/issues)
- **Discussions**: [参与讨论](https://github.com/YYC-Cube/yyc3-ui/discussions)

---

**Made with ❤️ by YYC-Cube**

[⬆ 返回顶部](#yyc3-ui)
