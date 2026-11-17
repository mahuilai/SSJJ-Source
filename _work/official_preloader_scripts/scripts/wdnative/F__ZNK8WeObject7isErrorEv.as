package wdnative
{
   import avm2.intrinsics.memory.li32;
   
   public function F__ZNK8WeObject7isErrorEv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc1_ = li32(_loc1_ + 4);
      _loc4_ = 1;
      if(_loc1_ != _loc4_)
      {
         _loc4_ = 0;
      }
      _loc1_ = _loc4_ & 1;
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

