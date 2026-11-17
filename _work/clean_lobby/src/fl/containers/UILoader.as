package fl.containers
{
   import fl.core.UIComponent;
   import fl.display.ProLoader;
   import fl.display.ProLoaderInfo;
   import fl.events.ComponentEvent;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class UILoader extends UIComponent
   {
      
      private static var defaultStyles:Object = {};
      
      protected var _scaleContent:Boolean = true;
      
      protected var _autoLoad:Boolean = true;
      
      protected var contentInited:Boolean = false;
      
      protected var _source:Object;
      
      protected var loader:ProLoader;
      
      protected var _maintainAspectRatio:Boolean = true;
      
      protected var contentClip:Sprite;
      
      public function UILoader()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         if(!_scaleContent && _width > 0)
         {
            return;
         }
         super.setSize(param1,param2);
      }
      
      public function get autoLoad() : Boolean
      {
         return _autoLoad;
      }
      
      public function set autoLoad(param1:Boolean) : void
      {
         _autoLoad = param1;
         if(_autoLoad && loader == null && _source != null && _source != "")
         {
            load();
         }
      }
      
      public function get scaleContent() : Boolean
      {
         return _scaleContent;
      }
      
      public function set scaleContent(param1:Boolean) : void
      {
         if(_scaleContent == param1)
         {
            return;
         }
         _scaleContent = param1;
         invalidate("size");
      }
      
      public function get maintainAspectRatio() : Boolean
      {
         return _maintainAspectRatio;
      }
      
      public function set maintainAspectRatio(param1:Boolean) : void
      {
         _maintainAspectRatio = param1;
         invalidate("size");
      }
      
      public function get bytesLoaded() : uint
      {
         return loader == null || loader.contentLoaderInfo == null ? 0 : loader.contentLoaderInfo.bytesLoaded;
      }
      
      public function get bytesTotal() : uint
      {
         return loader == null || loader.contentLoaderInfo == null ? 0 : loader.contentLoaderInfo.bytesTotal;
      }
      
      public function loadBytes(param1:ByteArray, param2:LoaderContext = null) : void
      {
         _unload();
         initLoader();
         try
         {
            loader.loadBytes(param1,param2);
         }
         catch(error:*)
         {
            throw error;
         }
      }
      
      public function get content() : DisplayObject
      {
         if(loader != null)
         {
            return loader.content;
         }
         if(contentClip.numChildren)
         {
            return contentClip.getChildAt(0);
         }
         return null;
      }
      
      public function get source() : Object
      {
         return _source;
      }
      
      public function set source(param1:Object) : void
      {
         if(param1 == "")
         {
            return;
         }
         _source = param1;
         _unload();
         if(_autoLoad && _source != null)
         {
            load();
         }
      }
      
      public function get percentLoaded() : Number
      {
         return bytesTotal <= 0 ? 0 : bytesLoaded / bytesTotal * 100;
      }
      
      public function load(param1:URLRequest = null, param2:LoaderContext = null) : void
      {
         _unload();
         if((param1 == null || param1.url == null) && (_source == null || _source == ""))
         {
            return;
         }
         var _loc3_:DisplayObject = getDisplayObjectInstance(source);
         if(_loc3_ != null)
         {
            contentClip.addChild(_loc3_);
            contentInited = true;
            invalidate("size");
            return;
         }
         param1 = param1;
         if(param1 == null)
         {
            param1 = new URLRequest(_source.toString());
         }
         if(param2 == null)
         {
            param2 = new LoaderContext(false,ApplicationDomain.currentDomain);
         }
         initLoader();
         loader.load(param1,param2);
      }
      
      public function unload() : void
      {
         _source = null;
         _unload(true);
      }
      
      public function close() : void
      {
         try
         {
            loader.close();
         }
         catch(error:*)
         {
            throw error;
         }
      }
      
      protected function _unload(param1:Boolean = false) : void
      {
         if(loader != null)
         {
            clearLoadEvents();
            contentClip.removeChild(loader);
            try
            {
               loader.close();
            }
            catch(e:Error)
            {
            }
            try
            {
               loader.unload();
            }
            catch(e:*)
            {
               if(param1)
               {
                  throw e;
               }
            }
            loader = null;
            return;
         }
         contentInited = false;
         if(contentClip.numChildren)
         {
            contentClip.removeChildAt(0);
         }
      }
      
      protected function initLoader() : void
      {
         loader = new ProLoader();
         loader.contentLoaderInfo.addEventListener("ioError",handleError,false,0,true);
         loader.contentLoaderInfo.addEventListener("securityError",handleError,false,0,true);
         loader.contentLoaderInfo.addEventListener("open",passEvent,false,0,true);
         loader.contentLoaderInfo.addEventListener("progress",passEvent,false,0,true);
         loader.contentLoaderInfo.addEventListener("complete",handleComplete,false,0,true);
         loader.contentLoaderInfo.addEventListener("init",handleInit,false,0,true);
         loader.contentLoaderInfo.addEventListener("httpStatus",passEvent,false,0,true);
         contentClip.addChild(loader);
      }
      
      protected function handleComplete(param1:Event) : void
      {
         clearLoadEvents();
         passEvent(param1);
      }
      
      protected function passEvent(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      protected function handleError(param1:Event) : void
      {
         passEvent(param1);
         clearLoadEvents();
         loader.contentLoaderInfo.removeEventListener("init",handleInit);
      }
      
      protected function handleInit(param1:Event) : void
      {
         loader.contentLoaderInfo.removeEventListener("init",handleInit);
         contentInited = true;
         passEvent(param1);
         invalidate("size");
      }
      
      protected function clearLoadEvents() : void
      {
         loader.contentLoaderInfo.removeEventListener("ioError",handleError);
         loader.contentLoaderInfo.removeEventListener("securityError",handleError);
         loader.contentLoaderInfo.removeEventListener("open",passEvent);
         loader.contentLoaderInfo.removeEventListener("progress",passEvent);
         loader.contentLoaderInfo.removeEventListener("httpStatus",passEvent);
         loader.contentLoaderInfo.removeEventListener("complete",handleComplete);
      }
      
      override protected function draw() : void
      {
         if(isInvalid("size"))
         {
            drawLayout();
         }
         super.draw();
      }
      
      protected function drawLayout() : void
      {
         var _loc1_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:ProLoaderInfo = null;
         if(!contentInited)
         {
            return;
         }
         var _loc6_:Boolean = false;
         if(loader)
         {
            _loc3_ = loader.contentLoaderInfo;
            _loc1_ = _loc3_.width;
            _loc5_ = _loc3_.height;
         }
         else
         {
            _loc1_ = contentClip.width;
            _loc5_ = contentClip.height;
         }
         var _loc2_:Number = _width;
         var _loc4_:Number = _height;
         if(!_scaleContent)
         {
            _width = contentClip.width;
            _height = contentClip.height;
         }
         else
         {
            sizeContent(contentClip,_loc1_,_loc5_,_width,_height);
         }
         if(_loc2_ != _width || _loc4_ != _height)
         {
            dispatchEvent(new ComponentEvent("resize",true));
         }
      }
      
      protected function sizeContent(param1:DisplayObject, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc6_:Number = param4;
         var _loc9_:Number = param5;
         if(_maintainAspectRatio)
         {
            _loc7_ = param4 / param5;
            _loc8_ = param2 / param3;
            if(_loc7_ < _loc8_)
            {
               _loc9_ = _loc6_ / _loc8_;
            }
            else
            {
               _loc6_ = _loc9_ * _loc8_;
            }
         }
         param1.width = _loc6_;
         param1.height = _loc9_;
         param1.x = param4 / 2 - _loc6_ / 2;
         param1.y = param5 / 2 - _loc9_ / 2;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         contentClip = new Sprite();
         addChild(contentClip);
      }
   }
}

