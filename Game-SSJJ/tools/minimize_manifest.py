import json
import os

P = r'D:\逆向\SSJJ双塔惊魂\Game-SSJJ-Source\Packages\manifest.json'
d = json.load(open(P, encoding='utf-8'))
deps = d.get('dependencies', {})

# 只保留引擎模块 + ugui；移除会与 2019.4.11 编译冲突的包
drop = [k for k in list(deps) if not k.startswith('com.unity.modules.') and k != 'com.unity.ugui']
for k in drop:
    deps.pop(k, None)

json.dump(d, open(P, 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print('removed', drop)
print('remaining', len(deps))
