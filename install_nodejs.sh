#!/bin/bash
# Node.js 系统安装器 (macOS) - 使用 curl 下载，无需预装 Node.js

echo ""
echo "============================================================"
echo "  Node.js 系统安装器（使用淘宝镜像，无需翻墙）"
echo "============================================================"
echo ""

# 检测系统是否已安装 Node.js
if command -v node &> /dev/null; then
  echo "[检测] 系统已安装 Node.js:"
  node --version
  echo ""
  read -p "是否继续安装/更新？(Y/N, 默认 N): " continue
  continue=${continue:-N}
  if [ "$continue" != "Y" ] && [ "$continue" != "y" ]; then
    echo "已取消"
    exit 0
  fi
fi

# 设置变量
NODE_VERSION="22.12.0"
ARCH=$(uname -m)

# 转换架构名称
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
  ARCH="arm64"
else
  ARCH="x64"
fi

# macOS 使用 pkg 安装包
FILENAME="node-v${NODE_VERSION}.pkg"
MIRROR_URL="https://npmmirror.com/mirrors/node/v${NODE_VERSION}/${FILENAME}"
BACKUP_URL="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v${NODE_VERSION}/${FILENAME}"
DOWNLOAD_PATH="/tmp/${FILENAME}"

echo "[信息] Node.js 版本: v${NODE_VERSION}"
echo "[信息] 系统架构: ${ARCH}"
echo "[信息] 下载路径: ${DOWNLOAD_PATH}"
echo ""

# 下载 Node.js
echo "[下载] 正在从淘宝镜像下载 Node.js..."
echo "[下载] URL: ${MIRROR_URL}"
echo ""

if curl -L --progress-bar -o "${DOWNLOAD_PATH}" "${MIRROR_URL}"; then
  echo "[下载] 下载完成！"
else
  echo "[警告] 淘宝镜像下载失败，尝试清华源..."
  if curl -L --progress-bar -o "${DOWNLOAD_PATH}" "${BACKUP_URL}"; then
    echo "[下载] 下载完成！"
  else
    echo ""
    echo "[错误] 下载失败"
    echo ""
    echo "请手动下载:"
    echo "  ${MIRROR_URL}"
    echo ""
    exit 1
  fi
fi

# 检查文件是否存在
if [ ! -f "${DOWNLOAD_PATH}" ]; then
  echo "[错误] 下载的文件不存在"
  exit 1
fi

# 安装 Node.js
echo ""
echo "[安装] 正在安装 Node.js..."
echo "[提示] 需要管理员权限，请输入密码"
echo ""

sudo installer -pkg "${DOWNLOAD_PATH}" -target /

if [ $? -ne 0 ]; then
  echo ""
  echo "[错误] 安装失败"
  echo ""
  exit 1
fi

# 清理
rm -f "${DOWNLOAD_PATH}"

echo ""
echo "============================================================"
echo "[成功] Node.js 安装完成！"
echo "============================================================"
echo ""
echo "请关闭此终端，重新打开，然后运行:"
echo "  node --version"
echo "  npm --version"
echo ""
echo "接下来:"
echo "  1. 运行 ./setup_npm_mirror.sh 配置国内镜像"
echo "  2. 运行 ./install_global.sh 安装 Claude Code"
echo ""
