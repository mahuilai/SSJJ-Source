use std::fs;
use std::path::PathBuf;
use std::sync::{Arc, Mutex, OnceLock};
#[cfg(windows)]
use std::thread;

use anyhow::{Context, Result};
use serde::Serialize;

use crate::profile::PlayerProfile;
use crate::settings::{self, AppSettings};

pub const PIPE_NAME: &str = r"\\.\pipe\ssjj-lobby-preview-v1";
const STATE_FILE: &str = "preview_state.json";

#[derive(Debug, Serialize)]
struct PreviewState<'a> {
    schema_version: u8,
    player_name: &'a str,
    level: u16,
    rank: &'a str,
    vip_level: u8,
    character: &'a str,
    career_skin: &'a str,
    map: &'a str,
    mode: &'a str,
    active_bag: u8,
    slots: [PreviewSlot<'a>; 4],
    equipped_cosmetics: &'a [String],
    equipped_sprays: &'a [u32],
    selected_title: &'a str,
    equipped_medals: &'a [String],
}

#[derive(Debug, Serialize)]
struct PreviewSlot<'a> {
    slot: &'static str,
    weapon: &'a str,
    skin: &'a str,
}

static PIPE_STATE: OnceLock<Arc<Mutex<Vec<u8>>>> = OnceLock::new();

pub fn state_path() -> Result<PathBuf> {
    let config = settings::user_config_path()?;
    let parent = config.parent().context("大厅配置目录不存在")?;
    Ok(parent.join(STATE_FILE))
}

pub fn sync(settings: &AppSettings, profile: &PlayerProfile) -> Result<PathBuf> {
    let bag_index = settings.active_bag.saturating_sub(1) as usize;
    let bag = settings.bags.get(bag_index);
    let slots = [
        ("primary", 0),
        ("secondary", 1),
        ("melee", 2),
        ("throwable", 3),
    ]
    .map(|(slot, index)| PreviewSlot {
        slot,
        weapon: bag.map(|item| item.slot(index)).unwrap_or_default(),
        skin: bag.map(|item| item.slot_skin(index)).unwrap_or_default(),
    });

    let state = PreviewState {
        schema_version: 1,
        player_name: &profile.player_name,
        level: profile.level,
        rank: &profile.rank,
        vip_level: profile.vip_level,
        character: &settings.career,
        career_skin: &settings.career_skin,
        map: &settings.map,
        mode: &settings.mode,
        active_bag: settings.active_bag,
        slots,
        equipped_cosmetics: &profile.equipped_cosmetics,
        equipped_sprays: &profile.equipped_sprays,
        selected_title: &profile.selected_title,
        equipped_medals: &profile.equipped_medals,
    };
    let mut bytes = serde_json::to_vec_pretty(&state).context("序列化 3D 展台状态失败")?;
    bytes.push(b'\n');
    let path = state_path()?;
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("创建展台状态目录失败：{}", parent.display()))?;
    }
    settings::write_atomic(&path, bytes.clone())
        .with_context(|| format!("写入 3D 展台状态失败：{}", path.display()))?;

    let initial = bytes.clone();
    let shared = PIPE_STATE
        .get_or_init(|| {
            let shared = Arc::new(Mutex::new(initial));
            start_pipe_server(Arc::clone(&shared));
            shared
        })
        .clone();
    if let Ok(mut latest) = shared.lock() {
        *latest = bytes;
    }
    Ok(path)
}

#[cfg(windows)]
fn start_pipe_server(state: Arc<Mutex<Vec<u8>>>) {
    thread::Builder::new()
        .name("ssjj-preview-pipe".to_owned())
        .spawn(move || windows_pipe::serve(state))
        .ok();
}

#[cfg(not(windows))]
fn start_pipe_server(_state: Arc<Mutex<Vec<u8>>>) {}

#[cfg(windows)]
mod windows_pipe {
    use std::ffi::c_void;
    use std::ptr;
    use std::sync::{Arc, Mutex};
    use std::thread;
    use std::time::Duration;

    use super::PIPE_NAME;

    type Handle = *mut c_void;
    const PIPE_ACCESS_OUTBOUND: u32 = 0x0000_0002;
    const ERROR_PIPE_CONNECTED: u32 = 535;

    #[link(name = "kernel32")]
    extern "system" {
        fn CreateNamedPipeW(
            name: *const u16,
            open_mode: u32,
            pipe_mode: u32,
            max_instances: u32,
            out_buffer_size: u32,
            in_buffer_size: u32,
            default_timeout: u32,
            security_attributes: *mut c_void,
        ) -> Handle;
        fn ConnectNamedPipe(pipe: Handle, overlapped: *mut c_void) -> i32;
        fn WriteFile(
            file: Handle,
            buffer: *const c_void,
            bytes_to_write: u32,
            bytes_written: *mut u32,
            overlapped: *mut c_void,
        ) -> i32;
        fn DisconnectNamedPipe(pipe: Handle) -> i32;
        fn FlushFileBuffers(file: Handle) -> i32;
        fn CloseHandle(handle: Handle) -> i32;
        fn GetLastError() -> u32;
    }

    pub(super) fn serve(state: Arc<Mutex<Vec<u8>>>) {
        let name: Vec<u16> = PIPE_NAME.encode_utf16().chain(std::iter::once(0)).collect();
        loop {
            let pipe = unsafe {
                CreateNamedPipeW(
                    name.as_ptr(),
                    PIPE_ACCESS_OUTBOUND,
                    0,
                    1,
                    64 * 1024,
                    1,
                    0,
                    ptr::null_mut(),
                )
            };
            if pipe.is_null() || pipe as isize == -1 {
                thread::sleep(Duration::from_millis(500));
                continue;
            }

            let connect_result = unsafe { ConnectNamedPipe(pipe, ptr::null_mut()) };
            let connect_error = if connect_result == 0 {
                unsafe { GetLastError() }
            } else {
                0
            };
            let connected = connect_result != 0 || connect_error == ERROR_PIPE_CONNECTED;
            if connected {
                let bytes = state
                    .lock()
                    .map(|latest| latest.clone())
                    .unwrap_or_default();
                let mut written = 0;
                if !bytes.is_empty() {
                    let result = unsafe {
                        WriteFile(
                            pipe,
                            bytes.as_ptr().cast(),
                            bytes.len().min(u32::MAX as usize) as u32,
                            &mut written,
                            ptr::null_mut(),
                        )
                    };
                    if result == 0 || written as usize != bytes.len() {
                        let error = unsafe { GetLastError() };
                        let _ = crate::launcher::append_launcher_log(&format!(
                            "PreviewBridge named-pipe write failed: error={error}, written={written}, expected={}",
                            bytes.len()
                        ));
                    } else {
                        unsafe { FlushFileBuffers(pipe) };
                        let _ = crate::launcher::append_launcher_log(&format!(
                            "PreviewBridge sent {} bytes through {PIPE_NAME}",
                            bytes.len()
                        ));
                    }
                } else {
                    let _ = crate::launcher::append_launcher_log(
                        "PreviewBridge accepted a pipe client with empty state",
                    );
                }
                unsafe {
                    DisconnectNamedPipe(pipe);
                }
            } else {
                let _ = crate::launcher::append_launcher_log(&format!(
                    "PreviewBridge named-pipe connect failed: error={connect_error}"
                ));
            }
            unsafe {
                CloseHandle(pipe);
            }
        }
    }
}
