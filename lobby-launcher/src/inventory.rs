use std::collections::BTreeMap;
use std::path::Path;

use anyhow::{Context, Result};
use serde::Deserialize;

const EMBEDDED_INVENTORY: &str = include_str!("../data/asset_inventory.json");

#[derive(Debug, Clone)]
pub struct Inventory {
    pub weapons: Vec<Weapon>,
    pub characters: Vec<Character>,
    pub maps: Vec<GameMap>,
    /// [PATCH] 武器皮肤（weaponskin/<key>），base 为推断的适用武器 key（可能为空）。
    pub weapon_skins: Vec<WeaponSkin>,
    /// [PATCH] 角色皮肤（playerskin/<key>）。
    pub career_skins: Vec<CareerSkin>,
    /// [PATCH] 喷漆仓库（spray/<id>），id 是原版资源 ID。
    pub sprays: Vec<Spray>,
    /// [PATCH] 饰品仓库（accessory/<key>）。
    pub accessories: Vec<CosmeticPart>,
    /// [PATCH] 角色时装部件（avatarplayer/<key>）：body / cloth / hair 三系。
    pub avatar_parts: Vec<CosmeticPart>,
    pub medals: Vec<Collectible>,
    pub titles: Vec<Collectible>,
}

#[derive(Debug, Clone)]
pub struct Collectible {
    pub key: String,
    pub name: String,
    pub complete: bool,
    pub preview_available: bool,
    /// None 表示未验证此资源是否可被战斗客户端加载。
    pub client_available: Option<bool>,
}

#[derive(Debug, Clone)]
pub struct WeaponSkin {
    pub key: String,
    pub base: String,
    pub complete: bool,
    pub preview_available: bool,
    pub client_available: Option<bool>,
}

#[derive(Debug, Clone)]
pub struct CareerSkin {
    pub key: String,
    pub complete: bool,
    /// 所属角色内部名（来自 PlayerSkinInfo.Player）。空 = 独立角色皮肤或表内未登记。
    pub player: String,
}

impl CareerSkin {
    /// A skin belongs only to the role named by the official PlayerSkinInfo row.
    /// An unresolved owner must never make a skin compatible with every role.
    pub fn belongs_to(&self, player: &str) -> bool {
        let owner = self.player.trim();
        !owner.is_empty() && owner.eq_ignore_ascii_case(player.trim())
    }
}

/// 喷漆：原版 spray/<ResId> 包内是 256x256 贴图 + 贴墙 quad。
#[derive(Debug, Clone)]
pub struct Spray {
    pub id: u32,
    pub complete: bool,
    pub preview_available: bool,
    pub client_available: Option<bool>,
    /// 原版允许玩家自定义喷漆上的署名（SparyTextures.HasName）。
    pub has_name: bool,
    pub color_id: u8,
    pub width: u16,
    pub height: u16,
}

impl Spray {
    pub fn key(&self) -> String {
        self.id.to_string()
    }
}

/// 装扮类条目（饰品 / 时装部件）：只有资源键，没有表格中文名。
#[derive(Debug, Clone)]
pub struct CosmeticPart {
    pub key: String,
    pub complete: bool,
    pub preview_available: bool,
    pub client_available: Option<bool>,
}

impl CosmeticPart {
    /// avatar_body_lurker01 -> Body；avatar_cloth_assault01 -> Cloth；其余按前缀归类。
    pub fn group(&self) -> &'static str {
        let lower = self.key.to_ascii_lowercase();
        if lower.starts_with("avatar_body") {
            "身体"
        } else if lower.starts_with("avatar_cloth") {
            "服装"
        } else if lower.starts_with("avatar_hair") {
            "发型"
        } else if lower.starts_with("avatar_head") {
            "头部"
        } else if lower.starts_with("accessory") {
            "挂件"
        } else {
            "其他"
        }
    }
}

#[derive(Debug, Clone)]
pub struct Weapon {
    pub key: String,
    pub cn: String,
    pub kind: String,
    pub complete: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CharacterKind {
    Human,
    Zombie,
    Mech,
    Pet,
    Other,
}

impl CharacterKind {
    pub const ALL: [Self; 5] = [
        Self::Human,
        Self::Zombie,
        Self::Mech,
        Self::Pet,
        Self::Other,
    ];

    pub fn label(self) -> &'static str {
        match self {
            Self::Human => "人类",
            Self::Zombie => "僵尸",
            Self::Mech => "机甲",
            Self::Pet => "宠物",
            Self::Other => "其他",
        }
    }

    pub fn from_key(key: &str) -> Self {
        match key {
            "human" => Self::Human,
            "zombie" => Self::Zombie,
            "mech" => Self::Mech,
            "pet" => Self::Pet,
            _ => Self::Other,
        }
    }

    pub fn order(self) -> u8 {
        match self {
            Self::Human => 0,
            Self::Zombie => 1,
            Self::Mech => 2,
            Self::Pet => 3,
            Self::Other => 4,
        }
    }
}

#[derive(Debug, Clone)]
pub struct Character {
    pub key: String,
    pub cn: String,
    pub kind: CharacterKind,
    pub complete: bool,
    pub npc_only: bool,
}

#[derive(Debug, Clone)]
pub struct GameMap {
    pub key: String,
    pub id: String,
    pub md5: String,
    pub src: String,
    pub availability: MapAvailability,
    pub preview_available: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MapAvailability {
    Installed,
    InstallAtLaunch,
    NotIntegrated,
    IncompleteResources,
}

impl GameMap {
    pub fn available(&self) -> bool {
        matches!(
            self.availability,
            MapAvailability::Installed | MapAvailability::InstallAtLaunch
        )
    }

    pub fn installed(&self) -> bool {
        self.availability == MapAvailability::Installed
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WeaponCategory {
    Rifle,
    Sniper,
    Pistol,
    Melee,
    Grenade,
    Shotgun,
    Other,
}

impl WeaponCategory {
    pub const ALL: [Self; 7] = [
        Self::Rifle,
        Self::Sniper,
        Self::Pistol,
        Self::Melee,
        Self::Grenade,
        Self::Shotgun,
        Self::Other,
    ];

    pub fn label(self) -> &'static str {
        match self {
            Self::Rifle => "步枪",
            Self::Sniper => "狙击",
            Self::Pistol => "手枪",
            Self::Melee => "近战",
            Self::Grenade => "投掷",
            Self::Shotgun => "霰弹",
            Self::Other => "特殊",
        }
    }

    pub fn glyph(self) -> &'static str {
        match self {
            Self::Rifle => "步",
            Self::Sniper => "狙",
            Self::Pistol => "手",
            Self::Melee => "刀",
            Self::Grenade => "雷",
            Self::Shotgun => "霰",
            Self::Other => "特",
        }
    }

    pub fn order(self) -> u8 {
        match self {
            Self::Rifle => 0,
            Self::Sniper => 1,
            Self::Pistol => 2,
            Self::Melee => 3,
            Self::Grenade => 4,
            Self::Shotgun => 5,
            Self::Other => 6,
        }
    }
}

impl Weapon {
    pub fn display_name(&self) -> &str {
        if self.cn.trim().is_empty() {
            &self.key
        } else {
            &self.cn
        }
    }

    pub fn category(&self) -> WeaponCategory {
        classify_weapon(&self.kind)
    }
}

impl Character {
    pub fn display_name(&self) -> &str {
        if self.cn.trim().is_empty() {
            &self.key
        } else {
            &self.cn
        }
    }

    /// A role can be selected for battle only when both its player model bundle
    /// and the official lobby role-card icon are present.
    pub fn selectable(&self) -> bool {
        self.kind == CharacterKind::Human
            && self.complete
            && !self.npc_only
            && crate::official_preview::has("character", &self.key)
    }

    pub fn has_official_lobby_icon(&self) -> bool {
        self.kind == CharacterKind::Human
            && !self.npc_only
            && crate::official_preview::has("character", &self.key)
    }
}

#[derive(Debug, Deserialize)]
struct RawInventory {
    #[serde(default)]
    weapons: BTreeMap<String, RawWeapon>,
    #[serde(default)]
    characters: BTreeMap<String, RawCharacter>,
    #[serde(default)]
    maps: BTreeMap<String, RawMap>,
    #[serde(default)]
    weapon_skins: BTreeMap<String, RawWeaponSkin>,
    #[serde(default)]
    career_skins: BTreeMap<String, RawCareerSkin>,
    #[serde(default)]
    sprays: BTreeMap<String, RawSpray>,
    #[serde(default)]
    accessories: BTreeMap<String, RawCosmeticPart>,
    #[serde(default)]
    avatar_parts: BTreeMap<String, RawCosmeticPart>,
    #[serde(default)]
    medals: BTreeMap<String, RawCollectible>,
    #[serde(default)]
    titles: BTreeMap<String, RawCollectible>,
}

#[derive(Debug, Default, Deserialize)]
struct RawCollectible {
    #[serde(default)]
    name: String,
    #[serde(default)]
    complete: bool,
    #[serde(default)]
    preview_available: bool,
    #[serde(default)]
    client_available: Option<bool>,
}

#[derive(Debug, Default, Deserialize)]
struct RawWeaponSkin {
    #[serde(default)]
    base: String,
    #[serde(default = "default_true", alias = "has_mesh")]
    complete: bool,
    #[serde(default)]
    preview_available: bool,
    #[serde(default)]
    client_available: Option<bool>,
}

#[derive(Debug, Default, Deserialize)]
struct RawCareerSkin {
    #[serde(default = "default_true", alias = "has_mesh")]
    complete: bool,
    #[serde(default)]
    player: String,
}

#[derive(Debug, Default, Deserialize)]
struct RawSpray {
    #[serde(default = "default_true")]
    complete: bool,
    #[serde(default)]
    preview_available: bool,
    #[serde(default)]
    client_available: Option<bool>,
    #[serde(default, deserialize_with = "deserialize_boolish")]
    has_name: bool,
    #[serde(default)]
    color_id: u8,
    #[serde(default)]
    w: u16,
    #[serde(default)]
    h: u16,
}

fn deserialize_boolish<'de, D>(deserializer: D) -> std::result::Result<bool, D::Error>
where
    D: serde::Deserializer<'de>,
{
    #[derive(Deserialize)]
    #[serde(untagged)]
    enum Boolish {
        Bool(bool),
        Integer(i64),
    }

    match Boolish::deserialize(deserializer)? {
        Boolish::Bool(value) => Ok(value),
        Boolish::Integer(0) => Ok(false),
        Boolish::Integer(1) => Ok(true),
        Boolish::Integer(value) => Err(serde::de::Error::custom(format!(
            "expected 0 or 1 for boolean field, found {value}"
        ))),
    }
}

#[derive(Debug, Default, Deserialize)]
struct RawCosmeticPart {
    #[serde(default = "default_true")]
    complete: bool,
    #[serde(default)]
    preview_available: bool,
    #[serde(default)]
    client_available: Option<bool>,
}

#[derive(Debug, Default, Deserialize)]
struct RawWeapon {
    #[serde(default)]
    cn: String,
    #[serde(default, rename = "type")]
    kind: String,
    #[serde(default = "default_true", alias = "has_mesh")]
    complete: bool,
}

#[derive(Debug, Default, Deserialize)]
struct RawCharacter {
    #[serde(default)]
    cn: String,
    #[serde(default)]
    kind: String,
    #[serde(default = "default_true", alias = "has_mesh")]
    complete: bool,
    #[serde(default)]
    npc_only: bool,
}

#[derive(Debug, Default, Deserialize)]
struct RawMap {
    #[serde(default)]
    md5: String,
    #[serde(default)]
    src: String,
    #[serde(default, rename = "complete", alias = "has_mesh")]
    complete: Option<bool>,
}

fn default_true() -> bool {
    true
}

impl Inventory {
    pub fn load_embedded() -> Result<Self> {
        Self::parse(EMBEDDED_INVENTORY)
    }

    pub fn parse(json: &str) -> Result<Self> {
        let raw: RawInventory =
            serde_json::from_str(json).context("资源清单 asset_inventory.json 解析失败")?;

        let mut weapons: Vec<Weapon> = raw
            .weapons
            .into_iter()
            .map(|(key, item)| Weapon {
                // 契约要求输出内部名，清单 key 才是客户端认的标识。
                key,
                cn: item.cn,
                kind: item.kind,
                complete: item.complete,
            })
            .collect();
        weapons.sort_by(|a, b| crate::official_preview::compare_weapons(&a.key, &b.key));

        let mut characters: Vec<Character> = raw
            .characters
            .into_iter()
            .map(|(key, item)| Character {
                cn: crate::official_preview::character_name(&key)
                    .map(str::to_owned)
                    .unwrap_or(item.cn),
                key,
                kind: CharacterKind::from_key(&item.kind),
                complete: item.complete,
                npc_only: item.npc_only,
            })
            .collect();
        characters.sort_by(|a, b| {
            b.complete
                .cmp(&a.complete)
                .then_with(|| a.kind.order().cmp(&b.kind.order()))
                .then_with(|| a.key.cmp(&b.key))
        });

        let mut maps: Vec<GameMap> = raw
            .maps
            .into_iter()
            .filter(|(key, _)| is_map_package(key))
            .map(|(key, item)| {
                // 缺少资源完整性字段时采取保守状态，不把未知地图误报为可启动。
                let complete = item.complete.unwrap_or(false);
                let availability = if !complete {
                    MapAvailability::IncompleteResources
                } else {
                    MapAvailability::InstallAtLaunch
                };
                let id = key.rsplit('/').next().unwrap_or(&key).to_owned();
                let preview_available = crate::official_preview::has("map", &id);
                GameMap {
                    id,
                    key,
                    md5: item.md5,
                    src: item.src,
                    availability,
                    preview_available,
                }
            })
            .collect();
        // [PATCH] 地图按编号自然排序（map1, map2, ... map10, map11, map12 ...），可用地图优先。
        fn map_number(key: &str) -> u32 {
            key.rsplit('/')
                .next()
                .unwrap_or(key)
                .trim_start_matches("map")
                .parse::<u32>()
                .unwrap_or(u32::MAX)
        }
        maps.sort_by(|a, b| {
            b.available()
                .cmp(&a.available())
                .then_with(|| map_number(&a.key).cmp(&map_number(&b.key)))
                .then_with(|| a.key.cmp(&b.key))
        });

        let mut weapon_skins: Vec<WeaponSkin> = raw
            .weapon_skins
            .into_iter()
            .map(|(key, item)| WeaponSkin {
                preview_available: crate::official_preview::has("skin", &key),
                key,
                base: item.base,
                complete: item.complete,
                client_available: item.client_available,
            })
            .collect();
        weapon_skins.sort_by(|a, b| b.complete.cmp(&a.complete).then_with(|| a.key.cmp(&b.key)));

        let mut career_skins: Vec<CareerSkin> = raw
            .career_skins
            .into_iter()
            .map(|(key, item)| CareerSkin {
                key,
                complete: item.complete,
                player: item.player,
            })
            .collect();
        career_skins.sort_by(|a, b| {
            b.complete
                .cmp(&a.complete)
                .then_with(|| a.player.cmp(&b.player))
                .then_with(|| a.key.cmp(&b.key))
        });

        let mut sprays: Vec<Spray> = raw
            .sprays
            .into_iter()
            .filter_map(|(key, item)| {
                // 清单 key 是字符串化的 ResId；解析不了的直接丢，避免喷漆页出现空卡。
                key.parse::<u32>().ok().map(|id| Spray {
                    id,
                    complete: item.complete,
                    preview_available: crate::official_preview::has("spray", &key),
                    client_available: item.client_available,
                    has_name: item.has_name,
                    color_id: item.color_id,
                    width: item.w,
                    height: item.h,
                })
            })
            .collect();
        sprays.sort_by(|a, b| b.complete.cmp(&a.complete).then_with(|| a.id.cmp(&b.id)));

        fn cosmetic(mut items: Vec<CosmeticPart>) -> Vec<CosmeticPart> {
            items.sort_by(|a, b| {
                b.complete
                    .cmp(&a.complete)
                    .then_with(|| a.group().cmp(b.group()))
                    .then_with(|| a.key.cmp(&b.key))
            });
            items
        }

        let accessories = cosmetic(
            raw.accessories
                .into_iter()
                .map(|(key, item)| CosmeticPart {
                    preview_available: crate::official_preview::has("accessory", &key),
                    key,
                    complete: item.complete,
                    client_available: item.client_available,
                })
                .collect(),
        );
        let avatar_parts = cosmetic(
            raw.avatar_parts
                .into_iter()
                .map(|(key, item)| CosmeticPart {
                    preview_available: crate::official_preview::has("avatar_part", &key),
                    key,
                    complete: item.complete,
                    client_available: item.client_available,
                })
                .collect(),
        );

        fn collectibles(items: BTreeMap<String, RawCollectible>, kind: &str) -> Vec<Collectible> {
            let mut items: Vec<Collectible> = items
                .into_iter()
                .map(|(key, item)| Collectible {
                    name: if item.name.trim().is_empty() {
                        key.clone()
                    } else {
                        item.name
                    },
                    preview_available: crate::official_preview::has(kind, &key),
                    key,
                    complete: item.complete,
                    client_available: item.client_available,
                })
                .collect();
            items.sort_by(|a, b| {
                a.key
                    .parse::<u32>()
                    .unwrap_or(u32::MAX)
                    .cmp(&b.key.parse::<u32>().unwrap_or(u32::MAX))
                    .then_with(|| a.key.cmp(&b.key))
            });
            items
        }
        let medals = collectibles(raw.medals, "medal");
        let titles = collectibles(raw.titles, "title");

        Ok(Self {
            weapons,
            characters,
            maps,
            weapon_skins,
            career_skins,
            sprays,
            accessories,
            avatar_parts,
            medals,
            titles,
        })
    }

    pub fn weapon(&self, key: &str) -> Option<&Weapon> {
        self.weapons.iter().find(|w| w.key == key)
    }

    pub fn character(&self, key: &str) -> Option<&Character> {
        self.characters
            .iter()
            .find(|c| c.key.eq_ignore_ascii_case(key))
    }

    pub fn map(&self, key: &str) -> Option<&GameMap> {
        self.maps.iter().find(|m| m.key == key || m.id == key)
    }

    pub fn available_weapon_count(&self) -> usize {
        self.weapons.iter().filter(|w| w.complete).count()
    }

    pub fn available_character_count(&self) -> usize {
        self.characters.iter().filter(|c| c.selectable()).count()
    }

    pub fn available_map_count(&self) -> usize {
        self.maps.iter().filter(|m| m.available()).count()
    }

    pub fn previewed_medal_count(&self) -> usize {
        self.medals
            .iter()
            .filter(|item| item.preview_available)
            .count()
    }

    pub fn previewed_title_count(&self) -> usize {
        self.titles
            .iter()
            .filter(|item| item.preview_available)
            .count()
    }

    pub fn installed_map_count(&self) -> usize {
        self.maps.iter().filter(|m| m.installed()).count()
    }

    pub fn install_at_launch_map_count(&self) -> usize {
        self.maps
            .iter()
            .filter(|m| m.availability == MapAvailability::InstallAtLaunch)
            .count()
    }

    /// 根据当前游戏目录刷新地图状态。未安装的地图只显示为“启动时验证”，
    /// 只有资源安装脚本成功运行后才会在下次启动显示为“已安装”。
    pub fn refresh_map_readiness(&mut self, game_dir: &str, install_script: &str) {
        let root = Path::new(game_dir.trim());
        let bundle_root = root
            .join("SSJJ_BattleClient_Unity_Data")
            .join("StreamingAssets")
            .join("AssetBundles")
            .join("Windows");
        let manifest_path = bundle_root.join("AssetBundles");
        let manifest = std::fs::read_to_string(&manifest_path).unwrap_or_default();
        let client_exists = root.join("SSJJ_BattleClient_Unity.exe").is_file();
        let can_install = client_exists && Path::new(install_script.trim()).is_file();

        for map in &mut self.maps {
            map.preview_available = crate::official_preview::has("map", &map.id);
            if map.availability == MapAvailability::IncompleteResources {
                continue;
            }

            let Some(scene_id) = map
                .id
                .strip_prefix("map")
                .and_then(|value| value.parse::<u32>().ok())
            else {
                map.availability = MapAvailability::NotIntegrated;
                continue;
            };
            let bundle_name = format!("maps/map{scene_id}");
            let bundle_file = bundle_root.join(format!("{bundle_name}_{}", map.md5));
            let manifest_has_entry = manifest.contains(&format!("name=\"{bundle_name}\""));
            if manifest_has_entry && bundle_file.is_file() {
                map.availability = MapAvailability::Installed;
            } else if can_install {
                map.availability = MapAvailability::InstallAtLaunch;
            } else {
                map.availability = MapAvailability::NotIntegrated;
            }
        }

        fn map_number(key: &str) -> u32 {
            key.rsplit('/')
                .next()
                .unwrap_or(key)
                .trim_start_matches("map")
                .parse::<u32>()
                .unwrap_or(u32::MAX)
        }
        self.maps.sort_by(|a, b| {
            b.available()
                .cmp(&a.available())
                .then_with(|| b.installed().cmp(&a.installed()))
                .then_with(|| map_number(&a.key).cmp(&map_number(&b.key)))
                .then_with(|| a.key.cmp(&b.key))
        });
    }

    /// [PATCH] 皮肤查询：空串或找不到都返回 None（调用方回落默认皮肤）。
    pub fn weapon_skin(&self, key: &str) -> Option<&WeaponSkin> {
        if key.is_empty() {
            return None;
        }
        self.weapon_skins.iter().find(|s| s.key == key)
    }

    pub fn career_skin(&self, key: &str) -> Option<&CareerSkin> {
        let key = key.trim();
        if key.is_empty() {
            return None;
        }
        self.career_skins.iter().find(|s| s.key.eq_ignore_ascii_case(key))
    }

    pub fn available_weapon_skin_count(&self) -> usize {
        self.weapon_skins.iter().filter(|s| s.complete).count()
    }

    pub fn available_career_skin_count(&self) -> usize {
        self.career_skins.iter().filter(|s| s.complete).count()
    }

    /// 某个角色可选皮肤（含未完成的，由调用方按 complete 过滤）。
    pub fn career_skins_for<'a>(&'a self, player: &'a str) -> Vec<&'a CareerSkin> {
        if player.trim().is_empty() {
            return Vec::new();
        }
        self.career_skins
            .iter()
            .filter(|skin| skin.belongs_to(player))
            .collect()
    }

    pub fn spray(&self, id: u32) -> Option<&Spray> {
        self.sprays.iter().find(|s| s.id == id)
    }

    pub fn available_spray_count(&self) -> usize {
        self.sprays.iter().filter(|s| s.complete).count()
    }

    pub fn available_accessory_count(&self) -> usize {
        self.accessories.iter().filter(|a| a.complete).count()
    }

    pub fn available_avatar_part_count(&self) -> usize {
        self.avatar_parts.iter().filter(|a| a.complete).count()
    }
}

fn is_map_package(key: &str) -> bool {
    (key.starts_with("maps/") || key.starts_with("unitymaps/")) && key != "maps/common"
}

fn classify_weapon(kind: &str) -> WeaponCategory {
    let lower = kind.to_ascii_lowercase();
    // Rifle 要排在 Grenade 前：GrenadeRifleSpecial 是发射榴弹的枪，占主武器槽。
    if lower.contains("sniper") {
        WeaponCategory::Sniper
    } else if lower.contains("rifle") || lower == "m4a1g" {
        WeaponCategory::Rifle
    } else if lower.contains("grenade") {
        WeaponCategory::Grenade
    } else if lower.contains("knife")
        || lower == "saw"
        || lower == "bladeshield"
        || lower == "shovel"
    {
        WeaponCategory::Melee
    } else if lower.contains("pistol") {
        WeaponCategory::Pistol
    } else if lower.contains("shotgun") {
        WeaponCategory::Shotgun
    } else {
        WeaponCategory::Other
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn inventory() -> Inventory {
        Inventory::load_embedded().expect("embedded inventory")
    }

    #[test]
    fn inventory_has_expected_counts() {
        let inv = inventory();
        assert_eq!(inv.weapons.len(), 1451);
        assert_eq!(inv.characters.len(), 811);
        assert_eq!(inv.maps.len(), 587);
        assert_eq!(inv.available_weapon_count(), 1434);
        assert!(inv.available_character_count() > 0);
        assert!(inv.characters.iter().filter(|c| c.selectable()).all(|c| c.has_official_lobby_icon()));
        // [PATCH] 587 张地图资源全部齐全，全部可进入（启动时自动安装）。
        assert_eq!(inv.available_map_count(), 587);
        // 全量索引：皮肤表含不完整资源条目，UI 会逐项标注资源状态。
        assert_eq!(inv.weapon_skins.len(), 499);
        assert_eq!(inv.career_skins.len(), 90);
        assert_eq!(inv.available_weapon_skin_count(), 414);
        assert_eq!(inv.available_career_skin_count(), 84);
        assert_eq!(inv.accessories.len(), 419);
        assert_eq!(inv.avatar_parts.len(), 43);
        assert_eq!(inv.medals.len(), 32);
        assert_eq!(inv.titles.len(), 59);
        assert_eq!(inv.previewed_medal_count(), 32);
        assert_eq!(inv.previewed_title_count(), 59);
        assert!(inv
            .weapon_skin("skin_ak47_g_12years")
            .is_some_and(|s| s.complete && s.base == "ak47_g"));
        assert!(inv.career_skin("ares2").is_some_and(|s| s.complete));
        // 空串 = 默认皮肤，不查表
        assert!(inv.weapon_skin("").is_none());
        assert!(inv.career_skin("").is_none());
    }

    #[test]
    fn every_complete_map_is_playable() {
        let inv = inventory();
        // 旧实现硬编码只放行 map1；现在数据驱动，齐资源的图全部可玩。
        assert!(inv.map("maps/map1").expect("map1").available());
        assert!(inv.map("maps/map12").expect("map12").available());
        assert!(inv.map("maps/map43").expect("map43").available());
        assert!(inv.map("maps/map791").expect("map791").available());
        assert!(inv
            .maps
            .iter()
            .filter(|m| m.available())
            .all(|m| m.key.starts_with("maps/map")));
        assert!(!inv.maps.iter().any(|m| m.key == "modeconfig"));
        assert!(!inv.maps.iter().any(|m| m.key == "maps/common"));
        assert!(!inv.maps.iter().any(|m| m.key == "maps/effect"));
    }

    #[test]
    fn incomplete_resources_are_retained() {
        let inv = inventory();
        assert!(inv.weapon("pvegatling").is_some_and(|w| !w.complete));
        assert!(inv.character("freya").is_some_and(|c| !c.complete));
    }

    #[test]
    fn character_kind_comes_from_career_flags() {
        let inv = inventory();
        assert_eq!(
            inv.character("police").map(|c| c.kind),
            Some(CharacterKind::Human)
        );
        assert!(inv
            .characters
            .iter()
            .any(|c| c.kind == CharacterKind::Zombie));
    }

    #[test]
    fn empty_chinese_name_falls_back_to_internal_name() {
        let inv = inventory();
        let item = inv
            .weapons
            .iter()
            .find(|w| w.cn.is_empty())
            .expect("empty cn");
        assert_eq!(item.display_name(), item.key);
    }

    #[test]
    fn categories_are_derived_from_type_field() {
        assert_eq!(classify_weapon("Rifle"), WeaponCategory::Rifle);
        assert_eq!(classify_weapon("SniperRifle"), WeaponCategory::Sniper);
        assert_eq!(classify_weapon("DoublePistol"), WeaponCategory::Pistol);
        assert_eq!(classify_weapon("NbrKnife"), WeaponCategory::Melee);
        assert_eq!(classify_weapon("Grenade"), WeaponCategory::Grenade);
        assert_eq!(
            classify_weapon("GrenadeRifleSpecial"),
            WeaponCategory::Rifle
        );
        assert_eq!(classify_weapon("ShotGunMelee"), WeaponCategory::Shotgun);
        assert_eq!(classify_weapon("Uav"), WeaponCategory::Other);
    }
}
