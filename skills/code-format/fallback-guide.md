# code-format 降级策略

文档缺失时的处理方式。

## 文档缺失影响表

| 缺失文档 | 影响 | 降级处理 |
|----------|------|----------|
| `docs/components.md` | 无法做组件复用 | 扫描 `src/components/` 推断现有组件，输出中说明"组件文档缺失" |
| `docs/tech-spec.md` | 无交互逻辑 | 生成纯视图代码，所有数据位置标 `// TODO:` |
| `docs/dev-spec.md` | 无编码规范 | 扫描 `src/` 中的现有文件，参照其风格 |

## components.md 缺失时的扫描方式

```
扫描 src/components/ 目录，提取：
- 组件文件名（推断组件名）
- 文件中的 defineProps（推断 props）
- 注意：无法确认 props 的正确用法，需在输出中标记
```

## 多文档同时缺失

如果 `components.md` 和 `tech-spec.md` 同时缺失，在开始前告知用户：

> "关键文档缺失（components.md、tech-spec.md），将以降级模式运行：生成纯视图代码，组件复用依赖目录扫描推断，所有数据逻辑标记 TODO。建议先补充文档再运行以获得更高质量输出。是否继续？"
