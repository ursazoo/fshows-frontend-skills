#!/bin/bash
# design-to-code 前置条件检查
# exit 0 = 可继续  exit 1 = 阻断（必需文件缺失）  exit 2 = 需暂停等用户决策（components.md 缺失）

PROJECT_ROOT="${1:-.}"
BLOCK=()
PAUSE=()
WARN=()

# 阻断：README.md（框架版本未知则无法生成）
[ ! -f "$PROJECT_ROOT/README.md" ] && BLOCK+=("README.md — 技术栈信息缺失，code-format 无法确定框架版本")

# 暂停：docs/components.md（组件文档缺失，组件复用无法保证）
[ ! -f "$PROJECT_ROOT/docs/components.md" ] && PAUSE+=("docs/components.md")

# 警告：其余文档（缺失降级处理，不阻断）
[ ! -f "$PROJECT_ROOT/docs/tech-spec.md" ] && WARN+=("docs/tech-spec.md — 缺失时数据逻辑全部标 TODO")
[ ! -f "$PROJECT_ROOT/docs/dev-spec.md" ]  && WARN+=("docs/dev-spec.md — 缺失时扫描 src/ 推断编码风格")

echo "=== design-to-code 前置检查 ==="
echo "项目路径：$PROJECT_ROOT"
echo ""

if [ ${#BLOCK[@]} -gt 0 ]; then
  echo "STATUS: BLOCKED"
  echo "❌ 必需文件缺失（必须补充后才能继续）："
  for f in "${BLOCK[@]}"; do echo "   - $f"; done
  echo ""
  exit 1
fi

if [ ${#PAUSE[@]} -gt 0 ]; then
  echo "STATUS: NEEDS_DECISION"
  echo "⚠️  docs/components.md 不存在"
  echo ""
  echo "影响：code-format 无法查找现有组件，将基于 src/ 目录扫描推断，"
  echo "      存在重复造轮子风险（已有组件被重新实现）。"
  echo ""
  echo "解决方案："
  echo "   1. 等待 component-doc-gen CI 定时任务生成并合并 MR（推荐）"
  echo "   2. 手动创建 docs/components.md"
  echo "   3. 以降级模式继续（接受组件复用质量下降）"
  echo ""
fi

if [ ${#WARN[@]} -gt 0 ]; then
  echo "⚠️  以下文档缺失（可继续，质量有所下降）："
  for f in "${WARN[@]}"; do echo "   - $f"; done
  echo ""
fi

if [ ${#PAUSE[@]} -gt 0 ]; then
  exit 2
fi

echo "STATUS: OK"
[ ${#WARN[@]} -eq 0 ] && echo "✓ 所有文档齐全，可以开始" || echo "✓ 必需文档存在，可以开始"
exit 0
