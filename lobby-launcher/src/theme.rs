use eframe::egui::{
    self, Align2, Color32, FontId, Frame, Margin, Response, RichText, Rounding, Sense, Stroke,
    TextStyle, Ui, Vec2,
};

// Palette adapted from OneLauncher: deep blue-grey surfaces, cool white type, brand blue.
pub const BG: Color32 = Color32::from_rgb(17, 23, 28);
pub const TOP: Color32 = Color32::from_rgb(21, 28, 34);
pub const SIDEBAR: Color32 = Color32::from_rgb(17, 23, 28);
pub const PANEL: Color32 = Color32::from_rgb(21, 28, 34);
pub const PANEL_SOFT: Color32 = Color32::from_rgb(16, 24, 31);
pub const CARD: Color32 = Color32::from_rgb(21, 28, 34);
pub const CARD_HOVER: Color32 = Color32::from_rgb(26, 34, 40);
pub const INPUT: Color32 = Color32::from_rgb(16, 24, 31);
pub const SEGMENT_ON: Color32 = Color32::from_rgb(34, 44, 53);
pub const LINE: Color32 = Color32::from_rgba_premultiplied(25, 25, 25, 25);
pub const LINE_SOFT: Color32 = Color32::from_rgba_premultiplied(12, 12, 12, 12);

pub const TEXT: Color32 = Color32::from_rgb(213, 219, 255);
pub const MUTED: Color32 = Color32::from_rgb(120, 129, 141);
pub const FAINT: Color32 = Color32::from_rgb(95, 104, 116);
pub const DISABLED: Color32 = Color32::from_rgb(75, 84, 96);

pub const ACCENT: Color32 = Color32::from_rgb(43, 75, 255);
pub const ACCENT_HOVER: Color32 = Color32::from_rgb(57, 87, 255);
pub const ACCENT_PRESSED: Color32 = Color32::from_rgb(40, 67, 221);
pub const ACCENT_DISABLED: Color32 = Color32::from_rgb(31, 47, 129);
pub const ACCENT_SOFT: Color32 = Color32::from_rgba_premultiplied(8, 14, 46, 46);
pub const ON_ACCENT: Color32 = Color32::from_rgb(240, 244, 255);

pub const GHOST: Color32 = Color32::from_rgba_premultiplied(12, 12, 12, 12);
pub const GHOST_HOVER: Color32 = Color32::from_rgba_premultiplied(26, 26, 26, 26);
pub const GHOST_PRESSED: Color32 = Color32::from_rgba_premultiplied(38, 38, 38, 38);

pub const SUCCESS: Color32 = Color32::from_rgb(63, 185, 127);
pub const SUCCESS_DEEP: Color32 = Color32::from_rgb(35, 154, 96);
pub const SUCCESS_SOFT: Color32 = Color32::from_rgba_premultiplied(5, 22, 14, 36);
pub const DANGER: Color32 = Color32::from_rgb(255, 84, 84);
pub const DANGER_DEEP: Color32 = Color32::from_rgb(214, 52, 52);
pub const DANGER_SOFT: Color32 = Color32::from_rgba_premultiplied(32, 9, 9, 32);
pub const INFO: Color32 = Color32::from_rgb(97, 175, 239);
pub const INFO_SOFT: Color32 = Color32::from_rgba_premultiplied(14, 25, 34, 36);

pub fn apply(ctx: &egui::Context) {
    let mut style = (*ctx.style()).clone();
    let mut visuals = egui::Visuals::dark();

    visuals.panel_fill = BG;
    visuals.window_fill = PANEL;
    visuals.faint_bg_color = CARD;
    visuals.extreme_bg_color = INPUT;
    visuals.code_bg_color = INPUT;
    visuals.override_text_color = Some(TEXT);
    visuals.hyperlink_color = Color32::from_rgb(110, 140, 255);
    visuals.selection.bg_fill = Color32::from_rgba_premultiplied(19, 32, 110, 110);
    visuals.selection.stroke = Stroke::new(1.0_f32, ACCENT);
    visuals.window_stroke = Stroke::new(1.0_f32, LINE);
    visuals.window_rounding = Rounding::same(10.0);
    visuals.menu_rounding = Rounding::same(8.0);
    visuals.widgets.noninteractive.bg_fill = PANEL;
    visuals.widgets.noninteractive.weak_bg_fill = PANEL;
    visuals.widgets.noninteractive.bg_stroke = Stroke::new(1.0_f32, LINE_SOFT);
    visuals.widgets.noninteractive.fg_stroke = Stroke::new(1.0_f32, TEXT);
    visuals.widgets.inactive.bg_fill = CARD;
    visuals.widgets.inactive.weak_bg_fill = CARD;
    visuals.widgets.inactive.bg_stroke = Stroke::new(1.0_f32, LINE_SOFT);
    visuals.widgets.inactive.fg_stroke = Stroke::new(1.0_f32, TEXT);
    visuals.widgets.inactive.rounding = Rounding::same(8.0);
    visuals.widgets.hovered.bg_fill = CARD_HOVER;
    visuals.widgets.hovered.weak_bg_fill = CARD_HOVER;
    visuals.widgets.hovered.bg_stroke = Stroke::new(1.0_f32, GHOST_HOVER);
    visuals.widgets.hovered.fg_stroke = Stroke::new(1.0_f32, TEXT);
    visuals.widgets.hovered.rounding = Rounding::same(8.0);
    visuals.widgets.active.bg_fill = SEGMENT_ON;
    visuals.widgets.active.weak_bg_fill = SEGMENT_ON;
    visuals.widgets.active.bg_stroke = Stroke::new(1.0_f32, GHOST_PRESSED);
    visuals.widgets.active.fg_stroke = Stroke::new(1.0_f32, TEXT);
    visuals.widgets.active.rounding = Rounding::same(8.0);
    visuals.widgets.open.bg_fill = CARD_HOVER;
    visuals.widgets.open.weak_bg_fill = CARD_HOVER;
    visuals.widgets.open.bg_stroke = Stroke::new(1.0_f32, GHOST_HOVER);
    visuals.window_shadow = egui::epaint::Shadow {
        offset: egui::vec2(0.0, 10.0),
        blur: 32.0,
        spread: 0.0,
        color: Color32::from_black_alpha(160),
    };
    visuals.popup_shadow = visuals.window_shadow;
    style.visuals = visuals;
    style.spacing.item_spacing = egui::vec2(10.0, 10.0);
    style.spacing.button_padding = egui::vec2(14.0, 7.0);
    style.spacing.interact_size.y = 32.0;
    style.spacing.slider_width = 170.0;
    style.spacing.scroll.bar_width = 7.0;
    style.spacing.scroll.floating = true;
    style.text_styles = [
        (TextStyle::Heading, FontId::proportional(26.0)),
        (TextStyle::Body, FontId::proportional(14.0)),
        (TextStyle::Button, FontId::proportional(14.0)),
        (TextStyle::Small, FontId::proportional(12.0)),
        (TextStyle::Monospace, FontId::monospace(12.5)),
    ]
    .into();

    ctx.set_style(style);
}

pub fn panel_frame(fill: Color32, margin: Margin) -> Frame {
    Frame::none().fill(fill).inner_margin(margin)
}

pub fn muted(text: impl Into<String>) -> RichText {
    RichText::new(text).size(12.5).color(MUTED)
}

pub fn page_title(ui: &mut Ui, title: &str, subtitle: &str) {
    ui.label(RichText::new(title).size(27.0).strong().color(TEXT));
    ui.add_space(3.0);
    ui.label(RichText::new(subtitle).size(12.5).color(MUTED));
}

pub fn section_label(ui: &mut Ui, text: &str) {
    ui.label(RichText::new(text).size(11.0).strong().color(FAINT));
}

pub fn pill(ui: &mut Ui, text: impl Into<String>, fg: Color32, bg: Color32) -> Response {
    let text = text.into();
    let font = FontId::proportional(11.0);
    let width = text_width(ui, &text, font.clone()) + 18.0;
    let (rect, response) = ui.allocate_exact_size(Vec2::new(width, 24.0), Sense::hover());
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(12.0), bg);
    painter.text(rect.center(), Align2::CENTER_CENTER, text, font, fg);
    response
}

pub fn chip(ui: &mut Ui, label: &str, value: &str) {
    let label_font = FontId::proportional(10.0);
    let value_font = FontId::proportional(11.5);
    let label_width = text_width(ui, label, label_font.clone());
    let value_width = text_width(ui, value, value_font.clone());
    let width = 9.0 + label_width + 5.0 + value_width + 9.0;
    let (rect, _) = ui.allocate_exact_size(Vec2::new(width, 22.0), Sense::hover());
    let painter = ui.painter();
    painter.rect_filled(rect, Rounding::same(7.0), GHOST);
    painter.rect_stroke(rect, Rounding::same(7.0), Stroke::new(1.0_f32, LINE_SOFT));
    painter.text(
        egui::pos2(rect.left() + 9.0, rect.center().y),
        Align2::LEFT_CENTER,
        label,
        label_font,
        FAINT,
    );
    painter.text(
        egui::pos2(rect.left() + 9.0 + label_width + 5.0, rect.center().y),
        Align2::LEFT_CENTER,
        value,
        value_font,
        TEXT,
    );
}

fn text_width(ui: &Ui, text: &str, font: FontId) -> f32 {
    ui.fonts(|fonts| {
        fonts
            .layout_no_wrap(text.to_owned(), font, Color32::WHITE)
            .size()
            .x
    })
}

pub fn hline(ui: &mut Ui) {
    ui.add_space(2.0);
    let width = ui.available_width();
    let (rect, _) = ui.allocate_exact_size(egui::vec2(width, 1.0), egui::Sense::hover());
    ui.painter().rect_filled(rect, Rounding::ZERO, LINE_SOFT);
    ui.add_space(2.0);
}

pub fn dot(ui: &mut Ui, color: Color32, radius: f32) {
    let (rect, _) =
        ui.allocate_exact_size(egui::vec2(radius * 2.0, radius * 2.0), egui::Sense::hover());
    ui.painter().circle_filled(rect.center(), radius, color);
}
