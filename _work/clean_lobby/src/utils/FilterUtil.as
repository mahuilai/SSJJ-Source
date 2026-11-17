package utils
{
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   
   public class FilterUtil
   {
      
      public static const GRAY_FILTER:ColorMatrixFilter = new ColorMatrixFilter([0.30815,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]);
      
      public static const LIGHT_COLOR_TRANSFORM:ColorTransform = new ColorTransform(1,1,1,1,40,40,40,0);
      
      public static const DARK_COLOR_TRANSFORM:ColorTransform = new ColorTransform(1,1,1,1,-50,-50,-50,0);
      
      public function FilterUtil()
      {
         super();
      }
      
      public static function addFilter(param1:DisplayObject, param2:BitmapFilter) : void
      {
         var _loc3_:Array = param1.filters || [];
         _loc3_.push(param2);
         param1.filters = _loc3_;
      }
      
      public static function clearFilter(param1:DisplayObject, param2:Class) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = undefined;
         var _loc4_:Array = param1.filters;
         if(_loc4_ != null && _loc4_.length > 0)
         {
            _loc5_ = _loc4_.length - 1;
            while(_loc5_ > -1)
            {
               _loc3_ = _loc4_[_loc5_];
               if(_loc3_ is param2)
               {
                  _loc4_.splice(_loc5_,1);
               }
               _loc5_--;
            }
            param1.filters = _loc4_;
         }
      }
      
      public static function getStrokeFilter(param1:uint = 0, param2:Number = 1, param3:Number = 2, param4:Number = 2, param5:Number = 16) : GlowFilter
      {
         return new GlowFilter(param1,param2,param3,param4,param5);
      }
      
      public static function gray(param1:DisplayObject, param2:Boolean = true) : void
      {
         if(param2)
         {
            addFilter(param1,GRAY_FILTER);
         }
         else
         {
            clearFilter(param1,ColorMatrixFilter);
         }
      }
   }
}

