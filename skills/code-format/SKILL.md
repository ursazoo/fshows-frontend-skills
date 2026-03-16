---
name: code-format
description: 将蓝湖 HTML/CSS 转为项目框架代码
model: opus
---

# code-format

**核心原则：优先复用，禁止猜测。禁止省略代码。**

## 执行步骤

### 1. 读取上下文（动代码前必须全部读完）

按以下优先级查找每类文档，找到第一个即用，不要重复查找：

| 用途 | 优先 | 兜底顺序 |
|------|------|---------|
| 技术栈 | `README.md` | → `CLAUDE.md` → `package.json` |
| 组件文档 | `docs/components.md` | → `docs/` 下含 "Props"/"组件" 的 .md |
| 编码规范 | `docs/dev-spec.md` | → `docs/` 下含 "命名规范"/"开发规范" 的 .md → 扫描 `src/` 推断 |
| 交互逻辑 | `docs/tech-spec.md` | → 无则全部标 TODO |

**调用方（design-to-code）会传入 CONTEXT_FILES，直接使用传入路径，不必自己查找。**

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
