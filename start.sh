#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 检查便携版 Node.js
PORTABLE_NODE="$SCRIPT_DIR/node/bin/node"

if [ -f "$PORTABLE_NODE" ]; then
    # 使用便携版 Node.js
    "$PORTABLE_NODE" "$SCRIPT_DIR/launcher/index.js" "$@"
elif command -v node &> /dev/null; then
    # 使用系统 Node.js
    node "$SCRIPT_DIR/launcher/index.js" "$@"
else
    echo "[错误] 未找到 Node.js"
    echo ""
    echo "请选择以下方式之一:"
    echo "  1. 运行安装器下载便携版 Node.js:"
    echo "     node $SCRIPT_DIR/launcher/installer.js"
    echo ""
    echo "  2. 安装系统 Node.js:"
    echo "     brew install node"
    echo ""
    exit 1
fi
