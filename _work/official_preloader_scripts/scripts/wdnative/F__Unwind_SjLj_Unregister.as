package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F_fc_key_init_once;
   import wdnative_nternal._fc_key;
   import wdnative_nternal._fc_static;
   import wdnative_nternal._sEntries;
   import wdnative_nternal._sEntryCount;
   import wdnative_nternal._use_fc_key;
   
   public function F__Unwind_SjLj_Unregister() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc6_ = li32(_loc1_);
      _loc5_ = li32(wdnative_nternal._use_fc_key);
      if(_loc5_ <= -1)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_fc_key_init_once();
         _loc5_ = li32(wdnative_nternal._use_fc_key);
      }
      if(_loc5_ != 0)
      {
         _loc5_ = li32(wdnative_nternal._fc_key);
         if(_loc5_ >= 0)
         {
            if(li32(wdnative_nternal._sEntryCount) > _loc5_)
            {
               var _temp_6:* = _loc5_ << 3;
               var _loc4_:int;
               var _temp_7:* = int((_loc4_ = li32(wdnative_nternal._sEntries)) + _temp_6);
               si32(_loc6_,_temp_7);
            }
         }
      }
      else
      {
         si32(_loc6_,wdnative_nternal._fc_static);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

