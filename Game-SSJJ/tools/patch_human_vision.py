# -*- coding: utf-8 -*-
"""[OFFLINE-VISION] bot 视觉拟人化：呼吸微晃 + 随机扫视 + 反应过冲。

核心设计：视线（ViewYaw）与弹道（AimYaw）分离。
  - it.AimYaw/AimPitch = 弹道（命中判定 it.AimErrorDeg <= angRadius 用它，必须准）
  - it.ViewYaw/ViewPitch = 视线（写 data.ViewYaw -> SyncOfflineAnimStates 的
    orientation.Yaw/Pitch -> 头部/上身朝向，负责"像人"）
执行层两处 data.ViewYaw = it.AimYaw 改为 it.ViewYaw。

晃动源：
  1) 呼吸微晃（常驻）：双频正弦，幅度随难度（easy ~1.1° / hell ~0.4°）
  2) 随机扫视（非交战状态）：每 3~7s 一次 ±20~35° 快速扫出再回正
  3) 反应过冲：SpringAim 临界阻尼 ζ=1 -> ζ≈0.85（人瞄准有过冲回修）
另修：launch_config god_mode=true（启动链 OfflineGameController:808 用
setting.GodMode 覆盖静态字段，之前配置里是 false 导致无敌全程失效）。
"""
import io, json

AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
GP = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameplay.cs'

# ================= 1) BotIntent 加视线字段 =================
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()
old = '''	public float MoveForward = 1f;
	public float MoveRight = 0f;'''
new = '''	public float MoveForward = 1f;
	public float MoveRight = 0f;
	// [OFFLINE-VISION] 视线（视觉朝向）：默认=弹道。执行层写 data.ViewYaw 驱动
	// 头部/上身；弹道 AimYaw 保持精准不受晃动影响（命中判定只用 AimYaw）。
	public float ViewYaw;
	public float ViewPitch;'''
assert old in s, 'BotIntent anchor missing'
s = s.replace(old, new, 1)

# ================= 2) Agent 加扫视状态 =================
old = '''	public uint DriftSeed;'''
new = '''	public uint DriftSeed;
	// [OFFLINE-VISION] 随机扫视：到点快速扫出再回正（人眼珠不时飘一下）
	public float NextScan;
	public float ScanEnd;
	public float ScanDur;
	public float ScanMag;'''
assert old in s, 'DriftSeed anchor missing'
s = s.replace(old, new, 1)

# ================= 3) Tick：扫视调度 + 视线输出 =================
old = '''		it.AimYaw = AimYaw + ErrYaw;
		it.AimPitch = AimPitch + ErrPitch;'''
new = '''		it.AimYaw = AimYaw + ErrYaw;
		it.AimPitch = AimPitch + ErrPitch;

		// [OFFLINE-VISION] 视线拟人化：呼吸微晃 + 随机扫视（只动 ViewYaw，不动弹道）
		// 呼吸：双频正弦，越准的 bot 晃得越少（easy ~1.1° / hell ~0.4°）
		float breathAmp = 0.30f + (1f - Mathf.Clamp01(p.AimSkill)) * 0.85f;
		float breath = Mathf.Sin(now * 1.9f + Id * 1.3f) * breathAmp
			+ Mathf.Sin(now * 6.3f + Id * 2.1f) * breathAmp * 0.32f;
		// 扫视：非交战/非掩体状态每 3~7s 一次；sin(πk) 扫出再回正
		if (NextScan <= 0f) NextScan = now + UnityEngine.Random.Range(2f, 6f);
		if (now >= NextScan && State != BotState.Combat && State != BotState.TakeCover
			&& State != BotState.Reload && bestId < 0)
		{
			NextScan = now + UnityEngine.Random.Range(3f, 7f);
			ScanDur = UnityEngine.Random.Range(0.14f, 0.24f);
			ScanEnd = now + ScanDur;
			ScanMag = (UnityEngine.Random.value < 0.5f ? -1f : 1f) * UnityEngine.Random.Range(20f, 38f);
		}
		float scanOff = 0f;
		if (now < ScanEnd && ScanDur > 0f)
		{
			float k = 1f - (ScanEnd - now) / ScanDur;
			scanOff = Mathf.Sin(k * Mathf.PI) * ScanMag;
		}
		it.ViewYaw = it.AimYaw + breath + scanOff;
		it.ViewPitch = Mathf.Clamp(it.AimPitch + breath * 0.35f, -80f, 80f);'''
assert old in s, 'Tick output anchor missing'
s = s.replace(old, new, 1)

# ================= 4) SpringAim 反应过冲 =================
old = '''		float accY = w * w * dYaw - 2f * w * AimVelYaw;
		float accP = w * w * dPitch - 2f * w * AimVelPitch;'''
new = '''		// [OFFLINE-VISION] ζ≈0.85（原临界阻尼 ζ=1 无过冲）：人抬手瞄准会过冲
		// 再回修，这是"活人"与"伺服电机"最直观的差别。
		float accY = w * w * dYaw - 1.7f * w * AimVelYaw;
		float accP = w * w * dPitch - 1.7f * w * AimVelPitch;'''
assert old in s, 'SpringAim anchor missing'
s = s.replace(old, new, 1)

# ================= 5) ResetForRespawn 重置 =================
old = '''		ErrYaw = 0f; ErrPitch = 0f; ErrTgtYaw = 0f; ErrTgtPitch = 0f; ErrNextTgt = 0f;'''
new = '''		ErrYaw = 0f; ErrPitch = 0f; ErrTgtYaw = 0f; ErrTgtPitch = 0f; ErrNextTgt = 0f;
		NextScan = 0f; ScanEnd = 0f; ScanDur = 0f; ScanMag = 0f;'''
assert old in s, 'Reset anchor missing'
s = s.replace(old, new, 1)
io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('OfflineBotAI.cs vision patched')

# ================= 6) 执行层：data.ViewYaw 用视线 =================
g = io.open(GP, encoding='utf-8', errors='surrogatepass').read()
old = '''        // 朝向写回快照（第三人称模型转身靠它）
        data.ViewYaw = it.AimYaw;'''
new = '''        // 朝向写回快照（第三人称模型转身靠它）
        // [OFFLINE-VISION] 视线=ViewYaw（含呼吸/扫视晃动），弹道 AimYaw 保持精准
        data.ViewYaw = it.ViewYaw;'''
assert old in g, 'ViewYaw write anchor missing'
g = g.replace(old, new, 1)

old = '''        data.MoveYaw = it.MoveYaw;
        data.ViewYaw = it.AimYaw;'''
new = '''        data.MoveYaw = it.MoveYaw;
        data.ViewYaw = it.ViewYaw;   // [OFFLINE-VISION] 视线（含晃动）'''
assert old in g, 'BspStep ViewYaw anchor missing'
g = g.replace(old, new, 1)
io.open(GP, 'w', encoding='utf-8', errors='surrogatepass').write(g)
print('OfflineGameplay.cs ViewYaw wired')

# ================= 7) launch_config god_mode=true =================
CFG = r'D:\SSJJ-4399\battle\3_64\launch_config.json'
d = json.load(io.open(CFG, encoding='utf-8'))
if d.get('god_mode') is not True:
    d['god_mode'] = True
    json.dump(d, io.open(CFG, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print('launch_config god_mode -> true')
else:
    print('launch_config god_mode already true')
