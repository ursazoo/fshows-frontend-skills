---
name: code-gen
description: 从蓝湖 MCP 获取设计稿 HTML/CSS 和切图。由 design-to-code 显式调用。
model: sonnet
disable-model-invocation: true
metadata:
  mcp-server: lanhu
---

# code-gen

**职责：** 从蓝湖 MCP 获取设计稿数据，保存到固定路径，供 code-format 消费。

**不做：** 转换框架代码、分析业务逻辑、引入项目上下文。

## 执行步骤

1. 调用 `lanhu_get_designs` 获取设计图列表，找到匹配的 design_id
   - 有 URL → 从 URL 中提取项目信息后查列表确认
   - 只有名称 → 在列表中模糊匹配
2. 调用 `lanhu_get_ai_analyze_design_result`，等待 status=completed
3. 调用 `lanhu_get_design_slices`，下载切图到 `assets/`
4. 保存产物到 `.claude/lanhu-output/<页面名称>/`
5. 返回路径摘要给调用方

## 输出约定

```
.claude/lanhu-output/<页面名称>/
├── index.html
├── style.css       （如有）
└── assets/
```

返回格式：
```
路径：.claude/lanhu-output/<页面名称>/
切图：N 个
主要元素：<3-5 行简述顶层结构>
```

## 关键陷阱

- `lanhu_get_ai_analyze_design_result` 是异步的，必须等 status=completed 再读
- design_id 不能猜，必须从 `lanhu_get_designs` 返回值中取
- `lanhu_get_pages` 是 Axure 原型页面接口，不是设计稿，不要混用
