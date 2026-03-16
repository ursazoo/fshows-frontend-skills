# design-to-code 工作流详情

## 文档缺失影响

| 缺失文档 | 对 code-format 的影响 |
|----------|----------------------|
| `docs/components.md` | 无法复用组件，会生成重复代码 |
| `docs/tech-spec.md` | 无交互逻辑，只能生成静态视图 |
| `docs/dev-spec.md` | 可能不符合团队编码规范 |

## 失败模式

### "一次性"思维

AI 生成代码后直接报告"完成"，没有输出 TODO 列表，用户误以为代码生产可用。

**防范：** 阶段 2 完成后必须输出 TODO 列表，主动提示 code review 步骤。

### 跳过 subagent 隔离

直接在主会话中调用蓝湖 MCP，大量原始 HTML 数据涌入上下文，稀释后续 code-format 读取业务文档的效果。

**防范：** code-gen 必须以 subagent 运行，只返回路径和摘要。

### 文档缺失时静默降级

`docs/components.md` 不存在，AI 直接进入生成流程，最终生成大量本可复用的重复组件。

**防范：** 前置检查时明确告知缺失文档及影响，等用户决策。

## 完整流程图

```
用户：蓝湖页面 URL 或页面名称
         │
         ▼
   [check-prerequisites.sh]
   - README.md 存在？
   - 蓝湖 MCP 已配置？
   - docs/ 文档状态？
         │
         ▼
   [阶段 1: code-gen subagent]
   - 获取 page_id
   - 获取 HTML+CSS（等待 completed）
   - 下载切图
   - 保存到 .claude/lanhu-output/
         │
         ▼ 返回：路径 + 元素摘要
         │
   [阶段 2: code-format]
   - 读 README/components/tech-spec/dev-spec
   - 组件映射（查 components.md）
   - 补全交互逻辑（查 tech-spec.md）
   - 生成完整框架代码
         │
         ▼ 返回：文件列表 + TODO 列表
         │
   [阶段 3: code-review（用户确认后）]
   - /code-review-expert
```
