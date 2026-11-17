package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__ZNKSt11logic_error4whatEv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc1_ = li32(_loc1_ + 4);
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

