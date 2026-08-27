# 🔧 Augment MCP 代理 | Augment MCP Proxy

> **在 Augment 中复用第三方 Anthropic API 的智能代理——节省 Credits，本地部署、隐私安全，无缝集成 MCP 工具。**
>
> *Smart proxy to reuse third-party Anthropic API in Augment — save credits, local & private deployment, seamless MCP tool integration.*

---

## ⭐ 核心卖点 | Why Star This

| 卖点 | Feature | 一句话 |
|------|---------|--------|
| 💰 **节省 Credits** | Save Credits | 复用第三方 Anthropic API，大幅降低使用成本 |
| 🔒 **本地私有** | Local & Private | 本地部署，数据不出本机，安全可控 |
| 🔌 **MCP 集成** | MCP Integration | 无缝接入 Model Context Protocol 工具生态 |
| ⚡ **即插即用** | Plug & Play | 配置简单，开箱即用，无需改造 Augment |
| 🔄 **兼容 API** | API Compatible | 兼容 Anthropic 官方 API 格式 |

---

## 🏆 技术栈 | Tech Stack

![Python](https://img.shields.io/badge/Python-3.9+-blue?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-teal?logo=fastapi)
![MCP](https://img.shields.io/badge/MCP-SDK-blue?logo=modelcontextprotocol)
![Anthropic](https://img.shields.io/badge/Anthropic-API-orange?logo=anthropic)
![Docker](https://img.shields.io/badge/Docker-24.0+-blue?logo=docker)

---

## 🚀 快速开始 | Quick Start

```bash
git clone https://github.com/Windyhhh/Augment-MCP-Proxy.git
cd Augment-MCP-Proxy

# 1. 配置代理
cp .env.example .env
# 编辑 .env，填入第三方 API Key 和端点

# 2. 启动代理服务
pip install -r requirements.txt
python proxy_server.py --port 8000

# 3. 在 Augment 中配置 MCP 工具
# 将代理端点配置为 Anthropic API 地址

# 4. Docker 部署 (可选)
docker-compose up -d
```

---

## 📂 项目结构 | Project Structure

```
Augment-MCP-Proxy/
├── proxy_server.py            # 代理服务入口
├── config.py                  # 配置
├── proxy/                     # 代理核心
│   ├── anthropic_client.py    # Anthropic 客户端
│   ├── api_proxy.py           # API 代理逻辑
│   ├── request_transform.py   # 请求转换
│   └── response_transform.py  # 响应转换
├── mcp/                       # MCP 集成
│   ├── mcp_server.py          # MCP 服务器
│   ├── tools/                 # MCP 工具
│   └── resources/             # 资源
├── .env.example               # 环境变量
├── docker-compose.yml
└── requirements.txt
```

---

## 🔬 核心实现 | Core Implementation

### API 代理 | API Proxy

```python
# 第三方 Anthropic API 代理
from fastapi import FastAPI, Request
import httpx
import os

app = FastAPI()
ANTHROPIC_ENDPOINT = os.getenv("THIRD_PARTY_ENDPOINT")

@app.post("/v1/messages")
async def proxy_messages(request: Request):
    """代理 Anthropic 消息接口"""
    # 1. 读取请求体
    body = await request.json()
    
    # 2. 转发到第三方 API
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{ANTHROPIC_ENDPOINT}/v1/messages",
            json=body,
            headers={
                "x-api-key": os.getenv("THIRD_PARTY_API_KEY"),
                "anthropic-version": "2023-06-01"
            },
            timeout=120.0
        )
    
    # 3. 返回响应
    return response.json()
```

---

## 🎯 应用场景 | Use Cases

- 💻 **开发者工具**：AI 编码助手低成本接入
- 🔒 **企业内网**：本地私有 AI 代理
- 💰 **成本优化**：减少官方 API 费用
- 🔌 **工具集成**：MCP 生态工具接入

---

## ⚠️ 注意 | Note

使用第三方 API 时请遵守相关服务条款与合规要求，确保数据安全。

---

## 📄 License

MIT License — 自由使用、修改和分发。

---

> 💡 **Augment 第三方 API 代理，Star ⭐ 用最低成本享受强大 AI 能力！**
