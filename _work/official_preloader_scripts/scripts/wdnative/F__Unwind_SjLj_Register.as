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
   
   public function F__Unwind_SjLj_Register() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._use_fc_key);
      if(_loc1_ <= -1)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_fc_key_init_once();
         _loc1_ = li32(wdnative_nternal._use_fc_key);
      }
      _loc7_ = li32(_loc3_);
      if(_loc1_ != 0)
      {
         _loc1_ = 0;
         _loc6_ = li32(wdnative_nternal._fc_key);
         if(_loc6_ >= 0)
         {
            var _loc5_:int = li32(wdnative_nternal._sEntryCount);
            if(_loc5_ > _loc6_)
            {
               var _temp_6:* = _loc6_ << 3;
               var _loc4_:int;
               _loc5_ = (_loc4_ = li32(wdnative_nternal._sEntries)) + _temp_6;
               _loc1_ = li32(_loc5_);
            }
         }
         si32(_loc1_,_loc7_);
         _loc1_ = li32(wdnative_nternal._fc_key);
         if(_loc1_ >= 0)
         {
            _loc5_ = li32(wdnative_nternal._sEntryCount);
            if(_loc5_ > _loc1_)
            {
               var _temp_10:* = _loc1_ << 3;
               var _temp_11:* = int((_loc4_ = li32(wdnative_nternal._sEntries)) + _temp_10);
               si32(_loc7_,_temp_11);
            }
         }
      }
      else
      {
         _loc5_ = li32(wdnative_nternal._fc_static);
         si32(_loc5_,_loc7_);
         si32(_loc7_,wdnative_nternal._fc_static);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

