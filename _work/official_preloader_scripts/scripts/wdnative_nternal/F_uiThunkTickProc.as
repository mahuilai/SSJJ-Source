package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F_uiThunkTickProc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc16_:int = 0;
      var _loc10_:Number = NaN;
      var _loc11_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      si32(wdnative_nternal._sEnterFrame,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_avm2_wake();
      _loc2_ += 16;
      _loc1_ = wdnative.eax;
      _loc16_ = li32(wdnative_nternal._sOldUiTickProc);
      if(_loc16_ != 0)
      {
         wdnative.ESP = _loc2_;
         wdnative.ptr2fun[_loc16_]();
      }
      var _loc12_:Number = new Date().time;
      _loc10_ = _loc12_ + 5000;
      while(true)
      {
         _loc12_ = new Date().time;
         if(_loc12_ >= _loc10_)
         {
            break;
         }
         var _temp_8:* = int(threadId);
         _loc2_ -= 16;
         var _loc15_:int = _temp_8 + 8;
         si32(_loc15_,_loc2_ + 4);
         si32(wdnative_nternal._sThunkTickLock,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_lock_id();
         _loc2_ += 16;
         _loc14_ = li32(wdnative_nternal._sThunkTickHead);
         _loc13_ = 0;
         si32(_loc13_,wdnative_nternal._sThunkTickHead);
         _loc2_ -= 16;
         si32(wdnative_nternal._sThunkTickLock,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_unlock();
         _loc2_ += 16;
         if(_loc14_ == 0)
         {
            if(_loc1_ == 0)
            {
               break;
            }
            var _temp_12:* = int(threadId);
            _loc2_ -= 16;
            _loc15_ = _temp_12 + 8;
            si32(_loc15_,_loc2_ + 4);
            si32(wdnative_nternal._sThunkTickLock,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_lock_id();
            _loc2_ += 16;
            _loc15_ = li32(wdnative_nternal._sThunkTickHead);
            if(_loc15_ == 0)
            {
               _loc2_ -= 16;
               si32(1,_loc2_ + 8);
               si32(wdnative_nternal._sThunkTickLock,_loc2_ + 4);
               si32(wdnative_nternal._sThunkTickHead,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_msleep();
               _loc2_ += 16;
            }
            _loc2_ -= 16;
            si32(wdnative_nternal._sThunkTickLock,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_unlock();
            _loc2_ += 16;
            _loc1_ = 0;
         }
         else
         {
            do
            {
               _loc11_ = _loc14_;
               _loc9_ = _loc13_;
               _loc14_ = li32(_loc11_ + 20);
               si32(_loc9_,_loc11_ + 20);
               _loc13_ = _loc11_;
            }
            while(_loc14_ != 0);
            var _temp_22:* = li32(_loc11_ + 8);
            var _temp_21:* = li32(_loc11_ + 12);
            var _temp_20:* = li32(_loc11_);
            var _temp_19:* = li32(_loc11_ + 4);
            _loc2_ -= 32;
            var _loc4_:int = _loc11_ + 16;
            si32(_loc4_,_loc2_ + 16);
            si32(_temp_19,_loc2_ + 12);
            si32(_temp_20,_loc2_ + 8);
            si32(_temp_21,_loc2_ + 4);
            si32(_temp_22,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_thrImpersonate();
            _loc2_ += 32;
            _loc15_ = wdnative.eax;
            si32(_loc15_,_loc11_ + 4);
            _loc2_ -= 16;
            si32(_loc11_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_wake_one();
            _loc2_ += 16;
            _loc1_ = 1;
            if(_loc9_ != 0)
            {
               do
               {
                  var _loc5_:int = li32(_loc9_ + 20);
                  var _loc8_:int = li32(_loc9_ + 8);
                  var _loc7_:int = li32(_loc9_ + 12);
                  var _loc6_:int = li32(_loc9_);
                  _loc4_ = li32(_loc9_ + 4);
                  _loc2_ -= 32;
                  _loc15_ = _loc9_ + 16;
                  si32(_loc15_,_loc2_ + 16);
                  si32(_loc4_,_loc2_ + 12);
                  si32(_loc6_,_loc2_ + 8);
                  si32(_loc7_,_loc2_ + 4);
                  si32(_loc8_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_thrImpersonate();
                  _loc2_ += 32;
                  _loc15_ = wdnative.eax;
                  si32(_loc15_,_loc9_ + 4);
                  _loc2_ -= 16;
                  si32(_loc9_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_avm2_wake_one();
                  _loc2_ += 16;
                  _loc1_ = 1;
                  _loc9_ = _loc5_;
               }
               while(_loc5_ != 0);
            }
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

