package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import ui.core.UICommon;
   import ui.events.UIEvent;
   import utils.UIUtil;
   
   public class UIBase extends Sprite
   {
      
      protected var _width:Number;
      
      protected var _height:Number;
      
      protected var _contentWidth:Number = 0;
      
      protected var _contentHeight:Number = 0;
      
      protected var _enabled:Boolean = true;
      
      protected var _mouseChildren:Boolean;
      
      protected var _styleName:String;
      
      private var _time:int = 0;
      
      public function UIBase()
      {
         var _loc1_:* = undefined;
         super();
         if(numChildren > 0)
         {
            _loc1_ = this.getChildAt(0);
         }
         mouseChildren = tabEnabled = tabChildren = false;
         preinitialize();
         createChildren();
         initialize();
      }
      
      public function set styleName(param1:String) : void
      {
         _styleName = param1;
         style = UICommon.style.getStyle(param1);
      }
      
      public function get styleName() : String
      {
         return _styleName;
      }
      
      public function set style(param1:Object) : void
      {
         if(param1)
         {
            UIUtil.initObject(this,param1);
         }
      }
      
      protected function preinitialize() : void
      {
      }
      
      protected function createChildren() : void
      {
      }
      
      protected function initialize() : void
      {
      }
      
      public function commitMeasure() : void
      {
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
      }
      
      public function get displayWidth() : Number
      {
         return width * scaleX;
      }
      
      public function get displayHeight() : Number
      {
         return height * scaleY;
      }
      
      protected function get measureWidth() : Number
      {
         var _loc4_:int = 0;
         var _loc1_:DisplayObject = null;
         var _loc3_:Number = NaN;
         var _loc2_:Number = 0;
         _loc4_ = numChildren - 1;
         while(_loc4_ > -1)
         {
            _loc1_ = getChildAt(_loc4_);
            if(_loc1_.visible)
            {
               _loc3_ = _loc1_.x + _loc1_.width * _loc1_.scaleX;
               if(_loc1_ is UIBase)
               {
                  _loc3_ = _loc1_.x + _loc1_.width * _loc1_.scaleX;
               }
               else
               {
                  _loc3_ = _loc1_.x + _loc1_.width;
               }
               _loc2_ = Math.max(_loc3_,_loc2_);
            }
            _loc4_--;
         }
         return _loc2_;
      }
      
      protected function get measureHeight() : Number
      {
         var _loc4_:int = 0;
         var _loc1_:DisplayObject = null;
         var _loc3_:Number = NaN;
         var _loc2_:Number = 0;
         _loc4_ = numChildren - 1;
         while(_loc4_ > -1)
         {
            _loc1_ = getChildAt(_loc4_);
            if(_loc1_.visible)
            {
               if(_loc1_ is UIBase)
               {
                  _loc3_ = _loc1_.y + _loc1_.height * _loc1_.scaleY;
               }
               else
               {
                  _loc3_ = _loc1_.y + _loc1_.height;
               }
               _loc2_ = Math.max(_loc3_,_loc2_);
            }
            _loc4_--;
         }
         return _loc2_;
      }
      
      override public function set width(param1:Number) : void
      {
         if(_width != param1)
         {
            _width = param1;
            callLater(changeSize);
         }
      }
      
      override public function set height(param1:Number) : void
      {
         if(_height != param1)
         {
            _height = param1;
            callLater(changeSize);
         }
      }
      
      override public function get width() : Number
      {
         if(!isNaN(_width))
         {
            return _width;
         }
         if(_contentWidth != 0)
         {
            return _contentWidth;
         }
         return measureWidth;
      }
      
      override public function get height() : Number
      {
         if(!isNaN(_height))
         {
            return _height;
         }
         if(_contentHeight != 0)
         {
            return _contentHeight;
         }
         return measureHeight;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = param1;
         callLater(changeSize);
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = param1;
         callLater(changeSize);
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(_enabled != param1)
         {
            _enabled = param1;
            mouseEnabled = param1;
            super.mouseChildren = !param1 ? false : _mouseChildren;
         }
      }
      
      override public function set mouseChildren(param1:Boolean) : void
      {
         _mouseChildren = super.mouseChildren = param1;
      }
      
      protected function changeSize() : void
      {
         if(hasEventListener("resize"))
         {
            dispatchEvent(new Event("resize"));
         }
      }
      
      public function remove() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function removeChildByName(param1:String) : void
      {
         var _loc2_:DisplayObject = getChildByName(param1);
         if(_loc2_)
         {
            removeChild(_loc2_);
         }
      }
      
      public function callLater(param1:Function, param2:Array = null) : void
      {
         UICommon.render.callLater(param1,param2);
      }
      
      public function exeCallLater(param1:Function) : void
      {
         UICommon.render.exeCallLater(param1);
      }
      
      public function sendEvent(param1:String, param2:* = null) : void
      {
         if(hasEventListener(param1))
         {
            dispatchEvent(new UIEvent(param1,param2));
         }
      }
      
      public function dispose() : void
      {
      }
      
      public function isInvalid(param1:String, param2:String, param3:String = null) : Boolean
      {
         return true;
      }
      
      public function drawNow() : void
      {
      }
      
      protected function draw() : void
      {
      }
      
      public function validateNow() : void
      {
      }
      
      public function invalidate(param1:String = "", param2:Boolean = true) : void
      {
      }
   }
}

