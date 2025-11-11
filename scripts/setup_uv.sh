#!/bin/bash

# AIstudioProxyAPI - 从 Poetry 迁移到 uv 的设置脚本
# 此脚本将帮助您完成 uv 环境的设置

set -e

echo "🚀 AIstudioProxyAPI - 从 Poetry 迁移到 uv"
echo "======================================"

# 检查 uv 是否已安装
if ! command -v uv &> /dev/null; then
    echo "❌ uv 未安装，正在安装 uv..."
    echo "请参考以下命令安装 uv："
    echo "  macOS/Linux:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  Windows (PowerShell):"
    echo "  powershell -c \"irm https://astral.sh/uv/install.ps1 | iex\""
    echo ""
    echo "安装完成后，请重新运行此脚本"
    exit 1
fi

echo "✅ uv 已安装: $(uv --version)"

# 检查当前目录是否正确
if [ ! -f "pyproject.toml" ]; then
    echo "❌ 错误: 请在项目根目录运行此脚本"
    exit 1
fi

echo "📦 正在安装项目依赖..."
# 使用 uv 安装依赖
uv sync

echo "🔧 正在安装浏览器依赖..."
# 安装 Camoufox 和 Playwright 依赖
uv run camoufox fetch
uv run playwright install-deps firefox

echo "✅ 环境设置完成！"
echo ""
echo "🎯 现在可以使用以下命令运行项目："
echo "  启动 GUI 模式:     uv run python gui_launcher.py"
echo "  启动调试模式:     uv run python launch_camoufox.py --debug"
echo "  启动无头模式:     uv run python launch_camoufox.py --headless"
echo ""
echo "📖 更多信息请查看 docs/poetry-to-uv-migration.md"