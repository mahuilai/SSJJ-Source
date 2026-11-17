# -*- coding: utf-8 -*-
p = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src\CleanLobbyRoot.as"
with open(p, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Add import ui.core.UICommon if needed
if "import ui.core.UICommon;" not in text:
    text = text.replace("import ui.core.UIComponent;", "import ui.core.UIComponent;\n   import ui.core.UICommon;")

# 2. In init(): add UICommon.stage = stage; UICommon.init(this);
target_init = '''      private function init(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, init);'''

replace_init = '''      private function init(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, init);
         try {
            UICommon.stage = stage;
            UICommon.init(this);
         } catch(eInit:Error) {}'''

text = text.replace(target_init, replace_init, 1)

with open(p, "w", encoding="utf-8") as f:
    f.write(text)
print("CleanLobbyRoot.as init() updated with UICommon.init!")
