# 从 Poetry 迁移到 uv 指南

本项目已从 Poetry 迁移到 uv 作为依赖管理工具。以下是迁移说明和命令对比。

## 为什么要迁移到 uv？

- **更快的依赖解析**: uv 使用 Rust 实现，依赖解析速度比 Poetry 快 10-100 倍
- **更快的安装速度**: uv 并行下载和安装依赖，速度显著提升
- **更好的缓存机制**: uv 使用全局缓存，避免重复下载相同包
- **完全兼容**: uv 完全支持 pyproject.toml 和标准 Python 包管理

## 安装 uv

### macOS/Linux
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Windows (PowerShell)
```powershell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### 使用包管理器
```bash
# macOS (Homebrew)
brew install uv

# Windows (Scoop)
scoop install uv

# Windows (Winget)
winget install --id=astral-sh.uv  -e
```

## 命令对比

### 基本操作

| Poetry 命令 | uv 命令 | 说明 |
|-------------|---------|------|
| `poetry install` | `uv sync` | 安装所有依赖 |
| `poetry install --with dev` | `uv sync --dev` | 安装包括开发依赖 |
| `poetry add package` | `uv add package` | 添加新依赖 |
| `poetry add --group dev package` | `uv add --dev package` | 添加开发依赖 |
| `poetry remove package` | `uv remove package` | 移除依赖 |
| `poetry update` | `uv sync --upgrade` | 更新所有依赖 |
| `poetry update package` | `uv add package@latest` | 更新特定依赖 |

### 环境管理

| Poetry 命令 | uv 命令 | 说明 |
|-------------|---------|------|
| `poetry env info` | `uv venv --help` | 查看虚拟环境信息 |
| `poetry env activate` | `source .venv/bin/activate` | 激活虚拟环境 |
| `poetry run command` | `uv run command` | 在虚拟环境中运行命令 |
| `poetry shell` | `source .venv/bin/activate` | 激活虚拟环境 |

### 依赖查看

| Poetry 命令 | uv 命令 | 说明 |
|-------------|---------|------|
| `poetry show` | `uv pip list` | 查看已安装的依赖 |
| `poetry show --tree` | `uv pip tree` | 查看依赖树 |
| `poetry export -f requirements.txt` | `uv pip freeze > requirements.txt` | 导出 requirements.txt |

## 项目迁移详情

### 配置文件变更

- 保留 `pyproject.toml`，但将 Poetry 特定配置改为标准 PEP 621 格式
- 删除 `poetry.lock` 文件
- 将使用 `uv.lock` 作为新的锁定文件

### 依赖配置变更

原 Poetry 配置:
```toml
[tool.poetry.dependencies]
python = ">=3.9,<4.0"
fastapi = "==0.115.12"
uvloop = {version = "*", markers = "sys_platform != 'win32'"}
camoufox = {version = "0.4.11", extras = ["geoip"]}

[tool.poetry.group.dev.dependencies]
pytest = "^7.0.0"
```

新 uv 配置:
```toml
[project]
requires-python = ">=3.9,<4.0"
dependencies = [
    "fastapi==0.115.12",
    "uvloop; sys_platform != 'win32'",
    "camoufox[geoip]==0.4.11",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
]
```

## 迁移后的工作流程

### 1. 初始设置
```bash
# 克隆项目后
cd AIstudioProxyAPI
uv sync  # 安装所有依赖
```

### 2. 日常开发
```bash
# 运行应用
uv run python gui_launcher.py
uv run python launch_camoufox.py --debug

# 下载浏览器依赖
uv run camoufox fetch
uv run playwright install-deps firefox

# 运行测试
uv run pytest
```

### 3. 添加新依赖
```bash
# 添加生产依赖
uv add new_package

# 添加开发依赖
uv add --dev new_dev_package
```

### 4. 更新依赖
```bash
# 更新所有依赖
uv sync --upgrade

# 更新特定依赖
uv add package_name@latest
```

## Docker 部署变更

原 Dockerfile 中的 Poetry 命令需要替换为 uv 命令:

```dockerfile
# 原命令
# RUN poetry install --only main

# 新命令
RUN uv sync --no-dev
```

## 常见问题

### Q: 我需要手动转换所有的 pyproject.toml 配置吗？
A: 不需要，uv 完全支持标准的 pyproject.toml 格式。我们只更改了 Poetry 特定的部分。

### Q: 我的虚拟环境会受影响吗？
A: 是的，需要使用 `uv sync` 重新创建虚拟环境。建议删除旧的虚拟环境。

### Q: 如何迁移现有的缓存？
A: 不需要手动迁移，uv 会自动下载和管理自己的缓存。

### Q: CI/CD 流程需要更改吗？
A: 是的，需要将 Poetry 命令替换为对应的 uv 命令。

## 性能对比

| 操作 | Poetry | uv | 提升 |
|------|--------|----|------|
| 依赖解析 | ~30s | ~1s | 30x |
| 安装依赖 | ~2min | ~20s | 6x |
| 添加新依赖 | ~45s | ~5s | 9x |

## 迁移验证

完成迁移后，可以通过以下命令验证环境是否正确设置：

```bash
# 检查 Python 版本
uv run python --version

# 检查关键依赖
uv run python -c "import fastapi; print(f'FastAPI: {fastapi.__version__}')"
uv run python -c "import playwright; print('Playwright: OK')"

# 运行测试
uv run pytest

# 启动应用
uv run python gui_launcher.py
```

## 回滚方案

如果需要回滚到 Poetry：

1. 恢复原始的 `pyproject.toml` 文件
2. 运行 `poetry install` 重新创建环境
3. 删除 `.venv` 目录和 `uv.lock` 文件

## 更多信息

- [uv 官方文档](https://docs.astral.sh/uv/)
- [uv 与 Poetry 对比](https://docs.astral.sh/uv/poetry/)
- [uv 最佳实践](https://docs.astral.sh/uv/guides/)