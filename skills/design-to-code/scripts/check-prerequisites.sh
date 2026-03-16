#!/bin/bash
# design-to-code 前置条件检查
# exit 0 = 可继续  exit 1 = 阻断  exit 2 = 需暂停等用户决策
# stdout 输出 CONTEXT_FILES 供 design-to-code 传给 code-format

PROJECT_ROOT="${1:-.}"
BLOCK=()
PAUSE=()
WARN=()

# ─── 技术栈来源（三层兜底）────────────────────────────────────
TECH_STACK_FILE=""

if [ -f "$PROJECT_ROOT/README.md" ]; then
  TECH_STACK_FILE="README.md"
elif [ -f "$PROJECT_ROOT/CLAUDE.md" ] && \
     grep -qi "技术栈\|vue\|react\|uni-app\|angular\|svelte\|framework\|stack" "$PROJECT_ROOT/CLAUDE.md"; then
  TECH_STACK_FILE="CLAUDE.md"
elif [ -f "$PROJECT_ROOT/package.json" ]; then
  # 从 package.json 自动生成最简 README.md
  FRAMEWORK=""
  grep -q '"@dcloudio/uni-app"' "$PROJECT_ROOT/package.json"  && FRAMEWORK="uni-app + Vue"
  grep -q '"@tarojs/taro"' "$PROJECT_ROOT/package.json"       && FRAMEWORK="Taro + Vue"
  grep -q '"vue"' "$PROJECT_ROOT/package.json" && [ -z "$FRAMEWORK" ] && FRAMEWORK="Vue"
  grep -q '"nuxt"' "$PROJECT_ROOT/package.json"               && FRAMEWORK="Nuxt"
  # 微信/支付宝原生小程序：无 package.json 框架字段，检测项目配置文件
  [ -f "$PROJECT_ROOT/project.config.json" ] && [ -z "$FRAMEWORK" ]  && FRAMEWORK="微信原生小程序"
  [ -f "$PROJECT_ROOT/mini.project.json" ] && [ -z "$FRAMEWORK" ]    && FRAMEWORK="支付宝原生小程序"
  [ -z "$FRAMEWORK" ] && FRAMEWORK="未知框架"

  LANG="JavaScript"
  grep -q '"typescript"\|"@types/"' "$PROJECT_ROOT/package.json" && LANG="TypeScript"

  UI_LIB=""
  grep -q '"element-plus"\|"element-ui"' "$PROJECT_ROOT/package.json" && UI_LIB=" + Element Plus"
  grep -q '"ant-design-vue"\|"antd"' "$PROJECT_ROOT/package.json"     && UI_LIB=" + Ant Design"
  grep -q '"vant"' "$PROJECT_ROOT/package.json"                       && UI_LIB=" + Vant"
  grep -q '"@nutui"' "$PROJECT_ROOT/package.json"                     && UI_LIB=" + NutUI"

  PROJECT_NAME=$(basename "$PROJECT_ROOT")
  cat > "$PROJECT_ROOT/README.md" << EOF
# $PROJECT_NAME

> 由 design-to-code 前置检查自动生成，请补充完善。

## 技术栈

- 框架：$FRAMEWORK$UI_LIB
- 语言：$LANG
EOF
  TECH_STACK_FILE="README.md（自动生成，请补充完善）"
  WARN+=("README.md 不存在，已根据 package.json 自动生成，请检查技术栈是否准确")
fi

if [ -z "$TECH_STACK_FILE" ]; then
  BLOCK+=("无法确定技术栈：缺少 README.md / CLAUDE.md / package.json")
fi

# ─── 组件文档来源（两层兜底）──────────────────────────────────
COMPONENT_DOC_FILE=""

if [ -f "$PROJECT_ROOT/docs/components.md" ]; then
  COMPONENT_DOC_FILE="docs/components.md"
elif [ -d "$PROJECT_ROOT/docs" ]; then
  # 扫描 docs/ 下含组件说明的 .md 文件
  FOUND=$(grep -rl "Props\|props\|组件\|Component" "$PROJECT_ROOT/docs/" 2>/dev/null \
    | grep "\.md$" | head -1)
  if [ -n "$FOUND" ]; then
    COMPONENT_DOC_FILE="${FOUND#$PROJECT_ROOT/}"
    WARN+=("docs/components.md 不存在，将使用 $COMPONENT_DOC_FILE 作为组件参考")
  fi
fi

if [ -z "$COMPONENT_DOC_FILE" ]; then
  PAUSE+=("docs/ 中无任何组件文档")
fi

# ─── 编码规范来源（宽松，有替代则用替代）────────────────────────
DEV_SPEC_FILE=""
if [ -f "$PROJECT_ROOT/docs/dev-spec.md" ]; then
  DEV_SPEC_FILE="docs/dev-spec.md"
elif [ -d "$PROJECT_ROOT/docs" ]; then
  FOUND=$(grep -rl "命名规范\|编码规范\|开发规范\|代码风格\|ESLint" "$PROJECT_ROOT/docs/" 2>/dev/null \
    | grep "\.md$" | head -1)
  [ -n "$FOUND" ] && DEV_SPEC_FILE="${FOUND#$PROJECT_ROOT/}"
fi
[ -z "$DEV_SPEC_FILE" ] && WARN+=("dev-spec — 缺失时扫描 src/ 推断编码风格")

# ─── 技术规格来源（宽松）────────────────────────────────────────
TECH_SPEC_FILE=""
[ -f "$PROJECT_ROOT/docs/tech-spec.md" ] && TECH_SPEC_FILE="docs/tech-spec.md"
[ -z "$TECH_SPEC_FILE" ] && WARN+=("tech-spec — 缺失时数据逻辑全部标 TODO")

# ─── 输出 ────────────────────────────────────────────────────────
echo "=== design-to-code 前置检查 ==="
echo "项目路径：$PROJECT_ROOT"
echo ""

if [ ${#BLOCK[@]} -gt 0 ]; then
  echo "STATUS: BLOCKED"
  echo "❌ 必需信息缺失："
  for f in "${BLOCK[@]}"; do echo "   - $f"; done
  exit 1
fi

if [ ${#PAUSE[@]} -gt 0 ]; then
  echo "STATUS: NEEDS_DECISION"
  echo "⚠️  docs/ 中无任何组件文档"
  echo ""
  echo "影响：code-format 无法复用现有组件，存在重复造轮子风险。"
  echo ""
  echo "解决方案："
  echo "   1. 立即运行 component-doc-gen 生成初稿，审阅后再继续（推荐）"
  echo "   2. 等待 CI 定时任务生成并合并 MR"
  echo "   3. 以降级模式继续（接受组件复用质量下降）"
  echo "   4. 取消"
  echo ""
fi

# 输出找到的文件路径，供 code-format 使用
echo "CONTEXT_FILES:"
echo "  TECH_STACK=${TECH_STACK_FILE}"
echo "  COMPONENT_DOC=${COMPONENT_DOC_FILE}"
echo "  DEV_SPEC=${DEV_SPEC_FILE}"
echo "  TECH_SPEC=${TECH_SPEC_FILE}"
echo ""

if [ ${#WARN[@]} -gt 0 ]; then
  echo "⚠️  以下文档缺失或使用替代文件："
  for f in "${WARN[@]}"; do echo "   - $f"; done
  echo ""
fi

if [ ${#PAUSE[@]} -gt 0 ]; then
  exit 2
fi

echo "STATUS: OK"
[ ${#WARN[@]} -eq 0 ] && echo "✓ 所有文档齐全" || echo "✓ 核心文档就绪（部分使用替代文件）"
exit 0
