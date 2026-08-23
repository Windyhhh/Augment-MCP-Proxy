require('dotenv').config();
const axios = require('axios');
const http = require('http');

// 第三方 API 配置
const THIRD_PARTY_API = process.env.THIRD_PARTY_API || 'https://aiapi.ihep.ac.cn/apiv2/anthropic';
const API_KEY = process.env.API_KEY || '';
const MCP_PORT = process.env.MCP_PORT || 3000;

if (!API_KEY) {
  console.error('错误：未设置 API_KEY 环境变量');
  process.exit(1);
}

// 支持的模型列表
const SUPPORTED_MODELS = [
  { id: 'claude-3-haiku-20240229', name: 'Claude 3 Haiku' },
  { id: 'claude-3-sonnet-20240229', name: 'Claude 3 Sonnet' },
  { id: 'claude-3-opus-20240229', name: 'Claude 3 Opus' }
];

// 创建 HTTP 服务器
const server = http.createServer(async (req, res) => {
  // 设置 CORS 头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Content-Type', 'application/json');

  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // 路由：获取模型列表
  if (req.url === '/v1/models' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({
      object: 'list',
      data: SUPPORTED_MODELS.map(model => ({
        id: model.id,
        object: 'model',
        created: Math.floor(Date.now() / 1000),
        owned_by: 'anthropic'
      }))
    }));
    return;
  }

  // 路由：处理消息请求
  if (req.url === '/v1/messages' && req.method === 'POST') {
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', async () => {
      try {
        const params = JSON.parse(body);
        
        console.log(`[${new Date().toISOString()}] 处理请求：模型=${params.model}, 消息数=${params.messages?.length || 0}`);

        // 转发到第三方 API
        const response = await axios.post(
          `${THIRD_PARTY_API}/v1/messages`,
          {
            model: params.model,
            max_tokens: params.max_tokens || 4096,
            messages: params.messages,
            temperature: params.temperature || 0.7,
            system: params.system
          },
          {
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${API_KEY}`,
              'X-API-Key': API_KEY
            },
            timeout: 30000
          }
        );

        console.log(`[${new Date().toISOString()}] API 响应成功`);
        res.writeHead(200);
        res.end(JSON.stringify(response.data));
      } catch (error) {
        console.error(`[${new Date().toISOString()}] API 调用失败：`, error.response?.data || error.message);
        res.writeHead(error.response?.status || 500);
        res.end(JSON.stringify({
          error: {
            type: 'api_error',
            message: error.response?.data?.error?.message || error.message
          }
        }));
      }
    });
    return;
  }

  // 路由：健康检查
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200);
    res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));
    return;
  }

  // 404
  res.writeHead(404);
  res.end(JSON.stringify({ error: 'Not Found' }));
});

server.listen(MCP_PORT, () => {
  console.log(`\n========================================`);
  console.log(`MCP 代理服务器启动成功！`);
  console.log(`========================================`);
  console.log(`服务器地址：http://localhost:${MCP_PORT}`);
  console.log(`第三方 API：${THIRD_PARTY_API}`);
  console.log(`支持的模型：`);
  SUPPORTED_MODELS.forEach(m => console.log(`  - ${m.id} (${m.name})`));
  console.log(`========================================\n`);
});

server.on('error', (err) => {
  console.error(`服务器错误：${err.message}`);
  if (err.code === 'EADDRINUSE') {
    console.error(`端口 ${MCP_PORT} 已被占用，请修改 .env 中的 MCP_PORT`);
  }
  process.exit(1);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('\n收到关闭信号，正在优雅关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('\n收到中断信号，正在优雅关闭服务器...');
  server.close(() => {
    console.log('服务器已关闭');
    process.exit(0);
  });
});
