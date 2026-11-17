package wdnative
{
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F_idalloc;
   
   public function _wrap_delete_WeSceDiffuse(param1:*) : void
   {
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc4_ = _loc3_;
      _loc2_ = param1;
      if(_loc2_ != 0)
      {
         _loc3_ -= 16;
         si32(_loc2_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F_idalloc();
         _loc3_ += 16;
      }
      var _loc5_:* = undefined;
      _loc3_ = _loc4_;
      wdnative.ESP = _loc3_;
      return _loc5_;
   }
}

