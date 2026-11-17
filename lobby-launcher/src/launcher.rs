use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, ExitStatus, Stdio};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc::{self, Receiver, TryRecvError};
use std::sync::Arc;
use std::thread;
use std::time::{Duration, Instant};
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{bail, Context, Result};
use serde::Serialize;

use crate::settings::{launch_config_path, map_config_id, write_atomic, AppSettings, BagLoadout};

const GAME_PROCESS: &str = "SSJJ_BattleClient_Unity.exe";
const GAME_START_GRACE: Duration = Duration::from_secs(2);
const SCRIPT_EXIT_GRACE: Duration = Duration::from_secs(30);
const GAME_EXIT_GRACE: Duration = Duration::from_millis(2500);
const CREATE_NO_WINDOW: u32 = 0x0800_0000;

#[derive(Debug, Serialize)]
struct LaunchConfig<'a> {
    map: &'a str,
    mode: &'a str,
    career: &'a str,
    hand: &'a str,
    weapon: &'a str,
    /// [PATCH] 武器皮肤（weaponskin/<key>），空 = 默认皮肤。
    weapon_skin: &'a str,
    weapon_skin_weapon: &'a str,
    /// [PATCH] 角色皮肤（playerskin/<key>），空 = 默认皮肤。
    career_skin: &'a str,
    bot_count: u8,
    ally_bot_count: u8,
    enemy_bot_count: u8,
    bot_difficulty: &'a str,
    bot_career: &'a str,
    god_mode: bool,
    spawn: [f32; 3],
    active_bag: u8,
    bags: &'a [BagLoadout],
}

pub struct SpawnedLaunch {
    pub child: Child,
}

pub fn launcher_log_path() -> Result<PathBuf> {
    let config = crate::settings::user_config_path()?;
    let parent = config
        .parent()
        .context("大厅配置目录不存在，无法创建日志目录")?;
    Ok(parent.join("logs").join("launcher.log"))
}

pub(crate) fn append_launcher_log(message: &str) -> Result<()> {
    let path = launcher_log_path()?;
    let parent = path.parent().context("日志文件没有父目录")?;
    fs::create_dir_all(parent)
        .with_context(|| format!("创建日志目录失败：{}", parent.display()))?;
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&path)
        .with_context(|| format!("打开启动日志失败：{}", path.display()))?;
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();
    writeln!(file, "[{timestamp}] {message}")
        .with_context(|| format!("写入启动日志失败：{}", path.display()))
}

pub fn start_game(settings: &AppSettings) -> Result<SpawnedLaunch> {
    let _ = append_launcher_log(&format!(
        "启动请求：map={} mode={} career={} bag={}",
        settings.map, settings.mode, settings.career, settings.active_bag
    ));
    if settings.game_dir.trim().is_empty() {
        bail!("游戏目录为空，请先在设置里填写");
    }
    if !settings.map.starts_with("maps/") && !settings.map.starts_with("unitymaps/") {
        bail!("地图 key 不合法：{}", settings.map);
    }

    let config_path = write_launch_config(settings)?;
    let _ = append_launcher_log(&format!("启动配置已写入：{}", config_path.display()));

    // [PATCH] 全地图切换：选中地图不在客户端 manifest 里时，先自动安装再启动。
    // install_map.py 负责拷包 + 写 manifest 条目（ET 校验 + 备份回滚 + 幂等）。
    ensure_map_installed(settings)?;

    let script = PathBuf::from(settings.start_script.trim());
    if !script.is_file() {
        bail!("找不到启动脚本：{}，请在设置里检查路径", script.display());
    }
    let working_dir = script.parent().unwrap_or_else(|| Path::new("."));
    let python = if settings.python.trim().is_empty() {
        "python"
    } else {
        settings.python.trim()
    };

    let mut command = Command::new(python);
    let log_path = launcher_log_path()?;
    let log_parent = log_path.parent().context("日志文件没有父目录")?;
    fs::create_dir_all(log_parent)
        .with_context(|| format!("创建日志目录失败：{}", log_parent.display()))?;
    let stdout_log = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)
        .with_context(|| format!("打开启动日志失败：{}", log_path.display()))?;
    let stderr_log = stdout_log
        .try_clone()
        .with_context(|| format!("复制启动日志句柄失败：{}", log_path.display()))?;
    command
        .arg(&script)
        .current_dir(working_dir)
        .env("SSJJ_BUNDLE_ROOT", crate::settings::bundle_root())
        .env("SSJJ_GAME_DIR", settings.game_dir.trim())
        .env("PYTHONUTF8", "1")
        .env("PYTHONIOENCODING", "utf-8")
        .stdin(Stdio::null())
        .stdout(Stdio::from(stdout_log))
        .stderr(Stdio::from(stderr_log));
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        command.creation_flags(CREATE_NO_WINDOW);
    }

    let child = command.spawn().with_context(|| {
        format!("无法调用 Python（{python}），请确认已安装或在设置里填写 python.exe 完整路径")
    })?;
    let _ = append_launcher_log(&format!(
        "启动脚本已创建：python={} script={} pid={:?}",
        python,
        script.display(),
        child.id()
    ));

    Ok(SpawnedLaunch { child })
}

pub fn write_launch_config(settings: &AppSettings) -> Result<PathBuf> {
    let path = launch_config_path(settings);
    let value = launch_config_value(settings);
    let mut bytes = serde_json::to_vec_pretty(&value).context("序列化启动配置失败")?;
    bytes.push(b'\n');
    write_atomic(&path, bytes).with_context(|| format!("写入启动配置失败：{}", path.display()))?;
    let _ = append_launcher_log(&format!("launch_config 写入成功：{}", path.display()));
    Ok(path)
}

fn launch_config_value(settings: &AppSettings) -> LaunchConfig<'_> {
    LaunchConfig {
        map: map_config_id(&settings.map),
        mode: &settings.mode,
        career: &settings.career,
        hand: &settings.hand,
        weapon: &settings.weapon,
        weapon_skin: &settings.weapon_skin,
        weapon_skin_weapon: &settings.weapon_skin_weapon,
        career_skin: &settings.career_skin,
        // [PATCH] bot_count 始终等于队友+敌人（3+4=7，远低于旧的 12 上限），
        // 避免设置页改过 stepper 后这里写入过期的合计值。
        bot_count: settings.bot_total().min(12),
        ally_bot_count: settings.ally_bot_count,
        enemy_bot_count: settings.enemy_bot_count,
        bot_difficulty: &settings.bot_difficulty,
        bot_career: &settings.bot_career,
        god_mode: settings.god_mode,
        spawn: settings.spawn,
        active_bag: settings.active_bag,
        bags: &settings.bags,
    }
}

/// [PATCH] 全地图切换：启动前确保选中地图已装进客户端 manifest。
///
/// - 只处理 `maps/map<数字>` 命名；其它（unitymaps 等）跳过。
/// - manifest 里已有 `name="maps/mapN"` 条目就直接放行（幂等，零开销）。
/// - 否则调用 install_map.py --scene-id N（拷包 + 写 manifest 条目，
///   脚本内部有 ET 校验 + 备份回滚 + 幂等）。
/// - 返回 Ok(false) 表示跳过（脚本未配置或非标准命名），Ok(true) 表示已就绪。
fn ensure_map_installed(settings: &AppSettings) -> Result<bool> {
    let script = settings.map_install_script.trim();
    if script.is_empty() {
        return Ok(false);
    }
    let script_path = PathBuf::from(script);
    if !script_path.is_file() {
        bail!(
            "找不到地图安装脚本：{}，请在设置里检查路径",
            script_path.display()
        );
    }

    let id = map_config_id(&settings.map);
    let Some(scene_id) = id
        .strip_prefix("map")
        .and_then(|rest| rest.parse::<u32>().ok())
    else {
        return Ok(false);
    };
    let bundle_name = format!("maps/map{scene_id}");

    let bundle_root = Path::new(settings.game_dir.trim())
        .join("SSJJ_BattleClient_Unity_Data")
        .join("StreamingAssets")
        .join("AssetBundles")
        .join("Windows");
    let manifest = bundle_root.join("AssetBundles");
    if manifest.is_file() {
        if let Ok(text) = fs::read_to_string(&manifest) {
            if let Some(md5) = manifest_bundle_md5(&text, &bundle_name) {
                let installed_bundle = bundle_root.join(format!("{bundle_name}_{md5}"));
                if installed_bundle.is_file() {
                    let _ = append_launcher_log(&format!(
                        "地图已安装：{bundle_name}（{}）",
                        installed_bundle.display()
                    ));
                    return Ok(true);
                }
            }
        }
    }

    let python = if settings.python.trim().is_empty() {
        "python"
    } else {
        settings.python.trim()
    };
    let mut command = Command::new(python);
    command
        .arg(&script_path)
        .arg("--scene-id")
        .arg(scene_id.to_string())
        .arg("--client-root")
        .arg(settings.game_dir.trim())
        .env("SSJJ_BUNDLE_ROOT", crate::settings::bundle_root())
        .env("SSJJ_GAME_DIR", settings.game_dir.trim())
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped());
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        command.creation_flags(CREATE_NO_WINDOW);
    }

    let output = command
        .output()
        .with_context(|| format!("无法调用地图安装脚本（{python} {script}）"))?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    let _ = append_launcher_log(&format!(
        "地图安装器退出：scene_id={} status={:?}\nstdout:\n{}\nstderr:\n{}",
        scene_id,
        output.status.code(),
        stdout.trim(),
        stderr.trim()
    ));
    if !output.status.success() {
        bail!(
            "地图 {bundle_name} 自动安装失败（退出码 {:?}）：{} {}；日志：{}",
            output.status.code(),
            stdout.trim(),
            stderr.trim(),
            launcher_log_path()?.display()
        );
    }
    Ok(true)
}

fn manifest_bundle_md5<'a>(manifest: &'a str, bundle_name: &str) -> Option<&'a str> {
    for entry in manifest.split("<AssetBundle") {
        let Some(name) = xml_attribute(entry, "name") else {
            continue;
        };
        if name == bundle_name {
            return xml_attribute(entry, "md5");
        }
    }
    None
}

fn xml_attribute<'a>(element: &'a str, key: &str) -> Option<&'a str> {
    let needle = format!("{key}=\"");
    element.split_once(&needle)?.1.split('"').next()
}

#[derive(Debug, Clone)]
pub enum LaunchPhase {
    Idle,
    Launching { started: Instant },
    Running { since: Instant },
    Failed { message: String },
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MonitorEvent {
    GameStarted,
    GameExited,
}

pub struct LaunchMonitor {
    phase: LaunchPhase,
    child: Option<Child>,
    script_status: Option<ExitStatus>,
    watcher: ProcessWatcher,
    saw_game_absent: bool,
    game_missing_since: Option<Instant>,
}

impl LaunchMonitor {
    pub fn new() -> Self {
        Self {
            phase: LaunchPhase::Idle,
            child: None,
            script_status: None,
            watcher: ProcessWatcher::new(),
            saw_game_absent: false,
            game_missing_since: None,
        }
    }

    pub fn phase(&self) -> &LaunchPhase {
        &self.phase
    }

    pub fn is_busy(&self) -> bool {
        matches!(
            self.phase,
            LaunchPhase::Launching { .. } | LaunchPhase::Running { .. }
        )
    }

    pub fn launch(&mut self, settings: &AppSettings) -> Result<()> {
        if self.is_busy() {
            bail!("游戏正在启动或运行中");
        }

        match start_game(settings) {
            Ok(spawned) => {
                self.child = Some(spawned.child);
                self.script_status = None;
                self.saw_game_absent = false;
                self.game_missing_since = None;
                self.phase = LaunchPhase::Launching {
                    started: Instant::now(),
                };
                Ok(())
            }
            Err(err) => {
                let message = format!("{err:#}");
                let _ = append_launcher_log(&format!("启动失败：{message}"));
                self.phase = LaunchPhase::Failed {
                    message: message.clone(),
                };
                bail!(message);
            }
        }
    }

    pub fn poll(&mut self) -> Option<MonitorEvent> {
        let game_running = self.watcher.poll();

        if let Some(child) = self.child.as_mut() {
            match child.try_wait() {
                Ok(Some(status)) => {
                    self.script_status = Some(status);
                    self.child = None;
                }
                Ok(None) => {}
                Err(err) => {
                    self.child = None;
                    self.phase = LaunchPhase::Failed {
                        message: format!("无法读取启动脚本状态：{err}"),
                    };
                    return None;
                }
            }
        }

        match self.phase {
            LaunchPhase::Launching { started } => {
                if !game_running {
                    self.saw_game_absent = true;
                }

                if let Some(status) = self.script_status {
                    if !status.success() {
                        let _ =
                            append_launcher_log(&format!("start_offline.py 异常退出：{status}"));
                        self.phase = LaunchPhase::Failed {
                            message: format!(
                                "start_offline.py 异常退出（{status}），请查看游戏目录 log\\launcher.log"
                            ),
                        };
                        return None;
                    }
                }

                if game_running && (self.saw_game_absent || started.elapsed() >= GAME_START_GRACE) {
                    let _ = append_launcher_log("战斗客户端进程已启动");
                    self.phase = LaunchPhase::Running {
                        since: Instant::now(),
                    };
                    self.game_missing_since = None;
                    return Some(MonitorEvent::GameStarted);
                }

                if self.script_status.is_some_and(|status| status.success())
                    && !game_running
                    && started.elapsed() >= SCRIPT_EXIT_GRACE
                {
                    self.phase = LaunchPhase::Failed {
                        message: format!(
                            "等待游戏进程超时（{}），请查看 log\\launcher.log 与 log\\offline.log",
                            GAME_PROCESS
                        ),
                    };
                }
            }
            LaunchPhase::Running { .. } => {
                if game_running {
                    self.game_missing_since = None;
                } else {
                    let missing_since = *self.game_missing_since.get_or_insert_with(Instant::now);
                    if missing_since.elapsed() >= GAME_EXIT_GRACE {
                        let _ = append_launcher_log("战斗客户端进程已退出");
                        self.phase = LaunchPhase::Idle;
                        self.game_missing_since = None;
                        return Some(MonitorEvent::GameExited);
                    }
                }
            }
            LaunchPhase::Idle | LaunchPhase::Failed { .. } => {}
        }

        None
    }
}

struct ProcessWatcher {
    receiver: Receiver<bool>,
    latest: bool,
    stop: Arc<AtomicBool>,
}

impl ProcessWatcher {
    fn new() -> Self {
        let (sender, receiver) = mpsc::channel();
        let stop = Arc::new(AtomicBool::new(false));
        let thread_stop = Arc::clone(&stop);

        thread::spawn(move || {
            while !thread_stop.load(Ordering::Relaxed) {
                let running = game_process_running();
                if sender.send(running).is_err() {
                    break;
                }
                for _ in 0..12 {
                    if thread_stop.load(Ordering::Relaxed) {
                        return;
                    }
                    thread::sleep(Duration::from_millis(100));
                }
            }
        });

        Self {
            receiver,
            latest: false,
            stop,
        }
    }

    fn poll(&mut self) -> bool {
        loop {
            match self.receiver.try_recv() {
                Ok(value) => self.latest = value,
                Err(TryRecvError::Empty) | Err(TryRecvError::Disconnected) => break,
            }
        }
        self.latest
    }
}

impl Drop for ProcessWatcher {
    fn drop(&mut self) {
        self.stop.store(true, Ordering::Relaxed);
    }
}

fn game_process_running() -> bool {
    let mut command = Command::new("tasklist");
    command
        .args([
            "/FI",
            &format!("IMAGENAME eq {GAME_PROCESS}"),
            "/NH",
            "/FO",
            "CSV",
        ])
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::null());
    #[cfg(windows)]
    {
        use std::os::windows::process::CommandExt;
        command.creation_flags(CREATE_NO_WINDOW);
    }

    let Ok(output) = command.output() else {
        return false;
    };
    String::from_utf8_lossy(&output.stdout)
        .to_ascii_lowercase()
        .contains(&GAME_PROCESS.to_ascii_lowercase())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn launch_json_matches_the_contract_exactly() {
        let settings = AppSettings::default();
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["map"], "map1");
        assert_eq!(value["mode"], "team");
        assert_eq!(value["career"], "police");
        assert_eq!(value["hand"], "man");
        assert_eq!(value["weapon"], "ak47");
        // [PATCH] 人机团战默认编制 3 队友 / 4 敌人，bot_count 为两者之和。
        assert_eq!(value["bot_count"], 7);
        assert_eq!(value["ally_bot_count"], 3);
        assert_eq!(value["enemy_bot_count"], 4);
        assert_eq!(value["bot_career"], "terrorist");
        assert_eq!(value["god_mode"], false);
        assert_eq!(value["spawn"], serde_json::json!([0.0, 0.0, 0.0]));
        assert_eq!(value["active_bag"], 1);
        assert_eq!(value["bags"].as_array().unwrap().len(), 5);
        assert_eq!(value["bags"][0]["primary"], "ak47");
        assert_eq!(value["bags"][0]["secondary"], "deagle");
        assert_eq!(value["bags"][0]["melee"], "nbr_knife_g");
        assert_eq!(value["bags"][0]["throwable"], "grenade");
        // [PATCH] 每槽皮肤字段（空 = 默认外观）。
        assert_eq!(value["bags"][0]["primary_skin"], "");
        assert_eq!(value["bags"][0]["secondary_skin"], "");
        assert_eq!(value["bags"][0]["melee_skin"], "");
        assert_eq!(value["bags"][0]["throwable_skin"], "");
        // [PATCH] weapon_skin / weapon_skin_weapon / career_skin 字段。
        assert_eq!(value["weapon_skin"], "");
        assert_eq!(value["weapon_skin_weapon"], "");
        assert_eq!(value["career_skin"], "");
        assert_eq!(value.as_object().unwrap().len(), 17);
    }

    #[test]
    fn per_bag_skins_are_written_independently() {
        let mut settings = AppSettings::default();
        settings.bags[0].primary_skin = "skin_ak47_g_12years".to_owned();
        settings.bags[1].primary_skin = "skin_abyss_blade_lava".to_owned();
        settings.bags[1].secondary_skin = "skin_abyss_pistol_blood".to_owned();
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["bags"][0]["primary_skin"], "skin_ak47_g_12years");
        assert_eq!(value["bags"][0]["secondary_skin"], "");
        assert_eq!(value["bags"][1]["primary_skin"], "skin_abyss_blade_lava");
        assert_eq!(
            value["bags"][1]["secondary_skin"],
            "skin_abyss_pistol_blood"
        );
        assert_eq!(value["bags"][2]["primary_skin"], "");
        // 换背包不会串皮肤：切 active_bag 只换背包，不改各槽皮肤。
        settings.active_bag = 2;
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["active_bag"], 2);
        assert_eq!(value["bags"][0]["primary_skin"], "skin_ak47_g_12years");
        assert_eq!(value["bags"][1]["primary_skin"], "skin_abyss_blade_lava");
    }

    #[test]
    fn skins_are_written_to_launch_config() {
        let mut settings = AppSettings::default();
        settings.weapon_skin = "skin_ak47_g_12years".to_owned();
        settings.career_skin = "ares2".to_owned();
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["weapon_skin"], "skin_ak47_g_12years");
        assert_eq!(value["career_skin"], "ares2");
    }

    #[test]
    fn map_package_is_written_as_short_id() {
        let mut settings = AppSettings::default();
        settings.map = "maps/map43".to_owned();
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["map"], "map43");
    }

    #[test]
    fn launch_json_bot_count_is_ally_plus_enemy() {
        let mut settings = AppSettings::default();
        settings.ally_bot_count = 3;
        settings.enemy_bot_count = 4;
        // 旧的 bot_count 即使过期也不影响写出的合计值。
        settings.bot_count = 2;
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["ally_bot_count"], 3);
        assert_eq!(value["enemy_bot_count"], 4);
        assert_eq!(value["bot_count"], 7);
        // 3+4=7 不会被旧的 12 上限裁剪。
        assert_eq!(
            value["bot_count"].as_u64().unwrap(),
            value["ally_bot_count"].as_u64().unwrap() + value["enemy_bot_count"].as_u64().unwrap()
        );

        // 只带队友同样如实写出 enemy_bot_count=0。
        settings.ally_bot_count = 2;
        settings.enemy_bot_count = 0;
        let value = serde_json::to_value(launch_config_value(&settings)).unwrap();
        assert_eq!(value["bot_count"], 2);
        assert_eq!(value["ally_bot_count"], 2);
        assert_eq!(value["enemy_bot_count"], 0);
    }
}
