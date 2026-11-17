# -*- coding: utf-8 -*-
p = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src\CleanLobbyRoot.as"
with open(p, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Remove opaque box in drawFallbackModelPlaceholder
target_box = '''         var box:Sprite = new Sprite();
         box.x = vx;
         box.y = vy;
         box.graphics.beginFill(0x0b1522, 1);
         box.graphics.drawRect(0, 0, vw, vh);
         box.graphics.endFill();'''

replace_box = '''         var box:Sprite = new Sprite();
         box.x = vx;
         box.y = vy;'''

text = text.replace(target_box, replace_box)

# 2. Add logging in buildMainLobbyUI
target_initui = '''         mainView = new UIContainer();
         UIUtil.initUI(mainView, xmlMainView, xmlMainView);
         sceneLayer.addChild(mainView);'''

replace_initui = '''         mainView = new UIContainer();
         logToServer("buildMainLobbyUI: xmlMainView is null? " + (xmlMainView == null));
         try {
            UIUtil.initUI(mainView, xmlMainView, xmlMainView);
            logToServer("buildMainLobbyUI: mainView childCount=" + mainView.numChildren);
         } catch(eInitUI:Error) {
            logToServer("buildMainLobbyUI initUI CRASH: " + eInitUI.message + " " + eInitUI.getStackTrace());
         }
         sceneLayer.addChild(mainView);'''

text = text.replace(target_initui, replace_initui)

with open(p, "w", encoding="utf-8") as f:
    f.write(text)
print("patch 3 applied!")
