@echo off
setlocal

title Claude Code Portable

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"

:: 检查 node 是否存在
if not exist "%SCRIPT_DIR%node\node.exe" (
    echo [错误] 未找到 Node.js，请先运行安装器:
    echo   %SCRIPT_DIR%node\node.exe %SCRIPT_DIR%launcher\installer.js
    echo.
    echo 或者手动下载 Node.js 到 node 目录
    pause
    exit /b 1
)

:: 启动 Claude Code
"%SCRIPT_DIR%node\node.exe" "%SCRIPT_DIR%launcher\index.js" %*

endlocal
