@echo off
chcp 65001 >nul
title Claude Code - 全局安装器

echo.
echo ============================================================
echo   Claude Code 全局安装器
echo ============================================================
echo.

:: 检测 Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Node.js
    echo.
    echo 请先安装 Node.js:
    echo   双击运行 install_nodejs.cmd
    echo.
    pause
    exit /b 1
)

echo [检测] Node.js 版本:
node --version
echo.

echo 说明:
echo   此工具将安装 Claude Code 到系统全局
echo   安装后可在任意目录使用
echo.

set /p confirm="是否继续安装？(Y/N, 默认 Y): "
if /i "%confirm%"=="N" (
    echo 已取消安装
    pause
    exit /b 0
)

echo.
echo [安装] @anthropic-ai/claude-code ...
call npm install -g @anthropic-ai/claude-code

if errorlevel 1 (
    echo.
    echo [错误] 安装失败
    echo.
    echo 建议:
    echo   1. 检查网络连接
    echo   2. 配置 npm 镜像: setup_npm_mirror.cmd
    echo   3. 重试安装
    echo.
) else (
    echo.
    echo ============================================================
    echo [成功] 安装完成！
    echo ============================================================
    echo.
    echo 现在你可以在任意目录运行:
    echo   npx @anthropic-ai/claude-code
    echo.
    echo 安装 Skills (可选):
    echo   npm install -g @anthropic-ai/claude-code-skill-pdf
    echo   npm install -g @anthropic-ai/claude-code-skill-xlsx
    echo   npm install -g @anthropic-ai/claude-code-skill-pptx
    echo   npm install -g @anthropic-ai/claude-code-skill-docx
    echo.
    echo 提示: 请重新打开命令提示符。
    echo.
)

pause
