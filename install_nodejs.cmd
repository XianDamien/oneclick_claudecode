@echo off
chcp 65001 >nul
title Node.js 系统安装器（国内镜像）

echo.
echo ============================================================
echo   Node.js 系统安装器（使用淘宝镜像，无需翻墙）
echo ============================================================
echo.

:: 检测系统是否已安装 Node.js
where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [检测] 系统已安装 Node.js:
    node --version
    echo.
    set /p continue="是否继续安装/更新？(Y/N, 默认 N): "
    if /i not "%continue%"=="Y" (
        echo 已取消
        pause
        exit /b 0
    )
)

:: 设置变量
set "NODE_VERSION=22.12.0"
set "ARCH=x64"

:: 检测系统架构
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"

set "FILENAME=node-v%NODE_VERSION%-%ARCH%.msi"
set "MIRROR_URL=https://npmmirror.com/mirrors/node/v%NODE_VERSION%/%FILENAME%"
set "BACKUP_URL=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v%NODE_VERSION%/%FILENAME%"
set "DOWNLOAD_PATH=%TEMP%\%FILENAME%"

echo [信息] Node.js 版本: v%NODE_VERSION%
echo [信息] 系统架构: %ARCH%
echo [信息] 下载路径: %DOWNLOAD_PATH%
echo.

:: 下载 Node.js
echo [下载] 正在从淘宝镜像下载 Node.js...
echo [下载] URL: %MIRROR_URL%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference = 'Continue'; " ^
  "try { " ^
  "  Write-Host '正在下载，请稍候...' -ForegroundColor Cyan; " ^
  "  Invoke-WebRequest -Uri '%MIRROR_URL%' -OutFile '%DOWNLOAD_PATH%' -UseBasicParsing; " ^
  "  Write-Host '下载完成！' -ForegroundColor Green; " ^
  "} catch { " ^
  "  Write-Host '淘宝镜像下载失败，尝试清华源...' -ForegroundColor Yellow; " ^
  "  try { " ^
  "    Invoke-WebRequest -Uri '%BACKUP_URL%' -OutFile '%DOWNLOAD_PATH%' -UseBasicParsing; " ^
  "    Write-Host '下载完成！' -ForegroundColor Green; " ^
  "  } catch { " ^
  "    Write-Host '下载失败: ' + $_.Exception.Message -ForegroundColor Red; " ^
  "    exit 1; " ^
  "  } " ^
  "}"

if errorlevel 1 (
    echo.
    echo [错误] 下载失败
    echo.
    echo 请手动下载:
    echo   %MIRROR_URL%
    echo.
    pause
    exit /b 1
)

:: 检查文件是否存在
if not exist "%DOWNLOAD_PATH%" (
    echo [错误] 下载的文件不存在
    pause
    exit /b 1
)

:: 安装 Node.js
echo.
echo [安装] 正在安装 Node.js...
echo [提示] 请在弹出的安装向导中点击"Next"完成安装
echo.

msiexec /i "%DOWNLOAD_PATH%" /qb

if errorlevel 1 (
    echo.
    echo [错误] 安装失败
    echo.
    pause
    exit /b 1
)

:: 清理
del "%DOWNLOAD_PATH%" 2>nul

echo.
echo ============================================================
echo [成功] Node.js 安装完成！
echo ============================================================
echo.
echo 请关闭此窗口，重新打开命令提示符，然后运行:
echo   node --version
echo   npm --version
echo.
echo 接下来:
echo   1. 运行 setup_npm_mirror.cmd 配置国内镜像
echo   2. 运行 install_global.cmd 安装 Claude Code
echo.

pause
