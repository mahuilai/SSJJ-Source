package fl
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class FUIAssets
   {
      
      private var FLUI_ASSETS:Class = FLUI_ASSETS_swf;
      
      private var _loader:Loader = null;
      
      private var _complete:Function = null;
      
      public function FUIAssets()
      {
         super();
      }
      
      public function loadAssets(param1:Function) : void
      {
         this._complete = param1;
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener("complete",onCompleteHander);
         var _loc2_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         if("Desktop" == Capabilities.playerType)
         {
            _loc2_.allowCodeImport = true;
         }
         this._loader.loadBytes(new FLUI_ASSETS() as ByteArray,_loc2_);
      }
      
      private function onCompleteHander(param1:Event) : void
      {
         this._complete.apply();
         this.dispose();
         this._complete = null;
      }
      
      private function dispose() : void
      {
         this._loader.contentLoaderInfo.removeEventListener("complete",onCompleteHander);
         this._loader.unload();
         this._loader = null;
      }
   }
}

