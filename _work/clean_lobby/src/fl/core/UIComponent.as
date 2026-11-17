package fl.core
{
   import fl.events.ComponentEvent;
   import fl.managers.FocusManager;
   import fl.managers.IFocusManager;
   import fl.managers.IFocusManagerComponent;
   import fl.managers.StyleManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.system.IME;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class UIComponent extends Sprite
   {
      
      public static var inCallLaterPhase:Boolean = false;
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "focusRectSkin":"focusRectSkin",
         "focusRectPadding":2,
         "textFormat":new TextFormat("_sans",11,0,false,false,false,"","","left",0,0,0,0),
         "disabledTextFormat":new TextFormat("_sans",11,10066329,false,false,false,"","","left",0,0,0,0),
         "defaultTextFormat":new TextFormat("_sans",11,0,false,false,false,"","","left",0,0,0,0),
         "defaultDisabledTextFormat":new TextFormat("_sans",11,10066329,false,false,false,"","","left",0,0,0,0)
      };
      
      private static var focusManagers:Dictionary = new Dictionary(true);
      
      private static var focusManagerUsers:Dictionary = new Dictionary(true);
      
      public const version:String = "3.0.3.1";
      
      public var focusTarget:IFocusManagerComponent;
      
      protected var isLivePreview:Boolean = false;
      
      private var tempText:TextField;
      
      protected var instanceStyles:Object;
      
      protected var sharedStyles:Object;
      
      protected var callLaterMethods:Dictionary;
      
      protected var invalidateFlag:Boolean = false;
      
      protected var _enabled:Boolean = true;
      
      protected var invalidHash:Object;
      
      protected var uiFocusRect:DisplayObject;
      
      protected var isFocused:Boolean = false;
      
      private var _focusEnabled:Boolean = true;
      
      private var _mouseFocusEnabled:Boolean = true;
      
      protected var _width:Number;
      
      protected var _height:Number;
      
      protected var _x:Number;
      
      protected var _y:Number;
      
      protected var startWidth:Number;
      
      protected var startHeight:Number;
      
      protected var _imeMode:String = null;
      
      protected var _oldIMEMode:String = null;
      
      protected var errorCaught:Boolean = false;
      
      protected var _inspector:Boolean = false;
      
      public function UIComponent()
      {
         super();
         instanceStyles = {};
         sharedStyles = {};
         invalidHash = {};
         callLaterMethods = new Dictionary();
         StyleManager.registerInstance(this);
         configUI();
         invalidate("all");
         tabEnabled = this is IFocusManagerComponent;
         focusRect = false;
         if(tabEnabled)
         {
            addEventListener("focusIn",focusInHandler);
            addEventListener("focusOut",focusOutHandler);
            addEventListener("keyDown",keyDownHandler);
            addEventListener("keyUp",keyUpHandler);
         }
         initializeFocusManager();
         addEventListener("enterFrame",hookAccessibility,false,0,true);
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      public static function mergeStyles(... rest) : Object
      {
         var _loc6_:* = 0;
         var _loc3_:Object = null;
         var _loc4_:Object = {};
         var _loc5_:uint = uint(rest.length);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = rest[_loc6_];
            for(var _loc2_ in _loc3_)
            {
               if(_loc4_[_loc2_] == null)
               {
                  _loc4_[_loc2_] = rest[_loc6_][_loc2_];
               }
            }
            _loc6_++;
         }
         return _loc4_;
      }
      
      public function get componentInspectorSetting() : Boolean
      {
         return _inspector;
      }
      
      public function set componentInspectorSetting(param1:Boolean) : void
      {
         _inspector = param1;
         if(_inspector)
         {
            beforeComponentParameters();
         }
         else
         {
            afterComponentParameters();
         }
      }
      
      protected function beforeComponentParameters() : void
      {
      }
      
      protected function afterComponentParameters() : void
      {
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(param1 == _enabled)
         {
            return;
         }
         _enabled = param1;
         invalidate("state");
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         _width = param1;
         _height = param2;
         invalidate("size");
         dispatchEvent(new ComponentEvent("resize",false));
      }
      
      override public function get width() : Number
      {
         return _width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(_width == param1)
         {
            return;
         }
         setSize(param1,height);
      }
      
      override public function get height() : Number
      {
         return _height;
      }
      
      override public function set height(param1:Number) : void
      {
         if(_height == param1)
         {
            return;
         }
         setSize(width,param1);
      }
      
      public function setStyle(param1:String, param2:Object) : void
      {
         if(instanceStyles[param1] === param2 && !(param2 is TextFormat))
         {
            return;
         }
         instanceStyles[param1] = param2;
         invalidate("styles");
      }
      
      public function clearStyle(param1:String) : void
      {
         setStyle(param1,null);
      }
      
      public function getStyle(param1:String) : Object
      {
         return instanceStyles[param1];
      }
      
      public function move(param1:Number, param2:Number) : void
      {
         _x = param1;
         _y = param2;
         super.x = Math.round(param1);
         super.y = Math.round(param2);
         dispatchEvent(new ComponentEvent("move"));
      }
      
      override public function get x() : Number
      {
         return isNaN(_x) ? super.x : _x;
      }
      
      override public function set x(param1:Number) : void
      {
         move(param1,_y);
      }
      
      override public function get y() : Number
      {
         return isNaN(_y) ? super.y : _y;
      }
      
      override public function set y(param1:Number) : void
      {
         move(_x,param1);
      }
      
      override public function get scaleX() : Number
      {
         return width / startWidth;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         setSize(startWidth * param1,height);
      }
      
      override public function get scaleY() : Number
      {
         return height / startHeight;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         setSize(width,startHeight * param1);
      }
      
      protected function getScaleY() : Number
      {
         return super.scaleY;
      }
      
      protected function setScaleY(param1:Number) : void
      {
         super.scaleY = param1;
      }
      
      protected function getScaleX() : Number
      {
         return super.scaleX;
      }
      
      protected function setScaleX(param1:Number) : void
      {
         super.scaleX = param1;
      }
      
      override public function get visible() : Boolean
      {
         return super.visible;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible == param1)
         {
            return;
         }
         super.visible = param1;
         var _loc2_:String = param1 ? "show" : "hide";
         dispatchEvent(new ComponentEvent(_loc2_,true));
      }
      
      public function validateNow() : void
      {
         invalidate("all",false);
         draw();
      }
      
      public function invalidate(param1:String = "all", param2:Boolean = true) : void
      {
         invalidHash[param1] = true;
         if(param2)
         {
            this.callLater(draw);
         }
      }
      
      public function setSharedStyle(param1:String, param2:Object) : void
      {
         if(sharedStyles[param1] === param2 && !(param2 is TextFormat))
         {
            return;
         }
         sharedStyles[param1] = param2;
         if(instanceStyles[param1] == null)
         {
            invalidate("styles");
         }
      }
      
      public function get focusEnabled() : Boolean
      {
         return _focusEnabled;
      }
      
      public function set focusEnabled(param1:Boolean) : void
      {
         _focusEnabled = param1;
      }
      
      public function get mouseFocusEnabled() : Boolean
      {
         return _mouseFocusEnabled;
      }
      
      public function set mouseFocusEnabled(param1:Boolean) : void
      {
         _mouseFocusEnabled = param1;
      }
      
      public function get focusManager() : IFocusManager
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_)
         {
            if(UIComponent.focusManagers[_loc1_] != null)
            {
               return IFocusManager(UIComponent.focusManagers[_loc1_]);
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }
      
      public function set focusManager(param1:IFocusManager) : void
      {
         UIComponent.focusManagers[this] = param1;
      }
      
      public function drawFocus(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         isFocused = param1;
         if(uiFocusRect != null && contains(uiFocusRect))
         {
            removeChild(uiFocusRect);
            uiFocusRect = null;
         }
         if(param1)
         {
            uiFocusRect = getDisplayObjectInstance(getStyleValue("focusRectSkin")) as Sprite;
            if(uiFocusRect == null)
            {
               return;
            }
            _loc2_ = Number(getStyleValue("focusRectPadding"));
            uiFocusRect.x = -_loc2_;
            uiFocusRect.y = -_loc2_;
            uiFocusRect.width = width + _loc2_ * 2;
            uiFocusRect.height = height + _loc2_ * 2;
            addChildAt(uiFocusRect,0);
         }
      }
      
      public function setFocus() : void
      {
         if(stage)
         {
            stage.focus = this;
         }
      }
      
      public function getFocus() : InteractiveObject
      {
         if(stage)
         {
            return stage.focus;
         }
         return null;
      }
      
      protected function setIMEMode(param1:Boolean) : *
      {
         if(_imeMode != null)
         {
            if(param1)
            {
               IME.enabled = true;
               _oldIMEMode = IME.conversionMode;
               try
               {
                  if(!errorCaught && IME.conversionMode != "UNKNOWN")
                  {
                     IME.conversionMode = _imeMode;
                  }
                  errorCaught = false;
               }
               catch(e:Error)
               {
                  errorCaught = true;
                  throw new Error("IME mode not supported: " + _imeMode);
               }
            }
            else
            {
               if(IME.conversionMode != "UNKNOWN" && _oldIMEMode != "UNKNOWN")
               {
                  IME.conversionMode = _oldIMEMode;
               }
               IME.enabled = false;
            }
         }
      }
      
      public function drawNow() : void
      {
         draw();
      }
      
      protected function configUI() : void
      {
         isLivePreview = checkLivePreview();
         var _loc2_:Number = rotation;
         rotation = 0;
         var _loc1_:Number = super.width;
         var _loc3_:Number = super.height;
         super.scaleX = super.scaleY = 1;
         setSize(_loc1_,_loc3_);
         move(super.x,super.y);
         rotation = _loc2_;
         startWidth = _loc1_;
         startHeight = _loc3_;
         if(numChildren > 0)
         {
            removeChildAt(0);
         }
      }
      
      protected function checkLivePreview() : Boolean
      {
         var _loc1_:String = null;
         if(parent == null)
         {
            return false;
         }
         try
         {
            _loc1_ = getQualifiedClassName(parent);
         }
         catch(e:Error)
         {
         }
         return _loc1_ == "fl.livepreview::LivePreviewParent";
      }
      
      protected function isInvalid(param1:String, ... rest) : Boolean
      {
         if(invalidHash[param1] || invalidHash["all"])
         {
            return true;
         }
         while(rest.length > 0)
         {
            if(invalidHash[rest.pop()])
            {
               return true;
            }
         }
         return false;
      }
      
      protected function validate() : void
      {
         invalidHash = {};
      }
      
      protected function draw() : void
      {
         if(isInvalid("size","styles"))
         {
            if(isFocused && focusManager.showFocusIndicator)
            {
               drawFocus(true);
            }
         }
         validate();
      }
      
      protected function getDisplayObjectInstance(param1:Object) : DisplayObject
      {
         var _loc2_:Object = null;
         if(param1 is Class)
         {
            return new param1() as DisplayObject;
         }
         if(param1 is DisplayObject)
         {
            (param1 as DisplayObject).x = 0;
            (param1 as DisplayObject).y = 0;
            return param1 as DisplayObject;
         }
         trace("skin.toString():" + param1.toString());
         try
         {
            _loc2_ = getDefinitionByName(param1.toString());
         }
         catch(e:Error)
         {
            try
            {
               _loc2_ = loaderInfo.applicationDomain.getDefinition(param1.toString()) as Object;
            }
            catch(e:Error)
            {
            }
         }
         if(_loc2_ == null)
         {
            return null;
         }
         return new _loc2_() as DisplayObject;
      }
      
      protected function getStyleValue(param1:String) : Object
      {
         return instanceStyles[param1] == null ? sharedStyles[param1] : instanceStyles[param1];
      }
      
      protected function copyStylesToChild(param1:UIComponent, param2:Object) : void
      {
         for(var _loc3_ in param2)
         {
            param1.setStyle(_loc3_,getStyleValue(param2[_loc3_]));
         }
      }
      
      protected function callLater(param1:Function) : void
      {
         if(inCallLaterPhase)
         {
            return;
         }
         callLaterMethods[param1] = true;
         if(stage != null)
         {
            try
            {
               stage.addEventListener("render",callLaterDispatcher,false,0,true);
               stage.invalidate();
            }
            catch(se:SecurityError)
            {
               addEventListener("enterFrame",callLaterDispatcher,false,0,true);
            }
         }
         else
         {
            addEventListener("addedToStage",callLaterDispatcher,false,0,true);
         }
      }
      
      private function callLaterDispatcher(param1:Event) : void
      {
         if(param1.type == "addedToStage")
         {
            try
            {
               removeEventListener("addedToStage",callLaterDispatcher);
               stage.addEventListener("render",callLaterDispatcher,false,0,true);
               stage.invalidate();
               return;
            }
            catch(se1:SecurityError)
            {
               addEventListener("enterFrame",callLaterDispatcher,false,0,true);
            }
         }
         else
         {
            param1.target.removeEventListener("render",callLaterDispatcher);
            param1.target.removeEventListener("enterFrame",callLaterDispatcher);
            try
            {
               if(stage == null)
               {
                  addEventListener("addedToStage",callLaterDispatcher,false,0,true);
                  return;
               }
            }
            catch(se2:SecurityError)
            {
            }
         }
         inCallLaterPhase = true;
         var _loc2_:Dictionary = callLaterMethods;
         for(var _loc3_ in _loc2_)
         {
            _loc3_();
            delete _loc2_[_loc3_];
         }
         inCallLaterPhase = false;
      }
      
      private function initializeFocusManager() : void
      {
         var _loc1_:IFocusManager = null;
         var _loc2_:Dictionary = null;
         if(stage == null)
         {
            addEventListener("addedToStage",addedHandler,false,0,true);
         }
         else
         {
            createFocusManager();
            _loc1_ = focusManager;
            if(_loc1_ != null)
            {
               _loc2_ = focusManagerUsers[_loc1_];
               if(_loc2_ == null)
               {
                  _loc2_ = new Dictionary(true);
                  focusManagerUsers[_loc1_] = _loc2_;
               }
               _loc2_[this] = true;
            }
         }
         addEventListener("removedFromStage",removedHandler);
      }
      
      private function addedHandler(param1:Event) : void
      {
         removeEventListener("addedToStage",addedHandler);
         initializeFocusManager();
      }
      
      private function removedHandler(param1:Event) : void
      {
         var _loc3_:Dictionary = null;
         var _loc6_:Boolean = false;
         var _loc4_:IFocusManager = null;
         removeEventListener("removedFromStage",removedHandler);
         addEventListener("addedToStage",addedHandler);
         var _loc2_:IFocusManager = focusManager;
         if(_loc2_ != null)
         {
            _loc3_ = focusManagerUsers[_loc2_];
            if(_loc3_ != null)
            {
               delete _loc3_[this];
               _loc6_ = true;
               var _loc9_:int = 0;
               var _loc8_:Dictionary = _loc3_;
               for(var _loc7_ in _loc8_)
               {
                  _loc6_ = false;
               }
               if(_loc6_)
               {
                  delete focusManagerUsers[_loc2_];
                  _loc3_ = null;
               }
            }
            if(_loc3_ == null)
            {
               _loc2_.deactivate();
               for(var _loc5_ in focusManagers)
               {
                  _loc4_ = focusManagers[_loc5_];
                  if(_loc2_ == _loc4_)
                  {
                     delete focusManagers[_loc5_];
                  }
               }
            }
         }
      }
      
      protected function createFocusManager() : void
      {
         var _loc2_:Boolean = true;
         try
         {
            stage.getChildAt(0);
         }
         catch(se:SecurityError)
         {
            _loc2_ = false;
         }
         var _loc1_:DisplayObjectContainer = null;
         if(_loc2_)
         {
            _loc1_ = stage;
         }
         else
         {
            _loc1_ = this;
            try
            {
               while(_loc1_.parent != null)
               {
                  _loc1_ = _loc1_.parent;
               }
            }
            catch(se:SecurityError)
            {
            }
         }
         if(focusManagers[_loc1_] == null)
         {
            focusManagers[_loc1_] = new FocusManager(_loc1_);
         }
      }
      
      protected function isOurFocus(param1:DisplayObject) : Boolean
      {
         return param1 == this;
      }
      
      protected function focusInHandler(param1:FocusEvent) : void
      {
         var _loc2_:IFocusManager = null;
         if(isOurFocus(param1.target as DisplayObject))
         {
            _loc2_ = focusManager;
            if(_loc2_ && _loc2_.showFocusIndicator)
            {
               drawFocus(true);
               isFocused = true;
            }
         }
      }
      
      protected function focusOutHandler(param1:FocusEvent) : void
      {
         if(isOurFocus(param1.target as DisplayObject))
         {
            drawFocus(false);
            isFocused = false;
         }
      }
      
      protected function keyDownHandler(param1:KeyboardEvent) : void
      {
      }
      
      protected function keyUpHandler(param1:KeyboardEvent) : void
      {
      }
      
      protected function hookAccessibility(param1:Event) : void
      {
         removeEventListener("enterFrame",hookAccessibility);
         initializeAccessibility();
      }
      
      protected function initializeAccessibility() : void
      {
         if(UIComponent.createAccessibilityImplementation != null)
         {
            UIComponent.createAccessibilityImplementation(this);
         }
      }
   }
}

