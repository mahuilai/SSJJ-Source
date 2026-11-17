# -*- coding: utf-8 -*-
p = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src\utils\UIUtil.as"
with open(p, "r", encoding="utf-8") as f:
    text = f.read()

target = 'param1[_loc5_].addChild(_loc3_);'
replacement = '''if(param1.hasOwnProperty(_loc5_) && param1[_loc5_] != null) {
                        param1[_loc5_].addChild(_loc3_);
                     } else {
                        param1.addChild(_loc3_);
                     }'''

if target in text:
    text = text.replace(target, replacement, 1)
    with open(p, "w", encoding="utf-8") as f:
        f.write(text)
    print("SUCCESS: param1[_loc5_] check added!")
else:
    print("Target not found")
