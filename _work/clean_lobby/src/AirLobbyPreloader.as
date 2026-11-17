package
{
   import flash.desktop.NativeApplication;
   import flash.display.NativeWindow;
   import flash.display.NativeWindowInitOptions;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.system.Capabilities;

   [SWF(width="1024", height="650", backgroundColor="#080c14", frameRate="30")]
   public class AirLobbyPreloader extends Sprite
   {
      public function AirLobbyPreloader()
      {
         super();
         if(stage)
         {
            initWindow();
         }
         else
         {
            addEventListener(Event.ADDED_TO_STAGE, initWindow);
         }
      }

      private function initWindow(e:Event = null) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE, initWindow);
         try
         {
            var opts:NativeWindowInitOptions = new NativeWindowInitOptions();
            opts.renderMode = "direct";
            opts.systemChrome = "standard";
            opts.transparent = false;
            opts.resizable = true;
            opts.maximizable = true;
            opts.minimizable = true;

            var win:NativeWindow = new NativeWindow(opts);
            win.title = "4399生死狙击 - 官方离线大厅 (方案1A 原版UI+Stage3D)";
            win.stage.color = 0x080c14;
            win.stage.scaleMode = "noScale";
            win.stage.align = "TL";
            win.stage.frameRate = 30;
            win.stage.stageWidth = 1024;
            win.stage.stageHeight = 650;
            win.x = Math.max(0, int((Capabilities.screenResolutionX - 1040) * 0.5));
            win.y = Math.max(0, int((Capabilities.screenResolutionY - 700) * 0.5));
            NativeApplication.nativeApplication.autoExit = false;
            win.activate();
            win.stage.addChild(new CleanLobbyRoot());
            win.addEventListener(Event.CLOSE, function(ev:Event):void {
               NativeApplication.nativeApplication.exit();
            });
            try {
               stage.nativeWindow.visible = false;
            } catch(eHide:Error) {}
         }
         catch(err:Error)
         {
            stage.color = 0x080c14;
            stage.scaleMode = "noScale";
            stage.align = "TL";
            addChild(new CleanLobbyRoot());
         }
      }
   }
}
