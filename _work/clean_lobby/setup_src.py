# -*- coding: utf-8 -*-
import os, shutil, sys, re

sys.stdout.reconfigure(encoding='utf-8')

LOBBY_SRC = r"D:\逆向\SSJJ双塔惊魂\资源下载\大厅资源\SSJJ-main\export\Lobby\src"
CLEAN_SRC = r"D:\逆向\SSJJ双塔惊魂\_work\clean_lobby\src"

if os.path.exists(CLEAN_SRC):
    shutil.rmtree(CLEAN_SRC)
os.makedirs(CLEAN_SRC, exist_ok=True)

for pkg in ["ui", "style", "utils", "fl", "editor", os.path.join("com", "greensock")]:
    s = os.path.join(LOBBY_SRC, pkg)
    d = os.path.join(CLEAN_SRC, pkg)
    os.makedirs(os.path.dirname(d), exist_ok=True)
    shutil.copytree(s, d)
    print(f"[setup_src] Copied package {pkg} -> {d}")

# 1. Make UIContainer and ui.core.UIComponent dynamic so XML child names can be attached directly
for rel in [os.path.join("ui", "UIContainer.as"), os.path.join("ui", "core", "UIComponent.as")]:
    fp = os.path.join(CLEAN_SRC, rel)
    txt = open(fp, "r", encoding="utf-8").read()
    txt = txt.replace("public class ", "public dynamic class ")
    open(fp, "w", encoding="utf-8").write(txt)
    print(f"[setup_src] Made {rel} dynamic")

# 2. Replace style/I18NConfig.as with standalone dictionary implementation
i18n_code = '''package style
{
   public class I18NConfig
   {
      public static var dic:Object = {
         "WORD_19": "宋体",
         "WORD_20": "微软雅黑",
         "WORD_258": "点券",
         "WORD_280": "主武器",
         "WORD_283": "修理",
         "WORD_284": "卸下",
         "WORD_604": "购物车",
         "WORD_605": "激活码",
         "WORD_606": "礼券",
         "WORD_609": "武器",
         "WORD_610": "角色",
         "WORD_611": "道具",
         "WORD_612": "礼包",
         "WORD_735": "GP",
         "WORD_999": "个人仓库",
         "WORD_1630": "前往商城",
         "WORD_8477": "皮肤"
      };

      public function I18NConfig()
      {
         super();
      }

      public static function loadProperties(raw:String) : void
      {
         if(!raw) return;
         var lines:Array = raw.split("\\n");
         for(var i:int = 0; i < lines.length; i++)
         {
            var line:String = lines[i];
            var eq:int = line.indexOf("=");
            if(eq > 0)
            {
               var k:String = line.substring(0, eq).replace(/^\\s+|\\s+$/g, "");
               if(k.charCodeAt(0) == 0xFEFF) k = k.substring(1);
               var v:String = line.substring(eq + 1).replace(/\\r/g, "");
               dic[k] = v;
            }
         }
      }

      public static function getText(param1:String) : String
      {
         if(param1 == null) return "";
         if(dic[param1] != null) return String(dic[param1]);
         return param1;
      }
   }
}
'''
open(os.path.join(CLEAN_SRC, "style", "I18NConfig.as"), "w", encoding="utf-8").write(i18n_code)
print("[setup_src] Wrote standalone style/I18NConfig.as")

# 3. Patch utils/UIUtil.as:
#    - recursive className resolution from rootXml for <UIComponent className="..."/>
#    - safe dynamic property read/write
#    - direct ApplicationDomain.currentDomain symbol resolution
uiutil_path = os.path.join(CLEAN_SRC, "utils", "UIUtil.as")
txt = open(uiutil_path, "r", encoding="utf-8").read()

txt = txt.replace(
    "public static function initUI(param1:DisplayObjectContainer, param2:XML) : void\n      {",
    "public static function initUI(param1:DisplayObjectContainer, param2:XML, rootXml:XML = null) : void\n      {\n         if(rootXml == null) { rootXml = param2; }"
).replace(
    "public static function initUI(param1:DisplayObjectContainer, param2:XML) : void\r\n      {",
    "public static function initUI(param1:DisplayObjectContainer, param2:XML, rootXml:XML = null) : void\r\n      {\r\n         if(rootXml == null) { rootXml = param2; }"
)

txt = re.sub(
    r'if\(_loc4_ != ""\)\s*\{\s*_loc3_ = param1\[_loc4_\];\s*\}',
    'if(_loc4_ != "" && (_loc4_ in param1)) { try { _loc3_ = param1[_loc4_]; } catch(e:Error) {} }',
    txt
)

txt = re.sub(
    r'case "UIComponent":.*?break;',
    '''case "UIComponent":
                  if(_loc4_ != "" && (_loc4_ in param1))
                  {
                     try { _loc3_ = param1[_loc4_]; } catch(e:Error) {}
                  }
                  if(!_loc3_)
                  {
                     var _clsName:String = String(_loc7_.@className);
                     if(_clsName != "" && rootXml != null && rootXml[_clsName].length() > 0)
                     {
                        var _subComp:UIContainer = new UIContainer();
                        initUI(_subComp, rootXml[_clsName][0], rootXml);
                        _loc3_ = _subComp;
                     }
                     else if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     if(!_loc3_)
                     {
                        _loc3_ = new UIContainer();
                     }
                  }
                  break;''',
    txt,
    flags=re.S
)

txt = re.sub(
    r'case "ExtComponent":.*?break;',
    '''case "ExtComponent":
                  if(!_loc3_)
                  {
                     if(String(_loc7_.@definition) != "")
                     {
                        _loc3_ = getInstance(_loc7_.@definition);
                     }
                     if(!_loc3_)
                     {
                        _loc3_ = new UIContainer();
                     }
                  }
                  break;''',
    txt,
    flags=re.S
)

txt = re.sub(
    r'if\(_loc4_ != ""\)\s*\{\s*param1\[_loc4_\] = _loc3_;\s*_loc3_\.name = _loc4_;\s*\}',
    'if(_loc4_ != "") { try { param1[_loc4_] = _loc3_; } catch(e:Error) {} _loc3_.name = _loc4_; }',
    txt
)

txt = re.sub(
    r'public static function getDefinition\(param1:String\)\s*:\s*\*.*?return _loc5_;\s*\}',
    '''public static function getDefinition(param1:String) : *
      {
         var _loc2_:Class = null;
         try
         {
            _loc2_ = getGameDefinitionByName(param1) as Class;
            if(_loc2_ == null)
            {
               _loc2_ = getDefinitionByAssetClass(param1);
            }
            return _loc2_;
         }
         catch(error:Error)
         {
            var _loc5_:* = null;
         }
         return _loc5_;
      }''',
    txt,
    flags=re.S
)
open(uiutil_path, "w", encoding="utf-8").write(txt)
print("[setup_src] Patched utils/UIUtil.as")

# 4. Patch AssetManager.as so missing BitmapData never throws fatal error
am_path = os.path.join(CLEAN_SRC, "ui", "managers", "AssetManager.as")
am_txt = open(am_path, "r", encoding="utf-8").read()
am_txt = am_txt.replace(
    'throw new Error("NULL BitmapData:" + param1);',
    '_loc6_.data = new BitmapData(1,1,true,0); _loc6_.type = 2;'
)
open(am_path, "w", encoding="utf-8").write(am_txt)
print("[setup_src] Patched ui/managers/AssetManager.as")
