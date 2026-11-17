#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod app;
mod fonts;
mod inventory;
mod launcher;
mod official_lobby;
mod official_preview;
mod preview_bridge;
mod profile;
mod server;
mod settings;
mod theme;

use std::env;
use anyhow::{Context, Result};
use eframe::egui;

use crate::app::LobbyApp;
use crate::inventory::Inventory;
use crate::settings::AppSettings;

fn main() -> Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.iter().any(|arg| arg == "--legacy") {
        return run_legacy_egui();
    }

    // The official AIR preloader and Lobby SWF provide the visible UI.
    // Rust is only the launcher/supervisor; the demo page is no longer the default.
    official_lobby::run()
}

fn run_legacy_egui() -> Result<()> {
    let inventory = Inventory::load_embedded().context("嵌入的资源清单损坏，请重新构建启动器")?;
    let loaded = AppSettings::load();
    let font_result = fonts::load_system_font();
    let font_name = font_result.as_ref().ok().map(|font| font.file_name());
    let font_error = font_result.as_ref().err().cloned();

    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_title("生死狙击 · 离线大厅 (Legacy)")
            .with_inner_size([1280.0, 800.0])
            .with_min_inner_size([1024.0, 660.0])
            .with_resizable(true)
            .with_decorations(false)
            .with_icon(app_icon()),
        renderer: eframe::Renderer::Glow,
        vsync: true,
        multisampling: 0,
        ..Default::default()
    };

    eframe::run_native(
        "生死狙击 · 离线大厅 (Legacy)",
        options,
        Box::new(move |cc| {
            theme::apply(&cc.egui_ctx);
            if let Ok(font) = font_result {
                fonts::install(&cc.egui_ctx, font);
            }
            Ok(Box::new(LobbyApp::new(
                inventory, loaded, font_name, font_error,
            )))
        }),
    )
    .map_err(|err| anyhow::anyhow!("创建大厅窗口失败：{err}"))
}

fn app_icon() -> egui::IconData {
    let bytes = include_bytes!("../assets/icon.png");
    match image::load_from_memory(bytes) {
        Ok(img) => {
            let rgba = img.to_rgba8();
            let (width, height) = rgba.dimensions();
            egui::IconData {
                rgba: rgba.into_raw(),
                width,
                height,
            }
        }
        Err(_) => egui::IconData {
            rgba: vec![0, 0, 0, 0],
            width: 1,
            height: 1,
        },
    }
}
