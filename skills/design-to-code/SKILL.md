---
name: design-to-code
description: 蓝湖设计稿转框架代码，三阶段工作流入口
---

# design-to-code

三阶段工作流：code-gen → code-format → code-review

## 入参收集（开始前必须确认）

**必需信息：**
- 蓝湖页面 URL 或页面名称

**未提供时必须先问：**
```
请提供要转换的蓝湖页面地址（URL）或页面名称，例如：
- https://lanhuapp.com/web/#/item/project/stage?pid=xxx&id=yyy
- 或直接告诉我页面名称，我来查
```
不能假设或猜测页面，必须等用户明确给出后再继续。

## 前置检查

运行 `scripts/check-prerequisites.sh <项目根目录>`，按 exit code 处理：

| exit | STATUS | 行为 |
|------|--------|------|
| 1 | BLOCKED | 告知原因，**停止** |
| 2 | NEEDS_DECISION | 显示脚本输出，**暂停**，按话术询问用户 |
| 0 | OK | 读取 CONTEXT_FILES，直接进入阶段 1 |

脚本 stdout 包含 `CONTEXT_FILES` 块，格式如下：
```
CONTEXT_FILES:
  TECH_STACK=README.md
  COMPONENT_DOC=docs/开发规范与组件文档.md
  DEV_SPEC=docs/开发规范与组件文档.md
  TECH_SPEC=
```
将这些路径传给 code-format，code-format 按此读取，不自行查找。

**NEEDS_DECISION 时的询问话术：**
```
docs/ 中没有找到组件文档，有四个选项：
1. 立即运行 component-doc-gen 生成初稿，我帮你审阅后再继续（推荐）
2. 等待 CI 定时任务生成并合并 MR 后再转换
3. 以降级模式继续：扫描 src/ 推断可用组件，生成后请重点 review 组件使用部分
4. 取消

请选择（1/2/3/4）：
```

选 1 → 运行 component-doc-gen，完成后继续。选 2 → 停止。选 3 → 继续并在最终摘要标注"降级模式运行"。选 4 → 退出。

详见 → `workflow-guide.md#文档缺失影响`

## 阶段 1：code-gen（subagent）

以 subagent 方式调用，传入页面信息。等待返回：输出路径 + 元素摘要。

## 阶段 2：code-format

用阶段 1 的输出路径调用 code-format。

## 阶段 3：code-review（可选）

阶段 2 完成后询问用户是否 code review，确认后调用 `/code-review-expert`。

## 进度反馈

```
阶段 1/3：正在从蓝湖获取设计稿数据...
✓ 阶段 1 完成 → 阶段 2/3：正在生成框架代码...
✓ 阶段 2 完成 → 是否进行 code review？(y/n)
```

完整失败模式见 → `workflow-guide.md#失败模式`
