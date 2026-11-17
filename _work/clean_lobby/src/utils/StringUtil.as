package utils
{
   public class StringUtil
   {
      
      public function StringUtil()
      {
         super();
      }
      
      public static function isEmpty(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return true;
         }
         return !param1.length;
      }
      
      public static function fillArray(param1:Array, param2:String, param3:Class = null) : Array
      {
         var _loc8_:int = 0;
         var _loc4_:Array = null;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:String = null;
         var _loc7_:Array = [];
         _loc8_ = 0;
         while(_loc8_ < param1.length)
         {
            _loc7_.push(param1[_loc8_]);
            _loc8_++;
         }
         if(param2)
         {
            _loc4_ = param2.split(",");
            _loc9_ = 0;
            _loc6_ = Math.min(_loc7_.length,_loc4_.length);
            while(_loc9_ < _loc6_)
            {
               _loc5_ = _loc4_[_loc9_];
               _loc7_[_loc9_] = _loc5_ == "true" ? true : (_loc5_ == "false" ? false : _loc5_);
               if(param3 != null)
               {
                  _loc7_[_loc9_] = param3(_loc5_);
               }
               _loc9_++;
            }
         }
         return _loc7_;
      }
      
      public static function substitute(param1:String, ... rest) : String
      {
         if(param1 == null)
         {
            return "";
         }
         var _loc3_:* = rest;
         if(rest != null && rest.length == 1 && rest[0] is Array)
         {
            _loc3_ = rest[0];
         }
         var _loc5_:int = 0;
         var _loc4_:int = int(_loc3_.length);
         while(_loc5_ < _loc4_)
         {
            param1 = param1.replace(new RegExp("\\{" + _loc5_ + "\\}","g"),_loc3_[_loc5_]);
            _loc5_++;
         }
         return param1;
      }
   }
}

