# code-format 失败模式

真实案例，来自 screenshot-to-code、FigmaToCode、monday.com、shadcn/ui 生产项目的实践总结。

## 失败 0：硬编码设计 token 值（最高频，所有项目必现）

**场景：** 蓝湖给出颜色 `#7c3aed`、间距 `14px`、字号 `14px`，直接写进代码。项目实际有 CSS 变量 `var(--color-primary)`、`var(--spacing-sm)`、`text-sm`。

**识别信号：** 代码中出现十六进制颜色值、px 数字字面量，而不是 CSS 变量或设计 token。

```css
/* 错误 */
color: #7c3aed;
margin: 14px;

/* 正确 */
color: var(--color-primary);
margin: var(--spacing-sm);
```

**正确做法：** 先查 `docs/dev-spec.md` 中的 token 映射表；找不到则在输出摘要中标注 `⚠ 未映射 token: #7c3aed`，不自行命名。

> 来源：monday.com 工程博客（生产环境）、shadcn/ui Figma 项目（200+ 组件验证）

---

## 失败 1：重写已有组件

**场景：** 蓝湖中有搜索框，直接用 `<input>` 实现，但项目的 `<SearchInput>` 有内置防抖、清除按钮和样式规范。

**识别信号：** 生成的代码中出现基础 HTML 元素（input/button/select），而 components.md 中有对应的封装组件。

**正确做法：** 查 `docs/components.md` → 找到 `<SearchInput>` → 使用它。

---

## 失败 2：自行发明 API 路径

**场景：** 页面需要加载列表，AI 写了 `/api/order/list`，实际接口是 `/v2/orders?type=xxx`。

**识别信号：** 代码中出现 `/api/` 开头的路径但 tech-spec.md 未定义。

**正确做法：** 在 `docs/tech-spec.md` 找接口 → 找不到用 `// TODO: 补充 API 路径` 标记。

---

## 失败 3：硬编码枚举显示文字

**场景：** 订单状态显示"待支付"直接硬编码，但 tech-spec.md 定义了 `ORDER_STATUS_MAP` 常量。

**识别信号：** 代码中出现中文状态字符串字面量。

**正确做法：** 检查 tech-spec.md 的枚举定义 → 引用现有的格式化工具函数。

---

## 失败 4：省略代码

**场景：** 生成了 template 和 script setup 但用 `// handle error` 代替实际错误处理，或省略 `<style scoped>`。

**识别信号：** 代码中出现任何形式的省略注释。

**正确做法：** 写完整代码。不确定的逻辑用 `// TODO:` 标记，但不省略整个区块。

---

## 失败 5：props 名称猜错

**场景：** 用了 `<Button type="primary">` 但实际组件的 prop 是 `variant="primary"`。

**识别信号：** 使用了 components.md 中未记录的 prop 名称。

**正确做法：** props 名称必须以 `docs/components.md` 中的实际文档为准，不能凭 UI 库经验猜测。
