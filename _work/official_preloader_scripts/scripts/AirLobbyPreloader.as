package
{
   import flash.display.NativeWindow;
   import flash.display.NativeWindowInitOptions;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   
   [SWF(width="500", height="375", backgroundColor="#ffffff", frameRate="24")]
   public class AirLobbyPreloader extends Sprite
   {
      
      private static const _logger:ILogger = getLogger(AirLobbyPreloader);
      
      public function AirLobbyPreloader()
      {
         super();
         this.stage.color = 0;
         var _loc3_:NativeWindowInitOptions = new NativeWindowInitOptions();
         _loc3_.renderMode = "direct";
         _loc3_.systemChrome = "none";
         var _loc2_:NativeWindow = new NativeWindow(_loc3_);
         _loc2_.stage.color = 0;
         var _loc1_:Point = Mini.getDefaultPosition();
         _loc2_.stage.nativeWindow.x = _loc1_.x;
         _loc2_.stage.nativeWindow.y = _loc1_.y;
         _loc2_.width = 1024;
         _loc2_.height = 650;
         _loc2_.activate();
         _loc2_.stage.addChild(new Mini());
         _loc2_.addEventListener("deactivate",onDeActivate);
         _loc2_.addEventListener("activate",onActivate);
         stage.nativeWindow.close();
      }
      
      private function onActivate(param1:Event) : void
      {
      }
      
      private function onDeActivate(param1:Event) : void
      {
      }
   }
}

