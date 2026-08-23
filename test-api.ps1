# MCP 代理服务器测试脚本 (PowerShell)
# 用法: ./test-api.ps1

Write-Host "========================================" -ForegroundColor Green
Write-Host "MCP 代理服务器 - 功能测试" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$SERVER_URL = "http://localhost:3000"

# 测试 1: 健康检查
Write-Host "[测试 1] 健康检查" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SERVER_URL/health" -Method GET
    Write-Host "✓ 服务器状态: $($response.status)" -ForegroundColor Green
    Write-Host "  时间戳: $($response.timestamp)`n" -ForegroundColor Green
} catch {
    Write-Host "✗ 健康检查失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  请确保 MCP 服务器正在运行 (node index.js)`n" -ForegroundColor Red
    exit 1
}

# 测试 2: 获取模型列表
Write-Host "[测试 2] 获取模型列表" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$SERVER_URL/v1/models" -Method GET
    Write-Host "✓ 可用模型数量: $($response.data.Count)" -ForegroundColor Green
    $response.data | ForEach-Object {
        Write-Host "  - $($_.id)" -ForegroundColor Green
    }
    Write-Host ""
} catch {
    Write-Host "✗ 获取模型列表失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# 测试 3: 发送测试消息
Write-Host "[测试 3] 发送测试消息 (Claude 3 Haiku)" -ForegroundColor Yellow
try {
    $body = @{
        model = "claude-3-haiku-20240229"
        max_tokens = 100
        temperature = 0.7
        messages = @(
            @{
                role = "user"
                content = "用一句话介绍你自己"
            }
        )
    } | ConvertTo-Json

    Write-Host "  请求内容: $body`n" -ForegroundColor Gray

    $response = Invoke-RestMethod -Uri "$SERVER_URL/v1/messages" -Method POST `
        -ContentType "application/json" -Body $body

    Write-Host "✓ API 响应成功" -ForegroundColor Green
    Write-Host "  模型: $($response.model)" -ForegroundColor Green
    Write-Host "  停止原因: $($response.stop_reason)" -ForegroundColor Green
    if ($response.content[0].text) {
        Write-Host "  回复: $($response.content[0].text)`n" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ 消息发送失败: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "  错误详情: $responseBody`n" -ForegroundColor Red
    }
}

# 测试 4: 测试不同模型
Write-Host "[测试 4] 测试所有模型" -ForegroundColor Yellow
$models = @("claude-3-haiku-20240229", "claude-3-sonnet-20240229", "claude-3-opus-20240229")
foreach ($model in $models) {
    try {
        $body = @{
            model = $model
            max_tokens = 50
            messages = @(
                @{
                    role = "user"
                    content = "Hello"
                }
            )
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri "$SERVER_URL/v1/messages" -Method POST `
            -ContentType "application/json" -Body $body

        Write-Host "✓ $model - 正常" -ForegroundColor Green
    } catch {
        Write-Host "✗ $model - 失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "测试完成！" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
