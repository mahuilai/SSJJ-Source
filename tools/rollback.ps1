#Requires -Version 5.1
<#
.SYNOPSIS
    SSJJ 离线复刻工程 · 一键回滚
.DESCRIPTION
    把战斗客户端恢复到「原版未改动」状态：停进程 + 用 Assembly-CSharp.dll.orig.bak
    覆盖回 Managed 目录。默认 **dry-run**，必须显式 -Apply 才真正执行。
.PARAMETER Apply
    真正执行回滚（不加则只打印计划）。
.PARAMETER SkipProcessKill
    跳过停进程步骤（只还程序集）。
.EXAMPLE
    pwsh -File tools\rollback.ps1              # 预览
    pwsh -File tools\rollback.ps1 -Apply       # 执行
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$SkipProcessKill
)

$ErrorActionPreference = 'Continue'

$GameRoot = 'D:\SSJJ-4399\battle\3_64'
$Managed  = Join-Path $GameRoot 'SSJJ_BattleClient_Unity_Data\Managed'
$Target   = Join-Path $Managed 'Assembly-CSharp.dll'
$Backup   = Join-Path $Managed 'Assembly-CSharp.dll.orig.bak'

$Mode = if ($Apply) { 'APPLY' } else { 'DRY-RUN' }
Write-Host "=== 一键回滚 ($Mode) ===" -ForegroundColor White

# --- 前置检查 ---
if (-not (Test-Path -LiteralPath $Backup)) {
    Write-Host "[FAIL] 找不到原版备份: $Backup —— 无法回滚" -ForegroundColor Red
    exit 1
}
Write-Host ("[OK] 原版基准: {0} ({1:N2} MB)" -f $Backup, ((Get-Item -LiteralPath $Backup).Length / 1MB))

if (Test-Path -LiteralPath $Target) {
    $t = Get-Item -LiteralPath $Target
    Write-Host ("[OK] 当前部署: {0} ({1:N2} MB, {2})" -f $Target, ($t.Length / 1MB), $t.LastWriteTime)
} else {
    Write-Host "[WARN] 当前部署不存在: $Target" -ForegroundColor Yellow
}

# --- 步骤 1：停进程 ---
$procs = @('SSJJ_BattleClient_Unity', 'MicroClient', 'AirLobbyPreloader', 'AirAloneChat', 'adl', 'SSJJ-Server')
if ($SkipProcessKill) {
    Write-Host "[SKIP] 停进程（-SkipProcessKill）" -ForegroundColor DarkYellow
} else {
    foreach ($p in $procs) {
        $running = @(Get-Process -Name $p -ErrorAction SilentlyContinue)
        if ($running.Count -gt 0) {
            Write-Host ("[{0}] 停进程 {1} (PID {2})" -f ($(if($Apply){'DO'}else{'WOULD'})), $p, (($running.Id) -join ','))
            if ($Apply) { $running | Stop-Process -Force -ErrorAction SilentlyContinue }
        }
    }
    # java 只停我们大厅用的（命令行含 LobbyLoginServer）
    $jv = @(Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -like '*LobbyLoginServer*' })
    if ($jv.Count -gt 0) {
        Write-Host ("[{0}] 停大厅 Java 服 PID {1}" -f ($(if($Apply){'DO'}else{'WOULD'})), (($jv.ProcessId) -join ','))
        if ($Apply) { $jv | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } }
    }
    Write-Host "[OK] 进程检查完成"
}

# --- 步骤 2：还原程序集 ---
Write-Host ("[{0}] 复制 {1} -> {2}" -f ($(if($Apply){'DO'}else{'WOULD'})), $Backup, $Target)
if ($Apply) {
    try {
        Copy-Item -LiteralPath $Backup -Destination $Target -Force -ErrorAction Stop
        $now = Get-Item -LiteralPath $Target
        Write-Host ("[OK] 已还原: {0:N2} MB" -f ($now.Length / 1MB)) -ForegroundColor Green
    } catch {
        Write-Host "[FAIL] 还原失败: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# --- 步骤 3：提示后续 ---
Write-Host "`n--- 回滚后状态 ---"
Write-Host "客户端已回到原版。离线功能（Offline*.cs）已一并移除。"
Write-Host "若需重新部署补丁，执行 M1 的构建脚本（待实现）。"

if (-not $Apply) {
    Write-Host "`n这是 DRY-RUN。加 -Apply 才会真正执行。" -ForegroundColor Yellow
}
exit 0
