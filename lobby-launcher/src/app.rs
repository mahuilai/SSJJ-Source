use std::collections::HashMap;
use std::path::Path;
use std::time::{Duration, Instant};

use eframe::egui::{
    self, Align, Align2, Color32, CursorIcon, FontId, Frame, Layout, Margin, Rect, Response,
    RichText, Rounding, ScrollArea, Sense, Shape, Stroke, Ui, Vec2,
};

use crate::inventory::{
    Character, CharacterKind, Collectible, GameMap, Inventory, MapAvailability, Weapon,
    WeaponCategory,
};
use crate::launcher::{LaunchMonitor, LaunchPhase, MonitorEvent};
use crate::settings::{self, AppSettings, BagLoadout, LoadedSettings};
use crate::theme;

const TITLEBAR_HEIGHT: f32 = 48.0;
const SIDEBAR_WIDTH: f32 = 208.0;
const FOOTER_HEIGHT: f32 = 88.0;
const MAP_MIN_WIDTH: f32 = 248.0;
const CHARACTER_MIN_WIDTH: f32 = 124.0;
const WEAPON_MIN_WIDTH: f32 = 178.0;
const AVATAR_COLORS: [Color32; 7] = [
    Color32::from_rgb(101, 132, 255),
    Color32::from_rgb(88, 174, 201),
    Color32::from_rgb(116, 186, 138),
    Color32::from_rgb(164, 134, 235),
    Color32::from_rgb(220, 121, 121),
    Color32::from_rgb(131, 155, 222),
    Color32::from_rgb(200, 176, 111),
];

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Page {
    Maps,
    Characters,
    Weapons,
    /// [PATCH] 喷漆仓库（spray），原版个性化系统之一。
    Sprays,
    /// [PATCH] 饰品 / 时装部件仓库（accessory + avatarplayer）。
    Cosmetics,
    Honors,
    OnlineServices,
    Settings,
}

impl Page {
    fn label(self) -> &'static str {
        match self {
            Self::Maps => "地图",
            Self::Characters => "角色",
            Self::Weapons => "仓库",
            Self::Sprays => "喷漆",
            Self::Cosmetics => "饰品",
            Self::Honors => "勋章 / 称号",
            Self::OnlineServices => "在线功能",
            Self::Settings => "设置",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum WindowButton {
    Minimize,
    Maximize,
    Close,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum CharacterFilter {
    All,
    Available,
    Missing,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum NoticeKind {
    Info,
    Success,
    Error,
}

#[derive(Debug, Clone)]
struct Notice {
    text: String,
    kind: NoticeKind,
    until: Instant,
}

impl Notice {
    fn new(kind: NoticeKind, text: impl Into<String>) -> Self {
        let duration = match kind {
            NoticeKind::Error => Duration::from_secs(9),
            NoticeKind::Info | NoticeKind::Success => Duration::from_secs(5),
        };
        Self {
            text: text.into(),
            kind,
            until: Instant::now() + duration,
        }
    }

    fn colors(&self) -> (Color32, Color32, Color32) {
        match self.kind {
            NoticeKind::Info => (theme::TEXT, theme::INFO_SOFT, theme::LINE),
            NoticeKind::Success => (theme::SUCCESS, theme::SUCCESS_SOFT, theme::SUCCESS_DEEP),
            NoticeKind::Error => (theme::DANGER, theme::DANGER_SOFT, theme::DANGER_DEEP),
        }
    }
}

#[derive(Default)]
struct PreviewCache {
    textures: HashMap<(&'static str, String), Option<egui::TextureHandle>>,
}

impl PreviewCache {
    const LIMIT: usize = 600;

    fn get(
        &mut self,
        ctx: &egui::Context,
        kind: &'static str,
        key: &str,
    ) -> Option<&egui::TextureHandle> {
        if self.textures.len() >= Self::LIMIT {
            // 全量仓库有 2000+ 张预览图，全部常驻会占掉数百 MB 显存；超限后只保留当前可见项。
            self.textures.clear();
        }
        let entry = self
            .textures
            .entry((kind, key.to_owned()))
            .or_insert_with(|| {
                let bytes = crate::official_preview::read(kind, key)?;
                let image = image::load_from_memory(&bytes).ok()?.to_rgba8();
                let size = [image.width() as usize, image.height() as usize];
                let pixels = egui::ColorImage::from_rgba_unmultiplied(size, image.as_raw());
                Some(ctx.load_texture(
                    format!("preview-{kind}-{key}"),
                    pixels,
                    egui::TextureOptions::LINEAR,
                ))
            });
        entry.as_ref()
    }

    /// 皮肤预览只读取大厅单品 SWF 里确实存在的皮肤图，不用基础枪图或材质贴图代替。
    fn get_skin(
        &mut self,
        ctx: &egui::Context,
        skin: &str,
        weapon: &str,
    ) -> Option<&egui::TextureHandle> {
        let skin = skin.trim();
        if skin.is_empty() {
            return self.get(ctx, "weapon", weapon);
        }
        if self.textures.len() >= Self::LIMIT {
            self.textures.clear();
        }
        let cache_key = format!("{skin}\u{1}{weapon}");
        let entry = self
            .textures
            .entry(("skin", cache_key.clone()))
            .or_insert_with(|| {
                let bytes = crate::official_preview::read("skin", skin)?;
                let image = image::load_from_memory(&bytes).ok()?.to_rgba8();
                let size = [image.width() as usize, image.height() as usize];
                let pixels = egui::ColorImage::from_rgba_unmultiplied(size, image.as_raw());
                Some(ctx.load_texture(
                    format!("preview-skin-{cache_key}"),
                    pixels,
                    egui::TextureOptions::LINEAR,
                ))
            });
        entry.as_ref()
    }
}

/// [PATCH] 皮肤选择弹窗状态：绑定到"某个背包的某个槽位"，不会串到其它背包。
#[derive(Clone)]
struct SkinPicker {
    bag: usize,
    slot: usize,
    weapon: String,
    search: String,
}

/// [PATCH] 槽位皮肤行的点击结果。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum SkinRowAction {
    None,
    Pick,
    Clear,
}

pub struct LobbyApp {
    inventory: Inventory,
    settings: AppSettings,
    profile: crate::profile::PlayerProfile,
    page: Page,
    character_filter: CharacterFilter,
    character_kind: Option<CharacterKind>,
    character_search: String,
    /// [PATCH] 角色皮肤搜索（85 个皮肤里快速定位）。
    career_skin_search: String,
    /// [PATCH] 喷漆仓库搜索 + 筛选。
    spray_search: String,
    spray_available_only: bool,
    /// [PATCH] 饰品/时装仓库搜索 + 分组筛选。
    cosmetic_search: String,
    cosmetic_group: Option<&'static str>,
    cosmetic_available_only: bool,
    honor_search: String,
    honor_show_titles: bool,
    weapon_category: Option<WeaponCategory>,
    weapons_available_only: bool,
    weapon_search: String,
    /// [PATCH] 皮肤选择弹窗（每个背包槽位独立，不做全局单皮肤）。
    skin_picker: Option<SkinPicker>,
    /// 仓库武器网格分页（4 行/页）。
    weapon_page: usize,
    warehouse_slot: usize,
    warehouse_show_all: bool,
    warehouse_show_skins: bool,
    previews: PreviewCache,
    logo: Option<egui::TextureHandle>,
    launch: LaunchMonitor,
    font_name: Option<String>,
    font_error: Option<String>,
    notice: Option<Notice>,
}

impl LobbyApp {
    pub fn new(
        mut inventory: Inventory,
        loaded: LoadedSettings,
        font_name: Option<String>,
        font_error: Option<String>,
    ) -> Self {
        let LoadedSettings {
            mut settings,
            warning,
            notice: load_notice,
            needs_save,
        } = loaded;
        inventory.refresh_map_readiness(&settings.game_dir, &settings.map_install_script);
        let loaded_profile = crate::profile::PlayerProfile::load(&inventory);
        let normalized = settings.normalize(&inventory);
        let mut notice = warning.map(|warning| Notice::new(NoticeKind::Error, warning));
        if notice.is_none() {
            notice = loaded_profile
                .warning
                .as_ref()
                .map(|warning| Notice::new(NoticeKind::Error, warning.clone()));
        }
        if notice.is_none() {
            notice = load_notice.map(|text| Notice::new(NoticeKind::Info, text));
        }
        if normalized && notice.is_none() {
            notice = Some(Notice::new(
                NoticeKind::Info,
                "已按当前资源清单修正上次失效的选择",
            ));
        }

        let mut app = Self {
            inventory,
            settings,
            profile: loaded_profile.profile,
            page: Page::Characters,
            character_filter: CharacterFilter::All,
            character_kind: None,
            character_search: String::new(),
            career_skin_search: String::new(),
            spray_search: String::new(),
            spray_available_only: false,
            cosmetic_search: String::new(),
            cosmetic_group: None,
            cosmetic_available_only: false,
            honor_search: String::new(),
            honor_show_titles: false,
            weapon_category: None,
            weapons_available_only: false,
            weapon_search: String::new(),
            skin_picker: None,
            weapon_page: 0,
            warehouse_slot: 0,
            warehouse_show_all: true,
            warehouse_show_skins: false,
            previews: PreviewCache::default(),
            logo: None,
            launch: LaunchMonitor::new(),
            font_name,
            font_error,
            notice,
        };

        if normalized || needs_save {
            if let Err(err) = app.settings.save() {
                app.notice = Some(Notice::new(
                    NoticeKind::Error,
                    format!("保存大厅配置失败：{err:#}"),
                ));
            }
        }
        if loaded_profile.needs_save {
            if let Err(err) = app.profile.save() {
                app.notice = Some(Notice::new(
                    NoticeKind::Error,
                    format!("保存本地玩家资料失败：{err:#}"),
                ));
            }
        }
        if let Err(err) = crate::preview_bridge::sync(&app.settings, &app.profile) {
            app.notice = Some(Notice::new(
                NoticeKind::Error,
                format!("同步本地 3D 展台状态失败：{err:#}"),
            ));
        }

        app
    }

    fn save_settings(&mut self) {
        self.inventory
            .refresh_map_readiness(&self.settings.game_dir, &self.settings.map_install_script);
        if let Err(err) = self.settings.save() {
            self.notice = Some(Notice::new(
                NoticeKind::Error,
                format!("保存大厅配置失败：{err:#}"),
            ));
        }
        if let Err(err) = crate::preview_bridge::sync(&self.settings, &self.profile) {
            self.notice = Some(Notice::new(
                NoticeKind::Error,
                format!("同步本地 3D 展台状态失败：{err:#}"),
            ));
        }
    }

    fn save_profile(&mut self) {
        if let Err(err) = self.profile.save() {
            self.notice = Some(Notice::new(
                NoticeKind::Error,
                format!("保存本地玩家资料失败：{err:#}"),
            ));
        }
        if let Err(err) = crate::preview_bridge::sync(&self.settings, &self.profile) {
            self.notice = Some(Notice::new(
                NoticeKind::Error,
                format!("同步本地 3D 展台状态失败：{err:#}"),
            ));
        }
    }

    fn toast(&mut self, kind: NoticeKind, text: impl Into<String>) {
        self.notice = Some(Notice::new(kind, text));
    }

    fn title_bar(&mut self, ctx: &egui::Context) {
        let maximized = ctx.input(|input| input.viewport().maximized.unwrap_or(false));

        egui::TopBottomPanel::top("lobby-titlebar")
            .exact_height(TITLEBAR_HEIGHT)
            .frame(Frame::none().fill(theme::TOP))
            .show(ctx, |ui| {
                let bar = ui.max_rect();
                let drag = ui.interact(
                    bar,
                    egui::Id::new("lobby-titlebar-drag"),
                    Sense::click_and_drag(),
                );
                if drag.drag_started() {
                    ctx.send_viewport_cmd(egui::ViewportCommand::StartDrag);
                }
                if drag.double_clicked() {
                    ctx.send_viewport_cmd(egui::ViewportCommand::Maximized(!maximized));
                }
                ui.painter().hline(
                    bar.x_range(),
                    bar.bottom() - 0.5,
                    Stroke::new(1.0_f32, theme::LINE_SOFT),
                );

                ui.horizontal_centered(|ui| {
                    ui.add_space(14.0);

                    let (logo_rect, _) = ui.allocate_exact_size(Vec2::splat(30.0), Sense::hover());
                    // [PATCH] 左上角改成原版生死狙击图标（assets/icon.png，随 exe 内嵌）。
                    let tex_id = {
                        let tex = self.logo.get_or_insert_with(|| {
                            let bytes = include_bytes!("../assets/icon.png");
                            let img = image::load_from_memory(bytes)
                                .expect("assets/icon.png 解码失败")
                                .to_rgba8();
                            let size = [img.width() as usize, img.height() as usize];
                            let color =
                                egui::ColorImage::from_rgba_unmultiplied(size, img.as_raw());
                            ui.ctx()
                                .load_texture("ssjj-logo", color, egui::TextureOptions::LINEAR)
                        });
                        tex.id()
                    };
                    ui.painter().image(
                        tex_id,
                        logo_rect,
                        egui::Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0)),
                        egui::Color32::WHITE,
                    );

                    ui.add_space(9.0);
                    ui.label(
                        RichText::new("生死狙击")
                            .size(15.5)
                            .strong()
                            .color(theme::TEXT),
                    );
                    ui.add_space(3.0);
                    ui.label(RichText::new("离线作战大厅").size(10.5).color(theme::FAINT));
                    ui.add_space(9.0);
                    theme::pill(ui, "本地资源", theme::SUCCESS, theme::SUCCESS_SOFT);

                    ui.with_layout(Layout::right_to_left(Align::Center), |ui| {
                        ui.spacing_mut().item_spacing.x = 2.0;
                        ui.add_space(5.0);
                        window_button(ui, ctx, WindowButton::Close, maximized);
                        window_button(ui, ctx, WindowButton::Maximize, maximized);
                        window_button(ui, ctx, WindowButton::Minimize, maximized);
                        ui.add_space(12.0);

                        ui.spacing_mut().item_spacing.x = 7.0;
                        let weapon = self
                            .inventory
                            .weapon(&self.settings.weapon)
                            .map(|weapon| elide(weapon.display_name(), 12))
                            .unwrap_or_else(|| self.settings.weapon.clone());
                        let career = career_label(&self.settings.career);
                        let map = self
                            .inventory
                            .map(&self.settings.map)
                            .map(|map| map.id.clone())
                            .unwrap_or_else(|| self.settings.map.clone());

                        theme::chip(ui, "玩家", &elide(&self.profile.player_name, 12));
                        theme::chip(ui, "VIP", &self.profile.vip_level.to_string());
                        theme::chip(ui, &format!("背包{}", self.settings.active_bag), &weapon);
                        theme::chip(ui, "模式", settings::mode_label(&self.settings.mode));
                        theme::chip(ui, "角色", career);
                        theme::chip(ui, "地图", &map);
                    });
                });
            });
    }

    fn sidebar(&mut self, ctx: &egui::Context) {
        egui::SidePanel::left("lobby-sidebar")
            .exact_width(SIDEBAR_WIDTH)
            .resizable(false)
            .frame(theme::panel_frame(
                theme::SIDEBAR,
                Margin::symmetric(12.0, 16.0),
            ))
            .show(ctx, |ui| {
                ui.spacing_mut().item_spacing.y = 6.0;
                theme::section_label(ui, "作战配置");
                ui.add_space(4.0);

                if nav_item(ui, Page::Maps, self.page, Some(self.inventory.maps.len())) {
                    self.page = Page::Maps;
                }
                if nav_item(
                    ui,
                    Page::Characters,
                    self.page,
                    Some(self.inventory.characters.len()),
                ) {
                    self.page = Page::Characters;
                }
                if nav_item(
                    ui,
                    Page::Weapons,
                    self.page,
                    Some(self.inventory.weapons.len()),
                ) {
                    self.page = Page::Weapons;
                }

                ui.add_space(12.0);
                theme::section_label(ui, "装扮仓库");
                ui.add_space(4.0);
                if nav_item(
                    ui,
                    Page::Sprays,
                    self.page,
                    Some(self.inventory.sprays.len()),
                ) {
                    self.page = Page::Sprays;
                }
                if nav_item(
                    ui,
                    Page::Cosmetics,
                    self.page,
                    Some(self.inventory.accessories.len() + self.inventory.avatar_parts.len()),
                ) {
                    self.page = Page::Cosmetics;
                }
                if nav_item(
                    ui,
                    Page::Honors,
                    self.page,
                    Some(self.inventory.medals.len() + self.inventory.titles.len()),
                ) {
                    self.page = Page::Honors;
                }

                if nav_item(ui, Page::OnlineServices, self.page, Some(8)) {
                    self.page = Page::OnlineServices;
                }

                ui.add_space(12.0);
                theme::section_label(ui, "启动器");
                ui.add_space(4.0);
                if nav_item(ui, Page::Settings, self.page, None) {
                    self.page = Page::Settings;
                }

                ui.with_layout(Layout::bottom_up(Align::LEFT), |ui| {
                    ui.label(
                        RichText::new("v0.1.0 · 单机大厅")
                            .size(10.5)
                            .color(theme::FAINT),
                    );
                    ui.add_space(4.0);
                    theme::hline(ui);
                    ui.add_space(3.0);
                    ui.label(
                        RichText::new(format!(
                            "{} 武器  ·  {} 角色  ·  {} 地图",
                            self.inventory.weapons.len(),
                            self.inventory.characters.len(),
                            self.inventory.maps.len()
                        ))
                        .size(10.5)
                        .color(theme::FAINT),
                    );
                    ui.add_space(3.0);
                    ui.label(
                        RichText::new("资源清单已加载")
                            .size(10.5)
                            .color(theme::SUCCESS),
                    );
                });
            });
    }

    fn bottom_bar(&mut self, ctx: &egui::Context) {
        let phase = self.launch.phase().clone();
        let busy = self.launch.is_busy();
        let (status_color, title, detail, button_text) = match &phase {
            LaunchPhase::Idle => (
                theme::SUCCESS,
                "准备就绪".to_owned(),
                "启动时将写入 launch_config.json，并调用 start_offline.py".to_owned(),
                "启动游戏",
            ),
            LaunchPhase::Launching { started } => (
                theme::ACCENT,
                "正在启动游戏".to_owned(),
                format!(
                    "已等待 {:.1} 秒 · 正在注入离线客户端并拉起游戏进程",
                    started.elapsed().as_secs_f32()
                ),
                "正在启动…",
            ),
            LaunchPhase::Running { since } => (
                theme::SUCCESS,
                "游戏运行中".to_owned(),
                format!(
                    "已运行 {:.0} 秒 · 关闭游戏后会自动回到大厅",
                    since.elapsed().as_secs_f32()
                ),
                "游戏运行中",
            ),
            LaunchPhase::Failed { message } => (
                theme::DANGER,
                "启动失败".to_owned(),
                message.clone(),
                "重试启动",
            ),
        };

        egui::TopBottomPanel::bottom("lobby-footer")
            .exact_height(FOOTER_HEIGHT)
            .frame(theme::panel_frame(
                theme::TOP,
                Margin::symmetric(24.0, 14.0),
            ))
            .show(ctx, |ui| {
                ui.horizontal_centered(|ui| {
                    ui.vertical(|ui| {
                        ui.horizontal(|ui| {
                            theme::dot(ui, status_color, 4.0);
                            ui.label(RichText::new(title).size(15.0).strong().color(status_color));
                            if matches!(phase, LaunchPhase::Launching { .. }) {
                                ui.spinner();
                            }
                        });
                        ui.add_space(3.0);
                        let detail_label = ui.add(
                            egui::Label::new(RichText::new(&detail).size(11.5).color(theme::FAINT))
                                .truncate(),
                        );
                        if !matches!(phase, LaunchPhase::Idle) {
                            detail_label.on_hover_text(&detail);
                        }
                    });

                    ui.with_layout(Layout::right_to_left(Align::Center), |ui| {
                        let response = launch_button(ui, button_text, !busy);
                        if response.clicked() && !busy {
                            match self.launch.launch(&self.settings) {
                                Ok(()) => {
                                    let path = settings::launch_config_path(&self.settings);
                                    self.toast(
                                        NoticeKind::Success,
                                        format!("启动配置已写入 {}", path.display()),
                                    );
                                }
                                Err(err) => {
                                    self.toast(NoticeKind::Error, format!("启动失败：{err:#}"));
                                }
                            }
                        }

                        ui.add_space(10.0);
                        // [PATCH] 摘要里带上已选皮肤，便于启动前确认（按当前背包统计槽位皮肤）。
                        let mut skin_note = String::new();
                        let active_index = (self.settings.active_bag as usize).saturating_sub(1);
                        let bag_skins = self
                            .settings
                            .bags
                            .get(active_index)
                            .map(BagLoadout::skin_count)
                            .unwrap_or(0);
                        if bag_skins > 0 {
                            skin_note.push_str(&format!(
                                "  ·  背包 {} 皮肤 {}/4 槽",
                                self.settings.active_bag, bag_skins
                            ));
                        }
                        if !self.settings.weapon_skin.trim().is_empty() {
                            skin_note.push_str(&format!(
                                "  ·  旧版皮肤 {}",
                                self.settings.weapon_skin.trim()
                            ));
                        }
                        if !self.settings.career_skin.trim().is_empty() {
                            skin_note.push_str(&format!(
                                "  ·  角色皮肤 {}",
                                self.settings.career_skin.trim()
                            ));
                        }
                        ui.label(
                            RichText::new(format!(
                                "地图 {}  ·  阵营 {}  ·  武器 {}{}",
                                map_display(&self.inventory, &self.settings.map),
                                career_label(&self.settings.career),
                                weapon_display(&self.inventory, &self.settings.weapon),
                                skin_note
                            ))
                            .size(11.0)
                            .color(theme::MUTED),
                        );
                    });
                });
            });
    }

    fn central(&mut self, ctx: &egui::Context) {
        egui::CentralPanel::default()
            .frame(theme::panel_frame(theme::BG, Margin::symmetric(26.0, 18.0)))
            .show(ctx, |ui| {
                if let Some(font_error) = self.font_error.clone() {
                    warning_banner(
                        ui,
                        "中文字体未能加载",
                        &format!("界面可能显示为方块。{font_error}"),
                    );
                    ui.add_space(10.0);
                }

                let mut dirty = match self.page {
                    Page::Maps => self.maps_page(ui),
                    Page::Characters => self.characters_page(ui),
                    Page::Weapons => self.weapons_page(ui),
                    Page::Sprays => self.sprays_page(ui),
                    Page::Cosmetics => self.cosmetics_page(ui),
                    Page::Honors => self.honors_page(ui),
                    Page::OnlineServices => self.online_services_page(ui),
                    Page::Settings => self.settings_page(ui),
                };

                // [PATCH] 皮肤选择弹窗（浮在页面上，避免被仓库滚动区裁切）。
                if self.skin_picker_window(ui.ctx()) {
                    dirty = true;
                }

                if dirty {
                    if matches!(
                        self.page,
                        Page::Honors | Page::Sprays | Page::Cosmetics
                    ) {
                        self.save_profile();
                    } else {
                        self.save_settings();
                    }
                }
            });
    }

    fn honors_page(&mut self, ui: &mut Ui) -> bool {
        let show_titles = self.honor_show_titles;
        let category = if show_titles { "title" } else { "medal" };
        let mut dirty = false;
        ScrollArea::vertical()
            .id_salt("honors-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "勋章与称号",
                    "图标从大厅本地缓存提取；装备状态保存在离线玩家资料中。",
                    Some((
                        format!(
                            "{} 勋章 · {} 称号",
                            self.inventory.medals.len(),
                            self.inventory.titles.len()
                        ),
                        theme::INFO,
                        theme::INFO_SOFT,
                    )),
                );
                ui.add_space(12.0);
                ui.horizontal(|ui| {
                    if choice_pill(
                        ui,
                        !show_titles,
                        &format!("勋章 {}", self.inventory.medals.len()),
                    ) {
                        self.honor_show_titles = false;
                    }
                    if choice_pill(
                        ui,
                        show_titles,
                        &format!("称号 {}", self.inventory.titles.len()),
                    ) {
                        self.honor_show_titles = true;
                    }
                    ui.add_space(12.0);
                    ui.add(
                        egui::TextEdit::singleline(&mut self.honor_search)
                            .desired_width(250.0)
                            .hint_text("按名称或资源 ID 搜索"),
                    );
                    if !self.honor_search.is_empty() && choice_pill(ui, false, "清空") {
                        self.honor_search.clear();
                    }
                    ui.with_layout(Layout::right_to_left(Align::Center), |ui| {
                        let equipped = if show_titles {
                            if self.profile.selected_title.is_empty() {
                                "未装备称号".to_owned()
                            } else {
                                format!("已装备称号 {}", self.profile.selected_title)
                            }
                        } else {
                            format!("已装备 {} 枚勋章", self.profile.equipped_medals.len())
                        };
                        ui.label(RichText::new(equipped).size(11.0).color(theme::MUTED));
                    });
                });
                ui.add_space(10.0);

                let needle = self.honor_search.trim().to_ascii_lowercase();
                let list = if show_titles {
                    self.inventory
                        .titles
                        .iter()
                        .filter(|item| {
                            needle.is_empty()
                                || item.key.contains(&needle)
                                || item.name.to_ascii_lowercase().contains(&needle)
                        })
                        .cloned()
                        .collect::<Vec<_>>()
                } else {
                    self.inventory
                        .medals
                        .iter()
                        .filter(|item| {
                            needle.is_empty()
                                || item.key.contains(&needle)
                                || item.name.to_ascii_lowercase().contains(&needle)
                        })
                        .cloned()
                        .collect::<Vec<_>>()
                };
                ui.label(
                    RichText::new(format!("{} 项 · 点击卡片切换装备状态", list.len()))
                        .size(11.0)
                        .color(theme::FAINT),
                );
                ui.add_space(8.0);

                let width = ui.available_width();
                let spacing = ui.spacing().item_spacing.x;
                let columns = columns_for(width, 132.0, spacing).clamp(2, 6);
                let card_width = ((width - spacing * (columns.saturating_sub(1)) as f32)
                    / columns as f32)
                    .floor()
                    .max(118.0);
                let texture_cache = &mut self.previews;
                let profile = &mut self.profile;
                ui.horizontal_wrapped(|ui| {
                    ui.spacing_mut().item_spacing = Vec2::new(spacing, 10.0);
                    for item in &list {
                        let equipped = if show_titles {
                            profile.selected_title == item.key
                        } else {
                            profile.equipped_medals.contains(&item.key)
                        };
                        let unlocked = profile.is_unlocked(category, &item.key);
                        let preview = texture_cache.get(ui.ctx(), category, &item.key);
                        if collectible_card(ui, item, preview, equipped, unlocked, card_width) {
                            if !item.complete || !unlocked {
                                continue;
                            }
                            if show_titles {
                                if equipped {
                                    profile.selected_title.clear();
                                } else {
                                    profile.selected_title = item.key.clone();
                                }
                            } else if equipped {
                                profile.equipped_medals.retain(|key| key != &item.key);
                            } else {
                                profile.equipped_medals.push(item.key.clone());
                            }
                            dirty = true;
                        }
                    }
                });
                if list.is_empty() {
                    ui.add_space(24.0);
                    ui.vertical_centered(|ui| {
                        ui.label(
                            RichText::new("没有匹配的资源")
                                .size(13.0)
                                .color(theme::FAINT),
                        );
                    });
                }
            });
        dirty
    }

    /// 皮肤选择弹窗：只列当前槽位武器可用的皮肤，带缩略图与搜索。
    /// 返回是否修改了配置（触发保存）。
    fn skin_picker_window(&mut self, ctx: &egui::Context) -> bool {
        let Some(state) = self.skin_picker.clone() else {
            return false;
        };
        if state.bag >= self.settings.bags.len()
            || self.settings.bags[state.bag].slot(state.slot) != state.weapon
        {
            // 槽位武器被换掉/背包被清空：弹窗作废，避免把皮肤写到别的枪上。
            self.skin_picker = None;
            return false;
        }

        let current = self.settings.bags[state.bag]
            .slot_skin(state.slot)
            .to_owned();
        let candidates = settings::skins_for_weapon(&self.inventory, &state.weapon);
        let weapon_label = self
            .inventory
            .weapon(&state.weapon)
            .map(|weapon| weapon.display_name().to_owned())
            .filter(|name| !name.trim().is_empty())
            .unwrap_or_else(|| state.weapon.clone());
        let slot_labels = ["主武器", "副武器", "近战", "投掷"];

        let mut search = state.search.clone();
        let mut open = true;
        let mut close = false;
        let mut chosen: Option<String> = None;
        let mut use_default = false;

        let previews = &mut self.previews;
        egui::Window::new("选择皮肤")
            .id(egui::Id::new("skin-picker-window"))
            .collapsible(false)
            .resizable(false)
            .open(&mut open)
            .anchor(Align2::CENTER_CENTER, Vec2::ZERO)
            .frame(
                Frame::none()
                    .fill(theme::PANEL)
                    .stroke(Stroke::new(1.0_f32, theme::LINE))
                    .rounding(Rounding::same(12.0))
                    .inner_margin(Margin::same(16.0)),
            )
            .show(ctx, |ui| {
                ui.set_width(780.0);
                ui.label(
                    RichText::new(format!(
                        "背包 {} · {} · {}",
                        state.bag + 1,
                        slot_labels[state.slot.min(3)],
                        weapon_label
                    ))
                    .size(15.0)
                    .strong()
                    .color(theme::TEXT),
                );
                ui.add_space(3.0);
                ui.label(
                    RichText::new("皮肤只作用于这个槽位的这把武器；换枪/换背包后外观跟着武器走。")
                        .size(11.0)
                        .color(theme::FAINT),
                );
                ui.add_space(8.0);
                ui.horizontal(|ui| {
                    ui.add(
                        egui::TextEdit::singleline(&mut search)
                            .desired_width(260.0)
                            .hint_text("搜索皮肤名"),
                    );
                    ui.add_space(8.0);
                    ui.label(
                        RichText::new(format!(
                            "当前：{}",
                            if current.trim().is_empty() {
                                "默认外观"
                            } else {
                                current.trim()
                            }
                        ))
                        .size(11.5)
                        .color(theme::MUTED),
                    );
                    ui.add_space(8.0);
                    if click_pill(ui, "使用默认外观", theme::FAINT, theme::GHOST) {
                        use_default = true;
                    }
                    if click_pill(ui, "关闭", theme::FAINT, theme::GHOST) {
                        close = true;
                    }
                });
                ui.add_space(8.0);

                if candidates.is_empty() {
                    ui.label(
                        RichText::new("这把武器在资源清单里没有关联皮肤，只能使用默认外观。")
                            .size(12.0)
                            .color(theme::FAINT),
                    );
                } else {
                    let needle = search.trim().to_ascii_lowercase();
                    let list: Vec<&crate::inventory::WeaponSkin> = candidates
                        .iter()
                        .filter(|skin| {
                            needle.is_empty()
                                || skin.key.to_ascii_lowercase().contains(&needle)
                        })
                        .collect();
                    let local_ready = list.iter().filter(|skin| skin.complete).count();
                    let preview_ready = list.iter().filter(|skin| skin.preview_available).count();
                    ui.label(
                        RichText::new(format!(
                            "{} 个关联皮肤 · 本地资源 {local_ready} · 预览图 {preview_ready} · 缺资源项不可装备",
                            list.len()
                        ))
                            .size(11.0)
                            .color(theme::FAINT),
                    );
                    ui.add_space(6.0);
                    ScrollArea::vertical()
                        .max_height(420.0)
                        .auto_shrink([false, false])
                        .show(ui, |ui| {
                            ui.set_width(ui.available_width());
                            ui.horizontal_wrapped(|ui| {
                                for skin in &list {
                                    let thumb =
                                        previews.get_skin(ui.ctx(), &skin.key, &state.weapon);
                                    if skin_card(
                                        ui,
                                        &skin.key,
                                        thumb,
                                        current.trim() == skin.key,
                                        skin.complete,
                                        skin.preview_available,
                                        skin.client_available,
                                        176.0,
                                    ) {
                                        chosen = Some(skin.key.clone());
                                    }
                                }
                            });
                        });
                }
            });

        let mut dirty = false;
        if let Some(key) = chosen {
            *self.settings.bags[state.bag].slot_skin_mut(state.slot) = key;
            dirty = true;
            close = true;
        } else if use_default {
            self.settings.bags[state.bag]
                .slot_skin_mut(state.slot)
                .clear();
            dirty = true;
            close = true;
        }

        if close || !open {
            self.skin_picker = None;
        } else if let Some(picker) = self.skin_picker.as_mut() {
            picker.search = search;
        }
        dirty
    }

    fn maps_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        ScrollArea::vertical()
            .id_salt("maps-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "选择战场",
                    "地图按客户端状态标记：已安装，或启动时执行本地安装校验；缺图地图不会冒充已就绪。",
                    Some((
                        format!(
                            "已安装 {} · 启动验证 {}",
                            self.inventory.installed_map_count(),
                            self.inventory.install_at_launch_map_count(),
                        ),
                        theme::INFO,
                        theme::INFO_SOFT,
                    )),
                );
                ui.add_space(14.0);
                theme::section_label(ui, "对局模式与规则");
                ui.add_space(6.0);
                if self.rules_card(ui) {
                    dirty = true;
                }
                ui.add_space(18.0);

                let width = ui.available_width();
                let spacing = ui.spacing().item_spacing.x;
                let columns = columns_for(width, MAP_MIN_WIDTH, spacing);
                let card_width = ((width - 1.0 - spacing * (columns.saturating_sub(1)) as f32)
                    / columns as f32)
                    .floor()
                    .max(180.0);

                let selected = self.settings.map.clone();
                let mut new_selection = None;
                ui.horizontal_wrapped(|ui| {
                    for map in &self.inventory.maps {
                        let is_selected = map.key == selected;
                        let preview = self.previews.get(ui.ctx(), "map", &map.key);
                        if map_card(ui, preview, map, is_selected, card_width) && !is_selected {
                            new_selection = Some(map.key.clone());
                        }
                    }
                });
                if let Some(key) = new_selection {
                    self.settings.map = key;
                    dirty = true;
                }

                ui.add_space(16.0);
            });
        dirty
    }

    fn rules_card(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        Frame::none()
            .fill(theme::CARD)
            .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
            .rounding(Rounding::same(10.0))
            .inner_margin(Margin::same(18.0))
            .show(ui, |ui| {
                ui.set_min_width(ui.available_width());
                ui.columns(4, |columns| {
                    columns[0].label(theme::muted("游戏模式"));
                    columns[0].add_space(7.0);
                    let previous_mode = self.settings.mode.clone();
                    egui::ComboBox::from_id_salt("mode-select")
                        .width(columns[0].available_width().min(190.0))
                        .selected_text(settings::mode_label(&self.settings.mode))
                        .show_ui(&mut columns[0], |ui| {
                            for (name, label) in settings::MODES {
                                ui.selectable_value(
                                    &mut self.settings.mode,
                                    name.to_owned(),
                                    label,
                                );
                            }
                        });
                    if self.settings.mode != previous_mode {
                        dirty = true;
                        // [PATCH] 切到团队模式且当前编制为空时，套用人机团战默认 3/4；
                        // 只处理 0 总数，避免覆盖用户已手动设置的队友/敌人数量。
                        if settings::is_team_mode(&self.settings.mode)
                            && self.settings.bot_total() == 0
                        {
                            self.settings.apply_team_bot_defaults();
                        }
                    }

                    columns[1].label(theme::muted("队友数量"));
                    columns[1].add_space(7.0);
                    let mut ally = self.settings.ally_bot_count;
                    if number_stepper(&mut columns[1], &mut ally, 0, 6) {
                        self.settings.ally_bot_count = ally;
                        self.settings.bot_count = self.settings.bot_total();
                        dirty = true;
                    }
                    columns[1].add_space(5.0);
                    columns[1].label(
                        RichText::new("与玩家同队，显示原版队友名牌")
                            .size(10.5)
                            .color(theme::FAINT),
                    );

                    columns[2].label(theme::muted("敌人数量"));
                    columns[2].add_space(7.0);
                    let mut enemy = self.settings.enemy_bot_count;
                    if number_stepper(&mut columns[2], &mut enemy, 0, 8) {
                        self.settings.enemy_bot_count = enemy;
                        self.settings.bot_count = self.settings.bot_total();
                        dirty = true;
                    }
                    columns[2].add_space(5.0);
                    columns[2].label(
                        RichText::new("敌对阵营，不显示名字")
                            .size(10.5)
                            .color(theme::FAINT),
                    );

                    columns[3].label(theme::muted("AI 难度"));
                    columns[3].add_space(7.0);
                    let diff_index = settings::DIFFICULTIES
                        .iter()
                        .position(|(name, _)| *name == self.settings.bot_difficulty)
                        .unwrap_or(1);
                    if let Some(index) = segmented_choice(
                        &mut columns[3],
                        &settings::DIFFICULTIES
                            .iter()
                            .map(|(_, label)| *label)
                            .collect::<Vec<_>>(),
                        diff_index,
                    ) {
                        let name = settings::DIFFICULTIES[index].0;
                        if self.settings.bot_difficulty != name {
                            self.settings.bot_difficulty = name.to_owned();
                            dirty = true;
                        }
                    }
                    columns[3].add_space(5.0);
                    columns[3].label(
                        RichText::new("噩梦及以上会连跳/空中转向")
                            .size(10.5)
                            .color(theme::FAINT),
                    );
                });
                ui.add_space(10.0);
                ui.columns(3, |columns| {
                    columns[0].label(theme::muted("机器人阵营"));
                    columns[0].add_space(7.0);
                    let selected = usize::from(self.settings.bot_career == "police");
                    if let Some(index) =
                        segmented_choice(&mut columns[0], &["恐怖分子", "警察"], selected)
                    {
                        let career = if index == 0 { "terrorist" } else { "police" };
                        if self.settings.bot_career != career {
                            self.settings.bot_career = career.to_owned();
                            dirty = true;
                        }
                    }

                    columns[1].label(theme::muted("无敌模式"));
                    columns[1].add_space(7.0);
                    columns[1].horizontal(|ui| {
                        let mut god = self.settings.god_mode;
                        if toggle_switch(ui, &mut god) {
                            self.settings.god_mode = god;
                            dirty = true;
                        }
                        ui.add_space(2.0);
                        ui.label(
                            RichText::new(if god { "开启" } else { "关闭" })
                                .size(11.5)
                                .color(if god { theme::TEXT } else { theme::MUTED }),
                        );
                    });

                    columns[2].label(theme::muted("提示"));
                    columns[2].add_space(7.0);
                    columns[2].label(
                        RichText::new("队友/敌人数量与难度会写入 launch_config")
                            .size(10.5)
                            .color(theme::FAINT),
                    );
                });
            });
        dirty
    }

    fn characters_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        ScrollArea::vertical()
            .id_salt("characters-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                let available = self.inventory.available_character_count();
                let official_roles = self
                    .inventory
                    .characters
                    .iter()
                    .filter(|character| character.has_official_lobby_icon())
                    .count();
                let missing = official_roles.saturating_sub(available);
                page_header(
                    ui,
                    "选择角色",
                    "选择角色后，可在上方切换该角色的专属皮肤。",
                    Some((
                        format!("{available} / {official_roles} 可用",),
                        theme::INFO,
                        theme::INFO_SOFT,
                    )),
                );
                ui.add_space(16.0);

                let current_name = self.inventory.character(&self.settings.career)
                    .map(|c| c.display_name().to_owned()).unwrap_or_else(|| self.settings.career.clone());
                let role_skins: Vec<_> = self.inventory.career_skins_for(&self.settings.career)
                    .into_iter().cloned().collect();
                egui::CollapsingHeader::new(format!("{} · 角色皮肤", current_name))
                    .id_salt("current-role-skins").default_open(true).show(ui, |ui| {
                        ui.horizontal(|ui| {
                            if choice_pill(ui, self.settings.career_skin.is_empty(), "默认外观") {
                                self.settings.career_skin.clear(); dirty = true;
                            }
                            if role_skins.is_empty() { ui.label(theme::muted("该角色没有已关联的皮肤")); }
                        });
                        ui.horizontal_wrapped(|ui| {
                            for skin in &role_skins {
                                let preview = self.previews.get(ui.ctx(), "career_skin", &skin.key);
                                let has_preview = preview.is_some();
                                if skin_card(ui, &skin.key, preview, self.settings.career_skin == skin.key,
                                    skin.complete, has_preview, None, 200.0) {
                                    self.settings.career_skin = skin.key.clone(); dirty = true;
                                }
                            }
                        });
                    });
                ui.add_space(10.0);

                ui.horizontal(|ui| {
                    ui.add(
                        egui::TextEdit::singleline(&mut self.character_search)
                            .desired_width(240.0)
                            .hint_text("搜索角色（内部名 / 中文名）"),
                    );
                    if !self.character_search.is_empty() && choice_pill(ui, false, "清空搜索") {
                        self.character_search.clear();
                    }
                });
                ui.add_space(8.0);
                ui.horizontal_wrapped(|ui| {
                    let listed = official_roles;
                    if choice_pill(
                        ui,
                        self.character_filter == CharacterFilter::All,
                        &format!("大厅角色 {listed}"),
                    ) {
                        self.character_filter = CharacterFilter::All;
                    }
                    if choice_pill(
                        ui,
                        self.character_filter == CharacterFilter::Available,
                        &format!("可用 {available}"),
                    ) {
                        self.character_filter = CharacterFilter::Available;
                    }
                    if choice_pill(
                        ui,
                        self.character_filter == CharacterFilter::Missing,
                        &format!("缺资源 {missing}"),
                    ) {
                        self.character_filter = CharacterFilter::Missing;
                    }
                });
                ui.add_space(6.0);
                ui.horizontal_wrapped(|ui| {
                    if choice_pill(ui, self.character_kind.is_none(), "人类角色") {
                        self.character_kind = None;
                    }
                });
                ui.add_space(14.0);

                let width = ui.available_width();
                let spacing = ui.spacing().item_spacing.x;
                let columns = columns_for(width, CHARACTER_MIN_WIDTH, spacing);
                let card_width = ((width - 1.0 - spacing * (columns.saturating_sub(1)) as f32)
                    / columns as f32)
                    .floor()
                    .max(100.0);

                let selected = self.settings.career.clone();
                let filter = self.character_filter;
                let kind = self.character_kind;
                let needle = self.character_search.trim().to_lowercase();
                let filtered: Vec<usize> = self
                    .inventory
                    .characters
                    .iter()
                    .enumerate()
                    .filter(|(_, character)| {
                        if !character.has_official_lobby_icon() {
                            return false;
                        }
                        let show = match filter {
                            CharacterFilter::All => true,
                            CharacterFilter::Available => character.selectable(),
                            CharacterFilter::Missing => !character.selectable(),
                        };
                        show
                            && character.kind == CharacterKind::Human
                            && !character.npc_only
                            && kind.map_or(true, |kind| character.kind == kind)
                            && (needle.is_empty()
                                || character.key.to_lowercase().contains(&needle)
                                || character.cn.to_lowercase().contains(&needle))
                    })
                    .map(|(index, _)| index)
                    .collect();

                let inventory = &self.inventory;
                let previews = &mut self.previews;
                let mut new_selection = None;
                let grid_height =
                    (ui.ctx().available_rect().height() - 300.0).clamp(320.0, 760.0);
                virtual_grid(
                    ui,
                    "character-grid",
                    filtered.len(),
                    columns,
                    158.0,
                    grid_height,
                    |ui, index| {
                        let character = &inventory.characters[filtered[index]];
                        let is_selected = character.key.eq_ignore_ascii_case(&selected);
                        let preview = previews.get(ui.ctx(), "character", &character.key);
                        if character_card(ui, preview, character, is_selected, card_width)
                            && !is_selected
                        {
                            new_selection = Some(character.key.clone());
                        }
                    },
                );
                if let Some(key) = new_selection {
                    self.settings.career = key;
                    let skin_still_belongs = self
                        .inventory
                        .career_skins_for(&self.settings.career)
                        .iter()
                        .any(|skin| skin.key.eq_ignore_ascii_case(&self.settings.career_skin));
                    if !skin_still_belongs {
                        self.settings.career_skin.clear();
                    }
                    dirty = true;
                }
                if filtered.is_empty() {
                    ui.add_space(30.0);
                    ui.vertical_centered(|ui| {
                        ui.label(
                            RichText::new("当前筛选下没有角色")
                                .size(14.0)
                                .color(theme::FAINT),
                        );
                    });
                }
                ui.add_space(14.0);

                ui.add_space(18.0);
            });
        dirty
    }

    fn weapons_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        let bag_index = (self.settings.active_bag.saturating_sub(1) as usize).min(settings::BAG_COUNT - 1);
        let bag = self.settings.bags[bag_index].clone();
        let mut picked: Option<(String, bool)> = None;
        let mut remove_slot = None;
        ScrollArea::vertical().id_salt("warehouse-page").auto_shrink([false, false]).show(ui, |ui| {
            ui.set_width(ui.available_width());
            ui.horizontal(|ui| {
                ui.label(RichText::new("个人仓库").size(22.0).strong().color(theme::TEXT));
                ui.with_layout(Layout::right_to_left(Align::Center), |ui| {
                    ui.label(RichText::new(format!("金币 {}    GP {}", self.profile.gold, self.profile.gp)).color(theme::MUTED));
                });
            });
            ui.add_space(12.0);
            let total_width = ui.available_width();
            let bag_width = (total_width * 0.27).clamp(190.0, 270.0);
            let list_width = (total_width - bag_width - 16.0).max(280.0);
            ui.horizontal_top(|ui| {
                ui.allocate_ui_with_layout(Vec2::new(bag_width, 0.0), Layout::top_down(Align::Min), |ui| {
                    Frame::none().fill(theme::PANEL_SOFT).stroke(Stroke::new(1.0_f32, theme::LINE))
                        .inner_margin(Margin::same(7.0)).show(ui, |ui| {
                        ui.set_width(bag_width - 14.0);
                        ui.label(RichText::new("竞技背包").size(15.0).color(Color32::from_rgb(231, 204, 125)));
                        ui.horizontal(|ui| {
                            for index in 0..settings::BAG_COUNT {
                                let id = index as u8 + 1;
                                if ui.selectable_label(self.settings.active_bag == id, id.to_string()).clicked() {
                                    self.settings.active_bag = id;
                                    self.settings.weapon = self.settings.bags[index].primary.clone();
                                    dirty = true;
                                }
                            }
                        });
                        ui.add_space(6.0);
                        for slot in 0..4 {
                            let key = bag.slot(slot);
                            let weapon = self.inventory.weapon(key);
                            let art = self.previews.get_skin(ui.ctx(), bag.slot_skin(slot), key);
                            if slot_card(ui, slot, key, weapon, art, self.warehouse_slot == slot, ui.available_width()) {
                                self.warehouse_slot = slot;
                                self.warehouse_show_all = false;
                                self.weapon_category = None;
                                self.weapon_page = 0;
                            }
                            ui.horizontal(|ui| {
                                if ui.add_enabled(!key.is_empty(), egui::Button::new("皮肤")).clicked() {
                                    self.skin_picker = Some(SkinPicker { bag: bag_index, slot,
                                        weapon: key.to_owned(), search: String::new() });
                                }
                                if ui.add_enabled(!key.is_empty(), egui::Button::new("卸下")).clicked() { remove_slot = Some(slot); }
                                if !bag.slot_skin(slot).is_empty() {
                                    ui.label(RichText::new("已应用皮肤").size(10.0).color(theme::SUCCESS));
                                }
                            });
                            ui.add_space(7.0);
                        }
                    });
                });
                ui.add_space(8.0);
                ui.allocate_ui_with_layout(Vec2::new(list_width, 0.0), Layout::top_down(Align::Min), |ui| {
                    ui.set_width(list_width);
                    ui.horizontal(|ui| {
                        ui.label(RichText::new("武器").size(17.0).strong().color(Color32::from_rgb(231, 204, 125)));
                        let response = ui.add(egui::TextEdit::singleline(&mut self.weapon_search)
                            .desired_width((list_width - 135.0).min(280.0)).hint_text("搜索武器"));
                        if response.changed() { self.weapon_page = 0; }
                    });
                    ui.horizontal_wrapped(|ui| {
                        if ui.selectable_label(self.weapon_category.is_none() && self.warehouse_show_all, "全部").clicked() {
                            self.weapon_category = None; self.warehouse_show_all = true; self.weapon_page = 0;
                        }
                        for category in WeaponCategory::ALL {
                            if ui.selectable_label(self.weapon_category == Some(category), category.label()).clicked() {
                                self.weapon_category = Some(category); self.warehouse_show_all = true; self.weapon_page = 0;
                            }
                        }
                        if ui.checkbox(&mut self.weapons_available_only, "仅可装备").changed() { self.weapon_page = 0; }
                    });
                    ui.add_space(8.0);
                    let slot = self.warehouse_slot.min(3);
                    let needle = self.weapon_search.trim().to_lowercase();
                    let filtered: Vec<usize> = self.inventory.weapons.iter().enumerate().filter(|(_, w)| {
                        (!self.weapons_available_only || w.complete)
                            && (self.warehouse_show_all || settings::slot_accepts(slot, w.category()))
                            && self.weapon_category.map_or(true, |c| w.category() == c)
                            && (needle.is_empty() || w.key.to_lowercase().contains(&needle)
                                || w.display_name().to_lowercase().contains(&needle))
                    }).map(|(index, _)| index).collect();
                    let pages = filtered.len().div_ceil(8).max(1);
                    self.weapon_page = self.weapon_page.min(pages - 1);
                    let width = ((ui.available_width() - ui.spacing().item_spacing.x) / 2.0).floor();
                    for row in 0..4 {
                        ui.horizontal(|ui| {
                            for column in 0..2 {
                                let item = self.weapon_page * 8 + row * 2 + column;
                                if item >= filtered.len() { break; }
                                let weapon = &self.inventory.weapons[filtered[item]];
                                let equipped_slot = (0..4).find(|&s| bag.slot(s) == weapon.key);
                                let art = match equipped_slot {
                                    Some(s) => self.previews.get_skin(ui.ctx(), bag.slot_skin(s), &weapon.key).cloned(),
                                    None => self.previews.get(ui.ctx(), "weapon", &weapon.key).cloned(),
                                };
                                let frame = self.previews.get(ui.ctx(), "ui", if equipped_slot.is_some() {
                                    "storage_item_new3" } else { "mall_item_new1" }).cloned();
                                let background = crate::official_preview::weapon_background(&weapon.key)
                                    .and_then(|key| self.previews.get(ui.ctx(), "ui", key)).cloned();
                                match warehouse_weapon_card(ui, art.as_ref(), frame.as_ref(), background.as_ref(), weapon, equipped_slot.is_some(), self.settings.active_bag, width) {
                                    WarehouseAction::Equip => picked = Some((weapon.key.clone(), false)),
                                    WarehouseAction::Skin => picked = Some((weapon.key.clone(), true)),
                                    WarehouseAction::Unequip => remove_slot = equipped_slot,
                                    WarehouseAction::None => {}
                                }
                            }
                        });
                        ui.add_space(3.0);
                    }
                    if filtered.is_empty() { ui.label(theme::muted("没有符合筛选条件的武器")); }
                    ui.horizontal(|ui| {
                        if ui.add_enabled(self.weapon_page > 0, egui::Button::new("≪")).clicked() { self.weapon_page = 0; }
                        if ui.add_enabled(self.weapon_page > 0, egui::Button::new("〈")).clicked() { self.weapon_page -= 1; }
                        ui.label(format!("{} / {}", self.weapon_page + 1, pages));
                        if ui.add_enabled(self.weapon_page + 1 < pages, egui::Button::new("〉")).clicked() { self.weapon_page += 1; }
                        if ui.add_enabled(self.weapon_page + 1 < pages, egui::Button::new("≫")).clicked() { self.weapon_page = pages - 1; }
                        ui.label(RichText::new(format!("共 {} 件", filtered.len())).size(11.0).color(theme::MUTED));
                    });
                });
            });
        });
        if let Some(slot) = remove_slot {
            self.settings.bags[bag_index].slot_mut(slot).clear();
            self.settings.bags[bag_index].slot_skin_mut(slot).clear();
            if slot == 0 { self.settings.weapon.clear(); }
            dirty = true;
        }
        if let Some((key, open_skin)) = picked {
            if let Some(weapon) = self.inventory.weapon(&key).filter(|w| w.complete) {
                let slot = (0..4).find(|&s| settings::slot_accepts(s, weapon.category())).unwrap_or(0);
                if self.settings.bags[bag_index].slot(slot) != key {
                    self.settings.bags[bag_index].slot_skin_mut(slot).clear();
                }
                *self.settings.bags[bag_index].slot_mut(slot) = key.clone();
                self.warehouse_slot = slot;
                if slot == 0 { self.settings.weapon = key.clone(); }
                if open_skin { self.skin_picker = Some(SkinPicker { bag: bag_index, slot, weapon: key, search: String::new() }); }
                dirty = true;
            }
        }
        dirty
    }

    /// [PATCH] 喷漆仓库：原版 spray 全量，直接展示 bundle 内的 Texture2D。
    fn sprays_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        let total = self.inventory.sprays.len();
        let ready = self.inventory.available_spray_count();
        let needle = self.spray_search.trim().to_owned();
        let only_ready = self.spray_available_only;
        let list: Vec<(u32, bool, bool, bool, Option<bool>)> = self
            .inventory
            .sprays
            .iter()
            .filter(|s| {
                (needle.is_empty() || s.id.to_string().contains(&needle))
                    && (!only_ready || s.complete)
            })
            .map(|s| {
                (
                    s.id,
                    s.complete,
                    s.has_name,
                    s.preview_available,
                    s.client_available,
                )
            })
            .collect();

        ScrollArea::vertical()
            .id_salt("sprays-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "喷漆仓库",
                    "原版 spray/<ResId> 包，贴图直接从 bundle 的 Texture2D 导出（128px 缩略）。",
                    Some((
                        format!("{ready} / {total} 可用"),
                        theme::INFO,
                        theme::INFO_SOFT,
                    )),
                );
                ui.add_space(12.0);
                ui.horizontal(|ui| {
                    ui.add(
                        egui::TextEdit::singleline(&mut self.spray_search)
                            .desired_width(200.0)
                            .hint_text("按编号搜索喷漆"),
                    );
                    if !self.spray_search.is_empty() && choice_pill(ui, false, "清空") {
                        self.spray_search.clear();
                    }
                    ui.add_space(12.0);
                    if choice_pill(ui, self.spray_available_only, "仅显示可用") {
                        self.spray_available_only = !self.spray_available_only;
                    }
                    ui.add_space(12.0);
                    ui.label(
                        RichText::new("喷漆图案即原版涂鸦，仓库内可直接预览")
                            .size(11.0)
                            .color(theme::FAINT),
                    );
                });
                ui.add_space(12.0);

                let previews = &mut self.previews;
                let profile = &mut self.profile;
                ui.horizontal_wrapped(|ui| {
                    let size = 104.0;
                    for (id, complete, has_name, preview_available, client_available) in &list {
                        let unlocked = profile.is_unlocked("spray", &id.to_string());
                        let equipped = profile.equipped_sprays.contains(id);
                        let (rect, resp) =
                            ui.allocate_exact_size(Vec2::splat(size), Sense::click());
                        let inner = rect.shrink(2.0);
                        ui.painter()
                            .rect_filled(inner, Rounding::same(8.0), theme::CARD);
                        ui.painter().rect_stroke(
                            inner,
                            Rounding::same(8.0),
                            Stroke::new(
                                1.0_f32,
                                if equipped {
                                    theme::ACCENT
                                } else if resp.hovered() && *complete && unlocked {
                                    theme::LINE
                                } else {
                                    theme::LINE_SOFT
                                },
                            ),
                        );
                        let art = Rect::from_min_size(
                            inner.min + Vec2::new(8.0, 8.0),
                            Vec2::splat(size - 34.0),
                        );
                        ui.painter()
                            .rect_filled(art, Rounding::same(4.0), theme::PANEL_SOFT);
                        if *preview_available {
                            if let Some(tex) = previews.get(ui.ctx(), "spray", &id.to_string()) {
                                paint_preview(ui.painter(), art.shrink(3.0), tex, Color32::WHITE);
                            } else {
                                paint_missing_preview(ui, art, "预览图读取失败");
                            }
                        } else {
                            paint_missing_preview(ui, art, "无预览图");
                        }
                        ui.painter().text(
                            egui::pos2(inner.center().x, inner.max.y - 11.0),
                            Align2::CENTER_CENTER,
                            if equipped {
                                format!("#{id} · 已装备")
                            } else {
                                format!("#{id}")
                            },
                            FontId::proportional(10.5),
                            if equipped {
                                theme::ACCENT
                            } else if *complete && unlocked {
                                theme::MUTED
                            } else {
                                theme::DISABLED
                            },
                        );
                        if *has_name {
                            ui.painter().circle_filled(
                                egui::pos2(inner.max.x - 8.0, inner.min.y + 8.0),
                                3.0,
                                theme::SUCCESS,
                            );
                        }
                        let enabled = *complete && unlocked;
                        let resp = if enabled {
                            resp.on_hover_cursor(CursorIcon::PointingHand)
                        } else {
                            resp.on_hover_cursor(CursorIcon::NotAllowed)
                        };
                        if resp.clicked() && enabled {
                            if equipped {
                                profile
                                    .equipped_sprays
                                    .retain(|equipped_id| equipped_id != id);
                            } else {
                                profile.equipped_sprays.push(*id);
                            }
                            dirty = true;
                        }
                        if resp.hovered() {
                            let tip = if *has_name {
                                "支持自定义署名"
                            } else {
                                "官方喷漆"
                            };
                            let client = match client_available {
                                Some(true) => "已验证",
                                Some(false) => "不可用",
                                None => "未验证",
                            };
                            resp.on_hover_text(format!(
                                "喷漆 #{id} · {tip}\n资源包：{}\n预览图：{}\n客户端：{client}",
                                if *complete { "已索引" } else { "缺失" },
                                if *preview_available {
                                    "已索引"
                                } else {
                                    "缺失"
                                }
                            ));
                        }
                    }
                });
                if list.is_empty() {
                    ui.add_space(30.0);
                    ui.vertical_centered(|ui| {
                        ui.label(
                            RichText::new("没有匹配的喷漆")
                                .size(13.0)
                                .color(theme::FAINT),
                        );
                    });
                }
                ui.add_space(18.0);
            });
        dirty
    }

    /// [PATCH] 饰品 / 时装仓库：accessory + avatarplayer 两部分，原版只有资源键没有中文名。
    fn cosmetics_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        let acc_total = self.inventory.accessories.len();
        let part_total = self.inventory.avatar_parts.len();
        let needle = self.cosmetic_search.trim().to_ascii_lowercase();
        let only_ready = self.cosmetic_available_only;
        let group = self.cosmetic_group;

        let mut acc: Vec<(String, &'static str, bool, bool, Option<bool>)> = self
            .inventory
            .accessories
            .iter()
            .filter(|a| {
                a.key.to_ascii_lowercase().contains(&needle)
                    && (!only_ready || a.complete)
                    && group.map_or(true, |g| a.group() == g)
            })
            .map(|a| {
                (
                    a.key.clone(),
                    "accessory",
                    a.complete,
                    a.preview_available,
                    a.client_available,
                )
            })
            .collect();
        let parts: Vec<(String, &'static str, bool, bool, Option<bool>)> = self
            .inventory
            .avatar_parts
            .iter()
            .filter(|a| {
                a.key.to_ascii_lowercase().contains(&needle)
                    && (!only_ready || a.complete)
                    && group.map_or(true, |g| a.group() == g)
            })
            .map(|a| {
                (
                    a.key.clone(),
                    "avatar_part",
                    a.complete,
                    a.preview_available,
                    a.client_available,
                )
            })
            .collect();
        acc.extend(parts);
        acc.sort();

        let groups: Vec<&'static str> = vec!["挂件", "身体", "服装", "发型", "头部", "其他"];

        ScrollArea::vertical()
            .id_salt("cosmetics-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "饰品 / 时装仓库",
                    "只使用官方大厅 PartsAssets / StuffAssets 图标；缺少对应图标的项目明确显示缺图，不拿角色或装备材质代替。",
                    Some((
                        format!("{acc_total} 挂件 · {part_total} 部件"),
                        theme::INFO,
                        theme::INFO_SOFT,
                    )),
                );
                ui.add_space(12.0);
                ui.horizontal(|ui| {
                    ui.add(
                        egui::TextEdit::singleline(&mut self.cosmetic_search)
                            .desired_width(220.0)
                            .hint_text("搜索内部键"),
                    );
                    if !self.cosmetic_search.is_empty() && choice_pill(ui, false, "清空") {
                        self.cosmetic_search.clear();
                    }
                    ui.add_space(12.0);
                    if choice_pill(ui, only_ready, "仅显示可用") {
                        self.cosmetic_available_only = !only_ready;
                    }
                });
                ui.add_space(6.0);
                ui.horizontal_wrapped(|ui| {
                    if choice_pill(ui, group.is_none(), "全部类型") {
                        self.cosmetic_group = None;
                    }
                    for g in &groups {
                        let n = self
                            .inventory
                            .accessories
                            .iter()
                            .chain(self.inventory.avatar_parts.iter())
                            .filter(|a| a.group() == *g)
                            .count();
                        if n == 0 {
                            continue;
                        }
                        if choice_pill(ui, group == Some(g), &format!("{g} {n}")) {
                            self.cosmetic_group = Some(g);
                        }
                    }
                });
                ui.add_space(12.0);

                let previews = &mut self.previews;
                let profile = &mut self.profile;
                ui.horizontal_wrapped(|ui| {
                    ui.spacing_mut().item_spacing = Vec2::new(10.0, 10.0);
                    let card_w = 194.0;
                    for (key, category, complete, preview_available, client_available) in &acc {
                        let equipped = profile.is_equipped_cosmetic(category, key);
                        let unlocked = profile.is_unlocked(category, key);
                        let (rect, resp) = ui.allocate_exact_size(
                            Vec2::new(card_w, 178.0),
                            Sense::click(),
                        );
                        let enabled = *complete && unlocked;
                        let fill = if equipped {
                            theme::ACCENT_SOFT
                        } else if enabled && resp.hovered() {
                            theme::CARD_HOVER
                        } else {
                            theme::CARD
                        };
                        ui.painter().rect_filled(rect, Rounding::same(8.0), fill);
                        ui.painter().rect_stroke(
                            rect,
                            Rounding::same(8.0),
                            Stroke::new(
                                if equipped { 1.5_f32 } else { 1.0_f32 },
                                if equipped { theme::ACCENT } else { theme::LINE_SOFT },
                            ),
                        );
                        let art = Rect::from_min_max(
                            rect.min + Vec2::splat(8.0),
                            egui::pos2(rect.right() - 8.0, rect.top() + 122.0),
                        );
                        ui.painter().rect_filled(art, Rounding::same(5.0), theme::PANEL_SOFT);
                        if *preview_available {
                            if let Some(texture) = previews.get(ui.ctx(), category, key) {
                                paint_preview(ui.painter(), art.shrink(4.0), texture, Color32::WHITE);
                            } else {
                                paint_missing_preview(ui, art, "预览图读取失败");
                            }
                        } else {
                            paint_missing_preview(ui, art, "无材质预览图");
                        }
                        ui.painter().text(
                            egui::pos2(rect.left() + 9.0, rect.top() + 136.0),
                            Align2::LEFT_CENTER,
                            elide(key, 27),
                            FontId::proportional(10.5),
                            if enabled { theme::TEXT } else { theme::DISABLED },
                        );
                        let client_label = match client_available {
                            Some(true) => "已验证",
                            Some(false) => "不可用",
                            None => "未验证",
                        };
                        let state = if equipped {
                            format!("已装备 · 客户端{client_label}")
                        } else if !*complete {
                            "资源包缺失".to_owned()
                        } else if !unlocked {
                            "未加入本地解锁清单".to_owned()
                        } else {
                            format!("本地可装备 · 客户端{client_label}")
                        };
                        ui.painter().text(
                            egui::pos2(rect.left() + 9.0, rect.top() + 160.0),
                            Align2::LEFT_CENTER,
                            &state,
                            FontId::proportional(9.2),
                            if equipped {
                                theme::ACCENT
                            } else if client_available == &Some(false) || !enabled {
                                theme::DANGER
                            } else if enabled {
                                theme::SUCCESS
                            } else {
                                theme::FAINT
                            },
                        );
                        let resp = if enabled {
                            resp.on_hover_cursor(CursorIcon::PointingHand)
                        } else {
                            resp.on_hover_cursor(CursorIcon::NotAllowed)
                        };
                        if resp.clicked() && enabled {
                            profile.toggle_cosmetic(category, key);
                            dirty = true;
                        }
                        if resp.hovered() {
                            resp.on_hover_text(format!(
                                "{key}\n资源包：{}\n材质预览：{}\n客户端使用状态：{client_label}",
                                if *complete { "已索引" } else { "缺失" },
                                if *preview_available { "已索引" } else { "缺失" },
                            ));
                        }
                    }
                });
                if acc.is_empty() {
                    ui.add_space(30.0);
                    ui.vertical_centered(|ui| {
                        ui.label(RichText::new("没有匹配的饰品").size(13.0).color(theme::FAINT));
                    });
                }
                ui.add_space(18.0);
            });
        dirty
    }

    fn online_services_page(&mut self, ui: &mut Ui) -> bool {
        const SERVICES: [(&str, &str); 8] = [
            ("好友与私聊", "在线账号与消息服务"),
            ("军团", "军团成员、申请与仓库服务"),
            ("天梯排行", "在线赛季与段位数据"),
            ("交易市场", "挂售、购买与余额校验"),
            ("商城充值", "支付与账户余额服务"),
            ("武器工坊", "在线锻造与配件服务"),
            ("任务活动", "每日任务、活动与奖励领取"),
            ("抽奖系统", "在线奖池与奖励发放"),
        ];
        ScrollArea::vertical()
            .id_salt("online-services-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "在线服务",
                    "离线大厅不伪造 AMF3/RPC 成功响应；这些项目需要真实在线服务。",
                    Some(("离线不可用".to_owned(), theme::FAINT, theme::GHOST)),
                );
                ui.add_space(14.0);
                let width = ui.available_width();
                let spacing = ui.spacing().item_spacing.x;
                let columns = columns_for(width, 218.0, spacing).clamp(1, 4);
                let card_width = ((width - spacing * (columns - 1) as f32) / columns as f32)
                    .floor()
                    .max(190.0);
                ui.horizontal_wrapped(|ui| {
                    ui.spacing_mut().item_spacing = Vec2::new(spacing, 10.0);
                    for (name, detail) in SERVICES {
                        let (rect, response) = ui.allocate_exact_size(
                            Vec2::new(card_width, 100.0),
                            Sense::hover(),
                        );
                        ui.painter().rect_filled(
                            rect,
                            Rounding::same(9.0),
                            if response.hovered() {
                                theme::CARD_HOVER
                            } else {
                                theme::CARD
                            },
                        );
                        ui.painter().rect_stroke(
                            rect,
                            Rounding::same(9.0),
                            Stroke::new(1.0_f32, theme::LINE_SOFT),
                        );
                        ui.painter().text(
                            rect.min + Vec2::new(12.0, 22.0),
                            Align2::LEFT_CENTER,
                            name,
                            FontId::proportional(14.0),
                            theme::TEXT,
                        );
                        ui.painter().text(
                            rect.min + Vec2::new(12.0, 48.0),
                            Align2::LEFT_CENTER,
                            "离线不可用",
                            FontId::proportional(10.5),
                            theme::FAINT,
                        );
                        ui.painter().text(
                            rect.min + Vec2::new(12.0, 76.0),
                            Align2::LEFT_CENTER,
                            elide(detail, 32),
                            FontId::proportional(10.0),
                            theme::MUTED,
                        );
                    }
                });
                ui.add_space(12.0);
                ui.label(
                    RichText::new(
                        "本地资料、武器仓库、皮肤、喷漆、饰品、勋章、称号和战斗配置可离线操作；在线项目不会扣除本地金币，也不会假装领取或交易成功。",
                    )
                    .size(11.0)
                    .color(theme::FAINT),
                );
            });
        false
    }

    fn settings_page(&mut self, ui: &mut Ui) -> bool {
        let mut dirty = false;
        let weapon_previews = self
            .inventory
            .weapons
            .iter()
            .filter(|item| {
                crate::official_preview::has("weapon", &item.key)
            })
            .count();
        let character_previews = self
            .inventory
            .characters
            .iter()
            .filter(|item| item.has_official_lobby_icon())
            .count();
        let spray_previews = self
            .inventory
            .sprays
            .iter()
            .filter(|item| crate::official_preview::has("spray", &item.id.to_string()))
            .count();
        let skin_previews = self
            .inventory
            .weapon_skins
            .iter()
            .filter(|item| crate::official_preview::has("skin", &item.key))
            .count();
        let accessory_previews = self
            .inventory
            .accessories
            .iter()
            .filter(|item| crate::official_preview::has("accessory", &item.key))
            .count();
        let avatar_part_previews = self
            .inventory
            .avatar_parts
            .iter()
            .filter(|item| crate::official_preview::has("avatar_part", &item.key))
            .count();
        ScrollArea::vertical()
            .id_salt("settings-page")
            .auto_shrink([false, false])
            .show(ui, |ui| {
                ui.set_width(ui.available_width());
                page_header(
                    ui,
                    "启动器设置",
                    "路径与出生点会保存在本机；大厅选择变更后自动持久化。",
                    Some(("自动保存".to_owned(), theme::SUCCESS, theme::SUCCESS_SOFT)),
                );
                ui.add_space(18.0);

                theme::section_label(ui, "客户端与启动脚本");
                ui.add_space(6.0);
                Frame::none()
                    .fill(theme::CARD)
                    .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
                    .rounding(Rounding::same(12.0))
                    .inner_margin(Margin::same(18.0))
                    .show(ui, |ui| {
                        ui.set_min_width(ui.available_width());

                        ui.label(theme::muted("游戏目录"));
                        if ui
                            .add(
                                egui::TextEdit::singleline(&mut self.settings.game_dir)
                                    .desired_width(f32::INFINITY)
                                    .hint_text(settings::DEFAULT_GAME_DIR),
                            )
                            .changed()
                        {
                            dirty = true;
                        }
                        path_status(
                            ui,
                            Path::new(self.settings.game_dir.trim()).is_dir(),
                            "目录存在",
                            "目录不存在",
                        );

                        ui.add_space(12.0);
                        ui.label(theme::muted("启动脚本（start_offline.py）"));
                        if ui
                            .add(
                                egui::TextEdit::singleline(&mut self.settings.start_script)
                                    .desired_width(f32::INFINITY)
                                    .hint_text(settings::default_start_script()),
                            )
                            .changed()
                        {
                            dirty = true;
                        }
                        path_status(
                            ui,
                            Path::new(self.settings.start_script.trim()).is_file(),
                            "脚本存在",
                            "找不到脚本",
                        );

                        ui.add_space(12.0);
                        ui.label(theme::muted("Python 可执行文件"));
                        if ui
                            .add(
                                egui::TextEdit::singleline(&mut self.settings.python)
                                    .desired_width(f32::INFINITY)
                                    .hint_text(settings::default_python()),
                            )
                            .changed()
                        {
                            dirty = true;
                        }
                        let python = self.settings.python.trim();
                        if python.contains('\\') || python.contains('/') {
                            path_status(
                                ui,
                                Path::new(python).is_file(),
                                "解释器存在",
                                "找不到解释器",
                            );
                        } else {
                            ui.horizontal(|ui| {
                                theme::dot(ui, theme::INFO, 3.0);
                                ui.label(
                                    RichText::new("将从 PATH 中查找")
                                        .size(10.5)
                                        .color(theme::FAINT),
                                );
                            });
                        }

                        ui.add_space(12.0);
                        ui.label(theme::muted("地图安装脚本（install_map.py）"));
                        if ui
                            .add(
                                egui::TextEdit::singleline(&mut self.settings.map_install_script)
                                    .desired_width(f32::INFINITY)
                                    .hint_text(settings::default_map_install_script()),
                            )
                            .changed()
                        {
                            dirty = true;
                        }
                        path_status(
                            ui,
                            self.settings.map_install_script.trim().is_empty()
                                || Path::new(self.settings.map_install_script.trim()).is_file(),
                            if self.settings.map_install_script.trim().is_empty() {
                                "留空 = 关闭自动装图"
                            } else {
                                "脚本存在"
                            },
                            "找不到脚本",
                        );
                    });

                ui.add_space(20.0);
                theme::section_label(ui, "出生点");
                ui.add_space(6.0);
                Frame::none()
                    .fill(theme::CARD)
                    .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
                    .rounding(Rounding::same(12.0))
                    .inner_margin(Margin::same(18.0))
                    .show(ui, |ui| {
                        ui.set_min_width(ui.available_width());
                        ui.label(
                            RichText::new("按 [x, y, z] 数组写入 launch_config.json，默认全为 0。")
                                .size(11.5)
                                .color(theme::MUTED),
                        );
                        ui.add_space(6.0);
                        ui.columns(3, |columns| {
                            for (index, name) in ["X", "Y", "Z"].iter().enumerate() {
                                columns[index].label(theme::muted(*name));
                                columns[index].add_space(4.0);
                                let response = columns[index].add_sized(
                                    [columns[index].available_width(), 30.0],
                                    egui::DragValue::new(&mut self.settings.spawn[index])
                                        .speed(10.0),
                                );
                                if response.changed() {
                                    dirty = true;
                                }
                            }
                        });
                    });

                ui.add_space(20.0);
                theme::section_label(ui, "运行信息");
                ui.add_space(6.0);
                Frame::none()
                    .fill(theme::PANEL_SOFT)
                    .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
                    .rounding(Rounding::same(12.0))
                    .inner_margin(Margin::same(18.0))
                    .show(ui, |ui| {
                        ui.set_min_width(ui.available_width());
                        info_row(
                            ui,
                            "中文字体",
                            self.font_name.as_deref().unwrap_or("未加载"),
                            self.font_name.is_some(),
                        );
                        info_row(
                            ui,
                            "资源清单",
                            &format!(
                                "{} 武器 / {} 角色 / {} 地图（已编译进 exe）",
                                self.inventory.weapons.len(),
                                self.inventory.characters.len(),
                                self.inventory.maps.len()
                            ),
                            true,
                        );
                        info_row(
                            ui,
                            "本地预览图",
                            &format!(
                                "武器 {weapon_previews}/{} · 角色 {character_previews}/{} · 武器皮肤 {skin_previews}/{} · 喷漆 {spray_previews}/{} · 地图 {}/{}",
                                self.inventory.weapons.len(),
                                self.inventory.characters.len(),
                                self.inventory.weapon_skins.len(),
                                self.inventory.sprays.len(),
                                self.inventory.maps.iter().filter(|item| item.preview_available).count(),
                                self.inventory.maps.len(),
                            ),
                            true,
                        );
                        info_row(
                            ui,
                            "勋章 / 称号",
                            &format!(
                                "勋章 {} 个预览 · 称号 {} 个预览 · 客户端使用状态待验证",
                                self.inventory.previewed_medal_count(),
                                self.inventory.previewed_title_count(),
                            ),
                            true,
                        );
                        info_row(
                            ui,
                            "官方大厅图标",
                            &format!(
                                "饰品 {accessory_previews}/{} · 角色部件 {avatar_part_previews}/{}（仅匹配到原版 SWF 图标的项目）",
                                self.inventory.accessories.len(),
                                self.inventory.avatar_parts.len(),
                            ),
                            accessory_previews + avatar_part_previews > 0,
                        );
                        info_row(
                            ui,
                            "地图状态",
                            &format!(
                                "已安装 {} · 启动时校验 {} · 资源可选 {}",
                                self.inventory.installed_map_count(),
                                self.inventory.install_at_launch_map_count(),
                                self.inventory.available_map_count(),
                            ),
                            self.inventory.installed_map_count() > 0,
                        );
                        info_row(
                            ui,
                            "资源完整度",
                            &format!(
                                "武器 {}/{} · 角色 {}/{} · 武器皮肤 {}/{} · 角色皮肤 {}/{} · 喷漆 {}/{} · 饰品 {}/{}",
                                self.inventory.available_weapon_count(), self.inventory.weapons.len(),
                                self.inventory.available_character_count(), self.inventory.characters.len(),
                                self.inventory.available_weapon_skin_count(), self.inventory.weapon_skins.len(),
                                self.inventory.available_career_skin_count(), self.inventory.career_skins.len(),
                                self.inventory.available_spray_count(), self.inventory.sprays.len(),
                                self.inventory.available_accessory_count() + self.inventory.available_avatar_part_count(),
                                self.inventory.accessories.len() + self.inventory.avatar_parts.len(),
                            ),
                            true,
                        );
                        if let Ok(path) = settings::user_config_path() {
                            info_row(ui, "大厅配置", &path.display().to_string(), true);
                        }
                        if let Ok(path) = crate::launcher::launcher_log_path() {
                            info_row(ui, "启动日志", &path.display().to_string(), true);
                        }
                        if let Ok(path) = crate::preview_bridge::state_path() {
                            info_row(
                                ui,
                                "展台状态快照",
                                &path.display().to_string(),
                                true,
                            );
                        }
                        info_row(
                            ui,
                            "展台命名管道",
                            &format!(
                                "{} · 等待 Unity 渲染端连接",
                                crate::preview_bridge::PIPE_NAME
                            ),
                            false,
                        );
                        info_row(
                            ui,
                            "启动配置",
                            &settings::launch_config_path(&self.settings)
                                .display()
                                .to_string(),
                            true,
                        );
                    });

                if let Some(font_error) = &self.font_error {
                    ui.add_space(12.0);
                    warning_banner(ui, "字体问题", font_error);
                }
                ui.add_space(18.0);
            });
        dirty
    }

    fn draw_notice(&mut self, ctx: &egui::Context) {
        if self
            .notice
            .as_ref()
            .is_some_and(|notice| Instant::now() >= notice.until)
        {
            self.notice = None;
        }
        let Some(notice) = self.notice.clone() else {
            return;
        };
        let (fg, bg, border) = notice.colors();
        egui::Area::new(egui::Id::new("lobby-notice"))
            .anchor(Align2::RIGHT_BOTTOM, egui::vec2(-26.0, -108.0))
            .order(egui::Order::Foreground)
            .show(ctx, |ui| {
                Frame::none()
                    .fill(bg)
                    .stroke(Stroke::new(1.0_f32, border))
                    .rounding(Rounding::same(10.0))
                    .inner_margin(Margin::symmetric(14.0, 10.0))
                    .show(ui, |ui| {
                        ui.set_max_width(440.0);
                        ui.label(RichText::new(notice.text).size(12.5).color(fg));
                    });
            });
        ctx.request_repaint_after(Duration::from_millis(200));
    }
}

impl eframe::App for LobbyApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        if let Some(event) = self.launch.poll() {
            match event {
                MonitorEvent::GameStarted => {
                    self.toast(NoticeKind::Success, "游戏已启动，正在进入战场…");
                }
                MonitorEvent::GameExited => {
                    self.toast(NoticeKind::Info, "游戏已退出，欢迎回到大厅");
                }
            }
        }

        self.title_bar(ctx);
        self.sidebar(ctx);
        self.bottom_bar(ctx);
        self.central(ctx);
        self.draw_notice(ctx);
        resize_handles(ctx);

        if self.launch.is_busy() {
            ctx.request_repaint_after(Duration::from_millis(250));
        } else {
            ctx.request_repaint_after(Duration::from_millis(900));
        }
    }

    fn clear_color(&self, _visuals: &egui::Visuals) -> [f32; 4] {
        let color = theme::BG;
        [
            color.r() as f32 / 255.0,
            color.g() as f32 / 255.0,
            color.b() as f32 / 255.0,
            1.0,
        ]
    }
}

fn nav_item(ui: &mut Ui, page: Page, current: Page, count: Option<usize>) -> bool {
    let height = 40.0;
    let (rect, response) =
        ui.allocate_exact_size(Vec2::new(ui.available_width(), height), Sense::click());
    let selected = page == current;
    let hovered = response.hovered();
    let painter = ui.painter();

    if selected {
        painter.rect_filled(rect, Rounding::same(8.0), theme::GHOST);
        painter.rect_stroke(rect, Rounding::same(8.0), Stroke::new(1.0_f32, theme::LINE));
    } else if hovered {
        painter.rect_filled(rect, Rounding::same(8.0), theme::GHOST_HOVER);
    }

    draw_nav_icon(
        painter,
        egui::pos2(rect.left() + 20.0, rect.center().y),
        page,
        if selected { theme::TEXT } else { theme::MUTED },
    );

    painter.text(
        egui::pos2(rect.left() + 39.0, rect.center().y),
        Align2::LEFT_CENTER,
        page.label(),
        FontId::proportional(13.5),
        if selected { theme::TEXT } else { theme::MUTED },
    );

    if let Some(count) = count {
        painter.text(
            egui::pos2(rect.right() - 11.0, rect.center().y),
            Align2::RIGHT_CENTER,
            count.to_string(),
            FontId::proportional(10.5),
            if selected { theme::MUTED } else { theme::FAINT },
        );
    }

    if selected {
        painter.circle_filled(
            egui::pos2(rect.left() + 8.0, rect.center().y),
            1.8,
            theme::ACCENT,
        );
    }

    let response = response.on_hover_cursor(CursorIcon::PointingHand);
    response.clicked()
}

fn draw_nav_icon(painter: &egui::Painter, center: egui::Pos2, page: Page, color: Color32) {
    let stroke = Stroke::new(1.35_f32, color);
    let (cx, cy) = (center.x, center.y);
    match page {
        Page::Maps => {
            painter.circle_stroke(egui::pos2(cx, cy - 2.0), 4.2, stroke);
            painter.line_segment(
                [egui::pos2(cx - 2.9, cy + 1.1), egui::pos2(cx, cy + 5.6)],
                stroke,
            );
            painter.line_segment(
                [egui::pos2(cx + 2.9, cy + 1.1), egui::pos2(cx, cy + 5.6)],
                stroke,
            );
            painter.circle_filled(egui::pos2(cx, cy - 2.0), 1.3, color);
        }
        Page::Characters => {
            painter.circle_stroke(egui::pos2(cx, cy - 3.0), 3.2, stroke);
            let mut shoulders = Vec::with_capacity(9);
            for step in 0..=8 {
                let angle = std::f32::consts::PI * (1.0 + step as f32 / 8.0);
                shoulders.push(egui::pos2(
                    cx + angle.cos() * 5.6,
                    cy + 5.4 + angle.sin() * 3.6,
                ));
            }
            painter.add(Shape::line(shoulders, stroke));
        }
        Page::Weapons => {
            painter.circle_stroke(center, 4.8, stroke);
            for (dx, dy) in [(0.0_f32, -1.0_f32), (0.0, 1.0), (-1.0, 0.0), (1.0, 0.0)] {
                painter.line_segment(
                    [
                        egui::pos2(cx + dx * 3.1, cy + dy * 3.1),
                        egui::pos2(cx + dx * 6.6, cy + dy * 6.6),
                    ],
                    stroke,
                );
            }
            painter.circle_filled(center, 1.1, color);
        }
        Page::Sprays => {
            // 喷罐：罐体 + 喷头 + 雾点。
            painter.rect_stroke(
                Rect::from_min_max(
                    egui::pos2(cx - 4.6, cy - 2.4),
                    egui::pos2(cx + 1.4, cy + 5.6),
                ),
                Rounding::same(1.4),
                stroke,
            );
            painter.line_segment(
                [
                    egui::pos2(cx - 1.6, cy - 2.4),
                    egui::pos2(cx - 1.6, cy - 4.8),
                ],
                stroke,
            );
            painter.line_segment(
                [
                    egui::pos2(cx - 1.6, cy - 4.8),
                    egui::pos2(cx + 1.6, cy - 4.8),
                ],
                stroke,
            );
            for (dx, dy, r) in [
                (3.6_f32, -6.0_f32, 1.2_f32),
                (5.6, -3.8, 0.9),
                (4.2, -1.4, 0.7),
            ] {
                painter.circle_filled(egui::pos2(cx + dx, cy + dy), r, color);
            }
        }
        Page::Cosmetics => {
            // 菱形宝石 + 挂绳。
            let top = egui::pos2(cx, cy - 5.6);
            let right = egui::pos2(cx + 4.8, cy - 0.6);
            let bottom = egui::pos2(cx, cy + 5.6);
            let left = egui::pos2(cx - 4.8, cy - 0.6);
            painter.add(Shape::closed_line(vec![top, right, bottom, left], stroke));
            painter.line_segment([left, right], stroke);
            painter.line_segment([top, bottom], stroke);
        }
        Page::Honors => {
            painter.circle_stroke(center, 4.8, stroke);
            painter.line_segment([egui::pos2(cx, cy - 7.0), egui::pos2(cx, cy - 4.6)], stroke);
            painter.line_segment(
                [
                    egui::pos2(cx - 5.0, cy + 4.8),
                    egui::pos2(cx - 3.2, cy + 7.0),
                ],
                stroke,
            );
            painter.line_segment(
                [
                    egui::pos2(cx + 5.0, cy + 4.8),
                    egui::pos2(cx + 3.2, cy + 7.0),
                ],
                stroke,
            );
        }
        Page::OnlineServices => {
            let center = egui::pos2(cx, cy);
            for point in [
                egui::pos2(cx, cy - 4.8),
                egui::pos2(cx - 4.4, cy + 3.6),
                egui::pos2(cx + 4.4, cy + 3.6),
            ] {
                painter.line_segment([center, point], stroke);
                painter.circle_filled(point, 1.8, color);
            }
            painter.circle_stroke(center, 2.0, stroke);
        }
        Page::Settings => {
            for (row, knob) in [(0usize, 0.68_f32), (1, 0.34), (2, 0.74)] {
                let y = cy - 4.4 + row as f32 * 4.4;
                painter.line_segment([egui::pos2(cx - 5.6, y), egui::pos2(cx + 5.6, y)], stroke);
                painter.circle_filled(egui::pos2(cx - 5.6 + 11.2 * knob, y), 1.9, color);
            }
        }
    }
}

fn career_label(value: &str) -> &str {
    match value {
        "police" => "警察",
        "terrorist" => "恐怖分子",
        other => other,
    }
}

/// [PATCH] 皮肤选择行：标签 + 搜索框 + 下拉（只列资源完整的皮肤）。
/// `selected` 为空串 = 默认皮肤。返回是否有改动。
fn skin_picker(
    ui: &mut Ui,
    label: &str,
    hint: &str,
    search: &mut String,
    keys: &[String],
    selected: &mut String,
    id_salt: &str,
) -> bool {
    let mut changed = false;
    Frame::none()
        .fill(theme::CARD)
        .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
        .rounding(Rounding::same(10.0))
        .inner_margin(Margin::symmetric(14.0, 10.0))
        .show(ui, |ui| {
            ui.set_min_width(ui.available_width());
            ui.horizontal(|ui| {
                ui.label(theme::muted(label));
                ui.add_space(8.0);
                ui.add(
                    egui::TextEdit::singleline(search)
                        .desired_width(170.0)
                        .hint_text("搜索皮肤"),
                );
                ui.add_space(8.0);

                let filter = search.trim().to_ascii_lowercase();
                let list: Vec<&String> = keys
                    .iter()
                    .filter(|k| filter.is_empty() || k.to_ascii_lowercase().contains(&filter))
                    .collect();

                let display = if selected.trim().is_empty() {
                    "默认皮肤".to_owned()
                } else {
                    selected.trim().to_owned()
                };
                let combo_id = format!("{id_salt}-select");
                egui::ComboBox::from_id_salt(&combo_id)
                    .width(250.0)
                    .selected_text(display)
                    .show_ui(ui, |ui| {
                        if ui
                            .selectable_label(selected.trim().is_empty(), "默认皮肤")
                            .clicked()
                        {
                            *selected = String::new();
                            changed = true;
                        }
                        for key in list.iter().take(500) {
                            let picked = selected.trim() == key.as_str();
                            if ui.selectable_label(picked, key.as_str()).clicked() {
                                *selected = (*key).clone();
                                changed = true;
                            }
                        }
                    });

                ui.add_space(8.0);
                ui.label(
                    RichText::new(format!("{} 个可用", keys.len()))
                        .size(11.0)
                        .color(theme::FAINT),
                );
                if !selected.trim().is_empty() {
                    ui.add_space(6.0);
                    if theme::pill(ui, "恢复默认", theme::FAINT, theme::GHOST).clicked() {
                        *selected = String::new();
                        changed = true;
                    }
                }
            });
            ui.add_space(4.0);
            ui.label(RichText::new(hint).size(11.0).color(theme::FAINT));
        });
    changed
}

fn page_header(
    ui: &mut Ui,
    title: &str,
    subtitle: &str,
    badge: Option<(String, Color32, Color32)>,
) {
    ui.horizontal(|ui| {
        ui.vertical(|ui| {
            theme::page_title(ui, title, subtitle);
        });
        if let Some((text, fg, bg)) = badge {
            ui.with_layout(Layout::right_to_left(Align::Center), |ui| {
                theme::pill(ui, text, fg, bg);
            });
        }
    });
}

fn paint_preview(
    painter: &egui::Painter,
    area: Rect,
    texture: &egui::TextureHandle,
    tint: Color32,
) {
    let size = texture.size_vec2();
    if size.x <= 0.0 || size.y <= 0.0 || area.width() <= 0.0 || area.height() <= 0.0 {
        return;
    }
    let scale = (area.width() / size.x).min(area.height() / size.y);
    let rect = Rect::from_center_size(area.center(), size * scale);
    painter.image(
        texture.id(),
        rect,
        Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0)),
        tint,
    );
}

fn paint_missing_preview(ui: &Ui, area: Rect, label: &str) {
    ui.painter()
        .rect_filled(area, Rounding::same(5.0), theme::PANEL_SOFT);
    ui.painter().text(
        area.center(),
        Align2::CENTER_CENTER,
        label,
        FontId::proportional(10.0),
        theme::FAINT,
    );
}

fn map_card(
    ui: &mut Ui,
    preview: Option<&egui::TextureHandle>,
    map: &GameMap,
    selected: bool,
    width: f32,
) -> bool {
    let height = 174.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let enabled = map.available();
    let hovered = enabled && response.hovered();
    let response = if enabled {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    };
    let clicked = enabled && response.clicked();

    let painter = ui.painter();
    let fill = if !enabled {
        theme::PANEL_SOFT
    } else if hovered {
        theme::CARD_HOVER
    } else {
        theme::CARD
    };
    let border = if selected {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else if hovered {
        Stroke::new(1.0_f32, theme::LINE)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    painter.rect_filled(rect, Rounding::same(10.0), fill);
    painter.rect_stroke(rect, Rounding::same(10.0), border);

    let art = Rect::from_min_max(rect.min, egui::pos2(rect.right(), rect.top() + 104.0));
    let art_painter = painter.with_clip_rect(art);
    match preview {
        Some(texture) => {
            let art_rounding = Rounding {
                nw: 10.0,
                ne: 10.0,
                sw: 0.0,
                se: 0.0,
            };
            painter.rect_filled(
                art,
                art_rounding,
                if enabled {
                    Color32::from_rgb(15, 23, 29)
                } else {
                    Color32::from_rgb(17, 22, 27)
                },
            );
            let area = Rect::from_min_max(
                art.left_top() + egui::vec2(8.0, 20.0),
                art.right_bottom() - egui::vec2(8.0, 6.0),
            );
            paint_preview(
                &art_painter,
                area,
                texture,
                if enabled {
                    Color32::WHITE
                } else {
                    Color32::from_white_alpha(90)
                },
            );
        }
        None => draw_map_art(&art_painter, art, map, enabled),
    }

    let preview_label = if map.preview_available {
        "地图资源包 · 有预览图"
    } else {
        "地图资源包 · 暂无预览图"
    };
    art_painter.text(
        art.left_top() + egui::vec2(12.0, 10.0),
        Align2::LEFT_TOP,
        preview_label,
        FontId::proportional(9.5),
        if map.preview_available {
            theme::MUTED
        } else {
            theme::DANGER
        },
    );

    let (tag_text, tag_fg, tag_bg) = match map.availability {
        MapAvailability::Installed if selected => ("已选择", theme::ON_ACCENT, theme::ACCENT),
        MapAvailability::Installed => ("已安装", theme::SUCCESS, theme::SUCCESS_SOFT),
        MapAvailability::InstallAtLaunch => ("启动时验证", theme::INFO, theme::INFO_SOFT),
        MapAvailability::NotIntegrated => ("未接入", theme::FAINT, theme::GHOST),
        MapAvailability::IncompleteResources => ("资源不完整", theme::DANGER, theme::DANGER_SOFT),
    };
    draw_tag(
        &art_painter,
        egui::pos2(art.right() - 9.0, art.top() + 9.0),
        tag_text,
        tag_fg,
        tag_bg,
    );

    let title_color = if enabled {
        theme::TEXT
    } else {
        theme::DISABLED
    };
    painter.text(
        egui::pos2(rect.left() + 13.0, art.bottom() + 14.0),
        Align2::LEFT_TOP,
        &map.id,
        FontId::proportional(17.0),
        title_color,
    );
    painter.text(
        egui::pos2(rect.left() + 13.0, art.bottom() + 39.0),
        Align2::LEFT_TOP,
        format!("{} · {}", map.key, map.src),
        FontId::proportional(10.5),
        if enabled {
            theme::MUTED
        } else {
            theme::DISABLED
        },
    );
    painter.text(
        egui::pos2(rect.left() + 13.0, art.bottom() + 56.0),
        Align2::LEFT_TOP,
        elide(&map.md5, 34),
        FontId::monospace(9.5),
        theme::FAINT,
    );

    if !enabled {
        painter.rect_filled(rect, Rounding::same(10.0), Color32::from_black_alpha(70));
    }

    let tooltip = match map.availability {
        MapAvailability::Installed => {
            format!(
                "{}\n客户端已安装\n资源包：{}\n来源：{}",
                map.id, map.key, map.src
            )
        }
        MapAvailability::InstallAtLaunch => {
            format!(
                "{}\n启动时会运行本地安装校验；只有校验成功后才能进入\n资源包：{}\n来源：{}",
                map.id, map.key, map.src
            )
        }
        MapAvailability::NotIntegrated => {
            format!("{}\n未接入客户端，当前版本不可进入", map.key)
        }
        MapAvailability::IncompleteResources => {
            format!("{}\n资源不完整，缺少地图资源", map.key)
        }
    };
    response.on_hover_text(tooltip);
    clicked
}

fn draw_map_art(painter: &egui::Painter, rect: Rect, _map: &GameMap, enabled: bool) {
    let rounding = Rounding {
        nw: 10.0,
        ne: 10.0,
        sw: 0.0,
        se: 0.0,
    };
    let base = if enabled {
        Color32::from_rgb(15, 23, 29)
    } else {
        Color32::from_rgb(17, 22, 27)
    };
    painter.rect_filled(rect, rounding, base);

    painter.text(
        rect.center(),
        Align2::CENTER_CENTER,
        "暂无地图预览图",
        FontId::proportional(12.0),
        if enabled { theme::MUTED } else { theme::FAINT },
    );
}

fn character_card(
    ui: &mut Ui,
    preview: Option<&egui::TextureHandle>,
    character: &Character,
    selected: bool,
    width: f32,
) -> bool {
    let height = 158.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let enabled = character.selectable();
    let hovered = enabled && response.hovered();
    let response = if enabled {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    };
    let clicked = enabled && response.clicked();

    let painter = ui.painter();
    let fill = if !enabled {
        theme::PANEL_SOFT
    } else if hovered {
        theme::CARD_HOVER
    } else {
        theme::CARD
    };
    let border = if selected {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else if hovered {
        Stroke::new(1.0_f32, theme::LINE)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    painter.rect_filled(rect, Rounding::same(10.0), fill);
    painter.rect_stroke(rect, Rounding::same(10.0), border);

    let seed = hash_text(&character.key);
    let avatar_color = if enabled {
        AVATAR_COLORS[seed as usize % AVATAR_COLORS.len()]
    } else {
        theme::DISABLED
    };
    let center = egui::pos2(rect.center().x, rect.top() + 45.0);
    if let Some(texture) = preview {
        painter.circle_filled(center, 33.0, avatar_color.gamma_multiply(0.11));
        let area = Rect::from_min_max(
            egui::pos2(rect.left() + 6.0, rect.top() + 3.0),
            egui::pos2(rect.right() - 6.0, rect.top() + 87.0),
        );
        paint_preview(
            painter,
            area,
            texture,
            if enabled {
                Color32::WHITE
            } else {
                Color32::from_white_alpha(80)
            },
        );
    } else {
        painter.circle_filled(center, 28.0, avatar_color.gamma_multiply(0.17));
        painter.circle_stroke(
            center,
            28.0,
            Stroke::new(1.2_f32, avatar_color.gamma_multiply(0.65)),
        );
        painter.text(
            center,
            Align2::CENTER_CENTER,
            avatar_initial(&character.key),
            FontId::proportional(22.0),
            avatar_color,
        );
    }

    if selected {
        draw_tag(
            painter,
            egui::pos2(rect.right() - 8.0, rect.top() + 8.0),
            "已选择",
            theme::ON_ACCENT,
            theme::ACCENT,
        );
    } else if !enabled {
        let (label, fg, bg) = if character.npc_only {
            ("仅 NPC", theme::INFO, theme::INFO_SOFT)
        } else {
            ("缺资源", theme::DANGER, theme::DANGER_SOFT)
        };
        draw_tag(
            painter,
            egui::pos2(rect.right() - 8.0, rect.top() + 8.0),
            label,
            fg,
            bg,
        );
    } else if preview.is_none() {
        draw_tag(
            painter,
            egui::pos2(rect.right() - 8.0, rect.top() + 8.0),
            "无预览图",
            theme::DANGER,
            theme::DANGER_SOFT,
        );
    }

    let name = elide(character.display_name(), 13);
    painter.text(
        egui::pos2(rect.center().x, rect.top() + 94.0),
        Align2::CENTER_CENTER,
        name,
        FontId::proportional(13.0),
        if enabled {
            theme::TEXT
        } else {
            theme::DISABLED
        },
    );
    painter.text(
        egui::pos2(rect.center().x, rect.top() + 118.0),
        Align2::CENTER_CENTER,
        elide(&character.key, 18),
        FontId::monospace(9.5),
        theme::FAINT,
    );
    painter.text(
        egui::pos2(rect.center().x, rect.top() + 139.0),
        Align2::CENTER_CENTER,
        if !enabled {
            "资源不完整"
        } else if preview.is_some() {
            "资源完整 · 有预览"
        } else {
            "资源完整 · 无预览图"
        },
        FontId::proportional(10.5),
        if !enabled || preview.is_none() {
            theme::DANGER
        } else {
            theme::MUTED
        },
    );

    let tooltip = if enabled {
        format!(
            "角色：{}\n内部名：{}\n预览图：{}",
            character.display_name(),
            character.key,
            if preview.is_some() {
                "已找到"
            } else {
                "缺失"
            }
        )
    } else {
        format!("角色：{}\n资源不完整，无法选择", character.key)
    };
    response.on_hover_text(tooltip);
    clicked
}

fn recommended_categories(slot: usize) -> &'static [WeaponCategory] {
    match slot {
        1 => &[WeaponCategory::Pistol],
        2 => &[WeaponCategory::Melee],
        3 => &[WeaponCategory::Grenade],
        _ => &[
            WeaponCategory::Rifle,
            WeaponCategory::Sniper,
            WeaponCategory::Shotgun,
            WeaponCategory::Other,
        ],
    }
}

fn slot_card(
    ui: &mut Ui,
    index: usize,
    key: &str,
    weapon: Option<&Weapon>,
    preview: Option<&egui::TextureHandle>,
    selected: bool,
    width: f32,
) -> bool {
    let labels = ["主武器", "副武器", "近战", "投掷"];
    let height = 92.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let hovered = response.hovered();
    let painter = ui.painter();
    let fill = if selected {
        theme::ACCENT_SOFT
    } else if hovered {
        theme::CARD_HOVER
    } else {
        theme::PANEL_SOFT
    };
    let border = if selected {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    painter.rect_filled(rect, Rounding::same(10.0), fill);
    painter.rect_stroke(rect, Rounding::same(10.0), border);

    painter.text(
        rect.left_top() + egui::vec2(12.0, 9.0),
        Align2::LEFT_TOP,
        format!("{} · {}", index + 1, labels[index.min(3)]),
        FontId::proportional(10.5),
        theme::MUTED,
    );
    let name = weapon
        .map(|weapon| weapon.display_name())
        .filter(|name| !name.trim().is_empty())
        .unwrap_or(key);
    let name = if name.trim().is_empty() {
        "空槽位"
    } else {
        name
    };
    let name_chars = if preview.is_some() { 7 } else { 12 };
    painter.text(
        rect.left_top() + egui::vec2(12.0, 32.0),
        Align2::LEFT_TOP,
        elide(name, name_chars),
        FontId::proportional(15.0),
        theme::TEXT,
    );
    painter.text(
        rect.left_top() + egui::vec2(12.0, 58.0),
        Align2::LEFT_TOP,
        elide(key, if preview.is_some() { 11 } else { 18 }),
        FontId::proportional(10.0),
        theme::FAINT,
    );
    if let Some(texture) = preview {
        let art = Rect::from_min_max(
            egui::pos2(rect.right() - 72.0, rect.top() + 14.0),
            egui::pos2(rect.right() - 8.0, rect.bottom() - 12.0),
        );
        paint_preview(
            &painter.with_clip_rect(art),
            art,
            texture,
            if weapon.is_some_and(|weapon| weapon.complete) {
                Color32::WHITE
            } else {
                Color32::from_white_alpha(90)
            },
        );
    }
    if weapon.is_some_and(|weapon| !weapon.complete) {
        draw_tag(
            painter,
            egui::pos2(rect.right() - 8.0, rect.top() + 8.0),
            "资源不完整",
            theme::DANGER,
            theme::DANGER_SOFT,
        );
    }
    if selected {
        painter.circle_filled(
            egui::pos2(rect.left() + 8.0, rect.center().y),
            2.5,
            theme::ACCENT,
        );
    }
    response
        .on_hover_cursor(CursorIcon::PointingHand)
        .on_hover_text(format!(
            "{}\n槽位武器：{}\n内部名：{}",
            labels[index.min(3)],
            weapon.map(|w| w.display_name()).unwrap_or("未装载"),
            if key.is_empty() { "-" } else { key }
        ))
        .clicked()
}

/// [PATCH] 槽位皮肤行：缩略图 + 当前皮肤 + 选/清按钮。
fn slot_skin_row(
    ui: &mut Ui,
    index: usize,
    skin: &str,
    thumb: Option<&egui::TextureHandle>,
) -> SkinRowAction {
    let labels = ["主武器", "副武器", "近战", "投掷"];
    let skin = skin.trim();
    let mut action = SkinRowAction::None;
    Frame::none()
        .fill(theme::PANEL_SOFT)
        .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
        .rounding(Rounding::same(8.0))
        .inner_margin(Margin::symmetric(10.0, 8.0))
        .show(ui, |ui| {
            ui.set_min_width(ui.available_width());
            ui.horizontal(|ui| {
                ui.label(
                    RichText::new(format!("{}皮肤", labels[index.min(3)]))
                        .size(10.5)
                        .color(theme::MUTED),
                );
                ui.add_space(4.0);
                if let Some(texture) = thumb {
                    let (rect, _) = ui.allocate_exact_size(Vec2::new(88.0, 24.0), Sense::hover());
                    paint_preview(
                        &ui.painter().with_clip_rect(rect),
                        rect,
                        texture,
                        Color32::WHITE,
                    );
                }
            });
            ui.add_space(2.0);
            ui.label(
                RichText::new(elide(
                    if skin.is_empty() {
                        "默认外观"
                    } else {
                        skin
                    },
                    26,
                ))
                .size(11.0)
                .color(if skin.is_empty() {
                    theme::FAINT
                } else {
                    theme::TEXT
                }),
            )
            .on_hover_text(if skin.is_empty() {
                "默认外观"
            } else {
                skin
            });
            ui.add_space(3.0);
            ui.horizontal(|ui| {
                if click_pill(ui, "选皮肤", theme::ACCENT, theme::ACCENT_SOFT) {
                    action = SkinRowAction::Pick;
                }
                if !skin.is_empty() && click_pill(ui, "默认", theme::FAINT, theme::GHOST) {
                    action = SkinRowAction::Clear;
                }
            });
        });
    action
}

/// [PATCH] 皮肤选择弹窗里的缩略图卡片（点一下即应用）。
fn skin_card(
    ui: &mut Ui,
    skin: &str,
    thumb: Option<&egui::TextureHandle>,
    selected: bool,
    resource_available: bool,
    preview_available: bool,
    client_available: Option<bool>,
    width: f32,
) -> bool {
    let height = 92.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let hovered = resource_available && response.hovered();
    let painter = ui.painter();
    let fill = if selected {
        theme::ACCENT_SOFT
    } else if hovered {
        theme::CARD_HOVER
    } else {
        theme::PANEL_SOFT
    };
    let border = if selected {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    painter.rect_filled(rect, Rounding::same(8.0), fill);
    painter.rect_stroke(rect, Rounding::same(8.0), border);

    let art = Rect::from_min_max(
        rect.left_top() + egui::vec2(8.0, 7.0),
        egui::pos2(rect.right() - 8.0, rect.top() + 59.0),
    );
    match thumb {
        Some(texture) => paint_preview(&painter.with_clip_rect(art), art, texture, Color32::WHITE),
        None => {
            painter.text(
                art.center(),
                Align2::CENTER_CENTER,
                "无预览图",
                FontId::proportional(10.0),
                theme::FAINT,
            );
        }
    }
    painter.text(
        egui::pos2(rect.left() + 9.0, rect.top() + 73.0),
        Align2::LEFT_CENTER,
        elide(skin, 24),
        FontId::proportional(10.5),
        if selected {
            theme::ACCENT
        } else if resource_available {
            theme::TEXT
        } else {
            theme::DISABLED
        },
    );
    painter.text(
        egui::pos2(rect.left() + 9.0, rect.top() + 85.0),
        Align2::LEFT_CENTER,
        match (resource_available, client_available) {
            (false, _) => "缺少本地资源包",
            (true, Some(true)) => "资源包已索引 · 游戏端已验证",
            (true, Some(false)) => "资源包已索引 · 游戏端不可用",
            (true, None) => "资源包已索引 · 游戏端未验证",
        },
        FontId::proportional(9.0),
        if !resource_available || client_available == Some(false) {
            theme::DANGER
        } else {
            theme::SUCCESS
        },
    );
    let response = if resource_available {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    };
    response
        .on_hover_text(format!(
            "{skin}\n本地模型资源包：{}\n预览图：{}",
            if resource_available {
                "已索引"
            } else {
                "缺失，不能应用"
            },
            if preview_available && thumb.is_some() {
                "已索引"
            } else {
                "缺失"
            }
        ))
        .clicked()
        && resource_available
}

fn collectible_card(
    ui: &mut Ui,
    item: &Collectible,
    preview: Option<&egui::TextureHandle>,
    equipped: bool,
    unlocked: bool,
    width: f32,
) -> bool {
    let height = 148.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let usable = item.complete && unlocked;
    let fill = if equipped {
        theme::ACCENT_SOFT
    } else if response.hovered() {
        theme::CARD_HOVER
    } else {
        theme::CARD
    };
    let border = if equipped {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    ui.painter().rect_filled(rect, Rounding::same(9.0), fill);
    ui.painter().rect_stroke(rect, Rounding::same(9.0), border);

    let art = Rect::from_min_max(
        rect.min + Vec2::new(8.0, 8.0),
        egui::pos2(rect.right() - 8.0, rect.top() + 88.0),
    );
    ui.painter()
        .rect_filled(art, Rounding::same(6.0), theme::PANEL_SOFT);
    if let Some(texture) = preview.filter(|_| item.preview_available) {
        paint_preview(ui.painter(), art.shrink(3.0), texture, Color32::WHITE);
    } else {
        ui.painter().text(
            art.center(),
            Align2::CENTER_CENTER,
            "无预览图",
            FontId::proportional(10.0),
            theme::DANGER,
        );
    }

    let name = elide(&item.name, 16);
    ui.painter().text(
        egui::pos2(rect.center().x, rect.top() + 104.0),
        Align2::CENTER_CENTER,
        name,
        FontId::proportional(11.5),
        if usable { theme::TEXT } else { theme::DISABLED },
    );
    let client_label = match item.client_available {
        Some(true) => "游戏端已验证",
        Some(false) => "游戏端不可用",
        None => "游戏端未验证",
    };
    ui.painter().text(
        egui::pos2(rect.center().x, rect.top() + 125.0),
        Align2::CENTER_CENTER,
        if equipped { "已装备" } else { client_label },
        FontId::proportional(9.5),
        if equipped {
            theme::ACCENT
        } else if item.client_available == Some(false) || preview.is_none() {
            theme::DANGER
        } else {
            theme::FAINT
        },
    );

    let response = if usable {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    };
    response
        .on_hover_text(format!(
            "{}\n资源 ID：{}\n{}\n预览图：{}",
            item.name,
            item.key,
            client_label,
            if item.preview_available {
                "已索引"
            } else {
                "缺失"
            }
        ))
        .clicked()
        && usable
}

fn weapon_card(
    ui: &mut Ui,
    preview: Option<&egui::TextureHandle>,
    weapon: &Weapon,
    selected: bool,
    width: f32,
) -> bool {
    let height = 164.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, height), Sense::click());
    let enabled = weapon.complete;
    let hovered = enabled && response.hovered();
    let response = if enabled {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    };
    let clicked = enabled && response.clicked();

    let painter = ui.painter();
    let fill = if !enabled {
        theme::PANEL_SOFT
    } else if hovered {
        theme::CARD_HOVER
    } else {
        theme::CARD
    };
    let border = if selected {
        Stroke::new(1.5_f32, theme::ACCENT)
    } else if hovered {
        Stroke::new(1.0_f32, theme::LINE)
    } else {
        Stroke::new(1.0_f32, theme::LINE_SOFT)
    };
    painter.rect_filled(rect, Rounding::same(10.0), fill);
    painter.rect_stroke(rect, Rounding::same(10.0), border);

    let art = Rect::from_min_max(rect.min, egui::pos2(rect.right(), rect.top() + 82.0));
    let art_rounding = Rounding {
        nw: 10.0,
        ne: 10.0,
        sw: 0.0,
        se: 0.0,
    };
    painter.rect_filled(
        art,
        art_rounding,
        if enabled {
            Color32::from_rgb(15, 23, 29)
        } else {
            Color32::from_rgb(17, 22, 27)
        },
    );

    let category = weapon.category();
    let art_painter = painter.with_clip_rect(art);
    if let Some(texture) = preview {
        let image_area = Rect::from_min_max(
            art.left_top() + egui::vec2(12.0, 24.0),
            art.right_bottom() - egui::vec2(12.0, 18.0),
        );
        paint_preview(
            &art_painter,
            image_area,
            texture,
            if enabled {
                Color32::WHITE
            } else {
                Color32::from_white_alpha(90)
            },
        );
    } else {
        art_painter.text(
            art.center() + egui::vec2(0.0, 2.0),
            Align2::CENTER_CENTER,
            category.glyph(),
            FontId::proportional(38.0),
            if enabled {
                theme::ACCENT.gamma_multiply(0.30)
            } else {
                Color32::from_white_alpha(10)
            },
        );
    }
    art_painter.text(
        art.left_top() + egui::vec2(11.0, 9.0),
        Align2::LEFT_TOP,
        if preview.is_some() {
            category.label().to_owned()
        } else {
            format!("{} · 无预览图", category.label())
        },
        FontId::proportional(10.0),
        if enabled && preview.is_some() {
            theme::MUTED
        } else if enabled {
            theme::DANGER
        } else {
            theme::FAINT
        },
    );
    art_painter.line_segment(
        [
            egui::pos2(art.left() + 11.0, art.bottom() - 13.0),
            egui::pos2(art.right() - 11.0, art.bottom() - 13.0),
        ],
        Stroke::new(
            1.0_f32,
            if enabled {
                theme::LINE
            } else {
                Color32::from_white_alpha(7)
            },
        ),
    );

    if selected {
        draw_tag(
            &art_painter,
            egui::pos2(art.right() - 8.0, art.top() + 8.0),
            "已装备",
            theme::ON_ACCENT,
            theme::ACCENT,
        );
    } else if !enabled {
        draw_tag(
            &art_painter,
            egui::pos2(art.right() - 8.0, art.top() + 8.0),
            "资源不完整",
            theme::DANGER,
            theme::DANGER_SOFT,
        );
    }

    painter.text(
        egui::pos2(rect.left() + 12.0, art.bottom() + 9.0),
        Align2::LEFT_TOP,
        elide(weapon.display_name(), 12),
        FontId::proportional(15.0),
        if enabled {
            theme::TEXT
        } else {
            theme::DISABLED
        },
    );

    let kind_text = if weapon.kind.trim().is_empty() {
        "未分类".to_owned()
    } else {
        elide(&weapon.kind, 18)
    };
    painter.text(
        egui::pos2(rect.left() + 12.0, art.bottom() + 30.0),
        Align2::LEFT_TOP,
        format!("{} · {}", category.label(), kind_text),
        FontId::proportional(10.5),
        if enabled {
            theme::MUTED
        } else {
            theme::DISABLED
        },
    );
    painter.text(
        egui::pos2(rect.left() + 12.0, art.bottom() + 48.0),
        Align2::LEFT_TOP,
        elide(&weapon.key, 26),
        FontId::monospace(9.5),
        theme::FAINT,
    );
    painter.text(
        egui::pos2(rect.right() - 12.0, art.bottom() + 57.0),
        Align2::RIGHT_BOTTOM,
        if !enabled {
            "资源不完整"
        } else if preview.is_some() {
            "可用 · 有图"
        } else {
            "可用 · 无图"
        },
        FontId::proportional(9.5),
        if enabled && preview.is_some() {
            theme::SUCCESS
        } else {
            theme::DANGER
        },
    );

    if !enabled {
        painter.rect_filled(rect, Rounding::same(10.0), Color32::from_black_alpha(54));
    }

    let tooltip = if enabled {
        format!(
            "{}\n内部名：{}\n类型：{}\n预览图：{}",
            weapon.display_name(),
            weapon.key,
            if weapon.kind.is_empty() {
                "未分类"
            } else {
                &weapon.kind
            },
            if preview.is_some() {
                "已找到"
            } else {
                "缺失"
            }
        )
    } else {
        format!(
            "{}\n内部名：{}\n资源不完整：缺少模型网格，无法装备",
            weapon.display_name(),
            weapon.key
        )
    };
    response.on_hover_text(tooltip);
    clicked
}

fn draw_tag(painter: &egui::Painter, right_top: egui::Pos2, text: &str, fg: Color32, bg: Color32) {
    let width = text.chars().count() as f32 * 10.2 + 15.0;
    let tag_rect = Rect::from_min_size(
        egui::pos2(right_top.x - width, right_top.y),
        egui::vec2(width, 20.0),
    );
    painter.rect_filled(tag_rect, Rounding::same(10.0), bg);
    painter.text(
        tag_rect.center(),
        Align2::CENTER_CENTER,
        text,
        FontId::proportional(10.0),
        fg,
    );
}

fn choice_pill(ui: &mut Ui, selected: bool, text: &str) -> bool {
    filter_button(ui, selected, text).clicked()
}

/// [PATCH] 可点击的小胶囊按钮（theme::pill 是纯展示 Sense::hover，点了没反应）。
fn click_pill(ui: &mut Ui, text: &str, fg: Color32, bg: Color32) -> bool {
    let font = FontId::proportional(11.0);
    let width = text_width(ui, text, font.clone()) + 18.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, 24.0), Sense::click());
    let fill = if response.hovered() {
        bg.gamma_multiply(1.6)
    } else {
        bg
    };
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(12.0), fill);
    painter.text(rect.center(), Align2::CENTER_CENTER, text, font, fg);
    response.on_hover_cursor(CursorIcon::PointingHand).clicked()
}

fn filter_button(ui: &mut Ui, selected: bool, text: &str) -> Response {
    let font = FontId::proportional(11.5);
    let width = text_width(ui, text, font.clone()) + 22.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, 30.0), Sense::click());
    let hovered = response.hovered();
    let fill = if selected {
        theme::SEGMENT_ON
    } else if hovered {
        theme::GHOST_HOVER
    } else {
        theme::GHOST
    };
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(8.0), fill);
    if selected {
        painter.rect_stroke(rect, Rounding::same(8.0), Stroke::new(1.0_f32, theme::LINE));
    }
    painter.text(
        rect.center(),
        Align2::CENTER_CENTER,
        text,
        font,
        if selected { theme::TEXT } else { theme::MUTED },
    );
    response.on_hover_cursor(CursorIcon::PointingHand)
}

fn segmented_choice(ui: &mut Ui, options: &[&str], selected: usize) -> Option<usize> {
    let mut clicked = None;
    Frame::none()
        .fill(theme::INPUT)
        .stroke(Stroke::new(1.0_f32, theme::LINE_SOFT))
        .rounding(Rounding::same(8.0))
        .inner_margin(Margin::same(3.0))
        .show(ui, |ui| {
            ui.spacing_mut().item_spacing.x = 2.0;
            ui.horizontal(|ui| {
                for (index, option) in options.iter().enumerate() {
                    let response = segment_button(ui, option, index == selected);
                    if response.clicked() {
                        clicked = Some(index);
                    }
                }
            });
        });
    clicked
}

fn segment_button(ui: &mut Ui, text: &str, selected: bool) -> Response {
    let font = FontId::proportional(12.0);
    let width = text_width(ui, text, font.clone()) + 20.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, 26.0), Sense::click());
    let hovered = response.hovered();
    let fill = if selected {
        theme::SEGMENT_ON
    } else if hovered {
        theme::GHOST_HOVER
    } else {
        Color32::TRANSPARENT
    };
    let painter = ui.painter();
    if fill != Color32::TRANSPARENT {
        painter.rect_filled(rect, Rounding::same(6.0), fill);
    }
    painter.text(
        rect.center(),
        Align2::CENTER_CENTER,
        text,
        font,
        if selected { theme::TEXT } else { theme::MUTED },
    );
    response.on_hover_cursor(CursorIcon::PointingHand)
}

fn number_stepper(ui: &mut Ui, value: &mut u8, min: u8, max: u8) -> bool {
    let mut changed = false;
    ui.horizontal(|ui| {
        ui.spacing_mut().item_spacing.x = 4.0;
        if step_button(ui, "−", *value > min).clicked() {
            *value = value.saturating_sub(1);
            changed = true;
        }

        let (rect, _) = ui.allocate_exact_size(Vec2::new(44.0, 30.0), Sense::hover());
        let painter = ui.painter();
        painter.rect_filled(rect, Rounding::same(7.0), theme::INPUT);
        painter.rect_stroke(
            rect,
            Rounding::same(7.0),
            Stroke::new(1.0_f32, theme::LINE_SOFT),
        );
        painter.text(
            rect.center(),
            Align2::CENTER_CENTER,
            value.to_string(),
            FontId::proportional(14.5),
            theme::TEXT,
        );

        if step_button(ui, "+", *value < max).clicked() {
            *value = (*value + 1).min(max);
            changed = true;
        }
    });
    changed
}

fn step_button(ui: &mut Ui, label: &str, enabled: bool) -> Response {
    let (rect, response) = ui.allocate_exact_size(Vec2::splat(30.0), Sense::click());
    let hovered = enabled && response.hovered();
    let pressed = enabled && response.is_pointer_button_down_on();
    let fill = if !enabled {
        theme::PANEL_SOFT
    } else if pressed {
        theme::SEGMENT_ON
    } else if hovered {
        theme::GHOST_HOVER
    } else {
        theme::INPUT
    };
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(7.0), fill);
    painter.rect_stroke(
        rect,
        Rounding::same(7.0),
        Stroke::new(1.0_f32, theme::LINE_SOFT),
    );
    painter.text(
        rect.center(),
        Align2::CENTER_CENTER,
        label,
        FontId::proportional(15.0),
        if enabled {
            theme::TEXT
        } else {
            theme::DISABLED
        },
    );
    if enabled {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response
    }
}

fn toggle_switch(ui: &mut Ui, on: &mut bool) -> bool {
    let (rect, response) = ui.allocate_exact_size(Vec2::new(40.0, 22.0), Sense::click());
    let progress = ui.ctx().animate_bool_with_time(response.id, *on, 0.18);
    let track = mix_color(theme::INPUT, theme::ACCENT, progress);
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(11.0), track);
    painter.rect_stroke(
        rect,
        Rounding::same(11.0),
        Stroke::new(
            1.0_f32,
            if *on {
                Color32::TRANSPARENT
            } else {
                theme::LINE_SOFT
            },
        ),
    );
    let knob_x = egui::lerp((rect.left() + 11.0)..=(rect.right() - 11.0), progress);
    painter.circle_filled(egui::pos2(knob_x, rect.center().y), 8.0, Color32::WHITE);

    let response = response.on_hover_cursor(CursorIcon::PointingHand);
    if response.clicked() {
        *on = !*on;
        ui.ctx().request_repaint();
        true
    } else {
        false
    }
}

fn launch_button(ui: &mut Ui, text: &str, enabled: bool) -> Response {
    let (rect, response) = ui.allocate_exact_size(Vec2::new(188.0, 44.0), Sense::click());
    let hovered = enabled && response.hovered();
    let pressed = enabled && response.is_pointer_button_down_on();
    let fill = if !enabled {
        theme::ACCENT_DISABLED
    } else if pressed {
        theme::ACCENT_PRESSED
    } else if hovered {
        theme::ACCENT_HOVER
    } else {
        theme::ACCENT
    };
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(9.0), fill);
    painter.rect_stroke(
        rect,
        Rounding::same(9.0),
        Stroke::new(1.0_f32, Color32::from_rgba_premultiplied(20, 20, 20, 20)),
    );
    painter.text(
        rect.center(),
        Align2::CENTER_CENTER,
        text,
        FontId::proportional(14.5),
        if enabled {
            theme::ON_ACCENT
        } else {
            Color32::from_rgb(159, 174, 235)
        },
    );
    if enabled {
        response.on_hover_cursor(CursorIcon::PointingHand)
    } else {
        response.on_hover_cursor(CursorIcon::NotAllowed)
    }
}

fn window_button(ui: &mut Ui, ctx: &egui::Context, button: WindowButton, maximized: bool) {
    let (rect, response) = ui.allocate_exact_size(Vec2::new(40.0, 30.0), Sense::click());
    let hovered = response.hovered();
    let pressed = response.is_pointer_button_down_on();
    let is_close = matches!(button, WindowButton::Close);
    let fill = if is_close && hovered {
        theme::DANGER_DEEP
    } else if pressed {
        theme::GHOST_PRESSED
    } else if hovered {
        theme::GHOST_HOVER
    } else {
        Color32::TRANSPARENT
    };
    let painter = ui.painter();
    if fill != Color32::TRANSPARENT {
        painter.rect_filled(rect, Rounding::same(6.0), fill);
    }
    let color = if is_close && hovered {
        Color32::WHITE
    } else if hovered {
        theme::TEXT
    } else {
        theme::MUTED
    };
    let center = rect.center();
    let stroke = Stroke::new(1.2_f32, color);

    match button {
        WindowButton::Minimize => {
            painter.line_segment(
                [
                    egui::pos2(center.x - 4.5, center.y + 2.0),
                    egui::pos2(center.x + 4.5, center.y + 2.0),
                ],
                stroke,
            );
        }
        WindowButton::Maximize => {
            if maximized {
                let back = Rect::from_min_size(
                    egui::pos2(center.x - 4.5, center.y - 4.5),
                    Vec2::splat(7.0),
                );
                let front = Rect::from_min_size(
                    egui::pos2(center.x - 1.5, center.y - 1.5),
                    Vec2::splat(7.0),
                );
                painter.rect_stroke(back, Rounding::same(1.0), stroke);
                painter.rect_stroke(front, Rounding::same(1.0), stroke);
            } else {
                let square = Rect::from_center_size(center, Vec2::splat(9.0));
                painter.rect_stroke(square, Rounding::same(1.5), stroke);
            }
        }
        WindowButton::Close => {
            painter.line_segment(
                [
                    egui::pos2(center.x - 4.5, center.y - 4.5),
                    egui::pos2(center.x + 4.5, center.y + 4.5),
                ],
                stroke,
            );
            painter.line_segment(
                [
                    egui::pos2(center.x - 4.5, center.y + 4.5),
                    egui::pos2(center.x + 4.5, center.y - 4.5),
                ],
                stroke,
            );
        }
    }

    let response = response.on_hover_cursor(CursorIcon::PointingHand);
    if response.clicked() {
        match button {
            WindowButton::Minimize => ctx.send_viewport_cmd(egui::ViewportCommand::Minimized(true)),
            WindowButton::Maximize => {
                ctx.send_viewport_cmd(egui::ViewportCommand::Maximized(!maximized))
            }
            WindowButton::Close => ctx.send_viewport_cmd(egui::ViewportCommand::Close),
        }
    }
}

fn resize_handles(ctx: &egui::Context) {
    if ctx.input(|input| input.viewport().maximized.unwrap_or(false)) {
        return;
    }

    let screen = ctx.screen_rect();
    let edge = 4.0;
    let corner = 10.0;
    let Some(pos) = ctx.input(|input| input.pointer.interact_pos()) else {
        return;
    };

    let left = pos.x <= screen.left() + edge;
    let right = pos.x >= screen.right() - edge;
    let top = pos.y <= screen.top() + edge;
    let bottom = pos.y >= screen.bottom() - edge;
    let near_left = pos.x <= screen.left() + corner;
    let near_right = pos.x >= screen.right() - corner;
    let near_top = pos.y <= screen.top() + corner;
    let near_bottom = pos.y >= screen.bottom() - corner;

    let target = if near_left && near_top {
        Some((
            egui::viewport::ResizeDirection::NorthWest,
            CursorIcon::ResizeNwSe,
        ))
    } else if near_right && near_top {
        Some((
            egui::viewport::ResizeDirection::NorthEast,
            CursorIcon::ResizeNeSw,
        ))
    } else if near_left && near_bottom {
        Some((
            egui::viewport::ResizeDirection::SouthWest,
            CursorIcon::ResizeNeSw,
        ))
    } else if near_right && near_bottom {
        Some((
            egui::viewport::ResizeDirection::SouthEast,
            CursorIcon::ResizeNwSe,
        ))
    } else if left {
        Some((
            egui::viewport::ResizeDirection::West,
            CursorIcon::ResizeHorizontal,
        ))
    } else if right {
        Some((
            egui::viewport::ResizeDirection::East,
            CursorIcon::ResizeHorizontal,
        ))
    } else if top {
        Some((
            egui::viewport::ResizeDirection::North,
            CursorIcon::ResizeVertical,
        ))
    } else if bottom {
        Some((
            egui::viewport::ResizeDirection::South,
            CursorIcon::ResizeVertical,
        ))
    } else {
        None
    };

    if let Some((direction, cursor)) = target {
        ctx.set_cursor_icon(cursor);
        if ctx.input(|input| input.pointer.primary_pressed()) {
            ctx.send_viewport_cmd(egui::ViewportCommand::BeginResize(direction));
        }
    }
}

fn text_width(ui: &Ui, text: &str, font: FontId) -> f32 {
    ui.fonts(|fonts| {
        fonts
            .layout_no_wrap(text.to_owned(), font, Color32::WHITE)
            .size()
            .x
    })
}

fn mix_color(from: Color32, to: Color32, t: f32) -> Color32 {
    let mix = |a: u8, b: u8| {
        (a as f32 + (b as f32 - a as f32) * t)
            .round()
            .clamp(0.0, 255.0) as u8
    };
    Color32::from_rgb(
        mix(from.r(), to.r()),
        mix(from.g(), to.g()),
        mix(from.b(), to.b()),
    )
}

fn path_status(ui: &mut Ui, ok: bool, ok_text: &str, bad_text: &str) {
    ui.horizontal(|ui| {
        theme::dot(ui, if ok { theme::SUCCESS } else { theme::DANGER }, 3.0);
        ui.label(
            RichText::new(if ok { ok_text } else { bad_text })
                .size(10.5)
                .color(if ok { theme::FAINT } else { theme::DANGER }),
        );
    });
}

fn info_row(ui: &mut Ui, label: &str, value: &str, ok: bool) {
    ui.horizontal(|ui| {
        ui.add_sized(
            [88.0, 20.0],
            egui::Label::new(RichText::new(label).size(11.5).color(theme::MUTED)),
        );
        theme::dot(ui, if ok { theme::SUCCESS } else { theme::DANGER }, 3.0);
        ui.label(RichText::new(value).size(11.5).color(theme::TEXT));
    });
    ui.add_space(5.0);
}

fn warning_banner(ui: &mut Ui, title: &str, detail: &str) {
    Frame::none()
        .fill(theme::DANGER_SOFT)
        .stroke(Stroke::new(1.0_f32, Color32::from_rgb(92, 47, 50)))
        .rounding(Rounding::same(9.0))
        .inner_margin(Margin::symmetric(13.0, 10.0))
        .show(ui, |ui| {
            ui.set_min_width(ui.available_width());
            ui.label(
                RichText::new(title)
                    .size(12.5)
                    .strong()
                    .color(theme::DANGER),
            );
            ui.label(RichText::new(detail).size(11.5).color(theme::MUTED));
        });
}

fn map_display(inventory: &Inventory, key: &str) -> String {
    inventory
        .map(key)
        .map(|map| map.id.clone())
        .unwrap_or_else(|| key.to_owned())
}

fn weapon_display(inventory: &Inventory, key: &str) -> String {
    inventory
        .weapon(key)
        .map(|weapon| weapon.display_name().to_owned())
        .unwrap_or_else(|| key.to_owned())
}

fn columns_for(width: f32, min_card_width: f32, spacing: f32) -> usize {
    (((width + spacing) / (min_card_width + spacing)).floor() as usize).max(1)
}

fn virtual_grid(
    ui: &mut Ui,
    id: &str,
    total: usize,
    columns: usize,
    card_height: f32,
    max_height: f32,
    mut card: impl FnMut(&mut Ui, usize),
) {
    let columns = columns.max(1);
    if total == 0 {
        return;
    }
    let row_height = card_height + ui.spacing().item_spacing.y;
    let rows = total.div_ceil(columns);
    ScrollArea::vertical()
        .id_salt(id)
        .auto_shrink([false, false])
        .max_height(max_height)
        .show_rows(ui, row_height, rows, |ui, row_range| {
            ui.set_width(ui.available_width());
            for row in row_range {
                ui.horizontal(|ui| {
                    for column in 0..columns {
                        let index = row * columns + column;
                        if index >= total {
                            break;
                        }
                        card(ui, index);
                    }
                });
            }
        });
}

fn elide(text: &str, max_chars: usize) -> String {
    if text.chars().count() <= max_chars {
        return text.to_owned();
    }
    let mut result: String = text.chars().take(max_chars.saturating_sub(1)).collect();
    result.push('…');
    result
}

fn avatar_initial(name: &str) -> String {
    name.chars()
        .find(|ch| ch.is_ascii_alphanumeric())
        .or_else(|| name.chars().next())
        .map(|ch| ch.to_ascii_uppercase().to_string())
        .unwrap_or_else(|| "?".to_owned())
}

fn hash_text(text: &str) -> u64 {
    let mut hash = 0xcbf2_9ce4_8422_2325_u64;
    for byte in text.as_bytes() {
        hash ^= *byte as u64;
        hash = hash.wrapping_mul(0x0000_0100_0000_01b3);
    }
    hash
}

#[derive(Clone, Copy)]
enum WarehouseAction { None, Equip, Unequip, Skin }

/// Original NewMall/NewStorageWeaponItem geometry: 224 x 103, art/name above y=78.
fn warehouse_weapon_card(ui: &mut Ui, preview: Option<&egui::TextureHandle>, frame: Option<&egui::TextureHandle>, background: Option<&egui::TextureHandle>,
    weapon: &Weapon, equipped: bool, bag: u8, width: f32) -> WarehouseAction {
    let scale = width / 224.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, 103.0 * scale), Sense::click());
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::ZERO, Color32::from_rgb(22, 33, 43));
    if let Some(frame) = frame {
        painter.image(frame.id(), rect, Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0)), Color32::WHITE);
    }
    painter.rect_stroke(rect, Rounding::ZERO, Stroke::new(if equipped { 1.5_f32 } else { 1.0_f32 },
        if equipped { Color32::from_rgb(78, 174, 224) } else { Color32::from_rgb(70, 85, 100) }));
    let point = |x: f32, y: f32| rect.min + Vec2::new(x * scale, y * scale);
    if let Some(background) = background {
        painter.image(background.id(), Rect::from_min_max(point(1.0, 1.0), point(223.0, 77.0)),
            Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0)), Color32::WHITE);
    }
    let art = Rect::from_min_max(point(8.0, 5.0), point(216.0, 56.0));
    if let Some(texture) = preview {
        paint_preview(painter, art, texture, if weapon.complete { Color32::WHITE } else { Color32::from_white_alpha(90) });
    } else {
        painter.text(art.center(), Align2::CENTER_CENTER, "大厅原图缺失", FontId::proportional(11.0 * scale), theme::MUTED);
    }
    painter.text(point(9.0, 64.0), Align2::LEFT_CENTER, elide(weapon.display_name(), 15),
        FontId::proportional(12.0 * scale), Color32::WHITE);
    painter.text(point(218.0, 64.0), Align2::RIGHT_CENTER, "永久", FontId::proportional(13.0 * scale), Color32::from_rgb(244, 219, 149));
    if equipped {
        painter.text(point(219.0, 8.0), Align2::RIGHT_TOP, format!("[背包{bag}]"), FontId::proportional(11.0 * scale), Color32::GREEN);
    }
    let footer = Rect::from_min_max(point(1.0, 78.0), point(223.0, 102.0));
    painter.rect_filled(footer, Rounding::ZERO, Color32::from_rgb(10, 19, 26));
    let skin_rect = Rect::from_min_max(point(130.0, 79.0), point(175.0, 100.0));
    let equip_rect = Rect::from_min_max(point(176.0, 79.0), point(222.0, 100.0));
    let skin_resp = ui.interact(skin_rect, response.id.with("skin"), Sense::click());
    let equip_resp = ui.interact(equip_rect, response.id.with("equip"), Sense::click());
    painter.text(skin_rect.center(), Align2::CENTER_CENTER, "皮肤", FontId::proportional(12.0 * scale), theme::INFO);
    painter.text(equip_rect.center(), Align2::CENTER_CENTER, if !weapon.complete { "缺资源" } else if equipped { "卸下" } else { "装备" },
        FontId::proportional(12.0 * scale), if weapon.complete { theme::INFO } else { theme::DANGER });
    painter.line_segment([point(175.0, 80.0), point(175.0, 98.0)], Stroke::new(1.0_f32, theme::LINE));
    let mut action = WarehouseAction::None;
    if weapon.complete {
        if skin_resp.clicked() { action = WarehouseAction::Skin; }
        else if equip_resp.clicked() { action = if equipped { WarehouseAction::Unequip } else { WarehouseAction::Equip }; }
        else if response.clicked() { action = WarehouseAction::Equip; }
    }
    response.on_hover_text(format!("{}\n{}", weapon.display_name(), weapon.key));
    action
}
