---
name: code-format
description: 将蓝湖 HTML/CSS 转为项目框架代码
model: opus
---

# code-format

**核心原则：优先复用，禁止猜测。禁止省略代码。**

## 执行步骤

### 1. 读取上下文（动代码前必须全部读完）

| 文件 | 用途 |
|------|------|
| `README.md` | 技术栈（Vue 版本、UI 库） |
| `docs/components.md` | 可复用组件目录，含 props/用法 |
| `docs/tech-spec.md` | API 接口、交互逻辑约定 |
| `docs/dev-spec.md` | 命名规范、文件结构、样式规范 |

文件缺失时的降级策略见 → `fallback-guide.md`

### 2. 分析蓝湖产物

读取 `.claude/lanhu-output/<页面名称>/index.html`，列出主要 UI 元素（不写代码）。

### 3. 组件映射

对每个 UI 元素查 `docs/components.md`：
- 有完全匹配 → 直接用，传正确 props
- 有近似组件 → 用现有组件 + 自定义 class
- 确认没有 → 按 dev-spec 新建，标记为"新增组件"

常见映射失败案例见 → `failure-patterns.md`

### 4. 补全交互逻辑

从 `docs/tech-spec.md` 取：API 路径、状态处理、格式化规则。
找不到的用 `// TODO: 待确认` 标记，**不自行发明**。

### 5. 生成完整代码

**硬性约束（必须遵守）：**
- 写完整代码，不允许 `// ... rest of component` 等占位
- 颜色/间距/字号精确匹配蓝湖数据
- 图片用 `assets/` 中的实际文件路径

### 6. 输出摘要

```
✓ 生成文件：[列表]
✓ 复用组件：[列表]
⚠ 新增组件：[列表]（需 review）
⚠ TODO 项：[列表]
```
