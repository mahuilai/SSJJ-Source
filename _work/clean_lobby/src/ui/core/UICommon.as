package ui.core
{
   import editor.managers.ILocalAssetManager;
   import flash.display.Sprite;
   import flash.display.Stage;
   import style.StyleConfig;
   import ui.UIToolTips;
   import ui.managers.AssetManager;
   import ui.managers.RenderManager;
   import ui.managers.TimerManager;
   
   public class UICommon
   {
      
      public static var stage:Stage;
      
      public static var localAsset:ILocalAssetManager;
      
      public static var stageAgent:Sprite;
      
      public static var stageAgent2:Sprite;
      
      public static var scale:Number = 1;
      
      public static var LOBBY_WIDTH:int = 1024;
      
      public static var LOBBY_HEIGHT:int = 650;
      
      public static var render:RenderManager = new RenderManager();
      
      public static var timer:TimerManager = new TimerManager();
      
      public static var asset:AssetManager = new AssetManager();
      
      public static var style:StyleConfig = new StyleConfig();
      
      public function UICommon()
      {
         super();
      }
      
      public static function init(param1:Sprite) : void
      {
         stage = param1.stage;
         if(param1.hasOwnProperty("stageAgent"))
         {
            stageAgent = param1["stageAgent"];
            stageAgent2 = param1["stageAgent2"];
            scale = param1["lobbyScale"];
            LOBBY_WIDTH = param1["lobbyWidth"];
            LOBBY_HEIGHT = param1["lobbyHeight"];
            new UIToolTips();
            UIToolTips.instance.mouseChildren = false;
            UIToolTips.instance.mouseEnabled = false;
            stageAgent.addChild(UIToolTips.instance);
         }
         else
         {
            stage = param1.stage;
            new UIToolTips();
            UIToolTips.instance.mouseChildren = false;
            UIToolTips.instance.mouseEnabled = false;
            stage.addChild(UIToolTips.instance);
         }
      }
   }
}

