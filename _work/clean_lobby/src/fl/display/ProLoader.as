package fl.display
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class ProLoader extends Sprite
   {
      
      private var _cli:ProLoaderInfo;
      
      private var _loader:Loader;
      
      private var _realContentLoader:Loader;
      
      private var _loading:Boolean;
      
      private var _hasRequestedContentParentProp:Boolean;
      
      public function ProLoader()
      {
         super();
         _loader = new Loader();
         _loader.contentLoaderInfo.sharedEvents.addEventListener("__proLoaderRSLPreloaderSandbox",handleProLoaderRSLPreloaderSandboxEvent,false,0,true);
         super.addChild(_loader);
         _realContentLoader = null;
         _cli = new ProLoaderInfo(this);
         _loading = false;
         _hasRequestedContentParentProp = false;
      }
      
      private function handleProLoaderRSLPreloaderSandboxEvent(param1:Object) : void
      {
         var _loc2_:DisplayObjectContainer = null;
         if(param1.loaderInfo != null)
         {
            try
            {
               _realContentLoader = param1.loaderInfo.loader;
            }
            catch(se:SecurityError)
            {
               _realContentLoader = null;
            }
            _cli.realContentLoaderInfo = param1.loaderInfo;
         }
         else if(param1.shape != null && getQualifiedClassName(param1.shape) == "flash.display::Shape")
         {
            try
            {
               _loc2_ = param1.shape.parent;
               if(_loc2_ != null)
               {
                  _loc2_.removeChild(param1.shape);
                  if(super.numChildren < 2)
                  {
                     super.addChild(_loc2_);
                  }
               }
            }
            catch(se:SecurityError)
            {
            }
         }
      }
      
      internal function loadDoneCallback(param1:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = null;
         if(!_loading)
         {
            _loader.unload();
            return false;
         }
         _loading = false;
         if(param1 != null)
         {
            try
            {
               if(_cli.realContentLoaderInfo == null)
               {
                  if(param1.loaderInfo.loader != _loader)
                  {
                     _realContentLoader = param1.loaderInfo.loader;
                     _cli.realContentLoaderInfo = _realContentLoader.contentLoaderInfo;
                     if(_hasRequestedContentParentProp)
                     {
                        _loc2_ = _loader.content.parent as DisplayObjectContainer;
                        if(_loc2_ == this || _loc2_ == null)
                        {
                           while(super.numChildren > 1)
                           {
                              super.removeChildAt(1);
                           }
                           super.addChild(param1);
                        }
                        else
                        {
                           _loc2_.addChildAt(param1,_loc2_.getChildIndex(_loader.content));
                           _loc2_.removeChild(_loader.content);
                        }
                     }
                     else
                     {
                        super.addChild(param1);
                     }
                  }
                  else if(!_hasRequestedContentParentProp || _cli._lcRequestedContentParentSet && param1.parent != this)
                  {
                     super.addChild(param1);
                  }
               }
               else if(_hasRequestedContentParentProp)
               {
                  if(param1.parent == this)
                  {
                     while(super.numChildren > 2)
                     {
                        super.removeChildAt(1);
                     }
                  }
               }
               else
               {
                  super.addChild(param1);
               }
            }
            catch(se:SecurityError)
            {
            }
         }
         return true;
      }
      
      public function get realLoader() : Loader
      {
         return _loader.contentLoaderInfo.loader;
      }
      
      public function get realContentLoader() : Loader
      {
         return _realContentLoader == null ? null : _realContentLoader.contentLoaderInfo.loader;
      }
      
      public function get content() : DisplayObject
      {
         if(super.numChildren > 1)
         {
            return super.getChildAt(1);
         }
         if(_realContentLoader)
         {
            return _realContentLoader.content;
         }
         return _loader.content;
      }
      
      public function get contentLoaderInfo() : ProLoaderInfo
      {
         return _cli;
      }
      
      public function close() : void
      {
         if(_loading)
         {
            _loading = false;
            try
            {
               _loader.close();
            }
            catch(err:Error)
            {
            }
         }
         else
         {
            _loader.close();
         }
      }
      
      public function load(param1:URLRequest, param2:LoaderContext = null) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         while(super.numChildren > 1)
         {
            super.removeChildAt(1);
         }
         _realContentLoader = null;
         _hasRequestedContentParentProp = false;
         _cli.reset();
         if(param2 == null)
         {
            param2 = new LoaderContext();
         }
         if(param2.hasOwnProperty("requestedContentParent"))
         {
            _hasRequestedContentParentProp = true;
            _loc3_ = param2["requestedContentParent"];
            if(_loc3_ == null)
            {
               param2["requestedContentParent"] = this;
               _cli._lcRequestedContentParentSet = true;
            }
         }
         _loader.load(param1,param2);
         _loading = true;
      }
      
      public function loadBytes(param1:ByteArray, param2:LoaderContext = null) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         while(super.numChildren > 1)
         {
            super.removeChildAt(1);
         }
         _realContentLoader = null;
         _hasRequestedContentParentProp = false;
         _cli.reset();
         if(param2 == null)
         {
            param2 = new LoaderContext();
         }
         if(param2.hasOwnProperty("requestedContentParent"))
         {
            _hasRequestedContentParentProp = true;
            _loc3_ = param2["requestedContentParent"];
            if(_loc3_ == null)
            {
               param2["requestedContentParent"] = this;
               _cli._lcRequestedContentParentSet = true;
            }
         }
         _loader.loadBytes(param1,param2);
         _loading = true;
      }
      
      public function loadFilePromise(param1:Object, param2:LoaderContext = null) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         while(super.numChildren > 1)
         {
            super.removeChildAt(1);
         }
         _realContentLoader = null;
         _hasRequestedContentParentProp = false;
         _cli.reset();
         if(param2 == null)
         {
            param2 = new LoaderContext();
         }
         if(param2.hasOwnProperty("requestedContentParent"))
         {
            _hasRequestedContentParentProp = true;
            _loc3_ = param2["requestedContentParent"];
            if(_loc3_ == null)
            {
               param2["requestedContentParent"] = this;
               _cli._lcRequestedContentParentSet = true;
            }
         }
         _loader["loadFilePromise"](param1,param2);
         _loading = true;
      }
      
      public function unload() : void
      {
         if(!_loading)
         {
            while(super.numChildren > 1)
            {
               super.removeChildAt(1);
            }
            _loader.unload();
         }
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         if(_realContentLoader != null && _realContentLoader.content == param1 || _loader.content == param1)
         {
            return super.addChild(param1);
         }
         throw new Error("Error #2069: The ProLoader class does not implement this method.");
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         throw new Error("Error #2069: The ProLoader class does not implement this method.");
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         throw new Error("Error #2069: The ProLoader class does not implement this method.");
      }
      
      override public function removeChildAt(param1:int) : DisplayObject
      {
         throw new Error("Error #2069: The ProLoader class does not implement this method.");
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         throw new Error("Error #2069: The ProLoader class does not implement this method.");
      }
      
      override public function get numChildren() : int
      {
         return super.numChildren - 1;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         if(param1 >= 0)
         {
            param1++;
         }
         return super.getChildAt(param1);
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         return super.getChildIndex(param1) - 1;
      }
      
      public function get uncaughtErrorEvents() : EventDispatcher
      {
         return _loader["uncaughtErrorEvents"];
      }
   }
}

