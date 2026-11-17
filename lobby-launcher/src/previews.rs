// 由 tools/extract_previews.py 生成，请勿手改。
pub fn bytes(kind: &str, key: &str) -> Option<&'static [u8]> {
    match (kind, key) {
        ("weapon", "92fs") => Some(include_bytes!("../assets/previews/weapons/92fs.png")),
        ("weapon", "92fs_gp") => Some(include_bytes!("../assets/previews/weapons/92fs_gp.png")),
        ("weapon", "aa12_hell_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/aa12_hell_dragon.png"
        )),
        ("weapon", "aa12_hell_dragon1") => Some(include_bytes!(
            "../assets/previews/weapons/aa12_hell_dragon1.png"
        )),
        ("weapon", "aa12_hell_dragon2") => Some(include_bytes!(
            "../assets/previews/weapons/aa12_hell_dragon2.png"
        )),
        ("weapon", "aa12_hero") => Some(include_bytes!("../assets/previews/weapons/aa12_hero.png")),
        ("weapon", "aa12_hero1") => {
            Some(include_bytes!("../assets/previews/weapons/aa12_hero1.png"))
        }
        ("weapon", "abyss_blade") => {
            Some(include_bytes!("../assets/previews/weapons/abyss_blade.png"))
        }
        ("weapon", "abyss_blade1") => Some(include_bytes!(
            "../assets/previews/weapons/abyss_blade1.png"
        )),
        ("weapon", "abyss_blade2") => Some(include_bytes!(
            "../assets/previews/weapons/abyss_blade2.png"
        )),
        ("weapon", "abyss_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/abyss_pistol.png"
        )),
        ("weapon", "acg_hand_of_zeuss") => Some(include_bytes!(
            "../assets/previews/weapons/acg_hand_of_zeuss.png"
        )),
        ("weapon", "acg_notdistinguish") => Some(include_bytes!(
            "../assets/previews/weapons/acg_notdistinguish.png"
        )),
        ("weapon", "acg_scar_legend") => Some(include_bytes!(
            "../assets/previews/weapons/acg_scar_legend.png"
        )),
        ("weapon", "actsword") => Some(include_bytes!("../assets/previews/weapons/actsword.png")),
        ("weapon", "ad16") => Some(include_bytes!("../assets/previews/weapons/ad16.png")),
        ("weapon", "ad16crazydevil") => Some(include_bytes!(
            "../assets/previews/weapons/ad16crazydevil.png"
        )),
        ("weapon", "ad16_demon") => {
            Some(include_bytes!("../assets/previews/weapons/ad16_demon.png"))
        }
        ("weapon", "af2011a") => Some(include_bytes!("../assets/previews/weapons/af2011a.png")),
        ("weapon", "af2011a1") => Some(include_bytes!("../assets/previews/weapons/af2011a1.png")),
        ("weapon", "af2011a2") => Some(include_bytes!("../assets/previews/weapons/af2011a2.png")),
        ("weapon", "ak12") => Some(include_bytes!("../assets/previews/weapons/ak12.png")),
        ("weapon", "ak12_phoenix") => Some(include_bytes!(
            "../assets/previews/weapons/ak12_phoenix.png"
        )),
        ("weapon", "ak12_wukong") => {
            Some(include_bytes!("../assets/previews/weapons/ak12_wukong.png"))
        }
        ("weapon", "ak47") => Some(include_bytes!("../assets/previews/weapons/ak47.png")),
        ("weapon", "ak47_a") => Some(include_bytes!("../assets/previews/weapons/ak47_a.png")),
        ("weapon", "ak47_assault") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_assault.png"
        )),
        ("weapon", "ak47_blue_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_blue_dragon.png"
        )),
        ("weapon", "ak47_c") => Some(include_bytes!("../assets/previews/weapons/ak47_c.png")),
        ("weapon", "ak47_domination") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_domination.png"
        )),
        ("weapon", "ak47_dragon") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_dragon.png"))
        }
        ("weapon", "ak47_esg") => Some(include_bytes!("../assets/previews/weapons/ak47_esg.png")),
        ("weapon", "ak47_eternity") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_eternity.png"
        )),
        ("weapon", "ak47_g") => Some(include_bytes!("../assets/previews/weapons/ak47_g.png")),
        ("weapon", "ak47_g1") => Some(include_bytes!("../assets/previews/weapons/ak47_g1.png")),
        ("weapon", "ak47_glory") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_glory.png"))
        }
        ("weapon", "ak47_hero") => Some(include_bytes!("../assets/previews/weapons/ak47_hero.png")),
        ("weapon", "ak47_hero1") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_hero1.png"))
        }
        ("weapon", "ak47_legend_ct") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_legend_ct.png"
        )),
        ("weapon", "ak47_legend_t") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_legend_t.png"
        )),
        ("weapon", "ak47_lego") => Some(include_bytes!("../assets/previews/weapons/ak47_lego.png")),
        ("weapon", "ak47_mars") => Some(include_bytes!("../assets/previews/weapons/ak47_mars.png")),
        ("weapon", "ak47_mars1") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_mars1.png"))
        }
        ("weapon", "ak47_mars2") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_mars2.png"))
        }
        ("weapon", "ak47_paratrooper") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_paratrooper.png"
        )),
        ("weapon", "ak47_quantum") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_quantum.png"
        )),
        ("weapon", "ak47_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_redflash.png"
        )),
        ("weapon", "ak47_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_redflash1.png"
        )),
        ("weapon", "ak47_rose") => Some(include_bytes!("../assets/previews/weapons/ak47_rose.png")),
        ("weapon", "ak47_spring") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_spring.png"))
        }
        ("weapon", "ak47_strike") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_strike.png"))
        }
        ("weapon", "ak47_symphony") => Some(include_bytes!(
            "../assets/previews/weapons/ak47_symphony.png"
        )),
        ("weapon", "ak47_test") => Some(include_bytes!("../assets/previews/weapons/ak47_test.png")),
        ("weapon", "ak47_ult") => Some(include_bytes!("../assets/previews/weapons/ak47_ult.png")),
        ("weapon", "ak47_unique") => {
            Some(include_bytes!("../assets/previews/weapons/ak47_unique.png"))
        }
        ("weapon", "ak47_y") => Some(include_bytes!("../assets/previews/weapons/ak47_y.png")),
        ("weapon", "ak47_yh") => Some(include_bytes!("../assets/previews/weapons/ak47_yh.png")),
        ("weapon", "ak47_zh") => Some(include_bytes!("../assets/previews/weapons/ak47_zh.png")),
        ("weapon", "ak47_zs") => Some(include_bytes!("../assets/previews/weapons/ak47_zs.png")),
        ("weapon", "ak47_zy") => Some(include_bytes!("../assets/previews/weapons/ak47_zy.png")),
        ("weapon", "ak74u") => Some(include_bytes!("../assets/previews/weapons/ak74u.png")),
        ("weapon", "ak74u1") => Some(include_bytes!("../assets/previews/weapons/ak74u1.png")),
        ("weapon", "ak74u2") => Some(include_bytes!("../assets/previews/weapons/ak74u2.png")),
        ("weapon", "ak_hero_alpha") => Some(include_bytes!(
            "../assets/previews/weapons/ak_hero_alpha.png"
        )),
        ("weapon", "ak_unburied") => {
            Some(include_bytes!("../assets/previews/weapons/ak_unburied.png"))
        }
        ("weapon", "an94") => Some(include_bytes!("../assets/previews/weapons/an94.png")),
        ("weapon", "an94_bone") => Some(include_bytes!("../assets/previews/weapons/an94_bone.png")),
        ("weapon", "an94_g") => Some(include_bytes!("../assets/previews/weapons/an94_g.png")),
        ("weapon", "an94_g1") => Some(include_bytes!("../assets/previews/weapons/an94_g1.png")),
        ("weapon", "an94_ma") => Some(include_bytes!("../assets/previews/weapons/an94_ma.png")),
        ("weapon", "angerfirescar") => Some(include_bytes!(
            "../assets/previews/weapons/angerfirescar.png"
        )),
        ("weapon", "angerfirescar1") => Some(include_bytes!(
            "../assets/previews/weapons/angerfirescar1.png"
        )),
        ("weapon", "ar15") => Some(include_bytes!("../assets/previews/weapons/ar15.png")),
        ("weapon", "ar15_bone") => Some(include_bytes!("../assets/previews/weapons/ar15_bone.png")),
        ("weapon", "ar15_gilding") => Some(include_bytes!(
            "../assets/previews/weapons/ar15_gilding.png"
        )),
        ("weapon", "ar15_rage") => Some(include_bytes!("../assets/previews/weapons/ar15_rage.png")),
        ("weapon", "ar15_s") => Some(include_bytes!("../assets/previews/weapons/ar15_s.png")),
        ("weapon", "ar15_ult") => Some(include_bytes!("../assets/previews/weapons/ar15_ult.png")),
        ("weapon", "ar15_xc") => Some(include_bytes!("../assets/previews/weapons/ar15_xc.png")),
        ("weapon", "arc_electric_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/arc_electric_shotgun.png"
        )),
        ("weapon", "arm_cannon_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/arm_cannon_machinegun.png"
        )),
        ("weapon", "asura_blade") => {
            Some(include_bytes!("../assets/previews/weapons/asura_blade.png"))
        }
        ("weapon", "aug") => Some(include_bytes!("../assets/previews/weapons/aug.png")),
        ("weapon", "auga3") => Some(include_bytes!("../assets/previews/weapons/auga3.png")),
        ("weapon", "aug_ult") => Some(include_bytes!("../assets/previews/weapons/aug_ult.png")),
        ("weapon", "awakening") => Some(include_bytes!("../assets/previews/weapons/awakening.png")),
        ("weapon", "awakening1") => {
            Some(include_bytes!("../assets/previews/weapons/awakening1.png"))
        }
        ("weapon", "awakening2") => {
            Some(include_bytes!("../assets/previews/weapons/awakening2.png"))
        }
        ("weapon", "awake_claw") => {
            Some(include_bytes!("../assets/previews/weapons/awake_claw.png"))
        }
        ("weapon", "awake_claw1") => {
            Some(include_bytes!("../assets/previews/weapons/awake_claw1.png"))
        }
        ("weapon", "awake_claw2") => {
            Some(include_bytes!("../assets/previews/weapons/awake_claw2.png"))
        }
        ("weapon", "awm_bilibili") => Some(include_bytes!(
            "../assets/previews/weapons/awm_bilibili.png"
        )),
        ("weapon", "awm_bone") => Some(include_bytes!("../assets/previews/weapons/awm_bone.png")),
        ("weapon", "awm_c") => Some(include_bytes!("../assets/previews/weapons/awm_c.png")),
        ("weapon", "awm_g") => Some(include_bytes!("../assets/previews/weapons/awm_g.png")),
        ("weapon", "awm_hero") => Some(include_bytes!("../assets/previews/weapons/awm_hero.png")),
        ("weapon", "awm_hero1") => Some(include_bytes!("../assets/previews/weapons/awm_hero1.png")),
        ("weapon", "awm_hero_lite") => Some(include_bytes!(
            "../assets/previews/weapons/awm_hero_lite.png"
        )),
        ("weapon", "awm_legend_ct") => Some(include_bytes!(
            "../assets/previews/weapons/awm_legend_ct.png"
        )),
        ("weapon", "awm_legend_t") => Some(include_bytes!(
            "../assets/previews/weapons/awm_legend_t.png"
        )),
        ("weapon", "awm_s") => Some(include_bytes!("../assets/previews/weapons/awm_s.png")),
        ("weapon", "awm_snow_wolf") => Some(include_bytes!(
            "../assets/previews/weapons/awm_snow_wolf.png"
        )),
        ("weapon", "awm_strike") => {
            Some(include_bytes!("../assets/previews/weapons/awm_strike.png"))
        }
        ("weapon", "awm_tlx") => Some(include_bytes!("../assets/previews/weapons/awm_tlx.png")),
        ("weapon", "awm_wolf") => Some(include_bytes!("../assets/previews/weapons/awm_wolf.png")),
        ("weapon", "awm_y") => Some(include_bytes!("../assets/previews/weapons/awm_y.png")),
        ("weapon", "awp") => Some(include_bytes!("../assets/previews/weapons/awp.png")),
        ("weapon", "awp_hell_snake") => Some(include_bytes!(
            "../assets/previews/weapons/awp_hell_snake.png"
        )),
        ("weapon", "awp_hell_snake1") => Some(include_bytes!(
            "../assets/previews/weapons/awp_hell_snake1.png"
        )),
        ("weapon", "awp_hell_snake2") => Some(include_bytes!(
            "../assets/previews/weapons/awp_hell_snake2.png"
        )),
        ("weapon", "awp_ult") => Some(include_bytes!("../assets/previews/weapons/awp_ult.png")),
        ("weapon", "axe") => Some(include_bytes!("../assets/previews/weapons/axe.png")),
        ("weapon", "axe_abyss") => Some(include_bytes!("../assets/previews/weapons/axe_abyss.png")),
        ("weapon", "axe_bone") => Some(include_bytes!("../assets/previews/weapons/axe_bone.png")),
        ("weapon", "axe_dawn") => Some(include_bytes!("../assets/previews/weapons/axe_dawn.png")),
        ("weapon", "axe_g") => Some(include_bytes!("../assets/previews/weapons/axe_g.png")),
        ("weapon", "b92_wolf") => Some(include_bytes!("../assets/previews/weapons/b92_wolf.png")),
        ("weapon", "baby_boxer") => {
            Some(include_bytes!("../assets/previews/weapons/baby_boxer.png"))
        }
        ("weapon", "baby_ram") => Some(include_bytes!("../assets/previews/weapons/baby_ram.png")),
        ("weapon", "banana_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/banana_pistol.png"
        )),
        ("weapon", "barrett_m107") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107.png"
        )),
        ("weapon", "barrett_m107_c") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107_c.png"
        )),
        ("weapon", "barrett_m107_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107_dragon.png"
        )),
        ("weapon", "barrett_m107_g") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107_g.png"
        )),
        ("weapon", "barrett_m107_glory") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107_glory.png"
        )),
        ("weapon", "barrett_m107_y") => Some(include_bytes!(
            "../assets/previews/weapons/barrett_m107_y.png"
        )),
        ("weapon", "bat") => Some(include_bytes!("../assets/previews/weapons/bat.png")),
        ("weapon", "bat_md") => Some(include_bytes!("../assets/previews/weapons/bat_md.png")),
        ("weapon", "bayonet_3") => Some(include_bytes!("../assets/previews/weapons/bayonet_3.png")),
        ("weapon", "bayonet_gilding") => Some(include_bytes!(
            "../assets/previews/weapons/bayonet_gilding.png"
        )),
        ("weapon", "beats_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/beats_rifle.png"))
        }
        ("weapon", "beer_bottle") => {
            Some(include_bytes!("../assets/previews/weapons/beer_bottle.png"))
        }
        ("weapon", "berserker_axe") => Some(include_bytes!(
            "../assets/previews/weapons/berserker_axe.png"
        )),
        ("weapon", "berserker_axe1") => Some(include_bytes!(
            "../assets/previews/weapons/berserker_axe1.png"
        )),
        ("weapon", "berserker_axe2") => Some(include_bytes!(
            "../assets/previews/weapons/berserker_axe2.png"
        )),
        ("weapon", "big_fish_sword") => Some(include_bytes!(
            "../assets/previews/weapons/big_fish_sword.png"
        )),
        ("weapon", "bizon") => Some(include_bytes!("../assets/previews/weapons/bizon.png")),
        ("weapon", "bizon_g") => Some(include_bytes!("../assets/previews/weapons/bizon_g.png")),
        ("weapon", "blacklightcrossbow") => Some(include_bytes!(
            "../assets/previews/weapons/blacklightcrossbow.png"
        )),
        ("weapon", "blacklightcrossbow1") => Some(include_bytes!(
            "../assets/previews/weapons/blacklightcrossbow1.png"
        )),
        ("weapon", "blacklightcrossbow2") => Some(include_bytes!(
            "../assets/previews/weapons/blacklightcrossbow2.png"
        )),
        ("weapon", "black_crow") => {
            Some(include_bytes!("../assets/previews/weapons/black_crow.png"))
        }
        ("weapon", "black_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/black_dagger.png"
        )),
        ("weapon", "black_dagger1") => Some(include_bytes!(
            "../assets/previews/weapons/black_dagger1.png"
        )),
        ("weapon", "black_dagger2") => Some(include_bytes!(
            "../assets/previews/weapons/black_dagger2.png"
        )),
        ("weapon", "black_hole_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/black_hole_grenade.png"
        )),
        ("weapon", "black_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/black_pistol.png"
        )),
        ("weapon", "black_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/black_pistol1.png"
        )),
        ("weapon", "black_pistol2") => Some(include_bytes!(
            "../assets/previews/weapons/black_pistol2.png"
        )),
        ("weapon", "black_saber") => {
            Some(include_bytes!("../assets/previews/weapons/black_saber.png"))
        }
        ("weapon", "bladeshield_g") => Some(include_bytes!(
            "../assets/previews/weapons/bladeshield_g.png"
        )),
        ("weapon", "bladeshield_hero") => Some(include_bytes!(
            "../assets/previews/weapons/bladeshield_hero.png"
        )),
        ("weapon", "bladeshield_hero1") => Some(include_bytes!(
            "../assets/previews/weapons/bladeshield_hero1.png"
        )),
        ("weapon", "blade_strike") => Some(include_bytes!(
            "../assets/previews/weapons/blade_strike.png"
        )),
        ("weapon", "blink_shadow") => Some(include_bytes!(
            "../assets/previews/weapons/blink_shadow.png"
        )),
        ("weapon", "block_battleship") => Some(include_bytes!(
            "../assets/previews/weapons/block_battleship.png"
        )),
        ("weapon", "block_candy_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/block_candy_pistol.png"
        )),
        ("weapon", "block_combined_cannon") => Some(include_bytes!(
            "../assets/previews/weapons/block_combined_cannon.png"
        )),
        ("weapon", "block_combined_flamethrower") => Some(include_bytes!(
            "../assets/previews/weapons/block_combined_flamethrower.png"
        )),
        ("weapon", "block_combined_jet") => Some(include_bytes!(
            "../assets/previews/weapons/block_combined_jet.png"
        )),
        ("weapon", "block_combined_jet_lite") => Some(include_bytes!(
            "../assets/previews/weapons/block_combined_jet_lite.png"
        )),
        ("weapon", "block_combined_rpg") => Some(include_bytes!(
            "../assets/previews/weapons/block_combined_rpg.png"
        )),
        ("weapon", "block_dragon_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/block_dragon_pistol.png"
        )),
        ("weapon", "block_little_cannon") => Some(include_bytes!(
            "../assets/previews/weapons/block_little_cannon.png"
        )),
        ("weapon", "block_short_bow") => Some(include_bytes!(
            "../assets/previews/weapons/block_short_bow.png"
        )),
        ("weapon", "block_umbrella") => Some(include_bytes!(
            "../assets/previews/weapons/block_umbrella.png"
        )),
        ("weapon", "blood_ar") => Some(include_bytes!("../assets/previews/weapons/blood_ar.png")),
        ("weapon", "blood_double_edge") => Some(include_bytes!(
            "../assets/previews/weapons/blood_double_edge.png"
        )),
        ("weapon", "blood_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/blood_grenade.png"
        )),
        ("weapon", "blood_knife") => {
            Some(include_bytes!("../assets/previews/weapons/blood_knife.png"))
        }
        ("weapon", "blood_m1887") => {
            Some(include_bytes!("../assets/previews/weapons/blood_m1887.png"))
        }
        ("weapon", "blood_m1932") => {
            Some(include_bytes!("../assets/previews/weapons/blood_m1932.png"))
        }
        ("weapon", "blood_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/blood_machinegun.png"
        )),
        ("weapon", "blood_mosin") => {
            Some(include_bytes!("../assets/previews/weapons/blood_mosin.png"))
        }
        ("weapon", "blood_shadow_sword") => Some(include_bytes!(
            "../assets/previews/weapons/blood_shadow_sword.png"
        )),
        ("weapon", "blunderbuss") => {
            Some(include_bytes!("../assets/previews/weapons/blunderbuss.png"))
        }
        ("weapon", "bone_wild_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/bone_wild_rifle.png"
        )),
        ("weapon", "book_of_doom") => Some(include_bytes!(
            "../assets/previews/weapons/book_of_doom.png"
        )),
        ("weapon", "book_of_doom1") => Some(include_bytes!(
            "../assets/previews/weapons/book_of_doom1.png"
        )),
        ("weapon", "book_of_doom2") => Some(include_bytes!(
            "../assets/previews/weapons/book_of_doom2.png"
        )),
        ("weapon", "botweapon") => Some(include_bytes!("../assets/previews/weapons/botweapon.png")),
        ("weapon", "bot_bomb") => Some(include_bytes!("../assets/previews/weapons/bot_bomb.png")),
        ("weapon", "bow") => Some(include_bytes!("../assets/previews/weapons/bow.png")),
        ("weapon", "bow_burn") => Some(include_bytes!("../assets/previews/weapons/bow_burn.png")),
        ("weapon", "bow_burn1") => Some(include_bytes!("../assets/previews/weapons/bow_burn1.png")),
        ("weapon", "bow_god") => Some(include_bytes!("../assets/previews/weapons/bow_god.png")),
        ("weapon", "bow_god1") => Some(include_bytes!("../assets/previews/weapons/bow_god1.png")),
        ("weapon", "brambles") => Some(include_bytes!("../assets/previews/weapons/brambles.png")),
        ("weapon", "brambles1") => Some(include_bytes!("../assets/previews/weapons/brambles1.png")),
        ("weapon", "bravebieber") => {
            Some(include_bytes!("../assets/previews/weapons/bravebieber.png"))
        }
        ("weapon", "brave_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/brave_dagger.png"
        )),
        ("weapon", "break_shotgun_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/break_shotgun_pistol.png"
        )),
        ("weapon", "break_star_machinegun_legend") => Some(include_bytes!(
            "../assets/previews/weapons/break_star_machinegun_legend.png"
        )),
        ("weapon", "break_star_machinegun_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/break_star_machinegun_legend1.png"
        )),
        ("weapon", "break_star_machinegun_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/break_star_machinegun_legend2.png"
        )),
        ("weapon", "brick_knife") => {
            Some(include_bytes!("../assets/previews/weapons/brick_knife.png"))
        }
        ("weapon", "brick_knife_gold") => Some(include_bytes!(
            "../assets/previews/weapons/brick_knife_gold.png"
        )),
        ("weapon", "broad_sword") => {
            Some(include_bytes!("../assets/previews/weapons/broad_sword.png"))
        }
        ("weapon", "brokenlight_knife") => Some(include_bytes!(
            "../assets/previews/weapons/brokenlight_knife.png"
        )),
        ("weapon", "brokenlight_knife1") => Some(include_bytes!(
            "../assets/previews/weapons/brokenlight_knife1.png"
        )),
        ("weapon", "brush_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/brush_dagger.png"
        )),
        ("weapon", "brush_dagger1") => Some(include_bytes!(
            "../assets/previews/weapons/brush_dagger1.png"
        )),
        ("weapon", "brush_dagger2") => Some(include_bytes!(
            "../assets/previews/weapons/brush_dagger2.png"
        )),
        ("weapon", "brush_dagger3") => Some(include_bytes!(
            "../assets/previews/weapons/brush_dagger3.png"
        )),
        ("weapon", "bubble_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/bubble_pistol.png"
        )),
        ("weapon", "burning_bombs") => Some(include_bytes!(
            "../assets/previews/weapons/burning_bombs.png"
        )),
        ("weapon", "burning_bombs_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/burning_bombs_dragon.png"
        )),
        ("weapon", "burning_bottle") => Some(include_bytes!(
            "../assets/previews/weapons/burning_bottle.png"
        )),
        ("weapon", "burning_bottle_ult") => Some(include_bytes!(
            "../assets/previews/weapons/burning_bottle_ult.png"
        )),
        ("weapon", "burning_firecracker") => Some(include_bytes!(
            "../assets/previews/weapons/burning_firecracker.png"
        )),
        ("weapon", "burning_smg") => {
            Some(include_bytes!("../assets/previews/weapons/burning_smg.png"))
        }
        ("weapon", "burster_nails") => Some(include_bytes!(
            "../assets/previews/weapons/burster_nails.png"
        )),
        ("weapon", "burst_assault") => Some(include_bytes!(
            "../assets/previews/weapons/burst_assault.png"
        )),
        ("weapon", "burst_assault1") => Some(include_bytes!(
            "../assets/previews/weapons/burst_assault1.png"
        )),
        ("weapon", "butterflywings_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/butterflywings_sniper.png"
        )),
        ("weapon", "butterfly_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/butterfly_grenade.png"
        )),
        ("weapon", "butterfly_knife") => Some(include_bytes!(
            "../assets/previews/weapons/butterfly_knife.png"
        )),
        ("weapon", "biogrenade") => {
            Some(include_bytes!("../assets/previews/weapons/biogrenade.png"))
        }
        ("weapon", "c4") => Some(include_bytes!("../assets/previews/weapons/c4.png")),
        ("weapon", "c4_claymore") => {
            Some(include_bytes!("../assets/previews/weapons/c4_claymore.png"))
        }
        ("weapon", "candy_deer_bow") => Some(include_bytes!(
            "../assets/previews/weapons/candy_deer_bow.png"
        )),
        ("weapon", "carrot_one") => {
            Some(include_bytes!("../assets/previews/weapons/carrot_one.png"))
        }
        ("weapon", "cat") => Some(include_bytes!("../assets/previews/weapons/cat.png")),
        ("weapon", "cat_claw") => Some(include_bytes!("../assets/previews/weapons/cat_claw.png")),
        ("weapon", "cavalry_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/cavalry_shotgun.png"
        )),
        ("weapon", "chansi") => Some(include_bytes!("../assets/previews/weapons/chansi.png")),
        ("weapon", "cheyTacM200") => {
            Some(include_bytes!("../assets/previews/weapons/cheyTacM200.png"))
        }
        ("weapon", "chicken") => Some(include_bytes!("../assets/previews/weapons/chicken.png")),
        ("weapon", "christmastree_gift") => Some(include_bytes!(
            "../assets/previews/weapons/christmastree_gift.png"
        )),
        ("weapon", "christmas_antler") => Some(include_bytes!(
            "../assets/previews/weapons/christmas_antler.png"
        )),
        ("weapon", "christmas_blade") => Some(include_bytes!(
            "../assets/previews/weapons/christmas_blade.png"
        )),
        ("weapon", "christmas_hat") => Some(include_bytes!(
            "../assets/previews/weapons/christmas_hat.png"
        )),
        ("weapon", "christmas_tree") => Some(include_bytes!(
            "../assets/previews/weapons/christmas_tree.png"
        )),
        ("weapon", "clarinet_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/clarinet_rifle.png"
        )),
        ("weapon", "claymore_tactical_180") => Some(include_bytes!(
            "../assets/previews/weapons/claymore_tactical_180.png"
        )),
        ("weapon", "claymore_tactical_360") => Some(include_bytes!(
            "../assets/previews/weapons/claymore_tactical_360.png"
        )),
        ("weapon", "cola_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/cola_grenade.png"
        )),
        ("weapon", "colossus_hammer") => Some(include_bytes!(
            "../assets/previews/weapons/colossus_hammer.png"
        )),
        ("weapon", "colt1873") => Some(include_bytes!("../assets/previews/weapons/colt1873.png")),
        ("weapon", "colt_boa") => Some(include_bytes!("../assets/previews/weapons/colt_boa.png")),
        ("weapon", "colt_boa_g") => {
            Some(include_bytes!("../assets/previews/weapons/colt_boa_g.png"))
        }
        ("weapon", "colt_bone") => Some(include_bytes!("../assets/previews/weapons/colt_bone.png")),
        ("weapon", "corbett") => Some(include_bytes!("../assets/previews/weapons/corbett.png")),
        ("weapon", "core_sniper") => {
            Some(include_bytes!("../assets/previews/weapons/core_sniper.png"))
        }
        ("weapon", "core_sniper1") => Some(include_bytes!(
            "../assets/previews/weapons/core_sniper1.png"
        )),
        ("weapon", "core_sniper2") => Some(include_bytes!(
            "../assets/previews/weapons/core_sniper2.png"
        )),
        ("weapon", "cow_gun_2021") => Some(include_bytes!(
            "../assets/previews/weapons/cow_gun_2021.png"
        )),
        ("weapon", "cozywinter_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/cozywinter_grenade.png"
        )),
        ("weapon", "cqtc_shadow") => {
            Some(include_bytes!("../assets/previews/weapons/cqtc_shadow.png"))
        }
        ("weapon", "cqtc_shadow1") => Some(include_bytes!(
            "../assets/previews/weapons/cqtc_shadow1.png"
        )),
        ("weapon", "cracker") => Some(include_bytes!("../assets/previews/weapons/cracker.png")),
        ("weapon", "crocodile_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/crocodile_pistol.png"
        )),
        ("weapon", "crossbow") => Some(include_bytes!("../assets/previews/weapons/crossbow.png")),
        ("weapon", "crossbow_black") => Some(include_bytes!(
            "../assets/previews/weapons/crossbow_black.png"
        )),
        ("weapon", "crossbow_black1") => Some(include_bytes!(
            "../assets/previews/weapons/crossbow_black1.png"
        )),
        ("weapon", "crossbow_black2") => Some(include_bytes!(
            "../assets/previews/weapons/crossbow_black2.png"
        )),
        ("weapon", "crossbow_g") => {
            Some(include_bytes!("../assets/previews/weapons/crossbow_g.png"))
        }
        ("weapon", "cross_nail_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/cross_nail_shotgun.png"
        )),
        ("weapon", "crowbar") => Some(include_bytes!("../assets/previews/weapons/crowbar.png")),
        ("weapon", "crystal_bow") => {
            Some(include_bytes!("../assets/previews/weapons/crystal_bow.png"))
        }
        ("weapon", "crystal_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/crystal_pistol.png"
        )),
        ("weapon", "crystal_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/crystal_pistol1.png"
        )),
        ("weapon", "crystal_pistol2") => Some(include_bytes!(
            "../assets/previews/weapons/crystal_pistol2.png"
        )),
        ("weapon", "crystal_spear") => Some(include_bytes!(
            "../assets/previews/weapons/crystal_spear.png"
        )),
        ("weapon", "cslr4") => Some(include_bytes!("../assets/previews/weapons/cslr4.png")),
        ("weapon", "ct_knight1_2") => Some(include_bytes!(
            "../assets/previews/weapons/ct_knight1_2.png"
        )),
        ("weapon", "cupid_bear") => {
            Some(include_bytes!("../assets/previews/weapons/cupid_bear.png"))
        }
        ("weapon", "custom_weapon") => Some(include_bytes!(
            "../assets/previews/weapons/custom_weapon.png"
        )),
        ("weapon", "cuttlefish_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/cuttlefish_grenade.png"
        )),
        ("weapon", "cybertron_beast") => Some(include_bytes!(
            "../assets/previews/weapons/cybertron_beast.png"
        )),
        ("weapon", "cyber_punk_sword") => Some(include_bytes!(
            "../assets/previews/weapons/cyber_punk_sword.png"
        )),
        ("weapon", "cz75") => Some(include_bytes!("../assets/previews/weapons/cz75.png")),
        ("weapon", "cz75_abyss") => {
            Some(include_bytes!("../assets/previews/weapons/cz75_abyss.png"))
        }
        ("weapon", "cz75_firework") => Some(include_bytes!(
            "../assets/previews/weapons/cz75_firework.png"
        )),
        ("weapon", "cz75_g") => Some(include_bytes!("../assets/previews/weapons/cz75_g.png")),
        ("weapon", "candy_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/candy_grenade.png"
        )),
        ("weapon", "dagger") => Some(include_bytes!("../assets/previews/weapons/dagger.png")),
        ("weapon", "dagger_1") => Some(include_bytes!("../assets/previews/weapons/dagger_1.png")),
        ("weapon", "dagger_2") => Some(include_bytes!("../assets/previews/weapons/dagger_2.png")),
        ("weapon", "dagger_3") => Some(include_bytes!("../assets/previews/weapons/dagger_3.png")),
        ("weapon", "dagger_4") => Some(include_bytes!("../assets/previews/weapons/dagger_4.png")),
        ("weapon", "dagger_5") => Some(include_bytes!("../assets/previews/weapons/dagger_5.png")),
        ("weapon", "dagger_bullet_burster") => Some(include_bytes!(
            "../assets/previews/weapons/dagger_bullet_burster.png"
        )),
        ("weapon", "dagger_bullet_burster1") => Some(include_bytes!(
            "../assets/previews/weapons/dagger_bullet_burster1.png"
        )),
        ("weapon", "dagger_bullet_burster2") => Some(include_bytes!(
            "../assets/previews/weapons/dagger_bullet_burster2.png"
        )),
        ("weapon", "dagger_ult") => {
            Some(include_bytes!("../assets/previews/weapons/dagger_ult.png"))
        }
        ("weapon", "darkdiamond") => {
            Some(include_bytes!("../assets/previews/weapons/darkdiamond.png"))
        }
        ("weapon", "darkdiamond1") => Some(include_bytes!(
            "../assets/previews/weapons/darkdiamond1.png"
        )),
        ("weapon", "darkdiamond2") => Some(include_bytes!(
            "../assets/previews/weapons/darkdiamond2.png"
        )),
        ("weapon", "darkfire_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/darkfire_rifle.png"
        )),
        ("weapon", "darts_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/darts_redflash.png"
        )),
        ("weapon", "darts_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/darts_redflash1.png"
        )),
        ("weapon", "dash_shield") => {
            Some(include_bytes!("../assets/previews/weapons/dash_shield.png"))
        }
        ("weapon", "data_cube") => Some(include_bytes!("../assets/previews/weapons/data_cube.png")),
        ("weapon", "data_cube1") => {
            Some(include_bytes!("../assets/previews/weapons/data_cube1.png"))
        }
        ("weapon", "data_cube2") => {
            Some(include_bytes!("../assets/previews/weapons/data_cube2.png"))
        }
        ("weapon", "dawn_light_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/dawn_light_shotgun.png"
        )),
        ("weapon", "dawn_light_shotgun1") => Some(include_bytes!(
            "../assets/previews/weapons/dawn_light_shotgun1.png"
        )),
        ("weapon", "dawn_light_shotgun2") => Some(include_bytes!(
            "../assets/previews/weapons/dawn_light_shotgun2.png"
        )),
        ("weapon", "deagle") => Some(include_bytes!("../assets/previews/weapons/deagle.png")),
        ("weapon", "deagle_a") => Some(include_bytes!("../assets/previews/weapons/deagle_a.png")),
        ("weapon", "deagle_assault") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_assault.png"
        )),
        ("weapon", "deagle_c") => Some(include_bytes!("../assets/previews/weapons/deagle_c.png")),
        ("weapon", "deagle_dawn") => {
            Some(include_bytes!("../assets/previews/weapons/deagle_dawn.png"))
        }
        ("weapon", "deagle_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_dragon.png"
        )),
        ("weapon", "deagle_g") => Some(include_bytes!("../assets/previews/weapons/deagle_g.png")),
        ("weapon", "deagle_glory") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_glory.png"
        )),
        ("weapon", "deagle_glory_beta") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_glory_beta.png"
        )),
        ("weapon", "deagle_hunter") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_hunter.png"
        )),
        ("weapon", "deagle_i") => Some(include_bytes!("../assets/previews/weapons/deagle_i.png")),
        ("weapon", "deagle_lego") => {
            Some(include_bytes!("../assets/previews/weapons/deagle_lego.png"))
        }
        ("weapon", "deagle_pulse") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_pulse.png"
        )),
        ("weapon", "deagle_pulse1") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_pulse1.png"
        )),
        ("weapon", "deagle_pulse2") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_pulse2.png"
        )),
        ("weapon", "deagle_special") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_special.png"
        )),
        ("weapon", "deagle_strike") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_strike.png"
        )),
        ("weapon", "deagle_uc") => Some(include_bytes!("../assets/previews/weapons/deagle_uc.png")),
        ("weapon", "deagle_ult") => {
            Some(include_bytes!("../assets/previews/weapons/deagle_ult.png"))
        }
        ("weapon", "deagle_warrior") => Some(include_bytes!(
            "../assets/previews/weapons/deagle_warrior.png"
        )),
        ("weapon", "deagle_y") => Some(include_bytes!("../assets/previews/weapons/deagle_y.png")),
        ("weapon", "death") => Some(include_bytes!("../assets/previews/weapons/death.png")),
        ("weapon", "death_ray") => Some(include_bytes!("../assets/previews/weapons/death_ray.png")),
        ("weapon", "death_xingtian") => Some(include_bytes!(
            "../assets/previews/weapons/death_xingtian.png"
        )),
        ("weapon", "demon_hunter_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/demon_hunter_grenade.png"
        )),
        ("weapon", "demon_hunter_revolver") => Some(include_bytes!(
            "../assets/previews/weapons/demon_hunter_revolver.png"
        )),
        ("weapon", "demon_hunter_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/demon_hunter_shotgun.png"
        )),
        ("weapon", "demon_hunter_sword") => Some(include_bytes!(
            "../assets/previews/weapons/demon_hunter_sword.png"
        )),
        ("weapon", "destroy_lmg") => {
            Some(include_bytes!("../assets/previews/weapons/destroy_lmg.png"))
        }
        ("weapon", "detective_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/detective_grenade.png"
        )),
        ("weapon", "devil_eye") => Some(include_bytes!("../assets/previews/weapons/devil_eye.png")),
        ("weapon", "dipper_sg") => Some(include_bytes!("../assets/previews/weapons/dipper_sg.png")),
        ("weapon", "doki_pistol") => {
            Some(include_bytes!("../assets/previews/weapons/doki_pistol.png"))
        }
        ("weapon", "double_baton") => Some(include_bytes!(
            "../assets/previews/weapons/double_baton.png"
        )),
        ("weapon", "double_bayonet") => Some(include_bytes!(
            "../assets/previews/weapons/double_bayonet.png"
        )),
        ("weapon", "double_blade") => Some(include_bytes!(
            "../assets/previews/weapons/double_blade.png"
        )),
        ("weapon", "double_deagle") => Some(include_bytes!(
            "../assets/previews/weapons/double_deagle.png"
        )),
        ("weapon", "double_deagle_dark") => Some(include_bytes!(
            "../assets/previews/weapons/double_deagle_dark.png"
        )),
        ("weapon", "double_deagle_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_deagle_g.png"
        )),
        ("weapon", "double_fangs") => Some(include_bytes!(
            "../assets/previews/weapons/double_fangs.png"
        )),
        ("weapon", "double_fangs_dark") => Some(include_bytes!(
            "../assets/previews/weapons/double_fangs_dark.png"
        )),
        ("weapon", "double_fangs_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_fangs_g.png"
        )),
        ("weapon", "double_fmg") => {
            Some(include_bytes!("../assets/previews/weapons/double_fmg.png"))
        }
        ("weapon", "double_fmg_dark") => Some(include_bytes!(
            "../assets/previews/weapons/double_fmg_dark.png"
        )),
        ("weapon", "double_fmg_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_fmg_g.png"
        )),
        ("weapon", "double_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/double_grenade.png"
        )),
        ("weapon", "double_infinity") => Some(include_bytes!(
            "../assets/previews/weapons/double_infinity.png"
        )),
        ("weapon", "double_infinity_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_infinity_g.png"
        )),
        ("weapon", "double_maul") => {
            Some(include_bytes!("../assets/previews/weapons/double_maul.png"))
        }
        ("weapon", "double_maul_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_maul_g.png"
        )),
        ("weapon", "double_mg3_gun") => Some(include_bytes!(
            "../assets/previews/weapons/double_mg3_gun.png"
        )),
        ("weapon", "double_scythe") => Some(include_bytes!(
            "../assets/previews/weapons/double_scythe.png"
        )),
        ("weapon", "double_scythe_hell") => Some(include_bytes!(
            "../assets/previews/weapons/double_scythe_hell.png"
        )),
        ("weapon", "double_scythe_hell1") => Some(include_bytes!(
            "../assets/previews/weapons/double_scythe_hell1.png"
        )),
        ("weapon", "double_steel_bayonet") => Some(include_bytes!(
            "../assets/previews/weapons/double_steel_bayonet.png"
        )),
        ("weapon", "double_uzi") => {
            Some(include_bytes!("../assets/previews/weapons/double_uzi.png"))
        }
        ("weapon", "double_uzi_g") => Some(include_bytes!(
            "../assets/previews/weapons/double_uzi_g.png"
        )),
        ("weapon", "double_uzi_rage") => Some(include_bytes!(
            "../assets/previews/weapons/double_uzi_rage.png"
        )),
        ("weapon", "doun") => Some(include_bytes!("../assets/previews/weapons/doun.png")),
        ("weapon", "doun_master") => {
            Some(include_bytes!("../assets/previews/weapons/doun_master.png"))
        }
        ("weapon", "doun_yecha") => {
            Some(include_bytes!("../assets/previews/weapons/doun_yecha.png"))
        }
        ("weapon", "dou_tmp_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/dou_tmp_pistol.png"
        )),
        ("weapon", "dp_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/dp_machinegun.png"
        )),
        ("weapon", "dp_machinegun1") => Some(include_bytes!(
            "../assets/previews/weapons/dp_machinegun1.png"
        )),
        ("weapon", "dp_machinegun2") => Some(include_bytes!(
            "../assets/previews/weapons/dp_machinegun2.png"
        )),
        ("weapon", "dragonknight2021") => Some(include_bytes!(
            "../assets/previews/weapons/dragonknight2021.png"
        )),
        ("weapon", "dragon_aura") => {
            Some(include_bytes!("../assets/previews/weapons/dragon_aura.png"))
        }
        ("weapon", "dragon_aura1") => Some(include_bytes!(
            "../assets/previews/weapons/dragon_aura1.png"
        )),
        ("weapon", "dragon_aura2") => Some(include_bytes!(
            "../assets/previews/weapons/dragon_aura2.png"
        )),
        ("weapon", "dragon_boat_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/dragon_boat_pistol.png"
        )),
        ("weapon", "dragon_stick") => Some(include_bytes!(
            "../assets/previews/weapons/dragon_stick.png"
        )),
        ("weapon", "dream_ar") => Some(include_bytes!("../assets/previews/weapons/dream_ar.png")),
        ("weapon", "drill_blade") => {
            Some(include_bytes!("../assets/previews/weapons/drill_blade.png"))
        }
        ("weapon", "drum_knife") => {
            Some(include_bytes!("../assets/previews/weapons/drum_knife.png"))
        }
        ("weapon", "drum_paila") => {
            Some(include_bytes!("../assets/previews/weapons/drum_paila.png"))
        }
        ("weapon", "dsr_1") => Some(include_bytes!("../assets/previews/weapons/dsr_1.png")),
        ("weapon", "dsr_rage") => Some(include_bytes!("../assets/previews/weapons/dsr_rage.png")),
        ("weapon", "dsr_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/dsr_redflash.png"
        )),
        ("weapon", "dsr_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/dsr_redflash1.png"
        )),
        ("weapon", "dusk_pistol") => {
            Some(include_bytes!("../assets/previews/weapons/dusk_pistol.png"))
        }
        ("weapon", "dusk_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/dusk_pistol1.png"
        )),
        ("weapon", "dusk_pistol2") => Some(include_bytes!(
            "../assets/previews/weapons/dusk_pistol2.png"
        )),
        ("weapon", "dust_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/dust_rifle.png"))
        }
        ("weapon", "dust_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/dust_shotgun.png"
        )),
        ("weapon", "earl_shield") => {
            Some(include_bytes!("../assets/previews/weapons/earl_shield.png"))
        }
        ("weapon", "electricity_smg") => Some(include_bytes!(
            "../assets/previews/weapons/electricity_smg.png"
        )),
        ("weapon", "electric_element") => Some(include_bytes!(
            "../assets/previews/weapons/electric_element.png"
        )),
        ("weapon", "electric_element1") => Some(include_bytes!(
            "../assets/previews/weapons/electric_element1.png"
        )),
        ("weapon", "electric_element2") => Some(include_bytes!(
            "../assets/previews/weapons/electric_element2.png"
        )),
        ("weapon", "electric_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/electric_grenade.png"
        )),
        ("weapon", "electric_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/electric_grenade1.png"
        )),
        ("weapon", "electric_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/electric_grenade2.png"
        )),
        ("weapon", "electric_laser_sword") => Some(include_bytes!(
            "../assets/previews/weapons/electric_laser_sword.png"
        )),
        ("weapon", "electric_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/electric_pistol.png"
        )),
        ("weapon", "electric_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/electric_rifle.png"
        )),
        ("weapon", "electric_rifle1") => Some(include_bytes!(
            "../assets/previews/weapons/electric_rifle1.png"
        )),
        ("weapon", "electric_rifle2") => Some(include_bytes!(
            "../assets/previews/weapons/electric_rifle2.png"
        )),
        ("weapon", "eleven_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/eleven_pistol.png"
        )),
        ("weapon", "endless_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/endless_machinegun.png"
        )),
        ("weapon", "end_bow") => Some(include_bytes!("../assets/previews/weapons/end_bow.png")),
        ("weapon", "esg_2019") => Some(include_bytes!("../assets/previews/weapons/esg_2019.png")),
        ("weapon", "ether_double_edge") => Some(include_bytes!(
            "../assets/previews/weapons/ether_double_edge.png"
        )),
        ("weapon", "evil_sword") => {
            Some(include_bytes!("../assets/previews/weapons/evil_sword.png"))
        }
        ("weapon", "evo3a1") => Some(include_bytes!("../assets/previews/weapons/evo3a1.png")),
        ("weapon", "evo3a1_1") => Some(include_bytes!("../assets/previews/weapons/evo3a1_1.png")),
        ("weapon", "evo3a1_2") => Some(include_bytes!("../assets/previews/weapons/evo3a1_2.png")),
        ("weapon", "fal") => Some(include_bytes!("../assets/previews/weapons/fal.png")),
        ("weapon", "famas") => Some(include_bytes!("../assets/previews/weapons/famas.png")),
        ("weapon", "famas_r") => Some(include_bytes!("../assets/previews/weapons/famas_r.png")),
        ("weapon", "famas_y") => Some(include_bytes!("../assets/previews/weapons/famas_y.png")),
        ("weapon", "fanatical_tempo_fmg") => Some(include_bytes!(
            "../assets/previews/weapons/fanatical_tempo_fmg.png"
        )),
        ("weapon", "fantian_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/fantian_grenade.png"
        )),
        ("weapon", "fantian_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/fantian_grenade1.png"
        )),
        ("weapon", "fantian_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/fantian_grenade2.png"
        )),
        ("weapon", "fantian_grenade3") => Some(include_bytes!(
            "../assets/previews/weapons/fantian_grenade3.png"
        )),
        ("weapon", "fan_legend") => {
            Some(include_bytes!("../assets/previews/weapons/fan_legend.png"))
        }
        ("weapon", "fan_legend1") => {
            Some(include_bytes!("../assets/previews/weapons/fan_legend1.png"))
        }
        ("weapon", "fan_legend2") => {
            Some(include_bytes!("../assets/previews/weapons/fan_legend2.png"))
        }
        ("weapon", "fate_flashbang") => Some(include_bytes!(
            "../assets/previews/weapons/fate_flashbang.png"
        )),
        ("weapon", "fate_flashbang1") => Some(include_bytes!(
            "../assets/previews/weapons/fate_flashbang1.png"
        )),
        ("weapon", "fate_flashbang2") => Some(include_bytes!(
            "../assets/previews/weapons/fate_flashbang2.png"
        )),
        ("weapon", "fear_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/fear_grenade.png"
        )),
        ("weapon", "feather_bow") => {
            Some(include_bytes!("../assets/previews/weapons/feather_bow.png"))
        }
        ("weapon", "feather_fan") => {
            Some(include_bytes!("../assets/previews/weapons/feather_fan.png"))
        }
        ("weapon", "feishu") => Some(include_bytes!("../assets/previews/weapons/feishu.png")),
        ("weapon", "firecracker") => {
            Some(include_bytes!("../assets/previews/weapons/firecracker.png"))
        }
        ("weapon", "firegod_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/firegod_rifle.png"
        )),
        ("weapon", "fireofjustice") => Some(include_bytes!(
            "../assets/previews/weapons/fireofjustice.png"
        )),
        ("weapon", "fireofjustice1") => Some(include_bytes!(
            "../assets/previews/weapons/fireofjustice1.png"
        )),
        ("weapon", "fireofjustice2") => Some(include_bytes!(
            "../assets/previews/weapons/fireofjustice2.png"
        )),
        ("weapon", "fire_demon_rpg") => Some(include_bytes!(
            "../assets/previews/weapons/fire_demon_rpg.png"
        )),
        ("weapon", "fire_demon_rpg1") => Some(include_bytes!(
            "../assets/previews/weapons/fire_demon_rpg1.png"
        )),
        ("weapon", "fire_demon_rpg2") => Some(include_bytes!(
            "../assets/previews/weapons/fire_demon_rpg2.png"
        )),
        ("weapon", "fish_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/fish_shotgun.png"
        )),
        ("weapon", "fish_sword") => {
            Some(include_bytes!("../assets/previews/weapons/fish_sword.png"))
        }
        ("weapon", "fissure_traveller_submachinegun") => Some(include_bytes!(
            "../assets/previews/weapons/fissure_traveller_submachinegun.png"
        )),
        ("weapon", "fist") => Some(include_bytes!("../assets/previews/weapons/fist.png")),
        ("weapon", "flashgrenade_ult") => Some(include_bytes!(
            "../assets/previews/weapons/flashgrenade_ult.png"
        )),
        ("weapon", "flash_arm") => Some(include_bytes!("../assets/previews/weapons/flash_arm.png")),
        ("weapon", "flash_arm1") => {
            Some(include_bytes!("../assets/previews/weapons/flash_arm1.png"))
        }
        ("weapon", "flash_arm2") => {
            Some(include_bytes!("../assets/previews/weapons/flash_arm2.png"))
        }
        ("weapon", "flash_pro") => Some(include_bytes!("../assets/previews/weapons/flash_pro.png")),
        ("weapon", "floating_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/floating_sniper.png"
        )),
        ("weapon", "flying_shuttle") => Some(include_bytes!(
            "../assets/previews/weapons/flying_shuttle.png"
        )),
        ("weapon", "flying_shuttle1") => Some(include_bytes!(
            "../assets/previews/weapons/flying_shuttle1.png"
        )),
        ("weapon", "flying_shuttle2") => Some(include_bytes!(
            "../assets/previews/weapons/flying_shuttle2.png"
        )),
        ("weapon", "fn2000") => Some(include_bytes!("../assets/previews/weapons/fn2000.png")),
        ("weapon", "fn2000tactic") => Some(include_bytes!(
            "../assets/previews/weapons/fn2000tactic.png"
        )),
        ("weapon", "fn2000tactic1") => Some(include_bytes!(
            "../assets/previews/weapons/fn2000tactic1.png"
        )),
        ("weapon", "fn2000tactic2") => Some(include_bytes!(
            "../assets/previews/weapons/fn2000tactic2.png"
        )),
        ("weapon", "frozen_rifle_95") => Some(include_bytes!(
            "../assets/previews/weapons/frozen_rifle_95.png"
        )),
        ("weapon", "flashgrenade") => Some(include_bytes!(
            "../assets/previews/weapons/flashgrenade.png"
        )),
        ("weapon", "g11_dg") => Some(include_bytes!("../assets/previews/weapons/g11_dg.png")),
        ("weapon", "g18_metal_storm") => Some(include_bytes!(
            "../assets/previews/weapons/g18_metal_storm.png"
        )),
        ("weapon", "g18_metal_storm1") => Some(include_bytes!(
            "../assets/previews/weapons/g18_metal_storm1.png"
        )),
        ("weapon", "g18_metal_storm2") => Some(include_bytes!(
            "../assets/previews/weapons/g18_metal_storm2.png"
        )),
        ("weapon", "g18_unique") => {
            Some(include_bytes!("../assets/previews/weapons/g18_unique.png"))
        }
        ("weapon", "g36c_tactic") => {
            Some(include_bytes!("../assets/previews/weapons/g36c_tactic.png"))
        }
        ("weapon", "g36c_tactic1") => Some(include_bytes!(
            "../assets/previews/weapons/g36c_tactic1.png"
        )),
        ("weapon", "g36c_tactic2") => Some(include_bytes!(
            "../assets/previews/weapons/g36c_tactic2.png"
        )),
        ("weapon", "g3sg1") => Some(include_bytes!("../assets/previews/weapons/g3sg1.png")),
        ("weapon", "g3sg1_1") => Some(include_bytes!("../assets/previews/weapons/g3sg1_1.png")),
        ("weapon", "g3sg1_2") => Some(include_bytes!("../assets/previews/weapons/g3sg1_2.png")),
        ("weapon", "gaia_sniper") => {
            Some(include_bytes!("../assets/previews/weapons/gaia_sniper.png"))
        }
        ("weapon", "galil") => Some(include_bytes!("../assets/previews/weapons/galil.png")),
        ("weapon", "ganjiang") => Some(include_bytes!("../assets/previews/weapons/ganjiang.png")),
        ("weapon", "ganjiang_g") => {
            Some(include_bytes!("../assets/previews/weapons/ganjiang_g.png"))
        }
        ("weapon", "ganjiang_moye_g") => Some(include_bytes!(
            "../assets/previews/weapons/ganjiang_moye_g.png"
        )),
        ("weapon", "gatling") => Some(include_bytes!("../assets/previews/weapons/gatling.png")),
        ("weapon", "gatling_abyss") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_abyss.png"
        )),
        ("weapon", "gatling_abyss_horror") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_abyss_horror.png"
        )),
        ("weapon", "gatling_dou_rage") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_dou_rage.png"
        )),
        ("weapon", "gatling_dou_rage1") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_dou_rage1.png"
        )),
        ("weapon", "gatling_dou_rage2") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_dou_rage2.png"
        )),
        ("weapon", "gatling_dou_rage_overload") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_dou_rage_overload.png"
        )),
        ("weapon", "gatling_g") => Some(include_bytes!("../assets/previews/weapons/gatling_g.png")),
        ("weapon", "gatling_xmas") => Some(include_bytes!(
            "../assets/previews/weapons/gatling_xmas.png"
        )),
        ("weapon", "gatling_y") => Some(include_bytes!("../assets/previews/weapons/gatling_y.png")),
        ("weapon", "gear_mouse") => {
            Some(include_bytes!("../assets/previews/weapons/gear_mouse.png"))
        }
        ("weapon", "gemini_blade") => Some(include_bytes!(
            "../assets/previews/weapons/gemini_blade.png"
        )),
        ("weapon", "ghost_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/ghost_grenade.png"
        )),
        ("weapon", "ghost_rider") => {
            Some(include_bytes!("../assets/previews/weapons/ghost_rider.png"))
        }
        ("weapon", "ghost_rider1") => Some(include_bytes!(
            "../assets/previews/weapons/ghost_rider1.png"
        )),
        ("weapon", "ghost_twins") => {
            Some(include_bytes!("../assets/previews/weapons/ghost_twins.png"))
        }
        ("weapon", "ghost_twins1") => Some(include_bytes!(
            "../assets/previews/weapons/ghost_twins1.png"
        )),
        ("weapon", "glaive") => Some(include_bytes!("../assets/previews/weapons/glaive.png")),
        ("weapon", "glock") => Some(include_bytes!("../assets/previews/weapons/glock.png")),
        ("weapon", "glock_auto") => {
            Some(include_bytes!("../assets/previews/weapons/glock_auto.png"))
        }
        ("weapon", "glock_auto1") => {
            Some(include_bytes!("../assets/previews/weapons/glock_auto1.png"))
        }
        ("weapon", "glock_auto2") => {
            Some(include_bytes!("../assets/previews/weapons/glock_auto2.png"))
        }
        ("weapon", "glock_hell_snake") => Some(include_bytes!(
            "../assets/previews/weapons/glock_hell_snake.png"
        )),
        ("weapon", "glock_hell_snake1") => Some(include_bytes!(
            "../assets/previews/weapons/glock_hell_snake1.png"
        )),
        ("weapon", "glock_hell_snake2") => Some(include_bytes!(
            "../assets/previews/weapons/glock_hell_snake2.png"
        )),
        ("weapon", "glock_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/glock_redflash.png"
        )),
        ("weapon", "glock_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/glock_redflash1.png"
        )),
        ("weapon", "glock_ult") => Some(include_bytes!("../assets/previews/weapons/glock_ult.png")),
        ("weapon", "gloves") => Some(include_bytes!("../assets/previews/weapons/gloves.png")),
        ("weapon", "gloves_metal") => Some(include_bytes!(
            "../assets/previews/weapons/gloves_metal.png"
        )),
        ("weapon", "goldhoop_bar") => Some(include_bytes!(
            "../assets/previews/weapons/goldhoop_bar.png"
        )),
        ("weapon", "gold_saber") => {
            Some(include_bytes!("../assets/previews/weapons/gold_saber.png"))
        }
        ("weapon", "gold_saber1") => {
            Some(include_bytes!("../assets/previews/weapons/gold_saber1.png"))
        }
        ("weapon", "gold_snake") => {
            Some(include_bytes!("../assets/previews/weapons/gold_snake.png"))
        }
        ("weapon", "gold_snake1") => {
            Some(include_bytes!("../assets/previews/weapons/gold_snake1.png"))
        }
        ("weapon", "gold_terminator") => Some(include_bytes!(
            "../assets/previews/weapons/gold_terminator.png"
        )),
        ("weapon", "gold_terminator1") => Some(include_bytes!(
            "../assets/previews/weapons/gold_terminator1.png"
        )),
        ("weapon", "great_blade") => {
            Some(include_bytes!("../assets/previews/weapons/great_blade.png"))
        }
        ("weapon", "grenade_abyss") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_abyss.png"
        )),
        ("weapon", "grenade_alioth") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_alioth.png"
        )),
        ("weapon", "grenade_alioth1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_alioth1.png"
        )),
        ("weapon", "grenade_alioth2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_alioth2.png"
        )),
        ("weapon", "grenade_aurora") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_aurora.png"
        )),
        ("weapon", "grenade_aurora1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_aurora1.png"
        )),
        ("weapon", "grenade_aurora2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_aurora2.png"
        )),
        ("weapon", "grenade_bilibili") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_bilibili.png"
        )),
        ("weapon", "grenade_bone") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_bone.png"
        )),
        ("weapon", "grenade_darkerosion") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_darkerosion.png"
        )),
        ("weapon", "grenade_darkerosion1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_darkerosion1.png"
        )),
        ("weapon", "grenade_darkerosion2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_darkerosion2.png"
        )),
        ("weapon", "grenade_dubhe") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_dubhe.png"
        )),
        ("weapon", "grenade_dubhe1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_dubhe1.png"
        )),
        ("weapon", "grenade_dubhe2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_dubhe2.png"
        )),
        ("weapon", "grenade_duck") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_duck.png"
        )),
        ("weapon", "grenade_football") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_football.png"
        )),
        ("weapon", "grenade_frozen_star") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_frozen_star.png"
        )),
        ("weapon", "grenade_frozen_star1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_frozen_star1.png"
        )),
        ("weapon", "grenade_frozen_star2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_frozen_star2.png"
        )),
        ("weapon", "grenade_hell_snake") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_hell_snake.png"
        )),
        ("weapon", "grenade_hell_snake1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_hell_snake1.png"
        )),
        ("weapon", "grenade_hell_snake2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_hell_snake2.png"
        )),
        ("weapon", "grenade_ice") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_ice.png"))
        }
        ("weapon", "grenade_lego") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_lego.png"
        )),
        ("weapon", "grenade_lock") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_lock.png"
        )),
        ("weapon", "grenade_lock1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_lock1.png"
        )),
        ("weapon", "grenade_lock2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_lock2.png"
        )),
        ("weapon", "grenade_m9") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_m9.png"))
        }
        ("weapon", "grenade_md") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_md.png"))
        }
        ("weapon", "grenade_pro") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_pro.png"))
        }
        ("weapon", "grenade_rage") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_rage.png"
        )),
        ("weapon", "grenade_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_redflash.png"
        )),
        ("weapon", "grenade_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_redflash1.png"
        )),
        ("weapon", "grenade_rpg_ice") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_rpg_ice.png"
        )),
        ("weapon", "grenade_rpg_ice1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_rpg_ice1.png"
        )),
        ("weapon", "grenade_rpg_ice2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_rpg_ice2.png"
        )),
        ("weapon", "grenade_scorpion") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_scorpion.png"
        )),
        ("weapon", "grenade_star_dark") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_star_dark.png"
        )),
        ("weapon", "grenade_stone") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_stone.png"
        )),
        ("weapon", "grenade_strike") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_strike.png"
        )),
        ("weapon", "grenade_test") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_test.png"
        )),
        ("weapon", "grenade_thorns") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_thorns.png"
        )),
        ("weapon", "grenade_universe") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_universe.png"
        )),
        ("weapon", "grenade_universe1") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_universe1.png"
        )),
        ("weapon", "grenade_universe2") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_universe2.png"
        )),
        ("weapon", "grenade_warrior") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_warrior.png"
        )),
        ("weapon", "grenade_wasp") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_wasp.png"
        )),
        ("weapon", "grenade_wukong") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_wukong.png"
        )),
        ("weapon", "grey_core") => Some(include_bytes!("../assets/previews/weapons/grey_core.png")),
        ("weapon", "grey_core1") => {
            Some(include_bytes!("../assets/previews/weapons/grey_core1.png"))
        }
        ("weapon", "grey_core2") => {
            Some(include_bytes!("../assets/previews/weapons/grey_core2.png"))
        }
        ("weapon", "guanyu_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/guanyu_rifle.png"
        )),
        ("weapon", "guardian_stick") => Some(include_bytes!(
            "../assets/previews/weapons/guardian_stick.png"
        )),
        ("weapon", "guqin_trans_sword") => Some(include_bytes!(
            "../assets/previews/weapons/guqin_trans_sword.png"
        )),
        ("weapon", "guqin_trans_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/guqin_trans_sword1.png"
        )),
        ("weapon", "guqin_trans_sword2") => Some(include_bytes!(
            "../assets/previews/weapons/guqin_trans_sword2.png"
        )),
        ("weapon", "grenade") => Some(include_bytes!("../assets/previews/weapons/grenade.png")),
        ("weapon", "grenade_pumpkin") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_pumpkin.png"
        )),
        ("weapon", "grenade_love") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_love.png"
        )),
        ("weapon", "grenade_mooncake") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_mooncake.png"
        )),
        ("weapon", "grenade_smoke") => Some(include_bytes!(
            "../assets/previews/weapons/grenade_smoke.png"
        )),
        ("weapon", "grenade_uc") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_uc.png"))
        }
        ("weapon", "grenade_egg") => {
            Some(include_bytes!("../assets/previews/weapons/grenade_egg.png"))
        }
        ("weapon", "hammer") => Some(include_bytes!("../assets/previews/weapons/hammer.png")),
        ("weapon", "hammer_disco") => Some(include_bytes!(
            "../assets/previews/weapons/hammer_disco.png"
        )),
        ("weapon", "hammer_g") => Some(include_bytes!("../assets/previews/weapons/hammer_g.png")),
        ("weapon", "hammer_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/hammer_machinegun.png"
        )),
        ("weapon", "hammer_machinegun1") => Some(include_bytes!(
            "../assets/previews/weapons/hammer_machinegun1.png"
        )),
        ("weapon", "hammer_machinegun2") => Some(include_bytes!(
            "../assets/previews/weapons/hammer_machinegun2.png"
        )),
        ("weapon", "hand_of_zeuss") => Some(include_bytes!(
            "../assets/previews/weapons/hand_of_zeuss.png"
        )),
        ("weapon", "hand_of_zeuss1") => Some(include_bytes!(
            "../assets/previews/weapons/hand_of_zeuss1.png"
        )),
        ("weapon", "hand_of_zeuss2") => Some(include_bytes!(
            "../assets/previews/weapons/hand_of_zeuss2.png"
        )),
        ("weapon", "han_sword") => Some(include_bytes!("../assets/previews/weapons/han_sword.png")),
        ("weapon", "han_sword1") => {
            Some(include_bytes!("../assets/previews/weapons/han_sword1.png"))
        }
        ("weapon", "han_sword2") => {
            Some(include_bytes!("../assets/previews/weapons/han_sword2.png"))
        }
        ("weapon", "harp_tactic") => {
            Some(include_bytes!("../assets/previews/weapons/harp_tactic.png"))
        }
        ("weapon", "harp_tactic1") => Some(include_bytes!(
            "../assets/previews/weapons/harp_tactic1.png"
        )),
        ("weapon", "harp_tactic2") => Some(include_bytes!(
            "../assets/previews/weapons/harp_tactic2.png"
        )),
        ("weapon", "hero") => Some(include_bytes!("../assets/previews/weapons/hero.png")),
        ("weapon", "herowoman") => Some(include_bytes!("../assets/previews/weapons/herowoman.png")),
        ("weapon", "herowoman_close") => Some(include_bytes!(
            "../assets/previews/weapons/herowoman_close.png"
        )),
        ("weapon", "herowoman_gun") => Some(include_bytes!(
            "../assets/previews/weapons/herowoman_gun.png"
        )),
        ("weapon", "herowoman_skyfire") => Some(include_bytes!(
            "../assets/previews/weapons/herowoman_skyfire.png"
        )),
        ("weapon", "hero_blade") => {
            Some(include_bytes!("../assets/previews/weapons/hero_blade.png"))
        }
        ("weapon", "hero_close") => {
            Some(include_bytes!("../assets/previews/weapons/hero_close.png"))
        }
        ("weapon", "hero_cold_death") => Some(include_bytes!(
            "../assets/previews/weapons/hero_cold_death.png"
        )),
        ("weapon", "hero_cold_death1") => Some(include_bytes!(
            "../assets/previews/weapons/hero_cold_death1.png"
        )),
        ("weapon", "hero_guanzi") => {
            Some(include_bytes!("../assets/previews/weapons/hero_guanzi.png"))
        }
        ("weapon", "hero_gun") => Some(include_bytes!("../assets/previews/weapons/hero_gun.png")),
        ("weapon", "hero_gun_woman") => Some(include_bytes!(
            "../assets/previews/weapons/hero_gun_woman.png"
        )),
        ("weapon", "hero_lego") => Some(include_bytes!("../assets/previews/weapons/hero_lego.png")),
        ("weapon", "hero_pokong") => {
            Some(include_bytes!("../assets/previews/weapons/hero_pokong.png"))
        }
        ("weapon", "hero_sangzhong") => Some(include_bytes!(
            "../assets/previews/weapons/hero_sangzhong.png"
        )),
        ("weapon", "hero_shark") => {
            Some(include_bytes!("../assets/previews/weapons/hero_shark.png"))
        }
        ("weapon", "hero_skyfire") => Some(include_bytes!(
            "../assets/previews/weapons/hero_skyfire.png"
        )),
        ("weapon", "hero_weapon_base") => Some(include_bytes!(
            "../assets/previews/weapons/hero_weapon_base.png"
        )),
        ("weapon", "hero_weapon_base_man") => Some(include_bytes!(
            "../assets/previews/weapons/hero_weapon_base_man.png"
        )),
        ("weapon", "hide_dou_blade") => Some(include_bytes!(
            "../assets/previews/weapons/hide_dou_blade.png"
        )),
        ("weapon", "highgrenade_deathray") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_deathray.png"
        )),
        ("weapon", "highgrenade_deathray1") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_deathray1.png"
        )),
        ("weapon", "highgrenade_deathray2") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_deathray2.png"
        )),
        ("weapon", "highgrenade_ult") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_ult.png"
        )),
        ("weapon", "hippo_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/hippo_grenade.png"
        )),
        ("weapon", "hk416") => Some(include_bytes!("../assets/previews/weapons/hk416.png")),
        ("weapon", "hk416_icey") => {
            Some(include_bytes!("../assets/previews/weapons/hk416_icey.png"))
        }
        ("weapon", "hk416_zero") => {
            Some(include_bytes!("../assets/previews/weapons/hk416_zero.png"))
        }
        ("weapon", "hkg11") => Some(include_bytes!("../assets/previews/weapons/hkg11.png")),
        ("weapon", "holy_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/holy_grenade.png"
        )),
        ("weapon", "holy_rosary") => {
            Some(include_bytes!("../assets/previews/weapons/holy_rosary.png"))
        }
        ("weapon", "honor_shield") => Some(include_bytes!(
            "../assets/previews/weapons/honor_shield.png"
        )),
        ("weapon", "hormone_injection") => Some(include_bytes!(
            "../assets/previews/weapons/hormone_injection.png"
        )),
        ("weapon", "hormone_injection1") => Some(include_bytes!(
            "../assets/previews/weapons/hormone_injection1.png"
        )),
        ("weapon", "hormone_injection2") => Some(include_bytes!(
            "../assets/previews/weapons/hormone_injection2.png"
        )),
        ("weapon", "horror_claw") => {
            Some(include_bytes!("../assets/previews/weapons/horror_claw.png"))
        }
        ("weapon", "howitzer") => Some(include_bytes!("../assets/previews/weapons/howitzer.png")),
        ("weapon", "howitzerwoman") => Some(include_bytes!(
            "../assets/previews/weapons/howitzerwoman.png"
        )),
        ("weapon", "howitzerwoman_skyfire") => Some(include_bytes!(
            "../assets/previews/weapons/howitzerwoman_skyfire.png"
        )),
        ("weapon", "howitzer_skyfire") => Some(include_bytes!(
            "../assets/previews/weapons/howitzer_skyfire.png"
        )),
        ("weapon", "hrc140_hell") => {
            Some(include_bytes!("../assets/previews/weapons/hrc140_hell.png"))
        }
        ("weapon", "hrc140_hell1") => Some(include_bytes!(
            "../assets/previews/weapons/hrc140_hell1.png"
        )),
        ("weapon", "hrc140_hell2") => Some(include_bytes!(
            "../assets/previews/weapons/hrc140_hell2.png"
        )),
        ("weapon", "hunter_ak47") => {
            Some(include_bytes!("../assets/previews/weapons/hunter_ak47.png"))
        }
        ("weapon", "hunter_cz75") => {
            Some(include_bytes!("../assets/previews/weapons/hunter_cz75.png"))
        }
        ("weapon", "hunter_nbr") => {
            Some(include_bytes!("../assets/previews/weapons/hunter_nbr.png"))
        }
        ("weapon", "hunter_submachinegun") => Some(include_bytes!(
            "../assets/previews/weapons/hunter_submachinegun.png"
        )),
        ("weapon", "hunter_vss") => {
            Some(include_bytes!("../assets/previews/weapons/hunter_vss.png"))
        }
        ("weapon", "hunter_xm1014") => Some(include_bytes!(
            "../assets/previews/weapons/hunter_xm1014.png"
        )),
        ("weapon", "hunting_knife") => Some(include_bytes!(
            "../assets/previews/weapons/hunting_knife.png"
        )),
        ("weapon", "hyena_shears") => Some(include_bytes!(
            "../assets/previews/weapons/hyena_shears.png"
        )),
        ("weapon", "hypertech") => Some(include_bytes!("../assets/previews/weapons/hypertech.png")),
        ("weapon", "hyper_revolver") => Some(include_bytes!(
            "../assets/previews/weapons/hyper_revolver.png"
        )),
        ("weapon", "hyper_revolver1") => Some(include_bytes!(
            "../assets/previews/weapons/hyper_revolver1.png"
        )),
        ("weapon", "hyper_revolver2") => Some(include_bytes!(
            "../assets/previews/weapons/hyper_revolver2.png"
        )),
        ("weapon", "highgrenade") => {
            Some(include_bytes!("../assets/previews/weapons/highgrenade.png"))
        }
        ("weapon", "highgrenade_g") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_g.png"
        )),
        ("weapon", "highgrenade_glory") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_glory.png"
        )),
        ("weapon", "highgrenade_y") => Some(include_bytes!(
            "../assets/previews/weapons/highgrenade_y.png"
        )),
        ("weapon", "ice_ax") => Some(include_bytes!("../assets/previews/weapons/ice_ax.png")),
        ("weapon", "ice_ball") => Some(include_bytes!("../assets/previews/weapons/ice_ball.png")),
        ("weapon", "ice_ball_ult") => Some(include_bytes!(
            "../assets/previews/weapons/ice_ball_ult.png"
        )),
        ("weapon", "ice_cream_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/ice_cream_grenade.png"
        )),
        ("weapon", "ice_dou_blade") => Some(include_bytes!(
            "../assets/previews/weapons/ice_dou_blade.png"
        )),
        ("weapon", "immortal_sword") => Some(include_bytes!(
            "../assets/previews/weapons/immortal_sword.png"
        )),
        ("weapon", "impasse_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/impasse_machinegun.png"
        )),
        ("weapon", "induction") => Some(include_bytes!("../assets/previews/weapons/induction.png")),
        ("weapon", "infinite_domination") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_domination.png"
        )),
        ("weapon", "infinite_hand1") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand1.png"
        )),
        ("weapon", "infinite_hand1_change_1") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand1_change_1.png"
        )),
        ("weapon", "infinite_hand1_change_2") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand1_change_2.png"
        )),
        ("weapon", "infinite_hand2") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand2.png"
        )),
        ("weapon", "infinite_hand2_change_1") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand2_change_1.png"
        )),
        ("weapon", "infinite_hand2_change_2") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand2_change_2.png"
        )),
        ("weapon", "infinite_hand3") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand3.png"
        )),
        ("weapon", "infinite_hand3_change_1") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand3_change_1.png"
        )),
        ("weapon", "infinite_hand3_change_2") => Some(include_bytes!(
            "../assets/previews/weapons/infinite_hand3_change_2.png"
        )),
        ("weapon", "inflatable_hammer") => Some(include_bytes!(
            "../assets/previews/weapons/inflatable_hammer.png"
        )),
        ("weapon", "intelligent_submachinegun") => Some(include_bytes!(
            "../assets/previews/weapons/intelligent_submachinegun.png"
        )),
        ("weapon", "iron_fan") => Some(include_bytes!("../assets/previews/weapons/iron_fan.png")),
        ("weapon", "iron_toothed_rake") => Some(include_bytes!(
            "../assets/previews/weapons/iron_toothed_rake.png"
        )),
        ("weapon", "jackhammer") => {
            Some(include_bytes!("../assets/previews/weapons/jackhammer.png"))
        }
        ("weapon", "jackhammer_g") => Some(include_bytes!(
            "../assets/previews/weapons/jackhammer_g.png"
        )),
        ("weapon", "jiewangzhe") => {
            Some(include_bytes!("../assets/previews/weapons/jiewangzhe.png"))
        }
        ("weapon", "jinjiao") => Some(include_bytes!("../assets/previews/weapons/jinjiao.png")),
        ("weapon", "jms") => Some(include_bytes!("../assets/previews/weapons/jms.png")),
        ("weapon", "jms_bilibili") => Some(include_bytes!(
            "../assets/previews/weapons/jms_bilibili.png"
        )),
        ("weapon", "jms_fight") => Some(include_bytes!("../assets/previews/weapons/jms_fight.png")),
        ("weapon", "jms_warrior") => {
            Some(include_bytes!("../assets/previews/weapons/jms_warrior.png"))
        }
        ("weapon", "jms_wolf") => Some(include_bytes!("../assets/previews/weapons/jms_wolf.png")),
        ("weapon", "judge_eye_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/judge_eye_rifle.png"
        )),
        ("weapon", "judge_eye_rifle1") => Some(include_bytes!(
            "../assets/previews/weapons/judge_eye_rifle1.png"
        )),
        ("weapon", "judge_eye_rifle2") => Some(include_bytes!(
            "../assets/previews/weapons/judge_eye_rifle2.png"
        )),
        ("weapon", "jump_hammer") => {
            Some(include_bytes!("../assets/previews/weapons/jump_hammer.png"))
        }
        ("weapon", "justice_from_above") => Some(include_bytes!(
            "../assets/previews/weapons/justice_from_above.png"
        )),
        ("weapon", "k28sword") => Some(include_bytes!("../assets/previews/weapons/k28sword.png")),
        ("weapon", "k28sword1") => Some(include_bytes!("../assets/previews/weapons/k28sword1.png")),
        ("weapon", "k28sword2") => Some(include_bytes!("../assets/previews/weapons/k28sword2.png")),
        ("weapon", "kac_reaper") => {
            Some(include_bytes!("../assets/previews/weapons/kac_reaper.png"))
        }
        ("weapon", "kac_reaper_g") => Some(include_bytes!(
            "../assets/previews/weapons/kac_reaper_g.png"
        )),
        ("weapon", "keris") => Some(include_bytes!("../assets/previews/weapons/keris.png")),
        ("weapon", "ketuo_knife") => {
            Some(include_bytes!("../assets/previews/weapons/ketuo_knife.png"))
        }
        ("weapon", "ketuo_knife_1") => Some(include_bytes!(
            "../assets/previews/weapons/ketuo_knife_1.png"
        )),
        ("weapon", "ketuo_knife_2") => Some(include_bytes!(
            "../assets/previews/weapons/ketuo_knife_2.png"
        )),
        ("weapon", "ketuo_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/ketuo_pistol.png"
        )),
        ("weapon", "ketuo_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/ketuo_pistol1.png"
        )),
        ("weapon", "ketuo_pistol2") => Some(include_bytes!(
            "../assets/previews/weapons/ketuo_pistol2.png"
        )),
        ("weapon", "keyboard") => Some(include_bytes!("../assets/previews/weapons/keyboard.png")),
        ("weapon", "kingslayer") => {
            Some(include_bytes!("../assets/previews/weapons/kingslayer.png"))
        }
        ("weapon", "king_hammer") => {
            Some(include_bytes!("../assets/previews/weapons/king_hammer.png"))
        }
        ("weapon", "knife_cmdr") => {
            Some(include_bytes!("../assets/previews/weapons/knife_cmdr.png"))
        }
        ("weapon", "knife_pro") => Some(include_bytes!("../assets/previews/weapons/knife_pro.png")),
        ("weapon", "knife_wheel") => {
            Some(include_bytes!("../assets/previews/weapons/knife_wheel.png"))
        }
        ("weapon", "knuckle") => Some(include_bytes!("../assets/previews/weapons/knuckle.png")),
        ("weapon", "kriss") => Some(include_bytes!("../assets/previews/weapons/kriss.png")),
        ("weapon", "kriss1") => Some(include_bytes!("../assets/previews/weapons/kriss1.png")),
        ("weapon", "kunlungongzhu") => Some(include_bytes!(
            "../assets/previews/weapons/kunlungongzhu.png"
        )),
        ("weapon", "lamb_2nd") => Some(include_bytes!("../assets/previews/weapons/lamb_2nd.png")),
        ("weapon", "lantern") => Some(include_bytes!("../assets/previews/weapons/lantern.png")),
        ("weapon", "lantern2025") => {
            Some(include_bytes!("../assets/previews/weapons/lantern2025.png"))
        }
        ("weapon", "lantern_flashbang") => Some(include_bytes!(
            "../assets/previews/weapons/lantern_flashbang.png"
        )),
        ("weapon", "lantern_tactic") => Some(include_bytes!(
            "../assets/previews/weapons/lantern_tactic.png"
        )),
        ("weapon", "laser_hero_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/laser_hero_pistol.png"
        )),
        ("weapon", "laser_sword") => {
            Some(include_bytes!("../assets/previews/weapons/laser_sword.png"))
        }
        ("weapon", "laser_sword_ch") => Some(include_bytes!(
            "../assets/previews/weapons/laser_sword_ch.png"
        )),
        ("weapon", "lego_shotgun_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/lego_shotgun_pistol.png"
        )),
        ("weapon", "leviathan_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/leviathan_rifle.png"
        )),
        ("weapon", "liandaoMonther") => Some(include_bytes!(
            "../assets/previews/weapons/liandaoMonther.png"
        )),
        ("weapon", "lightening_sword") => Some(include_bytes!(
            "../assets/previews/weapons/lightening_sword.png"
        )),
        ("weapon", "lighting_star") => Some(include_bytes!(
            "../assets/previews/weapons/lighting_star.png"
        )),
        ("weapon", "lighting_star1") => Some(include_bytes!(
            "../assets/previews/weapons/lighting_star1.png"
        )),
        ("weapon", "light_birth") => {
            Some(include_bytes!("../assets/previews/weapons/light_birth.png"))
        }
        ("weapon", "light_birth1") => Some(include_bytes!(
            "../assets/previews/weapons/light_birth1.png"
        )),
        ("weapon", "light_birth2") => Some(include_bytes!(
            "../assets/previews/weapons/light_birth2.png"
        )),
        ("weapon", "light_darkness_submachinegun") => Some(include_bytes!(
            "../assets/previews/weapons/light_darkness_submachinegun.png"
        )),
        ("weapon", "light_edge_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/light_edge_grenade.png"
        )),
        ("weapon", "light_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/light_sniper.png"
        )),
        ("weapon", "light_with_shadow") => Some(include_bytes!(
            "../assets/previews/weapons/light_with_shadow.png"
        )),
        ("weapon", "little_piggy") => Some(include_bytes!(
            "../assets/previews/weapons/little_piggy.png"
        )),
        ("weapon", "lotus_flashbang") => Some(include_bytes!(
            "../assets/previews/weapons/lotus_flashbang.png"
        )),
        ("weapon", "lotus_flashbang1") => Some(include_bytes!(
            "../assets/previews/weapons/lotus_flashbang1.png"
        )),
        ("weapon", "lotus_flashbang2") => Some(include_bytes!(
            "../assets/previews/weapons/lotus_flashbang2.png"
        )),
        ("weapon", "lotus_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/lotus_pistol.png"
        )),
        ("weapon", "lover2025_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/lover2025_grenade.png"
        )),
        ("weapon", "love_crossbow") => Some(include_bytes!(
            "../assets/previews/weapons/love_crossbow.png"
        )),
        ("weapon", "lr4_dawn") => Some(include_bytes!("../assets/previews/weapons/lr4_dawn.png")),
        ("weapon", "lr4_dragon") => {
            Some(include_bytes!("../assets/previews/weapons/lr4_dragon.png"))
        }
        ("weapon", "lr4_rage") => Some(include_bytes!("../assets/previews/weapons/lr4_rage.png")),
        ("weapon", "m14") => Some(include_bytes!("../assets/previews/weapons/m14.png")),
        ("weapon", "m14_g") => Some(include_bytes!("../assets/previews/weapons/m14_g.png")),
        ("weapon", "m14_g1") => Some(include_bytes!("../assets/previews/weapons/m14_g1.png")),
        ("weapon", "m14_hell") => Some(include_bytes!("../assets/previews/weapons/m14_hell.png")),
        ("weapon", "m14_hell1") => Some(include_bytes!("../assets/previews/weapons/m14_hell1.png")),
        ("weapon", "m14_hell2") => Some(include_bytes!("../assets/previews/weapons/m14_hell2.png")),
        ("weapon", "m14_wukong") => {
            Some(include_bytes!("../assets/previews/weapons/m14_wukong.png"))
        }
        ("weapon", "m1887") => Some(include_bytes!("../assets/previews/weapons/m1887.png")),
        ("weapon", "m1887_dawn") => {
            Some(include_bytes!("../assets/previews/weapons/m1887_dawn.png"))
        }
        ("weapon", "m1887_y") => Some(include_bytes!("../assets/previews/weapons/m1887_y.png")),
        ("weapon", "m18a1_claymore") => Some(include_bytes!(
            "../assets/previews/weapons/m18a1_claymore.png"
        )),
        ("weapon", "m18a1_claymore1") => Some(include_bytes!(
            "../assets/previews/weapons/m18a1_claymore1.png"
        )),
        ("weapon", "m18a1_claymore2") => Some(include_bytes!(
            "../assets/previews/weapons/m18a1_claymore2.png"
        )),
        ("weapon", "m18a1_claymore_controller") => Some(include_bytes!(
            "../assets/previews/weapons/m18a1_claymore_controller.png"
        )),
        ("weapon", "m1911") => Some(include_bytes!("../assets/previews/weapons/m1911.png")),
        ("weapon", "m1911_jupiter") => Some(include_bytes!(
            "../assets/previews/weapons/m1911_jupiter.png"
        )),
        ("weapon", "m1911_rage") => {
            Some(include_bytes!("../assets/previews/weapons/m1911_rage.png"))
        }
        ("weapon", "m1932") => Some(include_bytes!("../assets/previews/weapons/m1932.png")),
        ("weapon", "m1932_th") => Some(include_bytes!("../assets/previews/weapons/m1932_th.png")),
        ("weapon", "m202flash") => Some(include_bytes!("../assets/previews/weapons/m202flash.png")),
        ("weapon", "m202flash_rpg") => Some(include_bytes!(
            "../assets/previews/weapons/m202flash_rpg.png"
        )),
        ("weapon", "m249") => Some(include_bytes!("../assets/previews/weapons/m249.png")),
        ("weapon", "m249_howitzer") => Some(include_bytes!(
            "../assets/previews/weapons/m249_howitzer.png"
        )),
        ("weapon", "m249_moon") => Some(include_bytes!("../assets/previews/weapons/m249_moon.png")),
        ("weapon", "m249_rocket") => {
            Some(include_bytes!("../assets/previews/weapons/m249_rocket.png"))
        }
        ("weapon", "m249_ult") => Some(include_bytes!("../assets/previews/weapons/m249_ult.png")),
        ("weapon", "m249_warrior") => Some(include_bytes!(
            "../assets/previews/weapons/m249_warrior.png"
        )),
        ("weapon", "m249_y") => Some(include_bytes!("../assets/previews/weapons/m249_y.png")),
        ("weapon", "m2_machine_gun") => Some(include_bytes!(
            "../assets/previews/weapons/m2_machine_gun.png"
        )),
        ("weapon", "m2_machine_gun1") => Some(include_bytes!(
            "../assets/previews/weapons/m2_machine_gun1.png"
        )),
        ("weapon", "m2_machine_gun2") => Some(include_bytes!(
            "../assets/previews/weapons/m2_machine_gun2.png"
        )),
        ("weapon", "m2_machine_gun3") => Some(include_bytes!(
            "../assets/previews/weapons/m2_machine_gun3.png"
        )),
        ("weapon", "m3") => Some(include_bytes!("../assets/previews/weapons/m3.png")),
        ("weapon", "m32") => Some(include_bytes!("../assets/previews/weapons/m32.png")),
        ("weapon", "m32_1") => Some(include_bytes!("../assets/previews/weapons/m32_1.png")),
        ("weapon", "m32_2") => Some(include_bytes!("../assets/previews/weapons/m32_2.png")),
        ("weapon", "m32_a") => Some(include_bytes!("../assets/previews/weapons/m32_a.png")),
        ("weapon", "m32_g") => Some(include_bytes!("../assets/previews/weapons/m32_g.png")),
        ("weapon", "m3_rage") => Some(include_bytes!("../assets/previews/weapons/m3_rage.png")),
        ("weapon", "m3_rage1") => Some(include_bytes!("../assets/previews/weapons/m3_rage1.png")),
        ("weapon", "m3_rage2") => Some(include_bytes!("../assets/previews/weapons/m3_rage2.png")),
        ("weapon", "m3_rage3") => Some(include_bytes!("../assets/previews/weapons/m3_rage3.png")),
        ("weapon", "m4") => Some(include_bytes!("../assets/previews/weapons/m4.png")),
        ("weapon", "m4a1") => Some(include_bytes!("../assets/previews/weapons/m4a1.png")),
        ("weapon", "m4a1_a") => Some(include_bytes!("../assets/previews/weapons/m4a1_a.png")),
        ("weapon", "m4a1_anger_monster") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_anger_monster.png"
        )),
        ("weapon", "m4a1_c") => Some(include_bytes!("../assets/previews/weapons/m4a1_c.png")),
        ("weapon", "m4a1_dawn") => Some(include_bytes!("../assets/previews/weapons/m4a1_dawn.png")),
        ("weapon", "m4a1_dragon") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_dragon.png"))
        }
        ("weapon", "m4a1_g") => Some(include_bytes!("../assets/previews/weapons/m4a1_g.png")),
        ("weapon", "m4a1_g1") => Some(include_bytes!("../assets/previews/weapons/m4a1_g1.png")),
        ("weapon", "m4a1_glory") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_glory.png"))
        }
        ("weapon", "m4a1_glory_red") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_glory_red.png"
        )),
        ("weapon", "m4a1_hero") => Some(include_bytes!("../assets/previews/weapons/m4a1_hero.png")),
        ("weapon", "m4a1_hero1") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_hero1.png"))
        }
        ("weapon", "m4a1_hero_alpha") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_hero_alpha.png"
        )),
        ("weapon", "m4a1_ice") => Some(include_bytes!("../assets/previews/weapons/m4a1_ice.png")),
        ("weapon", "m4a1_immortal") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_immortal.png"
        )),
        ("weapon", "m4a1_king") => Some(include_bytes!("../assets/previews/weapons/m4a1_king.png")),
        ("weapon", "m4a1_knight") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_knight.png"))
        }
        ("weapon", "m4a1_knight1") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_knight1.png"
        )),
        ("weapon", "m4a1_knight2") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_knight2.png"
        )),
        ("weapon", "m4a1_knight_lite") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_knight_lite.png"
        )),
        ("weapon", "m4a1_legend") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_legend.png"))
        }
        ("weapon", "m4a1_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_legend1.png"
        )),
        ("weapon", "m4a1_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_legend2.png"
        )),
        ("weapon", "m4a1_pluto") => {
            Some(include_bytes!("../assets/previews/weapons/m4a1_pluto.png"))
        }
        ("weapon", "m4a1_pro") => Some(include_bytes!("../assets/previews/weapons/m4a1_pro.png")),
        ("weapon", "m4a1_s") => Some(include_bytes!("../assets/previews/weapons/m4a1_s.png")),
        ("weapon", "m4a1_silence") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_silence.png"
        )),
        ("weapon", "m4a1_snow") => Some(include_bytes!("../assets/previews/weapons/m4a1_snow.png")),
        ("weapon", "m4a1_team_invasion") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_team_invasion.png"
        )),
        ("weapon", "m4a1_team_invasion1") => Some(include_bytes!(
            "../assets/previews/weapons/m4a1_team_invasion1.png"
        )),
        ("weapon", "m4a1_test") => Some(include_bytes!("../assets/previews/weapons/m4a1_test.png")),
        ("weapon", "m4a1_ult") => Some(include_bytes!("../assets/previews/weapons/m4a1_ult.png")),
        ("weapon", "m4a1_y") => Some(include_bytes!("../assets/previews/weapons/m4a1_y.png")),
        ("weapon", "m4a1_zy") => Some(include_bytes!("../assets/previews/weapons/m4a1_zy.png")),
        ("weapon", "m4a4") => Some(include_bytes!("../assets/previews/weapons/m4a4.png")),
        ("weapon", "m4a4_rage") => Some(include_bytes!("../assets/previews/weapons/m4a4_rage.png")),
        ("weapon", "m4a4_spring") => {
            Some(include_bytes!("../assets/previews/weapons/m4a4_spring.png"))
        }
        ("weapon", "m4a4_zh") => Some(include_bytes!("../assets/previews/weapons/m4a4_zh.png")),
        ("weapon", "m4_g") => Some(include_bytes!("../assets/previews/weapons/m4_g.png")),
        ("weapon", "m4_graffiti") => {
            Some(include_bytes!("../assets/previews/weapons/m4_graffiti.png"))
        }
        ("weapon", "m500") => Some(include_bytes!("../assets/previews/weapons/m500.png")),
        ("weapon", "m500_fire") => Some(include_bytes!("../assets/previews/weapons/m500_fire.png")),
        ("weapon", "m60") => Some(include_bytes!("../assets/previews/weapons/m60.png")),
        ("weapon", "m60e6bloodanger") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6bloodanger.png"
        )),
        ("weapon", "m60e6bloodanger1") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6bloodanger1.png"
        )),
        ("weapon", "m60e6bloodanger2") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6bloodanger2.png"
        )),
        ("weapon", "m60e6_vampire") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6_vampire.png"
        )),
        ("weapon", "m60e6_vampire_1") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6_vampire_1.png"
        )),
        ("weapon", "m60e6_vampire_2") => Some(include_bytes!(
            "../assets/previews/weapons/m60e6_vampire_2.png"
        )),
        ("weapon", "m60_1") => Some(include_bytes!("../assets/previews/weapons/m60_1.png")),
        ("weapon", "m60_2") => Some(include_bytes!("../assets/previews/weapons/m60_2.png")),
        ("weapon", "m60_roadmaster") => Some(include_bytes!(
            "../assets/previews/weapons/m60_roadmaster.png"
        )),
        ("weapon", "m79_howitzer") => Some(include_bytes!(
            "../assets/previews/weapons/m79_howitzer.png"
        )),
        ("weapon", "m79_howitzer1") => Some(include_bytes!(
            "../assets/previews/weapons/m79_howitzer1.png"
        )),
        ("weapon", "m79_howitzer2") => Some(include_bytes!(
            "../assets/previews/weapons/m79_howitzer2.png"
        )),
        ("weapon", "m84_devil") => Some(include_bytes!("../assets/previews/weapons/m84_devil.png")),
        ("weapon", "m84_devil1") => {
            Some(include_bytes!("../assets/previews/weapons/m84_devil1.png"))
        }
        ("weapon", "m84_devil2") => {
            Some(include_bytes!("../assets/previews/weapons/m84_devil2.png"))
        }
        ("weapon", "m96_shadow") => {
            Some(include_bytes!("../assets/previews/weapons/m96_shadow.png"))
        }
        ("weapon", "m99_barrett") => {
            Some(include_bytes!("../assets/previews/weapons/m99_barrett.png"))
        }
        ("weapon", "m99_barrett1") => Some(include_bytes!(
            "../assets/previews/weapons/m99_barrett1.png"
        )),
        ("weapon", "m99_barrett2") => Some(include_bytes!(
            "../assets/previews/weapons/m99_barrett2.png"
        )),
        ("weapon", "m99_barrett3") => Some(include_bytes!(
            "../assets/previews/weapons/m99_barrett3.png"
        )),
        ("weapon", "m9_devil") => Some(include_bytes!("../assets/previews/weapons/m9_devil.png")),
        ("weapon", "m9_devil1") => Some(include_bytes!("../assets/previews/weapons/m9_devil1.png")),
        ("weapon", "m9_devil2") => Some(include_bytes!("../assets/previews/weapons/m9_devil2.png")),
        ("weapon", "mace") => Some(include_bytes!("../assets/previews/weapons/mace.png")),
        ("weapon", "magnetic_track_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/magnetic_track_grenade.png"
        )),
        ("weapon", "magnetic_track_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/magnetic_track_grenade1.png"
        )),
        ("weapon", "magnetic_track_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/magnetic_track_grenade2.png"
        )),
        ("weapon", "mantis_arm") => {
            Some(include_bytes!("../assets/previews/weapons/mantis_arm.png"))
        }
        ("weapon", "manwang") => Some(include_bytes!("../assets/previews/weapons/manwang.png")),
        ("weapon", "maolin") => Some(include_bytes!("../assets/previews/weapons/maolin.png")),
        ("weapon", "maroon") => Some(include_bytes!("../assets/previews/weapons/maroon.png")),
        ("weapon", "mcx") => Some(include_bytes!("../assets/previews/weapons/mcx.png")),
        ("weapon", "mc_backsword") => Some(include_bytes!(
            "../assets/previews/weapons/mc_backsword.png"
        )),
        ("weapon", "mc_masonrysword") => Some(include_bytes!(
            "../assets/previews/weapons/mc_masonrysword.png"
        )),
        ("weapon", "md_93r") => Some(include_bytes!("../assets/previews/weapons/md_93r.png")),
        ("weapon", "mechbomberman") => Some(include_bytes!(
            "../assets/previews/weapons/mechbomberman.png"
        )),
        ("weapon", "mechbomberman2") => Some(include_bytes!(
            "../assets/previews/weapons/mechbomberman2.png"
        )),
        ("weapon", "mechfar") => Some(include_bytes!("../assets/previews/weapons/mechfar.png")),
        ("weapon", "mechfar2") => Some(include_bytes!("../assets/previews/weapons/mechfar2.png")),
        ("weapon", "mechnear") => Some(include_bytes!("../assets/previews/weapons/mechnear.png")),
        ("weapon", "mechnear2") => Some(include_bytes!("../assets/previews/weapons/mechnear2.png")),
        ("weapon", "mechpredator") => Some(include_bytes!(
            "../assets/previews/weapons/mechpredator.png"
        )),
        ("weapon", "mech_akm") => Some(include_bytes!("../assets/previews/weapons/mech_akm.png")),
        ("weapon", "mech_deagle") => {
            Some(include_bytes!("../assets/previews/weapons/mech_deagle.png"))
        }
        ("weapon", "mech_dou_akm") => Some(include_bytes!(
            "../assets/previews/weapons/mech_dou_akm.png"
        )),
        ("weapon", "mech_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/mech_grenade.png"
        )),
        ("weapon", "mech_king") => Some(include_bytes!("../assets/previews/weapons/mech_king.png")),
        ("weapon", "mech_nbr") => Some(include_bytes!("../assets/previews/weapons/mech_nbr.png")),
        ("weapon", "medusa_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/medusa_sniper.png"
        )),
        ("weapon", "mengji") => Some(include_bytes!("../assets/previews/weapons/mengji.png")),
        ("weapon", "mental_burster") => Some(include_bytes!(
            "../assets/previews/weapons/mental_burster.png"
        )),
        ("weapon", "mental_burster1") => Some(include_bytes!(
            "../assets/previews/weapons/mental_burster1.png"
        )),
        ("weapon", "mental_burster2") => Some(include_bytes!(
            "../assets/previews/weapons/mental_burster2.png"
        )),
        ("weapon", "metalman") => Some(include_bytes!("../assets/previews/weapons/metalman.png")),
        ("weapon", "mg3") => Some(include_bytes!("../assets/previews/weapons/mg3.png")),
        ("weapon", "mg3_camo") => Some(include_bytes!("../assets/previews/weapons/mg3_camo.png")),
        ("weapon", "mg3_g") => Some(include_bytes!("../assets/previews/weapons/mg3_g.png")),
        ("weapon", "mg4") => Some(include_bytes!("../assets/previews/weapons/mg4.png")),
        ("weapon", "mg4_1") => Some(include_bytes!("../assets/previews/weapons/mg4_1.png")),
        ("weapon", "mg4_2") => Some(include_bytes!("../assets/previews/weapons/mg4_2.png")),
        ("weapon", "mikaduki_sword") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword.png"
        )),
        ("weapon", "mikaduki_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword1.png"
        )),
        ("weapon", "mikaduki_sword_dkl") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_dkl.png"
        )),
        ("weapon", "mikaduki_sword_dkl_lite") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_dkl_lite.png"
        )),
        ("weapon", "mikaduki_sword_lotus") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_lotus.png"
        )),
        ("weapon", "mikaduki_sword_tradition") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_tradition.png"
        )),
        ("weapon", "mikaduki_sword_tradition1") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_tradition1.png"
        )),
        ("weapon", "mikaduki_sword_wave") => Some(include_bytes!(
            "../assets/previews/weapons/mikaduki_sword_wave.png"
        )),
        ("weapon", "minideath") => Some(include_bytes!("../assets/previews/weapons/minideath.png")),
        ("weapon", "minideath1") => {
            Some(include_bytes!("../assets/previews/weapons/minideath1.png"))
        }
        ("weapon", "mini_samurai_sword") => Some(include_bytes!(
            "../assets/previews/weapons/mini_samurai_sword.png"
        )),
        ("weapon", "mirage_dou_blade") => Some(include_bytes!(
            "../assets/previews/weapons/mirage_dou_blade.png"
        )),
        ("weapon", "mirage_dou_blade_hero") => Some(include_bytes!(
            "../assets/previews/weapons/mirage_dou_blade_hero.png"
        )),
        ("weapon", "mirage_sickle") => Some(include_bytes!(
            "../assets/previews/weapons/mirage_sickle.png"
        )),
        ("weapon", "mk14_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash.png"
        )),
        ("weapon", "mk14_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash1.png"
        )),
        ("weapon", "mk14_redflash_ether") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_ether.png"
        )),
        ("weapon", "mk14_redflash_ether1") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_ether1.png"
        )),
        ("weapon", "mk14_redflash_rose") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_rose.png"
        )),
        ("weapon", "mk14_redflash_rose1") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_rose1.png"
        )),
        ("weapon", "mk14_redflash_wolfram") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_wolfram.png"
        )),
        ("weapon", "mk14_redflash_wolfram1") => Some(include_bytes!(
            "../assets/previews/weapons/mk14_redflash_wolfram1.png"
        )),
        ("weapon", "mk_roadmaster") => Some(include_bytes!(
            "../assets/previews/weapons/mk_roadmaster.png"
        )),
        ("weapon", "mobius_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/mobius_machinegun.png"
        )),
        ("weapon", "monitor_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/monitor_grenade.png"
        )),
        ("weapon", "monk_pole") => Some(include_bytes!("../assets/previews/weapons/monk_pole.png")),
        ("weapon", "moon2026_sg") => {
            Some(include_bytes!("../assets/previews/weapons/moon2026_sg.png"))
        }
        ("weapon", "mooncake_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/mooncake_pistol.png"
        )),
        ("weapon", "moon_blade") => {
            Some(include_bytes!("../assets/previews/weapons/moon_blade.png"))
        }
        ("weapon", "moon_flashbang") => Some(include_bytes!(
            "../assets/previews/weapons/moon_flashbang.png"
        )),
        ("weapon", "moon_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/moon_rifle.png"))
        }
        ("weapon", "moye") => Some(include_bytes!("../assets/previews/weapons/moye.png")),
        ("weapon", "moye_g") => Some(include_bytes!("../assets/previews/weapons/moye_g.png")),
        ("weapon", "mp40") => Some(include_bytes!("../assets/previews/weapons/mp40.png")),
        ("weapon", "mp5") => Some(include_bytes!("../assets/previews/weapons/mp5.png")),
        ("weapon", "mp5sd6_devil") => Some(include_bytes!(
            "../assets/previews/weapons/mp5sd6_devil.png"
        )),
        ("weapon", "mp5sd6_devil1") => Some(include_bytes!(
            "../assets/previews/weapons/mp5sd6_devil1.png"
        )),
        ("weapon", "mp5sd6_devil2") => Some(include_bytes!(
            "../assets/previews/weapons/mp5sd6_devil2.png"
        )),
        ("weapon", "mp5_ice") => Some(include_bytes!("../assets/previews/weapons/mp5_ice.png")),
        ("weapon", "mp5_ice1") => Some(include_bytes!("../assets/previews/weapons/mp5_ice1.png")),
        ("weapon", "mp5_predator") => Some(include_bytes!(
            "../assets/previews/weapons/mp5_predator.png"
        )),
        ("weapon", "mp5_ult") => Some(include_bytes!("../assets/previews/weapons/mp5_ult.png")),
        ("weapon", "mp5_wr") => Some(include_bytes!("../assets/previews/weapons/mp5_wr.png")),
        ("weapon", "mp7a1tactic") => {
            Some(include_bytes!("../assets/previews/weapons/mp7a1tactic.png"))
        }
        ("weapon", "mp7a1tactic1") => Some(include_bytes!(
            "../assets/previews/weapons/mp7a1tactic1.png"
        )),
        ("weapon", "mp7a1tactic2") => Some(include_bytes!(
            "../assets/previews/weapons/mp7a1tactic2.png"
        )),
        ("weapon", "msr") => Some(include_bytes!("../assets/previews/weapons/msr.png")),
        ("weapon", "n2_grenade") => {
            Some(include_bytes!("../assets/previews/weapons/n2_grenade.png"))
        }
        ("weapon", "nbr_knife") => Some(include_bytes!("../assets/previews/weapons/nbr_knife.png")),
        ("weapon", "nbr_knife_c") => {
            Some(include_bytes!("../assets/previews/weapons/nbr_knife_c.png"))
        }
        ("weapon", "nbr_knife_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/nbr_knife_dragon.png"
        )),
        ("weapon", "nbr_knife_g") => {
            Some(include_bytes!("../assets/previews/weapons/nbr_knife_g.png"))
        }
        ("weapon", "nbr_knife_glory") => Some(include_bytes!(
            "../assets/previews/weapons/nbr_knife_glory.png"
        )),
        ("weapon", "nbr_knife_lego") => Some(include_bytes!(
            "../assets/previews/weapons/nbr_knife_lego.png"
        )),
        ("weapon", "nbr_knife_y") => {
            Some(include_bytes!("../assets/previews/weapons/nbr_knife_y.png"))
        }
        ("weapon", "netherworld_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/netherworld_shotgun.png"
        )),
        ("weapon", "night_owl_submachinegun") => Some(include_bytes!(
            "../assets/previews/weapons/night_owl_submachinegun.png"
        )),
        ("weapon", "night_rose_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/night_rose_rifle.png"
        )),
        ("weapon", "nonstopdance") => Some(include_bytes!(
            "../assets/previews/weapons/nonstopdance.png"
        )),
        ("weapon", "notdistinguish") => Some(include_bytes!(
            "../assets/previews/weapons/notdistinguish.png"
        )),
        ("weapon", "notdistinguish1") => Some(include_bytes!(
            "../assets/previews/weapons/notdistinguish1.png"
        )),
        ("weapon", "notdistinguish2") => Some(include_bytes!(
            "../assets/previews/weapons/notdistinguish2.png"
        )),
        ("weapon", "nova_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/nova_shotgun.png"
        )),
        ("weapon", "nova_shotgun1") => Some(include_bytes!(
            "../assets/previews/weapons/nova_shotgun1.png"
        )),
        ("weapon", "nova_shotgun2") => Some(include_bytes!(
            "../assets/previews/weapons/nova_shotgun2.png"
        )),
        ("weapon", "nunchaku") => Some(include_bytes!("../assets/previews/weapons/nunchaku.png")),
        ("weapon", "nunchakus_legend") => Some(include_bytes!(
            "../assets/previews/weapons/nunchakus_legend.png"
        )),
        ("weapon", "nunchakus_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/nunchakus_legend1.png"
        )),
        ("weapon", "nunchakus_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/nunchakus_legend2.png"
        )),
        ("weapon", "nunchaku_king") => Some(include_bytes!(
            "../assets/previews/weapons/nunchaku_king.png"
        )),
        ("weapon", "nunchaku_king1") => Some(include_bytes!(
            "../assets/previews/weapons/nunchaku_king1.png"
        )),
        ("weapon", "nurse") => Some(include_bytes!("../assets/previews/weapons/nurse.png")),
        ("weapon", "nurse_jiuwei") => Some(include_bytes!(
            "../assets/previews/weapons/nurse_jiuwei.png"
        )),
        ("weapon", "nurse_rage") => {
            Some(include_bytes!("../assets/previews/weapons/nurse_rage.png"))
        }
        ("weapon", "oar_blade") => Some(include_bytes!("../assets/previews/weapons/oar_blade.png")),
        ("weapon", "octopus") => Some(include_bytes!("../assets/previews/weapons/octopus.png")),
        ("weapon", "only") => Some(include_bytes!("../assets/previews/weapons/only.png")),
        ("weapon", "ots_tg") => Some(include_bytes!("../assets/previews/weapons/ots_tg.png")),
        ("weapon", "p28cannon") => Some(include_bytes!("../assets/previews/weapons/p28cannon.png")),
        ("weapon", "p28cannon1") => {
            Some(include_bytes!("../assets/previews/weapons/p28cannon1.png"))
        }
        ("weapon", "p28cannon2") => {
            Some(include_bytes!("../assets/previews/weapons/p28cannon2.png"))
        }
        ("weapon", "p3hero") => Some(include_bytes!("../assets/previews/weapons/p3hero.png")),
        ("weapon", "p3hero_dual_weapon") => Some(include_bytes!(
            "../assets/previews/weapons/p3hero_dual_weapon.png"
        )),
        ("weapon", "p3hero_gun_weapon") => Some(include_bytes!(
            "../assets/previews/weapons/p3hero_gun_weapon.png"
        )),
        ("weapon", "p3hero_one_hand_sword") => Some(include_bytes!(
            "../assets/previews/weapons/p3hero_one_hand_sword.png"
        )),
        ("weapon", "p3hero_polearms") => Some(include_bytes!(
            "../assets/previews/weapons/p3hero_polearms.png"
        )),
        ("weapon", "p90") => Some(include_bytes!("../assets/previews/weapons/p90.png")),
        ("weapon", "p90_hero") => Some(include_bytes!("../assets/previews/weapons/p90_hero.png")),
        ("weapon", "p90_hero1") => Some(include_bytes!("../assets/previews/weapons/p90_hero1.png")),
        ("weapon", "p90_s") => Some(include_bytes!("../assets/previews/weapons/p90_s.png")),
        ("weapon", "p90_s1") => Some(include_bytes!("../assets/previews/weapons/p90_s1.png")),
        ("weapon", "p90_s2") => Some(include_bytes!("../assets/previews/weapons/p90_s2.png")),
        ("weapon", "p90_ult") => Some(include_bytes!("../assets/previews/weapons/p90_ult.png")),
        ("weapon", "pan") => Some(include_bytes!("../assets/previews/weapons/pan.png")),
        ("weapon", "pandoraMonther") => Some(include_bytes!(
            "../assets/previews/weapons/pandoraMonther.png"
        )),
        ("weapon", "pandoraMonther_baigu") => Some(include_bytes!(
            "../assets/previews/weapons/pandoraMonther_baigu.png"
        )),
        ("weapon", "pan_g") => Some(include_bytes!("../assets/previews/weapons/pan_g.png")),
        ("weapon", "pan_ult") => Some(include_bytes!("../assets/previews/weapons/pan_ult.png")),
        ("weapon", "paperkite_knife") => Some(include_bytes!(
            "../assets/previews/weapons/paperkite_knife.png"
        )),
        ("weapon", "parasitic_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/parasitic_sniper.png"
        )),
        ("weapon", "parasitic_sniper1") => Some(include_bytes!(
            "../assets/previews/weapons/parasitic_sniper1.png"
        )),
        ("weapon", "parasitic_sniper2") => Some(include_bytes!(
            "../assets/previews/weapons/parasitic_sniper2.png"
        )),
        ("weapon", "petrified") => Some(include_bytes!("../assets/previews/weapons/petrified.png")),
        ("weapon", "petrified_kuilei") => Some(include_bytes!(
            "../assets/previews/weapons/petrified_kuilei.png"
        )),
        ("weapon", "petrified_rage") => Some(include_bytes!(
            "../assets/previews/weapons/petrified_rage.png"
        )),
        ("weapon", "phantom") => Some(include_bytes!("../assets/previews/weapons/phantom.png")),
        ("weapon", "phantom_master") => Some(include_bytes!(
            "../assets/previews/weapons/phantom_master.png"
        )),
        ("weapon", "phantom_smg") => {
            Some(include_bytes!("../assets/previews/weapons/phantom_smg.png"))
        }
        ("weapon", "phantom_smg1") => Some(include_bytes!(
            "../assets/previews/weapons/phantom_smg1.png"
        )),
        ("weapon", "phantom_smg2") => Some(include_bytes!(
            "../assets/previews/weapons/phantom_smg2.png"
        )),
        ("weapon", "phase_walker") => Some(include_bytes!(
            "../assets/previews/weapons/phase_walker.png"
        )),
        ("weapon", "phase_walker1") => Some(include_bytes!(
            "../assets/previews/weapons/phase_walker1.png"
        )),
        ("weapon", "phase_walker2") => Some(include_bytes!(
            "../assets/previews/weapons/phase_walker2.png"
        )),
        ("weapon", "photon_deformation") => Some(include_bytes!(
            "../assets/previews/weapons/photon_deformation.png"
        )),
        ("weapon", "photon_deformation1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_deformation1.png"
        )),
        ("weapon", "photon_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/photon_grenade.png"
        )),
        ("weapon", "photon_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_grenade1.png"
        )),
        ("weapon", "photon_grenade_combination") => Some(include_bytes!(
            "../assets/previews/weapons/photon_grenade_combination.png"
        )),
        ("weapon", "photon_grenade_combination1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_grenade_combination1.png"
        )),
        ("weapon", "photon_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/photon_pistol.png"
        )),
        ("weapon", "photon_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_pistol1.png"
        )),
        ("weapon", "photon_pistol_combination") => Some(include_bytes!(
            "../assets/previews/weapons/photon_pistol_combination.png"
        )),
        ("weapon", "photon_pistol_combination1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_pistol_combination1.png"
        )),
        ("weapon", "photon_sword") => Some(include_bytes!(
            "../assets/previews/weapons/photon_sword.png"
        )),
        ("weapon", "photon_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_sword1.png"
        )),
        ("weapon", "photon_sword_combination") => Some(include_bytes!(
            "../assets/previews/weapons/photon_sword_combination.png"
        )),
        ("weapon", "photon_sword_combination1") => Some(include_bytes!(
            "../assets/previews/weapons/photon_sword_combination1.png"
        )),
        ("weapon", "pickaxe") => Some(include_bytes!("../assets/previews/weapons/pickaxe.png")),
        ("weapon", "pig") => Some(include_bytes!("../assets/previews/weapons/pig.png")),
        ("weapon", "pistol_electric") => Some(include_bytes!(
            "../assets/previews/weapons/pistol_electric.png"
        )),
        ("weapon", "pistol_frozen_air") => Some(include_bytes!(
            "../assets/previews/weapons/pistol_frozen_air.png"
        )),
        ("weapon", "plunger2025_knife") => Some(include_bytes!(
            "../assets/previews/weapons/plunger2025_knife.png"
        )),
        ("weapon", "polypideMonther") => Some(include_bytes!(
            "../assets/previews/weapons/polypideMonther.png"
        )),
        ("weapon", "pp2000") => Some(include_bytes!("../assets/previews/weapons/pp2000.png")),
        ("weapon", "pp20001") => Some(include_bytes!("../assets/previews/weapons/pp20001.png")),
        ("weapon", "pp20002") => Some(include_bytes!("../assets/previews/weapons/pp20002.png")),
        ("weapon", "prism_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/prism_shotgun.png"
        )),
        ("weapon", "puppet_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/puppet_pistol.png"
        )),
        ("weapon", "pveawp") => Some(include_bytes!("../assets/previews/weapons/pveawp.png")),
        ("weapon", "pvegatling") => {
            Some(include_bytes!("../assets/previews/weapons/pvegatling.png"))
        }
        ("weapon", "pvegatling_boss1021") => Some(include_bytes!(
            "../assets/previews/weapons/pvegatling_boss1021.png"
        )),
        ("weapon", "px4") => Some(include_bytes!("../assets/previews/weapons/px4.png")),
        ("weapon", "pyramid_gemini") => Some(include_bytes!(
            "../assets/previews/weapons/pyramid_gemini.png"
        )),
        ("weapon", "pyramid_gemini1") => Some(include_bytes!(
            "../assets/previews/weapons/pyramid_gemini1.png"
        )),
        ("weapon", "pyramid_gemini2") => Some(include_bytes!(
            "../assets/previews/weapons/pyramid_gemini2.png"
        )),
        ("weapon", "qbu10") => Some(include_bytes!("../assets/previews/weapons/qbu10.png")),
        ("weapon", "qbu10_redstar") => Some(include_bytes!(
            "../assets/previews/weapons/qbu10_redstar.png"
        )),
        ("weapon", "qbu88") => Some(include_bytes!("../assets/previews/weapons/qbu88.png")),
        ("weapon", "qbz03") => Some(include_bytes!("../assets/previews/weapons/qbz03.png")),
        ("weapon", "qbz95") => Some(include_bytes!("../assets/previews/weapons/qbz95.png")),
        ("weapon", "qbz95_1st") => Some(include_bytes!("../assets/previews/weapons/qbz95_1st.png")),
        ("weapon", "qbz95_1st1") => {
            Some(include_bytes!("../assets/previews/weapons/qbz95_1st1.png"))
        }
        ("weapon", "qbz95_1st2") => {
            Some(include_bytes!("../assets/previews/weapons/qbz95_1st2.png"))
        }
        ("weapon", "qbz95_c") => Some(include_bytes!("../assets/previews/weapons/qbz95_c.png")),
        ("weapon", "qbz95_dragon") => Some(include_bytes!(
            "../assets/previews/weapons/qbz95_dragon.png"
        )),
        ("weapon", "qbz95_g") => Some(include_bytes!("../assets/previews/weapons/qbz95_g.png")),
        ("weapon", "qbz95_g1") => Some(include_bytes!("../assets/previews/weapons/qbz95_g1.png")),
        ("weapon", "qbz95_hero") => {
            Some(include_bytes!("../assets/previews/weapons/qbz95_hero.png"))
        }
        ("weapon", "qbz95_hero1") => {
            Some(include_bytes!("../assets/previews/weapons/qbz95_hero1.png"))
        }
        ("weapon", "qbz95_ht") => Some(include_bytes!("../assets/previews/weapons/qbz95_ht.png")),
        ("weapon", "qbz95_tz") => Some(include_bytes!("../assets/previews/weapons/qbz95_tz.png")),
        ("weapon", "qbz95_ult") => Some(include_bytes!("../assets/previews/weapons/qbz95_ult.png")),
        ("weapon", "qbz95_wolf") => {
            Some(include_bytes!("../assets/previews/weapons/qbz95_wolf.png"))
        }
        ("weapon", "qbz95_y") => Some(include_bytes!("../assets/previews/weapons/qbz95_y.png")),
        ("weapon", "qbz97") => Some(include_bytes!("../assets/previews/weapons/qbz97.png")),
        ("weapon", "qingniujing") => {
            Some(include_bytes!("../assets/previews/weapons/qingniujing.png"))
        }
        ("weapon", "qingniujing_mother") => Some(include_bytes!(
            "../assets/previews/weapons/qingniujing_mother.png"
        )),
        ("weapon", "qingshe") => Some(include_bytes!("../assets/previews/weapons/qingshe.png")),
        ("weapon", "qjz_89") => Some(include_bytes!("../assets/previews/weapons/qjz_89.png")),
        ("weapon", "qjz_891") => Some(include_bytes!("../assets/previews/weapons/qjz_891.png")),
        ("weapon", "qjz_892") => Some(include_bytes!("../assets/previews/weapons/qjz_892.png")),
        ("weapon", "queen") => Some(include_bytes!("../assets/previews/weapons/queen.png")),
        ("weapon", "r28rifle") => Some(include_bytes!("../assets/previews/weapons/r28rifle.png")),
        ("weapon", "r28rifle1") => Some(include_bytes!("../assets/previews/weapons/r28rifle1.png")),
        ("weapon", "r28rifle2") => Some(include_bytes!("../assets/previews/weapons/r28rifle2.png")),
        ("weapon", "rabbit_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/rabbit_grenade.png"
        )),
        ("weapon", "rabbit_hammer") => Some(include_bytes!(
            "../assets/previews/weapons/rabbit_hammer.png"
        )),
        ("weapon", "rabbit_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/rabbit_pistol.png"
        )),
        ("weapon", "radiant_edge") => Some(include_bytes!(
            "../assets/previews/weapons/radiant_edge.png"
        )),
        ("weapon", "radiant_edge1") => Some(include_bytes!(
            "../assets/previews/weapons/radiant_edge1.png"
        )),
        ("weapon", "radiant_edge2") => Some(include_bytes!(
            "../assets/previews/weapons/radiant_edge2.png"
        )),
        ("weapon", "radiant_edge3") => Some(include_bytes!(
            "../assets/previews/weapons/radiant_edge3.png"
        )),
        ("weapon", "rage") => Some(include_bytes!("../assets/previews/weapons/rage.png")),
        ("weapon", "rage_rage") => Some(include_bytes!("../assets/previews/weapons/rage_rage.png")),
        ("weapon", "rainbow_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/rainbow_pistol.png"
        )),
        ("weapon", "random_king") => {
            Some(include_bytes!("../assets/previews/weapons/random_king.png"))
        }
        ("weapon", "random_king1") => Some(include_bytes!(
            "../assets/previews/weapons/random_king1.png"
        )),
        ("weapon", "random_king2") => Some(include_bytes!(
            "../assets/previews/weapons/random_king2.png"
        )),
        ("weapon", "ray_shotgun") => {
            Some(include_bytes!("../assets/previews/weapons/ray_shotgun.png"))
        }
        ("weapon", "reaver_axe") => {
            Some(include_bytes!("../assets/previews/weapons/reaver_axe.png"))
        }
        ("weapon", "reaver_deagle") => Some(include_bytes!(
            "../assets/previews/weapons/reaver_deagle.png"
        )),
        ("weapon", "reaver_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/reaver_grenade.png"
        )),
        ("weapon", "reaver_m4") => Some(include_bytes!("../assets/previews/weapons/reaver_m4.png")),
        ("weapon", "rebirth_sword") => Some(include_bytes!(
            "../assets/previews/weapons/rebirth_sword.png"
        )),
        ("weapon", "red_laser_sword") => Some(include_bytes!(
            "../assets/previews/weapons/red_laser_sword.png"
        )),
        ("weapon", "red_sickle") => {
            Some(include_bytes!("../assets/previews/weapons/red_sickle.png"))
        }
        ("weapon", "revenge_berserker_deagle") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_deagle.png"
        )),
        ("weapon", "revenge_berserker_deagle1") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_deagle1.png"
        )),
        ("weapon", "revenge_berserker_deagle2") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_deagle2.png"
        )),
        ("weapon", "revenge_berserker_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_grenade.png"
        )),
        ("weapon", "revenge_berserker_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_grenade1.png"
        )),
        ("weapon", "revenge_berserker_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_grenade2.png"
        )),
        ("weapon", "revenge_berserker_m4a1") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_m4a1.png"
        )),
        ("weapon", "revenge_berserker_m4a1_1") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_m4a1_1.png"
        )),
        ("weapon", "revenge_berserker_m4a1_2") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_m4a1_2.png"
        )),
        ("weapon", "revenge_berserker_sword") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_sword.png"
        )),
        ("weapon", "revenge_berserker_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_sword1.png"
        )),
        ("weapon", "revenge_berserker_sword2") => Some(include_bytes!(
            "../assets/previews/weapons/revenge_berserker_sword2.png"
        )),
        ("weapon", "revolver_battle") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_battle.png"
        )),
        ("weapon", "revolver_battle1") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_battle1.png"
        )),
        ("weapon", "revolver_battle2") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_battle2.png"
        )),
        ("weapon", "revolver_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_redflash.png"
        )),
        ("weapon", "revolver_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_redflash1.png"
        )),
        ("weapon", "revolver_tube") => Some(include_bytes!(
            "../assets/previews/weapons/revolver_tube.png"
        )),
        ("weapon", "rider_dou_gun") => Some(include_bytes!(
            "../assets/previews/weapons/rider_dou_gun.png"
        )),
        ("weapon", "rider_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/rider_grenade.png"
        )),
        ("weapon", "rider_slingshot") => Some(include_bytes!(
            "../assets/previews/weapons/rider_slingshot.png"
        )),
        ("weapon", "rider_sword") => {
            Some(include_bytes!("../assets/previews/weapons/rider_sword.png"))
        }
        ("weapon", "rifle_opticor") => Some(include_bytes!(
            "../assets/previews/weapons/rifle_opticor.png"
        )),
        ("weapon", "rifle_phoenix") => Some(include_bytes!(
            "../assets/previews/weapons/rifle_phoenix.png"
        )),
        ("weapon", "ring_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/ring_grenade.png"
        )),
        ("weapon", "riotshield") => {
            Some(include_bytes!("../assets/previews/weapons/riotshield.png"))
        }
        ("weapon", "riotshield1") => {
            Some(include_bytes!("../assets/previews/weapons/riotshield1.png"))
        }
        ("weapon", "ripper") => Some(include_bytes!("../assets/previews/weapons/ripper.png")),
        ("weapon", "ripper_g") => Some(include_bytes!("../assets/previews/weapons/ripper_g.png")),
        ("weapon", "roadblock_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/roadblock_pistol.png"
        )),
        ("weapon", "roar_sniper_hero") => Some(include_bytes!(
            "../assets/previews/weapons/roar_sniper_hero.png"
        )),
        ("weapon", "roar_sniper_hero1") => Some(include_bytes!(
            "../assets/previews/weapons/roar_sniper_hero1.png"
        )),
        ("weapon", "rose_spear") => {
            Some(include_bytes!("../assets/previews/weapons/rose_spear.png"))
        }
        ("weapon", "rose_sword") => {
            Some(include_bytes!("../assets/previews/weapons/rose_sword.png"))
        }
        ("weapon", "rouge_card_hand") => Some(include_bytes!(
            "../assets/previews/weapons/rouge_card_hand.png"
        )),
        ("weapon", "rouge_mock") => {
            Some(include_bytes!("../assets/previews/weapons/rouge_mock.png"))
        }
        ("weapon", "rpgcaptaionjz") => Some(include_bytes!(
            "../assets/previews/weapons/rpgcaptaionjz.png"
        )),
        ("weapon", "rpgcaptaionyc") => Some(include_bytes!(
            "../assets/previews/weapons/rpgcaptaionyc.png"
        )),
        ("weapon", "rpg_7") => Some(include_bytes!("../assets/previews/weapons/rpg_7.png")),
        ("weapon", "rpg_7_1") => Some(include_bytes!("../assets/previews/weapons/rpg_7_1.png")),
        ("weapon", "rpg_7_2") => Some(include_bytes!("../assets/previews/weapons/rpg_7_2.png")),
        ("weapon", "rpg_by_parasitism") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_by_parasitism.png"
        )),
        ("weapon", "rpg_by_parasitism_rage") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_by_parasitism_rage.png"
        )),
        ("weapon", "rpg_captain_dp") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_captain_dp.png"
        )),
        ("weapon", "rpg_dlsj") => Some(include_bytes!("../assets/previews/weapons/rpg_dlsj.png")),
        ("weapon", "rpg_lssd") => Some(include_bytes!("../assets/previews/weapons/rpg_lssd.png")),
        ("weapon", "rpg_poke_ball") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_poke_ball.png"
        )),
        ("weapon", "rpg_redflash") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_redflash.png"
        )),
        ("weapon", "rpg_redflash1") => Some(include_bytes!(
            "../assets/previews/weapons/rpg_redflash1.png"
        )),
        ("weapon", "rpk") => Some(include_bytes!("../assets/previews/weapons/rpk.png")),
        ("weapon", "rpk_an") => Some(include_bytes!("../assets/previews/weapons/rpk_an.png")),
        ("weapon", "rpk_bone") => Some(include_bytes!("../assets/previews/weapons/rpk_bone.png")),
        ("weapon", "rpk_domination") => Some(include_bytes!(
            "../assets/previews/weapons/rpk_domination.png"
        )),
        ("weapon", "rpk_g") => Some(include_bytes!("../assets/previews/weapons/rpk_g.png")),
        ("weapon", "rpk_hero") => Some(include_bytes!("../assets/previews/weapons/rpk_hero.png")),
        ("weapon", "rpk_hero1") => Some(include_bytes!("../assets/previews/weapons/rpk_hero1.png")),
        ("weapon", "rpk_legend_ct") => Some(include_bytes!(
            "../assets/previews/weapons/rpk_legend_ct.png"
        )),
        ("weapon", "rpk_legend_t") => Some(include_bytes!(
            "../assets/previews/weapons/rpk_legend_t.png"
        )),
        ("weapon", "rpk_rage") => Some(include_bytes!("../assets/previews/weapons/rpk_rage.png")),
        ("weapon", "rpk_s") => Some(include_bytes!("../assets/previews/weapons/rpk_s.png")),
        ("weapon", "rpk_y") => Some(include_bytes!("../assets/previews/weapons/rpk_y.png")),
        ("weapon", "s17_m4a1_king") => Some(include_bytes!(
            "../assets/previews/weapons/s17_m4a1_king.png"
        )),
        ("weapon", "s2_copper_95") => Some(include_bytes!(
            "../assets/previews/weapons/s2_copper_95.png"
        )),
        ("weapon", "s2_silver_95") => Some(include_bytes!(
            "../assets/previews/weapons/s2_silver_95.png"
        )),
        ("weapon", "s3_copper_awm") => Some(include_bytes!(
            "../assets/previews/weapons/s3_copper_awm.png"
        )),
        ("weapon", "s3_silver_awm") => Some(include_bytes!(
            "../assets/previews/weapons/s3_silver_awm.png"
        )),
        ("weapon", "s4_copper_deagle") => Some(include_bytes!(
            "../assets/previews/weapons/s4_copper_deagle.png"
        )),
        ("weapon", "s4_silver_deagle") => Some(include_bytes!(
            "../assets/previews/weapons/s4_silver_deagle.png"
        )),
        ("weapon", "sa58_future") => {
            Some(include_bytes!("../assets/previews/weapons/sa58_future.png"))
        }
        ("weapon", "salute_gun") => {
            Some(include_bytes!("../assets/previews/weapons/salute_gun.png"))
        }
        ("weapon", "samurai_sword") => Some(include_bytes!(
            "../assets/previews/weapons/samurai_sword.png"
        )),
        ("weapon", "samurai_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/samurai_sword1.png"
        )),
        ("weapon", "samurai_sword2") => Some(include_bytes!(
            "../assets/previews/weapons/samurai_sword2.png"
        )),
        ("weapon", "sanDan_hero") => {
            Some(include_bytes!("../assets/previews/weapons/sanDan_hero.png"))
        }
        ("weapon", "sanDan_hero1") => Some(include_bytes!(
            "../assets/previews/weapons/sanDan_hero1.png"
        )),
        ("weapon", "saw") => Some(include_bytes!("../assets/previews/weapons/saw.png")),
        ("weapon", "sawed_pirate") => Some(include_bytes!(
            "../assets/previews/weapons/sawed_pirate.png"
        )),
        ("weapon", "saw_bone") => Some(include_bytes!("../assets/previews/weapons/saw_bone.png")),
        ("weapon", "saw_cut") => Some(include_bytes!("../assets/previews/weapons/saw_cut.png")),
        ("weapon", "saw_rage") => Some(include_bytes!("../assets/previews/weapons/saw_rage.png")),
        ("weapon", "scar") => Some(include_bytes!("../assets/previews/weapons/scar.png")),
        ("weapon", "scar_77") => Some(include_bytes!("../assets/previews/weapons/scar_77.png")),
        ("weapon", "scar_an") => Some(include_bytes!("../assets/previews/weapons/scar_an.png")),
        ("weapon", "scar_c") => Some(include_bytes!("../assets/previews/weapons/scar_c.png")),
        ("weapon", "scar_dragon") => {
            Some(include_bytes!("../assets/previews/weapons/scar_dragon.png"))
        }
        ("weapon", "scar_g") => Some(include_bytes!("../assets/previews/weapons/scar_g.png")),
        ("weapon", "scar_g1") => Some(include_bytes!("../assets/previews/weapons/scar_g1.png")),
        ("weapon", "scar_h") => Some(include_bytes!("../assets/previews/weapons/scar_h.png")),
        ("weapon", "scar_h1") => Some(include_bytes!("../assets/previews/weapons/scar_h1.png")),
        ("weapon", "scar_h2") => Some(include_bytes!("../assets/previews/weapons/scar_h2.png")),
        ("weapon", "scar_kingk") => {
            Some(include_bytes!("../assets/previews/weapons/scar_kingk.png"))
        }
        ("weapon", "scar_kingk1") => {
            Some(include_bytes!("../assets/previews/weapons/scar_kingk1.png"))
        }
        ("weapon", "scar_legend") => {
            Some(include_bytes!("../assets/previews/weapons/scar_legend.png"))
        }
        ("weapon", "scar_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/scar_legend1.png"
        )),
        ("weapon", "scar_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/scar_legend2.png"
        )),
        ("weapon", "scar_legend3") => Some(include_bytes!(
            "../assets/previews/weapons/scar_legend3.png"
        )),
        ("weapon", "scar_md") => Some(include_bytes!("../assets/previews/weapons/scar_md.png")),
        ("weapon", "scar_pro") => Some(include_bytes!("../assets/previews/weapons/scar_pro.png")),
        ("weapon", "scar_s") => Some(include_bytes!("../assets/previews/weapons/scar_s.png")),
        ("weapon", "scar_ult") => Some(include_bytes!("../assets/previews/weapons/scar_ult.png")),
        ("weapon", "scar_y") => Some(include_bytes!("../assets/previews/weapons/scar_y.png")),
        ("weapon", "scimitar") => Some(include_bytes!("../assets/previews/weapons/scimitar.png")),
        ("weapon", "scout") => Some(include_bytes!("../assets/previews/weapons/scout.png")),
        ("weapon", "scout_ult") => Some(include_bytes!("../assets/previews/weapons/scout_ult.png")),
        ("weapon", "screaming_chicken_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/screaming_chicken_grenade.png"
        )),
        ("weapon", "scythe") => Some(include_bytes!("../assets/previews/weapons/scythe.png")),
        ("weapon", "sea_of_shark") => Some(include_bytes!(
            "../assets/previews/weapons/sea_of_shark.png"
        )),
        ("weapon", "sea_of_shark1") => Some(include_bytes!(
            "../assets/previews/weapons/sea_of_shark1.png"
        )),
        ("weapon", "sea_of_shark2") => Some(include_bytes!(
            "../assets/previews/weapons/sea_of_shark2.png"
        )),
        ("weapon", "self_discipline_gun_controller") => Some(include_bytes!(
            "../assets/previews/weapons/self_discipline_gun_controller.png"
        )),
        ("weapon", "selfexplosion") => Some(include_bytes!(
            "../assets/previews/weapons/selfexplosion.png"
        )),
        ("weapon", "sg551") => Some(include_bytes!("../assets/previews/weapons/sg551.png")),
        ("weapon", "sg551_ult") => Some(include_bytes!("../assets/previews/weapons/sg551_ult.png")),
        ("weapon", "shadowless_sword") => Some(include_bytes!(
            "../assets/previews/weapons/shadowless_sword.png"
        )),
        ("weapon", "shadow_demon") => Some(include_bytes!(
            "../assets/previews/weapons/shadow_demon.png"
        )),
        ("weapon", "shadow_demon_archer") => Some(include_bytes!(
            "../assets/previews/weapons/shadow_demon_archer.png"
        )),
        ("weapon", "shadow_demon_bayonet") => Some(include_bytes!(
            "../assets/previews/weapons/shadow_demon_bayonet.png"
        )),
        ("weapon", "shadow_demon_sickle") => Some(include_bytes!(
            "../assets/previews/weapons/shadow_demon_sickle.png"
        )),
        ("weapon", "shak12") => Some(include_bytes!("../assets/previews/weapons/shak12.png")),
        ("weapon", "shak12_1") => Some(include_bytes!("../assets/previews/weapons/shak12_1.png")),
        ("weapon", "shak12_2") => Some(include_bytes!("../assets/previews/weapons/shak12_2.png")),
        ("weapon", "shak12_3") => Some(include_bytes!("../assets/previews/weapons/shak12_3.png")),
        ("weapon", "shield_cannon") => Some(include_bytes!(
            "../assets/previews/weapons/shield_cannon.png"
        )),
        ("weapon", "shield_cannon1") => Some(include_bytes!(
            "../assets/previews/weapons/shield_cannon1.png"
        )),
        ("weapon", "shield_cannon2") => Some(include_bytes!(
            "../assets/previews/weapons/shield_cannon2.png"
        )),
        ("weapon", "shield_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/shield_pistol.png"
        )),
        ("weapon", "shield_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/shield_shotgun.png"
        )),
        ("weapon", "shield_shotgun1") => Some(include_bytes!(
            "../assets/previews/weapons/shield_shotgun1.png"
        )),
        ("weapon", "shield_shotgun2") => Some(include_bytes!(
            "../assets/previews/weapons/shield_shotgun2.png"
        )),
        ("weapon", "shotgun_3_barrel") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_3_barrel.png"
        )),
        ("weapon", "shotgun_laser") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_laser.png"
        )),
        ("weapon", "shotgun_laser1") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_laser1.png"
        )),
        ("weapon", "shotgun_laser_lite") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_laser_lite.png"
        )),
        ("weapon", "shotgun_legend") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_legend.png"
        )),
        ("weapon", "shotgun_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_legend1.png"
        )),
        ("weapon", "shotgun_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_legend2.png"
        )),
        ("weapon", "shotgun_paila") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_paila.png"
        )),
        ("weapon", "shotgun_pistol_stone") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_pistol_stone.png"
        )),
        ("weapon", "shotgun_walker") => Some(include_bytes!(
            "../assets/previews/weapons/shotgun_walker.png"
        )),
        ("weapon", "shovel") => Some(include_bytes!("../assets/previews/weapons/shovel.png")),
        ("weapon", "shovel_g") => Some(include_bytes!("../assets/previews/weapons/shovel_g.png")),
        ("weapon", "shovel_rage") => {
            Some(include_bytes!("../assets/previews/weapons/shovel_rage.png"))
        }
        ("weapon", "shutter_flashbang") => Some(include_bytes!(
            "../assets/previews/weapons/shutter_flashbang.png"
        )),
        ("weapon", "shutter_flashbang1") => Some(include_bytes!(
            "../assets/previews/weapons/shutter_flashbang1.png"
        )),
        ("weapon", "shutter_flashbang2") => Some(include_bytes!(
            "../assets/previews/weapons/shutter_flashbang2.png"
        )),
        ("weapon", "sirens_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/sirens_pistol.png"
        )),
        ("weapon", "sirens_pistol1") => Some(include_bytes!(
            "../assets/previews/weapons/sirens_pistol1.png"
        )),
        ("weapon", "sirens_pistol2") => Some(include_bytes!(
            "../assets/previews/weapons/sirens_pistol2.png"
        )),
        ("weapon", "skeleton_knife") => Some(include_bytes!(
            "../assets/previews/weapons/skeleton_knife.png"
        )),
        ("weapon", "skydeagle") => Some(include_bytes!("../assets/previews/weapons/skydeagle.png")),
        ("weapon", "skydeagle1") => {
            Some(include_bytes!("../assets/previews/weapons/skydeagle1.png"))
        }
        ("weapon", "sky_dome_beacon") => Some(include_bytes!(
            "../assets/previews/weapons/sky_dome_beacon.png"
        )),
        ("weapon", "sky_dome_beacon1") => Some(include_bytes!(
            "../assets/previews/weapons/sky_dome_beacon1.png"
        )),
        ("weapon", "sky_dome_beacon2") => Some(include_bytes!(
            "../assets/previews/weapons/sky_dome_beacon2.png"
        )),
        ("weapon", "sky_sr") => Some(include_bytes!("../assets/previews/weapons/sky_sr.png")),
        ("weapon", "slime_gun") => Some(include_bytes!("../assets/previews/weapons/slime_gun.png")),
        ("weapon", "slingshot") => Some(include_bytes!("../assets/previews/weapons/slingshot.png")),
        ("weapon", "slingshot_bone") => Some(include_bytes!(
            "../assets/previews/weapons/slingshot_bone.png"
        )),
        ("weapon", "slingshot_g") => {
            Some(include_bytes!("../assets/previews/weapons/slingshot_g.png"))
        }
        ("weapon", "slingshot_g_test") => Some(include_bytes!(
            "../assets/previews/weapons/slingshot_g_test.png"
        )),
        ("weapon", "smaw") => Some(include_bytes!("../assets/previews/weapons/smaw.png")),
        ("weapon", "smaw_rpg") => Some(include_bytes!("../assets/previews/weapons/smaw_rpg.png")),
        ("weapon", "smoke") => Some(include_bytes!("../assets/previews/weapons/smoke.png")),
        ("weapon", "smoke_ult") => Some(include_bytes!("../assets/previews/weapons/smoke_ult.png")),
        ("weapon", "snaker") => Some(include_bytes!("../assets/previews/weapons/snaker.png")),
        ("weapon", "snake_chain_sword") => Some(include_bytes!(
            "../assets/previews/weapons/snake_chain_sword.png"
        )),
        ("weapon", "snake_chain_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/snake_chain_sword1.png"
        )),
        ("weapon", "snake_chain_sword2") => Some(include_bytes!(
            "../assets/previews/weapons/snake_chain_sword2.png"
        )),
        ("weapon", "snake_doun") => {
            Some(include_bytes!("../assets/previews/weapons/snake_doun.png"))
        }
        ("weapon", "sniperise") => Some(include_bytes!("../assets/previews/weapons/sniperise.png")),
        ("weapon", "sniper_guardian") => Some(include_bytes!(
            "../assets/previews/weapons/sniper_guardian.png"
        )),
        ("weapon", "snowball") => Some(include_bytes!("../assets/previews/weapons/snowball.png")),
        ("weapon", "snowball_gun") => Some(include_bytes!(
            "../assets/previews/weapons/snowball_gun.png"
        )),
        ("weapon", "sohg") => Some(include_bytes!("../assets/previews/weapons/sohg.png")),
        ("weapon", "sohg1") => Some(include_bytes!("../assets/previews/weapons/sohg1.png")),
        ("weapon", "sohg2") => Some(include_bytes!("../assets/previews/weapons/sohg2.png")),
        ("weapon", "soul_smg") => Some(include_bytes!("../assets/previews/weapons/soul_smg.png")),
        ("weapon", "space_master_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/space_master_rifle.png"
        )),
        ("weapon", "spanner") => Some(include_bytes!("../assets/previews/weapons/spanner.png")),
        ("weapon", "spas12") => Some(include_bytes!("../assets/previews/weapons/spas12.png")),
        ("weapon", "spas12_1") => Some(include_bytes!("../assets/previews/weapons/spas12_1.png")),
        ("weapon", "spas12_2") => Some(include_bytes!("../assets/previews/weapons/spas12_2.png")),
        ("weapon", "spas12_ult") => {
            Some(include_bytes!("../assets/previews/weapons/spas12_ult.png"))
        }
        ("weapon", "spear_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/spear_sniper.png"
        )),
        ("weapon", "spiderexplosion") => Some(include_bytes!(
            "../assets/previews/weapons/spiderexplosion.png"
        )),
        ("weapon", "spider_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/spider_grenade.png"
        )),
        ("weapon", "spike_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/spike_rifle.png"))
        }
        ("weapon", "spirits_sword") => Some(include_bytes!(
            "../assets/previews/weapons/spirits_sword.png"
        )),
        ("weapon", "spirits_sword1") => Some(include_bytes!(
            "../assets/previews/weapons/spirits_sword1.png"
        )),
        ("weapon", "spirits_sword2") => Some(include_bytes!(
            "../assets/previews/weapons/spirits_sword2.png"
        )),
        ("weapon", "ssg08") => Some(include_bytes!("../assets/previews/weapons/ssg08.png")),
        ("weapon", "starring_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/starring_rifle.png"
        )),
        ("weapon", "starvortex_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/starvortex_pistol.png"
        )),
        ("weapon", "star_debris_pistol_legend") => Some(include_bytes!(
            "../assets/previews/weapons/star_debris_pistol_legend.png"
        )),
        ("weapon", "star_debris_pistol_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/star_debris_pistol_legend1.png"
        )),
        ("weapon", "star_debris_pistol_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/star_debris_pistol_legend2.png"
        )),
        ("weapon", "stirling") => Some(include_bytes!("../assets/previews/weapons/stirling.png")),
        ("weapon", "storm_heroes") => Some(include_bytes!(
            "../assets/previews/weapons/storm_heroes.png"
        )),
        ("weapon", "storm_heroes1") => Some(include_bytes!(
            "../assets/previews/weapons/storm_heroes1.png"
        )),
        ("weapon", "storm_mg") => Some(include_bytes!("../assets/previews/weapons/storm_mg.png")),
        ("weapon", "storm_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/storm_shotgun.png"
        )),
        ("weapon", "strike_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/strike_pistol.png"
        )),
        ("weapon", "sun_sg") => Some(include_bytes!("../assets/previews/weapons/sun_sg.png")),
        ("weapon", "svd") => Some(include_bytes!("../assets/previews/weapons/svd.png")),
        ("weapon", "svi1911") => Some(include_bytes!("../assets/previews/weapons/svi1911.png")),
        ("weapon", "sw_95") => Some(include_bytes!("../assets/previews/weapons/sw_95.png")),
        ("weapon", "sway_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/sway_shotgun.png"
        )),
        ("weapon", "sway_shotgun1") => Some(include_bytes!(
            "../assets/previews/weapons/sway_shotgun1.png"
        )),
        ("weapon", "sway_shotgun2") => Some(include_bytes!(
            "../assets/previews/weapons/sway_shotgun2.png"
        )),
        ("weapon", "sweet_slingshot") => Some(include_bytes!(
            "../assets/previews/weapons/sweet_slingshot.png"
        )),
        ("weapon", "sword_heaven") => Some(include_bytes!(
            "../assets/previews/weapons/sword_heaven.png"
        )),
        ("weapon", "sword_heaven_judge") => Some(include_bytes!(
            "../assets/previews/weapons/sword_heaven_judge.png"
        )),
        ("weapon", "sword_hell") => {
            Some(include_bytes!("../assets/previews/weapons/sword_hell.png"))
        }
        ("weapon", "sword_hell_snake") => Some(include_bytes!(
            "../assets/previews/weapons/sword_hell_snake.png"
        )),
        ("weapon", "sword_hell_snake1") => Some(include_bytes!(
            "../assets/previews/weapons/sword_hell_snake1.png"
        )),
        ("weapon", "sword_hell_snake2") => Some(include_bytes!(
            "../assets/previews/weapons/sword_hell_snake2.png"
        )),
        ("weapon", "sword_whip") => {
            Some(include_bytes!("../assets/previews/weapons/sword_whip.png"))
        }
        ("weapon", "sybil_hand") => {
            Some(include_bytes!("../assets/previews/weapons/sybil_hand.png"))
        }
        ("weapon", "taiyi_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/taiyi_grenade.png"
        )),
        ("weapon", "taiyi_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/taiyi_grenade1.png"
        )),
        ("weapon", "taiyi_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/taiyi_grenade2.png"
        )),
        ("weapon", "tanghulu") => Some(include_bytes!("../assets/previews/weapons/tanghulu.png")),
        ("weapon", "tangyuan") => Some(include_bytes!("../assets/previews/weapons/tangyuan.png")),
        ("weapon", "tar21") => Some(include_bytes!("../assets/previews/weapons/tar21.png")),
        ("weapon", "tenth_moon_cake_blade") => Some(include_bytes!(
            "../assets/previews/weapons/tenth_moon_cake_blade.png"
        )),
        ("weapon", "the_book_of_order") => Some(include_bytes!(
            "../assets/previews/weapons/the_book_of_order.png"
        )),
        ("weapon", "the_book_of_order1") => Some(include_bytes!(
            "../assets/previews/weapons/the_book_of_order1.png"
        )),
        ("weapon", "the_book_of_order2") => Some(include_bytes!(
            "../assets/previews/weapons/the_book_of_order2.png"
        )),
        ("weapon", "thirteen_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/thirteen_pistol.png"
        )),
        ("weapon", "thomson") => Some(include_bytes!("../assets/previews/weapons/thomson.png")),
        ("weapon", "thomson_g") => Some(include_bytes!("../assets/previews/weapons/thomson_g.png")),
        ("weapon", "thor_hammer") => {
            Some(include_bytes!("../assets/previews/weapons/thor_hammer.png"))
        }
        ("weapon", "thor_hammer1") => Some(include_bytes!(
            "../assets/previews/weapons/thor_hammer1.png"
        )),
        ("weapon", "thor_hammer2") => Some(include_bytes!(
            "../assets/previews/weapons/thor_hammer2.png"
        )),
        ("weapon", "thor_hammer3") => Some(include_bytes!(
            "../assets/previews/weapons/thor_hammer3.png"
        )),
        ("weapon", "thunderous") => {
            Some(include_bytes!("../assets/previews/weapons/thunderous.png"))
        }
        ("weapon", "thunderous1") => {
            Some(include_bytes!("../assets/previews/weapons/thunderous1.png"))
        }
        ("weapon", "thunder_boom") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_boom.png"
        )),
        ("weapon", "thunder_boom1") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_boom1.png"
        )),
        ("weapon", "thunder_boom2") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_boom2.png"
        )),
        ("weapon", "thunder_hammer") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_hammer.png"
        )),
        ("weapon", "thunder_hammer1") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_hammer1.png"
        )),
        ("weapon", "thunder_hammer2") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_hammer2.png"
        )),
        ("weapon", "thunder_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_machinegun.png"
        )),
        ("weapon", "thunder_scepter") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_scepter.png"
        )),
        ("weapon", "thunder_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_shotgun.png"
        )),
        ("weapon", "thunder_submachinegun_legend") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_submachinegun_legend.png"
        )),
        ("weapon", "thunder_submachinegun_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_submachinegun_legend1.png"
        )),
        ("weapon", "thunder_submachinegun_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/thunder_submachinegun_legend2.png"
        )),
        ("weapon", "tianping_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/tianping_grenade.png"
        )),
        ("weapon", "tianping_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/tianping_grenade1.png"
        )),
        ("weapon", "tianping_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/tianping_grenade2.png"
        )),
        ("weapon", "tigerfist") => Some(include_bytes!("../assets/previews/weapons/tigerfist.png")),
        ("weapon", "tiger_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/tiger_rifle.png"))
        }
        ("weapon", "tiger_teeth_fight_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/tiger_teeth_fight_dagger.png"
        )),
        ("weapon", "tmp_pistol") => {
            Some(include_bytes!("../assets/previews/weapons/tmp_pistol.png"))
        }
        ("weapon", "tmp_pistol1") => {
            Some(include_bytes!("../assets/previews/weapons/tmp_pistol1.png"))
        }
        ("weapon", "tmp_tactics") => {
            Some(include_bytes!("../assets/previews/weapons/tmp_tactics.png"))
        }
        ("weapon", "tmp_tactics1") => Some(include_bytes!(
            "../assets/previews/weapons/tmp_tactics1.png"
        )),
        ("weapon", "tmp_tactics2") => Some(include_bytes!(
            "../assets/previews/weapons/tmp_tactics2.png"
        )),
        ("weapon", "top_whip") => Some(include_bytes!("../assets/previews/weapons/top_whip.png")),
        ("weapon", "tp82_hell") => Some(include_bytes!("../assets/previews/weapons/tp82_hell.png")),
        ("weapon", "tp82_hell1") => {
            Some(include_bytes!("../assets/previews/weapons/tp82_hell1.png"))
        }
        ("weapon", "tp82_hell2") => {
            Some(include_bytes!("../assets/previews/weapons/tp82_hell2.png"))
        }
        ("weapon", "tps_test") => Some(include_bytes!("../assets/previews/weapons/tps_test.png")),
        ("weapon", "trans_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/trans_machinegun.png"
        )),
        ("weapon", "trick_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/trick_dagger.png"
        )),
        ("weapon", "trick_glass_darts") => Some(include_bytes!(
            "../assets/previews/weapons/trick_glass_darts.png"
        )),
        ("weapon", "trident_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/trident_pistol.png"
        )),
        ("weapon", "twelve_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/twelve_pistol.png"
        )),
        ("weapon", "twine") => Some(include_bytes!("../assets/previews/weapons/twine.png")),
        ("weapon", "twine_rage") => {
            Some(include_bytes!("../assets/previews/weapons/twine_rage.png"))
        }
        ("weapon", "twins_infinity") => Some(include_bytes!(
            "../assets/previews/weapons/twins_infinity.png"
        )),
        ("weapon", "twins_infinity1") => Some(include_bytes!(
            "../assets/previews/weapons/twins_infinity1.png"
        )),
        ("weapon", "twins_infinity2") => Some(include_bytes!(
            "../assets/previews/weapons/twins_infinity2.png"
        )),
        ("weapon", "type56") => Some(include_bytes!("../assets/previews/weapons/type56.png")),
        ("weapon", "type91_dagger") => Some(include_bytes!(
            "../assets/previews/weapons/type91_dagger.png"
        )),
        ("weapon", "type91_dagger1") => Some(include_bytes!(
            "../assets/previews/weapons/type91_dagger1.png"
        )),
        ("weapon", "type91_dagger2") => Some(include_bytes!(
            "../assets/previews/weapons/type91_dagger2.png"
        )),
        ("weapon", "type91_dagger3") => Some(include_bytes!(
            "../assets/previews/weapons/type91_dagger3.png"
        )),
        ("weapon", "type97") => Some(include_bytes!("../assets/previews/weapons/type97.png")),
        ("weapon", "uav") => Some(include_bytes!("../assets/previews/weapons/uav.png")),
        ("weapon", "ultimax100") => {
            Some(include_bytes!("../assets/previews/weapons/ultimax100.png"))
        }
        ("weapon", "ultimax100_1") => Some(include_bytes!(
            "../assets/previews/weapons/ultimax100_1.png"
        )),
        ("weapon", "ultimax100_2") => Some(include_bytes!(
            "../assets/previews/weapons/ultimax100_2.png"
        )),
        ("weapon", "umbrella_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/umbrella_shotgun.png"
        )),
        ("weapon", "ump45") => Some(include_bytes!("../assets/previews/weapons/ump45.png")),
        ("weapon", "ump45_ult") => Some(include_bytes!("../assets/previews/weapons/ump45_ult.png")),
        ("weapon", "usp45") => Some(include_bytes!("../assets/previews/weapons/usp45.png")),
        ("weapon", "usp45_bilibili") => Some(include_bytes!(
            "../assets/previews/weapons/usp45_bilibili.png"
        )),
        ("weapon", "usp45_devil") => {
            Some(include_bytes!("../assets/previews/weapons/usp45_devil.png"))
        }
        ("weapon", "usp45_devil1") => Some(include_bytes!(
            "../assets/previews/weapons/usp45_devil1.png"
        )),
        ("weapon", "usp45_devil2") => Some(include_bytes!(
            "../assets/previews/weapons/usp45_devil2.png"
        )),
        ("weapon", "usp45_ult") => Some(include_bytes!("../assets/previews/weapons/usp45_ult.png")),
        ("weapon", "usp_neptune") => {
            Some(include_bytes!("../assets/previews/weapons/usp_neptune.png"))
        }
        ("weapon", "usp_pro") => Some(include_bytes!("../assets/previews/weapons/usp_pro.png")),
        ("weapon", "uts15") => Some(include_bytes!("../assets/previews/weapons/uts15.png")),
        ("weapon", "uts151") => Some(include_bytes!("../assets/previews/weapons/uts151.png")),
        ("weapon", "uts152") => Some(include_bytes!("../assets/previews/weapons/uts152.png")),
        ("weapon", "venom_knife") => {
            Some(include_bytes!("../assets/previews/weapons/venom_knife.png"))
        }
        ("weapon", "verdict_legend") => Some(include_bytes!(
            "../assets/previews/weapons/verdict_legend.png"
        )),
        ("weapon", "verdict_legend1") => Some(include_bytes!(
            "../assets/previews/weapons/verdict_legend1.png"
        )),
        ("weapon", "verdict_legend2") => Some(include_bytes!(
            "../assets/previews/weapons/verdict_legend2.png"
        )),
        ("weapon", "vinesheart_sniper") => Some(include_bytes!(
            "../assets/previews/weapons/vinesheart_sniper.png"
        )),
        ("weapon", "viper") => Some(include_bytes!("../assets/previews/weapons/viper.png")),
        ("weapon", "viper_rage") => {
            Some(include_bytes!("../assets/previews/weapons/viper_rage.png"))
        }
        ("weapon", "vip_grenade") => {
            Some(include_bytes!("../assets/previews/weapons/vip_grenade.png"))
        }
        ("weapon", "vip_knife") => Some(include_bytes!("../assets/previews/weapons/vip_knife.png")),
        ("weapon", "void_jump") => Some(include_bytes!("../assets/previews/weapons/void_jump.png")),
        ("weapon", "void_link") => Some(include_bytes!("../assets/previews/weapons/void_link.png")),
        ("weapon", "void_spear") => {
            Some(include_bytes!("../assets/previews/weapons/void_spear.png"))
        }
        ("weapon", "volcano") => Some(include_bytes!("../assets/previews/weapons/volcano.png")),
        ("weapon", "vss") => Some(include_bytes!("../assets/previews/weapons/vss.png")),
        ("weapon", "vss_1") => Some(include_bytes!("../assets/previews/weapons/vss_1.png")),
        ("weapon", "vss_2") => Some(include_bytes!("../assets/previews/weapons/vss_2.png")),
        ("weapon", "vss_ult") => Some(include_bytes!("../assets/previews/weapons/vss_ult.png")),
        ("weapon", "water_shotgun") => Some(include_bytes!(
            "../assets/previews/weapons/water_shotgun.png"
        )),
        ("weapon", "wave_machinegun") => Some(include_bytes!(
            "../assets/previews/weapons/wave_machinegun.png"
        )),
        ("weapon", "weird_transform_pistol") => Some(include_bytes!(
            "../assets/previews/weapons/weird_transform_pistol.png"
        )),
        ("weapon", "whitetiger") => {
            Some(include_bytes!("../assets/previews/weapons/whitetiger.png"))
        }
        ("weapon", "whitetiger1") => {
            Some(include_bytes!("../assets/previews/weapons/whitetiger1.png"))
        }
        ("weapon", "white_sword_gun") => Some(include_bytes!(
            "../assets/previews/weapons/white_sword_gun.png"
        )),
        ("weapon", "white_sword_gun1") => Some(include_bytes!(
            "../assets/previews/weapons/white_sword_gun1.png"
        )),
        ("weapon", "white_sword_gun2") => Some(include_bytes!(
            "../assets/previews/weapons/white_sword_gun2.png"
        )),
        ("weapon", "windmill") => Some(include_bytes!("../assets/previews/weapons/windmill.png")),
        ("weapon", "windward") => Some(include_bytes!("../assets/previews/weapons/windward.png")),
        ("weapon", "wind_axe") => Some(include_bytes!("../assets/previews/weapons/wind_axe.png")),
        ("weapon", "wind_boxer") => {
            Some(include_bytes!("../assets/previews/weapons/wind_boxer.png"))
        }
        ("weapon", "wind_spirit") => {
            Some(include_bytes!("../assets/previews/weapons/wind_spirit.png"))
        }
        ("weapon", "wind_trans_shortbow") => Some(include_bytes!(
            "../assets/previews/weapons/wind_trans_shortbow.png"
        )),
        ("weapon", "wind_trans_shortbow1") => Some(include_bytes!(
            "../assets/previews/weapons/wind_trans_shortbow1.png"
        )),
        ("weapon", "wind_trans_shortbow2") => Some(include_bytes!(
            "../assets/previews/weapons/wind_trans_shortbow2.png"
        )),
        ("weapon", "wings_smg") => Some(include_bytes!("../assets/previews/weapons/wings_smg.png")),
        ("weapon", "wing_knife") => {
            Some(include_bytes!("../assets/previews/weapons/wing_knife.png"))
        }
        ("weapon", "wolfclaw") => Some(include_bytes!("../assets/previews/weapons/wolfclaw.png")),
        ("weapon", "wolfclaw1") => Some(include_bytes!("../assets/previews/weapons/wolfclaw1.png")),
        ("weapon", "wolfclaw2") => Some(include_bytes!("../assets/previews/weapons/wolfclaw2.png")),
        ("weapon", "wolf_tooth") => {
            Some(include_bytes!("../assets/previews/weapons/wolf_tooth.png"))
        }
        ("weapon", "wooduan_flag") => Some(include_bytes!(
            "../assets/previews/weapons/wooduan_flag.png"
        )),
        ("weapon", "work_hammer") => {
            Some(include_bytes!("../assets/previews/weapons/work_hammer.png"))
        }
        ("weapon", "wuji_rifle") => {
            Some(include_bytes!("../assets/previews/weapons/wuji_rifle.png"))
        }
        ("weapon", "wuji_rifle1") => {
            Some(include_bytes!("../assets/previews/weapons/wuji_rifle1.png"))
        }
        ("weapon", "wuji_rifle2") => {
            Some(include_bytes!("../assets/previews/weapons/wuji_rifle2.png"))
        }
        ("weapon", "wuji_rifle3") => {
            Some(include_bytes!("../assets/previews/weapons/wuji_rifle3.png"))
        }
        ("weapon", "xcom_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/xcom_grenade.png"
        )),
        ("weapon", "xianhu") => Some(include_bytes!("../assets/previews/weapons/xianhu.png")),
        ("weapon", "xiya_order_dou_gun") => Some(include_bytes!(
            "../assets/previews/weapons/xiya_order_dou_gun.png"
        )),
        ("weapon", "xm1014") => Some(include_bytes!("../assets/previews/weapons/xm1014.png")),
        ("weapon", "xm1014_ult") => {
            Some(include_bytes!("../assets/previews/weapons/xm1014_ult.png"))
        }
        ("weapon", "xm1014_wolf") => {
            Some(include_bytes!("../assets/previews/weapons/xm1014_wolf.png"))
        }
        ("weapon", "xm8") => Some(include_bytes!("../assets/previews/weapons/xm8.png")),
        ("weapon", "xm8_4399") => Some(include_bytes!("../assets/previews/weapons/xm8_4399.png")),
        ("weapon", "xm8_qq") => Some(include_bytes!("../assets/previews/weapons/xm8_qq.png")),
        ("weapon", "yinjiao") => Some(include_bytes!("../assets/previews/weapons/yinjiao.png")),
        ("weapon", "yinyang_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/yinyang_grenade.png"
        )),
        ("weapon", "yinyang_grenade1") => Some(include_bytes!(
            "../assets/previews/weapons/yinyang_grenade1.png"
        )),
        ("weapon", "yinyang_grenade2") => Some(include_bytes!(
            "../assets/previews/weapons/yinyang_grenade2.png"
        )),
        ("weapon", "yinyang_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/yinyang_rifle.png"
        )),
        ("weapon", "yoyo_ball") => Some(include_bytes!("../assets/previews/weapons/yoyo_ball.png")),
        ("weapon", "yuanbao_hammer") => Some(include_bytes!(
            "../assets/previews/weapons/yuanbao_hammer.png"
        )),
        ("weapon", "yuetu") => Some(include_bytes!("../assets/previews/weapons/yuetu.png")),
        ("weapon", "zhaoyun_rifle") => Some(include_bytes!(
            "../assets/previews/weapons/zhaoyun_rifle.png"
        )),
        ("weapon", "zhaoyun_sword") => Some(include_bytes!(
            "../assets/previews/weapons/zhaoyun_sword.png"
        )),
        ("weapon", "zongzi_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/zongzi_grenade.png"
        )),
        ("weapon", "zhangXinLeiGrenade") => Some(include_bytes!(
            "../assets/previews/weapons/zhangXinLeiGrenade.png"
        )),
        ("weapon", "zhounian_grenade") => Some(include_bytes!(
            "../assets/previews/weapons/zhounian_grenade.png"
        )),
        ("weapon", "92fs_wolf") => Some(include_bytes!("../assets/previews/weapons/92fs_wolf.png")),
        ("weapon", "ak48") => Some(include_bytes!("../assets/previews/weapons/ak48.png")),
        ("weapon", "card1") => Some(include_bytes!("../assets/previews/weapons/card1.png")),
        ("weapon", "knife_test") => {
            Some(include_bytes!("../assets/previews/weapons/knife_test.png"))
        }
        ("weapon", "nbr_kniff_c") => {
            Some(include_bytes!("../assets/previews/weapons/nbr_kniff_c.png"))
        }
        ("weapon", "rouge_card") => {
            Some(include_bytes!("../assets/previews/weapons/rouge_card.png"))
        }
        ("weapon", "skin_carbon_fiber_nbr") => Some(include_bytes!(
            "../assets/previews/weapons/skin_carbon_fiber_nbr.png"
        )),
        ("weapon", "skin_double_fangs_g_honor") => Some(include_bytes!(
            "../assets/previews/weapons/skin_double_fangs_g_honor.png"
        )),
        ("character", "rpg_by_parasitism") => Some(include_bytes!(
            "../assets/previews/characters/rpg_by_parasitism.png"
        )),
        ("character", "dlc4_ms_verB") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_ms_verB.png"
        )),
        ("character", "dlc4_ms_verG") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_ms_verG.png"
        )),
        ("character", "assassin") => {
            Some(include_bytes!("../assets/previews/characters/assassin.png"))
        }
        ("character", "rpg_skin_bookofdoom_magic_icerose") => Some(include_bytes!(
            "../assets/previews/characters/rpg_skin_bookofdoom_magic_icerose.png"
        )),
        ("character", "rpg_10200901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10200901.png"
        )),
        ("character", "acg_crystal_water") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_water.png"
        )),
        ("character", "dlc4_elite_wurenji") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_elite_wurenji.png"
        )),
        ("character", "dlc3_bs_Asura") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_Asura.png"
        )),
        ("character", "rpg_10003601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003601.png"
        )),
        ("character", "rpg_10005901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005901.png"
        )),
        ("character", "dlc2_zombie") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_zombie.png"
        )),
        ("character", "dlc4_bs_jijia") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_jijia.png"
        )),
        ("character", "rpg_empty_ruodian") => Some(include_bytes!(
            "../assets/previews/characters/rpg_empty_ruodian.png"
        )),
        ("character", "rpg_10801101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10801101.png"
        )),
        ("character", "acg_cloud_fire_bow") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_fire_bow.png"
        )),
        ("character", "hasu_b1") => {
            Some(include_bytes!("../assets/previews/characters/hasu_b1.png"))
        }
        ("character", "rpg_empty_1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_empty_1.png"
        )),
        ("character", "pvephantom") => Some(include_bytes!(
            "../assets/previews/characters/pvephantom.png"
        )),
        ("character", "qiangling_tank") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_tank.png"
        )),
        ("character", "freya") => Some(include_bytes!("../assets/previews/characters/freya.png")),
        ("character", "envoy_shenpan") => Some(include_bytes!(
            "../assets/previews/characters/envoy_shenpan.png"
        )),
        ("character", "envoy_shenpan1") => Some(include_bytes!(
            "../assets/previews/characters/envoy_shenpan1.png"
        )),
        ("character", "envoy_shenpan2") => Some(include_bytes!(
            "../assets/previews/characters/envoy_shenpan2.png"
        )),
        ("character", "renzhe") => Some(include_bytes!("../assets/previews/characters/renzhe.png")),
        ("character", "qiangling_Mushroom01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Mushroom01.png"
        )),
        ("character", "qiangling_Mushroom02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Mushroom02.png"
        )),
        ("character", "hellwalker") => Some(include_bytes!(
            "../assets/previews/characters/hellwalker.png"
        )),
        ("character", "rpg_10004701") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004701.png"
        )),
        ("character", "researcher_2") => Some(include_bytes!(
            "../assets/previews/characters/researcher_2.png"
        )),
        ("character", "researcher_1") => Some(include_bytes!(
            "../assets/previews/characters/researcher_1.png"
        )),
        ("character", "rpg_cabrite_1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_1.png"
        )),
        ("character", "rpg_cabrite_2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_2.png"
        )),
        ("character", "rpg_captain_jz_nine") => Some(include_bytes!(
            "../assets/previews/characters/rpg_captain_jz_nine.png"
        )),
        ("character", "firedragon") => Some(include_bytes!(
            "../assets/previews/characters/firedragon.png"
        )),
        ("character", "dj_girl_t") => Some(include_bytes!(
            "../assets/previews/characters/dj_girl_t.png"
        )),
        ("character", "rpg_cabrite_3") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_3.png"
        )),
        ("character", "rpg_cabrite_4") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_4.png"
        )),
        ("character", "rpg_cabrite_5") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_5.png"
        )),
        ("character", "feihuwoman") => Some(include_bytes!(
            "../assets/previews/characters/feihuwoman.png"
        )),
        ("character", "rpg_cabrite_6") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_6.png"
        )),
        ("character", "rpg_hanhan") => Some(include_bytes!(
            "../assets/previews/characters/rpg_hanhan.png"
        )),
        ("character", "hero_lego") => Some(include_bytes!(
            "../assets/previews/characters/hero_lego.png"
        )),
        ("character", "icedragon") => Some(include_bytes!(
            "../assets/previews/characters/icedragon.png"
        )),
        ("character", "doun") => Some(include_bytes!("../assets/previews/characters/doun.png")),
        ("character", "dlc_cyber_9527") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_9527.png"
        )),
        ("character", "matrix") => Some(include_bytes!("../assets/previews/characters/matrix.png")),
        ("character", "rpg_minion_wu") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_wu.png"
        )),
        ("character", "qiangling_VerB") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_VerB.png"
        )),
        ("character", "spiderboom") => Some(include_bytes!(
            "../assets/previews/characters/spiderboom.png"
        )),
        ("character", "qiangling_VerG") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_VerG.png"
        )),
        ("character", "hero_gun") => {
            Some(include_bytes!("../assets/previews/characters/hero_gun.png"))
        }
        ("character", "rpg_10003501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003501.png"
        )),
        ("character", "rpg_10005801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005801.png"
        )),
        ("character", "dlc2_bs_yaolong") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_yaolong.png"
        )),
        ("character", "destroyrider") => Some(include_bytes!(
            "../assets/previews/characters/destroyrider.png"
        )),
        ("character", "self_explosion") => Some(include_bytes!(
            "../assets/previews/characters/self_explosion.png"
        )),
        ("character", "acg_scanner_dark") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_dark.png"
        )),
        ("character", "blast") => Some(include_bytes!("../assets/previews/characters/blast.png")),
        ("character", "dog_bawanglong") => Some(include_bytes!(
            "../assets/previews/characters/dog_bawanglong.png"
        )),
        ("character", "shadow_demon_tps") => Some(include_bytes!(
            "../assets/previews/characters/shadow_demon_tps.png"
        )),
        ("character", "gezhe2") => Some(include_bytes!("../assets/previews/characters/gezhe2.png")),
        ("character", "herowoman_gun") => Some(include_bytes!(
            "../assets/previews/characters/herowoman_gun.png"
        )),
        ("character", "police") => Some(include_bytes!("../assets/previews/characters/police.png")),
        ("character", "acg_scanner_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_boss.png"
        )),
        ("character", "rpg_10300401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300401.png"
        )),
        ("character", "meatwoman_s3") => Some(include_bytes!(
            "../assets/previews/characters/meatwoman_s3.png"
        )),
        ("character", "pix_type2") => Some(include_bytes!(
            "../assets/previews/characters/pix_type2.png"
        )),
        ("character", "xiaoqiao") => {
            Some(include_bytes!("../assets/previews/characters/xiaoqiao.png"))
        }
        ("character", "rpg_10300404") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300404.png"
        )),
        ("character", "rpg_10300402") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300402.png"
        )),
        ("character", "rpg_10300403") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300403.png"
        )),
        ("character", "rpg_captain_jz") => Some(include_bytes!(
            "../assets/previews/characters/rpg_captain_jz.png"
        )),
        ("character", "rpg_10004601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004601.png"
        )),
        ("character", "mercenary2_2") => Some(include_bytes!(
            "../assets/previews/characters/mercenary2_2.png"
        )),
        ("character", "acg_scanner_light") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_light.png"
        )),
        ("character", "mercenary2_1") => Some(include_bytes!(
            "../assets/previews/characters/mercenary2_1.png"
        )),
        ("character", "dlc2_poisonZomb") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_poisonZomb.png"
        )),
        ("character", "gezhe") => Some(include_bytes!("../assets/previews/characters/gezhe.png")),
        ("character", "rpg_10800101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800101.png"
        )),
        ("character", "acg_cloud_light_bow") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_light_bow.png"
        )),
        ("character", "acg_cloud_wood_shield") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_wood_shield.png"
        )),
        ("character", "qiangling_baolei01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_baolei01.png"
        )),
        ("character", "qiangling_baolei02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_baolei02.png"
        )),
        ("character", "acg_thunder_girl") => Some(include_bytes!(
            "../assets/previews/characters/acg_thunder_girl.png"
        )),
        ("character", "rpg_minion_parasitism") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_parasitism.png"
        )),
        ("character", "boss02_1") => {
            Some(include_bytes!("../assets/previews/characters/boss02_1.png"))
        }
        ("character", "acg_pig_water") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_water.png"
        )),
        ("character", "rpg_10003401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003401.png"
        )),
        ("character", "dlc_cyber_machine") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_machine.png"
        )),
        ("character", "dlc3_ms_jvren") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_jvren.png"
        )),
        ("character", "bojue") => Some(include_bytes!("../assets/previews/characters/bojue.png")),
        ("character", "rpg_10200701") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10200701.png"
        )),
        ("character", "rpg_mofang") => Some(include_bytes!(
            "../assets/previews/characters/rpg_mofang.png"
        )),
        ("character", "rpg_10800102") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800102.png"
        )),
        ("character", "rpg_10003403") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003403.png"
        )),
        ("character", "rpg_10003402") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003402.png"
        )),
        ("character", "rpg_10005701") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005701.png"
        )),
        ("character", "pvegatlingleiting") => Some(include_bytes!(
            "../assets/previews/characters/pvegatlingleiting.png"
        )),
        ("character", "dlc3_bs_ShiMi") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_ShiMi.png"
        )),
        ("character", "dlc3_bs_zhongjia") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_zhongjia.png"
        )),
        ("character", "phantom") => {
            Some(include_bytes!("../assets/previews/characters/phantom.png"))
        }
        ("character", "rpg_10004501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004501.png"
        )),
        ("character", "rpg_10300301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300301.png"
        )),
        ("character", "dlc2_boomer_02") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_boomer_02.png"
        )),
        ("character", "rpg_10600501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600501.png"
        )),
        ("character", "rpg_10300302") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300302.png"
        )),
        ("character", "snake_doun") => Some(include_bytes!(
            "../assets/previews/characters/snake_doun.png"
        )),
        ("character", "baofengwoman") => Some(include_bytes!(
            "../assets/previews/characters/baofengwoman.png"
        )),
        ("character", "rpg_10300305") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300305.png"
        )),
        ("character", "dlc4_elite_Jianke") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_elite_Jianke.png"
        )),
        ("character", "rpg_10300306") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300306.png"
        )),
        ("character", "rpg_10300303") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300303.png"
        )),
        ("character", "vippet") => Some(include_bytes!("../assets/previews/characters/vippet.png")),
        ("character", "acg_cloud_dark_sword") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_dark_sword.png"
        )),
        ("character", "rpg_10300304") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300304.png"
        )),
        ("character", "dlc3_bs_nushou") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_nushou.png"
        )),
        ("character", "rpg_10300307") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300307.png"
        )),
        ("character", "dlc5_boss_Troll") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_Troll.png"
        )),
        ("character", "rpg_10800001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800001.png"
        )),
        ("character", "rpg_10800002") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800002.png"
        )),
        ("character", "jack_2022") => Some(include_bytes!(
            "../assets/previews/characters/jack_2022.png"
        )),
        ("character", "acg_cloud_dark_bow") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_dark_bow.png"
        )),
        ("character", "acg_paila") => Some(include_bytes!(
            "../assets/previews/characters/acg_paila.png"
        )),
        ("character", "type2_2") => {
            Some(include_bytes!("../assets/previews/characters/type2_2.png"))
        }
        ("character", "qiangling_garuda") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_garuda.png"
        )),
        ("character", "dlc3_bs_mushi") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_mushi.png"
        )),
        ("character", "luna") => Some(include_bytes!("../assets/previews/characters/luna.png")),
        ("character", "ahriman") => {
            Some(include_bytes!("../assets/previews/characters/ahriman.png"))
        }
        ("character", "rpg_10200801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10200801.png"
        )),
        ("character", "rpg_10005601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005601.png"
        )),
        ("character", "rpg_10003301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003301.png"
        )),
        ("character", "skating_girl") => Some(include_bytes!(
            "../assets/previews/characters/skating_girl.png"
        )),
        ("character", "dlc4_ms_guangren") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_ms_guangren.png"
        )),
        ("character", "rpg_minion_bug") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_bug.png"
        )),
        ("character", "rpg_10800003") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800003.png"
        )),
        ("character", "maolin") => Some(include_bytes!("../assets/previews/characters/maolin.png")),
        ("character", "dlc2_boomer") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_boomer.png"
        )),
        ("character", "acg_scanner_water") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_water.png"
        )),
        ("character", "pilot") => Some(include_bytes!("../assets/previews/characters/pilot.png")),
        ("character", "acg_cube_dark") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_dark.png"
        )),
        ("character", "qiangling_ange") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_ange.png"
        )),
        ("character", "twine") => Some(include_bytes!("../assets/previews/characters/twine.png")),
        ("character", "qiangling_gaizaojia") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_gaizaojia.png"
        )),
        ("character", "qiangling_shimi") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_shimi.png"
        )),
        ("character", "acg_shadow_girl") => Some(include_bytes!(
            "../assets/previews/characters/acg_shadow_girl.png"
        )),
        ("character", "hero_shark") => Some(include_bytes!(
            "../assets/previews/characters/hero_shark.png"
        )),
        ("character", "rpg_10004401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004401.png"
        )),
        ("character", "anqila") => Some(include_bytes!("../assets/previews/characters/anqila.png")),
        ("character", "dieying_4399") => Some(include_bytes!(
            "../assets/previews/characters/dieying_4399.png"
        )),
        ("character", "dlc4_ms_liudan") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_ms_liudan.png"
        )),
        ("character", "rpg_tank1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_tank1.png"
        )),
        ("character", "dog_sanjiaolong") => Some(include_bytes!(
            "../assets/previews/characters/dog_sanjiaolong.png"
        )),
        ("character", "xiaotianlang") => Some(include_bytes!(
            "../assets/previews/characters/xiaotianlang.png"
        )),
        ("character", "beretsman") => Some(include_bytes!(
            "../assets/previews/characters/beretsman.png"
        )),
        ("character", "pandora_ct") => Some(include_bytes!(
            "../assets/previews/characters/pandora_ct.png"
        )),
        ("character", "dlc_cyber_blade") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_blade.png"
        )),
        ("character", "rpg_mofang1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_mofang1.png"
        )),
        ("character", "rpg_mofang2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_mofang2.png"
        )),
        ("character", "qiangling_yiliya") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_yiliya.png"
        )),
        ("character", "rpg_10003201") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003201.png"
        )),
        ("character", "rpg_10005501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005501.png"
        )),
        ("character", "rpg_10005502") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005502.png"
        )),
        ("character", "guardian_b1") => Some(include_bytes!(
            "../assets/previews/characters/guardian_b1.png"
        )),
        ("character", "rpg_10800308") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800308.png"
        )),
        ("character", "rpg_10800309") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800309.png"
        )),
        ("character", "mirage") => Some(include_bytes!("../assets/previews/characters/mirage.png")),
        ("character", "rpg_debug") => Some(include_bytes!(
            "../assets/previews/characters/rpg_debug.png"
        )),
        ("character", "rpg_10800302") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800302.png"
        )),
        ("character", "rpg_10800303") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800303.png"
        )),
        ("character", "rpg_10800301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800301.png"
        )),
        ("character", "dlc3_ms_qiangshou") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_qiangshou.png"
        )),
        ("character", "rpg_10800306") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800306.png"
        )),
        ("character", "rpg_10800307") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800307.png"
        )),
        ("character", "rpg_10005503") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005503.png"
        )),
        ("character", "rpg_10800304") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800304.png"
        )),
        ("character", "qiangling_ducaizhe") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_ducaizhe.png"
        )),
        ("character", "rpg_10800305") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800305.png"
        )),
        ("character", "bossjy1003") => Some(include_bytes!(
            "../assets/previews/characters/bossjy1003.png"
        )),
        ("character", "acg_pig_light") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_light.png"
        )),
        ("character", "dlc5_boss_priest") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_priest.png"
        )),
        ("character", "bossjy1002") => Some(include_bytes!(
            "../assets/previews/characters/bossjy1002.png"
        )),
        ("character", "bossjy1001") => Some(include_bytes!(
            "../assets/previews/characters/bossjy1001.png"
        )),
        ("character", "death_xingtian") => Some(include_bytes!(
            "../assets/previews/characters/death_xingtian.png"
        )),
        ("character", "tongyun") => {
            Some(include_bytes!("../assets/previews/characters/tongyun.png"))
        }
        ("character", "hyaena") => Some(include_bytes!("../assets/previews/characters/hyaena.png")),
        ("character", "dlc_cyber_bs_wolf") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_wolf.png"
        )),
        ("character", "spring_snake") => Some(include_bytes!(
            "../assets/previews/characters/spring_snake.png"
        )),
        ("character", "dlc2_bs_xingtian") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_xingtian.png"
        )),
        ("character", "dlc3_bs_jianshi") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_jianshi.png"
        )),
        ("character", "dog_jialong") => Some(include_bytes!(
            "../assets/previews/characters/dog_jialong.png"
        )),
        ("character", "pvepetrified_1") => Some(include_bytes!(
            "../assets/previews/characters/pvepetrified_1.png"
        )),
        ("character", "vippet_2022") => Some(include_bytes!(
            "../assets/previews/characters/vippet_2022.png"
        )),
        ("character", "dlc2_flame") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_flame.png"
        )),
        ("character", "zibaofeichongmuti") => Some(include_bytes!(
            "../assets/previews/characters/zibaofeichongmuti.png"
        )),
        ("character", "rpg_10004301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004301.png"
        )),
        ("character", "robot_tiepiren") => Some(include_bytes!(
            "../assets/previews/characters/robot_tiepiren.png"
        )),
        ("character", "dragoon02_a1") => Some(include_bytes!(
            "../assets/previews/characters/dragoon02_a1.png"
        )),
        ("character", "rpg_10600301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600301.png"
        )),
        ("character", "dragoon02_a2") => Some(include_bytes!(
            "../assets/previews/characters/dragoon02_a2.png"
        )),
        ("character", "daodangui2022") => Some(include_bytes!(
            "../assets/previews/characters/daodangui2022.png"
        )),
        ("character", "dlc4_bs_jingjie") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_jingjie.png"
        )),
        ("character", "dlc4_bs_gaizaoren") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_gaizaoren.png"
        )),
        ("character", "dlc4_bs_gaizaoren_1") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_gaizaoren_1.png"
        )),
        ("character", "mechnear") => {
            Some(include_bytes!("../assets/previews/characters/mechnear.png"))
        }
        ("character", "liandaoMonther") => Some(include_bytes!(
            "../assets/previews/characters/liandaoMonther.png"
        )),
        ("character", "rpg_10801501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10801501.png"
        )),
        ("character", "hasu_a") => Some(include_bytes!("../assets/previews/characters/hasu_a.png")),
        ("character", "cheerleader") => Some(include_bytes!(
            "../assets/previews/characters/cheerleader.png"
        )),
        ("character", "dlc_cyber_bs_machine") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_machine.png"
        )),
        ("character", "baofeng") => {
            Some(include_bytes!("../assets/previews/characters/baofeng.png"))
        }
        ("character", "dlc6_ms_blue") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_ms_blue.png"
        )),
        ("character", "dog") => Some(include_bytes!("../assets/previews/characters/dog.png")),
        ("character", "dlc2_bs_zhizhu") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_zhizhu.png"
        )),
        ("character", "weapon_pig") => Some(include_bytes!(
            "../assets/previews/characters/weapon_pig.png"
        )),
        ("character", "rpg_minion_woman") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_woman.png"
        )),
        ("character", "qiangling_asura") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_asura.png"
        )),
        ("character", "queen") => Some(include_bytes!("../assets/previews/characters/queen.png")),
        ("character", "dlc_cyber_bs_scientist") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_scientist.png"
        )),
        ("character", "dlc_cyber_shield") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_shield.png"
        )),
        ("character", "snaker") => Some(include_bytes!("../assets/previews/characters/snaker.png")),
        ("character", "petrified_rage") => Some(include_bytes!(
            "../assets/previews/characters/petrified_rage.png"
        )),
        ("character", "rpg_zilvshouwei") => Some(include_bytes!(
            "../assets/previews/characters/rpg_zilvshouwei.png"
        )),
        ("character", "rpg_10003101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003101.png"
        )),
        ("character", "rpg_10003104") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003104.png"
        )),
        ("character", "polypideMonther") => Some(include_bytes!(
            "../assets/previews/characters/polypideMonther.png"
        )),
        ("character", "rpg_10003103") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003103.png"
        )),
        ("character", "rpg_10005401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005401.png"
        )),
        ("character", "dlc_cyber_dog") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_dog.png"
        )),
        ("character", "jiewangzhe") => Some(include_bytes!(
            "../assets/previews/characters/jiewangzhe.png"
        )),
        ("character", "rpg_jinghuaqi") => Some(include_bytes!(
            "../assets/previews/characters/rpg_jinghuaqi.png"
        )),
        ("character", "acg_slime_fire") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_fire.png"
        )),
        ("character", "bs_diaochan") => Some(include_bytes!(
            "../assets/previews/characters/bs_diaochan.png"
        )),
        ("character", "nurse") => Some(include_bytes!("../assets/previews/characters/nurse.png")),
        ("character", "rpg_10003109") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003109.png"
        )),
        ("character", "dlc5_boss_headwolf") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_headwolf.png"
        )),
        ("character", "rpg_10800201") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800201.png"
        )),
        ("character", "rpg_10003106") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003106.png"
        )),
        ("character", "dlc3_bs_zhujiao") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_zhujiao.png"
        )),
        ("character", "rpg_10003105") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003105.png"
        )),
        ("character", "unityManCT") => Some(include_bytes!(
            "../assets/previews/characters/unityManCT.png"
        )),
        ("character", "rpg_10003108") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003108.png"
        )),
        ("character", "rpg_10003107") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003107.png"
        )),
        ("character", "machao") => Some(include_bytes!("../assets/previews/characters/machao.png")),
        ("character", "dlc_cyber_bs_blade") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_blade.png"
        )),
        ("character", "dlc3_bs_kaijia") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_kaijia.png"
        )),
        ("character", "rpg_10800310") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800310.png"
        )),
        ("character", "dlc3_bs_weishi") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_weishi.png"
        )),
        ("character", "qiangling_Selina") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Selina.png"
        )),
        ("character", "mechaman_ct") => Some(include_bytes!(
            "../assets/previews/characters/mechaman_ct.png"
        )),
        ("character", "acg_crystal_wood") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_wood.png"
        )),
        ("character", "rpg_by_parasitism_rage") => Some(include_bytes!(
            "../assets/previews/characters/rpg_by_parasitism_rage.png"
        )),
        ("character", "dlc4_bs_Rabbit") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_Rabbit.png"
        )),
        ("character", "rpg_10003113") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003113.png"
        )),
        ("character", "rpg_10003112") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003112.png"
        )),
        ("character", "rpg_10004201") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004201.png"
        )),
        ("character", "qiangling_ghost") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_ghost.png"
        )),
        ("character", "rpg_dragon_01") => Some(include_bytes!(
            "../assets/previews/characters/rpg_dragon_01.png"
        )),
        ("character", "howitzer_skyfire") => Some(include_bytes!(
            "../assets/previews/characters/howitzer_skyfire.png"
        )),
        ("character", "rpg_10003115") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003115.png"
        )),
        ("character", "rpg_10003114") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003114.png"
        )),
        ("character", "huiselv") => {
            Some(include_bytes!("../assets/previews/characters/huiselv.png"))
        }
        ("character", "rpg_10600401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600401.png"
        )),
        ("character", "rpg_bookofdoom") => Some(include_bytes!(
            "../assets/previews/characters/rpg_bookofdoom.png"
        )),
        ("character", "acg_cloud_light_fist") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_light_fist.png"
        )),
        ("character", "rpg_10600402") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600402.png"
        )),
        ("character", "guardian_a") => Some(include_bytes!(
            "../assets/previews/characters/guardian_a.png"
        )),
        ("character", "rpg_10003111") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003111.png"
        )),
        ("character", "rpg_10600403") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600403.png"
        )),
        ("character", "tps") => Some(include_bytes!("../assets/previews/characters/tps.png")),
        ("character", "rpg_10003110") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003110.png"
        )),
        ("character", "rpg_10801402") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10801402.png"
        )),
        ("character", "acg_cloud_fire_shield") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_fire_shield.png"
        )),
        ("character", "rpg_10801401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10801401.png"
        )),
        ("character", "rpg_10003117") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003117.png"
        )),
        ("character", "rpg_10003116") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003116.png"
        )),
        ("character", "nurse_rage") => Some(include_bytes!(
            "../assets/previews/characters/nurse_rage.png"
        )),
        ("character", "rpg_10003119") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003119.png"
        )),
        ("character", "rpg_10201001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10201001.png"
        )),
        ("character", "rpg_10003118") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003118.png"
        )),
        ("character", "acg_cloud_light_wand") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_light_wand.png"
        )),
        ("character", "xiya") => Some(include_bytes!("../assets/previews/characters/xiya.png")),
        ("character", "dlc_cyber_scientist") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_scientist.png"
        )),
        ("character", "raptor") => Some(include_bytes!("../assets/previews/characters/raptor.png")),
        ("character", "snowman") => {
            Some(include_bytes!("../assets/previews/characters/snowman.png"))
        }
        ("character", "pig") => Some(include_bytes!("../assets/previews/characters/pig.png")),
        ("character", "rpg_10003124") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003124.png"
        )),
        ("character", "zhongjiezhe") => Some(include_bytes!(
            "../assets/previews/characters/zhongjiezhe.png"
        )),
        ("character", "dlc6_ms_green") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_ms_green.png"
        )),
        ("character", "pvegatling") => Some(include_bytes!(
            "../assets/previews/characters/pvegatling.png"
        )),
        ("character", "rpg_10003123") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003123.png"
        )),
        ("character", "rpg_10005301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005301.png"
        )),
        ("character", "rpg_10003125") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003125.png"
        )),
        ("character", "mengji") => Some(include_bytes!("../assets/previews/characters/mengji.png")),
        ("character", "nurse_jiuwei") => Some(include_bytes!(
            "../assets/previews/characters/nurse_jiuwei.png"
        )),
        ("character", "rpg_10003120") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003120.png"
        )),
        ("character", "rpg_minion_boomer") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_boomer.png"
        )),
        ("character", "bankX_a") => {
            Some(include_bytes!("../assets/previews/characters/bankX_a.png"))
        }
        ("character", "rpg_10003001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003001.png"
        )),
        ("character", "rpg_10003122") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003122.png"
        )),
        ("character", "rpg_10003121") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003121.png"
        )),
        ("character", "dlc2_bs_bone") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_bone.png"
        )),
        ("character", "cia_girl1") => Some(include_bytes!(
            "../assets/previews/characters/cia_girl1.png"
        )),
        ("character", "rpg_10099901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10099901.png"
        )),
        ("character", "xiya_yh1_v3") => Some(include_bytes!(
            "../assets/previews/characters/xiya_yh1_v3.png"
        )),
        ("character", "herowoman") => Some(include_bytes!(
            "../assets/previews/characters/herowoman.png"
        )),
        ("character", "hero_skyfire") => Some(include_bytes!(
            "../assets/previews/characters/hero_skyfire.png"
        )),
        ("character", "qiangling_yecha02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_yecha02.png"
        )),
        ("character", "acg_yiliya_ss1") => Some(include_bytes!(
            "../assets/previews/characters/acg_yiliya_ss1.png"
        )),
        ("character", "rpg_10100401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10100401.png"
        )),
        ("character", "qiangling_yecha01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_yecha01.png"
        )),
        ("character", "rpg_10100402") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10100402.png"
        )),
        ("character", "acg_slime_wood") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_wood.png"
        )),
        ("character", "rpg_honglian1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian1.png"
        )),
        ("character", "longyin_yh1_v3") => Some(include_bytes!(
            "../assets/previews/characters/longyin_yh1_v3.png"
        )),
        ("character", "geiger") => Some(include_bytes!("../assets/previews/characters/geiger.png")),
        ("character", "rpg_honglian3") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian3.png"
        )),
        ("character", "acg_cloud_water_sword") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_water_sword.png"
        )),
        ("character", "qinglong") => {
            Some(include_bytes!("../assets/previews/characters/qinglong.png"))
        }
        ("character", "rpg_honglian2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian2.png"
        )),
        ("character", "rpg_honglian5") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian5.png"
        )),
        ("character", "rpg_honglian4") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian4.png"
        )),
        ("character", "rpg_minion_builder") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_builder.png"
        )),
        ("character", "bs_zhaoyun") => Some(include_bytes!(
            "../assets/previews/characters/bs_zhaoyun.png"
        )),
        ("character", "qingniujing") => Some(include_bytes!(
            "../assets/previews/characters/qingniujing.png"
        )),
        ("character", "rpg_honglian6") => Some(include_bytes!(
            "../assets/previews/characters/rpg_honglian6.png"
        )),
        ("character", "rpg_10004103") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004103.png"
        )),
        ("character", "rpg_minion_officer") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_officer.png"
        )),
        ("character", "rpg_10004102") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004102.png"
        )),
        ("character", "rpg_10600101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10600101.png"
        )),
        ("character", "type2_gold") => Some(include_bytes!(
            "../assets/previews/characters/type2_gold.png"
        )),
        ("character", "dlc4_elite_Ball") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_elite_Ball.png"
        )),
        ("character", "rpg_10004105") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004105.png"
        )),
        ("character", "messiah") => {
            Some(include_bytes!("../assets/previews/characters/messiah.png"))
        }
        ("character", "rpg_10004104") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004104.png"
        )),
        ("character", "dlc4_bs_shiyanti") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_shiyanti.png"
        )),
        ("character", "hero_sangzhong") => Some(include_bytes!(
            "../assets/previews/characters/hero_sangzhong.png"
        )),
        ("character", "qingniujing_mother") => Some(include_bytes!(
            "../assets/previews/characters/qingniujing_mother.png"
        )),
        ("character", "rpg_10003130") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003130.png"
        )),
        ("character", "dlc_cyber_bs_engineer") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_engineer.png"
        )),
        ("character", "rpg_10004101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004101.png"
        )),
        ("character", "acg_cloud_wood_fist") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_wood_fist.png"
        )),
        ("character", "sunshangxiang") => Some(include_bytes!(
            "../assets/previews/characters/sunshangxiang.png"
        )),
        ("character", "rpg_10004107") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004107.png"
        )),
        ("character", "rpg_10004106") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004106.png"
        )),
        ("character", "rpg_10004109") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004109.png"
        )),
        ("character", "rpg_10004108") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004108.png"
        )),
        ("character", "chicken") => {
            Some(include_bytes!("../assets/previews/characters/chicken.png"))
        }
        ("character", "metalman") => {
            Some(include_bytes!("../assets/previews/characters/metalman.png"))
        }
        ("character", "dlc5_boss_chimera") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_chimera.png"
        )),
        ("character", "police_2") => {
            Some(include_bytes!("../assets/previews/characters/police_2.png"))
        }
        ("character", "dlc4_ms_Ball") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_ms_Ball.png"
        )),
        ("character", "mechbomberman") => Some(include_bytes!(
            "../assets/previews/characters/mechbomberman.png"
        )),
        ("character", "qiangling_no8820") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_no8820.png"
        )),
        ("character", "zhenji") => Some(include_bytes!("../assets/previews/characters/zhenji.png")),
        ("character", "mechpredator") => Some(include_bytes!(
            "../assets/previews/characters/mechpredator.png"
        )),
        ("character", "rpg_10004114") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004114.png"
        )),
        ("character", "acg_pig_dark") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_dark.png"
        )),
        ("character", "rpg_10004113") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004113.png"
        )),
        ("character", "rpg_10004116") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004116.png"
        )),
        ("character", "rpg_10004115") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004115.png"
        )),
        ("character", "dragoon01_a1") => Some(include_bytes!(
            "../assets/previews/characters/dragoon01_a1.png"
        )),
        ("character", "rpg_10004110") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004110.png"
        )),
        ("character", "mercenary2") => Some(include_bytes!(
            "../assets/previews/characters/mercenary2.png"
        )),
        ("character", "rpg_10004112") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004112.png"
        )),
        ("character", "rpg_10004111") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004111.png"
        )),
        ("character", "rpg_10800401") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800401.png"
        )),
        ("character", "yueyong") => {
            Some(include_bytes!("../assets/previews/characters/yueyong.png"))
        }
        ("character", "acg_zeus_soul") => Some(include_bytes!(
            "../assets/previews/characters/acg_zeus_soul.png"
        )),
        ("character", "rpg_10004118") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004118.png"
        )),
        ("character", "acg_cloud_wood_wand") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_wood_wand.png"
        )),
        ("character", "rpg_10004117") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004117.png"
        )),
        ("character", "haiyingwoman") => Some(include_bytes!(
            "../assets/previews/characters/haiyingwoman.png"
        )),
        ("character", "taikonggeji") => Some(include_bytes!(
            "../assets/previews/characters/taikonggeji.png"
        )),
        ("character", "rpg_10004119") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004119.png"
        )),
        ("character", "sanjiaozhou") => Some(include_bytes!(
            "../assets/previews/characters/sanjiaozhou.png"
        )),
        ("character", "rpg_10100301") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10100301.png"
        )),
        ("character", "dlc3_bs_huoqiang") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_huoqiang.png"
        )),
        ("character", "lilith") => Some(include_bytes!("../assets/previews/characters/lilith.png")),
        ("character", "acg_cloud_wood_sword") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_wood_sword.png"
        )),
        ("character", "schoolgirls") => Some(include_bytes!(
            "../assets/previews/characters/schoolgirls.png"
        )),
        ("character", "acg_crystal_fire") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_fire.png"
        )),
        ("character", "rpg_10004121") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004121.png"
        )),
        ("character", "rpg_10004120") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004120.png"
        )),
        ("character", "qiangling_Jianke") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Jianke.png"
        )),
        ("character", "mechfar2") => {
            Some(include_bytes!("../assets/previews/characters/mechfar2.png"))
        }
        ("character", "rpg_10004001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004001.png"
        )),
        ("character", "rpg_10004122") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004122.png"
        )),
        ("character", "acg_cloud_dark_wand") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_dark_wand.png"
        )),
        ("character", "aierya_4399") => Some(include_bytes!(
            "../assets/previews/characters/aierya_4399.png"
        )),
        ("character", "qiangling_Captain") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Captain.png"
        )),
        ("character", "qiangling_shiva") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_shiva.png"
        )),
        ("character", "rpg_10300601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10300601.png"
        )),
        ("character", "mechfar") => {
            Some(include_bytes!("../assets/previews/characters/mechfar.png"))
        }
        ("character", "rpg_elite_2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_elite_2.png"
        )),
        ("character", "rpg_captain_yc") => Some(include_bytes!(
            "../assets/previews/characters/rpg_captain_yc.png"
        )),
        ("character", "attendant_summer") => Some(include_bytes!(
            "../assets/previews/characters/attendant_summer.png"
        )),
        ("character", "herowoman_skyfire") => Some(include_bytes!(
            "../assets/previews/characters/herowoman_skyfire.png"
        )),
        ("character", "longyin_renzhe") => Some(include_bytes!(
            "../assets/previews/characters/longyin_renzhe.png"
        )),
        ("character", "sybil_nezha") => Some(include_bytes!(
            "../assets/previews/characters/sybil_nezha.png"
        )),
        ("character", "jiguan_bird03") => Some(include_bytes!(
            "../assets/previews/characters/jiguan_bird03.png"
        )),
        ("character", "dragoon01") => Some(include_bytes!(
            "../assets/previews/characters/dragoon01.png"
        )),
        ("character", "aisha") => Some(include_bytes!("../assets/previews/characters/aisha.png")),
        ("character", "dragoon03_a") => Some(include_bytes!(
            "../assets/previews/characters/dragoon03_a.png"
        )),
        ("character", "dlc6_elite_gyroscope02") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_elite_gyroscope02.png"
        )),
        ("character", "dlc6_elite_gyroscope01") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_elite_gyroscope01.png"
        )),
        ("character", "qiangling_Rabbit") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Rabbit.png"
        )),
        ("character", "rpg_10005105") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005105.png"
        )),
        ("character", "rpg_10005106") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005106.png"
        )),
        ("character", "rpg_10005103") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005103.png"
        )),
        ("character", "rpg_10005104") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005104.png"
        )),
        ("character", "qiangling_liegou") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_liegou.png"
        )),
        ("character", "rpg_10005102") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005102.png"
        )),
        ("character", "saitefujiang") => Some(include_bytes!(
            "../assets/previews/characters/saitefujiang.png"
        )),
        ("character", "rpg_10005109") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005109.png"
        )),
        ("character", "rpg_10005107") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005107.png"
        )),
        ("character", "acg_cube_water") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_water.png"
        )),
        ("character", "rpg_10005108") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005108.png"
        )),
        ("character", "rpg_elite_1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_elite_1.png"
        )),
        ("character", "dlc2_bs_qingshe") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_qingshe.png"
        )),
        ("character", "acg_cube_fire") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_fire.png"
        )),
        ("character", "p3hero") => Some(include_bytes!("../assets/previews/characters/p3hero.png")),
        ("character", "dlc4_bs_Captain") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_Captain.png"
        )),
        ("character", "acg_pig_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_boss.png"
        )),
        ("character", "luoli") => Some(include_bytes!("../assets/previews/characters/luoli.png")),
        ("character", "acg_cloud_fire_sword") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_fire_sword.png"
        )),
        ("character", "rpg_skin_bookofdoom_forest") => Some(include_bytes!(
            "../assets/previews/characters/rpg_skin_bookofdoom_forest.png"
        )),
        ("character", "rpg_10005116") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005116.png"
        )),
        ("character", "rpg_10005117") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005117.png"
        )),
        ("character", "rpg_10005114") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005114.png"
        )),
        ("character", "acg_cloud_water_shield") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_water_shield.png"
        )),
        ("character", "rpg_10005115") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005115.png"
        )),
        ("character", "rpg_10005112") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005112.png"
        )),
        ("character", "qingshe") => {
            Some(include_bytes!("../assets/previews/characters/qingshe.png"))
        }
        ("character", "rpg_10005113") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005113.png"
        )),
        ("character", "dog_yilong") => Some(include_bytes!(
            "../assets/previews/characters/dog_yilong.png"
        )),
        ("character", "rpg_10005110") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005110.png"
        )),
        ("character", "turkey") => Some(include_bytes!("../assets/previews/characters/turkey.png")),
        ("character", "rpg_10005111") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005111.png"
        )),
        ("character", "kuangmengjiang") => Some(include_bytes!(
            "../assets/previews/characters/kuangmengjiang.png"
        )),
        ("character", "rpg_10005118") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005118.png"
        )),
        ("character", "qiangling_Priest") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Priest.png"
        )),
        ("character", "rpg_10005119") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005119.png"
        )),
        ("character", "acg_cloud_fire_wand") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_fire_wand.png"
        )),
        ("character", "rpg_empty_wenzi") => Some(include_bytes!(
            "../assets/previews/characters/rpg_empty_wenzi.png"
        )),
        ("character", "acg_cloud_dark_fist") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_dark_fist.png"
        )),
        ("character", "dlc3_ms_Yasha") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_Yasha.png"
        )),
        ("character", "tqkxz_t") => {
            Some(include_bytes!("../assets/previews/characters/tqkxz_t.png"))
        }
        ("character", "rpg_10005120") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005120.png"
        )),
        ("character", "rabbit_grenade_npc") => Some(include_bytes!(
            "../assets/previews/characters/rabbit_grenade_npc.png"
        )),
        ("character", "acg_cloud_water_fist") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_water_fist.png"
        )),
        ("character", "dlc4_car_green") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_car_green.png"
        )),
        ("character", "mechawoman_ct") => Some(include_bytes!(
            "../assets/previews/characters/mechawoman_ct.png"
        )),
        ("character", "pvepetrified") => Some(include_bytes!(
            "../assets/previews/characters/pvepetrified.png"
        )),
        ("character", "lanbainvpu") => Some(include_bytes!(
            "../assets/previews/characters/lanbainvpu.png"
        )),
        ("character", "rpg_10005125") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005125.png"
        )),
        ("character", "rpg_10005123") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005123.png"
        )),
        ("character", "rpg_10005124") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005124.png"
        )),
        ("character", "rpg_10005121") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005121.png"
        )),
        ("character", "haiying") => {
            Some(include_bytes!("../assets/previews/characters/haiying.png"))
        }
        ("character", "rpg_10005001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005001.png"
        )),
        ("character", "gongyaoji") => Some(include_bytes!(
            "../assets/previews/characters/gongyaoji.png"
        )),
        ("character", "rpg_10005122") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10005122.png"
        )),
        ("character", "qiangling_taitan") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_taitan.png"
        )),
        ("character", "magician") => {
            Some(include_bytes!("../assets/previews/characters/magician.png"))
        }
        ("character", "rpg_leijing1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing1.png"
        )),
        ("character", "doun_yecha") => Some(include_bytes!(
            "../assets/previews/characters/doun_yecha.png"
        )),
        ("character", "rpg_10800601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800601.png"
        )),
        ("character", "bossjy3006") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3006.png"
        )),
        ("character", "bossjy3005") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3005.png"
        )),
        ("character", "bossjy3004") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3004.png"
        )),
        ("character", "rpg_10100501") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10100501.png"
        )),
        ("character", "bossjy3003") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3003.png"
        )),
        ("character", "bossjy3002") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3002.png"
        )),
        ("character", "bossjy3001") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3001.png"
        )),
        ("character", "shuangsha") => Some(include_bytes!(
            "../assets/previews/characters/shuangsha.png"
        )),
        ("character", "pandora_t") => Some(include_bytes!(
            "../assets/previews/characters/pandora_t.png"
        )),
        ("character", "howitzerwoman_skyfire") => Some(include_bytes!(
            "../assets/previews/characters/howitzerwoman_skyfire.png"
        )),
        ("character", "dlc2_rat") => {
            Some(include_bytes!("../assets/previews/characters/dlc2_rat.png"))
        }
        ("character", "phantom_uc") => Some(include_bytes!(
            "../assets/previews/characters/phantom_uc.png"
        )),
        ("character", "acg_slime_light") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_light.png"
        )),
        ("character", "acg_slime_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_boss.png"
        )),
        ("character", "dlc5_elite_cenTaurus_02") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_elite_cenTaurus_02.png"
        )),
        ("character", "mechawoman_t") => Some(include_bytes!(
            "../assets/previews/characters/mechawoman_t.png"
        )),
        ("character", "dlc5_elite_cenTaurus_01") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_elite_cenTaurus_01.png"
        )),
        ("character", "phantom_master") => Some(include_bytes!(
            "../assets/previews/characters/phantom_master.png"
        )),
        ("character", "qiangling_scientist") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_scientist.png"
        )),
        ("character", "dlc3_ms_Rasha") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_Rasha.png"
        )),
        ("character", "sybil_a") => {
            Some(include_bytes!("../assets/previews/characters/sybil_a.png"))
        }
        ("character", "meatwoman") => Some(include_bytes!(
            "../assets/previews/characters/meatwoman.png"
        )),
        ("character", "mech_king") => Some(include_bytes!(
            "../assets/previews/characters/mech_king.png"
        )),
        ("character", "mechbomberman2") => Some(include_bytes!(
            "../assets/previews/characters/mechbomberman2.png"
        )),
        ("character", "zhangfei") => {
            Some(include_bytes!("../assets/previews/characters/zhangfei.png"))
        }
        ("character", "acg_xunhangzhe_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_xunhangzhe_boss.png"
        )),
        ("character", "acg_cube_light") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_light.png"
        )),
        ("character", "dlc4_bs_nengliangti") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_nengliangti.png"
        )),
        ("character", "xiya_tlz") => {
            Some(include_bytes!("../assets/previews/characters/xiya_tlz.png"))
        }
        ("character", "jiqiaoshi") => Some(include_bytes!(
            "../assets/previews/characters/jiqiaoshi.png"
        )),
        ("character", "lx_dragon03") => Some(include_bytes!(
            "../assets/previews/characters/lx_dragon03.png"
        )),
        ("character", "dlc2_snake") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_snake.png"
        )),
        ("character", "lx_dragon02") => Some(include_bytes!(
            "../assets/previews/characters/lx_dragon02.png"
        )),
        ("character", "acg_slime_dark") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_dark.png"
        )),
        ("character", "lx_dragon01") => Some(include_bytes!(
            "../assets/previews/characters/lx_dragon01.png"
        )),
        ("character", "dlc4_car_blue") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_car_blue.png"
        )),
        ("character", "bs_baoxiang01") => Some(include_bytes!(
            "../assets/previews/characters/bs_baoxiang01.png"
        )),
        ("character", "bs_baoxiang02") => Some(include_bytes!(
            "../assets/previews/characters/bs_baoxiang02.png"
        )),
        ("character", "dj_girl") => {
            Some(include_bytes!("../assets/previews/characters/dj_girl.png"))
        }
        ("character", "herowoman_close") => Some(include_bytes!(
            "../assets/previews/characters/herowoman_close.png"
        )),
        ("character", "bs_baoxiang03") => Some(include_bytes!(
            "../assets/previews/characters/bs_baoxiang03.png"
        )),
        ("character", "mechnear2") => Some(include_bytes!(
            "../assets/previews/characters/mechnear2.png"
        )),
        ("character", "dlc3_ms_gaizao") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_gaizao.png"
        )),
        ("character", "dlc2_bs_baishe") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_baishe.png"
        )),
        ("character", "rpg_plane") => Some(include_bytes!(
            "../assets/previews/characters/rpg_plane.png"
        )),
        ("character", "rpg_leijing5") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing5.png"
        )),
        ("character", "rpg_leijing4") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing4.png"
        )),
        ("character", "rpg_leijing3") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing3.png"
        )),
        ("character", "acg_crystal_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_boss.png"
        )),
        ("character", "type2") => Some(include_bytes!("../assets/previews/characters/type2.png")),
        ("character", "rpg_leijing2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing2.png"
        )),
        ("character", "acg_cloud_wood_bow") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_wood_bow.png"
        )),
        ("character", "rpg_leijing6") => Some(include_bytes!(
            "../assets/previews/characters/rpg_leijing6.png"
        )),
        ("character", "ghost_t") => {
            Some(include_bytes!("../assets/previews/characters/ghost_t.png"))
        }
        ("character", "acg_crystal_dark") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_dark.png"
        )),
        ("character", "petrified_kuilei") => Some(include_bytes!(
            "../assets/previews/characters/petrified_kuilei.png"
        )),
        ("character", "doun_master") => Some(include_bytes!(
            "../assets/previews/characters/doun_master.png"
        )),
        ("character", "bossjy6001") => Some(include_bytes!(
            "../assets/previews/characters/bossjy6001.png"
        )),
        ("character", "rpg_10006001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10006001.png"
        )),
        ("character", "shadow_demon") => Some(include_bytes!(
            "../assets/previews/characters/shadow_demon.png"
        )),
        ("character", "acg_cloud_light_shield") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_light_shield.png"
        )),
        ("character", "pveawp") => Some(include_bytes!("../assets/previews/characters/pveawp.png")),
        ("character", "dlc_cyber_bs_dictator") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_dictator.png"
        )),
        ("character", "zhanshen") => {
            Some(include_bytes!("../assets/previews/characters/zhanshen.png"))
        }
        ("character", "heihongluoli") => Some(include_bytes!(
            "../assets/previews/characters/heihongluoli.png"
        )),
        ("character", "rpg_10201101") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10201101.png"
        )),
        ("character", "dlc5_boss_hunter") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_hunter.png"
        )),
        ("character", "bossjy2004") => Some(include_bytes!(
            "../assets/previews/characters/bossjy2004.png"
        )),
        ("character", "bossjy2003") => Some(include_bytes!(
            "../assets/previews/characters/bossjy2003.png"
        )),
        ("character", "bossjy2002") => Some(include_bytes!(
            "../assets/previews/characters/bossjy2002.png"
        )),
        ("character", "bossjy2001") => Some(include_bytes!(
            "../assets/previews/characters/bossjy2001.png"
        )),
        ("character", "mercenary") => Some(include_bytes!(
            "../assets/previews/characters/mercenary.png"
        )),
        ("character", "rocketHamster03") => Some(include_bytes!(
            "../assets/previews/characters/rocketHamster03.png"
        )),
        ("character", "acg_slime_water") => Some(include_bytes!(
            "../assets/previews/characters/acg_slime_water.png"
        )),
        ("character", "rocketHamster02") => Some(include_bytes!(
            "../assets/previews/characters/rocketHamster02.png"
        )),
        ("character", "rpg_minion_burning") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_burning.png"
        )),
        ("character", "rocketHamster04") => Some(include_bytes!(
            "../assets/previews/characters/rocketHamster04.png"
        )),
        ("character", "dlc_cyber_bs_hacker") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_hacker.png"
        )),
        ("character", "spirits_sword_npc") => Some(include_bytes!(
            "../assets/previews/characters/spirits_sword_npc.png"
        )),
        ("character", "acg_scanner_wood") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_wood.png"
        )),
        ("character", "dlc_cyber_tank") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_tank.png"
        )),
        ("character", "cia_girl") => {
            Some(include_bytes!("../assets/previews/characters/cia_girl.png"))
        }
        ("character", "assault01") => Some(include_bytes!(
            "../assets/previews/characters/assault01.png"
        )),
        ("character", "hxm_ct") => Some(include_bytes!("../assets/previews/characters/hxm_ct.png")),
        ("character", "acg_cloud_fire_fist") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_fire_fist.png"
        )),
        ("character", "dajieda") => {
            Some(include_bytes!("../assets/previews/characters/dajieda.png"))
        }
        ("character", "rocketHamster01") => Some(include_bytes!(
            "../assets/previews/characters/rocketHamster01.png"
        )),
        ("character", "qiangling_Assassin") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Assassin.png"
        )),
        ("character", "rpg_10800801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800801.png"
        )),
        ("character", "rpg_cabrite_captain") => Some(include_bytes!(
            "../assets/previews/characters/rpg_cabrite_captain.png"
        )),
        ("character", "saswoman") => {
            Some(include_bytes!("../assets/previews/characters/saswoman.png"))
        }
        ("character", "rpg_10800802") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10800802.png"
        )),
        ("character", "mechaman_t") => Some(include_bytes!(
            "../assets/previews/characters/mechaman_t.png"
        )),
        ("character", "acg_pig_wood") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_wood.png"
        )),
        ("character", "kunlungongzhu") => Some(include_bytes!(
            "../assets/previews/characters/kunlungongzhu.png"
        )),
        ("character", "twine_rage") => Some(include_bytes!(
            "../assets/previews/characters/twine_rage.png"
        )),
        ("character", "weapon_cat") => Some(include_bytes!(
            "../assets/previews/characters/weapon_cat.png"
        )),
        ("character", "acg_cloud_water_bow") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_water_bow.png"
        )),
        ("character", "dlc2_bs_xuekui") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_bs_xuekui.png"
        )),
        ("character", "jiuhudui2022") => Some(include_bytes!(
            "../assets/previews/characters/jiuhudui2022.png"
        )),
        ("character", "shadow_demon_scar") => Some(include_bytes!(
            "../assets/previews/characters/shadow_demon_scar.png"
        )),
        ("character", "rpg_10201201") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10201201.png"
        )),
        ("character", "qiangling_trick") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_trick.png"
        )),
        ("character", "rpg_10002901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10002901.png"
        )),
        ("character", "rpg_minion_boomer2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_boomer2.png"
        )),
        ("character", "acg_cloud_light_sword") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_light_sword.png"
        )),
        ("character", "pandoraMonther") => Some(include_bytes!(
            "../assets/previews/characters/pandoraMonther.png"
        )),
        ("character", "weapon_chicken") => Some(include_bytes!(
            "../assets/previews/characters/weapon_chicken.png"
        )),
        ("character", "ares1") => Some(include_bytes!("../assets/previews/characters/ares1.png")),
        ("character", "pvegunman") => Some(include_bytes!(
            "../assets/previews/characters/pvegunman.png"
        )),
        ("character", "baihu") => Some(include_bytes!("../assets/previews/characters/baihu.png")),
        ("character", "dlc5_boss_Assassin") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_Assassin.png"
        )),
        ("character", "acg_cloud_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_boss.png"
        )),
        ("character", "howitzer") => {
            Some(include_bytes!("../assets/previews/characters/howitzer.png"))
        }
        ("character", "yunli") => Some(include_bytes!("../assets/previews/characters/yunli.png")),
        ("character", "acg_pig_fire") => Some(include_bytes!(
            "../assets/previews/characters/acg_pig_fire.png"
        )),
        ("character", "shengdianqishi") => Some(include_bytes!(
            "../assets/previews/characters/shengdianqishi.png"
        )),
        ("character", "dog_02") => Some(include_bytes!("../assets/previews/characters/dog_02.png")),
        ("character", "matrix_s3A") => Some(include_bytes!(
            "../assets/previews/characters/matrix_s3A.png"
        )),
        ("character", "rabbit_grenade_npc1") => Some(include_bytes!(
            "../assets/previews/characters/rabbit_grenade_npc1.png"
        )),
        ("character", "axiuluo_a") => Some(include_bytes!(
            "../assets/previews/characters/axiuluo_a.png"
        )),
        ("character", "rpg_10500001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10500001.png"
        )),
        ("character", "rpg_10500002") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10500002.png"
        )),
        ("character", "acg_cube_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_boss.png"
        )),
        ("character", "boss1025") => {
            Some(include_bytes!("../assets/previews/characters/boss1025.png"))
        }
        ("character", "swoop") => Some(include_bytes!("../assets/previews/characters/swoop.png")),
        ("character", "qiangling_tianfa") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_tianfa.png"
        )),
        ("character", "hero_guanzi") => Some(include_bytes!(
            "../assets/previews/characters/hero_guanzi.png"
        )),
        ("character", "hero_pokong") => Some(include_bytes!(
            "../assets/previews/characters/hero_pokong.png"
        )),
        ("character", "boss1024") => {
            Some(include_bytes!("../assets/previews/characters/boss1024.png"))
        }
        ("character", "qiangling_no9527") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_no9527.png"
        )),
        ("character", "dlc3_bs_yongbing") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_yongbing.png"
        )),
        ("character", "dlc3_bs_kuangzhan") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_kuangzhan.png"
        )),
        ("character", "boss1023") => {
            Some(include_bytes!("../assets/previews/characters/boss1023.png"))
        }
        ("character", "boss1022") => {
            Some(include_bytes!("../assets/previews/characters/boss1022.png"))
        }
        ("character", "pix_police") => Some(include_bytes!(
            "../assets/previews/characters/pix_police.png"
        )),
        ("character", "researcher") => Some(include_bytes!(
            "../assets/previews/characters/researcher.png"
        )),
        ("character", "boss1021") => {
            Some(include_bytes!("../assets/previews/characters/boss1021.png"))
        }
        ("character", "boss1020") => {
            Some(include_bytes!("../assets/previews/characters/boss1020.png"))
        }
        ("character", "acg_xunhangzhe_feiji_boss") => Some(include_bytes!(
            "../assets/previews/characters/acg_xunhangzhe_feiji_boss.png"
        )),
        ("character", "pandoraMonther_baigu") => Some(include_bytes!(
            "../assets/previews/characters/pandoraMonther_baigu.png"
        )),
        ("character", "rpg_pet_tsxd2_1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_pet_tsxd2_1.png"
        )),
        ("character", "rpg_10002801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10002801.png"
        )),
        ("character", "feishu") => Some(include_bytes!("../assets/previews/characters/feishu.png")),
        ("character", "boss102005_2") => Some(include_bytes!(
            "../assets/previews/characters/boss102005_2.png"
        )),
        ("character", "hero_base_woman") => Some(include_bytes!(
            "../assets/previews/characters/hero_base_woman.png"
        )),
        ("character", "dlc5_boss_saintCrow") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_boss_saintCrow.png"
        )),
        ("character", "dlc_cyber_ghost") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_ghost.png"
        )),
        ("character", "dlc3_bs_kuangzhan_02") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_kuangzhan_02.png"
        )),
        ("character", "qiangling_Ball") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Ball.png"
        )),
        ("character", "rpg_11000002") => Some(include_bytes!(
            "../assets/previews/characters/rpg_11000002.png"
        )),
        ("character", "ghost") => Some(include_bytes!("../assets/previews/characters/ghost.png")),
        ("character", "rpg_11000003") => Some(include_bytes!(
            "../assets/previews/characters/rpg_11000003.png"
        )),
        ("character", "dlc2_light") => Some(include_bytes!(
            "../assets/previews/characters/dlc2_light.png"
        )),
        ("character", "rpg_10200601") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10200601.png"
        )),
        ("character", "rpg_10003901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003901.png"
        )),
        ("character", "rpg_minion_guard") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_guard.png"
        )),
        ("character", "dlc_cyber_bs_eagle") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_eagle.png"
        )),
        ("character", "rpg_11000001") => Some(include_bytes!(
            "../assets/previews/characters/rpg_11000001.png"
        )),
        ("character", "lurker") => Some(include_bytes!("../assets/previews/characters/lurker.png")),
        ("character", "hero_base_man") => Some(include_bytes!(
            "../assets/previews/characters/hero_base_man.png"
        )),
        ("character", "zhendangqi") => Some(include_bytes!(
            "../assets/previews/characters/zhendangqi.png"
        )),
        ("character", "sanjiaozhouwoman") => Some(include_bytes!(
            "../assets/previews/characters/sanjiaozhouwoman.png"
        )),
        ("character", "acg_cloud_dark_shield") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_dark_shield.png"
        )),
        ("character", "dlc4_bs_StarShip") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_bs_StarShip.png"
        )),
        ("character", "rpg_shixiang") => Some(include_bytes!(
            "../assets/previews/characters/rpg_shixiang.png"
        )),
        ("character", "dlc_cyber_8820") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_8820.png"
        )),
        ("character", "dlc_cyber_product") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_product.png"
        )),
        ("character", "lvbu") => Some(include_bytes!("../assets/previews/characters/lvbu.png")),
        ("character", "diaochan") => {
            Some(include_bytes!("../assets/previews/characters/diaochan.png"))
        }
        ("character", "dlc3_elite_Garuda") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_elite_Garuda.png"
        )),
        ("character", "dlc_cyber_punch") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_punch.png"
        )),
        ("character", "dlc_cyber_bs_titan") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_titan.png"
        )),
        ("character", "acg_crystal_light") => Some(include_bytes!(
            "../assets/previews/characters/acg_crystal_light.png"
        )),
        ("character", "rpg_10002701") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10002701.png"
        )),
        ("character", "dlc_cyber_assassin") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_assassin.png"
        )),
        ("character", "polypide") => {
            Some(include_bytes!("../assets/previews/characters/polypide.png"))
        }
        ("character", "rpg_captain_dp") => Some(include_bytes!(
            "../assets/previews/characters/rpg_captain_dp.png"
        )),
        ("character", "ai_girl") => {
            Some(include_bytes!("../assets/previews/characters/ai_girl.png"))
        }
        ("character", "xiaohongmao") => Some(include_bytes!(
            "../assets/previews/characters/xiaohongmao.png"
        )),
        ("character", "boss1022_1") => Some(include_bytes!(
            "../assets/previews/characters/boss1022_1.png"
        )),
        ("character", "rpg_jetpack") => Some(include_bytes!(
            "../assets/previews/characters/rpg_jetpack.png"
        )),
        ("character", "qiangling_jianhao") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_jianhao.png"
        )),
        ("character", "dlc3_bs_ShiVa") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_bs_ShiVa.png"
        )),
        ("character", "manwang") => {
            Some(include_bytes!("../assets/previews/characters/manwang.png"))
        }
        ("character", "kingslayer") => Some(include_bytes!(
            "../assets/previews/characters/kingslayer.png"
        )),
        ("character", "howitzerwoman") => Some(include_bytes!(
            "../assets/previews/characters/howitzerwoman.png"
        )),
        ("character", "rpg_10003801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003801.png"
        )),
        ("character", "rpg_minion_sacrifice") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_sacrifice.png"
        )),
        ("character", "dlc4_car_red") => Some(include_bytes!(
            "../assets/previews/characters/dlc4_car_red.png"
        )),
        ("character", "pverocket_1") => Some(include_bytes!(
            "../assets/previews/characters/pverocket_1.png"
        )),
        ("character", "boss02") => Some(include_bytes!("../assets/previews/characters/boss02.png")),
        ("character", "petrified") => Some(include_bytes!(
            "../assets/previews/characters/petrified.png"
        )),
        ("character", "boss01") => Some(include_bytes!("../assets/previews/characters/boss01.png")),
        ("character", "pverocket_2") => Some(include_bytes!(
            "../assets/previews/characters/pverocket_2.png"
        )),
        ("character", "dlc3_ms_jvfu") => Some(include_bytes!(
            "../assets/previews/characters/dlc3_ms_jvfu.png"
        )),
        ("character", "longyin") => {
            Some(include_bytes!("../assets/previews/characters/longyin.png"))
        }
        ("character", "dlc_cyber_bs_shield") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_bs_shield.png"
        )),
        ("character", "acg_scanner_fire") => Some(include_bytes!(
            "../assets/previews/characters/acg_scanner_fire.png"
        )),
        ("character", "feila") => Some(include_bytes!("../assets/previews/characters/feila.png")),
        ("character", "boss08") => Some(include_bytes!("../assets/previews/characters/boss08.png")),
        ("character", "qiangling_lieying") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_lieying.png"
        )),
        ("character", "boss07") => Some(include_bytes!("../assets/previews/characters/boss07.png")),
        ("character", "dlc5_monster_mushroom_01") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_monster_mushroom_01.png"
        )),
        ("character", "dlc5_monster_mushroom_02") => Some(include_bytes!(
            "../assets/previews/characters/dlc5_monster_mushroom_02.png"
        )),
        ("character", "boss09") => Some(include_bytes!("../assets/previews/characters/boss09.png")),
        ("character", "boss03") => Some(include_bytes!("../assets/previews/characters/boss03.png")),
        ("character", "boss06") => Some(include_bytes!("../assets/previews/characters/boss06.png")),
        ("character", "rpg_10004901") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004901.png"
        )),
        ("character", "boss05") => Some(include_bytes!("../assets/previews/characters/boss05.png")),
        ("character", "rpg_minion_escort") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_escort.png"
        )),
        ("character", "boss1014") => {
            Some(include_bytes!("../assets/previews/characters/boss1014.png"))
        }
        ("character", "boss11") => Some(include_bytes!("../assets/previews/characters/boss11.png")),
        ("character", "boss10") => Some(include_bytes!("../assets/previews/characters/boss10.png")),
        ("character", "boss1013") => {
            Some(include_bytes!("../assets/previews/characters/boss1013.png"))
        }
        ("character", "boss1012") => {
            Some(include_bytes!("../assets/previews/characters/boss1012.png"))
        }
        ("character", "boss13") => Some(include_bytes!("../assets/previews/characters/boss13.png")),
        ("character", "hero_close") => Some(include_bytes!(
            "../assets/previews/characters/hero_close.png"
        )),
        ("character", "qiangling_Centaur01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Centaur01.png"
        )),
        ("character", "boss1011") => {
            Some(include_bytes!("../assets/previews/characters/boss1011.png"))
        }
        ("character", "boss12") => Some(include_bytes!("../assets/previews/characters/boss12.png")),
        ("character", "qiangling_Centaur02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Centaur02.png"
        )),
        ("character", "boss1010") => {
            Some(include_bytes!("../assets/previews/characters/boss1010.png"))
        }
        ("character", "death") => Some(include_bytes!("../assets/previews/characters/death.png")),
        ("character", "acg_cloud_water_wand") => Some(include_bytes!(
            "../assets/previews/characters/acg_cloud_water_wand.png"
        )),
        ("character", "hero") => Some(include_bytes!("../assets/previews/characters/hero.png")),
        ("character", "boss1021_1") => Some(include_bytes!(
            "../assets/previews/characters/boss1021_1.png"
        )),
        ("character", "zhaoyun") => {
            Some(include_bytes!("../assets/previews/characters/zhaoyun.png"))
        }
        ("character", "rpg_skin_bookofdoom_magic_elf") => Some(include_bytes!(
            "../assets/previews/characters/rpg_skin_bookofdoom_magic_elf.png"
        )),
        ("character", "acg_cube_wood") => Some(include_bytes!(
            "../assets/previews/characters/acg_cube_wood.png"
        )),
        ("character", "attendant") => Some(include_bytes!(
            "../assets/previews/characters/attendant.png"
        )),
        ("character", "rpg_pet_tsxd2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_pet_tsxd2.png"
        )),
        ("character", "rpg_pet_tsxd1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_pet_tsxd1.png"
        )),
        ("character", "yuetu") => Some(include_bytes!("../assets/previews/characters/yuetu.png")),
        ("character", "mercenary_1") => Some(include_bytes!(
            "../assets/previews/characters/mercenary_1.png"
        )),
        ("character", "cat") => Some(include_bytes!("../assets/previews/characters/cat.png")),
        ("character", "mercenary_2") => Some(include_bytes!(
            "../assets/previews/characters/mercenary_2.png"
        )),
        ("character", "boss1019") => {
            Some(include_bytes!("../assets/previews/characters/boss1019.png"))
        }
        ("character", "feihu") => Some(include_bytes!("../assets/previews/characters/feihu.png")),
        ("character", "boss1018") => {
            Some(include_bytes!("../assets/previews/characters/boss1018.png"))
        }
        ("character", "boss1017") => {
            Some(include_bytes!("../assets/previews/characters/boss1017.png"))
        }
        ("character", "bs_zhizhujing") => Some(include_bytes!(
            "../assets/previews/characters/bs_zhizhujing.png"
        )),
        ("character", "rpg_jack5") => Some(include_bytes!(
            "../assets/previews/characters/rpg_jack5.png"
        )),
        ("character", "boss1015") => {
            Some(include_bytes!("../assets/previews/characters/boss1015.png"))
        }
        ("character", "rpg_10003701") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10003701.png"
        )),
        ("character", "longnv") => Some(include_bytes!("../assets/previews/characters/longnv.png")),
        ("character", "boss1003") => {
            Some(include_bytes!("../assets/previews/characters/boss1003.png"))
        }
        ("character", "qiangling_gulang") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_gulang.png"
        )),
        ("character", "qiangling_shenghui") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_shenghui.png"
        )),
        ("character", "boss1002") => {
            Some(include_bytes!("../assets/previews/characters/boss1002.png"))
        }
        ("character", "boss1001") => {
            Some(include_bytes!("../assets/previews/characters/boss1001.png"))
        }
        ("character", "sas") => Some(include_bytes!("../assets/previews/characters/sas.png")),
        ("character", "kuangtuzhongzhuang") => Some(include_bytes!(
            "../assets/previews/characters/kuangtuzhongzhuang.png"
        )),
        ("character", "dragoon03_c") => Some(include_bytes!(
            "../assets/previews/characters/dragoon03_c.png"
        )),
        ("character", "dragoon03_b") => Some(include_bytes!(
            "../assets/previews/characters/dragoon03_b.png"
        )),
        ("character", "rpg_bookofdoom2") => Some(include_bytes!(
            "../assets/previews/characters/rpg_bookofdoom2.png"
        )),
        ("character", "rpg_bookofdoom1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_bookofdoom1.png"
        )),
        ("character", "rpg_pet_tsxd1_1") => Some(include_bytes!(
            "../assets/previews/characters/rpg_pet_tsxd1_1.png"
        )),
        ("character", "bossjy4000") => Some(include_bytes!(
            "../assets/previews/characters/bossjy4000.png"
        )),
        ("character", "meat") => Some(include_bytes!("../assets/previews/characters/meat.png")),
        ("character", "rpg_10004804") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004804.png"
        )),
        ("character", "bossjy3003_1") => Some(include_bytes!(
            "../assets/previews/characters/bossjy3003_1.png"
        )),
        ("character", "rpg_10004803") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004803.png"
        )),
        ("character", "boss1009") => {
            Some(include_bytes!("../assets/previews/characters/boss1009.png"))
        }
        ("character", "boss1008") => {
            Some(include_bytes!("../assets/previews/characters/boss1008.png"))
        }
        ("character", "boss1007") => {
            Some(include_bytes!("../assets/previews/characters/boss1007.png"))
        }
        ("character", "boss1006") => {
            Some(include_bytes!("../assets/previews/characters/boss1006.png"))
        }
        ("character", "boss1005") => {
            Some(include_bytes!("../assets/previews/characters/boss1005.png"))
        }
        ("character", "rpg_10004802") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004802.png"
        )),
        ("character", "boss1004") => {
            Some(include_bytes!("../assets/previews/characters/boss1004.png"))
        }
        ("character", "chansi") => Some(include_bytes!("../assets/previews/characters/chansi.png")),
        ("character", "rpg_10004801") => Some(include_bytes!(
            "../assets/previews/characters/rpg_10004801.png"
        )),
        ("character", "carrot") => Some(include_bytes!("../assets/previews/characters/carrot.png")),
        ("character", "jinjiao") => {
            Some(include_bytes!("../assets/previews/characters/jinjiao.png"))
        }
        ("character", "yinjiao") => {
            Some(include_bytes!("../assets/previews/characters/yinjiao.png"))
        }
        ("character", "xianhu") => Some(include_bytes!("../assets/previews/characters/xianhu.png")),
        ("character", "huanling") => {
            Some(include_bytes!("../assets/previews/characters/huanling.png"))
        }
        ("character", "huanyu") => Some(include_bytes!("../assets/previews/characters/huanyu.png")),
        ("character", "dlc_cyber_shield_01") => Some(include_bytes!(
            "../assets/previews/characters/dlc_cyber_shield_01.png"
        )),
        ("character", "rpg_minion_woman_01") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_woman_01.png"
        )),
        ("character", "rpg_minion_officer_02") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_officer_02.png"
        )),
        ("character", "rpg_minion_woman_02") => Some(include_bytes!(
            "../assets/previews/characters/rpg_minion_woman_02.png"
        )),
        ("character", "dlc6_bs_train") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_bs_train.png"
        )),
        ("character", "fes25_cehua03") => Some(include_bytes!(
            "../assets/previews/characters/fes25_cehua03.png"
        )),
        ("character", "dlc6_bs_snake") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_bs_snake.png"
        )),
        ("character", "dlc6_bs_cube") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_bs_cube.png"
        )),
        ("character", "fes25_cehua01") => Some(include_bytes!(
            "../assets/previews/characters/fes25_cehua01.png"
        )),
        ("character", "fes25_cehua01_1") => Some(include_bytes!(
            "../assets/previews/characters/fes25_cehua01_1.png"
        )),
        ("character", "fes25_cehua01_2") => Some(include_bytes!(
            "../assets/previews/characters/fes25_cehua01_2.png"
        )),
        ("character", "chixia1") => {
            Some(include_bytes!("../assets/previews/characters/chixia1.png"))
        }
        ("character", "ct_knight1") => Some(include_bytes!(
            "../assets/previews/characters/ct_knight1.png"
        )),
        ("character", "ct_navy") => {
            Some(include_bytes!("../assets/previews/characters/ct_navy.png"))
        }
        ("character", "t_pirate") => {
            Some(include_bytes!("../assets/previews/characters/t_pirate.png"))
        }
        ("character", "dlc6_bs_toydragon") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_bs_toydragon.png"
        )),
        ("character", "dlc_bs_cactus") => Some(include_bytes!(
            "../assets/previews/characters/dlc_bs_cactus.png"
        )),
        ("character", "t_qingci") => {
            Some(include_bytes!("../assets/previews/characters/t_qingci.png"))
        }
        ("character", "ct_wuya") => {
            Some(include_bytes!("../assets/previews/characters/ct_wuya.png"))
        }
        ("character", "ct_ziyan") => {
            Some(include_bytes!("../assets/previews/characters/ct_ziyan.png"))
        }
        ("character", "spring_bs_cenTaurus") => Some(include_bytes!(
            "../assets/previews/characters/spring_bs_cenTaurus.png"
        )),
        ("character", "spring_bs_redbag") => Some(include_bytes!(
            "../assets/previews/characters/spring_bs_redbag.png"
        )),
        ("character", "dlc6_gtx_9090") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_gtx_9090.png"
        )),
        ("character", "dlc6_bs_book") => Some(include_bytes!(
            "../assets/previews/characters/dlc6_bs_book.png"
        )),
        ("character", "dlc7_boss_steamWhale") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_boss_steamWhale.png"
        )),
        ("character", "dlc7_bs_shuimu") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_bs_shuimu.png"
        )),
        ("character", "dlc7_ms_qingyu") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_ms_qingyu.png"
        )),
        ("character", "dlc7_ms_fuyou") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_ms_fuyou.png"
        )),
        ("character", "dlc7_elite_liechao") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_elite_liechao.png"
        )),
        ("character", "dlc7_bs_najia") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_bs_najia.png"
        )),
        ("character", "t_mask") => Some(include_bytes!("../assets/previews/characters/t_mask.png")),
        ("character", "ct_mask") => {
            Some(include_bytes!("../assets/previews/characters/ct_mask.png"))
        }
        ("character", "qiangling_Jianilu") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Jianilu.png"
        )),
        ("character", "qiangling_Cube") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Cube.png"
        )),
        ("character", "qiangling_Recipe") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Recipe.png"
        )),
        ("character", "qiangling_Top01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Top01.png"
        )),
        ("character", "qiangling_Top02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Top02.png"
        )),
        ("character", "qiangling_Toy01") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Toy01.png"
        )),
        ("character", "qiangling_Toy02") => Some(include_bytes!(
            "../assets/previews/characters/qiangling_Toy02.png"
        )),
        ("character", "dlc7_bs_daisi") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_bs_daisi.png"
        )),
        ("character", "sakura") => Some(include_bytes!("../assets/previews/characters/sakura.png")),
        ("character", "miko") => Some(include_bytes!("../assets/previews/characters/miko.png")),
        ("character", "t_xise") => Some(include_bytes!("../assets/previews/characters/t_xise.png")),
        ("character", "dlc7_boss_kelaken") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_boss_kelaken.png"
        )),
        ("character", "dlc7_ms_kelaken") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_ms_kelaken.png"
        )),
        ("character", "dlc7_boss_shanhu") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_boss_shanhu.png"
        )),
        ("character", "dlc7_bs_mecha") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_bs_mecha.png"
        )),
        ("character", "dlc7_boss_driver") => Some(include_bytes!(
            "../assets/previews/characters/dlc7_boss_driver.png"
        )),
        ("character", "dlc8_boss_hcyl") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_boss_hcyl.png"
        )),
        ("character", "dlc8_guai_nushou") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_guai_nushou.png"
        )),
        ("character", "dlc8_guai_tmsr") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_guai_tmsr.png"
        )),
        ("character", "dlc8_guai_jiachong") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_guai_jiachong.png"
        )),
        ("character", "dlc8_guai_hmsj") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_guai_hmsj.png"
        )),
        ("character", "ct_knight1_2") => Some(include_bytes!(
            "../assets/previews/characters/ct_knight1_2.png"
        )),
        ("character", "dlc8_boss_hzc") => Some(include_bytes!(
            "../assets/previews/characters/dlc8_boss_hzc.png"
        )),
        ("map", "maps/map43") => Some(include_bytes!("../assets/previews/maps/map43.png")),
        ("map", "maps/map12") => Some(include_bytes!("../assets/previews/maps/map12.png")),
        ("map", "maps/map791") => Some(include_bytes!("../assets/previews/maps/map791.png")),
        ("map", "maps/map1") => Some(include_bytes!("../assets/previews/maps/map1.png")),
        _ => crate::previews_spray::bytes(kind, key),
    }
}
