package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import ui.core.UICommon;
   
   public class UIImageNumber extends Sprite
   {
      
      private var _x:Number = 0;
      
      private var _y:Number = 0;
      
      private var _offset:Number = -1;
      
      private var _valueNum:String = "0";
      
      protected var _skin:String = "MainAssets.medal_num";
      
      protected var _align:String = "right";
      
      protected var _bitmap:AutoBitmap = new AutoBitmap();
      
      public function UIImageNumber()
      {
         super();
         createNumSprite3();
      }
      
      override public function get x() : Number
      {
         return _x;
      }
      
      override public function set x(param1:Number) : void
      {
         _x = param1;
         super.x = Math.round(param1);
      }
      
      override public function get y() : Number
      {
         return _y;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get width() : Number
      {
         var _loc1_:Number = _bitmap.width / 10;
         return _valueNum.length * _loc1_;
      }
      
      private function get numWidth() : Number
      {
         return _bitmap.width / 10;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = _bitmap.height;
      }
      
      override public function get height() : Number
      {
         return _bitmap.height;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = 1;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = 1;
      }
      
      override public function set y(param1:Number) : void
      {
         _y = param1;
         super.y = Math.round(param1);
      }
      
      public function get valueNum() : String
      {
         return _valueNum;
      }
      
      public function set valueNum(param1:String) : void
      {
         _valueNum = param1;
         createNumSprite3();
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
            createNumSprite3();
         }
      }
      
      public function get align() : String
      {
         return _align;
      }
      
      public function set align(param1:String) : void
      {
         if(_align != param1)
         {
            _align = param1;
            if(this.numChildren <= 0)
            {
               createNumSprite3();
               updateAlign();
            }
            else
            {
               updateAlign();
            }
         }
      }
      
      private function updateAlign() : void
      {
         var _loc3_:int = 0;
         var _loc2_:Bitmap = null;
         var _loc1_:int = this._valueNum.length;
         _loc3_ = 0;
         while(_loc3_ < this.numChildren)
         {
            _loc2_ = this.getChildAt(_loc3_) as Bitmap;
            if(align == "left")
            {
               _loc2_.x = _loc3_ * numWidth + offset * _loc3_;
            }
            else if(align == "center")
            {
               _loc2_.x = _loc3_ * numWidth - numWidth * _loc1_ / 2 + offset * _loc3_;
            }
            else if(align == "right")
            {
               _loc2_.x = _loc3_ * numWidth - numWidth * _loc1_ + offset * _loc3_;
            }
            else
            {
               _loc2_.x = _loc3_ * numWidth - numWidth * _loc1_ + offset * _loc3_;
            }
            _loc3_++;
         }
      }
      
      private function createNumSprite3() : void
      {
         var _loc9_:int = 0;
         var _loc6_:BitmapData = null;
         var _loc3_:int = 0;
         var _loc8_:Bitmap = null;
         var _loc1_:Rectangle = null;
         this.removeChildren();
         var _loc4_:Asset = UICommon.asset.getAsset(_skin);
         if(_loc4_ == null)
         {
            return;
         }
         _bitmap.clip = _loc4_;
         var _loc5_:BitmapData = new BitmapData(_bitmap.width,_bitmap.height,true,0);
         _loc5_.draw(_bitmap);
         var _loc7_:int = _bitmap.height;
         var _loc2_:int = this._valueNum.length;
         _loc9_ = 0;
         while(_loc9_ < _loc2_)
         {
            _loc6_ = new BitmapData(numWidth,_loc7_,true,0);
            _loc3_ = int(_valueNum.charAt(_loc9_));
            _loc8_ = new Bitmap();
            _loc1_ = new Rectangle(_loc3_ * numWidth,0,numWidth,_loc7_);
            _loc6_.copyPixels(_loc5_,_loc1_,new Point(0,0));
            _loc8_.bitmapData = _loc6_;
            if(align == "left")
            {
               _loc8_.x = _loc9_ * numWidth + offset * _loc9_;
            }
            else if(align == "center")
            {
               _loc8_.x = _loc9_ * numWidth - numWidth * _loc2_ / 2 + offset * _loc9_;
            }
            else if(align == "right")
            {
               _loc8_.x = _loc9_ * numWidth - numWidth * _loc2_ + offset * _loc9_;
            }
            else
            {
               _loc8_.x = _loc9_ * numWidth - numWidth * _loc2_ + offset * _loc9_;
            }
            addChild(_loc8_);
            _loc9_++;
         }
      }
      
      public function get offset() : Number
      {
         return _offset;
      }
      
      public function set offset(param1:Number) : void
      {
         _offset = param1;
         createNumSprite3();
      }
   }
}

