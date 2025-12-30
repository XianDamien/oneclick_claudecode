#!/usr/bin/env node
const https = require('https');
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync, spawn } = require('child_process');

const ROOT_DIR = path.dirname(__dirname);

// Node.js 版本
const NODE_VERSION = '22.12.0';

// 检测平台和架构
const platform = os.platform();
const arch = os.arch();

function getPlatformInfo() {
  const isWindows = platform === 'win32';
  const isMac = platform === 'darwin';
  const isArm = arch === 'arm64';

  let nodePlatform, nodeArch, ext;

  if (isWindows) {
    nodePlatform = 'win';
    nodeArch = isArm ? 'arm64' : 'x64';
    ext = 'zip';
  } else if (isMac) {
    nodePlatform = 'darwin';
    nodeArch = isArm ? 'arm64' : 'x64';
    ext = 'tar.gz';
  } else {
    nodePlatform = 'linux';
    nodeArch = isArm ? 'arm64' : 'x64';
    ext = 'tar.gz';
  }

  return { nodePlatform, nodeArch, ext, isWindows, isMac };
}

function getDownloadUrl() {
  const { nodePlatform, nodeArch, ext } = getPlatformInfo();
  const filename = `node-v${NODE_VERSION}-${nodePlatform}-${nodeArch}.${ext}`;
  return {
    url: `https://nodejs.org/dist/v${NODE_VERSION}/${filename}`,
    filename
  };
}

function download(url, dest) {
  return new Promise((resolve, reject) => {
    console.log(`下载: ${url}`);
    const file = fs.createWriteStream(dest);

    const request = https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // 处理重定向
        download(response.headers.location, dest).then(resolve).catch(reject);
        return;
      }

      const total = parseInt(response.headers['content-length'], 10);
      let downloaded = 0;

      response.on('data', (chunk) => {
        downloaded += chunk.length;
        const percent = ((downloaded / total) * 100).toFixed(1);
        process.stdout.write(`\r下载进度: ${percent}%`);
      });

      response.pipe(file);

      file.on('finish', () => {
        file.close();
        console.log('\n下载完成!');
        resolve(dest);
      });
    });

    request.on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

async function extractTarGz(src, dest) {
  console.log(`解压: ${src} -> ${dest}`);

  try {
    // 使用系统 tar 命令解压，--strip-components=1 去掉顶层目录
    execSync(`tar -xzf "${src}" -C "${dest}" --strip-components=1`, {
      stdio: 'inherit'
    });
  } catch (error) {
    throw new Error(`解压失败: ${error.message}`);
  }
}

async function extractZip(src, dest) {
  console.log(`解压: ${src} -> ${dest}`);

  // Windows: 使用 PowerShell 解压
  try {
    execSync(`powershell -command "Expand-Archive -Path '${src}' -DestinationPath '${dest}' -Force"`, {
      stdio: 'inherit'
    });

    // 移动内容到 node 目录
    const extracted = fs.readdirSync(dest).find(f => f.startsWith('node-'));
    if (extracted) {
      const extractedPath = path.join(dest, extracted);
      const files = fs.readdirSync(extractedPath);
      for (const file of files) {
        fs.renameSync(
          path.join(extractedPath, file),
          path.join(dest, file)
        );
      }
      fs.rmdirSync(extractedPath);
    }
  } catch (error) {
    throw new Error(`解压失败: ${error.message}`);
  }
}

async function installClaudeCode(nodePath) {
  console.log('\n安装 @anthropic-ai/claude-code 到便携目录...');

  const { isWindows } = getPlatformInfo();
  const npmCmd = isWindows
    ? path.join(nodePath, 'npm.cmd')
    : path.join(nodePath, 'bin', 'npm');

  // 设置 npm 前缀为便携目录，这样包会安装到 node/lib/node_modules
  const npmPrefix = isWindows ? nodePath : nodePath;

  return new Promise((resolve, reject) => {
    const child = spawn(npmCmd, [
      'install',
      '-g',
      '--prefix', npmPrefix,
      '@anthropic-ai/claude-code'
    ], {
      cwd: ROOT_DIR,
      stdio: 'inherit',
      env: {
        ...process.env,
        PATH: isWindows
          ? `${nodePath};${process.env.PATH}`
          : `${path.join(nodePath, 'bin')}:${process.env.PATH}`,
        // 防止使用系统全局目录
        npm_config_prefix: npmPrefix
      }
    });

    child.on('error', reject);
    child.on('exit', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`npm install 失败，退出码: ${code}`));
      }
    });
  });
}

async function main() {
  console.log('='.repeat(50));
  console.log('Claude Code Portable 安装器');
  console.log('='.repeat(50));
  console.log(`平台: ${platform}`);
  console.log(`架构: ${arch}`);
  console.log(`Node.js 版本: ${NODE_VERSION}`);
  console.log('='.repeat(50));

  const nodeDir = path.join(ROOT_DIR, 'node');
  const { isWindows, ext } = getPlatformInfo();

  // 检查是否已安装
  const nodeExe = isWindows
    ? path.join(nodeDir, 'node.exe')
    : path.join(nodeDir, 'bin', 'node');

  if (fs.existsSync(nodeExe)) {
    console.log('\nNode.js 已安装，跳过下载');
  } else {
    // 创建 node 目录
    if (!fs.existsSync(nodeDir)) {
      fs.mkdirSync(nodeDir, { recursive: true });
    }

    // 下载 Node.js
    const { url, filename } = getDownloadUrl();
    const downloadPath = path.join(ROOT_DIR, filename);

    try {
      await download(url, downloadPath);

      // 解压
      if (ext === 'tar.gz') {
        await extractTarGz(downloadPath, nodeDir);
      } else {
        await extractZip(downloadPath, nodeDir);
      }

      // 清理下载文件
      fs.unlinkSync(downloadPath);
      console.log('Node.js 安装完成!');
    } catch (error) {
      console.error('安装失败:', error.message);
      process.exit(1);
    }
  }

  // 安装 Claude Code
  try {
    await installClaudeCode(nodeDir);
    console.log('\n' + '='.repeat(50));
    console.log('安装完成!');
    console.log('='.repeat(50));
    console.log('\n使用方法:');
    if (isWindows) {
      console.log('  双击 start.cmd 启动');
    } else {
      console.log('  运行 ./start.sh 启动');
    }
    console.log('\n请先编辑 config.json 配置你的 API Key');
  } catch (error) {
    console.error('Claude Code 安装失败:', error.message);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error('安装失败:', error.message);
  process.exit(1);
});
