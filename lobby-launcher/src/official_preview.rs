//! Official lazy-loaded lobby icon SWFs exported to lossless local PNGs.
//! The index is generated from the icon names used by the original AIR UI.

use std::collections::{HashMap, HashSet};
use std::cmp::Ordering;
use std::path::{Path, PathBuf};
use std::sync::OnceLock;

use serde::Deserialize;

const INDEX_JSON: &str = include_str!("../data/official_lobby_preview_index.json");

#[derive(Deserialize)]
struct PreviewIndex {
    by_key: HashMap<String, HashMap<String, String>>,
    #[serde(default)]
    weapon_order: HashMap<String, u32>,
    #[serde(default)]
    character_names: HashMap<String, String>,
    #[serde(default)]
    weapons: HashMap<String, WeaponMetadata>,
}

#[derive(Deserialize)]
struct WeaponMetadata {
    id: u32,
    sort_lv: i32,
    money_type: i32,
    speciality: i32,
    client_bg_type: i32,
    xlv: i32,
}

fn weapon_metadata(key: &str) -> Option<&'static WeaponMetadata> {
    index().weapons.get(&key.trim().to_lowercase())
}

/// StorageProxy.getFilteredWeaponByFilterType's sort for local permanent items:
/// store/isNew/expiredTime are equal; neverExpiredIndex, sortLv, moneyType and
/// tid still follow the official AS3 ordering and exact shop_weapon values.
pub fn compare_weapons(a: &str, b: &str) -> Ordering {
    match (weapon_metadata(a), weapon_metadata(b)) {
        (Some(a), Some(b)) => {
            let permanent_rank = |value: i32| matches!(value, -1 | 0 | 1 | 7) as u8;
            permanent_rank(b.money_type).cmp(&permanent_rank(a.money_type))
                .then_with(|| a.sort_lv.cmp(&b.sort_lv))
                .then_with(|| a.money_type.cmp(&b.money_type))
                .then_with(|| b.id.cmp(&a.id))
        }
        (Some(_), None) => Ordering::Less,
        (None, Some(_)) => Ordering::Greater,
        (None, None) => a.cmp(b),
    }
}

/// Original NewStorageWeaponItem background choice; keys refer to the exact
/// exported MallAssets sprites included in the preview catalog.
pub fn weapon_background(key: &str) -> Option<&'static str> {
    let row = weapon_metadata(key)?;
    match row.client_bg_type {
        31 => return Some("bg_weapon_31"),
        41 => return Some("bg_weapon_41"),
        _ => {}
    }
    Some(match row.speciality {
        1 => "hero_bg",
        2 => "goldItemBg",
        3 => "brilliant_bg",
        6 => "god_ItemBg",
        8 => "ledengBg",
        _ if row.money_type == 2 => "gp_layer",
        _ if row.xlv == 4 => "heishi_bg",
        _ => "rmb_layer",
    })
}

fn index() -> &'static PreviewIndex {
    static INDEX: OnceLock<PreviewIndex> = OnceLock::new();
    INDEX.get_or_init(|| {
        serde_json::from_str(INDEX_JSON).expect("official lobby preview index is invalid")
    })
}

fn category(kind: &str) -> Option<&'static str> {
    match kind {
        "ui" => Some("ui"),
        "weapon" => Some("weapons"),
        "character" => Some("characters"),
        "career_skin" => Some("career_skins"),
        "skin" | "weapon_skin" => Some("weapon_skins"),
        "accessory" | "avatar_part" => Some("parts"),
        "item" => Some("items"),
        "spray" => Some("sprays"),
        "map" => Some("maps"),
        "medal" => Some("medals"),
        "title" => Some("titles"),
        _ => None,
    }
}

pub fn character_name(key: &str) -> Option<&'static str> {
    index().character_names.get(&key.trim().to_lowercase()).map(String::as_str)
}

/// The official warehouse's final stable tie-breaker is weapon `tid` descending.
/// Per-copy flags (new, rental, expiry, and quality) do not exist in this local
/// all-unlocked inventory, so this preserves the source ordering key available
/// from the official weapon dictionary.
pub fn weapon_tid(key: &str) -> Option<u32> {
    if let Some(row) = weapon_metadata(key) {
        return Some(row.id);
    }
    index()
        .weapon_order
        .get(&key.trim().to_lowercase())
        .copied()
}

fn relative_path(kind: &str, key: &str) -> Option<&'static str> {
    let category = category(kind)?;
    let key = key.trim().to_lowercase();
    if key.is_empty() || key.contains('/') || key.contains('\\') || key.contains("..") {
        return None;
    }
    let index = index();
    let row = index.by_key.get(category)?;
    row.get(&key).map(String::as_str)
}

fn roots() -> &'static [PathBuf] {
    static ROOTS: OnceLock<Vec<PathBuf>> = OnceLock::new();
    ROOTS.get_or_init(|| {
        let mut roots = Vec::new();
        if let Ok(exe) = std::env::current_exe() {
            if let Some(exe_dir) = exe.parent() {
                roots.push(exe_dir.join("data").join("previews").join("official_lobby"));
                if let Some(parent) = exe_dir.parent() {
                    roots.push(
                        parent
                            .join("data")
                            .join("previews")
                            .join("official_lobby"),
                    );
                }
            }
        }
        roots.push(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("data")
                .join("previews")
                .join("official_lobby"),
        );
        roots
    })
}

fn path(kind: &str, key: &str) -> Option<PathBuf> {
    let relative = relative_path(kind, key)?;
    if relative.contains("..") || relative.contains('\\') {
        return None;
    }
    roots()
        .iter()
        .map(|root| root.join(relative))
        .find(|candidate| candidate.is_file())
}

pub fn has(kind: &str, key: &str) -> bool {
    let Some(category) = category(kind) else {
        return false;
    };
    let key = key.trim().to_lowercase();
    if !index()
        .by_key
        .get(category)
        .is_some_and(|row| row.contains_key(&key))
    {
        return false;
    }

    static AVAILABLE: OnceLock<HashSet<String>> = OnceLock::new();
    let available = AVAILABLE.get_or_init(|| {
        let mut found = HashSet::new();
        for (category, entries) in &index().by_key {
            for (key, relative) in entries {
                if relative.contains("..") || relative.contains('\\') {
                    continue;
                }
                if roots().iter().any(|root| root.join(relative).is_file()) {
                    found.insert(format!("{category}\0{key}"));
                }
            }
        }
        found
    });
    available.contains(&format!("{category}\0{key}"))
}

pub fn read(kind: &str, key: &str) -> Option<Vec<u8>> {
    std::fs::read(path(kind, key)?).ok()
}
