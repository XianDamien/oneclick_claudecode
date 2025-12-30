#!/usr/bin/env node
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');

const { getConfig, ROOT_DIR } = require('./config');

// 检测平台
const platform = os.platform();
const isWindows = platform === 'win32';
const isMac = platform === 'darwin';

// 获取 Node.js 路径
function getNodePath() {
  if (isWindows) {
    return path.join(ROOT_DIR, 'node', 'node.exe');
  } else if (isMac) {
    // macOS: 先检查便携版，再用系统版
    const portableNode = path.join(ROOT_DIR, 'node', 'bin', 'node');
    if (fs.existsSync(portableNode)) {
      return portableNode;
    }
    // 使用系统 Node
    return 'node';
  }
  return 'node';
}

// 获取 Claude Code CLI 路径
function getClaudeCodePath() {
  if (isWindows) {
    return path.join(ROOT_DIR, 'node', 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js');
  } else if (isMac) {
    // macOS: 先检查便携版
    const portableCli = path.join(ROOT_DIR, 'node', 'lib', 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js');
    if (fs.existsSync(portableCli)) {
      return portableCli;
    }
    // 检查全局安装
    const globalCli = path.join(ROOT_DIR, 'node', 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js');
    if (fs.existsSync(globalCli)) {
      return globalCli;
    }
    // 尝试使用 npx
    return null;
  }
  return null;
}

// 获取 Git Bash 路径 (仅 Windows)
function getGitBashPath() {
  if (!isWindows) return null;

  const portableGit = path.join(ROOT_DIR, 'PortableGit', 'bin', 'bash.exe');
  if (fs.existsSync(portableGit)) {
    return portableGit;
  }
  return null;
}

// 主函数
async function main() {
  console.log(`[Claude Code Portable] 平台: ${platform}`);

  // 加载并验证配置
  const config = getConfig();

  // 设置环境变量
  process.env.ANTHROPIC_AUTH_TOKEN = config.apiKey;
  if (config.baseUrl) {
    process.env.ANTHROPIC_BASE_URL = config.baseUrl;
  }

  // Windows: 设置 Git Bash 路径
  const gitBashPath = getGitBashPath();
  if (gitBashPath) {
    process.env.CLAUDE_CODE_GIT_BASH_PATH = gitBashPath;
  }

  // 获取 Node 和 CLI 路径
  const nodePath = getNodePath();
  const cliPath = getClaudeCodePath();

  // 处理工作目录参数
  const args = process.argv.slice(2);
  let workDir = process.cwd();

  // 如果第一个参数是目录，切换到该目录
  if (args.length > 0 && fs.existsSync(args[0]) && fs.statSync(args[0]).isDirectory()) {
    workDir = path.resolve(args[0]);
    args.shift();
    console.log(`[Claude Code Portable] 工作目录: ${workDir}`);
  }

  // 启动 Claude Code
  console.log('[Claude Code Portable] 正在启动...\n');

  let child;

  if (cliPath && fs.existsSync(cliPath)) {
    // 使用便携版 CLI
    child = spawn(nodePath, [cliPath, ...args], {
      cwd: workDir,
      stdio: 'inherit',
      env: process.env
    });
  } else {
    // 使用 npx 运行
    const npxCmd = isWindows ? 'npx.cmd' : 'npx';
    child = spawn(npxCmd, ['@anthropic-ai/claude-code', ...args], {
      cwd: workDir,
      stdio: 'inherit',
      env: process.env,
      shell: true
    });
  }

  child.on('error', (error) => {
    console.error('[错误] 启动失败:', error.message);
    console.error('\n请确保已安装 Claude Code:');
    console.error('  npm install -g @anthropic-ai/claude-code');
    process.exit(1);
  });

  child.on('exit', (code) => {
    process.exit(code || 0);
  });
}

main().catch((error) => {
  console.error('[错误]', error.message);
  process.exit(1);
});
