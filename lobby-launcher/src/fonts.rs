use std::env;
use std::fs;
use std::path::PathBuf;

use eframe::egui::{self, FontData, FontDefinitions, FontFamily};

const CANDIDATES: &[&str] = &["msyh.ttc", "msyhbd.ttc", "simhei.ttf", "simsun.ttc"];
const FONT_KEY: &str = "ssjj-cjk";

pub struct CjkFont {
    pub path: PathBuf,
    pub data: Vec<u8>,
}

impl CjkFont {
    pub fn file_name(&self) -> String {
        self.path
            .file_name()
            .map(|name| name.to_string_lossy().into_owned())
            .unwrap_or_else(|| self.path.display().to_string())
    }
}

pub fn load_system_font() -> Result<CjkFont, String> {
    let windows_dir = env::var_os("WINDIR")
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from(r"C:\Windows"));
    let fonts_dir = windows_dir.join("Fonts");
    let mut errors = Vec::new();

    for name in CANDIDATES {
        let path = fonts_dir.join(name);
        match fs::read(&path) {
            Ok(data) => return Ok(CjkFont { path, data }),
            Err(err) => errors.push(format!("{}: {err}", path.display())),
        }
    }

    Err(format!(
        "未找到可用的中文字体，尝试过：{}",
        errors.join("；")
    ))
}

pub fn install(ctx: &egui::Context, font: CjkFont) {
    let mut definitions = FontDefinitions::default();
    definitions
        .font_data
        .insert(FONT_KEY.to_owned(), FontData::from_owned(font.data));

    for family in [FontFamily::Proportional, FontFamily::Monospace] {
        definitions
            .families
            .entry(family)
            .or_default()
            .insert(0, FONT_KEY.to_owned());
    }

    ctx.set_fonts(definitions);
}
