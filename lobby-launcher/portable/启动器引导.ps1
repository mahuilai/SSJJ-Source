param(
    [Parameter(Mandatory = $true)][string]$Executable
)

$ErrorActionPreference = 'Stop'
$bundleRoot = [IO.Path]::GetFullPath($PSScriptRoot)
$exePath = Join-Path $bundleRoot $Executable
$gameDir = Join-Path $bundleRoot 'battle\3_64'
$pythonExe = Join-Path $bundleRoot 'runtime\python\python.exe'
$startScript = Join-Path $bundleRoot 'scripts\start_offline.py'
$mapScript = Join-Path $bundleRoot 'scripts\install_map.py'

foreach ($required in @($exePath, (Join-Path $gameDir 'SSJJ_BattleClient_Unity.exe'), $pythonExe, $startScript, $mapScript)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "便携包缺少文件：$required"
    }
}

$configDir = Join-Path $env:APPDATA 'ssjj-lobby'
$configPath = Join-Path $configDir 'config.json'
New-Item -ItemType Directory -Force -Path $configDir | Out-Null

if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    try {
        $settings = [IO.File]::ReadAllText($configPath, [Text.Encoding]::UTF8) | ConvertFrom-Json
    } catch {
        throw "大厅配置无法解析，未覆盖原文件：$configPath ($($_.Exception.Message))"
    }
} else {
    $settings = [pscustomobject]@{}
}

$portablePaths = @{
    game_dir = $gameDir
    start_script = $startScript
    python = $pythonExe
    map_install_script = $mapScript
}
foreach ($entry in $portablePaths.GetEnumerator()) {
    if ($null -eq $settings.PSObject.Properties[$entry.Key]) {
        $settings | Add-Member -MemberType NoteProperty -Name $entry.Key -Value $entry.Value
    } else {
        $settings.($entry.Key) = $entry.Value
    }
}

$json = $settings | ConvertTo-Json -Depth 40
$tempPath = "$configPath.tmp"
[IO.File]::WriteAllText($tempPath, $json, [Text.UTF8Encoding]::new($false))
Move-Item -LiteralPath $tempPath -Destination $configPath -Force

$env:SSJJ_BUNDLE_ROOT = $bundleRoot
$env:PYTHONUTF8 = '1'
Start-Process -FilePath $exePath -WorkingDirectory $bundleRoot
