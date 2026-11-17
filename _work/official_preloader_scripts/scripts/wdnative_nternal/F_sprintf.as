package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.Fmemset;
   
   public function F_sprintf() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 240;
      _loc1_ = _loc3_ + 4;
      si32(_loc1_,_loc3_ - 236);
      _loc2_ -= 16;
      si32(232,_loc2_ + 8);
      si32(0,_loc2_ + 4);
      _loc5_ = _loc3_ - 232;
      si32(_loc5_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.Fmemset();
      _loc2_ += 16;
      si16(-1,_loc3_ - 218);
      si16(520,_loc3_ - 220);
      _loc4_ = li32(_loc3_);
      si32(_loc4_,_loc3_ - 232);
      si32(_loc4_,_loc3_ - 216);
      si32(2147483647,_loc3_ - 224);
      si32(2147483647,_loc3_ - 212);
      _loc2_ -= 16;
      si32(_loc1_,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str516,_loc2_ + 4);
      si32(_loc5_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___vfprintf();
      _loc2_ += 16;
      _loc1_ = li32(_loc3_ - 232);
      si8(0,_loc1_);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

