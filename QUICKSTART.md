# 快速开始

> 预计操作：20 分钟完成全部安装，之后每次使用只需一条命令。

---

## 前提

- 已安装 [Claude Code](https://claude.ai/code)（`claude` 命令可用）
- 已安装 Python 3.11+（用于蓝湖 MCP）
- 有蓝湖账号，能登录 lanhuapp.com

---

## 第一步：安装蓝湖 MCP

蓝湖 MCP 让 Claude Code 能直接读取设计稿数据。

```bash
# 1. 克隆 MCP 服务
git clone https://github.com/dsphper/lanhu-mcp ~/.claude/mcp-servers/lanhu-mcp

# 2. 创建 Python 环境并安装依赖
cd ~/.claude/mcp-servers/lanhu-mcp
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
playwright install chromium

# 3. 配置 Cookie
cp .env.example .env
```

然后获取你的蓝湖 Cookie：

1. 浏览器打开 [lanhuapp.com](https://lanhuapp.com)，登录
2. 按 F12 打开开发者工具 → Application → Cookies → `lanhuapp.com`
3. 复制 `_ga`、`lhtoken`、`user_id` 等关键 Cookie 值
4. 打开 `~/.claude/mcp-servers/lanhu-mcp/.env`，填入 Cookie 字符串：

```
LANHU_COOKIE=你的完整Cookie字符串
```

```bash
# 4. 注册 MCP 到 Claude Code（全局）
cd ~/.claude/mcp-servers/lanhu-mcp
source venv/bin/activate
python server.py &   # 启动服务（后台运行）

claude mcp add lanhu --transport http http://localhost:8000/mcp -s user
```

验证：`curl http://localhost:8000/mcp` 返回 JSON 则成功。

**每次重启电脑后需要重新启动 MCP 服务：**

```bash
bash ~/.claude/mcp-servers/lanhu-mcp/start.sh &
```

---

## 第二步：安装 Skills

```bash
# 克隆仓库
git clone https://github.com/fshows/fshows-frontend-skills ~/fshows-frontend-skills

# 一键安装（软链接到 ~/.claude/skills/）
bash ~/fshows-frontend-skills/install.sh
```

验证：`ls ~/.claude/skills/` 应能看到 `design-to-code`、`code-gen`、`code-format`、`component-doc-gen`。

---

## 第三步：配置项目

在你的前端项目根目录执行以下操作：

**3.1 复制 CLAUDE.md 模板**

```bash
cp ~/.claude/skills/design-to-code/templates/project-CLAUDE.md ./CLAUDE.md
```

打开 CLAUDE.md，按项目实际情况填写：
- 技术栈（Vue 3 / React / ...）
- UI 库（Element Plus / Ant Design / 无）
- CSS 方案（UnoCSS / Tailwind / SCSS）

**3.2 复制 PostToolUse Hook（可选，推荐）**

Hook 会在 Claude Code 每次写入代码文件后自动运行 ESLint：

```bash
mkdir -p .claude
cp ~/.claude/skills/design-to-code/templates/project-dot-claude-settings.json .claude/settings.json
```

**3.3 准备 docs/ 目录（影响生成质量）**

```
docs/
├── components.md   # 可用组件目录（可用 component-doc-gen 自动生成，见第四步）
├── tech-spec.md    # API 接口、枚举定义（需手动维护）
└── dev-spec.md     # 命名规范、样式规范（需手动维护）
```

`docs/tech-spec.md` 和 `docs/dev-spec.md` 需要团队手动维护。参考格式：

<details>
<summary>docs/tech-spec.md 示例</summary>

```markdown
# 技术规格

## API 约定

- 基础路径：/api/v1
- 认证：Header `Authorization: Bearer {token}`

## 枚举值

### 订单状态
| 值 | 含义 |
|----|------|
| pending | 待处理 |
| processing | 处理中 |
| completed | 已完成 |
| cancelled | 已取消 |
```

</details>

<details>
<summary>docs/dev-spec.md 示例</summary>

```markdown
# 开发规范

## CSS Token 映射

| 设计值 | 代码变量 |
|--------|----------|
| #7c3aed | var(--color-primary) |
| #f3f4f6 | var(--color-bg-secondary) |
| 16px | var(--spacing-md) |

## 文件结构

- 页面组件：src/views/{page}/index.vue
- 页面级子组件：src/views/{page}/components/
- 通用组件：src/components/

## 命名规范

- 组件文件：PascalCase（OrderCard.vue）
- 工具函数：camelCase
```

</details>

---

## 第四步：自动生成组件文档（推荐）

`docs/components.md` 记录了项目中所有可复用组件的 props 和用法。有了它，Claude Code 才能优先复用现有组件。

**手动生成（首次或临时使用）：**

```bash
cd your-project
claude -p "运行 component-doc-gen skill"
```

**CI 定时自动生成（推荐团队使用）：**

将 `~/.claude/skills/component-doc-gen/ci-template.yml` 中的 job 配置加入项目的 `.gitlab-ci.yml` 或 Codeup Pipeline 配置。

CI 会每周自动扫描 `src/` 目录，生成最新的 `docs/components.md` 并创建 MR 等待审阅。

---

## 使用

配置完成后，每次使用只需：

```bash
# 1. 进入你的前端项目目录
cd your-project

# 2. 确保蓝湖 MCP 在运行
bash ~/.claude/mcp-servers/lanhu-mcp/start.sh &

# 3. 打开 Claude Code
claude

# 4. 触发工作流
/design-to-code
```

Claude Code 会问你：

```
请提供要转换的蓝湖页面地址（URL）或页面名称
```

粘贴蓝湖页面 URL（如 `https://lanhuapp.com/web/#/item/project/stage?pid=xxx&id=yyy`）后，三阶段流程自动执行。

---

## 最终输出

```
✓ 生成文件：src/views/order/index.vue
✓ 复用组件：SearchInput, StatusTag, OrderCard
⚠ 新增组件：DateRangePicker（需 review）
⚠ TODO 项：
  - GET /api/orders 接口参数（需确认分页方式）
  - 订单状态枚举（docs/tech-spec.md 未定义）
```

代码已写入对应文件，TODO 项需人工补全后方可上线。

---

## 常见问题

**Q: 触发 `/design-to-code` 没有反应？**

确认 skill 文件在正确位置：`~/.claude/skills/design-to-code/SKILL.md`

**Q: 提示"蓝湖 MCP 未配置"？**

确认 MCP 服务在运行（`curl http://localhost:8000/mcp` 有返回），且已注册：`claude mcp list` 应看到 `lanhu`。

**Q: 生成的代码没有复用现有组件？**

检查 `docs/components.md` 是否存在且包含对应组件。可运行 component-doc-gen 重新生成。

**Q: 颜色/间距与设计稿不一致？**

在 `docs/dev-spec.md` 中补充 CSS token 映射表，Claude Code 下次生成时会参考。

---

> 文档和 skill 有问题？在 issues 中反馈。
