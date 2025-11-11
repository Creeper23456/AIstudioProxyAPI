# AIstudioProxyAPI - 从 Poetry 迁移到 uv 的设置脚本 (PowerShell 版本)
# 此脚本将帮助您完成 uv 环境的设置

Write-Host "🚀 AIstudioProxyAPI - 从 Poetry 迁移到 uv" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

# 检查 uv 是否已安装
try {
    $uvVersion = uv --version 2>$null
    Write-Host "✅ uv 已安装: $uvVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ uv 未安装，正在安装 uv..." -ForegroundColor Red
    Write-Host "请参考以下命令安装 uv：" -ForegroundColor Yellow
    Write-Host "  Windows (PowerShell):" -ForegroundColor Cyan
    Write-Host "  powershell -c `"irm https://astral.sh/uv/install.ps1 | iex`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "安装完成后，请重新运行此脚本" -ForegroundColor Yellow
    exit 1
}

# 检查当前目录是否正确
if (-not (Test-Path "pyproject.toml")) {
    Write-Host "❌ 错误: 请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

Write-Host "📦 正在安装项目依赖..." -ForegroundColor Yellow
# 使用 uv 安装依赖
uv sync

Write-Host "🔧 正在安装浏览器依赖..." -ForegroundColor Yellow
# 安装 Camoufox 和 Playwright 依赖
uv run camoufox fetch
uv run playwright install-deps firefox

Write-Host "✅ 环境设置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 现在可以使用以下命令运行项目：" -ForegroundColor Cyan
Write-Host "  启动 GUI 模式:     uv run python gui_launcher.py" -ForegroundColor White
Write-Host "  启动调试模式:     uv run python launch_camoufox.py --debug" -ForegroundColor White
Write-Host "  启动无头模式:     uv run python launch_camoufox.py --headless" -ForegroundColor White
Write-Host ""
Write-Host "📖 更多信息请查看 docs/poetry-to-uv-migration.md" -ForegroundColor Cyan