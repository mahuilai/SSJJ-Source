use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

use crate::inventory::Inventory;
use crate::settings::{self, write_atomic};

const PROFILE_FILE: &str = "profile.json";

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct PlayerProfile {
    pub player_name: String,
    pub level: u16,
    pub rank: String,
    pub gold: u64,
    pub gp: u64,
    pub vip_level: u8,
    /// 本地离线资料的资源拥有状态；它不会被当作官服账号数据。
    pub unlocked_assets: BTreeSet<String>,
    pub selected_title: String,
    pub equipped_medals: Vec<String>,
    /// 离线大厅中装备的喷漆资源 ID；不声称客户端已消费这些字段。
    pub equipped_sprays: Vec<u32>,
    /// 离线大厅中装备的饰品/时装，格式为 `category/key`。
    pub equipped_cosmetics: Vec<String>,
    pub portrait: String,
    /// Preserve fields written by newer or external profile producers.
    #[serde(flatten)]
    pub extra: BTreeMap<String, serde_json::Value>,
}

impl Default for PlayerProfile {
    fn default() -> Self {
        Self {
            player_name: "无端大傻逼".to_owned(),
            level: 91,
            rank: "最强王者".to_owned(),
            gold: 91,
            gp: 91,
            vip_level: 18,
            unlocked_assets: BTreeSet::new(),
            selected_title: String::new(),
            equipped_medals: Vec::new(),
            equipped_sprays: Vec::new(),
            equipped_cosmetics: Vec::new(),
            portrait: "police".to_owned(),
            extra: BTreeMap::new(),
        }
    }
}

pub struct LoadedProfile {
    pub profile: PlayerProfile,
    pub warning: Option<String>,
    pub needs_save: bool,
}

impl PlayerProfile {
    pub fn load(inventory: &Inventory) -> LoadedProfile {
        Self::load_keys(Self::inventory_asset_keys(inventory).collect())
    }

    /// Load the modern launcher profile using only rows from the original
    /// lobby GameData catalog. The legacy `Inventory` loader is intentionally
    /// kept for the explicit legacy screen, but is never consulted here.
    pub fn load_lobby_dataset(json: &str) -> LoadedProfile {
        let mut keys = BTreeSet::new();
        if let Ok(root) = serde_json::from_str::<serde_json::Value>(json) {
            for row in root.get("weapons").and_then(|v| v.as_array()).into_iter().flatten() {
                if let Some(key) = row.get("key").and_then(|v| v.as_str()) {
                    keys.insert(format!("weapon/{key}"));
                }
            }
            for row in root.get("characters").and_then(|v| v.as_array()).into_iter().flatten() {
                if let Some(key) = row.get("key").and_then(|v| v.as_str()) {
                    let category = if row.get("isSkin").and_then(|v| v.as_bool()).unwrap_or(false) {
                        "career_skin"
                    } else {
                        "character"
                    };
                    keys.insert(format!("{category}/{key}"));
                }
            }
            for row in root.get("skins").and_then(|v| v.as_array()).into_iter().flatten() {
                if let Some(key) = row.get("codeName").and_then(|v| v.as_str()) {
                    keys.insert(format!("weapon_skin/{key}"));
                }
            }
            for row in root.get("maps").and_then(|v| v.as_array()).into_iter().flatten() {
                if let Some(key) = row.get("key").and_then(|v| v.as_str()) {
                    keys.insert(format!("map/{key}"));
                }
            }
        }
        Self::load_keys(keys)
    }

    fn load_keys(asset_keys: BTreeSet<String>) -> LoadedProfile {
        let path = match profile_path() {
            Ok(path) => path,
            Err(err) => {
                return LoadedProfile {
                    profile: Self::seeded_keys(&asset_keys),
                    warning: Some(err.to_string()),
                    needs_save: false,
                };
            }
        };

        let mut profile = match fs::read(&path) {
            Ok(bytes) => match serde_json::from_slice::<Self>(&bytes) {
                Ok(profile) => profile,
                Err(err) => {
                    let backup = path.with_extension("json.corrupt");
                    let backup_note = fs::copy(&path, &backup)
                        .map(|_| format!("已备份损坏文件到 {}", backup.display()))
                        .unwrap_or_else(|copy_err| format!("备份失败：{copy_err}"));
                    let mut fresh = Self::seeded_keys(&asset_keys);
                    fresh.player_name = Self::default().player_name;
                    return LoadedProfile {
                        profile: fresh,
                        warning: Some(format!(
                            "本地玩家资料无法解析：{err}；{backup_note}，已载入默认离线资料"
                        )),
                        needs_save: true,
                    };
                }
            },
            Err(err) if err.kind() == std::io::ErrorKind::NotFound => {
                return LoadedProfile {
                    profile: Self::seeded_keys(&asset_keys),
                    warning: None,
                    needs_save: true,
                };
            }
            Err(err) => {
                return LoadedProfile {
                    profile: Self::seeded_keys(&asset_keys),
                    warning: Some(format!("读取本地玩家资料失败：{err}")),
                    needs_save: false,
                };
            }
        };

        let official_categories = [
            "weapon", "character", "career_skin", "map", "weapon_skin",
            "spray", "accessory", "avatar_part", "medal", "title",
        ];
        let mut needs_save = false;
        // Migrate recognized unlock categories away from stale client-cache
        // entries; keep unknown categories and profile fields intact.
        let before = profile.unlocked_assets.len();
        profile.unlocked_assets.retain(|entry| {
            let Some((category, _)) = entry.split_once('/') else { return true; };
            !official_categories.contains(&category) || asset_keys.contains(entry)
        });
        needs_save |= profile.unlocked_assets.len() != before;
        for key in asset_keys {
            if profile.unlocked_assets.insert(key) {
                needs_save = true;
            }
        }
        LoadedProfile {
            profile,
            warning: None,
            needs_save,
        }
    }

    pub fn seeded(inventory: &Inventory) -> Self {
        Self::seeded_keys(&Self::inventory_asset_keys(inventory).collect())
    }

    fn seeded_keys(keys: &BTreeSet<String>) -> Self {
        let mut profile = Self::default();
        profile.unlocked_assets = keys.clone();
        profile
    }

    pub fn save(&self) -> Result<PathBuf> {
        let path = profile_path()?;
        let parent = path.parent().context("大厅资料目录不存在")?;
        fs::create_dir_all(parent)
            .with_context(|| format!("创建玩家资料目录失败：{}", parent.display()))?;
        let mut bytes = serde_json::to_vec_pretty(self).context("序列化本地玩家资料失败")?;
        bytes.push(b'\n');
        write_atomic(&path, bytes)
            .with_context(|| format!("写入本地玩家资料失败：{}", path.display()))?;
        Ok(path)
    }

    pub fn is_unlocked(&self, category: &str, key: &str) -> bool {
        self.unlocked_assets.contains(&format!("{category}/{key}"))
    }

    pub fn unlocked_count(&self) -> usize {
        self.unlocked_assets.len()
    }

    pub fn is_equipped_cosmetic(&self, category: &str, key: &str) -> bool {
        self.equipped_cosmetics
            .iter()
            .any(|item| item == &format!("{category}/{key}"))
    }

    pub fn toggle_cosmetic(&mut self, category: &str, key: &str) {
        let item = format!("{category}/{key}");
        if self
            .equipped_cosmetics
            .iter()
            .any(|existing| existing == &item)
        {
            self.equipped_cosmetics.retain(|existing| existing != &item);
        } else {
            self.equipped_cosmetics.push(item);
        }
    }

    fn inventory_asset_keys(inventory: &Inventory) -> impl Iterator<Item = String> + '_ {
        inventory
            .weapons
            .iter()
            .map(|item| format!("weapon/{}", item.key))
            .chain(
                inventory
                    .characters
                    .iter()
                    .map(|item| format!("character/{}", item.key)),
            )
            .chain(inventory.maps.iter().map(|item| format!("map/{}", item.id)))
            .chain(
                inventory
                    .weapon_skins
                    .iter()
                    .map(|item| format!("weapon_skin/{}", item.key)),
            )
            .chain(
                inventory
                    .career_skins
                    .iter()
                    .map(|item| format!("career_skin/{}", item.key)),
            )
            .chain(
                inventory
                    .sprays
                    .iter()
                    .map(|item| format!("spray/{}", item.id)),
            )
            .chain(
                inventory
                    .accessories
                    .iter()
                    .map(|item| format!("accessory/{}", item.key)),
            )
            .chain(
                inventory
                    .avatar_parts
                    .iter()
                    .map(|item| format!("avatar_part/{}", item.key)),
            )
            .chain(
                inventory
                    .medals
                    .iter()
                    .map(|item| format!("medal/{}", item.key)),
            )
            .chain(
                inventory
                    .titles
                    .iter()
                    .map(|item| format!("title/{}", item.key)),
            )
    }
}

pub fn profile_path() -> Result<PathBuf> {
    let settings_path = settings::user_config_path()?;
    let parent = settings_path.parent().context("大厅配置目录不存在")?;
    Ok(Path::new(parent).join(PROFILE_FILE))
}
