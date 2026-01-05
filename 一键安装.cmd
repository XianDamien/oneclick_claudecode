@echo off
chcp 65001 >nul
title Claude Code 一键安装器

echo.
echo ============================================================
echo        Claude Code 一键安装器 (国内镜像加速)
echo ============================================================
echo   本工具将自动完成以下操作:
echo     1. 设置 PowerShell 执行策略
echo     2. 安装 Node.js (使用淘宝镜像)
echo     3. 配置 npm 使用国内镜像 (永久生效)
echo     4. 安装 Claude Code
echo     5. 配置 API Key (图形界面)
echo ============================================================
echo.

set /p confirm="是否开始安装？(Y/N, 默认 Y): "
if /i "%confirm%"=="N" (
    echo 已取消
    pause
    exit /b 0
)

:: ============================================================
:: 步骤 1: 设置 PowerShell 执行策略
:: ============================================================
echo.
echo ============================================================
echo [步骤 1/5] 设置 PowerShell 执行策略
echo ============================================================

powershell -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] PowerShell 执行策略已设置
) else (
    echo [警告] 设置执行策略失败，可能需要管理员权限
)

:: ============================================================
:: 步骤 2: 安装 Node.js
:: ============================================================
echo.
echo ============================================================
echo [步骤 2/5] 检测/安装 Node.js
echo ============================================================

where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [检测] 已安装 Node.js:
    node --version
    echo [跳过] 无需重复安装
    goto :npm_mirror
)

echo [检测] 未安装 Node.js，开始下载...

:: 设置变量
set "NODE_VERSION=22.12.0"
set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"

set "FILENAME=node-v%NODE_VERSION%-%ARCH%.msi"
set "MIRROR_URL=https://npmmirror.com/mirrors/node/v%NODE_VERSION%/%FILENAME%"
set "BACKUP_URL=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v%NODE_VERSION%/%FILENAME%"
set "DOWNLOAD_PATH=%TEMP%\%FILENAME%"

echo [下载] 从淘宝镜像下载 Node.js v%NODE_VERSION%...
echo [下载] URL: %MIRROR_URL%

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference = 'Continue'; " ^
  "try { " ^
  "  Write-Host '正在下载，请稍候...' -ForegroundColor Cyan; " ^
  "  Invoke-WebRequest -Uri '%MIRROR_URL%' -OutFile '%DOWNLOAD_PATH%' -UseBasicParsing; " ^
  "  Write-Host '下载完成！' -ForegroundColor Green; " ^
  "} catch { " ^
  "  Write-Host '淘宝镜像失败，尝试清华源...' -ForegroundColor Yellow; " ^
  "  try { " ^
  "    Invoke-WebRequest -Uri '%BACKUP_URL%' -OutFile '%DOWNLOAD_PATH%' -UseBasicParsing; " ^
  "    Write-Host '下载完成！' -ForegroundColor Green; " ^
  "  } catch { " ^
  "    Write-Host '下载失败: ' + $_.Exception.Message -ForegroundColor Red; " ^
  "    exit 1; " ^
  "  } " ^
  "}"

if errorlevel 1 (
    echo [错误] Node.js 下载失败
    echo 请手动下载: %MIRROR_URL%
    pause
    exit /b 1
)

if not exist "%DOWNLOAD_PATH%" (
    echo [错误] 下载文件不存在
    pause
    exit /b 1
)

echo [安装] 正在安装 Node.js...
msiexec /i "%DOWNLOAD_PATH%" /qb

if errorlevel 1 (
    echo [错误] Node.js 安装失败
    pause
    exit /b 1
)

del "%DOWNLOAD_PATH%" 2>nul
echo [OK] Node.js 安装完成

:: 刷新环境变量
set "PATH=%PATH%;C:\Program Files\nodejs"

:: ============================================================
:: 步骤 3: 配置 npm 镜像（永久生效）
:: ============================================================
:npm_mirror
echo.
echo ============================================================
echo [步骤 3/5] 配置 npm 使用国内镜像 (永久生效)
echo ============================================================

:: 设置 npm 配置
call npm config set registry https://registry.npmmirror.com

:: 同时设置系统环境变量，确保所有场景都能使用
setx npm_config_registry "https://registry.npmmirror.com" >nul 2>&1

echo [OK] npm 镜像配置完成
echo [当前] registry: https://registry.npmmirror.com
echo [提示] 已添加到系统环境变量，永久生效

:: ============================================================
:: 步骤 4: 安装 Claude Code
:: ============================================================
echo.
echo ============================================================
echo [步骤 4/5] 安装 Claude Code
echo ============================================================

echo [安装] @anthropic-ai/claude-code ...
call npm install -g @anthropic-ai/claude-code

if errorlevel 1 (
    echo [错误] Claude Code 安装失败
    pause
    exit /b 1
)
echo [OK] Claude Code 安装完成

:: ============================================================
:: 步骤 5: 配置 API Key（图形界面）
:: ============================================================
echo.
echo ============================================================
echo [步骤 5/5] 配置 API Key
echo ============================================================

:: 配置文件路径
set "CONFIG_DIR=%USERPROFILE%\.claude-installer"
set "CONFIG_FILE=%CONFIG_DIR%\config.json"

:: 检查是否存在配置文件
set "USE_DEFAULT=N"
if exist "%CONFIG_FILE%" (
    echo [检测] 发现已保存的配置
    echo.

    :: 读取配置文件
    for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$config = Get-Content '%CONFIG_FILE%' | ConvertFrom-Json; " ^
      "Write-Output $config.apiKey"') do set "SAVED_API_KEY=%%i"

    for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "$config = Get-Content '%CONFIG_FILE%' | ConvertFrom-Json; " ^
      "Write-Output $config.baseUrl"') do set "SAVED_BASE_URL=%%i"

    echo [已保存] Base URL: %SAVED_BASE_URL%
    echo [已保存] API Key: %SAVED_API_KEY:~0,20%...
    echo.

    set /p USE_DEFAULT="是否使用已保存的配置？(Y/N, 默认 Y): "
    if /i "%USE_DEFAULT%"=="" set "USE_DEFAULT=Y"

    if /i "%USE_DEFAULT%"=="Y" (
        set "API_KEY=%SAVED_API_KEY%"
        set "BASE_URL=%SAVED_BASE_URL%"
        echo [使用] 已保存的配置
        goto :save_env
    )
)

:: 弹出GUI配置
echo [提示] 即将弹出配置窗口，请填写 API 信息

:: 使用 PowerShell 创建双输入框的 GUI 表单
for /f "usebackq tokens=1,2 delims=|" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Add-Type -AssemblyName System.Windows.Forms; " ^
  "Add-Type -AssemblyName System.Drawing; " ^
  "$form = New-Object System.Windows.Forms.Form; " ^
  "$form.Text = 'Claude Code - API 配置'; " ^
  "$form.Size = New-Object System.Drawing.Size(500, 280); " ^
  "$form.StartPosition = 'CenterScreen'; " ^
  "$form.FormBorderStyle = 'FixedDialog'; " ^
  "$form.MaximizeBox = $false; " ^
  "$label1 = New-Object System.Windows.Forms.Label; " ^
  "$label1.Text = 'API Base URL (默认使用智谱 AI 代理):'; " ^
  "$label1.Location = New-Object System.Drawing.Point(20, 20); " ^
  "$label1.Size = New-Object System.Drawing.Size(450, 20); " ^
  "$textBox1 = New-Object System.Windows.Forms.TextBox; " ^
  "$textBox1.Location = New-Object System.Drawing.Point(20, 45); " ^
  "$textBox1.Size = New-Object System.Drawing.Size(440, 25); " ^
  "$textBox1.Text = 'https://open.bigmodel.cn/api/anthropic'; " ^
  "$label2 = New-Object System.Windows.Forms.Label; " ^
  "$label2.Text = 'API Key (从 open.bigmodel.cn 获取):'; " ^
  "$label2.Location = New-Object System.Drawing.Point(20, 85); " ^
  "$label2.Size = New-Object System.Drawing.Size(450, 20); " ^
  "$textBox2 = New-Object System.Windows.Forms.TextBox; " ^
  "$textBox2.Location = New-Object System.Drawing.Point(20, 110); " ^
  "$textBox2.Size = New-Object System.Drawing.Size(440, 25); " ^
  "$textBox2.Text = ''; " ^
  "$label3 = New-Object System.Windows.Forms.Label; " ^
  "$label3.Text = '提示: API Key 格式为 xxxxxxxx.xxxxxxxx'; " ^
  "$label3.Location = New-Object System.Drawing.Point(20, 140); " ^
  "$label3.Size = New-Object System.Drawing.Size(450, 20); " ^
  "$label3.ForeColor = [System.Drawing.Color]::Gray; " ^
  "$okButton = New-Object System.Windows.Forms.Button; " ^
  "$okButton.Location = New-Object System.Drawing.Point(280, 180); " ^
  "$okButton.Size = New-Object System.Drawing.Size(80, 30); " ^
  "$okButton.Text = '确定'; " ^
  "$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; " ^
  "$cancelButton = New-Object System.Windows.Forms.Button; " ^
  "$cancelButton.Location = New-Object System.Drawing.Point(380, 180); " ^
  "$cancelButton.Size = New-Object System.Drawing.Size(80, 30); " ^
  "$cancelButton.Text = '取消'; " ^
  "$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel; " ^
  "$form.Controls.AddRange(@($label1, $textBox1, $label2, $textBox2, $label3, $okButton, $cancelButton)); " ^
  "$form.AcceptButton = $okButton; " ^
  "$form.CancelButton = $cancelButton; " ^
  "$result = $form.ShowDialog(); " ^
  "if ($result -eq [System.Windows.Forms.DialogResult]::OK) { " ^
  "  Write-Output ($textBox1.Text + '|' + $textBox2.Text); " ^
  "} else { " ^
  "  Write-Output '|'; " ^
  "}"`) do (
    set "BASE_URL=%%a"
    set "API_KEY=%%b"
)

if "%BASE_URL%"=="" set "BASE_URL=https://open.bigmodel.cn/api/anthropic"

if "%API_KEY%"=="" (
    echo [跳过] 未输入 API Key
    echo [提示] 稍后可手动设置环境变量 ANTHROPIC_AUTH_TOKEN
    goto :done
)

:: 保存配置到文件
echo [保存] 正在保存配置到 %CONFIG_FILE%...
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$config = @{apiKey='%API_KEY%'; baseUrl='%BASE_URL%'}; " ^
  "$config | ConvertTo-Json | Set-Content '%CONFIG_FILE%' -Encoding UTF8"

echo [OK] 配置已保存，下次可直接使用

:save_env
:: 设置用户环境变量（永久）
echo [设置] 正在配置环境变量...
setx ANTHROPIC_AUTH_TOKEN "%API_KEY%" >nul
setx ANTHROPIC_BASE_URL "%BASE_URL%" >nul

:: 同时设置当前会话的环境变量（立即生效）
set "ANTHROPIC_AUTH_TOKEN=%API_KEY%"
set "ANTHROPIC_BASE_URL=%BASE_URL%"

echo [OK] API 配置完成

:: ============================================================
:: 完成 - 启动 Claude Code
:: ============================================================
echo.
echo ============================================================
echo                     安装完成!
echo ============================================================
echo.
echo   安装 Skills (可选，在 Claude Code 中运行):
echo     /plugin marketplace add anthropics/skills
echo     /plugin install document-skills@anthropic-agent-skills
echo.
echo   Skills 安装位置:
echo     %USERPROFILE%\.claude\plugins\marketplaces\anthropic-agent-skills\skills\
echo.
echo ============================================================
echo.
echo [启动] 正在启动 Claude Code...
echo.

:: 启动 Claude Code
call npx @anthropic-ai/claude-code

pause
exit /b 0

:: ============================================================
:: 未配置 API Key 的情况
:: ============================================================
:done
echo.
echo ============================================================
echo                     安装完成!
echo ============================================================
echo.
echo   [注意] 未配置 API Key，需要手动设置:
echo     setx ANTHROPIC_AUTH_TOKEN "你的API_KEY"
echo     setx ANTHROPIC_BASE_URL "https://open.bigmodel.cn/api/anthropic"
echo.
echo   然后重新打开终端，运行:
echo     npx @anthropic-ai/claude-code
echo.
echo   安装 Skills (可选，在 Claude Code 中运行):
echo     /plugin marketplace add anthropics/skills
echo     /plugin install document-skills@anthropic-agent-skills
echo.
echo   Skills 安装位置:
echo     %USERPROFILE%\.claude\plugins\marketplaces\anthropic-agent-skills\skills\
echo.
echo ============================================================

pause
