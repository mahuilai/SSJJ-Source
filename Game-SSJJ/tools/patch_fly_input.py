# -*- coding: utf-8 -*-
"""[OFFLINE-FLY2] 修复 F 飞行在地图外/死亡态动不了。

根因：GetPlayerOffes 的飞行输入源是 UserCommand（cmd.MoveForward/MoveRight），
而原版 UserCommandInitSystem 在玩家掉出世界/死亡/不可移动状态时不下发移动输入
（恒 0）→ 位移公式全 0 → SetPosition 原地不动。

修复：键盘直读（WASD + Space 升 + C/左Ctrl 降），yaw/pitch 从实体 orientation
读（离线链路 SyncOfflineAnimStates 每帧写，比 cmd 可靠），升降叠加到 Z 轴
（SSJJ 原生 X/Y 水平、Z 高度，正 Z=上）。加限频坐标日志供实机验证。
"""
import io

P = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineGameController.cs'
s = io.open(P, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-FLY2' in s:
    print('already patched, skip')
    raise SystemExit

# ---- 1) 类字段区加日志限频字段（挨着 s_moveLog）----
old = re.search(r'private static int s_moveLog;', s).group(0)
new = old + '
	 private static int s_flyLogN;
	 private static float s_flyLogT;'
assert old in s, 's_moveLog anchor missing'
s = s.replace(old, new, 1)

# ---- 2) 替换 GetPlayerOffes 的 isFly 块 ----
i = s.find('public static void GetPlayerOffes')
assert i > 0, 'GetPlayerOffes not found'
j = s.find('float num = (float)(cmd.CameraYaw / 100)', i)
assert j > 0, 'fly formula start not found'
k = s.find('adapter.SetPosition((float)adapter.GetX()', j)
assert k > 0, 'fly SetPosition not found'
kend = s.find(';', k) + 1
old_block = s[j:kend]

new_block = '''// [OFFLINE-FLY2] 键盘直读：地图外/死亡态 UserCommand 不下发移动输入（cmd 恒 0），
\t\t\t// 旧实现从此飞不动。yaw/pitch 从实体 orientation 读（离线链路每帧写，比 cmd 可靠）。
\t\t\tfloat mf = 0f, mr = 0f, up = 0f;
\t\t\tif (Input.GetKey(KeyCode.W)) mf += 100f;
\t\t\tif (Input.GetKey(KeyCode.S)) mf -= 100f;
\t\t\tif (Input.GetKey(KeyCode.D)) mr += 100f;
\t\t\tif (Input.GetKey(KeyCode.A)) mr -= 100f;
\t\t\tif (Input.GetKey(KeyCode.Space)) up += 100f;
\t\t\tif (Input.GetKey(KeyCode.C) || Input.GetKey(KeyCode.LeftControl)) up -= 100f;
\t\t\tfloat yawDeg = (float)(cmd.CameraYaw / 100);
\t\t\tfloat pitDeg = (float)(cmd.CameraPitch / 100);
\t\t\ttry
\t\t\t{
\t\t\t\tPlayerEntity meF = Contexts.sharedInstance.player.myPlayerEntity;
\t\t\t\tif (meF != null && meF.hasOrientation)
\t\t\t\t{
\t\t\t\t\tyawDeg = meF.orientation.Yaw;
\t\t\t\t\tpitDeg = meF.orientation.Pitch;
\t\t\t\t}
\t\t\t}
\t\t\tcatch (System.Exception) { }
\t\t\tfloat num = yawDeg * 0.01745f;
\t\t\tfloat num2 = (float)(90 - pitDeg) * 0.01745f;
\t\t\tfloat num3 = (yawDeg - 90f) * 0.01745f;
\t\t\tfloat num4 = Mathf.Sin(num2) * (Mathf.Cos(num) * mf + Mathf.Cos(num3) * mr) * 0.001f;
\t\t\tfloat num5 = Mathf.Sin(num2) * (Mathf.Sin(num) * mf + Mathf.Sin(num3) * mr) * 0.001f;
\t\t\t// Z 轴（SSJJ 原生高度，正=上）叠升降：平飞时 cos(90-pitch)=0 不漂
\t\t\tfloat num6 = (Mathf.Cos(num2) * (mf + mr) + up) * 0.001f;
\t\t\tadapter.SetPosition((float)adapter.GetX() + num4 * (float)speed, (float)adapter.GetY() + num5 * (float)speed, (float)adapter.GetZ() + num6 * (float)speed);
\t\t\tif (s_flyLogN < 6 || UnityEngine.Time.realtimeSinceStartup - s_flyLogT > 2f)
\t\t\t{
\t\t\t\ts_flyLogN++;
\t\t\t\ts_flyLogT = UnityEngine.Time.realtimeSinceStartup;
\t\t\t\tUnityEngine.Debug.Log("[OFFLINE-FLY] pos=" + adapter.GetX().ToString("F0") + "," + adapter.GetY().ToString("F0") + "," + adapter.GetZ().ToString("F0")
\t\t\t\t\t+ " in=" + mf.ToString("F0") + "/" + mr.ToString("F0") + "/" + up.ToString("F0")
\t\t\t\t\t+ " yaw=" + yawDeg.ToString("F0") + " pit=" + pitDeg.ToString("F0"));
\t\t\t}'''

s = s[:j] + new_block + s[kend:]
io.open(P, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('fly input source replaced')
