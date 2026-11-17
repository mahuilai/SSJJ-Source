package ui
{
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import ui.core.UICommon;
   
   public class UISlider extends UIBase
   {
      
      public static const HORIZONTAL:String = "horizontal";
      
      public static const VERTICAL:String = "vertical";
      
      protected var _allowBackClick:Boolean;
      
      protected var _max:Number = 100;
      
      protected var _min:Number = 0;
      
      protected var _tick:Number = 1;
      
      protected var _value:Number = 0;
      
      protected var _direction:String = "vertical";
      
      protected var _skin:String;
      
      protected var _back:UIImage;
      
      protected var _bar:UIButton;
      
      protected var _label:UILabel;
      
      protected var _showLabel:Boolean = true;
      
      public function UISlider(param1:String = null)
      {
         super();
         this.skin = param1;
         this.styleName = "UISlider";
      }
      
      override protected function preinitialize() : void
      {
         mouseChildren = true;
      }
      
      override protected function createChildren() : void
      {
         addChild(_back = new UIImage());
         addChild(_bar = new UIButton());
         addChild(_label = new UILabel());
      }
      
      override protected function initialize() : void
      {
         _bar.addEventListener("mouseDown",onButtonMouseDown);
         _back.sizeGrid = _bar.sizeGrid = "4,4,4,4";
         allowBackClick = true;
      }
      
      protected function onButtonMouseDown(param1:MouseEvent) : void
      {
         UICommon.stage.addEventListener("mouseUp",onStageMouseUp);
         UICommon.stage.addEventListener("mouseMove",onStageMouseMove);
         if(_direction == "vertical")
         {
            _bar.startDrag(false,new Rectangle(_bar.x,0,0,height - _bar.height));
         }
         else
         {
            _bar.startDrag(false,new Rectangle(0,_bar.y,width - _bar.width,0));
         }
         showValueText();
      }
      
      protected function showValueText() : void
      {
         if(_showLabel)
         {
            _label.text = _value + "";
            if(_direction == "vertical")
            {
               _label.x = _bar.x + 20;
               _label.y = (_bar.height - _label.height) * 0.5 + _bar.y;
            }
            else
            {
               _label.y = _bar.y - 20;
               _label.x = (_bar.width - _label.width) * 0.5 + _bar.x;
            }
         }
      }
      
      protected function hideValueText() : void
      {
         _label.text = "";
      }
      
      protected function onStageMouseUp(param1:MouseEvent) : void
      {
         UICommon.stage.removeEventListener("mouseUp",onStageMouseUp);
         UICommon.stage.removeEventListener("mouseMove",onStageMouseMove);
         _bar.stopDrag();
         hideValueText();
      }
      
      protected function onStageMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Number = _value;
         if(_direction == "vertical")
         {
            _value = _bar.y / (height - _bar.height) * (_max - _min) + _min;
         }
         else
         {
            _value = _bar.x / (width - _bar.width) * (_max - _min) + _min;
         }
         if(max <= min)
         {
            _value = 0;
         }
         _value = Math.round(_value / _tick) * _tick;
         if(_value != _loc2_)
         {
            showValueText();
            sendChangeEvent();
         }
      }
      
      protected function sendChangeEvent() : void
      {
         sendEvent("change");
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
            _back.skin = _skin;
            _bar.skin = _skin + "_bar";
            _contentWidth = _back.width;
            _contentHeight = _back.height;
            setBarPoint();
            callLater(changeBarSize);
         }
      }
      
      override protected function changeSize() : void
      {
         super.changeSize();
         _back.width = width;
         _back.height = height;
         setBarPoint();
         callLater(changeBarSize);
      }
      
      protected function setBarPoint() : void
      {
         if(_direction == "vertical")
         {
            _bar.x = (_back.width - _bar.width) * 0.5;
         }
         else
         {
            _bar.y = (_back.height - _bar.height) * 0.5;
         }
      }
      
      public function get sizeGrid() : String
      {
         return _back.sizeGrid;
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _back.sizeGrid = param1;
      }
      
      protected function changeValue() : void
      {
         _value = Math.round(_value / _tick) * _tick;
         if(max <= min)
         {
            _value = 0;
         }
         else
         {
            _value = _value > _max ? _max : (_value < _min ? _min : _value);
         }
         if(_direction == "vertical")
         {
            _bar.y = (_value - _min) / (_max - _min) * (height - _bar.height);
         }
         else
         {
            _bar.x = (_value - _min) / (_max - _min) * (width - _bar.width);
         }
         _bar.enabled = max > min;
         sendChangeEvent();
      }
      
      protected function changeBarSize() : void
      {
         if(_direction == "vertical")
         {
            if(_bar.height > _back.height)
            {
               _bar.height = _back.height * 0.9;
            }
         }
         else if(_bar.width > _back.width)
         {
            _bar.width = _back.width * 0.9;
         }
      }
      
      public function setSlider(param1:Number, param2:Number, param3:Number) : void
      {
         _value = -1;
         this.min = param1;
         this.max = param2 > param1 ? param2 : param1;
         this.value = param3 < param1 ? param1 : (param3 > param2 ? param2 : param3);
      }
      
      public function get tick() : Number
      {
         return _tick;
      }
      
      public function set tick(param1:Number) : void
      {
         _tick = param1;
         callLater(changeValue);
      }
      
      public function get max() : Number
      {
         return _max;
      }
      
      public function set max(param1:Number) : void
      {
         if(_max != param1)
         {
            _max = param1;
            callLater(changeValue);
            callLater(changeBarSize);
         }
      }
      
      public function get min() : Number
      {
         return _min;
      }
      
      public function set min(param1:Number) : void
      {
         if(_min != param1)
         {
            _min = param1;
            callLater(changeValue);
            callLater(changeBarSize);
         }
      }
      
      public function get value() : Number
      {
         return _value;
      }
      
      public function set value(param1:Number) : void
      {
         if(_value != param1)
         {
            _value = param1;
            changeValue();
            sendChangeEvent();
         }
      }
      
      public function get direction() : String
      {
         return _direction;
      }
      
      public function set direction(param1:String) : void
      {
         _direction = param1;
      }
      
      public function get showLabel() : Boolean
      {
         return _showLabel;
      }
      
      public function set showLabel(param1:Boolean) : void
      {
         _showLabel = param1;
      }
      
      public function get allowBackClick() : Boolean
      {
         return _allowBackClick;
      }
      
      public function set allowBackClick(param1:Boolean) : void
      {
         if(_allowBackClick != param1)
         {
            _allowBackClick = param1;
            if(_allowBackClick)
            {
               _back.addEventListener("mouseDown",onBackBoxMouseDown);
            }
            else
            {
               _back.removeEventListener("mouseDown",onBackBoxMouseDown);
            }
         }
      }
      
      protected function onBackBoxMouseDown(param1:MouseEvent) : void
      {
         if(_direction == "vertical")
         {
            value = _back.mouseY / (height - _bar.height) * (_max - _min) + _min;
         }
         else
         {
            value = _back.mouseX / (width - _bar.width) * (_max - _min) + _min;
         }
      }
      
      public function get bar() : UIButton
      {
         return _bar;
      }
   }
}

