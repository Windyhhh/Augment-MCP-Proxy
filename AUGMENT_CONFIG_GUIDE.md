# Augment MCP 服务器配置指南

## 系统要求
- **Node.js**: v16+ (已验证: v22.16.0)
- **npm**: v8+ (已验证: v10.9.2)
- **Augment 插件**: VS Code / JetBrains IDE 中已安装
- **操作系统**: Windows / macOS / Linux

---

## 一、MCP 服务器信息

### 服务器地址
```
http://localhost:3000
```

### 支持的模型
- `claude-3-haiku-20240229` - Claude 3 Haiku (最快，成本最低)
- `claude-3-sonnet-20240229` - Claude 3 Sonnet (平衡)
- `claude-3-opus-20240229` - Claude 3 Opus (最强能力)

### API 端点
| 端点 | 方法 | 说明 |
|------|------|------|
| `/v1/messages` | POST | 发送聊天消息 |
| `/v1/models` | GET | 获取模型列表 |
| `/health` | GET | 健康检查 |

---

## 二、VS Code 配置（Windows）

### 1. 打开配置文件
```
%APPDATA%\Code\User\globalStorage\anthropic.augment\mcp-servers.json
```

或在 VS Code 中：
1. 按 `Ctrl+Shift+P` 打开命令面板
2. 搜索 "Augment" 并查找 MCP 配置选项

### 2. 添加 MCP 服务器配置

在 `mcp-servers.json` 中添加以下配置：

```json
{
  "servers": [
    {
      "id": "third-party-anthropic-proxy",
      "name": "第三方 Anthropic 代理",
      "url": "http://localhost:3000",
      "enabled": true,
      "env": {}
    }
  ]
}
```

### 3. 完整配置文件示例
```json
{
  "servers": [
    {
      "id": "third-party-anthropic-proxy",
      "name": "第三方 Anthropic 代理",
      "url": "http://localhost:3000",
      "enabled": true,
      "env": {},
      "roles": [
        {
          "role": "user",
          "enabled": true
        }
      ]
    }
  ]
}
```

### 4. 重启 VS Code
```powershell
# 方式1：关闭所有 VS Code 实例
Get-Process code | Stop-Process -Force

# 方式2：重新启动 VS Code
Start-Process code
```

---

## 三、JetBrains IDE 配置（PyCharm/CLion 等，Windows）

### 1. 打开配置文件
```
%APPDATA%\JetBrains\<IDE版本>\options\augment.mcp-servers.json
```

例如 PyCharm：
```
%APPDATA%\JetBrains\PyCharm2024.1\options\augment.mcp-servers.json
```

### 2. 添加相同的 MCP 服务器配置

### 3. 重启 IDE

---

## 四、测试 MCP 连接

### 1. 命令行测试

```powershell
# 测试服务器健康状态
curl http://localhost:3000/health

# 获取模型列表
curl http://localhost:3000/v1/models

# 发送测试消息
curl -X POST http://localhost:3000/v1/messages `
  -H "Content-Type: application/json" `
  -d @- <<'EOF'
{
  "model": "claude-3-haiku-20240229",
  "max_tokens": 100,
  "messages": [
    {
      "role": "user",
      "content": "请用一句话介绍你自己"
    }
  ]
}
EOF
```

### 2. 在 Augment 中测试

1. 打开 VS Code / JetBrains
2. 打开或创建代码文件
3. 在 Augment 输入框中输入：
   ```
   use claude-3-haiku-20240229，你好，请给我一个 Python 的 Hello World 示例
   ```
4. 等待响应

---

## 五、常见问题排查

### 问题1：连接被拒绝（Connection refused）

**症状**：
```
curl: (7) Failed to connect to localhost port 3000
```

**解决方案**：
```powershell
# 1. 检查 MCP 服务器是否运行
Get-Process node

# 2. 查看 MCP 服务器日志
Get-Content c:\Users\32517\Desktop\augment\augment-mcp-proxy\mcp-server.log

# 3. 重启服务器
cd c:\Users\32517\Desktop\augment\augment-mcp-proxy
node index.js
```

### 问题2：端口已被占用

**症状**：
```
Error: listen EADDRINUSE: address already in use :::3000
```

**解决方案**：
```powershell
# 1. 修改 .env 文件中的 MCP_PORT
# 编辑 .env: MCP_PORT=3001

# 2. 更新 Augment 配置文件中的 url
# 改为 "url": "http://localhost:3001"

# 3. 重启服务器
cd c:\Users\32517\Desktop\augment\augment-mcp-proxy
node index.js
```

### 问题3：API 密钥错误

**症状**：
```
错误：未设置 API_KEY 环境变量
```

**解决方案**：
```powershell
# 编辑 .env 文件
# 确保 API_KEY 正确设置
# THIRD_PARTY_API=https://aiapi.ihep.ac.cn/apiv2/anthropic
# API_KEY=sk-xxx...
```

### 问题4：模型不可用

**症状**：
```
{
  "error": {
    "type": "api_error",
    "message": "模型不存在或无法访问"
  }
}
```

**解决方案**：
1. 确保第三方 API 支持您正在使用的模型
2. 检查 API_KEY 是否有效
3. 查看服务器日志获取详细错误信息

---

## 六、维护命令

### 启动服务器
```powershell
cd c:\Users\32517\Desktop\augment\augment-mcp-proxy
node index.js
```

### 停止服务器
```powershell
Get-Process node | Stop-Process -Force
```

### 查看服务器日志
```powershell
Get-Content -Tail 50 -Wait c:\Users\32517\Desktop\augment\augment-mcp-proxy\mcp-server.log
```

### 重启服务器
```powershell
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
cd c:\Users\32517\Desktop\augment\augment-mcp-proxy
node index.js
```

---

## 七、安全建议

1. **密钥保护**
   - .env 文件包含敏感信息，不要上传到 Git
   - 定期更换 API_KEY
   - 不要在代码中硬编码密钥

2. **防火墙配置**
   - 仅在本地 (localhost) 监听
   - 生产环境中使用 HTTPS
   - 实施身份验证和授权

3. **监控和日志**
   - 定期检查服务器日志
   - 监控异常请求
   - 设置日志轮转策略

---

## 八、性能优化

### 调整超时时间
编辑 `index.js` 中的 timeout 值（单位：毫秒）：
```javascript
timeout: 30000  // 30 秒
```

### 调整最大 tokens
在 Augment 请求时指定：
```
use claude-3-opus-20240229，max_tokens=8192，请写一篇完整的技术文章
```

---

## 九、联系和支持

- **服务器运行状态**：http://localhost:3000/health
- **第三方 API**：https://aiapi.ihep.ac.cn
- **Augment 文档**：检查 VS Code/JetBrains 的 Augment 帮助文档

---

**最后更新**：2025-12-03
