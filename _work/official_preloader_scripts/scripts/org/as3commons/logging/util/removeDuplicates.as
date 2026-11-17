package org.as3commons.logging.util
{
   import flash.utils.Dictionary;
   
   public function removeDuplicates(param1:Array) : void
   {
      var _loc5_:* = undefined;
      var _loc2_:Dictionary = new Dictionary();
      var _loc3_:* = int(param1.length);
      var _loc4_:* = 0;
      while(_loc4_ < _loc3_)
      {
         _loc5_ = param1[_loc4_];
         if(_loc2_[_loc5_])
         {
            param1.splice(_loc4_,1);
            _loc4_--;
            _loc3_--;
         }
         else
         {
            _loc2_[_loc5_] = true;
         }
         _loc4_++;
      }
   }
}

