# -*- coding: utf-8 -*-
"""[OFFLINE-MODEL-RANDOM] bot 职业从固定轮换改为每局洗牌随机。

原实现：wantCareer = bot.Careers[i % bot.Careers.Length] —— 每局第一只 bot
永远是 police、第二只 pandora_t……顺序固定，玩家两局就看到重复阵容。

新实现：三个池（Boss/Elite/Normal）各自维护一副洗好的牌，spawn 时按序发牌。
  - 每局开局重洗（SpawnBots 入口重置 deck）
  - Fisher-Yates 洗牌，同池内不重复（数组本身无重复元素）
  - 池切换不互相触发重洗（三个 deck 独立状态）
  - PickBotCareer 的已安装 fallback 加随机起点
"""
import io

P = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\Assets.Sources.Systems.Snapshot\OfflineBotSpawner.cs'
s = io.open(P, encoding='utf-8', errors='surrogatepass').read()

if 'CareerDeck' in s:
    print('already patched, skip')
    raise SystemExit

# ---- 1) 在 InstalledCareers 字段后插入 deck 机制 ----
anchor = '''\t\tprivate static readonly string[] InstalledCareers =
\t\t{
\t\t\t"police", "pandora_t", "feihuwoman", "acg_paila"
\t\t};'''
if anchor not in s:
    # 反编译文件行尾/空白可能有差异，用宽松定位
    import re
    m = re.search(r'private static readonly string\[\] InstalledCareers\s*=\s*\{[^}]*\};', s)
    if not m:
        print('FATAL: InstalledCareers anchor not found')
        raise SystemExit(1)
    anchor = m.group(0)

deck_code = anchor + '''

\t\t// [OFFLINE-MODEL-RANDOM] 职业发牌器：每个池一副洗好的牌，按序发、不重复。
\t\t// 三个池（Boss/Elite/Normal）状态独立，交替 spawn 不会互相触发重洗。
\t\tprivate sealed class CareerDeck
\t\t{
\t\t\tpublic string[] Pool;
\t\t\tpublic int[] Order;
\t\t\tpublic int Pos;
\t\t}

\t\tprivate static readonly CareerDeck _bossDeck = new CareerDeck();
\t\tprivate static readonly CareerDeck _eliteDeck = new CareerDeck();
\t\tprivate static readonly CareerDeck _normalDeck = new CareerDeck();

\t\t/// <summary>重置全部发牌器（每局开局调用，重洗出新阵容）。</summary>
\t\tprivate static void ReshuffleCareerDecks()
\t\t{
\t\t\t_bossDeck.Pool = null;
\t\t\t_eliteDeck.Pool = null;
\t\t\t_normalDeck.Pool = null;
\t\t}

\t\t/// <summary>从池里按洗牌顺序取一个职业；牌摸完或换池自动重洗。</summary>
\t\tprivate static string TakeRandomCareer(CareerDeck deck, string[] pool)
\t\t{
\t\t\tif (pool == null || pool.Length == 0) return null;
\t\t\tif (!object.ReferenceEquals(deck.Pool, pool) || deck.Order == null || deck.Pos >= deck.Order.Length)
\t\t\t{
\t\t\t\tdeck.Pool = pool;
\t\t\t\tdeck.Order = new int[pool.Length];
\t\t\t\tfor (int k = 0; k < pool.Length; k++) deck.Order[k] = k;
\t\t\t\t// Fisher-Yates
\t\t\t\tfor (int k = pool.Length - 1; k > 0; k--)
\t\t\t\t{
\t\t\t\t\tint j = UnityEngine.Random.Range(0, k + 1);
\t\t\t\t\tint t = deck.Order[k]; deck.Order[k] = deck.Order[j]; deck.Order[j] = t;
\t\t\t\t}
\t\t\t\tdeck.Pos = 0;
\t\t\t}
\t\t\treturn pool[deck.Order[deck.Pos++]];
\t\t}'''
s = s.replace(anchor, deck_code, 1)

# ---- 2) spawn 入口重洗（botCareer 赋值行附近，每局一次）----
old2 = '''\t\t\tstring botCareer = (cfg != null && !string.IsNullOrEmpty(cfg.BotCareer)) ? cfg.BotCareer : "police";'''
new2 = '''\t\t\t// [OFFLINE-MODEL-RANDOM] 每局重洗职业牌堆
\t\t\tReshuffleCareerDecks();
\t\t\tstring botCareer = (cfg != null && !string.IsNullOrEmpty(cfg.BotCareer)) ? cfg.BotCareer : "police";'''
if old2 in s:
    s = s.replace(old2, new2, 1)
else:
    print('WARN: botCareer anchor not found (deck reshuffle not wired)')

# ---- 3) 三处轮换改发牌 ----
old3 = '''\t\t\t\tstring wantCareer;
\t\t\t\tif (isBoss && bot.BossCareers != null && bot.BossCareers.Length > 0) wantCareer = bot.BossCareers[i % bot.BossCareers.Length];
\t\t\t\telse if (isElite && bot.EliteCareers != null && bot.EliteCareers.Length > 0) wantCareer = bot.EliteCareers[i % bot.EliteCareers.Length];
\t\t\t\telse if (bot.Careers != null && bot.Careers.Length > 0) wantCareer = bot.Careers[i % bot.Careers.Length];
\t\t\t\telse wantCareer = botCareer;'''
new3 = '''\t\t\t\t// [OFFLINE-MODEL-RANDOM] 按质量分层发牌：首领/精英/普通各自随机不重复
\t\t\t\tstring wantCareer;
\t\t\t\tif (isBoss && bot.BossCareers != null && bot.BossCareers.Length > 0)
\t\t\t\t\twantCareer = TakeRandomCareer(_bossDeck, bot.BossCareers);
\t\t\t\telse if (isElite && bot.EliteCareers != null && bot.EliteCareers.Length > 0)
\t\t\t\t\twantCareer = TakeRandomCareer(_eliteDeck, bot.EliteCareers);
\t\t\t\telse if (bot.Careers != null && bot.Careers.Length > 0)
\t\t\t\t\twantCareer = TakeRandomCareer(_normalDeck, bot.Careers);
\t\t\t\telse wantCareer = botCareer;'''
if old3 in s:
    s = s.replace(old3, new3, 1)
    print('career draw wired')
else:
    print('FATAL: career selection block not found')
    raise SystemExit(1)

# ---- 4) PickBotCareer 的已安装 fallback 加随机起点 ----
old4 = '''\t\t\t\tfor (int i = 0; i < InstalledCareers.Length; i++)
\t\t\t\t{
\t\t\t\t\tstring c = InstalledCareers[(index + i) % InstalledCareers.Length];'''
new4 = '''\t\t\t\t// [OFFLINE-MODEL-RANDOM] fallback 起点也随机，避免固定轮换痕迹
\t\t\t\tint off = UnityEngine.Random.Range(0, InstalledCareers.Length);
\t\t\t\tfor (int i = 0; i < InstalledCareers.Length; i++)
\t\t\t\t{
\t\t\t\t\tstring c = InstalledCareers[(off + index + i) % InstalledCareers.Length];'''
n4 = s.count(old4)
s = s.replace(old4, new4)
print('fallback random-start replacements:', n4)

io.open(P, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('patched OK. CareerDeck refs:', s.count('CareerDeck'), '| TakeRandomCareer:', s.count('TakeRandomCareer'))
