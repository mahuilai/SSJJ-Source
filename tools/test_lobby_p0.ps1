#Requires -Version 5.1
<#
.SYNOPSIS
    M2 P0 回归测试 · 大厅 Java 服务端连接层
.DESCRIPTION
    不依赖 AIR 客户端，直接以裸 TCP 验证已修的 P0：
      T1 端口只绑回环（原为 0.0.0.0）
      T2 超大帧被拒绝且服务端不 OOM/不退（原可被单包打崩）
      T3 空闲连接被超时回收（原无 SoTimeout，半开连接永久占线程）
      T4 连接数上限生效（原无限 new Thread）
    实现说明：服务端输出用文件重定向而非管道，避免子进程持有父进程管道句柄导致挂起。
    退出码 0 = 全通过。
.PARAMETER Port
    测试用端口（默认 2199，避开正式 2000）。
.EXAMPLE
    pwsh -File tools\test_lobby_p0.ps1
#>
[CmdletBinding()]
param([int]$Port = 2199)

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$JavaDir = Join-Path $Root '_work\lobby_host\java'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$LogDir = Join-Path $Root "Game-SSJJ-logs\p0test\$Stamp"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$SrvLog = Join-Path $LogDir 'server.log'
$SrvErr = Join-Path $LogDir 'server.err.log'

$script:Fail = 0
function Check {
    param([string]$Id, [string]$Name, [bool]$Ok, [string]$Detail='')
    $tag = if ($Ok) { 'PASS' } else { 'FAIL' }
    $color = if ($Ok) { 'Green' } else { 'Red' }
    Write-Host ("  [{0}] {1,-4} {2}  {3}" -f $tag, $Id, $Name, $Detail) -ForegroundColor $color
    if (-not $Ok) { $script:Fail++ }
}
function Get-SrvLog { if (Test-Path $SrvLog) { return (Get-Content $SrvLog -Raw -ErrorAction SilentlyContinue) } else { return '' } }

Write-Host "M2 P0 回归测试 · port=$Port · log=$LogDir" -ForegroundColor White

# ---------- 启动被测服务端（文件重定向，杜绝管道挂起） ----------
Write-Host "`n>>> 启动 LobbyLoginServer (maxFrame=4096, idleTimeout=2000, maxConn=3)"
$proc = $null
try {
    $args = @(
        '-Dssjj.maxFrame=4096', '-Dssjj.idleTimeoutMs=2000', '-Dssjj.maxConn=3',
        '-Dfile.encoding=UTF-8', '-cp', '.', 'LobbyLoginServer', "$Port"
    )
    $proc = Start-Process -FilePath 'java' -ArgumentList $args -WorkingDirectory $JavaDir `
        -RedirectStandardOutput $SrvLog -RedirectStandardError $SrvErr `
        -NoNewWindow -PassThru

    $ready = $false
    for ($i = 0; $i -lt 120; $i++) {
        Start-Sleep -Milliseconds 250
        if ((Get-SrvLog) -match 'listening') { $ready = $true; break }
        if ($proc.HasExited) { break }
    }
    Check 'T0' '服务端启动并进入监听' $ready ("pid=" + $proc.Id)
    if (-not $ready) {
        Write-Host "  --- server.log ---" -ForegroundColor DarkGray
        Get-Content $SrvLog -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        Write-Host "  --- server.err.log ---" -ForegroundColor DarkGray
        Get-Content $SrvErr -ErrorAction SilentlyContinue | Select-Object -First 15 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        return
    }

    # ---------- T1 绑定地址 ----------
    Write-Host "`n>>> T1 绑定地址"
    $line = ''
    for ($i = 0; $i -lt 10; $i++) {
        $m = netstat -ano | Select-String ":$Port\s" | Select-Object -First 1
        if ($m) { $line = $m.Line.Trim(); if ($line -match 'LISTENING') { break } }
        Start-Sleep -Milliseconds 200
    }
    Check 'T1a' '端口处于 LISTENING' ($line -match 'LISTENING') $line
    # 只看「本地地址」列；监听态的远端地址列本来就是 0.0.0.0:0，不参与判定
    $parts = @($line -split '\s+' | Where-Object { $_ -ne '' })
    $local = if ($parts.Count -ge 2) { $parts[1] } else { '' }
    Check 'T1b' '仅绑回环（本地地址为 127.0.0.1）' ($local -match '^127\.0\.0\.1:') "local=$local"

    # ---------- T2 超大帧 ----------
    Write-Host "`n>>> T2 超大帧 (len=0x0FFFFFFF ≈256MB)"
    try {
        $c = New-Object Net.Sockets.TcpClient
        $c.Connect('127.0.0.1', $Port)
        $ns = $c.GetStream()
        $b = [BitConverter]::GetBytes([int]0x0FFFFFFF)
        [Array]::Reverse($b)
        $ns.Write($b, 0, 4); $ns.Flush()
        Start-Sleep -Milliseconds 700
        $c.Close()
    } catch {
        Write-Host "  (客户端侧断开，属预期: $($_.Exception.Message))" -ForegroundColor DarkGray
    }
    Start-Sleep -Milliseconds 500
    Check 'T2a' '拒绝超大帧并记录' ((Get-SrvLog) -match 'frame too large') ''
    Check 'T2b' '服务端仍存活（未 OOM/未退出）' (-not $proc.HasExited) ''

    # ---------- T3 空闲超时 ----------
    Write-Host "`n>>> T3 空闲超时 (阈值 2000ms)"
    $idle = New-Object Net.Sockets.TcpClient
    $idle.Connect('127.0.0.1', $Port)
    Start-Sleep -Milliseconds 3200
    Check 'T3a' '空闲连接被回收' ((Get-SrvLog) -match 'idle timeout|\[conn\] TIMEOUT') ''
    Check 'T3b' '服务端仍存活' (-not $proc.HasExited) ''
    try { $idle.Close() } catch {}

    # ---------- T4 连接数上限 ----------
    Write-Host "`n>>> T4 连接数上限 (maxConn=3)"
    $conns = @()
    for ($i = 0; $i -lt 5; $i++) {
        try {
            $cc = New-Object Net.Sockets.TcpClient
            $cc.Connect('127.0.0.1', $Port)
            $conns += $cc
            Start-Sleep -Milliseconds 200
        } catch { }
    }
    Start-Sleep -Milliseconds 900
    Check 'T4a' '超限连接被拒绝并记录' ((Get-SrvLog) -match 'connection limit') ''
    Check 'T4b' '服务端仍存活' (-not $proc.HasExited) ''
    foreach ($c in $conns) { try { $c.Close() } catch {} }

    # ---------- T5 OOM 痕迹 ----------
    $all = (Get-SrvLog) + (Get-Content $SrvErr -Raw -ErrorAction SilentlyContinue)
    Check 'T5' '全程无 OutOfMemoryError' (-not ($all -match 'OutOfMemoryError')) ''

} finally {
    Write-Host "`n>>> 关闭被测服务端"
    if ($proc -and -not $proc.HasExited) {
        try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}
    }
    # 兜底：清掉任何占用测试端口的残留 java
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*LobbyLoginServer $Port*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

Write-Host "`n--- 结果 ---"
if ($script:Fail -gt 0) {
    Write-Host ("FAIL 项: " + $script:Fail) -ForegroundColor Red
    Write-Host "服务端日志: $SrvLog"
    exit 1
}
Write-Host '全部 P0 回归项通过。' -ForegroundColor Green
exit 0
