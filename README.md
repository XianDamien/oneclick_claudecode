# Claude Code 便携版

[![Author](https://img.shields.io/badge/Author-Steven_Lee-blue.svg)](https://github.com/alitrack)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一个跨平台（Windows/macOS）的开箱即用 Claude Code 环境，无需安装 Node.js 和 Git，解压即用，极致方便。

## ✨ 特性

- **跨平台支持**：同时支持 Windows 和 macOS
- **真正的便携**：所有依赖项（Node.js, Git）已打包，可存放在U盘中随处运行
- **开箱即用**：无需配置环境变量，不污染系统
- **网络友好**：默认配置使用国内大模型 API 代理，解决网络连接问题
- **一键启动**：提供启动脚本，双击即可启动
- **统一配置**：使用 JSON 配置文件，跨平台通用

## 🚀 快速开始

### 1. 配置 API Key

首次使用前，请先配置你的 API Key。

编辑根目录下的 `config.json` 文件：

```json
{
  "apiKey": "你的API_KEY放这里",
  "baseUrl": "https://open.bigmodel.cn/api/anthropic"
}
```

> 本项目默认使用智谱 AI (Bigmodel) 的 API 接口。你可以在 [这里](https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys) 获取你的 Key。

### 2. 启动 Claude Code

#### Windows

- **方法一 (直接启动)**：双击运行 `start.cmd`
- **方法二 (拖拽启动)**：将项目文件夹拖拽到 `start.cmd` 图标上
- **方法三 (旧版脚本)**：双击运行 `start_claude.cmd`（兼容旧版）

#### macOS

```bash
# 直接启动
./start.sh

# 在指定目录启动
./start.sh /path/to/your/project
```

### 3. (可选) 一键安装

如果你下载的是不含 Node.js 的精简版，可以运行安装器自动下载：

#### Windows
```cmd
node launcher\installer.js
```

#### macOS
```bash
node launcher/installer.js
```

### 4. (可选) Windows 右键菜单

1. **添加菜单**：双击运行 `_setup_right_click_menu.cmd`
2. **使用菜单**：在任意文件夹右键选择"在此处打开 Claude Code"
3. **移除菜单**：运行 `_remove_right_click_menu.cmd`

## 📂 目录结构

```
ClaudeCodePortable/
├── node/                          # 便携版 Node.js
├── PortableGit/                   # 便携版 Git (仅Windows)
├── launcher/
│   ├── index.js                   # 跨平台启动器
│   ├── config.js                  # 配置管理
│   └── installer.js               # 安装器
├── config.json                    # 【重要】API Key 配置文件
├── start.cmd                      # Windows 启动脚本
├── start.sh                       # macOS 启动脚本
├── start_claude.cmd               # Windows 启动脚本（旧版）
├── config.cmd                     # Windows 配置（旧版）
├── generate_reg.js                # 注册表生成脚本
├── _setup_right_click_menu.cmd    # 添加右键菜单
└── _remove_right_click_menu.cmd   # 移除右键菜单
```

## ❓ 常见问题 (FAQ)

### Q: 如何更新 Claude Code 到最新版本？

**Windows:**
```cmd
.\node\npm.cmd install -g @anthropic-ai/claude-code@latest
```

**macOS:**
```bash
./node/bin/npm install -g @anthropic-ai/claude-code@latest
```

### Q: macOS 提示"无法验证开发者"？

在终端运行：
```bash
xattr -cr /path/to/ClaudeCodePortable
```

### Q: 如何使用系统安装的 Node.js？

macOS 版本会自动检测系统 Node.js。如果你已经安装了 Node.js，可以删除 `node` 目录，脚本会自动使用系统版本。

## 致谢

- [Anthropic](https://www.anthropic.com/) for creating Claude Code
- [Node.js](https://nodejs.org/)
- [Git for Windows](https://git-scm.com/downloads/win)

---
