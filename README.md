# 🔌 Augment MCP 代理服务器 | Augment MCP Proxy

> **Use Third-Party Anthropic API in Augment — Save Your Credits**
>
> 一个轻量级 MCP 代理服务器，将 Augment（Anthropic 官方 VS Code 插件）连接到第三方 Anthropic API，从而**不消耗 Augment 积分**，只消耗第三方 API 配额。完全本地运行，代码分析在本地完成，隐私安全。
>
> A lightweight MCP proxy server that connects Augment (Anthropic's official VS Code extension) to third-party Anthropic APIs, **saving Augment credits**. Runs fully locally with code analysis done on your machine for privacy.

---

## ✨ 核心亮点

| 特性 | 说明 |
|------|------|
| 💰 **省钱** | 不消耗 Augment 积分，只用第三方 API 配额 |
| 🔄 **无缝集成** | Augment 使用体验完全不变，支持所有功能 |
| 🔒 **本地运行** | 代码分析在本地完成，不上传源码，隐私安全 |
| 🤖 **多模型支持** | Haiku / Sonnet / Opus 三个模型自由切换 |
| ⚡ **轻量级** | 仅 2 个依赖（axios + dotenv），启动秒级 |
| 🪟 **跨平台** | Windows / macOS / Linux 均可运行 |

---

## 🏗️ 工作原理

```
┌──────────────┐     HTTP      ┌──────────────────┐     HTTPS      ┌──────────────────┐
│   Augment    │ ────────────→ │  MCP Proxy       │ ─────────────→ │  Third-Party     │
│   (VS Code)  │ ←──────────── │  (localhost:3000)│ ←───────────── │  Anthropic API   │
└──────────────┘    响应       └──────────────────┘    响应         └──────────────────┘
                                    │
                                    ├─ /v1/models    → 模型列表
                                    ├─ /v1/messages  → 消息转发
                                    └─ /health        → 健康检查
```

Augment 插件通过 MCP 协议连接到本地代理服务器，代理将请求转发到第三方 Anthropic API，再将响应返回给 Augment。整个过程对 Augment 完全透明。

---

## 🚀 快速开始

### 环境要求

```bash
Node.js >= 14.0
npm >= 6.0
```

### 安装步骤

```bash
# 1. 克隆项目
git clone https://github.com/Windyhhh/Augment-MCP-Proxy.git
cd Augment-MCP-Proxy

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env，填入你的第三方 API Key
```

### 配置 `.env`

```env
# 第三方 API 地址（兼容 Anthropic 格式的 API）
THIRD_PARTY_API=https://your-api-endpoint.com/anthropic

# 你的 API Key
API_KEY=sk-your-api-key-here

# MCP 服务器端口（默认 3000）
MCP_PORT=3000
```

### 启动服务器

```bash
# 方式一：npm
npm start

# 方式二：直接运行
node index.js

# 方式三（Windows）：PowerShell 脚本
.\start-server.ps1 start
```

启动成功后会看到：

```
========================================
MCP 代理服务器启动成功！
========================================
服务器地址：http://localhost:3000
第三方 API：https://your-api-endpoint.com/anthropic
支持的模型：
  - claude-3-haiku-20240229 (Claude 3 Haiku)
  - claude-3-sonnet-20240229 (Claude 3 Sonnet)
  - claude-3-opus-20240229 (Claude 3 Opus)
========================================
```

---

## ⚙️ 配置 Augment

### 1. 找到 MCP 配置文件

Windows:
```
%APPDATA%\Code\User\globalStorage\anthropic.augment\mcp-servers.json
```

macOS:
```
~/Library/Application Support/Code/User/globalStorage/anthropic.augment/mcp-servers.json
```

Linux:
```
~/.config/Code/User/globalStorage/anthropic.augment/mcp-servers.json
```

### 2. 写入配置

将 `mcp-servers.json` 的内容复制到上述文件：

```json
{
  "mcpServers": {
    "augment-proxy": {
      "command": "node",
      "args": ["path/to/index.js"],
      "env": {
        "MCP_PORT": "3000"
      }
    }
  }
}
```

### 3. 重启 VS Code

完全关闭 VS Code 后重新打开，等待 5-10 秒让 MCP 服务器加载。

### 4. 开始使用

在 Augment 聊天中输入：

```
use claude-3-haiku-20240229, 你好！请给我一个 Python Hello World 示例
```

---

## 🧪 测试验证

### 健康检查

```bash
curl http://localhost:3000/health
```

预期输出：
```json
{"status":"ok","timestamp":"2025-01-01T00:00:00.000Z"}
```

### 获取模型列表

```bash
curl http://localhost:3000/v1/models
```

### 运行测试脚本（Windows）

```powershell
.\test-api.ps1
```

### 确认省钱效果

使用 MCP 代理前后对比 Augment 的积分余额，应该不会减少。

---

## 📁 项目结构

```
Augment-MCP-Proxy/
├── README.md                  # 本文件
├── package.json               # 项目配置
├── package-lock.json          # 依赖锁定
├── .env.example               # 环境变量模板
├── .gitignore                 # Git 忽略规则
├── index.js                   # MCP 代理服务器主文件
├── start-server.ps1           # Windows 启动/停止/重启脚本
├── test-api.ps1               # API 测试脚本
├── mcp-servers.json           # Augment MCP 配置示例
└── AUGMENT_CONFIG_GUIDE.md    # Augment 详细配置指南
```

---

## 🔧 API 接口

### `GET /health`
健康检查端点。

**响应：**
```json
{
  "status": "ok",
  "timestamp": "2025-01-01T00:00:00.000Z"
}
```

### `GET /v1/models`
获取支持的模型列表。

**响应：**
```json
{
  "object": "list",
  "data": [
    {
      "id": "claude-3-haiku-20240229",
      "object": "model",
      "created": 1735689600,
      "owned_by": "anthropic"
    }
  ]
}
```

### `POST /v1/messages`
转发消息请求到第三方 API。

**请求体：**
```json
{
  "model": "claude-3-sonnet-20240229",
  "max_tokens": 4096,
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "temperature": 0.7
}
```

---

## 🎯 支持的模型

| 模型 | 速度 | 质量 | 成本 | 最佳用途 |
|------|------|------|------|---------|
| **Haiku** | ⚡⚡⚡ | ⭐⭐ | 最低 | 简单问题、代码补全、日常对话 |
| **Sonnet** | ⚡⚡ | ⭐⭐⭐⭐ | 中等 | 通用任务、代码审查、推荐默认 |
| **Opus** | ⚡ | ⭐⭐⭐⭐⭐ | 较高 | 复杂问题、架构设计、深度分析 |

在 Augment 中切换模型：
```
use claude-3-haiku-20240229, ...
use claude-3-sonnet-20240229, ...
use claude-3-opus-20240229, ...
```

---

## 🛠️ PowerShell 脚本用法

```powershell
# 启动服务器
.\start-server.ps1 start

# 停止服务器
.\start-server.ps1 stop

# 重启服务器
.\start-server.ps1 restart

# 测试连接
.\start-server.ps1 test
```

---

## ❓ 常见问题

### Q: 服务器无法启动？
A: 检查 `.env` 文件中的 `API_KEY` 是否正确设置，确保没有多余的空格或引号。

### Q: 端口 3000 已被占用？
A: 修改 `.env` 中的 `MCP_PORT` 为其他端口（如 3001），然后更新 Augment 的 MCP 配置。

### Q: Augment 看不到新模型？
A: 完全关闭 VS Code（不是只关闭窗口），重新打开，等待 5-10 秒让 MCP 服务器加载。

### Q: 如何确认省钱了？
A: 使用 MCP 代理前后对比 Augment 的积分余额，应该不会减少。所有请求都走第三方 API。

### Q: 支持流式输出吗？
A: 当前版本支持标准非流式响应。流式输出（SSE）支持在开发中。

### Q: 可以同时连接多个 API 吗？
A: 当前版本单实例单 API。可以启动多个实例，使用不同端口，分别配置不同的 API。

---

## ⚠️ 注意事项

1. **API Key 安全**：`.env` 文件包含敏感信息，已在 `.gitignore` 中排除，不要提交到公开仓库
2. **网络要求**：确保能访问第三方 API 地址
3. **API 兼容性**：第三方 API 必须兼容 Anthropic Messages API 格式
4. **速率限制**：受第三方 API 的速率限制约束
5. **Augment 版本**：建议使用最新版 Augment 插件

---

## 📄 许可证

MIT License — 可自由使用、修改和分发。

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📌 相关链接

- [Anthropic API 文档](https://docs.anthropic.com/)
- [Augment 官方网站](https://augmentcode.com/)
- [MCP 协议规范](https://modelcontextprotocol.io/)

---

<div align="center">

**🔌 让每一行代码都更省钱 🔌**

[报告问题](https://github.com/Windyhhh/Augment-MCP-Proxy/issues) · [提出建议](https://github.com/Windyhhh/Augment-MCP-Proxy/issues)

</div>
