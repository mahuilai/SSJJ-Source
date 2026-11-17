# -*- coding: utf-8 -*-
"""拆分 OfflineBotAI.cs：类型区(L1-343) + Agent 字段区，输出到临时文件供新文件拼装。"""
import io, os, re

SRC = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Assets\Decompiled\OfflineBotAI.cs'
OUTDIR = r'D:\逆向\SSJJ双塔惊魂\_work\bot_split'
os.makedirs(OUTDIR, exist_ok=True)

s = io.open(SRC, encoding='utf-8', errors='surrogatepass').read()
lines = s.split('\n')

# 1) 类型区：文件头到 class OfflineBotAgent 之前
i_agent = s.find('class OfflineBotAgent')
# 往前找该行行首
line_start = s.rfind('\n', 0, i_agent) + 1
types_block = s[:line_start]

# 2) Agent 字段区：class 声明行到 Tick 方法前
i_tick = s.find('public BotIntent Tick(')
assert i_tick > line_start
fields_block = s[line_start:i_tick]

io.open(os.path.join(OUTDIR, 'types.txt'), 'w', encoding='utf-8', errors='surrogatepass').write(types_block)
io.open(os.path.join(OUTDIR, 'agent_fields.txt'), 'w', encoding='utf-8', errors='surrogatepass').write(fields_block)

print('types 区:', types_block.count('\n'), '行')
print('agent 字段区:', fields_block.count('\n'), '行')
print()
print('=== types 末尾 5 行 ===')
print('\n'.join(types_block.split('\n')[-6:]))
print()
print('=== agent 字段区开头 12 行 ===')
print('\n'.join(fields_block.split('\n')[:12]))
print()
print('=== agent 字段区末尾 8 行 ===')
print('\n'.join(fields_block.split('\n')[-9:]))
