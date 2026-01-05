#!/bin/bash
# Claude Code 一键安装器 (macOS)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║       Claude Code 一键安装器 (国内镜像加速)               ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  本工具将自动完成以下操作:                                ║"
echo "║    1. 安装 Node.js（使用淘宝镜像）                        ║"
echo "║    2. 配置 npm 使用国内镜像（永久生效）                   ║"
echo "║    3. 安装 Claude Code                                    ║"
echo "║    4. 配置 API Key（图形界面）                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

read -p "是否开始安装？(Y/N, 默认 Y): " confirm
confirm=${confirm:-Y}

if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
  echo "已取消"
  exit 0
fi

# ============================================================
# 步骤 1: 安装 Node.js
# ============================================================
echo ""
echo "============================================================"
echo "[步骤 1/4] 检测/安装 Node.js"
echo "============================================================"

if command -v node &> /dev/null; then
  echo "[检测] 已安装 Node.js:"
  node --version
  echo "[跳过] 无需重复安装"
else
  echo "[检测] 未安装 Node.js，开始下载..."

  NODE_VERSION="22.12.0"
  FILENAME="node-v${NODE_VERSION}.pkg"
  MIRROR_URL="https://npmmirror.com/mirrors/node/v${NODE_VERSION}/${FILENAME}"
  BACKUP_URL="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v${NODE_VERSION}/${FILENAME}"
  DOWNLOAD_PATH="/tmp/${FILENAME}"

  echo "[下载] 从淘宝镜像下载 Node.js v${NODE_VERSION}..."

  if curl -L --progress-bar -o "${DOWNLOAD_PATH}" "${MIRROR_URL}"; then
    echo "[下载] 下载完成！"
  else
    echo "[警告] 淘宝镜像失败，尝试清华源..."
    if curl -L --progress-bar -o "${DOWNLOAD_PATH}" "${BACKUP_URL}"; then
      echo "[下载] 下载完成！"
    else
      echo "[错误] 下载失败"
      exit 1
    fi
  fi

  echo "[安装] 正在安装 Node.js（需要管理员密码）..."
  sudo installer -pkg "${DOWNLOAD_PATH}" -target /

  if [ $? -ne 0 ]; then
    echo "[错误] Node.js 安装失败"
    exit 1
  fi

  rm -f "${DOWNLOAD_PATH}"
  echo "[OK] Node.js 安装完成"
fi

# ============================================================
# 步骤 2: 配置 npm 镜像（永久生效）
# ============================================================
echo ""
echo "============================================================"
echo "[步骤 2/4] 配置 npm 使用国内镜像（永久生效）"
echo "============================================================"

# 设置 npm 配置
npm config set registry https://registry.npmmirror.com

# 添加到 shell 配置文件，确保永久生效
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
  SHELL_RC="$HOME/.bash_profile"
fi

# 检查是否已配置
if ! grep -q "npm_config_registry" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# npm 国内镜像" >> "$SHELL_RC"
  echo "export npm_config_registry=https://registry.npmmirror.com" >> "$SHELL_RC"
fi

export npm_config_registry=https://registry.npmmirror.com

echo "[OK] npm 镜像配置完成"
echo "[当前] registry: https://registry.npmmirror.com"
echo "[提示] 已添加到 shell 配置，永久生效"

# ============================================================
# 步骤 3: 安装 Claude Code
# ============================================================
echo ""
echo "============================================================"
echo "[步骤 3/4] 安装 Claude Code"
echo "============================================================"

echo "[安装] @anthropic-ai/claude-code ..."
npm install -g @anthropic-ai/claude-code

if [ $? -ne 0 ]; then
  echo "[错误] Claude Code 安装失败"
  exit 1
fi
echo "[OK] Claude Code 安装完成"

# ============================================================
# 步骤 4: 配置 API Key（图形界面）
# ============================================================
echo ""
echo "============================================================"
echo "[步骤 4/4] 配置 API Key"
echo "============================================================"

echo "[提示] 即将弹出输入框，请输入你的 API Key"
echo "[提示] API Key 从 open.bigmodel.cn 获取"

# 使用 AppleScript 弹出图形界面输入框
API_KEY=$(osascript -e 'tell app "System Events" to display dialog "请输入你的 API Key

从 open.bigmodel.cn 获取
格式: xxxxxxxx.xxxxxxxx" default answer "" with title "Claude Code - API Key 配置" with icon note buttons {"取消", "确定"} default button "确定"' -e 'text returned of result' 2>/dev/null)

if [ -z "$API_KEY" ]; then
  echo "[跳过] 未输入 API Key"
  echo "[提示] 稍后可手动设置环境变量 ANTHROPIC_AUTH_TOKEN"
else
  echo "[设置] 正在配置环境变量..."

  # 移除旧的配置（如果存在）
  grep -v "ANTHROPIC_AUTH_TOKEN" "$SHELL_RC" > "$SHELL_RC.tmp" 2>/dev/null
  grep -v "ANTHROPIC_BASE_URL" "$SHELL_RC.tmp" > "$SHELL_RC" 2>/dev/null
  rm -f "$SHELL_RC.tmp"

  # 添加新配置
  echo "" >> "$SHELL_RC"
  echo "# Claude Code API 配置" >> "$SHELL_RC"
  echo "export ANTHROPIC_AUTH_TOKEN=\"$API_KEY\"" >> "$SHELL_RC"
  echo "export ANTHROPIC_BASE_URL=\"https://open.bigmodel.cn/api/anthropic\"" >> "$SHELL_RC"

  # 立即生效
  export ANTHROPIC_AUTH_TOKEN="$API_KEY"
  export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"

  echo "[OK] API Key 配置完成"
fi

# ============================================================
# 完成
# ============================================================
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    安装完成！                              ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  请关闭此终端，重新打开                                   ║"
echo "║                                                            ║"
echo "║  运行以下命令启动 Claude Code:                            ║"
echo "║    npx @anthropic-ai/claude-code                          ║"
echo "║                                                            ║"
echo "║  安装 Skills (可选):                                      ║"
echo "║    npm install -g @anthropic-ai/claude-code-skill-pdf     ║"
echo "║    npm install -g @anthropic-ai/claude-code-skill-xlsx    ║"
echo "║    npm install -g @anthropic-ai/claude-code-skill-pptx    ║"
echo "║    npm install -g @anthropic-ai/claude-code-skill-docx    ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
