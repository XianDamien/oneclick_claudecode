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

# 配置文件路径
CONFIG_DIR="$HOME/.claude-installer"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Shell 配置文件
SHELL_RC="$HOME/.zshrc"
if [ ! -f "$SHELL_RC" ]; then
  SHELL_RC="$HOME/.bash_profile"
fi

# 检查是否存在配置文件
USE_DEFAULT="N"
if [ -f "$CONFIG_FILE" ]; then
  echo "[检测] 发现已保存的配置"
  echo ""

  # 读取配置文件
  if command -v python3 &> /dev/null; then
    SAVED_API_KEY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['apiKey'])" 2>/dev/null)
    SAVED_BASE_URL=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['baseUrl'])" 2>/dev/null)
  else
    # 使用 grep 和 sed 简单解析（备用方案）
    SAVED_API_KEY=$(grep '"apiKey"' "$CONFIG_FILE" | sed 's/.*"apiKey"[^"]*"\([^"]*\)".*/\1/')
    SAVED_BASE_URL=$(grep '"baseUrl"' "$CONFIG_FILE" | sed 's/.*"baseUrl"[^"]*"\([^"]*\)".*/\1/')
  fi

  echo "[已保存] Base URL: $SAVED_BASE_URL"
  echo "[已保存] API Key: ${SAVED_API_KEY:0:20}..."
  echo ""

  read -p "是否使用已保存的配置？(Y/N, 默认 Y): " USE_DEFAULT
  USE_DEFAULT=${USE_DEFAULT:-Y}

  if [ "$USE_DEFAULT" = "Y" ] || [ "$USE_DEFAULT" = "y" ]; then
    API_KEY="$SAVED_API_KEY"
    BASE_URL="$SAVED_BASE_URL"
    echo "[使用] 已保存的配置"
  else
    USE_DEFAULT="N"
  fi
fi

# 如果不使用默认配置，弹出GUI
if [ "$USE_DEFAULT" != "Y" ] && [ "$USE_DEFAULT" != "y" ]; then
  echo "[提示] 即将弹出输入框，请配置 API 信息"
  echo "[提示] API Key 从 open.bigmodel.cn 获取"

  # 使用 AppleScript 弹出图形界面输入框（配置 Base URL）
  BASE_URL=$(osascript -e 'tell app "System Events" to display dialog "请输入 API Base URL

默认: https://open.bigmodel.cn/api/anthropic
支持智谱AI等国内代理" default answer "https://open.bigmodel.cn/api/anthropic" with title "Claude Code - Base URL 配置" with icon note buttons {"取消", "确定"} default button "确定"' -e 'text returned of result' 2>/dev/null)

  if [ -z "$BASE_URL" ]; then
    BASE_URL="https://open.bigmodel.cn/api/anthropic"
  fi

  # 使用 AppleScript 弹出图形界面输入框（配置 API Key）
  API_KEY=$(osascript -e 'tell app "System Events" to display dialog "请输入你的 API Key

从 open.bigmodel.cn 获取
格式: xxxxxxxx.xxxxxxxx" default answer "" with title "Claude Code - API Key 配置" with icon note buttons {"取消", "确定"} default button "确定"' -e 'text returned of result' 2>/dev/null)

  if [ -z "$API_KEY" ]; then
    echo "[跳过] 未输入 API Key"
    echo "[提示] 稍后可手动设置环境变量 ANTHROPIC_AUTH_TOKEN"
  else
    # 保存配置到文件
    echo "[保存] 正在保存配置到 $CONFIG_FILE..."
    mkdir -p "$CONFIG_DIR"

    cat > "$CONFIG_FILE" << EOF
{
  "apiKey": "$API_KEY",
  "baseUrl": "$BASE_URL"
}
EOF
    echo "[OK] 配置已保存，下次可直接使用"
  fi
fi

# 设置环境变量
if [ -n "$API_KEY" ]; then
  echo "[设置] 正在配置环境变量..."

  # 移除旧的配置（如果存在）
  grep -v "ANTHROPIC_AUTH_TOKEN" "$SHELL_RC" > "$SHELL_RC.tmp" 2>/dev/null || true
  grep -v "ANTHROPIC_BASE_URL" "$SHELL_RC.tmp" > "$SHELL_RC" 2>/dev/null || true
  rm -f "$SHELL_RC.tmp"

  # 添加新配置
  echo "" >> "$SHELL_RC"
  echo "# Claude Code API 配置" >> "$SHELL_RC"
  echo "export ANTHROPIC_AUTH_TOKEN=\"$API_KEY\"" >> "$SHELL_RC"
  echo "export ANTHROPIC_BASE_URL=\"$BASE_URL\"" >> "$SHELL_RC"

  # 立即生效
  export ANTHROPIC_AUTH_TOKEN="$API_KEY"
  export ANTHROPIC_BASE_URL="$BASE_URL"

  echo "[OK] API 配置完成"
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
