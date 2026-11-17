# -*- coding: utf-8 -*-
"""补丁 C：WantJump/WantCrouch 从 TakeCover 单分支挪到公共汇总区（所有状态都能连跳）。"""
import io, re

AI = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
s = io.open(AI, encoding='utf-8', errors='surrogatepass').read()

if 'OFFLINE-BHOPCOMMON' in s:
    print('C already patched')
    raise SystemExit(0)

# 1) TakeCover 分支里的单点赋值改注释（保留但标记由公共区覆盖）
old_branch = ('\t\tit.WantJump = p.Bhop && it.HasMove;' + '\n'
              + '\t\tit.WantCrouch = p.JumpDuck && it.HasMove;')
new_branch = ('\t\t// [OFFLINE-BHOPCOMMON] 跳/蹲意图统一在下方公共汇总区赋值（所有状态都能连跳），' + '\n'
              + '\t\t// 这里不再单点设置，避免只有 TakeCover 状态会跳。' + '\n'
              + '\t\tit.WantJump = p.Bhop && it.HasMove;' + '\n'
              + '\t\tit.WantCrouch = p.JumpDuck && it.HasMove;')
if old_branch in s:
    s = s.replace(old_branch, new_branch, 1)
    print('branch annotated')

# 2) 公共汇总区（AimErrorDeg 前）强制覆盖：所有状态默认给跳意图
old_common = ('\t\tit.AimErrorDeg = Mathf.Abs(ErrYaw) + Mathf.Abs(ErrPitch);' + '\n'
              + '\t\tit.TargetId = TargetId;')
new_common = ('\t\t// [OFFLINE-BHOPCOMMON] 公共汇总：身法 bot 只要有移动意图就持续给跳意图。' + '\n'
              + '\t\t// ApplyVertical 只在落地帧真正起跳 → 落地自动再跳 = 连跳（CS bhop 机制）。' + '\n'
              + '\t\t// 放在这里保证 Combat/Patrol/Advance/Retreat/TakeCover 全状态生效。' + '\n'
              + '\t\tit.WantJump = p.Bhop && it.HasMove;' + '\n'
              + '\t\tit.WantCrouch = p.JumpDuck && it.HasMove;' + '\n'
              + old_common)
assert old_common in s, 'common anchor missing'
s = s.replace(old_common, new_common, 1)

io.open(AI, 'w', encoding='utf-8', errors='surrogatepass').write(s)
print('C patched: WantJump/WantCrouch in common zone')
# 自检：现在有几处赋值
n = len(re.findall(r'it\.WantJump\s*=', s))
print('WantJump 赋值点数（应为 2：分支+公共）:', n)
