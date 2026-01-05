# Claude Code 一键安装器

[![Author](https://img.shields.io/badge/Author-Steven_Lee-blue.svg)](https://github.com/alitrack)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一个跨平台（Windows/macOS）的 Claude Code 一键安装工具，使用国内镜像加速，解决网络连接问题。

## 特性

- **一键安装**：自动安装 Node.js + npm 镜像 + Claude Code + API Key 配置
- **跨平台支持**：同时支持 Windows 和 macOS
- **国内镜像加速**：使用淘宝/清华镜像，下载速度快，无需翻墙
- **图形界面配置**：API Key 通过 GUI 输入框配置，简单易用
- **永久镜像配置**：npm 镜像自动添加到系统环境变量，永久生效

## 快速开始

### 一键安装（推荐）

#### Windows

双击运行 `一键安装.cmd`

#### macOS

```bash
chmod +x 一键安装.sh
./一键安装.sh
```

安装过程会自动完成：
1. 安装 Node.js（从淘宝镜像下载）
2. 配置 npm 使用国内镜像（永久生效）
3. 安装 Claude Code
4. 弹出图形界面配置 API Key

### 安装完成后

关闭当前终端，重新打开，运行：

```bash
npx @anthropic-ai/claude-code
```

## 分步安装

如果一键安装失败，可以尝试分步安装：

### 1. 安装 Node.js

#### Windows
```cmd
install_nodejs.cmd
```

#### macOS
```bash
./install_nodejs.sh
```

### 2. 配置 npm 镜像

#### Windows
```cmd
setup_npm_mirror.cmd
```

#### macOS
```bash
./setup_npm_mirror.sh
```

### 3. 安装 Claude Code

#### Windows
```cmd
install_global.cmd
```

#### macOS
```bash
./install_global.sh
```

## 安装 Skills（可选）

Skills 可以让 Claude 处理 PDF、Excel、PowerPoint、Word 等文件。

在 Claude Code 中运行以下命令：

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

安装完成后重启 Claude Code 即可使用。

### Skills 文件位置

Skills 安装后存放在用户目录下：

**Windows:**
```
C:\Users\你的用户名\.claude\plugins\marketplaces\anthropic-agent-skills\skills\
```

**macOS:**
```
~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/
```

每个 Skill 是一个文件夹，里面包含 `SKILL.md` 文件，这个文件定义了 Skill 的功能和使用方法。

### 可用的 Skills

安装 `document-skills` 后，你会获得以下 Skills：

| Skill 名称 | 功能说明 |
|-----------|---------|
| `pdf` | PDF 文件处理（提取文本、填写表单、合并等） |
| `xlsx` | Excel 表格处理（创建、编辑、数据分析） |
| `pptx` | PowerPoint 演示文稿（创建幻灯片、应用模板） |
| `docx` | Word 文档处理（创建、编辑、格式化） |
| `skill-creator` | 创建自定义 Skill |
| `mcp-builder` | 创建 MCP 服务器 |
| `webapp-testing` | Web 应用测试 |
| `frontend-design` | 前端设计 |
| `theme-factory` | 主题工厂（配色方案生成） |
| 更多... | 查看 Skills 目录了解全部 |

### 使用示例

```
"使用 pdf skill 提取这个文件的内容"
"使用 xlsx skill 创建一个销售报表"
"使用 pptx skill 制作一个项目汇报 PPT"
"使用 docx skill 写一份工作总结"
"使用 skill-creator 帮我创建一个自定义 skill"
```

## API Key 配置

本项目默认使用智谱 AI (Bigmodel) 的 API 接口。

1. 前往 [智谱 AI 控制台](https://open.bigmodel.cn/usercenter/proj-mgmt/apikeys) 获取 API Key
2. 在安装过程中的图形界面输入框中填入 API Key

如果错过了配置界面，可以手动设置环境变量：

#### Windows
```cmd
setx ANTHROPIC_AUTH_TOKEN "你的API_KEY"
setx ANTHROPIC_BASE_URL "https://open.bigmodel.cn/api/anthropic"
```

#### macOS
```bash
# 添加到 ~/.zshrc 或 ~/.bash_profile
export ANTHROPIC_AUTH_TOKEN="你的API_KEY"
export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
```

## 目录结构

```
ClaudeCodeInstaller/
├── 一键安装.cmd              # Windows 一键安装脚本
├── 一键安装.sh               # macOS 一键安装脚本
├── install_nodejs.cmd        # Windows Node.js 安装器
├── install_nodejs.sh         # macOS Node.js 安装器
├── setup_npm_mirror.cmd      # Windows npm 镜像配置
├── setup_npm_mirror.sh       # macOS npm 镜像配置
├── install_global.cmd        # Windows Claude Code 安装器
├── install_global.sh         # macOS Claude Code 安装器
├── LICENSE                   # MIT 许可证
└── README.md                 # 本文件
```

## 常见问题

### Q: 提示 PowerShell 执行策略错误？

一键安装脚本已自动处理此问题。如果仍然出错，手动运行：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### Q: npm 命令找不到？

关闭当前终端，重新打开一个新的命令提示符/PowerShell/终端窗口。

### Q: 如何更新 Claude Code？

```bash
npm install -g @anthropic-ai/claude-code@latest
```

### Q: macOS 提示"无法验证开发者"？

在终端运行：
```bash
xattr -cr /path/to/ClaudeCodeInstaller
```

### Q: 如何卸载？

```bash
npm uninstall -g @anthropic-ai/claude-code
```

## 致谢

- [Anthropic](https://www.anthropic.com/) for creating Claude Code
- [Node.js](https://nodejs.org/)
- [npmmirror](https://npmmirror.com/) 淘宝 npm 镜像

---
