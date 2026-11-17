package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_fc_key_init_once() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._once_2E_2506);
      if(_loc1_ == 0)
      {
         _loc6_ = li32(wdnative_nternal._sFirstFree);
         if(_loc6_ <= -1)
         {
            _loc6_ = li32(wdnative_nternal._sEntryCount);
            var _temp_4:* = int(_loc6_ + 1);
            _loc1_ = li32(wdnative_nternal._sEntries);
            si32(_temp_4,wdnative_nternal._sEntryCount);
            _loc2_ -= 16;
            var _loc5_:int = _temp_4 << 3;
            si32(_loc5_,_loc2_ + 4);
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_realloc();
            _loc2_ += 16;
            _loc4_ = wdnative.eax;
            si32(_loc4_,wdnative_nternal._sEntries);
         }
         else
         {
            var _temp_9:* = _loc6_ << 3;
            si32(li32(int((_loc4_ = li32(wdnative_nternal._sEntries)) + _temp_9) + 4),wdnative_nternal._sFirstFree);
         }
         _loc1_ = _loc6_ << 3;
         _loc1_ = _loc4_ + _loc1_;
         si32(0,_loc1_);
         si32(0,_loc1_ + 4);
         si32(_loc6_,wdnative_nternal._fc_key);
         si32(1,wdnative_nternal._use_fc_key);
         si32(1,wdnative_nternal._once_2E_2506);
      }
      else if(li32(wdnative_nternal._use_fc_key) <= -1)
      {
         si32(0,wdnative_nternal._use_fc_key);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

