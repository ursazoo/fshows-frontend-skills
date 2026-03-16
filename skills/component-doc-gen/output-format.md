# docs/components.md 输出格式

## 文件头部（固定，每次生成必须包含）

```markdown
# 组件文档

> ⚠️ 由 component-doc-gen 自动生成 · {生成日期}
> Props 名称和类型从源码静态提取，用法示例由 AI 推断。
> **合并前请审阅，确认无误后删除此提示块。**

---
```

## 通用组件节（shared）

```markdown
## 通用组件

> 路径：src/components/（跨页面可用）

### {ComponentName}

**文件：** `src/components/{ComponentName}.vue`

#### Props

| Prop | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| modelValue | `string` | 是 | — | v-model 绑定值 |
| placeholder | `string` | 否 | `''` | 占位文字 |
| disabled | `boolean` | 否 | `false` | 是否禁用 |

#### Emits

| 事件 | 参数 | 说明 |
|------|------|------|
| update:modelValue | `string` | 值变化时触发 |
| clear | — | 点击清除按钮时触发 |

#### 用法

```vue
<SearchInput
  v-model="keyword"
  placeholder="搜索订单"
  @clear="handleClear"
/>
```

---
```

## 页面级组件节（page）

```markdown
## 页面级组件

### {页面名称}（src/views/{page}/components/）

#### {ComponentName}

**文件：** `src/views/{page}/components/{ComponentName}.vue`

（格式同通用组件）

---
```

## 需人工确认的标注方式

当无法确定某个 prop 的类型或说明时，在对应行末尾标注：

```markdown
| status | `string` | 是 | — | 订单状态值 ⚠️ 需确认枚举范围 |
```

当整个组件 props 无法提取时（如动态 props、JS 文件无类型定义）：

```markdown
#### {ComponentName}

**文件：** `src/components/{ComponentName}.vue`

> ⚠️ 无法自动提取 Props（可能使用动态属性或缺少类型定义），请手动补充。

---
```

## 尾部统计（固定，每次生成必须包含）

```markdown
---

*生成统计：通用组件 {N} 个 · 页面级组件 {M} 个 · 需人工确认 {P} 项*
*下次自动更新：由 component-doc-gen CI 定时触发*
```
