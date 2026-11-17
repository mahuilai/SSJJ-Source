package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F__Unwind_ForcedUnwind_Phase2;
   import wdnative_nternal.F__Unwind_RaiseException_Phase2;
   import wdnative_nternal.F_abort;
   import wdnative_nternal.F_fc_key_init_once;
   import wdnative_nternal.F_uw_install_context;
   import wdnative_nternal._fc_key;
   import wdnative_nternal._fc_static;
   import wdnative_nternal._sEntries;
   import wdnative_nternal._sEntryCount;
   import wdnative_nternal._use_fc_key;
   
   public function F__Unwind_SjLj_Resume() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(wdnative_nternal._use_fc_key);
      if(_loc1_ <= -1)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_fc_key_init_once();
         _loc1_ = li32(wdnative_nternal._use_fc_key);
      }
      _loc9_ = li32(_loc3_);
      if(_loc1_ != 0)
      {
         _loc8_ = 0;
         _loc7_ = li32(wdnative_nternal._fc_key);
         if(_loc7_ >= 0)
         {
            var _loc6_:int = li32(wdnative_nternal._sEntryCount);
            if(_loc6_ > _loc7_)
            {
               var _temp_6:* = _loc7_ << 3;
               var _loc5_:int;
               _loc6_ = (_loc5_ = li32(wdnative_nternal._sEntries)) + _temp_6;
               _loc8_ = li32(_loc6_);
            }
         }
      }
      else
      {
         _loc8_ = li32(wdnative_nternal._fc_static);
      }
      si32(_loc8_,_loc3_ - 8);
      _loc6_ = li32(_loc9_ + 12);
      if(_loc6_ == 0)
      {
         _loc2_ -= 16;
         _loc6_ = _loc3_ - 8;
         si32(_loc6_,_loc2_ + 4);
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__Unwind_RaiseException_Phase2();
         _loc2_ += 16;
         _loc4_ = wdnative.eax;
      }
      else
      {
         _loc2_ -= 16;
         _loc6_ = _loc3_ - 8;
         si32(_loc6_,_loc2_ + 4);
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__Unwind_ForcedUnwind_Phase2();
         _loc2_ += 16;
         _loc4_ = wdnative.eax;
      }
      if(_loc4_ != 7)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_abort();
      }
      _loc2_ -= 16;
      _loc6_ = _loc3_ - 8;
      si32(_loc6_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_uw_install_context();
      _loc2_ += 16;
   }
}

