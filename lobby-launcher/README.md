# SSJJ 原版 AIR/SWF 大厅启动器

Rust 程序只负责启动与监控。默认入口不再绘制大厅界面，也不再打开 Edge 页面；可见大厅由官方 AIR 预加载器和原版 `Lobby.swf` 提供。原版 UI、动画、组件与交互资源必须从本机官方大厅安装和资源目录读取。

当前默认启动依赖工作区中的 `_work/launch_lobby.py`。该脚本会准备本地资源网关与 AMF3 兼容进程，再启动 AIR。界面渲染使用原版 SWF，但启动链目前仍依赖这些本地兼容进程；不要把它描述成无服务进程版本。

旧 Rust/Edge 页面仅能通过 `--legacy` 显式启动，属于保留的演示/回退代码，不是原版大厅入口。

## 开发环境

- Windows 10/11 x64
- Rust stable（MSVC 工具链）与 Cargo
- Visual Studio Build Tools 的 C++ 桌面组件（Rust Windows GNU 工具链也可自行配置）
- Python 3.8 或更新版本、Java：默认启动原版 AIR 大厅时需要

## 拉取后构建

```powershell
cd lobby-launcher
cargo build
cargo run
```

发布构建：

```powershell
python tools/build_release.py
```

输出位于 `dist/`。`data/asset_inventory.json` 和 `data/official_lobby_preview_index.json` 是构建必需的文本索引，已纳入仓库；官方预览 PNG 和完整战斗资源因版权与体积限制不纳入 Git。

## 本地资源

默认入口需要完整本地工作区、官方 AIR 运行时和大厅资源。若 Rust 程序无法自动找到 `_work/launch_lobby.py`，可设置 `SSJJ_WORKSPACE_ROOT` 指定工作区根目录；Python 可通过 `SSJJ_PYTHON` 指定。启动诊断日志写入 `%APPDATA%\ssjj-lobby\logs\official-lobby.log`。

若要启动战斗，需要在本机准备合法取得的资源：

- 官方大厅预览图：放在 `data/previews/official_lobby/`；使用本地大厅资源时，可运行 `python tools/extract_official_lobby_previews.py` 重新提取。该工具需要 Pillow；若本地有 Java 和 AMF3 解码器，还会补充仓库排序元数据。
- 战斗客户端：完整的 `battle/3_64` 目录。
- 全量资源包：资源全集与资源缓存，以及对应的 `_manifest_cache.xml`。

客户端资源必须由使用者自行准备，仓库不提供官方游戏二进制。

### 大厅目录数据来源

默认启动路径的武器、角色、皮肤和地图目录由 `tools/generate_lobby_dataset.py` 生成：武器、角色和皮肤来自本地官方大厅 `GameData` AMF3 表导出，预览键来自原版大厅 SWF 图标索引。该默认页面不从 `asset_inventory.json` 读取大厅目录；该旧清单仅保留给显式 `--legacy` 页面。当前地图中文名尚未从大厅本地化表还原时，会显示地图 ID，避免把战斗端目录名称冒充大厅名称。

重新生成目录：

```powershell
python tools/generate_lobby_dataset.py
```

## 运行配置

大厅设置保存在 `%APPDATA%\ssjj-lobby\config.json`，战斗启动配置写入所选客户端的 `launch_config.json`。便携发行包通过同目录 `启动器引导.ps1` 将客户端、脚本和 Python 路径指向解压目录；开发者也可在大厅“设置”页配置本地路径。

## 创建双启动器便携包

便携 ZIP 含当前 Rust 大厅、旧版大厅、离线客户端、Python 运行时、地图/角色/武器资源与预览图，解压后分别双击：

- `启动新版大厅.bat`
- `启动原始版大厅.bat`

生成发行包需要本地已有完整授权资源和 7-Zip。默认从工作区查找 `资源全集/`、`资源缓存/`、`_manifest_cache.xml`，从工作区所在磁盘根目录的 `SSJJ-4399/` 查找战斗客户端；可通过环境变量覆盖路径：`SSJJ_GAME_ROOT`、`SSJJ_RESOURCE_POOL`、`SSJJ_RESOURCE_CACHE`、`SSJJ_OFFICIAL_MANIFEST`、`SSJJ_PYTHON_RUNTIME`。

```powershell
python tools/build_release.py
python tools/package_portable.py
```

完整资源包约 20 GiB；输出是 ZIP64。发行包含官方版权资源，仅用于个人离线研究和本地使用，不要公开上传到 GitHub。

## 目录结构

```text
src/                 Rust UI、资源索引、配置持久化和启动器
data/                构建需要的文本索引；运行预览为本地资源
assets/icon.png      应用图标
portable/scripts/    可移植的 Python 启动与资源安装脚本
tools/               构建、资源提取与便携包组装工具
dist/                本地发行产物（已加入 Git 忽略规则）
```

## 离线边界

联网专属的好友、军团、商城等服务不会伪造成功响应；战斗支持范围取决于本地客户端已有的离线实现和资源。大厅中的资源解锁与客户端可加载性是两个不同状态。
