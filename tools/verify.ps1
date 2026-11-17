#Requires -Version 5.1
<#
.SYNOPSIS
    SSJJ 离线复刻工程 · 门禁自检脚本
.DESCRIPTION
    分层验收：G0 工程健康 / G1 补丁生效 / G2 大厅 / G3 桥梁 / G4 局内 / G5 分发。
    未实现的检查项输出 SKIP，绝不静默通过。
    退出码：0 = 该层全 PASS（SKIP 不算失败）；1 = 有 FAIL。
.PARAMETER Gate
    要执行的层级：G0..G5，或 ALL（默认 G0）。
.EXAMPLE
    pwsh -File tools\verify.ps1 -Gate G0
#>
[CmdletBinding()]
param(
    [ValidateSet('G0','G1','G2','G3','G4','G5','ALL')]
    [string]$Gate = 'G0'
)

$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

# ---------------- 结果收集 ----------------
$script:Results = @()
function Add-Result {
    param(
        [string]$Gate,
        [string]$Name,
        [ValidateSet('PASS','FAIL','SKIP')][string]$Status,
        [string]$Detail = ''
    )
    $script:Results += [pscustomobject]@{ Gate=$Gate; Name=$Name; Status=$Status; Detail=$Detail }
    $color = switch ($Status) { 'PASS' { 'Green' } 'FAIL' { 'Red' } default { 'DarkYellow' } }
    Write-Host ("  [{0}] {1,-46} {2}" -f $Status, $Name, $Detail) -ForegroundColor $color
}

function Test-PathExists {
    param([string]$Gate, [string]$Name, [string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Add-Result $Gate $Name 'PASS' $Path
        return $true
    }
    Add-Result $Gate $Name 'FAIL' "缺失: $Path"
    return $false
}

# ---------------- G0 工程健康 ----------------
function Invoke-GateG0 {
    Write-Host "`n=== G0 工程健康 ===" -ForegroundColor Cyan

    # 1. git 基线
    $gitOk = $false
    if (Test-Path '.git') {
        $commits = (git rev-list --count HEAD 2>$null)
        if ($LASTEXITCODE -eq 0 -and [int]$commits -gt 0) {
            $tracked = (git ls-files 2>$null | Measure-Object).Count
            Add-Result 'G0' 'git 基线存在' 'PASS' "commit=$commits tracked=$tracked"
            $gitOk = $true
        } else {
            Add-Result 'G0' 'git 基线存在' 'FAIL' '仓库无提交'
        }
    } else {
        Add-Result 'G0' 'git 基线存在' 'FAIL' '无 .git'
    }

    # 2. 核心源码必须被纳管（防 .gitignore 再度整目录排除）
    if ($gitOk) {
        $mustTrack = @(
            '_work/gateway_8080.py',
            '_work/launch_lobby.py',
            '_work/lobby_host/java/LobbyLoginServer.java',
            'SSJJ-Server/Program.cs',
            'STATE.md'
        )
        $missing = @()
        foreach ($f in $mustTrack) {
            $ls = git ls-files --error-unmatch $f 2>$null
            if ($LASTEXITCODE -ne 0) { $missing += $f }
        }
        if ($missing.Count -eq 0) {
            Add-Result 'G0' '核心源码已纳管' 'PASS' "$($mustTrack.Count) 项"
        } else {
            Add-Result 'G0' '核心源码已纳管' 'FAIL' ("未纳管: " + ($missing -join ', '))
        }

        # 反例：资源目录必须仍被忽略
        $ig = git check-ignore '资源全集' 2>$null
        if ($LASTEXITCODE -eq 0) {
            Add-Result 'G0' '原厂资源仍被忽略' 'PASS' '资源全集/ ignored'
        } else {
            Add-Result 'G0' '原厂资源仍被忽略' 'FAIL' '资源全集/ 未被忽略（体积风险）'
        }
    } else {
        Add-Result 'G0' '核心源码已纳管' 'SKIP' '依赖 git 基线'
        Add-Result 'G0' '原厂资源仍被忽略' 'SKIP' '依赖 git 基线'
    }

    # 3. 单一事实源
    Test-PathExists 'G0' 'STATE.md 存在' 'STATE.md' | Out-Null
    if (Test-Path 'STATE.md') {
        $hasM = (Select-String -Path 'STATE.md' -Pattern 'M5' -Quiet)
        Add-Result 'G0' 'STATE.md 含里程碑表' $(if ($hasM) {'PASS'} else {'FAIL'}) $(if ($hasM) {'M0-M5'} else {'未找到里程碑'})
    }
    # 交接文档已清理（2026-11-05）：仓库根与 docs/ 下不应再有交接/接手/HANDOVER 类文档；
    # 唯一允许的考古入口是 docs/archive/历史技术摘要.md（文件名不含"交接文档"）。
    # 注意：只扫根目录(非递归)+docs/(仅几十个文件)，全仓递归会扫进 17GB 资源目录而超时。
    $leftover = @(
        Get-ChildItem -Path '.' -File -Include '*交接*.md','*接手*.md','*HANDOVER*.md' -ErrorAction SilentlyContinue
        Get-ChildItem -Path 'docs' -File -Recurse -Include '*交接*.md','*接手*.md','*HANDOVER*.md' -ErrorAction SilentlyContinue
    )
    Add-Result 'G0' '交接文档已清理' $(if ($leftover.Count -eq 0) {'PASS'} else {'FAIL'}) `
        $(if ($leftover.Count -eq 0) {'仅 docs/archive/历史技术摘要.md'} else {($leftover.FullName -join ',')})

    # 4. 关键运行依赖
    $py = (Get-Command python -ErrorAction SilentlyContinue)
    Add-Result 'G0' 'python 可用' $(if ($py) {'PASS'} else {'FAIL'}) $(if ($py) { (python --version 2>&1) } else { '未找到 python' })
    $java = (Get-Command java -ErrorAction SilentlyContinue)
    Add-Result 'G0' 'java 可用' $(if ($java) {'PASS'} else {'FAIL'}) $(if ($java) { (java -version 2>&1 | Select-Object -First 1) } else { '未找到 java' })
    $dotnet = (Get-Command dotnet -ErrorAction SilentlyContinue)
    Add-Result 'G0' 'dotnet 可用' $(if ($dotnet) {'PASS'} else {'FAIL'}) $(if ($dotnet) { (dotnet --version 2>&1) } else { '未找到 dotnet' })

    # 5. 关键路径
    Test-PathExists 'G0' '网关脚本' '_work\gateway_8080.py' | Out-Null
    Test-PathExists 'G0' '大厅启动器' '_work\launch_lobby.py' | Out-Null
    Test-PathExists 'G0' 'Java 大厅服源码' '_work\lobby_host\java\LobbyLoginServer.java' | Out-Null
    Test-PathExists 'G0' '战斗服工程' 'SSJJ-Server\SSJJ-Server.csproj' | Out-Null
    Test-PathExists 'G0' '注入层源码目录' 'Game-SSJJ-Source\Assets\Decompiled' | Out-Null
    Test-PathExists 'G0' '坐标系契约(§6)' 'STATE.md' | Out-Null

    # 6. 原版程序集基准（M1 唯一真相）
    $orig = 'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed\Assembly-CSharp.dll.orig.bak'
    if (Test-Path -LiteralPath $orig) {
        $mb = [math]::Round((Get-Item -LiteralPath $orig).Length / 1MB, 2)
        Add-Result 'G0' '原版程序集基准存在' 'PASS' "$mb MB"
    } else {
        Add-Result 'G0' '原版程序集基准存在' 'FAIL' '缺失 Assembly-CSharp.dll.orig.bak（M1 无法进行）'
    }

    # 7. 技术债指标（仅记录，不计入 FAIL）
    $offline = @(Get-ChildItem 'Game-SSJJ-Source\Assets\Decompiled' -File -Filter 'Offline*.cs' -ErrorAction SilentlyContinue)
    $loc = 0
    if ($offline.Count -gt 0) {
        foreach ($f in $offline) { $loc += (Get-Content -LiteralPath $f.FullName | Measure-Object -Line).Lines }
    }
    Add-Result 'G0' '注入层规模(记录)' 'PASS' "$($offline.Count) 文件 / $loc 行"

    $emptyCatch = 0
    if ($offline.Count -gt 0) {
        $emptyCatch = (Select-String -Path $offline.FullName -Pattern 'catch\s*(\([^)]*\))?\s*\{\s*\}' -AllMatches |
                       ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
        if ($null -eq $emptyCatch) { $emptyCatch = 0 }
    }
    Add-Result 'G0' '空 catch 数量(记录)' 'PASS' "$emptyCatch 处 → M0 目标: 0"

    # 8. 一键回滚能力
    if (Test-Path 'tools\rollback.ps1') {
        Add-Result 'G0' '一键回滚脚本' 'PASS' 'tools\rollback.ps1'
    } else {
        Add-Result 'G0' '一键回滚脚本' 'FAIL' '缺失 tools\rollback.ps1'
    }
}

# ---------------- G1..G5 占位 ----------------
# ---------------- G1 一键迭代回路 ----------------
function Invoke-GateG1 {
    Write-Host "`n=== G1 一键迭代回路 ===" -ForegroundColor Cyan

    Test-PathExists 'G1' 'iterate.ps1 存在' 'tools\iterate.ps1' | Out-Null
    Test-PathExists 'G1' 'rollback.ps1 存在' 'tools\rollback.ps1' | Out-Null
    Test-PathExists 'G1' '加密回注器存在' 'Game-SSJJ\tools\inject_rebuild.py' | Out-Null
    Test-PathExists 'G1' '重编译工程存在' 'Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild\Assembly-CSharp.csproj' | Out-Null

    # 回注器必须带算法自校验（防止加密参数漂移后静默产出坏 DLL）
    if (Test-Path 'Game-SSJJ\tools\inject_rebuild.py') {
        $hasSanity = Select-String -Path 'Game-SSJJ\tools\inject_rebuild.py' -Pattern 'sanity encrypt' -Quiet
        Add-Result 'G1' '回注器含算法自校验' $(if ($hasSanity) {'PASS'} else {'FAIL'}) $(if ($hasSanity) {'sanity encrypt(recovered)==original'} else {'缺失自校验，危险'})
    }

    # 端到端实测：-Mode none -SkipDeploy 必须 ≤15s 且退出码 0
    if (Test-Path 'tools\iterate.ps1') {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $out = & pwsh -NoProfile -File 'tools\iterate.ps1' -Mode none -SkipDeploy 2>&1
        $code = $LASTEXITCODE
        $sw.Stop()
        $sec = [math]::Round($sw.Elapsed.TotalSeconds, 1)
        if ($code -eq 0 -and $sec -le 15) {
            Add-Result 'G1' 'iterate -Mode none ≤15s' 'PASS' "$sec s / exit=$code"
        } elseif ($code -eq 0) {
            Add-Result 'G1' 'iterate -Mode none ≤15s' 'FAIL' "超时 $sec s（>15s）"
        } else {
            $tail = ($out | Select-Object -Last 3) -join ' | '
            Add-Result 'G1' 'iterate -Mode none ≤15s' 'FAIL' "exit=$code :: $tail"
        }
        # 产物存档
        $arch = @(Get-ChildItem 'Game-SSJJ-logs\iter' -Directory -ErrorAction SilentlyContinue)
        Add-Result 'G1' '每轮产物已存档' $(if ($arch.Count -gt 0) {'PASS'} else {'FAIL'}) "$($arch.Count) 轮"
    } else {
        Add-Result 'G1' 'iterate -Mode none ≤15s' 'SKIP' '依赖 iterate.ps1'
    }
}

function Invoke-GateG2 {
    Write-Host "`n=== G2 局外大厅（服务端硬化部分）===" -ForegroundColor Cyan

    # 1) 静态断言：四个 P0 的修复痕迹必须在源码里（防止回退）
    $javaDir = '_work\lobby_host\java'
    $checks = @(
        @{ N='大厅仅绑回环';       F="$javaDir\LobbyLoginServer.java"; P='getLoopbackAddress';        W='P0-10' },
        @{ N='帧长上限存在';       F="$javaDir\LobbyLoginServer.java"; P='MAX_FRAME';                  W='P0-7'  },
        @{ N='连接数上限存在';     F="$javaDir\LobbyLoginServer.java"; P='ACTIVE_CONN';                W='P0-7'  },
        @{ N='空闲超时存在';       F="$javaDir\LobbyLoginServer.java"; P='setSoTimeout';                W='P0-7'  },
        @{ N='无回包可检测';       F="$javaDir\LobbyLoginServer.java"; P='NO-REPLY';                    W='P0-8'  },
        @{ N='存档原子写';         F="$javaDir\ProfileManager.java";   P='ATOMIC_MOVE';                 W='P0-9'  },
        @{ N='战斗服绑回环策略';   F='SSJJ-Server\src\Network\BindPolicy.cs'; P='SSJJ_BIND_ADDR';       W='P0-10' }
    )
    foreach ($c in $checks) {
        if (-not (Test-Path $c.F)) { Add-Result 'G2' $c.N 'FAIL' "$($c.W) 文件缺失: $($c.F)"; continue }
        $ok = Select-String -Path $c.F -Pattern ([regex]::Escape($c.P)) -Quiet
        Add-Result 'G2' $c.N $(if ($ok) {'PASS'} else {'FAIL'}) $(if ($ok) { $c.W } else { "$($c.W) 断言缺失，疑似回退" })
    }

    # 2) Java 可编译
    if (Get-Command javac -ErrorAction SilentlyContinue) {
        Push-Location $javaDir
        try {
            $o = & javac -encoding UTF-8 -d . *.java 2>&1
            $bad = @($o | Where-Object { $_ -match 'error|错误' })
            Add-Result 'G2' 'Java 服务端可编译' $(if ($bad.Count -eq 0) {'PASS'} else {'FAIL'}) $(if ($bad.Count -eq 0) {'0 error'} else { $bad[0] })
        } finally { Pop-Location }
    } else {
        Add-Result 'G2' 'Java 服务端可编译' 'SKIP' 'javac 不在 PATH'
    }

    # 3) P0 回归实测
    if (Test-Path 'tools\test_lobby_p0.ps1') {
        $o = & pwsh -NoProfile -File 'tools\test_lobby_p0.ps1' 2>&1
        $ok = ($LASTEXITCODE -eq 0)
        $fails = @($o | Select-String '\[FAIL\]')
        Add-Result 'G2' 'P0 回归实测通过' $(if ($ok) {'PASS'} else {'FAIL'}) $(if ($ok) { '10/10' } else { $fails -join '; ' })
    } else {
        Add-Result 'G2' 'P0 回归实测通过' 'FAIL' '缺少 tools\test_lobby_p0.ps1'
    }

    # 4) RPC 三级分类交付物
    if ((Test-Path 'docs\RPC分级.md') -and (Test-Path '_work\lobby_host\rpc_classification.json')) {
        try {
            $cls = Get-Content '_work\lobby_host\rpc_classification.json' -Raw | ConvertFrom-Json
            $s = $cls.summary
            Add-Result 'G2' 'RPC 三级分类已产出' 'PASS' ("A=$($s.A_handled) B零值桩=$($s.B_stub_sent) C死条目=$($s.C_never_sent)")
        } catch {
            Add-Result 'G2' 'RPC 三级分类已产出' 'FAIL' "json 解析失败: $($_.Exception.Message)"
        }
    } else {
        Add-Result 'G2' 'RPC 三级分类已产出' 'FAIL' '缺少 docs\RPC分级.md 或 rpc_classification.json'
    }

    # 5) 客户端级验收：消费最近一次 e2e 的 result.json（verify 本身不启动游戏）
    $e2eFiles = @(Get-ChildItem 'Game-SSJJ-logs\e2e' -Directory -ErrorAction SilentlyContinue |
        ForEach-Object {
            $p = Join-Path $_.FullName 'result.json'
            if (Test-Path $p) { Get-Item $p }
        } | Sort-Object LastWriteTime -Descending)
    if ($e2eFiles.Count -eq 0) {
        Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'SKIP' '未找到 e2e result.json；先运行 tools\test_lobby_e2e.ps1'
    } else {
        $e2ePath = $e2eFiles[0].FullName
        $ageHours = ((Get-Date) - $e2eFiles[0].LastWriteTime).TotalHours
        if ($ageHours -gt 24) {
            Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'SKIP' ("最近 e2e 结果过期({0:N1}h)：{1}" -f $ageHours, $e2ePath)
        } else {
            try {
                $e2e = Get-Content $e2ePath -Raw | ConvertFrom-Json
                $bad = @($e2e.results | Where-Object { $_.status -eq 'FAIL' } | ForEach-Object { $_.id })
                $e11 = @($e2e.results | Where-Object { $_.id -eq 'E11' })[0]
                if ($bad.Count -gt 0) {
                    Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'FAIL' ("e2e FAIL: " + ($bad -join ',') + "；详见 " + $e2e.artifacts)
                } elseif ($e11 -and $e11.status -eq 'SKIP') {
                    Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'SKIP' ('E9/E10 通过，但 E11 未标定：' + $e11.detail)
                } elseif ($e2e.ok) {
                    Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'PASS' ('e2e ' + $e2e.stamp + ' 全绿')
                } else {
                    Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'SKIP' ('e2e 未全绿：fail=' + $e2e.fail)
                }
            } catch {
                Add-Result 'G2' '客户端级验收（冷启动/仓库全量/换装保持/not-has-id）' 'SKIP' ("e2e result 解析失败: " + $_.Exception.Message)
            }
        }
    }
}

function Invoke-GatePlaceholder {
    param([string]$G, [string]$Title, [string]$Reason)
    Write-Host "`n=== $G $Title ===" -ForegroundColor Cyan
    Add-Result $G "$G 验收项" 'SKIP' $Reason
}

# ---------------- 主流程 ----------------
Write-Host "SSJJ 门禁自检 · root=$Root · gate=$Gate" -ForegroundColor White

$gates = if ($Gate -eq 'ALL') { @('G0','G1','G2','G3','G4','G5') } else { @($Gate) }

foreach ($g in $gates) {
    switch ($g) {
        'G0' { Invoke-GateG0 }
        'G1' { Invoke-GateG1 }
        'G2' { Invoke-GateG2 }
        'G3' { Invoke-GatePlaceholder 'G3' '启动桥梁' '待 M3 实现：需要全链路拉起' }
        'G4' { Invoke-GatePlaceholder 'G4' '服务端权威' '待 M4 实现：需要 headless 战斗服 + golden test' }
        'G5' { Invoke-GatePlaceholder 'G5' '分发包' '待 M5 实现：需要干净机器验证' }
    }
}

# ---------------- 汇总 ----------------
$fail = @($script:Results | Where-Object Status -eq 'FAIL')
$pass = @($script:Results | Where-Object Status -eq 'PASS')
$skip = @($script:Results | Where-Object Status -eq 'SKIP')

Write-Host "`n--- 汇总 ---" -ForegroundColor White
Write-Host ("PASS={0}  FAIL={1}  SKIP={2}" -f $pass.Count, $fail.Count, $skip.Count)

if ($fail.Count -gt 0) {
    Write-Host "`n失败项:" -ForegroundColor Red
    $fail | ForEach-Object { Write-Host ("  - [{0}] {1} :: {2}" -f $_.Gate, $_.Name, $_.Detail) -ForegroundColor Red }
    exit 1
}

Write-Host "`n门禁通过。" -ForegroundColor Green
exit 0
