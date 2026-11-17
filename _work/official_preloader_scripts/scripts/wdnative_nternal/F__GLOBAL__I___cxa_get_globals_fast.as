package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__GLOBAL__I___cxa_get_globals_fast() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      si8(0,wdnative_nternal.__ZL4init + 4);
      _loc1_ = li32(wdnative_nternal._sFirstFree);
      if(_loc1_ <= -1)
      {
         _loc1_ = li32(wdnative_nternal._sEntryCount);
         var _temp_2:* = int(_loc1_ + 1);
         var _loc5_:int = li32(wdnative_nternal._sEntries);
         si32(_temp_2,wdnative_nternal._sEntryCount);
         _loc2_ -= 16;
         var _loc6_:int = _temp_2 << 3;
         si32(_loc6_,_loc2_ + 4);
         si32(_loc5_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_realloc();
         _loc2_ += 16;
         _loc4_ = wdnative.eax;
         si32(_loc4_,wdnative_nternal._sEntries);
      }
      else
      {
         var _temp_7:* = _loc1_ << 3;
         _loc5_ = (_loc4_ = li32(wdnative_nternal._sEntries)) + _temp_7;
         _loc5_ = li32(_loc5_ + 4);
         si32(_loc5_,wdnative_nternal._sFirstFree);
      }
      _loc5_ = _loc1_ << 3;
      _loc5_ = _loc4_ + _loc5_;
      si32(0,_loc5_);
      si32(wdnative_nternal.__ZL15eh_globals_dtorPv,_loc5_ + 4);
      si32(_loc1_,wdnative_nternal.__ZL4init);
      si8(1,wdnative_nternal.__ZL4init + 4);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

