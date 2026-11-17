package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import ui.core.UICommon;
   
   public class UIScrollBar extends UIBase
   {
      
      public static const HORIZONTAL:String = "horizontal";
      
      public static const VERTICAL:String = "vertical";
      
      public static var scrollBarDelayTime:int = 500;
      
      public static var scrollBarMinNum:int = 15;
      
      protected var _scrollSize:Number = 1;
      
      protected var _skin:String;
      
      protected var _upButton:UIButton;
      
      protected var _downButton:UIButton;
      
      protected var _slider:UISlider;
      
      protected var _thumbPercent:Number = 0.3;
      
      protected var _target:Sprite;
      
      protected var _touchScrollEnable:Boolean = false;
      
      protected var _lastPoint:Point;
      
      protected var _lastOffset:Number;
      
      protected var _scrollRectangle:Rectangle;
      
      protected var _contentMask:UIMask;
      
      public function UIScrollBar(param1:String = null)
      {
         super();
         this.skin = param1;
         this.styleName = "UIScrollBar";
      }
      
      override protected function preinitialize() : void
      {
         mouseChildren = true;
      }
      
      override protected function createChildren() : void
      {
         addChild(_slider = new UISlider());
         addChild(_upButton = new UIButton());
         addChild(_downButton = new UIButton());
         _contentMask = new UIMask();
      }
      
      override protected function initialize() : void
      {
         _slider.showLabel = false;
         _slider.addEventListener("change",onSliderChange);
         _slider.setSlider(0,0,0);
         _upButton.addEventListener("mouseDown",onButtonMouseDown);
         _downButton.addEventListener("mouseDown",onButtonMouseDown);
      }
      
      protected function onSliderChange(param1:Event) : void
      {
         if(target && _scrollRectangle)
         {
            if(direction == "vertical")
            {
               target.y = -value;
            }
            else
            {
               target.x = -value;
            }
         }
         sendEvent("change");
      }
      
      protected function onButtonMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = param1.currentTarget == _upButton;
         slide(_loc2_);
         UICommon.timer.doOnce(scrollBarDelayTime,startLoop,[_loc2_]);
         UICommon.stage.addEventListener("mouseUp",onStageMouseUp);
      }
      
      protected function startLoop(param1:Boolean) : void
      {
         UICommon.timer.doFrameLoop(1,slide,[param1]);
      }
      
      protected function slide(param1:Boolean) : void
      {
         if(param1)
         {
            value -= _scrollSize;
         }
         else
         {
            value += _scrollSize;
         }
      }
      
      protected function onStageMouseUp(param1:MouseEvent) : void
      {
         UICommon.stage.removeEventListener("mouseUp",onStageMouseUp);
         UICommon.timer.clearTimer(startLoop);
         UICommon.timer.clearTimer(slide);
      }
      
      public function get skin() : String
      {
         return _skin;
      }
      
      public function set skin(param1:String) : void
      {
         if(_skin != param1)
         {
            _skin = param1;
            _slider.skin = _skin;
            _upButton.skin = _skin + "_up";
            _downButton.skin = _skin + "_down";
            callLater(changeScrollBar);
         }
      }
      
      protected function changeScrollBar() : void
      {
         if(_slider.direction == "vertical")
         {
            _slider.y = _upButton.height;
         }
         else
         {
            _slider.x = _upButton.width;
         }
         resetButtonPosition();
      }
      
      protected function resetButtonPosition() : void
      {
         if(_slider.direction == "vertical")
         {
            _downButton.y = _slider.y + _slider.height;
            _contentWidth = _downButton.width;
            _contentHeight = _downButton.y + _downButton.height;
         }
         else
         {
            _downButton.x = _slider.x + _slider.width;
            _contentWidth = _downButton.x + _downButton.width;
            _contentHeight = _downButton.height;
         }
      }
      
      override protected function changeSize() : void
      {
         super.changeSize();
         if(_slider.direction == "vertical")
         {
            _slider.height = height - _upButton.height - _downButton.height;
         }
         else
         {
            _slider.width = width - _upButton.width - _downButton.width;
         }
         resetButtonPosition();
      }
      
      public function setScroll(param1:Number, param2:Number, param3:Number) : void
      {
         exeCallLater(changeSize);
         _slider.setSlider(param1,param2,param3);
         _upButton.enabled = param2 > 0;
         _downButton.enabled = param2 > 0;
         _slider.bar.visible = param2 > 0;
      }
      
      public function get max() : Number
      {
         return _slider.max;
      }
      
      public function set max(param1:Number) : void
      {
         _slider.max = param1;
      }
      
      public function get min() : Number
      {
         return _slider.min;
      }
      
      public function set min(param1:Number) : void
      {
         _slider.min = param1;
      }
      
      public function get value() : Number
      {
         return _slider.value;
      }
      
      public function set value(param1:Number) : void
      {
         _slider.value = param1;
      }
      
      public function get direction() : String
      {
         return _slider.direction;
      }
      
      public function set direction(param1:String) : void
      {
         _slider.direction = param1;
      }
      
      public function get sizeGrid() : String
      {
         return _slider.sizeGrid;
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _slider.sizeGrid = param1;
      }
      
      public function get scrollSize() : Number
      {
         return _scrollSize;
      }
      
      public function set scrollSize(param1:Number) : void
      {
         _scrollSize = param1;
      }
      
      public function get thumbPercent() : Number
      {
         return _thumbPercent;
      }
      
      public function set thumbPercent(param1:Number) : void
      {
         exeCallLater(changeSize);
         _thumbPercent = param1;
         if(_slider.direction == "vertical")
         {
            _slider.bar.height = Math.max(int(_slider.height * param1),scrollBarMinNum);
         }
         else
         {
            _slider.bar.width = Math.max(int(_slider.width * param1),scrollBarMinNum);
         }
      }
      
      public function get target() : Sprite
      {
         return _target;
      }
      
      public function set target(param1:Sprite) : void
      {
         if(_target)
         {
            _target.removeEventListener("mouseWheel",onMouseWheel);
            _target.removeEventListener("mouseDown",onTargetMouseDown);
            _contentMask.dispose();
         }
         _target = param1;
         if(param1)
         {
            _contentMask.target = param1;
            _target.addEventListener("mouseWheel",onMouseWheel);
            if(_touchScrollEnable)
            {
               _target.addEventListener("mouseDown",onTargetMouseDown);
            }
         }
      }
      
      public function set scrollRectangle(param1:Rectangle) : void
      {
         _scrollRectangle = param1;
         _contentMask.x = _scrollRectangle.x;
         _contentMask.y = _scrollRectangle.y;
         _contentMask.width = _scrollRectangle.width;
         _contentMask.height = _scrollRectangle.height;
         var _loc2_:Rectangle = target.getRect(target);
         if(direction == "vertical")
         {
            min = _scrollRectangle.y;
            max = _loc2_.y + target.height - _scrollRectangle.height;
            thumbPercent = _scrollRectangle.height / (max - min);
         }
         else
         {
            min = _scrollRectangle.x;
            max = _loc2_.x + target.width - _scrollRectangle.width;
            thumbPercent = _scrollRectangle.width / (max - min);
         }
         onSliderChange(null);
      }
      
      public function get scrollRectangle() : Rectangle
      {
         return _scrollRectangle;
      }
      
      public function get touchScrollEnable() : Boolean
      {
         return _touchScrollEnable;
      }
      
      public function set touchScrollEnable(param1:Boolean) : void
      {
         _touchScrollEnable = param1;
      }
      
      protected function onTargetMouseDown(param1:MouseEvent) : void
      {
         _target.mouseChildren = true;
         UICommon.timer.clearTimer(tweenMove);
         if(!this.contains(param1.target as DisplayObject))
         {
            UICommon.stage.addEventListener("mouseUp",onStageMouseUp2);
            UICommon.stage.addEventListener("enterFrame",onStageEnterFrame);
            _lastPoint = new Point(UICommon.stage.mouseX,UICommon.stage.mouseY);
         }
      }
      
      protected function onStageEnterFrame(param1:Event) : void
      {
         _lastOffset = _slider.direction == "vertical" ? UICommon.stage.mouseY - _lastPoint.y : UICommon.stage.mouseX - _lastPoint.x;
         if(Math.abs(_lastOffset) >= 1)
         {
            _lastPoint.x = UICommon.stage.mouseX;
            _lastPoint.y = UICommon.stage.mouseY;
            _target.mouseChildren = false;
            value -= _lastOffset;
         }
      }
      
      protected function onStageMouseUp2(param1:MouseEvent) : void
      {
         UICommon.stage.removeEventListener("mouseUp",onStageMouseUp2);
         UICommon.stage.removeEventListener("enterFrame",onStageEnterFrame);
         if(Math.abs(_lastOffset) > 50)
         {
            _lastOffset = 50 * (_lastOffset > 0 ? 1 : -1);
         }
         UICommon.timer.doFrameLoop(1,tweenMove);
      }
      
      private function tweenMove() : void
      {
         _lastOffset *= 0.92;
         value -= _lastOffset;
         if(Math.abs(_lastOffset) < 0.5)
         {
            _target.mouseChildren = true;
            UICommon.timer.clearTimer(tweenMove);
         }
      }
      
      protected function onMouseWheel(param1:MouseEvent) : void
      {
         value += (param1.delta < 0 ? 1 : -1) * _thumbPercent * (max - min);
         if(value < max && value > min)
         {
            param1.stopPropagation();
         }
      }
   }
}

