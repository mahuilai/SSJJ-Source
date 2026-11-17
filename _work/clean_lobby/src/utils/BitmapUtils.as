package utils
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class BitmapUtils
   {
      
      private static var m:Matrix = new Matrix();
      
      private static var newRect:Rectangle = new Rectangle();
      
      private static var clipRect:Rectangle = new Rectangle();
      
      private static var grid:Rectangle = new Rectangle();
      
      public function BitmapUtils()
      {
         super();
      }
      
      public static function scale9Bmd(param1:BitmapData, param2:Array, param3:int, param4:int) : BitmapData
      {
         var _loc11_:Array = null;
         var _loc6_:Array = null;
         var _loc8_:Array = null;
         var _loc10_:Array = null;
         var _loc12_:int = 0;
         var _loc9_:int = 0;
         if(param1.width == param3 && param1.height == param4)
         {
            return param1.clone();
         }
         param3 = param3 > 1 ? param3 : 1;
         param4 = param4 > 1 ? param4 : 1;
         var _loc7_:int = int(param2[0]) + int(param2[2]);
         var _loc13_:int = int(param2[1]) + int(param2[3]);
         var _loc5_:BitmapData = new BitmapData(param3,param4,param1.transparent,0);
         if(param3 > _loc7_ && param4 > _loc13_)
         {
            setRect(grid,param2[0],param2[1],param1.width - param2[0] - param2[2],param1.height - param2[1] - param2[3]);
            _loc11_ = [0,grid.top,grid.bottom,param1.height];
            _loc6_ = [0,grid.left,grid.right,param1.width];
            _loc8_ = [0,grid.top,param4 - (param1.height - grid.bottom),param4];
            _loc10_ = [0,grid.left,param3 - (param1.width - grid.right),param3];
            _loc12_ = 0;
            while(_loc12_ < 3)
            {
               _loc9_ = 0;
               while(_loc9_ < 3)
               {
                  setRect(newRect,_loc6_[_loc12_],_loc11_[_loc9_],_loc6_[_loc12_ + 1] - _loc6_[_loc12_],_loc11_[_loc9_ + 1] - _loc11_[_loc9_]);
                  setRect(clipRect,_loc10_[_loc12_],_loc8_[_loc9_],_loc10_[_loc12_ + 1] - _loc10_[_loc12_],_loc8_[_loc9_ + 1] - _loc8_[_loc9_]);
                  m.identity();
                  m.a = clipRect.width / newRect.width;
                  m.d = clipRect.height / newRect.height;
                  m.tx = clipRect.x - newRect.x * m.a;
                  m.ty = clipRect.y - newRect.y * m.d;
                  _loc5_.draw(param1,m,null,null,clipRect,true);
                  _loc9_++;
               }
               _loc12_++;
            }
         }
         else
         {
            m.identity();
            m.scale(param3 / param1.width,param4 / param1.height);
            setRect(grid,0,0,param3,param4);
            _loc5_.draw(param1,m,null,null,grid,true);
         }
         return _loc5_;
      }
      
      public static function setRect(param1:Rectangle, param2:Number = 0, param3:Number = 0, param4:Number = 0, param5:Number = 0) : Rectangle
      {
         param1.x = param2;
         param1.y = param3;
         param1.width = param4;
         param1.height = param5;
         return param1;
      }
      
      public static function createClips(param1:BitmapData, param2:int, param3:int, param4:int = 0) : Vector.<BitmapData>
      {
         var _loc11_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:BitmapData = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc10_:Vector.<BitmapData> = new Vector.<BitmapData>();
         var _loc8_:int = Math.max(param1.width / param2,1);
         var _loc6_:int = Math.max(param1.height / param3,1);
         var _loc5_:Point = new Point();
         _loc11_ = 0;
         while(_loc11_ < param3)
         {
            _loc9_ = 0;
            while(_loc9_ < param2)
            {
               _loc7_ = new BitmapData(_loc8_,_loc6_);
               _loc7_.copyPixels(param1,new Rectangle(_loc9_ * _loc8_,_loc11_ * _loc6_,_loc8_,_loc6_),_loc5_);
               _loc10_.push(_loc7_);
               if(param4 != 0 && param4 == _loc10_.length)
               {
                  break;
               }
               _loc9_++;
            }
            if(param4 != 0 && param4 == _loc10_.length)
            {
               break;
            }
            _loc11_++;
         }
         return _loc10_;
      }
   }
}

