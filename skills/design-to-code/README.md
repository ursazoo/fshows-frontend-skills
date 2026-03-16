# design-to-code：蓝湖设计稿转代码工作流

> 让 Claude Code 直接读取蓝湖设计稿，生成符合项目规范的框架代码。

---

## 它能做什么

给 Claude Code 一个蓝湖页面链接，它会：

1. **自动读取设计稿**（通过蓝湖 MCP）——获取 HTML 结构、样式数据、切图
2. **映射到项目现有组件**——查阅 `docs/components.md`，优先复用，不重复造轮子
3. **生成完整框架代码**——Vue / React / 其他，以项目 README 为准
4. **标出所有待确认项**——API 路径、枚举、不确定的逻辑，全部标 `// TODO:`
5. **可选 code review**——生成后问你要不要跑 code-review-expert

**不会做：** 猜测 API 路径、硬编码设计 token 值（颜色/间距）、省略代码

---

## 架构概览

```
/design-to-code（入口 skill）
    │
    ├── 前置检查：README / 蓝湖 MCP / docs/components.md
    │
    ├── 阶段 1：code-gen（subagent 隔离）
    │   └── 蓝湖 MCP → 获取 HTML+CSS+切图 → 保存到 .claude/lanhu-output/
    │
    ├── 阶段 2：code-format
    │   └── 读 docs/ → 组件映射 → 生成完整框架代码
    │
    └── 阶段 3：code-review（用户确认后）
        └── /code-review-expert
```

### 为什么要 subagent 隔离？

蓝湖原始 HTML 数据量很大。如果直接在主会话读取，大量无关内容会稀释后续读取业务文档（components.md、tech-spec.md）的效果。code-gen 以独立 subagent 运行，只把"路径 + 元素摘要"返回给主流程。

---

## 文档质量 vs 生成质量

`docs/` 下的文档越齐全，生成质量越高：

| 文档 | 作用 | 缺失时的影响 |
|------|------|-------------|
| `docs/components.md` | 可复用组件目录（props/用法） | 会生成重复的组件 |
| `docs/tech-spec.md` | API 接口、枚举、交互逻辑 | 只能生成静态视图，数据逻辑全标 TODO |
| `docs/dev-spec.md` | 命名规范、文件结构、样式规范 | 可能不符合团队编码风格 |

`docs/components.md` 可以由 **component-doc-gen** CI 任务自动生成（见 QUICKSTART.md）。

---

## 最常见失败原因

**硬编码设计 token 值**（最高频）

蓝湖给出颜色 `#7c3aed`，直接写进代码。项目实际有 CSS 变量 `var(--color-primary)`。

防范方式：在 `docs/dev-spec.md` 中维护 token 映射表；`docs/components.md` 保持最新。

---

## 配套工具

| 工具 | 说明 |
|------|------|
| 蓝湖 MCP | 读取蓝湖设计稿数据（需安装配置） |
| component-doc-gen | CI 定时扫描 src/ 生成 docs/components.md |
| code-review-expert | 生成后可选的代码审查 |

---

快速开始 → 见 [QUICKSTART.md](./QUICKSTART.md)
