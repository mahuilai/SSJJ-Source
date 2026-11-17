package wdnative
{
   import avm2.intrinsics.memory.*;
   
   public function _wrap_freeSceParser(param1:int) : void
   {
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc4_ = _loc3_;
      _loc2_ = param1;
      if(_loc2_ != 0)
      {
         var _loc7_:int = li32(_loc2_);
         var _loc6_:int = li32(_loc7_ + 4);
         _loc3_ -= 16;
         si32(_loc2_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative.ptr2fun[_loc6_]();
         _loc3_ += 16;
      }
      var _loc5_:* = undefined;
      _loc3_ = _loc4_;
      wdnative.ESP = _loc3_;
      return _loc5_;
   }
}

