use std::env;
use std::fs;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::thread;

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tiny_http::{Header, Method, Response, Server, StatusCode};

use crate::launcher;
use crate::profile::PlayerProfile;
use crate::settings::AppSettings;

const EMBEDDED_LOBBY_DATA: &str = include_str!("../data/official_lobby_dataset.json");

#[derive(Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct WeaponDto {
    pub id: u32,
    pub key: String,
    pub name: String,
    pub category: String,
    pub category_name: String,
    pub quality_tag: String,
    pub background: String,
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct CharacterDto {
    pub key: String,
    pub name: String,
    pub faction: String,
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct GameMapDto {
    pub key: String,
    pub name: String,
    pub category: String,
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct InventoryDto {
    pub weapons: Vec<WeaponDto>,
    pub characters: Vec<CharacterDto>,
    pub maps: Vec<GameMapDto>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EquipWeaponReq {
    pub bag_index: usize,
    pub slot_index: usize,
    pub weapon_key: String,
    pub skin_key: Option<String>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EquipCharacterReq {
    pub career_key: String,
    pub skin_key: Option<String>,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct SetActiveBagReq {
    pub bag_index: u8,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LaunchCombatReq {
    pub map: String,
    pub mode: String,
    pub career: String,
    pub active_bag: u8,
    pub ally_bot_count: u8,
    pub enemy_bot_count: u8,
    pub bot_difficulty: String,
    pub god_mode: bool,
}

pub struct AppState {
    pub settings: Mutex<AppSettings>,
    pub profile: Mutex<PlayerProfile>,
    pub inventory_dto: InventoryDto,
    pub dist_dir: PathBuf,
}

pub fn start_server(
    settings: AppSettings,
    profile: PlayerProfile,
) -> Result<u16> {
    // 1. Locate dist-ui folder robustly
    let mut candidate_dirs = Vec::new();

    if let Ok(exe) = env::current_exe() {
        if let Some(exe_dir) = exe.parent() {
            candidate_dirs.push(exe_dir.join("dist-ui"));
            candidate_dirs.push(exe_dir.join("../dist-ui"));
            candidate_dirs.push(exe_dir.join("../../lobby-launcher/dist-ui"));
        }
    }
    if let Ok(cwd) = env::current_dir() {
        candidate_dirs.push(cwd.join("dist-ui"));
        candidate_dirs.push(cwd.join("lobby-launcher/dist-ui"));
        candidate_dirs.push(cwd.join("lobby-launcher/dist/dist-ui"));
    }
    candidate_dirs.push(PathBuf::from(r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\dist-ui"));
    candidate_dirs.push(PathBuf::from(r"D:\逆向\SSJJ双塔惊魂\dist-ui"));

    let dist_dir = candidate_dirs
        .into_iter()
        .find(|p| p.join("index.html").is_file())
        .unwrap_or_else(|| PathBuf::from("dist-ui"));

    eprintln!("[Lobby] Frontend dist-ui located at: {}", dist_dir.display());

    // 2. Parse official lobby dataset (2,056 weapons, 335 characters from official lobby tables)
    let inventory_dto: InventoryDto = serde_json::from_str(EMBEDDED_LOBBY_DATA)
        .unwrap_or_else(|_| InventoryDto {
            weapons: vec![],
            characters: vec![],
            maps: vec![],
        });

    let state = Arc::new(AppState {
        settings: Mutex::new(settings),
        profile: Mutex::new(profile),
        inventory_dto,
        dist_dir,
    });

    let server = Server::http("127.0.0.1:9099")
        .or_else(|_| Server::http("127.0.0.1:0"))
        .map_err(|e| anyhow::anyhow!("绑定 HTTP 服务端口失败: {e}"))?;

    let port = server.server_addr().to_ip().map(|a| a.port()).unwrap_or(9099);
    eprintln!("[Lobby] HTTP Server listening at http://127.0.0.1:{port}");

    let state_clone = Arc::clone(&state);
    thread::spawn(move || {
        for request in server.incoming_requests() {
            let state_ref = Arc::clone(&state_clone);
            thread::spawn(move || {
                let _ = handle_request(request, &state_ref);
            });
        }
    });

    Ok(port)
}

fn handle_request(mut req: tiny_http::Request, state: &Arc<AppState>) -> Result<()> {
    let url = req.url().to_string();
    let path = url.split('?').next().unwrap_or("/");

    let json_header = Header::from_bytes(&b"Content-Type"[..], &b"application/json; charset=utf-8"[..]).unwrap();
    let cors_header = Header::from_bytes(&b"Access-Control-Allow-Origin"[..], &b"*"[..]).unwrap();

    // 1. APIs
    if path == "/api/inventory" && req.method() == &Method::Get {
        let json = serde_json::to_vec(&state.inventory_dto)?;
        let mut resp = Response::from_data(json);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/profile" && req.method() == &Method::Get {
        let prof = state.profile.lock().unwrap();
        let sett = state.settings.lock().unwrap();
        let json = serde_json::json!({
            "playerName": prof.player_name,
            "level": prof.level,
            "vipLv": prof.vip_level,
            "rank": prof.rank,
            "active_bag": sett.active_bag,
            "career": sett.career,
            "bags": sett.bags,
        });
        let mut resp = Response::from_data(serde_json::to_vec(&json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/profile/equip_weapon" && req.method() == &Method::Post {
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body)?;
        let parsed: EquipWeaponReq = serde_json::from_str(&body)?;

        let mut sett = state.settings.lock().unwrap();
        if parsed.bag_index < sett.bags.len() {
            let bag = &mut sett.bags[parsed.bag_index];
            match parsed.slot_index {
                0 => bag.primary = parsed.weapon_key.clone(),
                1 => bag.secondary = parsed.weapon_key.clone(),
                2 => bag.melee = parsed.weapon_key.clone(),
                3 => bag.throwable = parsed.weapon_key.clone(),
                _ => {}
            }
            if let Some(skin) = parsed.skin_key {
                match parsed.slot_index {
                    0 => bag.primary_skin = skin,
                    1 => bag.secondary_skin = skin,
                    2 => bag.melee_skin = skin,
                    3 => bag.throwable_skin = skin,
                    _ => {}
                }
            }
            let _ = sett.save();
        }

        let resp_json = serde_json::json!({ "success": true });
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/profile/equip_character" && req.method() == &Method::Post {
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body)?;
        let parsed: EquipCharacterReq = serde_json::from_str(&body)?;

        let mut sett = state.settings.lock().unwrap();
        sett.career = parsed.career_key;
        if let Some(skin) = parsed.skin_key {
            sett.career_skin = skin;
        }
        let _ = sett.save();

        let resp_json = serde_json::json!({ "success": true });
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/profile/set_active_bag" && req.method() == &Method::Post {
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body)?;
        let parsed: SetActiveBagReq = serde_json::from_str(&body)?;

        let mut sett = state.settings.lock().unwrap();
        sett.active_bag = parsed.bag_index;
        let _ = sett.save();

        let resp_json = serde_json::json!({ "success": true });
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/settings" && req.method() == &Method::Get {
        let sett = state.settings.lock().unwrap();
        let mut resp = Response::from_data(serde_json::to_vec(&*sett)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/settings/save" && req.method() == &Method::Post {
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body)?;
        let new_sett: AppSettings = serde_json::from_str(&body)?;
        let mut sett = state.settings.lock().unwrap();
        *sett = new_sett;
        let _ = sett.save();

        let resp_json = serde_json::json!({ "success": true });
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/launch/combat" && req.method() == &Method::Post {
        let mut body = String::new();
        req.as_reader().read_to_string(&mut body)?;
        let parsed: LaunchCombatReq = serde_json::from_str(&body)?;

        let mut sett = state.settings.lock().unwrap();
        sett.map = parsed.map;
        sett.mode = parsed.mode;
        sett.career = parsed.career;
        sett.active_bag = parsed.active_bag;
        sett.ally_bot_count = parsed.ally_bot_count;
        sett.enemy_bot_count = parsed.enemy_bot_count;
        sett.bot_difficulty = parsed.bot_difficulty;
        sett.god_mode = parsed.god_mode;
        let _ = sett.save();

        let launch_res = launcher::start_game(&sett);
        let resp_json = match launch_res {
            Ok(_) => serde_json::json!({ "success": true, "message": "战斗进程已拉起" }),
            Err(e) => serde_json::json!({ "success": false, "error": e.to_string() }),
        };
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    if path == "/api/launch/flash_lobby" && req.method() == &Method::Post {
        let exe_rebuild = PathBuf::from(r"D:\逆向\SSJJ双塔惊魂\offline-lobby-rebuild\dist\启动离线大厅.bat");
        let script_official = PathBuf::from(r"D:\逆向\SSJJ双塔惊魂\_work\launch_lobby.py");

        let res = if exe_rebuild.is_file() {
            std::process::Command::new("cmd")
                .args(["/c", "start", "", exe_rebuild.to_str().unwrap()])
                .current_dir(exe_rebuild.parent().unwrap())
                .spawn()
        } else if script_official.is_file() {
            std::process::Command::new("python")
                .arg(&script_official)
                .current_dir(script_official.parent().unwrap())
                .spawn()
        } else {
            Err(std::io::Error::new(std::io::ErrorKind::NotFound, "未找到原版大厅启动脚本"))
        };

        let resp_json = match res {
            Ok(_) => serde_json::json!({ "success": true, "message": "原版大厅已唤起" }),
            Err(e) => serde_json::json!({ "success": false, "error": e.to_string() }),
        };
        let mut resp = Response::from_data(serde_json::to_vec(&resp_json)?);
        resp.add_header(json_header);
        resp.add_header(cors_header);
        req.respond(resp)?;
        return Ok(());
    }

    // 2. Serve local previews
    if path.starts_with("/previews/") {
        let rel_path = &path["/previews/".len()..];
        let mut local_candidates = Vec::new();
        if let Ok(exe) = env::current_exe() {
            if let Some(exe_dir) = exe.parent() {
                local_candidates.push(exe_dir.join(format!("assets/previews/{rel_path}")));
                local_candidates.push(exe_dir.join(format!("../assets/previews/{rel_path}")));
                local_candidates.push(exe_dir.join(format!("data/previews/{rel_path}")));
                local_candidates.push(exe_dir.join(format!("../data/previews/{rel_path}")));
            }
        }
        if let Ok(cwd) = env::current_dir() {
            local_candidates.push(cwd.join(format!("assets/previews/{rel_path}")));
            local_candidates.push(cwd.join(format!("data/previews/{rel_path}")));
            local_candidates.push(cwd.join(format!("lobby-launcher/assets/previews/{rel_path}")));
            local_candidates.push(cwd.join(format!("lobby-launcher/data/previews/{rel_path}")));
        }
        local_candidates.push(PathBuf::from(format!(r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\assets\previews\{rel_path}")));
        local_candidates.push(PathBuf::from(format!(r"D:\逆向\SSJJ双塔惊魂\lobby-launcher\data\previews\{rel_path}")));

        for cand in local_candidates {
            if cand.is_file() {
                if let Ok(bytes) = fs::read(&cand) {
                    let mut resp = Response::from_data(bytes);
                    resp.add_header(Header::from_bytes(&b"Content-Type"[..], &b"image/png"[..]).unwrap());
                    resp.add_header(cors_header);
                    req.respond(resp)?;
                    return Ok(());
                }
            }
        }
        let resp = Response::from_string("Preview Not Found").with_status_code(StatusCode(404));
        req.respond(resp)?;
        return Ok(());
    }

    // 3. Serve frontend static assets (from state.dist_dir)
    let clean_path = path.trim_start_matches('/');
    let file_path = if clean_path.is_empty() {
        state.dist_dir.join("index.html")
    } else {
        state.dist_dir.join(clean_path)
    };

    let target_file = if file_path.is_file() {
        file_path
    } else if !path.starts_with("/assets/") && !path.starts_with("/api/") {
        // SPA Fallback for client-side routing
        state.dist_dir.join("index.html")
    } else {
        let resp = Response::from_string("File Not Found").with_status_code(StatusCode(404));
        req.respond(resp)?;
        return Ok(());
    };

    if target_file.is_file() {
        if let Ok(bytes) = fs::read(&target_file) {
            let ext = target_file
                .extension()
                .and_then(|s| s.to_str())
                .unwrap_or("")
                .to_ascii_lowercase();

            let mime = match ext.as_str() {
                "js" | "mjs" => "application/javascript; charset=utf-8",
                "css" => "text/css; charset=utf-8",
                "png" => "image/png",
                "jpg" | "jpeg" => "image/jpeg",
                "svg" => "image/svg+xml",
                "ico" => "image/x-icon",
                "json" => "application/json; charset=utf-8",
                "woff" => "font/woff",
                "woff2" => "font/woff2",
                _ => "text/html; charset=utf-8",
            };

            let mut resp = Response::from_data(bytes);
            resp.add_header(Header::from_bytes(&b"Content-Type"[..], mime.as_bytes()).unwrap());
            resp.add_header(cors_header);
            req.respond(resp)?;
            return Ok(());
        }
    }

    let resp = Response::from_string("Not Found").with_status_code(StatusCode(404));
    req.respond(resp)?;
    Ok(())
}
