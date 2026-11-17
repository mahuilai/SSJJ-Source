#Requires -Version 5.1
<#
.SYNOPSIS
    M1/M2 端到端验收 · 起服 + 官方 AIR 大厅 + 自动化三视图取证
.DESCRIPTION
    链路：gateway:8080 + Java AMF3:2000 + AirLobbyPreloader(AIR)
    断言体系：
      E1 AIR 大厅窗口出现
      E2 客户端登录成功（服务端日志见到 loginV3 / getUserDataByLogin）
      E3 大厅窗口截图已生成
      E4 大厅画面非空白（低阈值，只拦纯黑/空白）
      E5 全程无 [RPC-ERR]（异常分支）
      E6 无 [NO-REPLY]（请求已解析但未回包，客户端会永久 pending）
      E7 UNIMPL_RPC 数不超过阈值（<= 50）
      E8 大厅主界面已启动（业务核心 RPC 8 命中 >= 3）
      E9 客户端初始化链已跑到主界面构建（MVVIEW/STUFFINIT/SHOW_MAIN_VIEW/业务RPC）
      E10 主界面像素健康度（unique_colors >= 200 且 mean >= 20）
.PARAMETER SettleSeconds
    窗口出现后再等多久截图（默认 12s，等资源与首帧稳定）。
.PARAMETER TimeoutSeconds
    等待窗口出现的上限（默认 240s）。
.PARAMETER SkipLaunch
    假定链路已起，只做取证与断言。
.EXAMPLE
    pwsh -File tools\test_lobby_e2e.ps1
#>
[CmdletBinding()]
param(
    [int]$SettleSeconds = 12,
    [int]$TimeoutSeconds = 240,
    [switch]$SkipLaunch
)

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$ArtDir = "Game-SSJJ-logs\e2e\$Stamp"
New-Item -ItemType Directory -Force -Path $ArtDir | Out-Null
$SrvLog = "Game-SSJJ-logs\server.log"
$ProbeLog = "Game-SSJJ-logs\probe.log"
$ClientLog = "Game-SSJJ-logs\client_error.log"
$LauncherLog = Join-Path $ArtDir 'launcher.log'

$script:Fail = 0
$script:Results = @()
function Check {
    param([string]$Id, [string]$Name, [bool]$Ok, [string]$Detail='')
    $tag = if ($Ok) { 'PASS' } else { 'FAIL' }
    $color = if ($Ok) { 'Green' } else { 'Red' }
    Write-Host ("  [{0}] {1,-3} {2}  {3}" -f $tag, $Id, $Name, $Detail) -ForegroundColor $color
    $script:Results += [pscustomobject]@{ id = $Id; status = $tag; name = $Name; detail = $Detail }
    if (-not $Ok) { $script:Fail++ }
}

function SkipCheck {
    param([string]$Id, [string]$Name, [string]$Detail='')
    Write-Host ("  [SKIP] {0,-3} {1}  {2}" -f $Id, $Name, $Detail) -ForegroundColor Yellow
    $script:Results += [pscustomobject]@{ id = $Id; status = 'SKIP'; name = $Name; detail = $Detail }
}

Add-Type -Namespace W -Name U -MemberDefinition @'
[DllImport("user32.dll", CharSet=CharSet.Unicode)]
public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
'@

function Get-LobbyHwnd {
    $out = (python -c "import sys; sys.path.insert(0, 'tools'); import lobby_watch as lw; print(lw.find_lobby()[0])" 2>&1 | Out-String).Trim()
    try {
        $val = [int64]$out
        if ($val -gt 0) { return [IntPtr]$val }
    } catch {}
    foreach ($title in 'SSJJ_FlashAir_Battle16397', 'SSJJ_FlashAir_Battle', 'SSJJ_BattleClient') {
        $h = [W.U]::FindWindow("ApolloRuntimeContentWindow", $title)
        if ($h -ne [IntPtr]::Zero) { return $h }
    }
    $p = Get-Process -Name 'AirLobbyPreloader' -ErrorAction SilentlyContinue |
         Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
    if ($p) { return [IntPtr]$p.MainWindowHandle }
    return [IntPtr]::Zero
}

function Stop-Stack {
    foreach ($n in 'AirLobbyPreloader','AirAloneChat','Adl','adl','MicroClient') {
        Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    Get-CimInstance Win32_Process -Filter "Name='java.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*LobbyLoginServer*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like '*gateway_8080*' -or $_.CommandLine -like '*launch_lobby*' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
}

Write-Host "生死狙击离线大厅 E2E 自动化测试 · artifacts=$ArtDir" -ForegroundColor White

# 记录日志起点，只看本轮
$startLen = 0
if (Test-Path $SrvLog) { $startLen = (Get-Item $SrvLog).Length }
$startProbeLen = 0
if (Test-Path $ProbeLog) { $startProbeLen = (Get-Item $ProbeLog).Length }
$startClientLen = 0
if (Test-Path $ClientLog) { $startClientLen = (Get-Item $ClientLog).Length }

function Get-FileDelta {
    param([string]$Path, [long]$StartOffset)
    if (-not (Test-Path $Path)) { return '' }
    $fs = [System.IO.File]::Open($Path, 'Open', 'Read', 'ReadWrite')
    try {
        if ($fs.Length -le $StartOffset) { return '' }
        $null = $fs.Seek($StartOffset, 'Begin')
        $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
        return $sr.ReadToEnd()
    } finally { $fs.Dispose() }
}

function Get-NewSrvLog { Get-FileDelta $SrvLog $startLen }
function Get-NewProbeLog { Get-FileDelta $ProbeLog $startProbeLen }
function Get-NewClientLog { Get-FileDelta $ClientLog $startClientLen }

$launcher = $null
try {
    if (-not $SkipLaunch) {
        Write-Host "`n>>> 清理残留并启动链路（VERBOSE RPC）"
        Stop-Stack
        Start-Sleep -Milliseconds 800
        $env:SSJJ_RPC_VERBOSE = '1'
        $launcher = Start-Process -FilePath 'python' -ArgumentList '_work\launch_lobby.py' `
            -WorkingDirectory $Root -RedirectStandardOutput $LauncherLog `
            -RedirectStandardError (Join-Path $ArtDir 'launcher.err.log') -NoNewWindow -PassThru
        Write-Host "  launcher pid=$($launcher.Id)"

        # 看门狗：确认本轮 java 真的把日志写进了 server.log
        $sinkOk = $false
        for ($i = 0; $i -lt 30; $i++) {
            Start-Sleep -Milliseconds 1000
            if ((Get-NewSrvLog) -match '\[log\] direct file sink') { $sinkOk = $true; break }
        }
        if (-not $sinkOk) {
            throw "日志通道未建立：本轮 java 没有向 server.log 写入 '[log] direct file sink'。" +
                  "任何基于该文件的服务端断言都不可信，中止测试。"
        }
        Write-Host "  [ok] 日志通道已确认（server.log 由本轮 java 直接写入）" -ForegroundColor DarkGreen

        # 等窗口
        Write-Host "`n>>> 等待 AIR 大厅窗口（上限 ${TimeoutSeconds}s）"
        $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
        $hwnd = [IntPtr]::Zero
        $loginSeen = $false
        while ((Get-Date) -lt $deadline) {
            Start-Sleep -Seconds 2
            if ($hwnd -eq [IntPtr]::Zero) { $hwnd = Get-LobbyHwnd }
            $lg = Get-NewSrvLog
            if ($lg -match 'loginV3|getUserDataByLogin') { $loginSeen = $true }
            if ($hwnd -ne [IntPtr]::Zero -and $loginSeen) { break }
        }
        Check 'E1' 'AIR 大厅窗口出现' ($hwnd -ne [IntPtr]::Zero) ("hwnd=" + $hwnd)
        Check 'E2' '客户端登录成功（服务端见到 loginV3/getUserDataByLogin）' $loginSeen ''
    } else {
        Write-Host "`n>>> [SKIP] 启动（-SkipLaunch）"
        Check 'E1' 'AIR 大厅窗口出现' ((Get-LobbyHwnd) -ne [IntPtr]::Zero) ''
        Check 'E2' '客户端登录成功' ((Get-NewSrvLog) -match 'loginV3|getUserDataByLogin') ''
    }

    # 等待客户端首帧和初始化链
    Write-Host "`n>>> 等待 ${SettleSeconds}s 让首帧渲染稳定"
    Start-Sleep -Seconds $SettleSeconds

    $initTimeout = 60
    if ($env:SSJJ_E2E_INIT_TIMEOUT) { $initTimeout = [int]$env:SSJJ_E2E_INIT_TIMEOUT }
    Write-Host "`n>>> 等待客户端初始化链（上限 ${initTimeout}s）"
    $deadlineInit = (Get-Date).AddSeconds($initTimeout)
    $clientDelta = ''
    $hasInit = $false; $hasShow = $false; $hasMv = $false; $hasStuff = $false
    $hallHit = 0
    $hallRpcs = @('showVersionAnnounce','addClickPosition','titaniumPanelOpen','getCharacterBoxInfo',
                  'getRoomChannel','getGlobalRoomChannel','getCharMedalList','showHallAnnounce')
    while ((Get-Date) -lt $deadlineInit) {
        $clientDelta = (Get-NewProbeLog) + "`n" + (Get-NewClientLog)
        $hasInit = ($clientDelta -match 'INIT_GAMEDATA')
        $hasShow = ($clientDelta -match 'SHOW_MAIN_VIEW|MainMediator')
        $hasMv = ($clientDelta -match 'MVVIEW::9_complete')
        $hasStuff = ($clientDelta -match 'STUFFINIT16::data_ready')
        $logNow = Get-NewSrvLog
        $hallHit = @($hallRpcs | Where-Object { $logNow -match ("<- " + [regex]::Escape($_) + " ") }).Count
        if (($hasMv -and $hasStuff) -or $hasShow -or ($hallHit -ge 3)) { break }
        Start-Sleep -Seconds 1
    }
    $clientDelta | Set-Content -Encoding UTF8 (Join-Path $ArtDir 'client.delta.log') -ErrorAction SilentlyContinue
    $mainReady = ($hasMv -and $hasStuff) -or $hasShow -or ($hallHit -ge 3)
    $initDetail = "hallRPC=$hallHit/8 MVVIEW::9_complete=$hasMv STUFFINIT16::data_ready=$hasStuff " +
                  "(旁证: INIT_GAMEDATA=$hasInit SHOW_MAIN_VIEW/MainMediator=$hasShow)"
    Check 'E9' '客户端初始化链已跑到主界面构建' $mainReady $initDetail

    # 1. 截图 1/3：大厅主界面 (DWM thumbnail)
    $shotMain = Join-Path $ArtDir 'lobby_main.png'
    $shot = Join-Path $ArtDir 'lobby.png'
    Write-Host "`n>>> 截图 1/3: 大厅主界面 (DWM thumbnail，遮挡无关)"
    $sj = (python 'tools\capture_lobby_dwm.py' $shotMain 2>&1 | Out-String).Trim()
    Write-Host "    $sj" -ForegroundColor DarkGray
    Copy-Item $shotMain $shot -Force -ErrorAction SilentlyContinue
    $shotOk = Test-Path $shotMain
    $colors = 0
    $shotMethod = 'dwm'
    try { $colors = [int]([regex]::Matches($sj, '"unique_colors":\s*(\d+)')[-1].Groups[1].Value) } catch {}
    Check 'E3' '大厅窗口截图已生成' $shotOk $(if ($shotOk) { "$([int]((Get-Item $shotMain).Length/1KB)) KB, colors=$colors" } else { '无截图' })
    Check 'E4' '大厅画面非空白' ($colors -gt 24) "unique_colors=$colors"

    # E10：主界面像素健康
    $minColors = 200
    if ($env:SSJJ_E2E_MIN_COLORS) { $minColors = [int]$env:SSJJ_E2E_MIN_COLORS }
    $minMean = 20
    if ($env:SSJJ_E2E_MIN_MEAN) { $minMean = [double]$env:SSJJ_E2E_MIN_MEAN }
    $mean = 0.0; $stddev = 0.0
    $hj = (python 'tools\img_health.py' $shotMain --json 2>&1 | Out-String).Trim()
    try {
        $h = $hj | ConvertFrom-Json
        $mean = [double]$h.mean
        $stddev = [double]$h.stddev
    } catch {}
    $healthOk = ($colors -ge $minColors) -and ($mean -ge $minMean)
    Check 'E10' '主界面像素健康（非登录黑屏）' $healthOk `
        "colors=$colors(>= $minColors), mean=$mean(>= $minMean), stddev=$stddev, via=$shotMethod"

    # 2. 截图 2/3：仓库界面 (点击 storageBtn, relx=0.954, rely=0.029)
    $shotWarehouse = Join-Path $ArtDir 'lobby_warehouse.png'
    Write-Host "`n>>> 截图 2/3: 仓库界面 (点击 storageBtn, relx=0.954, rely=0.029)"
    python 'tools\air_click.py' --title 'SSJJ_FlashAir' --relx 0.954 --rely 0.029
    Start-Sleep -Seconds 12
    $sjW = (python 'tools\capture_lobby_dwm.py' $shotWarehouse 2>&1 | Out-String).Trim()
    Write-Host "    $sjW" -ForegroundColor DarkGray
    $hjW = (python 'tools\img_health.py' $shotWarehouse --json 2>&1 | Out-String).Trim()
    Write-Host "    $hjW" -ForegroundColor DarkGray

    # 3. 截图 3/3：角色选择界面 (返回大厅后点击 selectRoleBtn, relx=0.145, rely=0.870)
    $shotRole = Join-Path $ArtDir 'lobby_role_select.png'
    Write-Host "`n>>> 截图 3/3: 角色选择界面 (返回大厅后点击 selectRoleBtn, relx=0.145, rely=0.870)"
    python 'tools\air_click.py' --title 'SSJJ_FlashAir' --relx 0.500 --rely 0.028
    Start-Sleep -Seconds 1
    python 'tools\air_click.py' --title 'SSJJ_FlashAir' --relx 0.500 --rely 0.028
    Start-Sleep -Seconds 2
    python 'tools\air_click.py' --title 'SSJJ_FlashAir' --relx 0.145 --rely 0.870
    Start-Sleep -Seconds 5
    $sjR = (python 'tools\capture_lobby_dwm.py' $shotRole 2>&1 | Out-String).Trim()
    Write-Host "    $sjR" -ForegroundColor DarkGray
    $hjR = (python 'tools\img_health.py' $shotRole --json 2>&1 | Out-String).Trim()
    Write-Host "    $hjR" -ForegroundColor DarkGray

    # 归档到 artifacts/ 根目录
    $rootArt = Join-Path $Root 'artifacts'
    New-Item -ItemType Directory -Force -Path $rootArt | Out-Null
    Copy-Item $shotMain (Join-Path $rootArt 'lobby_main.png') -Force -ErrorAction SilentlyContinue
    Copy-Item $shotWarehouse (Join-Path $rootArt 'lobby_warehouse.png') -Force -ErrorAction SilentlyContinue
    Copy-Item $shotRole (Join-Path $rootArt 'lobby_role_select.png') -Force -ErrorAction SilentlyContinue

    # 日志断言
    Write-Host "`n>>> 日志断言"
    $log = Get-NewSrvLog
    $log | Set-Content -Encoding UTF8 (Join-Path $ArtDir 'server.delta.log') -ErrorAction SilentlyContinue
    $rpcErr = ([regex]::Matches($log, '\[RPC-ERR #')).Count
    $noReply = ([regex]::Matches($log, '\[NO-REPLY #')).Count
    $unimpl = ([regex]::Matches($log, 'UNIMPL_RPC ')).Count
    $sentReq = ([regex]::Matches($log, '<- ')).Count
    $sentCb = ([regex]::Matches($log, '-> ')).Count

    Check 'E5' '无 RPC 异常' ($rpcErr -eq 0) "RPC-ERR=$rpcErr"
    Check 'E6' '无静默无回包' ($noReply -eq 0) "NO-REPLY=$noReply"
    Check 'E7' 'UNIMPL_RPC 在阈值内(<=50)' ($unimpl -le 50) "UNIMPL=$unimpl"

    # E8：大厅业务 RPC —— 只有主界面真正跑起来才会发这些；登录成功但 UI 不渲染时会缺失
    $hit = @($hallRpcs | Where-Object { $log -match ("<- " + [regex]::Escape($_) + " ") })
    Check 'E8' '大厅主界面已启动（业务 RPC 出现）' ($hit.Count -ge 3) ("命中 " + $hit.Count + "/" + $hallRpcs.Count + ": " + ($hit -join ','))
    Write-Host ("    统计: 请求 <-{0}  回包 ->{1}  RPC-ERR={2}  NO-REPLY={3}  UNIMPL={4}" -f $sentReq, $sentCb, $rpcErr, $noReply, $unimpl) -ForegroundColor DarkGray

    if (-not $SkipLaunch -and $launcher) {
        $ll = Get-Content $LauncherLog -ErrorAction SilentlyContinue
        if ($ll) { $ll | Select-Object -Last 8 | ForEach-Object { Write-Host "    | $_" -ForegroundColor DarkGray } }
    }
}
finally {
    if (-not $SkipLaunch) {
        Write-Host "`n>>> 收尾：关闭链路（保持机器干净）"
        Stop-Stack
    }
    Write-Host "产物目录: $ArtDir"
}

$summary = [pscustomobject]@{
    stamp = $Stamp
    ok = ($script:Fail -eq 0)
    fail = $script:Fail
    artifacts = $ArtDir
    results = $script:Results
}
$summary | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 (Join-Path $ArtDir 'result.json')

Write-Host "`n--- 结果 ---"
if ($script:Fail -gt 0) {
    Write-Host ("FAIL 项: " + $script:Fail) -ForegroundColor Red
    exit 1
}
Write-Host '端到端验收全部通过。' -ForegroundColor Green
exit 0
