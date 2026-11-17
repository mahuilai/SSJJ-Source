use std::env;
use std::fs;
use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};

use crate::inventory::{Inventory, WeaponSkin};

/// Defaults resolve from the portable package beside the executable. In a source
/// checkout, scripts fall back to the tracked portable helpers and the user can
/// select their own local game directory in Settings.
pub const DEFAULT_GAME_DIR: &str = "便携包中的 battle/3_64";
pub const DEFAULT_PYTHON: &str = "python";
pub const DEFAULT_START_SCRIPT: &str = "portable/scripts/start_offline.py";
pub const DEFAULT_MAP_INSTALL_SCRIPT: &str = "portable/scripts/install_map.py";

fn executable_dir() -> Option<PathBuf> {
    env::current_exe().ok()?.parent().map(Path::to_path_buf)
}

pub fn bundle_root() -> PathBuf {
    if let Some(dir) = executable_dir() {
        if dir
            .join("battle")
            .join("3_64")
            .join("SSJJ_BattleClient_Unity.exe")
            .is_file()
        {
            return dir;
        }
    }
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap_or_else(|| Path::new(env!("CARGO_MANIFEST_DIR")))
        .to_path_buf()
}

fn bundled_path(relative: &str) -> Option<PathBuf> {
    let path = executable_dir()?.join(relative);
    path.exists().then_some(path)
}

pub fn default_game_dir() -> String {
    bundled_path("battle/3_64/SSJJ_BattleClient_Unity.exe")
        .and_then(|_| executable_dir().map(|dir| dir.join("battle/3_64")))
        .map(|path| path.to_string_lossy().into_owned())
        .unwrap_or_default()
}

pub fn default_start_script() -> String {
    bundled_path("scripts/start_offline.py")
        .or_else(|| Some(Path::new(env!("CARGO_MANIFEST_DIR")).join(DEFAULT_START_SCRIPT)))
        .map(|path| path.to_string_lossy().into_owned())
        .unwrap_or_default()
}

pub fn default_python() -> String {
    bundled_path("runtime/python/python.exe")
        .map(|path| path.to_string_lossy().into_owned())
        .unwrap_or_else(|| DEFAULT_PYTHON.to_owned())
}

pub fn default_map_install_script() -> String {
    bundled_path("scripts/install_map.py")
        .or_else(|| Some(Path::new(env!("CARGO_MANIFEST_DIR")).join(DEFAULT_MAP_INSTALL_SCRIPT)))
        .map(|path| path.to_string_lossy().into_owned())
        .unwrap_or_default()
}
pub const MODE_TEAM: &str = "team";
pub const HAND_MAN: &str = "man";
pub const BAG_COUNT: usize = 5;
/// [PATCH] 人机团战默认编制：玩家 + 3 队友 vs 4 敌人 = 8 人（原版 MaxPlayers=8）。
pub const TEAM_ALLY_BOTS: u8 = 3;
pub const TEAM_ENEMY_BOTS: u8 = 4;
/// [PATCH] 旧配置里可能出现的团队类模式名（含别名），迁移时都要识别。
pub const TEAM_MODE_ALIASES: [&str; 8] = [
    "team",
    "team_ai",
    "teamai",
    "team_mode",
    "group",
    "bot_team",
    "team2003",
    "team_2003",
];

/// 离线端 OfflineGameSetting.ModeIdFromName 支持的模式名与对应的原版 RaceType。
pub const MODES: [(&str, &str); 10] = [
    ("team", "团队模式"),
    ("team_ai", "人机团战"),
    ("bighead", "大头人机"),
    ("blade_ai", "刀战人机"),
    ("personal", "个人竞技"),
    ("explode", "爆破模式"),
    ("deathmatch", "死亡竞赛"),
    ("blade", "刀锋战士"),
    ("flyknife", "飞刀战"),
    ("weaponmaster", "枪王模式"),
];

/// [PATCH] AI 难度档位（键, 显示名）。
pub const DIFFICULTIES: [(&str, &str); 5] = [
    ("easy", "简单"),
    ("normal", "普通"),
    ("hard", "困难"),
    ("nightmare", "噩梦"),
    ("hell", "地狱"),
];

pub fn difficulty_label(diff: &str) -> &str {
    DIFFICULTIES
        .iter()
        .find(|(name, _)| *name == diff)
        .map(|(_, label)| *label)
        .unwrap_or("普通")
}

pub fn mode_label(mode: &str) -> &str {
    MODES
        .iter()
        .find(|(name, _)| *name == mode)
        .map(|(_, label)| *label)
        .unwrap_or("团队模式")
}

/// [PATCH] 是否是团队类模式（team / team_ai / group / bot_team / team2003 等）。
pub fn is_team_mode(mode: &str) -> bool {
    let mode = mode.trim();
    TEAM_MODE_ALIASES
        .iter()
        .any(|name| name.eq_ignore_ascii_case(mode))
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(default)]
pub struct BagLoadout {
    pub primary: String,
    pub secondary: String,
    pub melee: String,
    pub throwable: String,
    /// [PATCH] 槽位皮肤：原版皮肤属于"那把武器"，每槽独立，空 = 默认外观。
    pub primary_skin: String,
    pub secondary_skin: String,
    pub melee_skin: String,
    pub throwable_skin: String,
}

impl Default for BagLoadout {
    fn default() -> Self {
        Self {
            primary: "ak47".to_owned(),
            secondary: "deagle".to_owned(),
            melee: "nbr_knife_g".to_owned(),
            throwable: "grenade".to_owned(),
            primary_skin: String::new(),
            secondary_skin: String::new(),
            melee_skin: String::new(),
            throwable_skin: String::new(),
        }
    }
}

impl BagLoadout {
    pub fn with_primary(primary: &str) -> Self {
        Self {
            primary: primary.to_owned(),
            ..Self::default()
        }
    }

    pub fn slot(&self, index: usize) -> &str {
        match index {
            0 => &self.primary,
            1 => &self.secondary,
            2 => &self.melee,
            _ => &self.throwable,
        }
    }

    pub fn slot_mut(&mut self, index: usize) -> &mut String {
        match index {
            0 => &mut self.primary,
            1 => &mut self.secondary,
            2 => &mut self.melee,
            _ => &mut self.throwable,
        }
    }

    /// [PATCH] 槽位皮肤（空串 = 默认外观）。
    pub fn slot_skin(&self, index: usize) -> &str {
        match index {
            0 => &self.primary_skin,
            1 => &self.secondary_skin,
            2 => &self.melee_skin,
            _ => &self.throwable_skin,
        }
    }

    pub fn slot_skin_mut(&mut self, index: usize) -> &mut String {
        match index {
            0 => &mut self.primary_skin,
            1 => &mut self.secondary_skin,
            2 => &mut self.melee_skin,
            _ => &mut self.throwable_skin,
        }
    }

    /// [PATCH] 已配皮肤的槽位数（大厅摘要用）。
    pub fn skin_count(&self) -> usize {
        (0..4)
            .filter(|slot| !self.slot_skin(*slot).trim().is_empty())
            .count()
    }

    pub fn weapon_count(&self) -> usize {
        [&self.primary, &self.secondary, &self.melee, &self.throwable]
            .iter()
            .filter(|key| !key.trim().is_empty())
            .count()
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(default)]
pub struct AppSettings {
    /// 资源清单里的地图包 key，例如 maps/map1。
    pub map: String,
    pub mode: String,
    pub career: String,
    pub hand: String,
    pub weapon: String,
    /// [PATCH] 武器皮肤 key（weaponskin/<key>），空 = 默认皮肤。
    pub weapon_skin: String,
    /// [PATCH] 该皮肤所属的武器 key（每把武器各自装扮，不覆盖主武器）。
    pub weapon_skin_weapon: String,
    /// [PATCH] 角色皮肤 key（playerskin/<key>），空 = 默认皮肤。
    pub career_skin: String,
    pub bot_count: u8,
    /// [PATCH] 队友/敌人分别配置（bot_count 保留为两者之和，兼容旧配置）。
    pub ally_bot_count: u8,
    pub enemy_bot_count: u8,
    /// [PATCH] AI 难度：easy/normal/hard/nightmare/hell。
    pub bot_difficulty: String,
    pub bot_career: String,
    pub god_mode: bool,
    pub spawn: [f32; 3],
    pub game_dir: String,
    pub start_script: String,
    pub python: String,
    /// [PATCH] 地图安装脚本路径（install_map.py），为空则跳过自动安装。
    pub map_install_script: String,
    /// 原版 5 个背包，每个背包 4 个武器槽。
    pub bags: Vec<BagLoadout>,
    /// 出发生效的背包（1..=5），游戏内 B 面板仍可切换。
    pub active_bag: u8,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            map: "maps/map1".to_owned(),
            mode: MODE_TEAM.to_owned(),
            career: "police".to_owned(),
            hand: HAND_MAN.to_owned(),
            weapon: "ak47".to_owned(),
            weapon_skin: String::new(),
            weapon_skin_weapon: String::new(),
            career_skin: String::new(),
            bot_count: TEAM_ALLY_BOTS + TEAM_ENEMY_BOTS,
            ally_bot_count: TEAM_ALLY_BOTS,
            enemy_bot_count: TEAM_ENEMY_BOTS,
            bot_difficulty: "normal".to_owned(),
            bot_career: "terrorist".to_owned(),
            god_mode: false,
            spawn: [0.0, 0.0, 0.0],
            game_dir: default_game_dir(),
            start_script: default_start_script(),
            python: default_python(),
            map_install_script: default_map_install_script(),
            bags: vec![BagLoadout::default(); BAG_COUNT],
            active_bag: 1,
        }
    }
}

pub struct LoadedSettings {
    pub settings: AppSettings,
    pub warning: Option<String>,
    /// [PATCH] 迁移旧配置后产生的非阻断提示（信息级，不是错误）。
    pub notice: Option<String>,
    /// [PATCH] 加载时迁移过旧配置，需要落盘保存。
    pub needs_save: bool,
}

/// [PATCH] 旧配置人机编制迁移结果。
#[derive(Debug, Default, Clone, PartialEq, Eq)]
pub struct BotCountMigration {
    /// 是否改动了配置（需要保存）。
    pub changed: bool,
    /// 给用户的提示（0/0 已套默认，或 1/0 保留只带队友）。
    pub notice: Option<String>,
}

impl AppSettings {
    pub fn load() -> LoadedSettings {
        let path = match user_config_path() {
            Ok(path) => path,
            Err(err) => {
                return LoadedSettings {
                    settings: Self::default(),
                    warning: Some(err.to_string()),
                    notice: None,
                    needs_save: false,
                };
            }
        };

        if !path.is_file() {
            return LoadedSettings {
                settings: Self::default(),
                warning: None,
                notice: None,
                needs_save: false,
            };
        }

        match fs::read_to_string(&path)
            .context("读取大厅配置失败")
            .and_then(|text| serde_json::from_str::<Self>(&text).context("大厅配置 JSON 格式错误"))
        {
            Ok(mut settings) => {
                let migration = settings.migrate_legacy_bot_counts();
                LoadedSettings {
                    settings,
                    warning: None,
                    notice: migration.notice,
                    needs_save: migration.changed,
                }
            }
            Err(err) => LoadedSettings {
                settings: Self::default(),
                warning: Some(format!("{err:#}，已恢复默认配置")),
                notice: None,
                needs_save: false,
            },
        }
    }

    /// [PATCH] 队友 + 敌人总数（不含玩家）。
    pub fn bot_total(&self) -> u8 {
        self.ally_bot_count.saturating_add(self.enemy_bot_count)
    }

    /// [PATCH] 套用人机团战默认编制（3 队友 / 4 敌人）。
    pub fn apply_team_bot_defaults(&mut self) {
        self.ally_bot_count = TEAM_ALLY_BOTS;
        self.enemy_bot_count = TEAM_ENEMY_BOTS;
        self.bot_count = self.bot_total();
    }

    /// [PATCH] 旧配置迁移：
    /// - 团队模式且队友+敌人 == 0：说明是旧版空编制，恢复 3/4 并标记需要保存；
    /// - 团队模式且敌人 == 0 但队友 > 0：保留用户选择（只带队友），仅提示；
    /// - 其它模式不动。
    pub fn migrate_legacy_bot_counts(&mut self) -> BotCountMigration {
        let mut migration = BotCountMigration::default();
        if !is_team_mode(&self.mode) {
            return migration;
        }

        if self.bot_total() == 0 {
            self.apply_team_bot_defaults();
            migration.changed = true;
            migration.notice = Some(format!(
                "旧配置没有可用的人机编制，已恢复人机团战默认 {TEAM_ALLY_BOTS} 队友 / {TEAM_ENEMY_BOTS} 敌人"
            ));
            eprintln!(
                "[settings] legacy team config had 0 bots, applied {TEAM_ALLY_BOTS}/{TEAM_ENEMY_BOTS}"
            );
        } else if self.enemy_bot_count == 0 {
            migration.notice = Some("当前配置只带队友（敌人数量为 0），已保留你的选择".to_owned());
            eprintln!("[settings] team config has 0 enemies, keeping allies-only loadout");
        }

        migration
    }

    pub fn save(&self) -> Result<()> {
        let path = user_config_path()?;
        let parent = path.parent().context("无法定位大厅配置目录")?;
        fs::create_dir_all(parent).context("创建大厅配置目录失败")?;
        write_atomic(&path, serde_json::to_vec_pretty(self)?)
    }

    /// 将可能过期/手改过的选择修正到这份资源清单里真实可用的项目。
    /// 返回是否发生了修改。
    pub fn normalize(&mut self, inventory: &Inventory) -> bool {
        let before = self.clone();

        if !MODES.iter().any(|(name, _)| *name == self.mode) {
            self.mode = MODE_TEAM.to_owned();
        }
        self.hand = HAND_MAN.to_owned();
        self.ally_bot_count = self.ally_bot_count.min(6);
        self.enemy_bot_count = self.enemy_bot_count.min(8);
        if self.ally_bot_count as u16 + self.enemy_bot_count as u16 > 12 {
            self.enemy_bot_count = 12u8.saturating_sub(self.ally_bot_count);
        }
        if !DIFFICULTIES
            .iter()
            .any(|(name, _)| *name == self.bot_difficulty)
        {
            self.bot_difficulty = "normal".to_owned();
        }
        self.bot_count = self.ally_bot_count.saturating_add(self.enemy_bot_count);
        if !self.bot_career.eq_ignore_ascii_case("police")
            && !self.bot_career.eq_ignore_ascii_case("terrorist")
        {
            self.bot_career = "terrorist".to_owned();
        }
        if self.spawn.iter().any(|v| !v.is_finite()) {
            self.spawn = [0.0, 0.0, 0.0];
        }

        let map_ok = inventory.map(&self.map).is_some_and(|map| map.available());
        if !map_ok {
            if let Some(map) = inventory.maps.iter().find(|map| map.available()) {
                self.map = map.key.clone();
            }
        }

        let weapon_ok = inventory
            .weapon(&self.weapon)
            .is_some_and(|weapon| weapon.complete);
        if !weapon_ok {
            self.weapon = if inventory
                .weapon("ak47")
                .is_some_and(|weapon| weapon.complete)
            {
                "ak47".to_owned()
            } else {
                inventory
                    .weapons
                    .iter()
                    .find(|weapon| weapon.complete)
                    .map(|weapon| weapon.key.clone())
                    .unwrap_or_default()
            };
        }

        let character_ok = inventory
            .character(&self.career)
            .is_some_and(|character| character.selectable());
        if !character_ok {
            self.career = if inventory
                .character("police")
                .is_some_and(|character| character.selectable())
            {
                "police".to_owned()
            } else {
                inventory
                    .characters
                    .iter()
                    .find(|character| character.selectable())
                    .map(|character| character.key.clone())
                    .unwrap_or_default()
            };
        }

        // [PATCH] 皮肤校验：非空但清单里没有/资源不完整 -> 回落默认皮肤（空串）。
        if !self.weapon_skin.trim().is_empty()
            && !inventory
                .weapon_skin(self.weapon_skin.trim())
                .is_some_and(|skin| skin.complete)
        {
            self.weapon_skin = String::new();
        }
        if self.weapon_skin.trim().is_empty() {
            self.weapon_skin_weapon.clear();
        }
        // Restore only a complete skin explicitly linked to the selected role.
        // The canonical key is written to launch_config, even for older saves
        // containing different casing or surrounding whitespace.
        self.career_skin = inventory
            .career_skin(&self.career_skin)
            .filter(|skin| skin.complete && skin.belongs_to(&self.career))
            .map(|skin| skin.key.clone())
            .unwrap_or_default();

        // 5 背包 × 4 槽：旧配置只有 weapon 字段时，把它装进 1 号背包主武器位。
        let default_primary = if self.weapon.trim().is_empty() {
            "ak47".to_owned()
        } else {
            self.weapon.clone()
        };
        if self.bags.len() < BAG_COUNT {
            self.bags
                .resize_with(BAG_COUNT, || BagLoadout::with_primary(&default_primary));
        }
        self.bags.truncate(BAG_COUNT);
        for bag in &mut self.bags {
            for slot in 0..4 {
                let key = bag.slot(slot).trim().to_owned();
                let valid = inventory
                    .weapon(&key)
                    .is_some_and(|weapon| weapon.complete && slot_accepts(slot, weapon.category()));
                if !valid {
                    let fallback = fallback_for_slot(inventory, slot, &default_primary);
                    *bag.slot_mut(slot) = fallback;
                }
                // [PATCH] 槽位皮肤：只清"资源缺失/不属于该槽位武器"的项，合法新字段必须保留。
                let weapon_key = bag.slot(slot).to_owned();
                let skin = bag.slot_skin(slot).trim().to_owned();
                if !skin.is_empty() && !skin_fits_weapon(inventory, &skin, &weapon_key) {
                    *bag.slot_skin_mut(slot) = String::new();
                }
            }
        }
        if self.active_bag < 1 || self.active_bag as usize > BAG_COUNT {
            self.active_bag = 1;
        }
        self.weapon = self.bags[self.active_bag as usize - 1].primary.clone();

        *self != before
    }
}

/// 原版槽位有固定类别：主武器只能放枪，副武器手枪，近战刀，投掷雷。
/// `Other` 是弹弓/无人机/加特林等特殊枪械，只允许进主武器槽。
pub fn slot_accepts(slot: usize, category: crate::inventory::WeaponCategory) -> bool {
    use crate::inventory::WeaponCategory;

    match slot {
        0 => matches!(
            category,
            WeaponCategory::Rifle
                | WeaponCategory::Sniper
                | WeaponCategory::Shotgun
                | WeaponCategory::Other
        ),
        1 => category == WeaponCategory::Pistol,
        2 => category == WeaponCategory::Melee,
        _ => category == WeaponCategory::Grenade,
    }
}

/// [PATCH] 皮肤是否属于这把武器（原版皮肤绑定武器，不跨枪）。
/// 清单未能归属（base 为空）时退化为"武器名出现在皮肤名里"。
pub fn skin_fits_weapon(inventory: &Inventory, skin: &str, weapon: &str) -> bool {
    let Some(item) = inventory.weapon_skin(skin.trim()) else {
        return false;
    };
    if weapon.trim().is_empty() {
        return false;
    }
    if item.base.trim().is_empty() {
        return skin
            .to_ascii_lowercase()
            .contains(&weapon.trim().to_ascii_lowercase());
    }
    if item.base.eq_ignore_ascii_case(weapon.trim()) {
        return true;
    }
    // Some table rows name the shared weapon family with a trailing model
    // variant `1` (for example *_legend1), while the loadout key omits it.
    item.base
        .strip_suffix('1')
        .is_some_and(|base| base.eq_ignore_ascii_case(weapon.trim()))
}

/// 某把武器关联的全部皮肤条目；第二项表示本地模型资源包是否完整。
pub fn skins_for_weapon(inventory: &Inventory, weapon: &str) -> Vec<WeaponSkin> {
    let key = weapon.trim();
    if key.is_empty() {
        return Vec::new();
    }
    inventory
        .weapon_skins
        .iter()
        .filter(|skin| skin_fits_weapon(inventory, &skin.key, key))
        .cloned()
        .collect()
}

fn fallback_for_slot(inventory: &Inventory, slot: usize, preferred: &str) -> String {
    use crate::inventory::WeaponCategory;

    let allowed: &[WeaponCategory] = match slot {
        0 => &[
            WeaponCategory::Rifle,
            WeaponCategory::Sniper,
            WeaponCategory::Shotgun,
            WeaponCategory::Other,
        ],
        1 => &[WeaponCategory::Pistol],
        2 => &[WeaponCategory::Melee],
        _ => &[WeaponCategory::Grenade],
    };
    let preferred_ok = inventory
        .weapon(preferred)
        .is_some_and(|weapon| weapon.complete && slot_accepts(slot, weapon.category()));
    if preferred_ok {
        return preferred.to_owned();
    }
    // 原版默认槽位固定，仓库扩容后不能因为排序变化把默认枪换成冷门武器。
    let canonical: &[&str] = match slot {
        0 => &["ak47"],
        1 => &["deagle", "92fs"],
        2 => &["nbr_knife_g"],
        _ => &["grenade"],
    };
    for key in canonical {
        if inventory
            .weapon(key)
            .is_some_and(|weapon| weapon.complete && slot_accepts(slot, weapon.category()))
        {
            return (*key).to_owned();
        }
    }
    for category in allowed {
        if let Some(weapon) = inventory
            .weapons
            .iter()
            .find(|weapon| weapon.complete && weapon.category() == *category)
        {
            return weapon.key.clone();
        }
    }
    inventory
        .weapons
        .iter()
        .find(|weapon| weapon.complete)
        .map(|weapon| weapon.key.clone())
        .unwrap_or_else(|| preferred.to_owned())
}

impl PartialEq for AppSettings {
    fn eq(&self, other: &Self) -> bool {
        self.map == other.map
            && self.mode == other.mode
            && self.career == other.career
            && self.hand == other.hand
            && self.weapon == other.weapon
            && self.weapon_skin == other.weapon_skin
            && self.weapon_skin_weapon == other.weapon_skin_weapon
            && self.career_skin == other.career_skin
            && self.bot_count == other.bot_count
            && self.ally_bot_count == other.ally_bot_count
            && self.enemy_bot_count == other.enemy_bot_count
            && self.bot_difficulty == other.bot_difficulty
            && self.bot_career == other.bot_career
            && self.god_mode == other.god_mode
            && self.spawn == other.spawn
            && self.game_dir == other.game_dir
            && self.start_script == other.start_script
            && self.python == other.python
            && self.map_install_script == other.map_install_script
            && self.bags == other.bags
            && self.active_bag == other.active_bag
    }
}

pub fn user_config_path() -> Result<PathBuf> {
    let base = env::var_os("APPDATA")
        .map(PathBuf::from)
        .context("环境变量 APPDATA 不存在")?;
    Ok(base.join("ssjj-lobby").join("config.json"))
}

pub fn launch_config_path(settings: &AppSettings) -> PathBuf {
    Path::new(settings.game_dir.trim()).join("launch_config.json")
}

pub fn map_config_id(map_key: &str) -> &str {
    map_key.rsplit('/').next().unwrap_or(map_key)
}

pub fn write_atomic(path: &Path, bytes: Vec<u8>) -> Result<()> {
    let parent = path.parent().context("目标文件没有父目录")?;
    if !parent.is_dir() {
        bail!("目录不存在：{}", parent.display());
    }
    let tmp = path.with_extension("json.tmp");
    fs::write(&tmp, bytes).with_context(|| format!("写入临时文件失败：{}", tmp.display()))?;
    if let Err(first) = fs::rename(&tmp, path) {
        let _ = fs::remove_file(path);
        fs::rename(&tmp, path)
            .with_context(|| format!("替换文件失败：{}（首次错误：{first}）", path.display()))?;
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::inventory::Inventory;

    #[test]
    fn defaults_match_the_launch_contract() {
        let settings = AppSettings::default();
        assert_eq!(settings.map, "maps/map1");
        assert_eq!(settings.mode, "team");
        assert_eq!(settings.career, "police");
        assert_eq!(settings.hand, "man");
        assert_eq!(settings.weapon, "ak47");
        // [PATCH] 人机团战默认编制：玩家 + 3 队友 vs 4 敌人（原版 MaxPlayers=8）。
        assert_eq!(settings.bot_count, 7);
        assert_eq!(settings.ally_bot_count, 3);
        assert_eq!(settings.enemy_bot_count, 4);
        assert_eq!(settings.bot_career, "terrorist");
        assert!(!settings.god_mode);
        assert_eq!(settings.spawn, [0.0, 0.0, 0.0]);
    }

    #[test]
    fn team_mode_aliases_are_recognized() {
        for mode in [
            "team",
            "team_ai",
            "teamai",
            "team_mode",
            "group",
            "bot_team",
            "team2003",
            "team_2003",
            " TEAM ",
        ] {
            assert!(is_team_mode(mode), "{mode} 应视为团队模式");
        }
        for mode in [
            "personal",
            "explode",
            "deathmatch",
            "blade",
            "flyknife",
            "weaponmaster",
            "",
        ] {
            assert!(!is_team_mode(mode), "{mode} 不应视为团队模式");
        }
    }

    #[test]
    fn legacy_team_zero_bots_falls_back_to_three_and_four() {
        // 模拟旧版配置：团队模式但编制被写成 0/0（进游戏只有自己，没法打团战）。
        let mut settings: AppSettings = serde_json::from_str(
            r#"{
                "mode": "team",
                "bot_count": 0,
                "ally_bot_count": 0,
                "enemy_bot_count": 0
            }"#,
        )
        .unwrap();
        assert_eq!(settings.bot_total(), 0);

        let migration = settings.migrate_legacy_bot_counts();
        assert!(migration.changed, "0/0 应触发迁移并标记需要保存");
        assert!(migration.notice.is_some());
        assert_eq!(settings.ally_bot_count, 3);
        assert_eq!(settings.enemy_bot_count, 4);
        assert_eq!(settings.bot_count, 7);

        // 迁移是幂等的：再次执行不会再改动。
        let again = settings.migrate_legacy_bot_counts();
        assert!(!again.changed);
    }

    #[test]
    fn legacy_allies_only_config_is_kept() {
        // 用户故意只带队友：1/0 不能被强行改成 3/4。
        let mut settings: AppSettings = serde_json::from_str(
            r#"{
                "mode": "team_ai",
                "bot_count": 1,
                "ally_bot_count": 1,
                "enemy_bot_count": 0
            }"#,
        )
        .unwrap();

        let migration = settings.migrate_legacy_bot_counts();
        assert!(!migration.changed, "只带队友是合法选择，不应迁移");
        assert!(migration.notice.is_some(), "应记录只带队友的提示");
        assert_eq!(settings.ally_bot_count, 1);
        assert_eq!(settings.enemy_bot_count, 0);
        assert_eq!(settings.bot_count, 1);

        // 后续 normalize 不应崩溃或改动编制。
        let inv = Inventory::load_embedded().unwrap();
        settings.normalize(&inv);
        assert_eq!(settings.ally_bot_count, 1);
        assert_eq!(settings.enemy_bot_count, 0);
        assert_eq!(settings.bot_count, 1);
    }

    #[test]
    fn non_team_modes_are_not_migrated() {
        let mut settings = AppSettings::default();
        settings.mode = "explode".to_owned();
        settings.ally_bot_count = 0;
        settings.enemy_bot_count = 0;
        settings.bot_count = 0;

        let migration = settings.migrate_legacy_bot_counts();
        assert!(!migration.changed);
        assert_eq!(settings.ally_bot_count, 0);
        assert_eq!(settings.enemy_bot_count, 0);
    }

    #[test]
    fn normalize_replaces_unavailable_choices() {
        let inv = Inventory::load_embedded().unwrap();
        let mut settings = AppSettings::default();
        // [PATCH] 587 张地图全部可玩，map43 现在是合法选择，不再被改写。
        settings.map = "maps/map43".to_owned();
        settings.weapon = "pvegatling".to_owned();
        settings.career = "freya".to_owned();
        settings.bot_count = 99;
        settings.ally_bot_count = 9;
        settings.enemy_bot_count = 9;
        settings.mode = "not_a_mode".to_owned();

        assert!(settings.normalize(&inv));
        assert_eq!(settings.map, "maps/map43");
        assert_eq!(settings.weapon, "ak47");
        assert_eq!(settings.career, "police");
        // 队友上限 6、总上限 12：9+9 -> 6+6 = 12
        assert_eq!(settings.ally_bot_count, 6);
        assert_eq!(settings.enemy_bot_count, 6);
        assert_eq!(settings.bot_count, 12);
        assert_eq!(settings.mode, "team");
    }

    #[test]
    fn normalize_keeps_valid_skins_and_drops_invalid_ones() {
        let inv = Inventory::load_embedded().unwrap();
        let mut settings = AppSettings::default();
        settings.weapon_skin = "skin_ak47_g_12years".to_owned();
        let skin = inv
            .career_skins
            .iter()
            .find(|skin| {
                skin.complete
                    && inv.character(&skin.player).is_some_and(|role| role.selectable())
            })
            .expect("inventory should have a complete skin associated with a playable role");
        settings.career = skin.player.clone();
        settings.career_skin = format!(" {} ", skin.key.to_uppercase());

        // 同角色的完整皮肤会恢复，旧配置的大小写和空白会规范化。
        settings.normalize(&inv);
        assert_eq!(settings.weapon_skin, "skin_ak47_g_12years");
        assert_eq!(settings.career_skin, skin.key);

        // 只切换角色而残留旧皮肤的配置，必须恢复新角色默认外观。
        settings.career = inv
            .characters
            .iter()
            .find(|role| role.selectable() && !skin.belongs_to(&role.key))
            .expect("another playable role")
            .key
            .clone();
        assert!(settings.normalize(&inv));
        assert!(settings.career_skin.is_empty());

        // 不存在的皮肤 -> 回落默认（空串）
        settings.weapon_skin = "not_a_skin".to_owned();
        settings.career_skin = "also_missing".to_owned();
        assert!(settings.normalize(&inv));
        assert!(settings.weapon_skin.is_empty());
        assert!(settings.career_skin.is_empty());
    }

    #[test]
    fn normalize_keeps_slot_skins_per_bag() {
        let inv = Inventory::load_embedded().unwrap();
        let mut settings = AppSettings::default();
        // bag1 主武器 ak47_g 皮肤 A；bag2 主武器另一把枪的皮肤 B（互不影响）。
        settings.bags[0].primary = "ak47_g".to_owned();
        settings.weapon = "ak47_g".to_owned();
        settings.bags[0].primary_skin = "skin_ak47_g_12years".to_owned();
        settings.bags[1].primary = "thunder_submachinegun_legend".to_owned();
        let b_skin = inv
            .weapon_skins
            .iter()
            .find(|skin| {
                skin.complete
                    && (skin
                        .base
                        .eq_ignore_ascii_case("thunder_submachinegun_legend")
                        || skin.base.strip_suffix('1').is_some_and(|base| {
                            base.eq_ignore_ascii_case("thunder_submachinegun_legend")
                        }))
            })
            .map(|skin| skin.key.clone())
            .expect("inventory should carry thunder_submachinegun_legend skins");
        settings.bags[1].primary_skin = b_skin.clone();

        assert!(!settings.normalize(&inv), "合法的槽位皮肤不应被清掉");
        assert_eq!(settings.bags[0].primary_skin, "skin_ak47_g_12years");
        assert_eq!(settings.bags[1].primary_skin, b_skin);
        assert!(settings.bags[2].primary_skin.is_empty());

        // 皮肤不属于该槽位武器（换枪遗留）-> 清空，避免皮肤跟着别的枪。
        settings.bags[0].primary = "thunder_submachinegun_legend".to_owned();
        assert!(settings.normalize(&inv));
        assert!(settings.bags[0].primary_skin.is_empty());
        assert_eq!(settings.bags[1].primary_skin, b_skin);

        // 不存在的皮肤同样回落默认。
        settings.bags[1].primary_skin = "not_a_skin".to_owned();
        assert!(settings.normalize(&inv));
        assert!(settings.bags[1].primary_skin.is_empty());
    }

    #[test]
    fn normalize_keeps_supported_modes() {
        let inv = Inventory::load_embedded().unwrap();
        let mut settings = AppSettings::default();
        settings.mode = "explode".to_owned();
        settings.normalize(&inv);
        assert_eq!(settings.mode, "explode");
        assert_eq!(mode_label("explode"), "爆破模式");
        assert_eq!(mode_label("???"), "团队模式");
    }

    #[test]
    fn normalize_moves_weapons_out_of_wrong_slots() {
        let inv = Inventory::load_embedded().unwrap();
        let mut settings = AppSettings::default();
        settings.bags[0].primary = "nbr_knife_g".to_owned();
        settings.bags[0].secondary = "grenade".to_owned();
        settings.bags[0].throwable = "ak47".to_owned();
        settings.weapon = "nbr_knife_g".to_owned();

        assert!(settings.normalize(&inv));
        let bag = &settings.bags[0];
        assert_eq!(bag.primary, "ak47");
        let secondary = inv.weapon(&bag.secondary).unwrap();
        assert_eq!(
            secondary.category(),
            crate::inventory::WeaponCategory::Pistol
        );
        let throwable = inv.weapon(&bag.throwable).unwrap();
        assert_eq!(
            throwable.category(),
            crate::inventory::WeaponCategory::Grenade
        );
        assert_eq!(settings.weapon, "ak47");
    }

    #[test]
    fn slot_accepts_matches_original_loadout_rules() {
        use crate::inventory::WeaponCategory as C;
        assert!(slot_accepts(0, C::Rifle));
        assert!(slot_accepts(0, C::Other));
        assert!(!slot_accepts(0, C::Melee));
        assert!(slot_accepts(1, C::Pistol));
        assert!(!slot_accepts(1, C::Grenade));
        assert!(slot_accepts(2, C::Melee));
        assert!(!slot_accepts(2, C::Pistol));
        assert!(slot_accepts(3, C::Grenade));
        assert!(!slot_accepts(3, C::Other));
    }

    #[test]
    fn map_id_is_derived_from_package_key() {
        assert_eq!(map_config_id("maps/map1"), "map1");
        assert_eq!(map_config_id("maps/map43"), "map43");
        assert_eq!(map_config_id("unitymaps/map_1"), "map_1");
    }
}
