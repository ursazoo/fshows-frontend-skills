#!/bin/bash
# fshows-frontend-skills 安装脚本
# 将 skills/ 目录下的所有 skill 软链接到 ~/.claude/skills/
#
# 用法：bash install.sh

set -e

SKILLS_DIR="$(cd "$(dirname "$0")/skills" && pwd)"
TARGET_DIR="$HOME/.claude/skills"

# 检查 Claude Code 是否安装
if ! command -v claude &>/dev/null; then
  echo "错误：未找到 claude 命令，请先安装 Claude Code：https://claude.ai/code"
  exit 1
fi

mkdir -p "$TARGET_DIR"

echo "安装 skills 到 $TARGET_DIR ..."
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$TARGET_DIR/$skill_name"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  跳过 $skill_name（已存在，如需更新请先删除 $target）"
  else
    ln -s "$skill_dir" "$target"
    echo "  ✓ $skill_name"
  fi
done

echo ""
echo "安装完成。在任意项目目录打开 Claude Code 后，输入 /design-to-code 即可使用。"
echo ""
echo "下一步：配置蓝湖 MCP（见 QUICKSTART.md 第一步）"
