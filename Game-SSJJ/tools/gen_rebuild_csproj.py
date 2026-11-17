import os
import subprocess
import sys

UNITY_DATA = r'D:\Unity\Editor\Data'
GAME_MANAGED = r'D:\SSJJ-4399\battle\3_64\SSJJ_BattleClient_Unity_Data\Managed'
SRC = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled'
OUT = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ\SourceBuild\Assembly-CSharp-rebuild'

os.makedirs(OUT, exist_ok=True)


def collect_dlls():
    refs = []
    for sub in (r'Managed', r'Managed\UnityEngine', r'UnityExtensions'):
        root = os.path.join(UNITY_DATA, sub)
        for r, _, files in os.walk(root):
            for f in files:
                if not f.lower().endswith('.dll'):
                    continue
                p = os.path.join(r, f)
                # 2019 的 UnityEngine.dll 是门面，与 *Module.dll 重复定义类型，剔除
                if os.path.normcase(p) == os.path.normcase(os.path.join(UNITY_DATA, 'Managed', 'UnityEngine.dll')):
                    continue
                refs.append(p)
    for f in os.listdir(GAME_MANAGED):
        if not f.lower().endswith('.dll'):
            continue
        if f in ('Assembly-CSharp.dll', 'Magic.dll'):
            continue
        # 引擎/BCL 一律用编辑器自带的，避免 CS0433 类型重复
        if f.startswith(('UnityEngine', 'System.', 'mscorlib', 'Mono.', 'Microsoft.',
                         'Accessibility', 'netstandard', 'Windows.')):
            continue
        refs.append(os.path.join(GAME_MANAGED, f))
    # uGUI 不在 Data\Managed，取模板缓存里的 2019.4 版本
    extra = [
        r'D:\Unity\Editor\Data\Resources\PackageManager\ProjectTemplates\libcache\com.unity.template.3d-4.2.8\ScriptAssemblies\UnityEngine.UI.dll',
    ]
    for p in extra:
        if os.path.exists(p):
            refs.append(p)
    seen = {}
    for p in refs:
        seen.setdefault(os.path.basename(p).lower(), p)
    return sorted(seen.values())


dlls = collect_dlls()
lines = ['<Project Sdk="Microsoft.NET.Sdk">', '  <PropertyGroup>',
         '    <TargetFramework>net48</TargetFramework>',
         '    <AssemblyName>Assembly-CSharp</AssemblyName>',
         '    <LangVersion>latest</LangVersion>',
         '    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>',
         '    <GenerateAssemblyInfo>false</GenerateAssemblyInfo>',
         '    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>',
         '    <NoWarn>CS0108;CS0114;CS0169;CS0414;CS0649;CS1591;CS0162;CS0219;CS0067</NoWarn>',
         '    <Deterministic>true</Deterministic>',
         '  </PropertyGroup>', '  <ItemGroup>',
         f'    <Compile Include="{SRC}\\**\\*.cs" />', '  </ItemGroup>', '  <ItemGroup>']
for p in dlls:
    name = os.path.splitext(os.path.basename(p))[0]
    lines.append(f'    <Reference Include="{name}"><HintPath>{p}</HintPath><Private>false</Private></Reference>')
lines += ['  </ItemGroup>', '</Project>', '']

csproj = os.path.join(OUT, 'Assembly-CSharp.csproj')
open(csproj, 'w', encoding='utf-8').write('\n'.join(lines))
print('refs', len(dlls), 'csproj', csproj)

if len(sys.argv) > 1 and sys.argv[1] == 'build':
    r = subprocess.run(['C:/Program Files/dotnet/dotnet.exe', 'build', csproj, '-v', 'q', '--nologo'],
                       capture_output=True, text=True, encoding='utf-8', errors='replace')
    log = os.path.join(OUT, 'build.log')
    open(log, 'w', encoding='utf-8').write((r.stdout or '') + '\n' + (r.stderr or ''))
    print('rc', r.returncode)
    errs = [l for l in ((r.stdout or '') + (r.stderr or '')).splitlines() if ': error ' in l]
    print('errors', len(errs))
    for l in errs[:25]:
        print(l[:220])
