# -*- coding: utf-8 -*-
"""[OFFLINE-GDIAG] PlanGrenade 决策诊断：每个 bot 每 5 秒最多一条，记录卡在哪道门。"""
import io, sys

AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-GDIAG' in s:
    print('already patched')
    sys.exit(0)

NL = chr(10)
T = chr(9)

# 1) 字段：每 agent 一个诊断时间
anchor = '	public float NextGrenade;'
assert anchor in s, 'anchor field missing'
s = s.replace(anchor, anchor + NL + '	private float _gdNext;   // [OFFLINE-GDIAG]', 1)

# 2) PlanGrenade 开头插入诊断（放在所有 return 之前，逐门记录）
old = '''	private void PlanGrenade(BotProfile p, BotWorld w, BotThreat best, int bestId, bool engaged,
		float hpRatio, Vector3 self, float now, BotIntent it)
	{
		if (!engaged || bestId < 0 || p.Melee) return;
		if (w == null || !w.MatchActive) return;
		if (State == BotState.Reload) return;
		if (now < NextGrenade) return;

		float d = Vector3.Distance(self, best.Pos);
		if (d < 7f || d > 24f) return;   // 太近自伤、太远扔不到'''

new = '''	private void PlanGrenade(BotProfile p, BotWorld w, BotThreat best, int bestId, bool engaged,
		float hpRatio, Vector3 self, float now, BotIntent it)
	{
		// [OFFLINE-GDIAG] 逐门诊断（每 5s 一条/bot）
		bool diag = now >= _gdNext;
		if (diag) _gdNext = now + 5f;
		string gate = "";
		if (!engaged || bestId < 0 || p.Melee) gate = "A_eng=" + engaged + ",bid=" + bestId + ",melee=" + p.Melee;
		else if (w == null || !w.MatchActive) gate = "B_world";
		else if (State == BotState.Reload) gate = "C_reload";
		else if (now < NextGrenade) gate = "D_cd=" + (NextGrenade - now).ToString("F1");
		else
		{
			float dd = Vector3.Distance(self, best.Pos);
			if (dd < 7f || dd > 24f) gate = "E_dist=" + dd.ToString("F1");
		}
		if (diag && gate.Length > 0)
			UnityEngine.Debug.Log("[OFFLINE-GDIAG] id=" + Id + " gate=" + gate + " state=" + State);

		if (!engaged || bestId < 0 || p.Melee) return;
		if (w == null || !w.MatchActive) return;
		if (State == BotState.Reload) return;
		if (now < NextGrenade) return;

		float d = Vector3.Distance(self, best.Pos);
		if (d < 7f || d > 24f) return;   // 太近自伤、太远扔不到'''

assert old in s, 'PlanGrenade body anchor missing'
s = s.replace(old, new, 1)

io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('GDIAG patched')
