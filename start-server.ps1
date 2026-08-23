# MCP 代理服务器启动脚本
# 用途：快速启动 MCP 代理服务器

param(
    [string]$Action = "start",
    [int]$Port = 3000
)

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$NodePath = "node"

function Start-MCPServer {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "启动 MCP 代理服务器..." -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    # 检查 .env 文件
    if (-not (Test-Path "$ProjectRoot\.env")) {
        Write-Host "错误：.env 文件不存在！" -ForegroundColor Red
        Write-Host "请确保 .env 文件存在并包含 API_KEY" -ForegroundColor Yellow
        exit 1
    }
    
    # 检查 node_modules
    if (-not (Test-Path "$ProjectRoot\node_modules")) {
        Write-Host "安装依赖..." -ForegroundColor Yellow
        cd $ProjectRoot
        npm install
    }
    
    Write-Host "服务器启动中..." -ForegroundColor Green
    Write-Host "监听地址：http://localhost:$Port" -ForegroundColor Cyan
    Write-Host "按 Ctrl+C 停止服务器" -ForegroundColor Yellow
    Write-Host ""
    
    cd $ProjectRoot
    & $NodePath index.js
}

function Stop-MCPServer {
    Write-Host "停止 MCP 服务器..." -ForegroundColor Yellow
    Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "服务器已停止" -ForegroundColor Green
}

function Restart-MCPServer {
    Write-Host "重启 MCP 服务器..." -ForegroundColor Yellow
    Stop-MCPServer
    Start-Sleep -Seconds 2
    Start-MCPServer
}

function Test-MCPServer {
    Write-Host "测试 MCP 服务器..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$Port/health" -ErrorAction Stop
        Write-Host "✓ 服务器健康检查：成功" -ForegroundColor Green
        Write-Host "  响应：$($response.Content)" -ForegroundColor Green
        
        $models = Invoke-WebRequest -Uri "http://localhost:$Port/v1/models" -ErrorAction Stop
        Write-Host "✓ 模型列表获取：成功" -ForegroundColor Green
        Write-Host "  支持的模型：" -ForegroundColor Green
        $models.Content | ConvertFrom-Json | Select-Object -ExpandProperty data | ForEach-Object {
            Write-Host "    - $($_.id)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "✗ 服务器连接失败" -ForegroundColor Red
        Write-Host "  错误：$($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 执行操作
switch ($Action.ToLower()) {
    "start" { Start-MCPServer }
    "stop" { Stop-MCPServer }
    "restart" { Restart-MCPServer }
    "test" { Test-MCPServer }
    default {
        Write-Host "用法：.\start-server.ps1 [start|stop|restart|test]" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "示例：" -ForegroundColor Cyan
        Write-Host "  .\start-server.ps1 start    # 启动服务器" -ForegroundColor Gray
        Write-Host "  .\start-server.ps1 stop     # 停止服务器" -ForegroundColor Gray
        Write-Host "  .\start-server.ps1 restart  # 重启服务器" -ForegroundColor Gray
        Write-Host "  .\start-server.ps1 test     # 测试服务器" -ForegroundColor Gray
    }
}

