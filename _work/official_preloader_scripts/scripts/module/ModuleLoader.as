package module
{
   import com.wooduan.bytes.utils.ByteUtils;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   
   public class ModuleLoader
   {
      
      private var _urlloader:URLLoader = null;
      
      private var _loader:Loader = null;
      
      private var resurl:String = "";
      
      private var reloadCount:int = 0;
      
      private var swfUrl:String = null;
      
      private var maxReload:int = 0;
      
      private var progressHandler:Function = null;
      
      private var completeHander:Function = null;
      
      public function ModuleLoader(param1:String, param2:String, param3:Function, param4:Function, param5:int = 5)
      {
         super();
         this.swfUrl = param1;
         this.resurl = param2;
         this.progressHandler = param3;
         this.completeHander = param4;
         this.maxReload = param5;
      }
      
      public function startLoad(param1:Boolean = false) : void
      {
         this._urlloader = new URLLoader();
         this._urlloader.dataFormat = "binary";
         this._urlloader.addEventListener("complete",onHallByteComplete);
         this._urlloader.addEventListener("progress",onProgressHander);
         this._urlloader.addEventListener("ioError",onIOError);
         this._urlloader.addEventListener("securityError",onSecurityError);
         var _loc2_:String = resurl + this.swfUrl;
         if(param1)
         {
            _loc2_ += "?" + new Date().time;
         }
         this._urlloader.load(new URLRequest(_loc2_));
      }
      
      public function dispose() : void
      {
         if(null != this._urlloader)
         {
            this._urlloader.removeEventListener("securityError",onSecurityError);
            this._urlloader.removeEventListener("progress",onProgressHander);
            this._urlloader.removeEventListener("complete",onHallByteComplete);
            this._urlloader.removeEventListener("ioError",onIOError);
            this._urlloader = null;
         }
         if(null != this._loader)
         {
            this._loader.contentLoaderInfo.removeEventListener("complete",onCompleteHander);
            this._loader.contentLoaderInfo.removeEventListener("ioError",onIOError);
            this._loader.contentLoaderInfo.removeEventListener("securityError",onSecurityError);
            this._loader.unloadAndStop(true);
            if(null != this._loader.parent)
            {
               this._loader.parent.removeChild(this._loader);
            }
            this._loader = null;
         }
         this.progressHandler = null;
         this.completeHander = null;
      }
      
      private function onProgressHander(param1:ProgressEvent) : void
      {
         this.progressHandler.apply(null,[param1]);
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         trace(param1.text);
         reloadModule();
      }
      
      private function onSecurityError(param1:IOErrorEvent) : void
      {
         trace(param1.text);
         reloadModule();
      }
      
      private function reloadModule() : Boolean
      {
         if(null != this._urlloader)
         {
            this._urlloader.removeEventListener("securityError",onSecurityError);
            this._urlloader.removeEventListener("progress",onProgressHander);
            this._urlloader.removeEventListener("complete",onHallByteComplete);
            this._urlloader.removeEventListener("ioError",onIOError);
            this._urlloader = null;
         }
         if(reloadCount < this.maxReload)
         {
            startLoad(true);
            reloadCount = reloadCount + 1;
            return true;
         }
         return false;
      }
      
      private function onHallByteComplete(param1:Event) : void
      {
         var _loc2_:String = null;
         if(null != this.swfUrl && this.swfUrl.lastIndexOf("_") > -1)
         {
            _loc2_ = this.swfUrl.substring(this.swfUrl.lastIndexOf("_") + 1,this.swfUrl.indexOf("."));
            if(_loc2_.length == 32 && _loc2_ != ByteUtils.hashBinary(_urlloader.data))
            {
               if(reloadModule())
               {
                  return;
               }
            }
         }
         loadModule();
      }
      
      private function loadModule() : void
      {
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener("complete",onCompleteHander);
         this._loader.contentLoaderInfo.addEventListener("ioError",onIOError);
         this._loader.contentLoaderInfo.addEventListener("securityError",onSecurityError);
         var _loc1_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         if("Desktop" == Capabilities.playerType)
         {
            _loc1_.allowLoadBytesCodeExecution = true;
         }
         this._loader.loadBytes(this._urlloader.data,_loc1_);
      }
      
      private function onCompleteHander(param1:Event) : void
      {
         this.completeHander.apply(null,[this._loader]);
      }
   }
}

