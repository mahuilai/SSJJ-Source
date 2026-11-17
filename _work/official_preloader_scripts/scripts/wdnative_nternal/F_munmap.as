package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_munmap() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
      if(_loc1_ == -1)
      {
         _loc1_ = int(Boolean(workerClass));
         si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
      }
      if(_loc1_ != 0)
      {
         var _temp_2:* = int(threadId);
         _loc2_ -= 16;
         var _loc12_:int = _temp_2 + 8;
         si32(_loc12_,_loc2_ + 4);
         si32(wdnative_nternal._smmapMtx,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_lock_id();
         _loc2_ += 16;
      }
      _loc11_ = li32(_loc3_ + 4);
      _loc10_ = li32(_loc3_);
      _loc12_ = _loc10_ + _loc11_;
      _loc12_ = _loc12_ + 4095;
      _loc9_ = _loc12_ >>> 12;
      _loc12_ = _loc10_ >> 31;
      _loc12_ = _loc12_ >>> 20;
      _loc12_ = _loc10_ + _loc12_;
      _loc8_ = _loc12_ >> 12;
      if(_loc9_ != _loc8_)
      {
         _loc1_ = _loc8_;
         do
         {
            _loc12_ = _loc1_ & 0x1F;
            _loc12_ = 1 << _loc12_;
            _loc12_ = _loc12_ ^ -1;
            var _loc7_:int = _loc1_ & -32;
            _loc7_ = _loc7_ >>> 3;
            _loc7_ = wdnative_nternal._mmapBlockAllocBitSet + _loc7_;
            var _loc6_:int = li32(_loc7_);
            _loc12_ = _loc6_ & _loc12_;
            si32(_loc12_,_loc7_);
            _loc1_ += 1;
         }
         while(_loc9_ != _loc1_);
      }
      _loc2_ -= 16;
      si32(_loc10_,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str2241,_loc2_ + 4);
      si32(wdnative_nternal.L__2E_str239,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_tprintf();
      _loc2_ += 16;
      _loc2_ -= 16;
      si32(_loc11_,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str3242,_loc2_ + 4);
      si32(wdnative_nternal.L__2E_str239,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_tprintf();
      _loc2_ += 16;
      _loc2_ -= 16;
      si32(_loc8_,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str4243,_loc2_ + 4);
      si32(wdnative_nternal.L__2E_str239,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_tprintf();
      _loc2_ += 16;
      _loc2_ -= 16;
      si32(_loc9_,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str5244,_loc2_ + 4);
      si32(wdnative_nternal.L__2E_str239,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_tprintf();
      _loc2_ += 16;
      wdnative.ESP = _loc2_ & -16;
      _loc1_ = (ramGetLength() + 4095) / 4096;
      _loc10_ = li32(wdnative_nternal._mmapBlockCount);
      if(_loc1_ > _loc10_)
      {
         do
         {
            _loc12_ = _loc10_ & 0x1F;
            _loc12_ = 1 << _loc12_;
            _loc7_ = _loc10_ & -32;
            _loc7_ = _loc7_ >>> 3;
            _loc7_ = wdnative_nternal._mmapBlockAllocBitSet + _loc7_;
            _loc6_ = li32(_loc7_);
            _loc12_ |= _loc6_;
            si32(_loc12_,_loc7_);
            _loc10_ += 1;
         }
         while(_loc1_ != _loc10_);
      }
      si32(_loc1_,wdnative_nternal._mmapBlockCount);
      _loc8_ = _loc1_ << 12;
      _loc5_ = _loc1_ + -1;
      _loc4_ = -1;
      do
      {
         _loc10_ = _loc8_;
         _loc9_ = _loc5_;
         _loc11_ = _loc4_;
         if(_loc9_ == -1)
         {
            break;
         }
         var _temp_23:* = _loc9_ & 0x1F;
         var _temp_28:* = 1 << _temp_23;
         var _temp_25:* = (_loc7_ = _loc9_ & -32) >>> 3;
         _loc7_ = wdnative_nternal._mmapBlockAllocBitSet + _temp_25;
         _loc7_ = li32(_loc7_);
         var _temp_29:* = _loc7_ & _temp_28;
         _loc8_ = _loc10_ + -4096;
         _loc5_ = _loc9_ + -1;
         _loc4_ = _loc11_ + -1;
      }
      while(_temp_29 == 0);
      while(true)
      {
         _loc12_ = _loc11_ ^ -1;
         if(_loc12_ >= 256)
         {
            _loc11_ = _loc9_ + 1;
            _loc2_ -= 16;
            si32(_loc11_,_loc2_ + 8);
            si32(wdnative_nternal.L__2E_str6245,_loc2_ + 4);
            si32(wdnative_nternal.L__2E_str239,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_tprintf();
            _loc2_ += 16;
            _loc2_ -= 16;
            si32(_loc10_,_loc2_ + 4);
            _loc1_ <<= 12;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_casRamLength();
            _loc2_ += 16;
            _loc10_ = wdnative.eax;
            if(_loc10_ == -1)
            {
               _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
               if(_loc1_ == -1)
               {
                  _loc1_ = int(Boolean(workerClass));
                  si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
               }
               if(_loc1_ != 0)
               {
                  _loc2_ -= 16;
                  si32(wdnative_nternal._smmapMtx,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_avm2_unlock();
                  _loc2_ += 16;
               }
               si32(22,wdnative_nternal._errno);
               _loc10_ = -1;
               break;
            }
            if(_loc10_ == _loc1_)
            {
               si32(_loc11_,wdnative_nternal._mmapBlockCount);
            }
            _loc12_ = int(ramGetLength());
            _loc2_ -= 16;
            si32(_loc12_,_loc2_ + 8);
            si32(wdnative_nternal.L__2E_str7246,_loc2_ + 4);
            si32(wdnative_nternal.L__2E_str239,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_tprintf();
            _loc2_ += 16;
         }
         _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
         if(_loc1_ == -1)
         {
            _loc1_ = int(Boolean(workerClass));
            si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
         }
         _loc10_ = 0;
         if(_loc1_ != 0)
         {
            _loc2_ -= 16;
            si32(wdnative_nternal._smmapMtx,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_unlock();
            _loc2_ += 16;
            _loc10_ = 0;
         }
         break;
      }
      wdnative.eax = _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

