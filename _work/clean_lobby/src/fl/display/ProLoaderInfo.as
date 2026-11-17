package fl.display
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.errors.IllegalOperationError;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.system.ApplicationDomain;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class ProLoaderInfo extends EventDispatcher
   {
      
      private var _proLoader:ProLoader;
      
      private var _realLI:LoaderInfo;
      
      private var _realContentLI:LoaderInfo;
      
      private var _rslPreloaderLoaded:Boolean;
      
      private var _doneProgressStalling:Boolean;
      
      private var _numAdded:int;
      
      internal var _lcRequestedContentParentSet:Boolean;
      
      public function ProLoaderInfo(param1:ProLoader)
      {
         super();
         _realContentLI = null;
         _lcRequestedContentParentSet = false;
         _rslPreloaderLoaded = false;
         _doneProgressStalling = false;
         _numAdded = 0;
         _proLoader = param1;
         _realLI = param1.realLoader.contentLoaderInfo;
         _realLI.addEventListener("asyncError",handleAsyncErrorEvent,false,0,true);
         _realLI.addEventListener("complete",handleLoaderInfoEvent,false,0,true);
         _realLI.addEventListener("httpStatus",handleLoaderInfoEvent,false,0,true);
         _realLI.addEventListener("init",handleLoaderInfoEvent,false,0,true);
         _realLI.addEventListener("ioError",handleLoaderInfoEvent,false,0,true);
         _realLI.addEventListener("open",handleLoaderInfoEvent,false,0,true);
         _realLI.addEventListener("progress",handleProgressEvent,false,0,true);
         _realLI.addEventListener("securityError",handleSecurityErrorEvent,false,0,true);
         _realLI.addEventListener("unload",handleLoaderInfoEvent,false,0,true);
      }
      
      internal function reset() : void
      {
         _realContentLI = null;
         _rslPreloaderLoaded = false;
         _doneProgressStalling = false;
         _lcRequestedContentParentSet = false;
      }
      
      public function get actionScriptVersion() : uint
      {
         return _realLI.actionScriptVersion;
      }
      
      public function get applicationDomain() : ApplicationDomain
      {
         return _realLI.applicationDomain;
      }
      
      public function get bytes() : ByteArray
      {
         return _realLI.bytes;
      }
      
      public function get bytesLoaded() : uint
      {
         if(_realLI.bytesLoaded >= _realLI.bytesTotal && _proLoader.content == null)
         {
            return _realLI.bytesTotal - 1;
         }
         return _realLI.bytesLoaded;
      }
      
      public function get bytesTotal() : uint
      {
         return _realLI.bytesTotal;
      }
      
      public function get childAllowsParent() : Boolean
      {
         return _realLI.childAllowsParent;
      }
      
      public function get childSandboxBridge() : Object
      {
         if(_realContentLI != null)
         {
            return _realContentLI["childSandboxBridge"];
         }
         return _realLI["childSandboxBridge"];
      }
      
      public function set childSandboxBridge(param1:Object) : void
      {
         if(_realContentLI != null)
         {
            _realContentLI["childSandboxBridge"] = param1;
         }
         else
         {
            _realLI["childSandboxBridge"] = param1;
         }
      }
      
      public function get content() : DisplayObject
      {
         return _proLoader.content;
      }
      
      public function get contentType() : String
      {
         return _realLI.contentType;
      }
      
      public function get frameRate() : Number
      {
         return _realLI.frameRate;
      }
      
      public function get height() : int
      {
         return _realLI.height;
      }
      
      public function get isURLInaccessible() : Boolean
      {
         return _realLI.isURLInaccessible;
      }
      
      public function get loader() : ProLoader
      {
         return _proLoader;
      }
      
      public function get loaderURL() : String
      {
         return _realLI.loaderURL;
      }
      
      public function get parameters() : Object
      {
         return _realLI.parameters;
      }
      
      public function get parentAllowsChild() : Boolean
      {
         return _realLI.parentAllowsChild;
      }
      
      public function get parentSandboxBridge() : Object
      {
         if(_realContentLI != null)
         {
            return _realContentLI["parentSandboxBridge"];
         }
         return _realLI["parentSandboxBridge"];
      }
      
      public function set parentSandboxBridge(param1:Object) : *
      {
         if(_realContentLI != null)
         {
            _realContentLI["parentSandboxBridge"] = param1;
         }
         else
         {
            _realLI["parentSandboxBridge"] = param1;
         }
      }
      
      public function get sameDomain() : Boolean
      {
         return _realLI.sameDomain;
      }
      
      public function get sharedEvents() : EventDispatcher
      {
         if(_realContentLI != null)
         {
            return _realContentLI.sharedEvents;
         }
         return _realLI.sharedEvents;
      }
      
      public function get swfVersion() : uint
      {
         return _realLI.swfVersion;
      }
      
      public function get url() : String
      {
         return _realLI.url;
      }
      
      public function get width() : int
      {
         return _realLI.width;
      }
      
      override public function dispatchEvent(param1:Event) : Boolean
      {
         Error.throwError(IllegalOperationError,2118);
         return false;
      }
      
      private function handleAsyncErrorEvent(param1:AsyncErrorEvent) : void
      {
         if(!_lcRequestedContentParentSet)
         {
            super.dispatchEvent(param1);
         }
      }
      
      private function handleLoaderInfoEvent(param1:Event) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         switch(param1.type)
         {
            case "httpStatus":
            case "ioError":
            case "open":
            case "unload":
               super.dispatchEvent(param1);
               break;
            case "init":
               if(!_rslPreloaderLoaded)
               {
                  try
                  {
                     _loc2_ = _realLI.content;
                     _loc3_ = getQualifiedClassName(_loc2_);
                     if(_loc3_.substr(-13) == "__Preloader__")
                     {
                        _loc4_ = _loc2_["__rslPreloader"];
                        if(_loc4_ != null)
                        {
                           _loc3_ = getQualifiedClassName(_loc4_);
                           if(_loc3_ == "fl.rsl::RSLPreloader")
                           {
                              _rslPreloaderLoaded = true;
                              _numAdded = 0;
                              _loc2_.addEventListener("added",handleAddedEvent,false,0,true);
                           }
                        }
                     }
                  }
                  catch(err:Error)
                  {
                     _rslPreloaderLoaded = false;
                  }
               }
               if(!_rslPreloaderLoaded)
               {
                  _proLoader.loadDoneCallback(_loc2_);
                  if(!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal)
                  {
                     _doneProgressStalling = true;
                     super.dispatchEvent(new ProgressEvent("progress",false,false,_realLI.bytesLoaded,_realLI.bytesTotal));
                  }
                  super.dispatchEvent(param1);
               }
               break;
            case "complete":
               if(!_rslPreloaderLoaded)
               {
                  super.dispatchEvent(param1);
               }
         }
      }
      
      private function handleProgressEvent(param1:ProgressEvent) : void
      {
         if(_doneProgressStalling || param1.bytesLoaded < param1.bytesTotal)
         {
            super.dispatchEvent(param1);
         }
      }
      
      private function handleSecurityErrorEvent(param1:SecurityErrorEvent) : void
      {
         if(!_lcRequestedContentParentSet || param1.errorID != 2047)
         {
            super.dispatchEvent(param1);
         }
      }
      
      private function handleAddedEvent(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         var _loc3_:DisplayObjectContainer = param1.currentTarget as DisplayObjectContainer;
         if(_loc2_ != null && _loc3_ != null && _loc2_.parent == _loc3_)
         {
            _numAdded = _numAdded + 1;
         }
         if(_numAdded > 1)
         {
            param1.currentTarget.removeEventListener("added",handleAddedEvent);
            if(_proLoader.loadDoneCallback(_loc2_))
            {
               if(!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal)
               {
                  _doneProgressStalling = true;
                  super.dispatchEvent(new ProgressEvent("progress",false,false,_realLI.bytesLoaded,_realLI.bytesTotal));
               }
               super.dispatchEvent(new Event("init",false,false));
               super.dispatchEvent(new Event("complete",false,false));
            }
         }
      }
      
      internal function set realContentLoaderInfo(param1:LoaderInfo) : void
      {
         var _loc2_:Object = null;
         _realContentLI = param1;
         _realContentLI.addEventListener("complete",handleRealContentEvent,false,0,true);
         _realContentLI.addEventListener("init",handleRealContentEvent,false,0,true);
         _realContentLI.addEventListener("ioError",handleLoaderInfoEvent,false,0,true);
         _realContentLI.addEventListener("securityError",handleSecurityErrorEvent,false,0,true);
         _rslPreloaderLoaded = true;
         if(_realContentLI.hasOwnProperty("childSandboxBridge"))
         {
            try
            {
               _loc2_ = _realLI["childSandboxBridge"];
               if(_loc2_ != null)
               {
                  _realContentLI["childSandboxBridge"] = _loc2_;
               }
            }
            catch(se:SecurityError)
            {
            }
            try
            {
               _loc2_ = _realLI["parentSandboxBridge"];
               if(_loc2_ != null)
               {
                  _realContentLI["parentSandboxBridge"] = _loc2_;
               }
            }
            catch(se:SecurityError)
            {
            }
         }
      }
      
      internal function get realContentLoaderInfo() : LoaderInfo
      {
         return _realContentLI;
      }
      
      private function handleRealContentEvent(param1:Event) : void
      {
         var _loc2_:DisplayObject = null;
         if(param1.type == "init")
         {
            try
            {
               _loc2_ = _realContentLI.content;
            }
            catch(se:SecurityError)
            {
               _loc2_ = null;
            }
            _proLoader.loadDoneCallback(_loc2_);
            if(!_doneProgressStalling && _realLI.bytesLoaded >= _realLI.bytesTotal)
            {
               _doneProgressStalling = true;
               super.dispatchEvent(new ProgressEvent("progress",false,false,_realLI.bytesLoaded,_realLI.bytesTotal));
            }
         }
         super.dispatchEvent(param1);
      }
   }
}

