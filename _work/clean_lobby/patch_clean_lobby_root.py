# -*- coding: utf-8 -*-
p = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src\CleanLobbyRoot.as"
with open(p, "r", encoding="utf-8") as f:
    text = f.read()

# Add logToServer helper
helper = '''      public static function logToServer(msg:String) : void
      {
         try {
            var ul:URLLoader = new URLLoader();
            ul.load(new URLRequest(BASE_URL + "__log?msg=" + encodeURIComponent(msg)));
         } catch(e:Error) {}
         trace("[CleanLobby] " + msg);
      }
'''

if "public static function logToServer" not in text:
    target_cls = "public class CleanLobbyRoot extends Sprite\n   {"
    replacement = target_cls + "\n" + helper
    text = text.replace(target_cls, replacement, 1)

# Now replace onAllAssetsReady
old_on_all = '''      private function onAllAssetsReady() : void
      {
         setLoadingProgress(0.95, "正在构建原版主界面与 Stage3D 3D渲染引擎...");
         _subViews = new CleanSubViews(this);
         buildMainLobbyUI();
         initClientViewStage3D();

         if(_loadingOverlay && _loadingOverlay.parent)
         {
            _loadingOverlay.parent.removeChild(_loadingOverlay);
            _loadingOverlay = null;
         }
         showToast("原版大厅加载完成 · 已解锁全量 " + catalogItems.length + " 件物品与 335 名角色");
      }'''

new_on_all = '''      private function onAllAssetsReady() : void
      {
         logToServer("onAllAssetsReady: entered");
         setLoadingProgress(0.95, "正在构建原版主界面与 Stage3D 3D渲染引擎...");

         try {
            logToServer("onAllAssetsReady: init CleanSubViews");
            _subViews = new CleanSubViews(this);
         } catch(e1:Error) {
            logToServer("CleanSubViews ERROR: " + e1.message);
         }

         try {
            logToServer("onAllAssetsReady: buildMainLobbyUI");
            buildMainLobbyUI();
         } catch(e2:Error) {
            logToServer("buildMainLobbyUI ERROR: " + e2.message + " " + e2.getStackTrace());
         }

         try {
            logToServer("onAllAssetsReady: initClientViewStage3D");
            initClientViewStage3D();
         } catch(e3:Error) {
            logToServer("initClientViewStage3D ERROR: " + e3.message);
         }

         // ALWAYS remove loading overlay so user is NEVER stuck on loading screen
         if(_loadingOverlay && _loadingOverlay.parent)
         {
            _loadingOverlay.parent.removeChild(_loadingOverlay);
            _loadingOverlay = null;
         }
         logToServer("onAllAssetsReady: overlay removed successfully!");
         showToast("原版大厅加载完成 · 已解锁全量 " + catalogItems.length + " 件物品与 335 名角色");
      }'''

if old_on_all in text:
    text = text.replace(old_on_all, new_on_all, 1)
    print("SUCCESS: replaced onAllAssetsReady")
else:
    print("WARNING: old_on_all not found")

with open(p, "w", encoding="utf-8") as f:
    f.write(text)
print("Updated CleanLobbyRoot.as")
