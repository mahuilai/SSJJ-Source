# 自定义皮肤安装：sanjiaozhouwoman (三国周瑜女)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$MainMd5 = '52ec316cfae6aa3a2f14e8a2f79baacc'
$SubMd5  = 'e9245a58bcfc380f9a49d83fbb76e7c7'
$MainName = 'player/sanjiaozhouwoman'
$SubName  = 'player/sanjiaozhouwoman$2'

function Find-GameDir {
    param([string]$start)
    $cands = @()
    $d = Get-Item $start
    for ($i = 0; $i -lt 6; $i++) {
        $cands += (Join-Path $d.FullName 'battle\3_64')
        $cands += $d.FullName
        if ($null -eq $d.Parent) { break }
        $d = $d.Parent
    }
    $cands += 'D:\SSJJ-4399\battle\3_64'
    $cands += 'C:\SSJJ-4399\battle\3_64'
    foreach ($c in $cands) {
        if ($c -and (Test-Path (Join-Path $c 'SSJJ_BattleClient_Unity.exe'))) {
            return (Resolve-Path $c).Path
        }
    }
    return $null
}

Write-Host "=== 自定义皮肤安装 ===" -ForegroundColor Cyan

$game = Find-GameDir $here
if (-not $game) {
    Write-Host "没自动找到游戏目录。" -ForegroundColor Yellow
    $game = Read-Host "请输入战斗客户端目录（含 SSJJ_BattleClient_Unity.exe，例如 D:\SSJJ-4399\battle\3_64）"
    $game = $game.Trim('"').Trim()
    if (-not (Test-Path (Join-Path $game 'SSJJ_BattleClient_Unity.exe'))) {
        Write-Host "目录里没有 SSJJ_BattleClient_Unity.exe，退出。" -ForegroundColor Red
        exit 1
    }
}
Write-Host "游戏目录: $game"

$win = Join-Path $game 'SSJJ_BattleClient_Unity_Data\StreamingAssets\AssetBundles\Windows'
$manifest = Join-Path $win 'AssetBundles'
if (-not (Test-Path $manifest)) {
    Write-Host "找不到清单文件: $manifest" -ForegroundColor Red
    exit 1
}

# ---- 1. 拷包到 player/ 子目录 ----
$playerDir = Join-Path $win 'player'
if (-not (Test-Path $playerDir)) { New-Item -ItemType Directory -Path $playerDir | Out-Null }
foreach ($f in @($MainMd5, $SubMd5)) {
    $leaf = if ($f -eq $MainMd5) { 'sanjiaozhouwoman' } else { 'sanjiaozhouwoman$2' }
    $dst = Join-Path $playerDir ("{0}_{1}" -f $leaf, $f)
    $srcFile = Join-Path (Join-Path $here 'player') ("{0}_{1}" -f $leaf, $f)
    if (-not (Test-Path $srcFile)) { Write-Host "缺少文件 $srcFile" -ForegroundColor Red; exit 1 }
    Copy-Item $srcFile $dst -Force
    $h = (Get-FileHash $dst -Algorithm MD5).Hash.ToLower()
    Write-Host ("  部署 {0}  md5={1} {2}" -f $leaf, $h, $(if ($h -eq $f) { 'OK' } else { '校验失败' }))
}

# ---- 2. 改清单 ----
Copy-Item $manifest ($manifest + '.skinbak') -Force
$doc = New-Object System.Xml.XmlDocument
$doc.PreserveWhitespace = $true
$doc.Load($manifest)
$root = $doc.DocumentElement

$node = $root.SelectSingleNode("AssetBundle[@name='$MainName']")
if ($null -eq $node) {
    $node = $doc.CreateElement('AssetBundle')
    $node.SetAttribute('name', $MainName)
    $node.SetAttribute('crc', '0')
    $root.AppendChild($node) | Out-Null
    Write-Host "  清单新增 $MainName"
} else {
    Write-Host "  清单更新 $MainName ($($node.GetAttribute('md5')) -> $MainMd5)"
}
$node.SetAttribute('md5', $MainMd5)
if (-not $node.GetAttribute('crc')) { $node.SetAttribute('crc', '0') }

$dep = $node.SelectSingleNode("Dependency[@name='$SubName']")
if ($null -eq $dep) {
    $dep = $doc.CreateElement('Dependency')
    $dep.SetAttribute('name', $SubName)
    $node.AppendChild($dep) | Out-Null
    Write-Host "  清单补依赖 $SubName"
}

# 用 XmlWriter 保持 utf-8 无 BOM，和原文件一致
$ws = New-Object System.Xml.XmlWriterSettings
$ws.Encoding = New-Object System.Text.UTF8Encoding($false)
$ws.Indent = $false
$ws.OmitXmlDeclaration = $false
$writer = [System.Xml.XmlWriter]::Create($manifest, $ws)
$doc.Save($writer)
$writer.Close()
$writer.Dispose()

# 自校验：能重新解析才算写成功
try {
    $chk = New-Object System.Xml.XmlDocument
    $chk.Load($manifest)
    $n2 = $chk.DocumentElement.SelectSingleNode("AssetBundle[@name='$MainName']")
    if ($n2.GetAttribute('md5') -ne $MainMd5) { throw 'md5 未写入' }
    Write-Host "  清单自校验 OK"
} catch {
    Copy-Item ($manifest + '.skinbak') $manifest -Force
    Write-Host "清单写入异常，已回滚: $_" -ForegroundColor Red
    exit 1
}

# ---- 3. 给启动器打保护（找到才打） ----
$rootDir = Split-Path -Parent (Split-Path -Parent $game)
$prep = Get-ChildItem -Path $rootDir -Filter 'prepare_launch_assets.py' -Recurse -Depth 4 -ErrorAction SilentlyContinue | Select-Object -First 1
if ($prep) {
    $txt = [System.IO.File]::ReadAllText($prep.FullName, [System.Text.Encoding]::UTF8)
    if ($txt -match 'PROTECTED_BUNDLES') {
        Write-Host ("  启动器已带保护: {0}" -f $prep.FullName)
    } else {
        $block = "`nPROTECTED_BUNDLES = {`n    `"player/sanjiaozhouwoman`",`n    `"player/sanjiaozhouwoman`$2`",`n}`n"
        $marker = 'DEFAULT_WEAPON = "nbr_knife_g"'
        if ($txt.Contains($marker)) {
            $txt = $txt.Replace($marker, $marker + $block)
            Copy-Item $prep.FullName ($prep.FullName + '.skinbak') -Force
            [System.IO.File]::WriteAllText($prep.FullName, $txt, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host ("  启动器已加保护: {0}" -f $prep.FullName)
        } else {
            Write-Host "  启动器格式不认识，跳过保护（清单已改好，用启动器重开可能被打回）" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  没找到启动器脚本，跳过保护" -ForegroundColor Yellow
}

# ---- 4. 角色配置：直接改成这个角色，否则进图看不见 ----
$cfg = Join-Path $game 'launch_config.json'
if (Test-Path $cfg) {
    try {
        $raw = [System.IO.File]::ReadAllText($cfg, [System.Text.Encoding]::UTF8)
        $j = $raw | ConvertFrom-Json
        if (($j.career -ne 'sanjiaozhouwoman') -or ($j.hand -ne 'woman')) {
            $oldCareer = $j.career
            Copy-Item $cfg ($cfg + '.skinbak') -Force
            $j.career = 'sanjiaozhouwoman'
            $j.hand = 'woman'
            $out = $j | ConvertTo-Json -Depth 12
            [System.IO.File]::WriteAllText($cfg, $out, (New-Object System.Text.UTF8Encoding($false)))
            Write-Host ("  已改 launch_config.json: career {0} -> sanjiaozhouwoman" -f $oldCareer)
        } else {
            Write-Host "  角色配置已是 sanjiaozhouwoman"
        }
    } catch {
        Write-Host "  launch_config.json 改不了，请手动设 career=sanjiaozhouwoman hand=woman" -ForegroundColor Yellow
    }
} else {
    Write-Host "  没找到 launch_config.json（首次启动会自己生成，生成后再跑一次本脚本）" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "安装完成。进游戏按 F3 看第三人称。" -ForegroundColor Green
Write-Host ("如需卸载：把 {0}.skinbak 覆盖回 AssetBundles 即可" -f $manifest)
Write-Host ""
