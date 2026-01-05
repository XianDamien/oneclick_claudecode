# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code 一键安装器 is a cross-platform (Windows/macOS) one-click installer for Claude Code. It uses Chinese mirrors (淘宝/清华) for all downloads, solving network connectivity issues in China.

## Features

- **One-Click Installation**: Automatically installs Node.js + npm mirror + Claude Code + API Key configuration
- **Cross-platform Support**: Windows (.cmd) and macOS (.sh) scripts
- **Chinese Mirror Acceleration**: Uses npmmirror.com (淘宝) with Tsinghua backup
- **GUI Configuration**: API Key input via PowerShell InputBox (Windows) or AppleScript dialog (macOS)
- **Permanent Mirror Config**: npm mirror added to system environment variables

## Architecture

Simple shell scripts that:
1. Download and install Node.js using PowerShell `Invoke-WebRequest` (Windows) or `curl` (macOS)
2. Configure npm to use Chinese mirror (setx for Windows, shell rc file for macOS)
3. Install Claude Code globally via npm
4. Show GUI dialog for API Key input

## Directory Structure

```
ClaudeCodeInstaller/
├── 一键安装.cmd              # Windows one-click installer (main entry)
├── 一键安装.sh               # macOS one-click installer (main entry)
├── install_nodejs.cmd/sh     # Node.js installer (standalone)
├── setup_npm_mirror.cmd/sh   # npm mirror configuration (standalone)
├── install_global.cmd/sh     # Claude Code installer (standalone)
├── LICENSE                   # MIT license
└── README.md                 # Documentation
```

## Key Environment Variables

- `ANTHROPIC_AUTH_TOKEN`: API key (required)
- `ANTHROPIC_BASE_URL`: API proxy URL (default: `https://open.bigmodel.cn/api/anthropic`)
- `npm_config_registry`: npm mirror (default: `https://registry.npmmirror.com`)

## Update Command

```bash
npm install -g @anthropic-ai/claude-code@latest
```

## Install Skills (Optional)

In Claude Code, run:

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
```

Restart Claude Code after installation.
