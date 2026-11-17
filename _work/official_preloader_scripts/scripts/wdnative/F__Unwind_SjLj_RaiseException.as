package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F__Unwind_RaiseException_Phase2;
   import wdnative_nternal.F_fc_key_init_once;
   import wdnative_nternal.F_uw_install_context;
   import wdnative_nternal._fc_key;
   import wdnative_nternal._fc_static;
   import wdnative_nternal._sEntries;
   import wdnative_nternal._sEntryCount;
   import wdnative_nternal._use_fc_key;
   
   public function F__Unwind_SjLj_RaiseException() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc13_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
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
      _loc13_ = li32(_loc3_);
      if(_loc1_ != 0)
      {
         _loc12_ = 0;
         _loc11_ = li32(wdnative_nternal._fc_key);
         if(_loc11_ >= 0)
         {
            var _loc10_:int = li32(wdnative_nternal._sEntryCount);
            if(_loc10_ > _loc11_)
            {
               var _temp_6:* = _loc11_ << 3;
               var _loc9_:int;
               _loc10_ = (_loc9_ = li32(wdnative_nternal._sEntries)) + _temp_6;
               _loc12_ = li32(_loc10_);
            }
         }
      }
      else
      {
         _loc12_ = li32(wdnative_nternal._fc_static);
      }
      _loc8_ = _loc12_;
      while(true)
      {
         si32(_loc8_,_loc3_ - 8);
         _loc7_ = 5;
         if(_loc8_ == 0)
         {
            break;
         }
         _loc6_ = li32(_loc8_ + 24);
         if(_loc6_ != 0)
         {
            var _temp_11:* = li32(_loc13_);
            var _temp_10:* = li32(_loc13_ + 4);
            _loc2_ -= 32;
            _loc5_ = _loc3_ - 8;
            si32(_loc5_,_loc2_ + 20);
            si32(_loc13_,_loc2_ + 16);
            si32(_temp_10,_loc2_ + 12);
            si32(_temp_11,_loc2_ + 8);
            si32(1,_loc2_ + 4);
            si32(1,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.ptr2fun[_loc6_]();
            _loc2_ += 32;
            _loc4_ = wdnative.eax;
            if(_loc4_ == 6)
            {
               si32(0,_loc13_ + 12);
               _loc10_ = li32(_loc3_ - 8);
               si32(_loc10_,_loc13_ + 16);
               si32(_loc12_,_loc3_ - 8);
               _loc2_ -= 16;
               si32(_loc5_,_loc2_ + 4);
               si32(_loc13_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F__Unwind_RaiseException_Phase2();
               _loc2_ += 16;
               _loc7_ = wdnative.eax;
               if(_loc7_ == 7)
               {
                  _loc2_ -= 16;
                  si32(_loc5_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_uw_install_context();
                  _loc2_ += 16;
               }
               break;
            }
            _loc7_ = 3;
            if(_loc4_ != 8)
            {
               break;
            }
            _loc8_ = li32(_loc3_ - 8);
         }
         _loc8_ = li32(_loc8_);
      }
      wdnative.eax = _loc7_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

