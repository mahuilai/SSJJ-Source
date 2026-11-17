# -*- coding: utf-8 -*-
p = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src\ui\managers\RenderManager.as"
with open(p, "r", encoding="utf-8") as f:
    text = f.read()

target1 = 'UICommon.stage.addEventListener("render",onValidate);'
replace1 = '''if(UICommon.stage != null) {
            UICommon.stage.addEventListener("render",onValidate);
            UICommon.stage.addEventListener("enterFrame",onValidate);
            UICommon.stage.invalidate();
         } else {
            renderAll();
            return;
         }'''

# Also remove the next 2 lines
target2 = '''         UICommon.stage.addEventListener("enterFrame",onValidate);
         if(UICommon.stage)
         {
            UICommon.stage.invalidate();
         }'''

text = text.replace(target2, "")
text = text.replace(target1, replace1)

# In onValidate:
target3 = 'UICommon.stage.removeEventListener("render",onValidate);'
replace3 = '''if(UICommon.stage != null) {
            UICommon.stage.removeEventListener("render",onValidate);
            UICommon.stage.removeEventListener("enterFrame",onValidate);
         }'''
target4 = 'UICommon.stage.removeEventListener("enterFrame",onValidate);'

text = text.replace(target4, "")
text = text.replace(target3, replace3)

with open(p, "w", encoding="utf-8") as f:
    f.write(text)
print("RenderManager.as patched successfully!")
