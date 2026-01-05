#!/bin/bash
# npm 镜像配置 (macOS/Linux)

echo ""
echo "============================================================"
echo "  配置 npm 使用国内镜像（淘宝镜像）"
echo "============================================================"
echo ""

# 检测 npm
if ! command -v npm &> /dev/null; then
  echo "[错误] 未找到 npm 命令"
  echo ""
  echo "请先安装 Node.js:"
  echo "  运行 ./install_nodejs.sh"
  echo ""
  exit 1
fi

echo "[当前] npm registry:"
npm config get registry
echo ""

echo "将配置以下镜像源:"
echo "  registry: https://registry.npmmirror.com"
echo "  disturl: https://npmmirror.com/dist"
echo "  electron_mirror: https://npmmirror.com/mirrors/electron/"
echo "  sass_binary_site: https://npmmirror.com/mirrors/node-sass/"
echo ""

read -p "是否继续？(Y/N, 默认 Y): " confirm
confirm=${confirm:-Y}

if [ "$confirm" != "Y" ] && [ "$confirm" != "y" ]; then
  echo "已取消配置"
  exit 0
fi

echo ""
echo "正在配置..."
echo ""

npm config set registry https://registry.npmmirror.com
npm config set disturl https://npmmirror.com/dist
npm config set electron_mirror https://npmmirror.com/mirrors/electron/
npm config set sass_binary_site https://npmmirror.com/mirrors/node-sass/
npm config set phantomjs_cdnurl https://npmmirror.com/mirrors/phantomjs/
npm config set chromedriver_cdnurl https://npmmirror.com/mirrors/chromedriver/

if [ $? -eq 0 ]; then
  echo ""
  echo "============================================================"
  echo "[成功] npm 镜像配置完成！"
  echo "============================================================"
  echo ""
  echo "[新配置] npm registry:"
  npm config get registry
  echo ""
  echo "现在所有 npm install 操作都会使用淘宝镜像，速度更快！"
  echo ""
else
  echo ""
  echo "[错误] 配置失败"
  echo ""
  exit 1
fi
