use std::env;
use std::fs::{self, OpenOptions};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

use anyhow::{bail, Context, Result};

const SCRIPT_RELATIVE_PATH: &str = "_work/launch_lobby.py";

fn workspace_from(path: &Path) -> Option<PathBuf> {
    let start = if path.is_file() { path.parent()? } else { path };
    start
        .ancestors()
        .find(|candidate| candidate.join(SCRIPT_RELATIVE_PATH).is_file())
        .map(Path::to_path_buf)
}

fn workspace_root() -> Result<PathBuf> {
    if let Some(root) = env::var_os("SSJJ_WORKSPACE_ROOT") {
        let root = PathBuf::from(root);
        if root.join(SCRIPT_RELATIVE_PATH).is_file() {
            return Ok(root);
        }
        bail!(
            "SSJJ_WORKSPACE_ROOT 指向的目录没有 {}：{}",
            SCRIPT_RELATIVE_PATH,
            root.display()
        );
    }

    if let Some(root) = env::current_exe().ok().and_then(|path| workspace_from(&path)) {
        return Ok(root);
    }
    if let Some(root) = env::current_dir().ok().and_then(|path| workspace_from(&path)) {
        return Ok(root);
    }

    bail!(
        "找不到原版大厅工作区。请从项目目录启动，或设置 SSJJ_WORKSPACE_ROOT。\n需要文件：{}",
        SCRIPT_RELATIVE_PATH
    )
}

fn log_path() -> Result<PathBuf> {
    let app_data = env::var_os("APPDATA")
        .map(PathBuf::from)
        .or_else(|| env::var_os("LOCALAPPDATA").map(PathBuf::from))
        .context("Windows 用户配置目录不可用")?;
    let directory = app_data.join("ssjj-lobby").join("logs");
    fs::create_dir_all(&directory)
        .with_context(|| format!("无法创建日志目录：{}", directory.display()))?;
    Ok(directory.join("official-lobby.log"))
}

pub fn run() -> Result<()> {
    let workspace = workspace_root()?;
    let script = workspace.join(SCRIPT_RELATIVE_PATH);
    let log_path = log_path()?;
    let stdout = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)
        .with_context(|| format!("无法写入原版大厅日志：{}", log_path.display()))?;
    let stderr = stdout
        .try_clone()
        .with_context(|| format!("无法复制大厅日志句柄：{}", log_path.display()))?;

    let python = env::var("SSJJ_PYTHON").unwrap_or_else(|_| "python".to_string());
    let mut command = Command::new(&python);
    command
        .args(["-u"])
        .arg(&script)
        .current_dir(&workspace)
        .env("PYTHONUTF8", "1")
        .env("PYTHONIOENCODING", "utf-8")
        .env("SSJJ_WORKSPACE_ROOT", &workspace)
        .stdin(Stdio::null())
        .stdout(Stdio::from(stdout))
        .stderr(Stdio::from(stderr));

    // Use the isolated SWF copied from the official Lobby, with only the
    // SmallBombCell null guard applied. All visible UI/assets remain original.
    let local_lobby = workspace
        .join("_work")
        .join("lobby_air")
        .join("Lobby_official_localfix_20261107.swf");
    if local_lobby.is_file() {
        command
            .env("SSJJ_LOBBY_SWF", &local_lobby)
            .env(
                "SSJJ_LOBBY_NAME",
                local_lobby
                    .file_name()
                    .and_then(|name| name.to_str())
                    .unwrap_or("Lobby_official_localfix.swf"),
            );
    }

    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        command.creation_flags(0x0800_0000); // CREATE_NO_WINDOW
    }

    let mut child = command.spawn().with_context(|| {
        format!(
            "无法启动原版大厅引导脚本（Python：{python}）。检查 Python/Java，并查看 {}",
            log_path.display()
        )
    })?;

    let _ = crate::launcher::append_launcher_log(&format!(
        "启动原版 AIR/SWF 大厅：script={} pid={} log={}",
        script.display(),
        child.id(),
        log_path.display()
    ));

    let status = child
        .wait()
        .with_context(|| format!("等待原版大厅退出失败；日志：{}", log_path.display()))?;
    let _ = crate::launcher::append_launcher_log(&format!(
        "原版 AIR/SWF 大厅引导进程退出：status={status}"
    ));
    if !status.success() {
        bail!(
            "原版大厅启动失败（{status}）。诊断日志：{}",
            log_path.display()
        );
    }
    Ok(())
}
