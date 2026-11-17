package ui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import ui.events.UIEvent;
   import utils.StringUtil;
   
   public class UIAssetsLoader extends Sprite
   {
      
      public static var getUrl:Function;
      
      private static var _context:LoaderContext;
      
      private static var _contextCount:int;
      
      private static var _currentcontext:LoaderContext;
      
      private static var assetsMap:Dictionary = new Dictionary(true);
      
      private var loader:Loader;
      
      private var _path:String;
      
      private var _fileName:String = "";
      
      private var _url:String;
      
      private var _cacheKey:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var showEffDuration:Number = 0.5;
      
      private var _loadTimeOutId:uint;
      
      private var _loadTimeOut:int = 5000;
      
      private var _reloadCount:int = 0;
      
      public var callback:Function;
      
      public var param:Object = null;
      
      private var _isCenterPosition:Boolean = false;
      
      private var _autoUnload:Boolean = true;
      
      private var _content:DisplayObject;
      
      public function UIAssetsLoader(param1:String = null, param2:Boolean = true, param3:Boolean = false)
      {
         super();
         _path = param1;
         loader = new Loader();
         this.autoUnload = param2;
         this.isCenterPosition = param3;
         this.addEventListener("removedFromStage",onRemoved,false,0,true);
         this.addEventListener("addedToStage",onAdd,false,0,true);
      }
      
      public static function getAssetsInCache(param1:String) : ByteArray
      {
         return assetsMap[param1];
      }
      
      public static function putAssetsInCache(param1:String, param2:ByteArray) : void
      {
         if(param1.length && param2 != null)
         {
            assetsMap[param1] = param2;
         }
      }
      
      public static function disposeCahce() : void
      {
         for each(var _loc1_ in assetsMap)
         {
            _loc1_.clear();
         }
         assetsMap = new Dictionary(true);
      }
      
      private function initHandler(param1:Event) : void
      {
         clearTimeoutId();
      }
      
      private function onRemoved(param1:Event) : void
      {
         if(autoUnload)
         {
            unload();
         }
         else if(_content && contains(_content))
         {
            removeChild(_content);
         }
      }
      
      private function onAdd(param1:Event) : void
      {
         if(_content)
         {
            addChild(_content);
         }
      }
      
      public function set fileName(param1:String) : void
      {
         _fileName = param1;
         _reloadCount = 0;
         loadFile();
      }
      
      public function get fileName() : String
      {
         return _fileName;
      }
      
      public function set path(param1:String) : void
      {
         _path = param1;
         _reloadCount = 0;
      }
      
      public function get path() : String
      {
         return _path;
      }
      
      public function loadFile(param1:String = null, param2:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc3_:LoaderContext = null;
         removeChildren();
         if(StringUtil.isEmpty(_path) || StringUtil.isEmpty(_fileName))
         {
            return;
         }
         loader.contentLoaderInfo.addEventListener("complete",completeHandler);
         loader.contentLoaderInfo.addEventListener("ioError",errorHandler);
         loader.contentLoaderInfo.addEventListener("securityError",errorHandler);
         loader.contentLoaderInfo.addEventListener("init",initHandler);
         clearTimeoutId();
         if(_path != null)
         {
            _loc5_ = StringUtil.substitute(_path,_fileName);
         }
         _cacheKey = _loc5_;
         if(getUrl != null)
         {
            _loc5_ = getUrl(_loc5_,param1,true,param2);
         }
         var _loc4_:ByteArray = getAssetsInCache(_cacheKey);
         _url = _loc5_;
         if(_loc4_ == null)
         {
            _loadTimeOutId = setTimeout(reloadFile,_loadTimeOut,_reloadCount);
            if(_currentcontext == null)
            {
               if(_contextCount > 6 || !_context)
               {
                  _contextCount = 0;
                  _context = new LoaderContext();
                  _context.applicationDomain = new ApplicationDomain();
                  _context.checkPolicyFile = true;
                  if(Security.sandboxType == "remote")
                  {
                     _context.securityDomain = SecurityDomain.currentDomain;
                  }
               }
               _contextCount = _contextCount + 1;
               _currentcontext = _context;
            }
            if("Desktop" == Capabilities.playerType)
            {
               _currentcontext.allowLoadBytesCodeExecution = true;
            }
            loader.load(new URLRequest(_loc5_),_currentcontext);
         }
         else if("Desktop" == Capabilities.playerType)
         {
            _loc3_ = new LoaderContext(false,null,null);
            _loc3_.allowLoadBytesCodeExecution = true;
            loader.loadBytes(_loc4_,_loc3_);
         }
         else
         {
            loader.loadBytes(_loc4_);
         }
      }
      
      private function reloadFile(param1:int) : void
      {
         var _loc2_:String = null;
         _reloadCount = _reloadCount + 1;
         if(_reloadCount > 3)
         {
            return;
         }
         if(_reloadCount % 2 == 1)
         {
            _loc2_ = Math.round(Math.random() * 100000000).toString();
         }
         loadFile(_loc2_,_reloadCount > 1);
      }
      
      private function clearTimeoutId() : void
      {
         if(_loadTimeOutId > 0)
         {
            clearTimeout(_loadTimeOutId);
         }
      }
      
      private function completeHandler(param1:Event) : void
      {
         var _loc3_:ByteArray = null;
         var _loc2_:ByteArray = null;
         loader.contentLoaderInfo.removeEventListener("complete",completeHandler);
         loader.contentLoaderInfo.removeEventListener("ioError",errorHandler);
         loader.contentLoaderInfo.removeEventListener("securityError",errorHandler);
         loader.contentLoaderInfo.removeEventListener("init",initHandler);
         if(_cacheKey != null)
         {
            _loc3_ = getAssetsInCache(_cacheKey);
            if(_loc3_ == null && loader.contentLoaderInfo != null && loader.contentLoaderInfo.bytes != null)
            {
               _loc2_ = new ByteArray();
               _loc2_.writeBytes(loader.contentLoaderInfo.bytes,0,loader.contentLoaderInfo.bytes.length);
               if(_loc2_.length > 0)
               {
                  putAssetsInCache(_cacheKey,_loc2_);
               }
            }
         }
         removeChildren();
         _content = loader.content;
         if(this.stage)
         {
            this.addChild(_content);
         }
         if(_width > 0)
         {
            _content.width = _width;
         }
         if(_height > 0)
         {
            _content.height = _height;
         }
         if(isCenterPosition && _content != null)
         {
            _content.x = -_content.width / 2;
            _content.y = -_content.height / 2;
         }
         if(callback != null)
         {
            if(null == param)
            {
               callback();
            }
            else
            {
               callback(param);
            }
            callback = null;
         }
      }
      
      private function errorHandler(param1:Event) : void
      {
         if(this.stage)
         {
            this.stage.dispatchEvent(new UIEvent("URL_ERROR",{"url":_url}));
         }
         trace("加载失败",_url);
         clearTimeoutId();
         reloadFile(_reloadCount);
      }
      
      public function unload() : void
      {
         _cacheKey = "";
         clearTimeoutId();
         removeChildren();
         clearFiltersAndStop(_content);
         _content = null;
         try
         {
            loader.unload();
         }
         catch(err:Error)
         {
         }
         try
         {
            loader.close();
         }
         catch(err:Error)
         {
         }
         loader.contentLoaderInfo.addEventListener("complete",completeHandler);
         loader.contentLoaderInfo.addEventListener("ioError",errorHandler);
         loader.contentLoaderInfo.addEventListener("securityError",errorHandler);
         loader.contentLoaderInfo.addEventListener("init",initHandler);
      }
      
      public function clearFiltersAndStop(param1:*) : void
      {
         var _loc2_:int = 0;
         if(param1 is MovieClip)
         {
            param1.filters = null;
            param1.stop();
         }
         if(param1 is DisplayObjectContainer)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numChildren)
            {
               clearFiltersAndStop(param1.getChildAt(_loc2_));
               _loc2_++;
            }
         }
      }
      
      override public function set width(param1:Number) : void
      {
         _width = param1;
         if(_content != null)
         {
            _content.width = _width;
         }
      }
      
      override public function get width() : Number
      {
         return (_content ? _content.width : _width) * scaleX;
      }
      
      override public function set height(param1:Number) : void
      {
         _height = param1;
         if(_content != null)
         {
            _content.height = _height;
         }
      }
      
      override public function get height() : Number
      {
         return (_content ? _content.height : _height) * scaleY;
      }
      
      public function set isCenterPosition(param1:Boolean) : void
      {
         _isCenterPosition = param1;
      }
      
      public function get isCenterPosition() : Boolean
      {
         return _isCenterPosition;
      }
      
      public function set autoUnload(param1:Boolean) : void
      {
         _autoUnload = param1;
      }
      
      public function get autoUnload() : Boolean
      {
         return _autoUnload;
      }
      
      public function getContent() : DisplayObject
      {
         return _content;
      }
      
      public function dispose() : void
      {
         unload();
         loader.contentLoaderInfo.removeEventListener("complete",completeHandler);
         loader.contentLoaderInfo.removeEventListener("ioError",errorHandler);
         loader.contentLoaderInfo.removeEventListener("init",initHandler);
         this.removeEventListener("removedFromStage",onRemoved);
         this.removeEventListener("addedToStage",onAdd);
      }
   }
}

