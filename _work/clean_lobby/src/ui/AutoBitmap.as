package ui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import ui.core.UICommon;
   import utils.BitmapUtils;
   
   public class AutoBitmap extends Sprite
   {
      
      private var _x:Number = 0;
      
      private var _y:Number = 0;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _sizeGrid:Array;
      
      private var _source:Vector.<Asset>;
      
      private var _clips:Vector.<Asset>;
      
      private var _index:int;
      
      private var _smoothing:Boolean;
      
      private var _shape:Shape;
      
      private var _bitMap:Bitmap;
      
      private var _asset:Asset;
      
      public function AutoBitmap()
      {
         super();
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
      
      override public function set y(param1:Number) : void
      {
         _y = param1;
         super.y = Math.round(param1);
      }
      
      override public function get width() : Number
      {
         return isNaN(_width) ? super.width : _width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(_width != param1)
         {
            _width = param1;
            callLater(changeSize);
         }
      }
      
      override public function get height() : Number
      {
         return isNaN(_height) ? super.height : _height;
      }
      
      override public function set height(param1:Number) : void
      {
         if(_height != param1)
         {
            _height = param1;
            callLater(changeSize);
         }
      }
      
      public function get sizeGrid() : Array
      {
         return _sizeGrid;
      }
      
      public function set sizeGrid(param1:Array) : void
      {
         _sizeGrid = param1;
         callLater(changeSize);
      }
      
      public function set clip(param1:Asset) : void
      {
         if(param1)
         {
            clips = new <Asset>[param1];
         }
         else
         {
            disposeTempBitmapdata();
            _source = _clips = null;
            _asset = null;
            bitmapData = null;
            shape = null;
         }
      }
      
      public function get asset() : Asset
      {
         return _asset;
      }
      
      public function get clips() : Vector.<Asset>
      {
         return _source;
      }
      
      public function set clips(param1:Vector.<Asset>) : void
      {
         disposeTempBitmapdata();
         _source = param1;
         if(param1 && param1.length > 0)
         {
            asset = param1[0];
            callLater(changeSize);
         }
      }
      
      public function set asset(param1:Asset) : void
      {
         _asset = param1;
         bitmapData = null;
         shape = null;
         if(param1 == null)
         {
            return;
         }
         if(_asset.type == 1)
         {
            shape = _asset.data as Shape;
         }
         else if(_asset.type == 2)
         {
            bitmapData = _asset.data as BitmapData;
         }
      }
      
      private function set bitmapData(param1:BitmapData) : void
      {
         if(_bitMap && this.contains(_bitMap))
         {
            this.removeChild(_bitMap);
         }
         if(param1 == null)
         {
            return;
         }
         if(_bitMap == null)
         {
            _bitMap = new Bitmap();
         }
         _bitMap.bitmapData = param1;
         this.addChild(_bitMap);
      }
      
      private function set shape(param1:Shape) : void
      {
         if(_shape && this.contains(_shape))
         {
            this.removeChild(_shape);
         }
         _shape = param1;
         if(!param1)
         {
            return;
         }
         this.addChild(_shape);
      }
      
      public function get index() : int
      {
         return _index;
      }
      
      public function set index(param1:int) : void
      {
         _index = param1;
         if(_clips && _clips.length > 0)
         {
            _index = _index < _clips.length && _index > -1 ? _index : 0;
            asset = _clips[_index];
            if(_bitMap)
            {
               _bitMap.smoothing = _smoothing;
            }
         }
      }
      
      private function changeSize() : void
      {
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:* = undefined;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         if(_source && _source.length > 0)
         {
            _loc1_ = Math.round(width);
            _loc4_ = Math.round(height);
            disposeTempBitmapdata();
            _loc3_ = new Vector.<Asset>();
            _loc5_ = 0;
            _loc2_ = int(_source.length);
            while(_loc5_ < _loc2_)
            {
               if(_sizeGrid && _source[_loc5_].type == 2)
               {
                  _source[_loc5_].data = BitmapUtils.scale9Bmd(_source[_loc5_].data as BitmapData,_sizeGrid,_loc1_,_loc4_);
               }
               _loc3_.push(_source[_loc5_]);
               _loc5_++;
            }
            _clips = _loc3_;
            index = _index;
            super.width = _loc1_;
            super.height = _loc4_;
         }
      }
      
      private function disposeTempBitmapdata() : void
      {
         var _loc1_:int = 0;
         if(_clips)
         {
            _loc1_ = _clips.length - 1;
            while(_loc1_ > -1)
            {
               if(_clips[_loc1_].data != _source[_loc1_].data && _clips[_loc1_].type == 2)
               {
                  (_clips[_loc1_] as BitmapData).dispose();
               }
               _loc1_--;
            }
            _clips.length = 0;
         }
      }
      
      public function get smoothing() : Boolean
      {
         return _smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         _smoothing = param1;
      }
      
      public function callLater(param1:Function, param2:Array = null) : void
      {
         UICommon.render.callLater(param1,param2);
      }
      
      public function exeCallLater(param1:Function) : void
      {
         UICommon.render.exeCallLater(param1);
      }
      
      public function dispose() : void
      {
         disposeTempBitmapdata();
         _source = _clips = null;
         _asset = null;
         bitmapData = null;
         shape = null;
      }
   }
}

