package tools
{
   public class StringUtils
   {
      
      public function StringUtils()
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

