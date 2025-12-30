const fs = require('fs');
const path = require('path');

const ROOT_DIR = path.dirname(__dirname);
const CONFIG_PATH = path.join(ROOT_DIR, 'config.json');

const DEFAULT_CONFIG = {
  apiKey: '',
  baseUrl: 'https://open.bigmodel.cn/api/anthropic'
};

function loadConfig() {
  try {
    if (!fs.existsSync(CONFIG_PATH)) {
      console.error('[错误] 未找到 config.json 配置文件！');
      console.error(`请在 ${ROOT_DIR} 目录下创建 config.json`);
      process.exit(1);
    }

    const content = fs.readFileSync(CONFIG_PATH, 'utf-8');
    const config = JSON.parse(content);

    return {
      ...DEFAULT_CONFIG,
      ...config
    };
  } catch (error) {
    console.error('[错误] 读取配置文件失败:', error.message);
    process.exit(1);
  }
}

function validateConfig(config) {
  if (!config.apiKey || config.apiKey === '你的API_KEY放这里') {
    console.error('[错误] 请先配置 API Key！');
    console.error(`编辑 ${CONFIG_PATH} 文件，将 apiKey 设置为你的 API Key`);
    process.exit(1);
  }
  return true;
}

function getConfig() {
  const config = loadConfig();
  validateConfig(config);
  return config;
}

module.exports = {
  loadConfig,
  validateConfig,
  getConfig,
  ROOT_DIR,
  CONFIG_PATH
};
