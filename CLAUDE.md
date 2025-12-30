# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code Portable (便携版) is a Windows-only portable environment for running Claude Code without installing Node.js or Git system-wide. It bundles portable versions of Node.js and Git, making it truly portable (e.g., can run from a USB drive).

## Architecture

The project consists of batch scripts and a Node.js helper:

- **config.cmd**: User configuration file for API key and proxy URL (uses 智谱 AI/Bigmodel proxy by default)
- **start_claude.cmd**: Main launcher that sets up the portable environment and starts Claude Code
  - Sets `CLAUDE_CODE_PATH`, `NODE_PATH`, and `CLAUDE_CODE_GIT_BASH_PATH`
  - Supports drag-and-drop: dropping a folder on this script will `cd` to that folder
  - Runs `node.exe` directly with the claude-code CLI
- **generate_reg.js**: Node.js script that generates Windows registry files for right-click context menu integration
  - Creates `add_claude_context.reg` or `remove_claude_context.reg` based on argument
  - Uses utf16le encoding with BOM for Windows registry compatibility
- **_setup_right_click_menu.cmd** / **_remove_right_click_menu.cmd**: Wrapper scripts that call `generate_reg.js` and auto-open the generated .reg files

## Directory Structure (at runtime)

```
ClaudeCodePortable/
├── node/                    # Portable Node.js (contains node.exe, npm.cmd, and node_modules)
├── PortableGit/             # Portable Git (bash.exe at PortableGit/bin/bash.exe)
├── config.cmd               # API Key configuration
└── start_claude.cmd         # Main entry point
```

## Key Environment Variables

- `ANTHROPIC_AUTH_TOKEN`: API key (required, set in config.cmd)
- `ANTHROPIC_BASE_URL`: API proxy URL (default: `https://open.bigmodel.cn/api/anthropic`)
- `CLAUDE_CODE_GIT_BASH_PATH`: Path to portable Git bash

## Update Command

To update Claude Code in this portable environment:
```cmd
.\node\npm.cmd install -g @anthropic-ai/claude-code@latest
```
