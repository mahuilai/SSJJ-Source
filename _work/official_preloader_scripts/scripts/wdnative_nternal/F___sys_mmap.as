package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F___sys_mmap() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 24);
      _loc12_ = li32(_loc3_ + 20);
      _loc11_ = li32(_loc3_ + 16);
      _loc10_ = li32(_loc3_ + 8);
      _loc9_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc3_);
      if(_loc11_ >= 0)
      {
         _loc7_ = 0;
         if(_loc11_ == 0)
         {
            _loc2_ -= 32;
            si32(_loc12_,_loc2_ + 20);
            si32(-1,_loc2_ + 16);
            si32(4096,_loc2_ + 12);
            si32(_loc10_,_loc2_ + 8);
            si32(_loc9_,_loc2_ + 4);
            si32(_loc8_,_loc2_);
            si32(_loc1_,_loc2_ + 24);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F___sys_mmap();
            _loc7_ = 0;
            _loc2_ += 32;
            _loc9_ = wdnative.eax;
            if(_loc9_ != 0)
            {
               _loc2_ -= 16;
               si32(3145728,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc7_ = _loc9_;
            }
         }
      }
      else
      {
         loop6:
         while(true)
         {
            _loc7_ = li32(_loc3_ + 12);
            if(_loc7_ != 0)
            {
               var _loc6_:int = _loc7_ & 0x1000;
               if(_loc6_ == 0)
               {
                  si32(22,wdnative_nternal._errno);
                  _loc7_ = -1;
                  break;
               }
            }
            _loc6_ = _loc10_ & 4;
            if(_loc6_ != 0)
            {
               si32(22,wdnative_nternal._errno);
               _loc7_ = -1;
               break;
            }
            _loc2_ -= 32;
            si32(_loc12_,_loc2_ + 24);
            si32(_loc11_,_loc2_ + 20);
            si32(_loc7_,_loc2_ + 16);
            si32(_loc10_,_loc2_ + 12);
            si32(_loc9_,_loc2_ + 8);
            si32(_loc8_,_loc2_ + 4);
            si32(wdnative_nternal.L__2E_str8247,_loc2_);
            si32(_loc1_,_loc2_ + 28);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_tprintf();
            _loc2_ += 32;
            _loc2_ -= 16;
            si32(_loc9_,_loc2_ + 8);
            si32(wdnative_nternal.L__2E_str9248,_loc2_ + 4);
            si32(wdnative_nternal.L__2E_str239,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_tprintf();
            _loc2_ += 16;
            var _temp_10:* = li32(wdnative_nternal._mmapBlockCount);
            _loc2_ -= 16;
            si32(_temp_10,_loc2_ + 8);
            si32(wdnative_nternal.L__2E_str10249,_loc2_ + 4);
            si32(wdnative_nternal.L__2E_str239,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_tprintf();
            _loc2_ += 16;
            _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
            if(_loc1_ == -1)
            {
               _loc1_ = int(Boolean(workerClass));
               si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
            }
            if(_loc1_ != 0)
            {
               var _temp_12:* = int(threadId);
               _loc2_ -= 16;
               _loc6_ = _temp_12 + 8;
               si32(_loc6_,_loc2_ + 4);
               si32(wdnative_nternal._smmapMtx,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_lock_id();
               _loc2_ += 16;
            }
            _loc6_ = _loc9_ + 4095;
            _loc1_ = _loc6_ >>> 12;
            _loc11_ = 0 - _loc1_;
            while(true)
            {
               _loc10_ = int(ramGetLength());
               if(_loc10_ <= -1)
               {
                  wdnative.ESP = _loc2_ & -16;
                  _loc8_ = (ramGetLength() + 4095) / 4096;
               }
               else
               {
                  _loc6_ = _loc10_ + 4095;
                  var _loc5_:int = _loc6_ >> 31;
                  var _temp_21:* = _loc5_ >>> 20;
                  _loc6_ += _temp_21;
                  _loc8_ = _loc6_ >> 12;
               }
               _loc7_ = li32(wdnative_nternal._mmapBlockCount);
               if(_loc8_ > _loc7_)
               {
                  do
                  {
                     _loc6_ = _loc7_ & 0x1F;
                     _loc6_ = 1 << _loc6_;
                     _loc5_ = _loc7_ & -32;
                     _loc5_ = _loc5_ >>> 3;
                     _loc5_ = wdnative_nternal._mmapBlockAllocBitSet + _loc5_;
                     var _loc4_:int = li32(_loc5_);
                     _loc6_ |= _loc4_;
                     si32(_loc6_,_loc5_);
                     _loc7_ += 1;
                  }
                  while(_loc8_ != _loc7_);
               }
               si32(_loc8_,wdnative_nternal._mmapBlockCount);
               _loc2_ -= 16;
               si32(_loc8_,_loc2_ + 8);
               si32(wdnative_nternal.L__2E_str11250,_loc2_ + 4);
               si32(wdnative_nternal.L__2E_str239,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_tprintf();
               _loc2_ += 16;
               _loc12_ = li32(wdnative_nternal._mmapBlockCount);
               loop2:
               while(true)
               {
                  _loc7_ = _loc12_;
                  _loc8_ = -1;
                  if(_loc7_ >= _loc1_)
                  {
                     _loc12_ = _loc11_ + _loc7_;
                     _loc8_ = _loc7_ - _loc1_;
                     while(_loc12_ < _loc7_)
                     {
                        var _temp_39:* = _loc12_ & 0x1F;
                        var _temp_44:* = 1 << _temp_39;
                        var _temp_41:* = (_loc5_ = _loc12_ & -32) >>> 3;
                        _loc5_ = wdnative_nternal._mmapBlockAllocBitSet + _temp_41;
                        _loc5_ = li32(_loc5_);
                        _loc6_ = _loc5_ & _temp_44;
                        if(_loc6_ == 0)
                        {
                           _loc12_ += 1;
                           continue;
                        }
                        continue loop2;
                     }
                     if(_loc8_ >= 0)
                     {
                        _loc12_ = _loc11_;
                        if(_loc1_ != 0)
                        {
                           do
                           {
                              _loc5_ = _loc7_ + _loc12_;
                              _loc6_ = _loc5_ & 0x1F;
                              _loc6_ = 1 << _loc6_;
                              _loc5_ &= -32;
                              _loc5_ = _loc5_ >>> 3;
                              _loc5_ = wdnative_nternal._mmapBlockAllocBitSet + _loc5_;
                              _loc4_ = li32(_loc5_);
                              _loc6_ |= _loc4_;
                              si32(_loc6_,_loc5_);
                           }
                           while(_loc12_ += 1, _loc12_ != 0);
                        }
                     }
                  }
                  break;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_ + 8);
               si32(wdnative_nternal.L__2E_str12251,_loc2_ + 4);
               si32(wdnative_nternal.L__2E_str239,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_tprintf();
               _loc2_ += 16;
               _loc2_ -= 16;
               si32(_loc8_,_loc2_ + 8);
               si32(wdnative_nternal.L__2E_str13252,_loc2_ + 4);
               si32(wdnative_nternal.L__2E_str239,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_tprintf();
               _loc2_ += 16;
               if(_loc8_ <= -1)
               {
                  _loc8_ = li32(wdnative_nternal._mmapBlockCount);
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_);
                  _loc7_ = _loc8_ + _loc1_;
                  _loc6_ = _loc7_ << 12;
                  si32(_loc6_,_loc2_ + 4);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_avm2_casRamLength();
                  _loc2_ += 16;
                  _loc12_ = wdnative.eax;
                  if(_loc12_ == -1)
                  {
                     _loc2_ -= 16;
                     si32(wdnative_nternal.L__2E_str14253,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_tprintf();
                     _loc2_ += 16;
                     _loc9_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
                     if(_loc9_ == -1)
                     {
                        _loc9_ = int(Boolean(workerClass));
                        si32(_loc9_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                     }
                     if(_loc9_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(wdnative_nternal._smmapMtx,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_avm2_unlock();
                        _loc2_ += 16;
                     }
                     si32(12,wdnative_nternal._errno);
                     _loc7_ = -1;
                     break loop6;
                  }
                  _loc2_ -= 16;
                  si32(_loc12_,_loc2_ + 4);
                  si32(wdnative_nternal.L__2E_str15254,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_tprintf();
                  _loc2_ += 16;
                  if(_loc12_ != _loc10_)
                  {
                     continue;
                  }
                  if(_loc1_ != 0)
                  {
                     _loc10_ = li32(wdnative_nternal._mmapBlockCount);
                     do
                     {
                        _loc6_ = _loc10_ & 0x1F;
                        _loc6_ = 1 << _loc6_;
                        _loc5_ = _loc10_ & -32;
                        _loc5_ = _loc5_ >>> 3;
                        _loc5_ = wdnative_nternal._mmapBlockAllocBitSet + _loc5_;
                        _loc4_ = li32(_loc5_);
                        _loc6_ |= _loc4_;
                        si32(_loc6_,_loc5_);
                        _loc10_ += 1;
                        _loc1_ += -1;
                     }
                     while(_loc1_ != 0);
                  }
                  si32(_loc7_,wdnative_nternal._mmapBlockCount);
                  _loc6_ = int(ramGetLength());
                  _loc2_ -= 16;
                  si32(_loc6_,_loc2_ + 8);
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
               if(_loc1_ != 0)
               {
                  _loc2_ -= 16;
                  si32(wdnative_nternal._smmapMtx,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_avm2_unlock();
                  _loc2_ += 16;
               }
               _loc7_ = _loc8_ << 12;
               _loc2_ -= 16;
               si32(_loc9_,_loc2_ + 8);
               si32(0,_loc2_ + 4);
               si32(_loc7_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.Fmemset();
               _loc2_ += 16;
               break loop6;
               _loc2_ -= 16;
               si32(_loc10_,_loc2_ + 8);
               si32(_loc12_,_loc2_ + 4);
               si32(wdnative_nternal.L__2E_str16255,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_tprintf();
               _loc2_ += 16;
            }
            break;
         }
      }
      wdnative.eax = _loc7_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

