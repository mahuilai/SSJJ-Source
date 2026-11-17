$ErrorActionPreference = 'Stop'

$project = $PSScriptRoot
$launcherRoot = Split-Path -Parent $project
$workspaceRoot = Split-Path -Parent $launcherRoot
$assetRoot = Join-Path $workspaceRoot '资源下载\大厅资源\SSJJ-main\export'
$officialAirRoot = 'D:\SSJJ\SSJJ-4399\Lobby'
$sdkRoot = Join-Path $workspaceRoot '_tools'
$assetOut = Join-Path $project 'assets'
$outRoot = Join-Path $project 'dist'
$appOut = Join-Path $outRoot 'SSJJ-Flash-Lobby'
$swfOut = Join-Path $appOut 'SSJJOfflineLobby.swf'
$mainAs = Join-Path $project 'src\OfflineLobby.as'
$mxmlc = Join-Path $sdkRoot 'bin\mxmlc.bat'

if (-not (Test-Path -LiteralPath $mxmlc)) { throw "Flex mxmlc not found: $mxmlc" }
if (-not (Test-Path -LiteralPath $assetRoot)) { throw "Official lobby export assets not found: $assetRoot" }
if (-not (Test-Path -LiteralPath $officialAirRoot)) { throw "Portable AIR runtime source not found: $officialAirRoot" }

New-Item -ItemType Directory -Force -Path $assetOut, $appOut | Out-Null

function Copy-SpriteFrame([string]$library, [string]$symbol, [string]$targetName) {
    $folder = Get-ChildItem -LiteralPath (Join-Path $assetRoot "$library\sprites") -Directory |
        Where-Object { $_.Name -like "*_${library}.${symbol}" } |
        Select-Object -First 1
    if (-not $folder) { throw "Missing official SWF sprite: $library.$symbol" }
    $frame = Join-Path $folder.FullName '1.png'
    if (-not (Test-Path -LiteralPath $frame)) { throw "Missing first frame for $library.$symbol" }
    Copy-Item -LiteralPath $frame -Destination (Join-Path $assetOut $targetName) -Force
}

Copy-SpriteFrame 'ResourceAssets' 'game_bg' 'lobby_bg.png'
Copy-SpriteFrame 'MallAssets' 'mall_bg' 'warehouse_bg.png'
Copy-SpriteFrame 'MallAssets' 'mall_item_new1' 'weapon_card.png'
Copy-SpriteFrame 'MallAssets' 'storage_item_new3' 'weapon_card_selected.png'
Copy-SpriteFrame 'NewRoleAssets' 'roleBg' 'role_bg.png'
Copy-SpriteFrame 'NewRoleAssets' 'blueItemF1' 'role_card.png'

$navSymbols = @{
    nav_gamehall = 'gameHall_1'
    nav_activity = 'activity_1'
    nav_factory = 'factory_1'
    nav_shop = 'shop_1'
    nav_rank = 'rank_1'
    nav_team = 'team_1'
    nav_creditshop = 'creditshop_1'
    nav_vitae = 'vitae_1'
    nav_warehouse = 'warehouse_1'
}
foreach ($entry in $navSymbols.GetEnumerator()) {
    Copy-SpriteFrame 'MainTopButtonAssets' $entry.Value ($entry.Key + '.png')
}

Copy-Item -LiteralPath (Join-Path $launcherRoot 'data\official_lobby_dataset.json') -Destination (Join-Path $assetOut 'official_lobby_dataset.json') -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot 'data\official_lobby_preview_index.json') -Destination (Join-Path $assetOut 'official_lobby_preview_index.json') -Force

$env:FLEX_HOME = $sdkRoot
$env:PLAYERGLOBAL_HOME = Join-Path $sdkRoot 'frameworks\libs\player'
& $mxmlc '-target-player=11.6' '-swf-version=19' `
    "-source-path+=$(Join-Path $project 'src')" '-optimize=true' "-output=$swfOut" $mainAs
if ($LASTEXITCODE -ne 0) { throw "mxmlc exited with code $LASTEXITCODE" }

# Build a separate captive AIR folder. The user's installed Lobby folder is read-only input.
foreach ($relative in @('AirLobbyPreloader.exe', 'air.dat', 'paras.dat', 'mimetype', 'Adobe AIR', 'META-INF\AIR\application.xml', 'images\icon128.png')) {
    $source = Join-Path $officialAirRoot $relative
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing AIR runtime component: $source" }
    $destination = Join-Path $appOut $relative
    $destinationDirectory = Split-Path -Parent $destination
    New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null
    if (Test-Path -LiteralPath $source -PathType Container) {
        Copy-Item -LiteralPath $source -Destination $destinationDirectory -Recurse -Force
    } else {
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }
}

$airMeta = Join-Path $appOut 'META-INF\AIR'
Copy-Item -LiteralPath (Join-Path $officialAirRoot 'META-INF\AIR\hash') -Destination $airMeta -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath $swfOut -Destination (Join-Path $appOut 'AirLobbyPreloader.swf') -Force

$descriptor = Join-Path $airMeta 'application.xml'
[xml]$app = Get-Content -LiteralPath $descriptor -Raw
$ns = New-Object System.Xml.XmlNamespaceManager($app.NameTable)
$ns.AddNamespace('a', 'http://ns.adobe.com/air/application/3.6')
$app.SelectSingleNode('/a:application/a:initialWindow/a:content', $ns).InnerText = 'AirLobbyPreloader.swf'
$app.SelectSingleNode('/a:application/a:initialWindow/a:systemChrome', $ns).InnerText = 'standard'
$app.SelectSingleNode('/a:application/a:initialWindow/a:transparent', $ns).InnerText = 'false'
$app.SelectSingleNode('/a:application/a:initialWindow/a:width', $ns).InnerText = '1024'
$app.SelectSingleNode('/a:application/a:initialWindow/a:height', $ns).InnerText = '650'
$title = $app.SelectSingleNode('/a:application/a:initialWindow/a:title', $ns)
if (-not $title) {
    $title = $app.CreateElement('title', 'http://ns.adobe.com/air/application/3.6')
    $app.SelectSingleNode('/a:application/a:initialWindow', $ns).AppendChild($title) | Out-Null
}
$title.InnerText = '生死狙击 · 离线大厅（SWF 重建）'
$app.Save($descriptor)

# Keep runtime data beside the independently built AIR app for local SWF art lookup.
New-Item -ItemType Directory -Force -Path (Join-Path $appOut 'data\previews\official_lobby') | Out-Null
Copy-Item -LiteralPath (Join-Path $launcherRoot 'data\previews\official_lobby') `
    -Destination (Join-Path $appOut 'data\previews') -Recurse -Force
Copy-Item -LiteralPath (Join-Path $launcherRoot 'data\official_lobby_dataset.json') -Destination (Join-Path $appOut 'data\official_lobby_dataset.json') -Force

$startBat = Join-Path $outRoot '启动SWF原版质感大厅.bat'
@'
@echo off
cd /d "%~dp0SSJJ-Flash-Lobby"
start "" AirLobbyPreloader.exe
'@ | Set-Content -LiteralPath $startBat -Encoding Ascii

Write-Host "Built custom lobby SWF: $swfOut"
Write-Host "AIR app folder: $appOut"
Write-Host "Launcher: $startBat"
