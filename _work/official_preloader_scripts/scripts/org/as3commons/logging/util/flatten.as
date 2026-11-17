package org.as3commons.logging.util
{
   public function flatten(param1:Array) : void
   {
      var _loc3_:* = undefined;
      var _loc4_:Array = null;
      var _loc2_:* = int(param1.length - 1);
      while(_loc2_ >= 0)
      {
         _loc3_ = param1[_loc2_];
         if(_loc3_ is Array)
         {
            _loc4_ = _loc3_ as Array;
            org.as3commons.logging.util.flatten(_loc4_);
            _loc4_.unshift(1);
            _loc4_.unshift(_loc2_);
            param1.splice.apply(null,_loc4_);
         }
         _loc2_--;
      }
   }
}

