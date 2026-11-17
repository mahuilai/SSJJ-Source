#Requires -Version 5.1
<#
.SYNOPSIS
    SSJJ 局内客户端 · 一键迭代回路
.DESCRIPTION
    把「改代码 → 构建 → 加密回注 → 启动 → 截图取证」压成一条命令，
    替换原先的人工多步操作，并留下每轮的耗时与产物，便于回归对比。

    实测基线（本机 2026-10-31）:
      全量重编译 9.3s + 加密回注 0.9s ≈ 11s（流水线本身并不慢，
      真正的成本在人肉验证环节，本脚本消除的正是后者）
.PARAMETER Mode
    battle = 构建并拉起 3D 战斗客户端；lobby = 只拉起 AIR 大厅；none = 只构建部署。
.PARAMETER SkipBuild
    跳过构建（只做加密回注 + 启动）。
.PARAMETER SkipDeploy
    跳过加密回注（只构建，不碰游戏目录）。
.PARAMETER NoCapture
    启动后不自动截图。
.PARAMETER WaitSeconds
    启动后等待多久再截图（默认 25s，进入战斗需更久）。
.EXAMPLE
    pwsh -File tools\iterate.ps1 -Mode none                 # 只验证能编过+回注
    pwsh -File tools\iterate.ps1 -Mode battle -WaitSeconds 40
#>
[CmdletBinding()]
param(
    [ValidateSet('battle','lobby','none')]
    [string]$Mode = 'none',
    [switch]$SkipBuild,
    [switch]$SkipDeploy,
    [switch]$NoCapture,
    [int]$WaitSeconds = 25
)

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$Managed   = 'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'
$Csproj    = 'Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild\Assembly-CSharp.csproj'
$OutDll    = 'Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild\bin\Debug\net48\Assembly-CSharp.dll'
$Deployer  = 'Game-SSJJ\tools\inject_rebuild.py'
$Stamp     = Get-Date -Format 'yyyyMMdd-HHmmss'
$ArtDir    = "Game-SSJJ-logs\iter\$Stamp"
New-Item -ItemType Directory -Force -Path $ArtDir | Out-Null

$script:Fail = $false
$script:T = [ordered]@{}

function Step {
    param([string]$Name, [scriptblock]$Body)
    Write-Host "`n>>> $Name" -ForegroundColor Cyan
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $ok = $true
    try { & $Body } catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        $ok = $false
    }
    $sw.Stop()
    $script:T[$Name] = [math]::Round($sw.Elapsed.TotalSeconds, 2)
    if (-not $ok) { $script:Fail = $true }
    Write-Host ("  [耗时 {0}s]" -f $script:T[$Name]) -ForegroundColor DarkGray
    return $ok
}

Write-Host "SSJJ 迭代回路 · mode=$Mode · artifacts=$ArtDir" -ForegroundColor White

# ---------- 0. 前置检查 ----------
Step '前置检查' {
    $miss = @()
    if (-not (Test-Path -LiteralPath "$Managed\Assembly-CSharp.dll.orig.bak")) { $miss += 'Assembly-CSharp.dll.orig.bak' }
    if (-not (Test-Path -LiteralPath 'Game source\01_metadata\recovered\Assembly-CSharp.decrypted.dll')) { $miss += 'Assembly-CSharp.decrypted.dll' }
    if (-not (Test-Path -LiteralPath $Csproj)) { $miss += $Csproj }
    if (-not (Test-Path -LiteralPath $Deployer)) { $miss += $Deployer }
    if ($miss.Count -gt 0) {
        Write-Host ("  缺失: " + ($miss -join ', ')) -ForegroundColor Red
        $script:Fail = $true
        throw '前置条件不满足'
    }
    Write-Host '  原版基准/解密版/工程/回注器 均在位'
} | Out-Null

if ($script:Fail) { Write-Host "`n前置检查失败，中止。" -ForegroundColor Red; exit 1 }

# ---------- 1. 构建 ----------
if ($SkipBuild) {
    Write-Host "`n>>> 构建 [SKIP]（-SkipBuild）" -ForegroundColor DarkYellow
    $script:T['构建'] = 0
} else {
    $buildOk = Step '构建' {
        $log = Join-Path $ArtDir 'build.log'
        dotnet build $Csproj -v m --nologo *>&1 | Tee-Object -FilePath $log | Out-Null
        $errs = Select-String -Path $log -Pattern 'error (CS|MSB|NETSDK)\d+' -ErrorAction SilentlyContinue
        if ($errs) {
            Write-Host "  编译错误 $($errs.Count) 条，前 8 条:" -ForegroundColor Red
            $errs | Select-Object -First 8 | ForEach-Object { Write-Host ("    " + $_.Line.Trim()) -ForegroundColor Red }
            throw "构建失败"
        }
        if (-not (Test-Path -LiteralPath $OutDll)) { throw "产物不存在: $OutDll" }
        $mb = [math]::Round((Get-Item -LiteralPath $OutDll).Length / 1MB, 2)
        Write-Host "  构建成功，产物 $mb MB"
        # 把产物存档，便于二分回滚
        Copy-Item -LiteralPath $OutDll -Destination (Join-Path $ArtDir 'Assembly-CSharp.plain.dll') -Force
    }
    if (-not $buildOk) { Write-Host "`n构建失败，中止（未触碰游戏目录）。" -ForegroundColor Red; exit 1 }
}

# ---------- 2. 加密回注 ----------
if ($SkipDeploy) {
    Write-Host "`n>>> 加密回注 [SKIP]（-SkipDeploy）" -ForegroundColor DarkYellow
    $script:T['加密回注'] = 0
} else {
    Step '加密回注' {
        # 回注前快照当前线上密文，供本轮内回滚
        $cur = Join-Path $Managed 'Assembly-CSharp.dll'
        if (Test-Path -LiteralPath $cur) {
            Copy-Item -LiteralPath $cur -Destination (Join-Path $ArtDir 'deployed.before.dll') -Force
        }
        $log = Join-Path $ArtDir 'deploy.log'
        python $Deployer *>&1 | Tee-Object -FilePath $log | Out-Null
        $txt = Get-Content $log -Raw
        if ($txt -match 'ABORT') { throw '回注器自校验失败（算法不匹配），已中止' }
        if ($txt -notmatch 'sanity encrypt\(recovered\)==original: True') {
            Write-Host '  [WARN] 未看到算法自校验 True，请检查 deploy.log' -ForegroundColor Yellow
        }
        Write-Host '  回注完成'
    } | Out-Null
    if ($script:Fail) { Write-Host "`n回注失败，中止。" -ForegroundColor Red; exit 1 }
}

# ---------- 3. 启动 ----------
$launched = $false
if ($Mode -eq 'none') {
    Write-Host "`n>>> 启动 [SKIP]（mode=none）" -ForegroundColor DarkYellow
    $script:T['启动'] = 0
} else {
    Step '启动' {
        $procs = if ($Mode -eq 'battle') { @('SSJJ_BattleClient_Unity') } else { @('AirLobbyPreloader','Adl','adl','MicroClient') }
        foreach ($p in $procs) {
            Get-Process -Name $p -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Milliseconds 800
        if ($Mode -eq 'battle') {
            if (-not (Test-Path '_work\launch_battle_client.py')) { throw '缺少 _work\launch_battle_client.py' }
            Start-Process -FilePath 'python' -ArgumentList '_work\launch_battle_client.py' -WindowStyle Minimized
        } else {
            if (-not (Test-Path '_work\launch_lobby.py')) { throw '缺少 _work\launch_lobby.py' }
            Start-Process -FilePath 'python' -ArgumentList '_work\launch_lobby.py' -WindowStyle Minimized
        }
        Write-Host "  已发起启动（$Mode）"
        $script:Launched = $true
    } | Out-Null
    $launched = $true
}

# ---------- 4. 取证截图 ----------
if ($launched -and -not $NoCapture) {
    Step '取证截图' {
        Write-Host "  等待 ${WaitSeconds}s 让客户端完成加载..."
        Start-Sleep -Seconds $WaitSeconds
        $shot = if ($Mode -eq 'battle') { 'Game-SSJJ\tools\shot_now.py' } else { 'Game-SSJJ\tools\shot_air.py' }
        if (-not (Test-Path $shot)) { Write-Host "  [SKIP] 截图脚本不存在: $shot" -ForegroundColor DarkYellow; return }
        $out = Join-Path $ArtDir 'capture.png'
        python $shot $out 2>&1 | ForEach-Object { Write-Host "    $_" }
        if (Test-Path -LiteralPath $out) {
            $kb = [int]((Get-Item -LiteralPath $out).Length / 1KB)
            Write-Host "  截图已保存 ($kb KB)"
            if ($kb -lt 20) { Write-Host '  [WARN] 截图异常小，可能是黑屏/未就绪' -ForegroundColor Yellow }
        } else {
            Write-Host '  [WARN] 未生成截图' -ForegroundColor Yellow
        }
    } | Out-Null
} else {
    Write-Host "`n>>> 取证截图 [SKIP]" -ForegroundColor DarkYellow
}

# ---------- 汇总 ----------
Write-Host "`n--- 本轮耗时 ---" -ForegroundColor White
$total = 0
foreach ($k in $script:T.Keys) {
    Write-Host ("  {0,-12} {1,6}s" -f $k, $script:T[$k])
    $total += $script:T[$k]
}
Write-Host ("  {0,-12} {1,6}s" -f '合计', [math]::Round($total, 2)) -ForegroundColor White
Write-Host "`n产物目录: $ArtDir"
Write-Host "回滚: pwsh -File tools\rollback.ps1 -Apply"

if ($script:Fail) { Write-Host "`n[FAIL] 迭代回路有失败环节。" -ForegroundColor Red; exit 1 }
Write-Host "`n[OK] 迭代回路完成。" -ForegroundColor Green
exit 0
