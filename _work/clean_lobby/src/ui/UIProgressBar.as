package ui
{
   import flash.display.Shape;
   
   public class UIProgressBar extends UIBase
   {
      
      public static const DIRECTION_RIGHT:String = "direction_right";
      
      public static const DIRECTION_LEFT:String = "direction_left";
      
      public static const DIRECTION_UP:String = "direction_up";
      
      public static const DIRECTION_DOWN:String = "direction_down";
      
      protected var _bg:UIImage;
      
      protected var _bar:UIImage;
      
      protected var _skin:String;
      
      protected var _percent:Number = 0.5;
      
      protected var _label:String;
      
      protected var _barLabel:UILabel;
      
      protected var _barMask:Shape;
      
      protected var _direction:String = "direction_right";
      
      public function UIProgressBar(param1:String = null)
      {
         super();
         this.skin = param1;
      }
      
      override protected function createChildren() : void
      {
         addChild(_bg = new UIImage());
         addChild(_bar = new UIImage());
         addChild(_barLabel = new UILabel());
         _barMask = new Shape();
         _barMask.graphics.beginFill(0);
         _barMask.graphics.drawRect(0,0,2,2);
         _barMask.graphics.endFill();
         addChild(_barMask);
         _bar.mask = _barMask;
         _barMask.width = _barMask.height = 1;
      }
      
      override protected function initialize() : void
      {
         _barLabel.width = 200;
         _barLabel.height = 18;
         _barLabel.textAlign = "center";
         _barLabel.filtersColor = "0x004080";
         _barLabel.textColor = "0xffffff";
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
            _bg.skin = _skin + "_back";
            _bar.skin = _skin;
            _contentWidth = _bg.width;
            _contentHeight = _bg.height;
            callLater(changeLabelPoint);
            callLater(changeValue);
         }
      }
      
      protected function changeLabelPoint() : void
      {
         _barLabel.x = (width - _barLabel.width) * 0.5;
         _barLabel.y = (height - _barLabel.height) * 0.5 - 2;
      }
      
      public function set direction(param1:String) : void
      {
         _direction = param1;
         _barMask.x = 0;
         _barMask.y = 0;
      }
      
      public function get direction() : String
      {
         return _direction;
      }
      
      public function get percent() : Number
      {
         return _percent;
      }
      
      public function set percent(param1:Number) : void
      {
         if(_percent != param1)
         {
            param1 = param1 > 1 ? 1 : (param1 < 0 ? 0 : param1);
            _percent = param1;
            sendEvent("change");
            callLater(changeValue);
         }
      }
      
      protected function changeValue() : void
      {
         var _loc3_:Array = null;
         var _loc1_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Number = NaN;
         if(sizeGrid)
         {
            _loc3_ = sizeGrid.split(",");
            if(_direction == "direction_right" || _direction == "direction_left")
            {
               _barMask.height = height;
               _loc4_ = Number(_loc3_[0]);
               _loc5_ = Number(_loc3_[2]);
               _loc1_ = width - _loc4_ - _loc5_;
               _loc6_ = _loc1_ * _percent;
               _barMask.width = _loc4_ + _loc5_ + _loc6_;
               _bar.visible = _barMask.width > _loc4_ + _loc5_;
               if(_direction == "direction_left")
               {
                  _barMask.x = _bg.width - _barMask.width;
               }
            }
            else if(_direction == "direction_down" || _direction == "direction_up")
            {
               _barMask.width = width;
               _loc7_ = Number(_loc3_[1]);
               _loc2_ = Number(_loc3_[3]);
               _loc1_ = height - _loc7_ - _loc2_;
               _loc6_ = _loc1_ * _percent;
               _barMask.height = _loc7_ + _loc2_ + _loc6_;
               _bar.visible = _barMask.height > _loc7_ + _loc2_;
               if(_direction == "direction_up")
               {
                  _barMask.y = _bg.height - _barMask.height;
               }
            }
         }
         else if(_direction == "direction_right")
         {
            _barMask.height = height;
            _barMask.width = width * _percent;
         }
         else if(_direction == "direction_left")
         {
            _barMask.height = height;
            _barMask.width = width * _percent;
            _barMask.x = _bg.width - _barMask.width;
         }
         else if(_direction == "direction_down")
         {
            _barMask.width = width;
            _barMask.height = height * _percent;
         }
         else if(_direction == "direction_up")
         {
            _barMask.width = width;
            _barMask.height = height * _percent;
            _barMask.y = _bg.height - _barMask.height;
         }
      }
      
      public function get label() : String
      {
         return _label;
      }
      
      public function set label(param1:String) : void
      {
         if(_label != param1)
         {
            _label = param1;
            _barLabel.text = _label;
         }
      }
      
      public function get bar() : UIImage
      {
         return _bar;
      }
      
      public function get barLabel() : UILabel
      {
         return _barLabel;
      }
      
      public function get sizeGrid() : String
      {
         return _bg.sizeGrid;
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _bg.sizeGrid = _bar.sizeGrid = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         _bg.width = _width;
         _bar.width = _width;
         _barLabel.width = _width;
         callLater(changeLabelPoint);
         callLater(changeValue);
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         _bg.height = _height;
         _bar.height = _height;
         callLater(changeLabelPoint);
      }
      
      override public function dispose() : void
      {
         _bg.dispose();
         _bar.dispose();
      }
   }
}

