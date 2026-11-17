package wdnative_nternal
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi16;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   
   public function F___sseek() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc1_ = si16(li16(_loc1_ + 14));
      _loc2_ -= 16;
      _loc4_ = li32(_loc3_ + 12);
      si32(_loc4_,_loc2_ + 12);
      _loc4_ = li32(_loc3_ + 8);
      si32(_loc4_,_loc2_ + 8);
      _loc4_ = li32(_loc3_ + 4);
      si32(_loc4_,_loc2_ + 4);
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_lseek();
      _loc2_ += 16;
      _loc1_ = wdnative.eax;
      _loc4_ = wdnative.edx;
      wdnative.eax = _loc1_;
      wdnative.edx = _loc4_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

