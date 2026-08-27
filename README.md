<div align="center">

# 🔧 Augment-MCP-Proxy

### Use a third-party Anthropic API inside Augment.

A local, private Node.js proxy that lets you reuse a third-party Anthropic API in Augment — save credits, keep data local.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node](https://img.shields.io/badge/Node.js-18+-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![PowerShell](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)

</div>

---

**Augment-MCP-Proxy** is a tiny local proxy that forwards Anthropic-API-style requests to a third-party provider, so you can use it inside Augment without burning official credits. It runs locally and privately — your data never leaves your machine.

> [!NOTE]
> 中文项目：在 Augment 中复用第三方 Anthropic API 的本地代理，节省额度、本地私有。

---

## Quickstart

```bash
git clone https://github.com/Windyhhh/Augment-MCP-Proxy.git
cd Augment-MCP-Proxy

# 1. Configure
cp .env.example .env   # set your third-party API key / endpoint

# 2. Start the proxy
./start-server.ps1

# 3. Verify
./test-api.ps1
```

Then point Augment's MCP config at `mcp-servers.json`. See `AUGMENT_CONFIG_GUIDE.md` for the full setup.

---

## Features

- **Local & private** — requests are proxied from your own machine.
- **Credit-friendly** — reuse a third-party Anthropic API instead of official quota.
- **Zero-config in Augment** — drop in the bundled `mcp-servers.json`.

---

## Project Structure

```
Augment-MCP-Proxy/
├── index.js               # proxy entry
├── mcp-servers.json       # Augment MCP server config
├── start-server.ps1       # start script
├── test-api.ps1           # smoke test
├── AUGMENT_CONFIG_GUIDE.md
└── .env.example
```

---

## License

MIT — free to use, modify and distribute.
