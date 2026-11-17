package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F___sys_write;
   import wdnative_nternal.F_abort;
   import wdnative_nternal.F_arena_malloc;
   import wdnative_nternal.F_avm2_unlock;
   import wdnative_nternal.F_base_pages_alloc;
   import wdnative_nternal.F_chunk_alloc;
   import wdnative_nternal.F_extent_tree_ad_insert;
   import wdnative_nternal.F_idalloc;
   import wdnative_nternal.F_malloc_init;
   import wdnative_nternal.F_uiThreadESPInit;
   import wdnative_nternal.F_uiThreadIdRaw;
   import wdnative_nternal.L__2E_str2617;
   import wdnative_nternal.L__2E_str46661;
   import wdnative_nternal.___atexit;
   import wdnative_nternal.___atexit0_2E_2723;
   import wdnative_nternal.___progname;
   import wdnative_nternal.__fini;
   import wdnative_nternal._arena_maxclass;
   import wdnative_nternal._arenas;
   import wdnative_nternal._base_next_addr;
   import wdnative_nternal._base_nodes;
   import wdnative_nternal._base_past_addr;
   import wdnative_nternal._chunksize_mask;
   import wdnative_nternal._environ;
   import wdnative_nternal._errno;
   import wdnative_nternal._huge;
   import wdnative_nternal._opt_sysv_2E_b;
   import wdnative_nternal._opt_xmalloc_2E_b;
   import wdnative_nternal._sCounter_2E_3947;
   import wdnative_nternal._sIsThreaded_2E_b;
   import wdnative_nternal._sLock_2E_3932;
   import wdnative_nternal._tls_init;
   import wdnative_nternal._tls_init_size;
   import wdnative_nternal._tls_static_space;
   
   public function F__start1() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_ + 4);
      _loc11_ = _loc1_ << 2;
      _loc10_ = li32(_loc3_ + 8);
      _loc9_ = _loc11_ + _loc10_;
      _loc11_ = _loc9_ + 4;
      si32(_loc11_,wdnative_nternal._environ);
      if(_loc1_ >= 1)
      {
         _loc10_ = li32(_loc10_);
         if(_loc10_ != 0)
         {
            si32(_loc10_,wdnative_nternal.___progname);
            _loc8_ = 0;
            while(true)
            {
               _loc1_ = _loc10_ + _loc8_;
               _loc7_ = li8(_loc1_);
               if(_loc7_ == 0)
               {
                  break;
               }
               if(_loc7_ != 47)
               {
                  _loc8_ += 1;
               }
               else
               {
                  _loc8_ += 1;
                  si32(int(_loc10_ + _loc8_),wdnative_nternal.___progname);
               }
            }
         }
      }
      _loc6_ = _loc9_ + 8;
      do
      {
         _loc10_ = _loc6_ + 4;
         _loc1_ = li32(_loc6_ - 4);
         _loc9_ = 0;
         _loc6_ = _loc10_;
         _loc7_ = _loc9_;
         _loc8_ = _loc9_;
      }
      while(_loc1_ != 0);
      while(true)
      {
         _loc6_ = li32(_loc10_ - 4);
         if(_loc6_ <= 3)
         {
            if(_loc6_ == 0)
            {
               break;
            }
            if(_loc6_ == 3)
            {
               _loc8_ = li32(_loc10_);
            }
         }
         else if(_loc6_ != 4)
         {
            if(_loc6_ == 5)
            {
               _loc9_ = li32(_loc10_);
            }
         }
         else
         {
            _loc7_ = li32(_loc10_);
         }
         _loc10_ += 8;
      }
      if(_loc7_ == 32)
      {
         if(_loc8_ != 0)
         {
            if(_loc9_ != 0)
            {
               if(_loc9_ != 0)
               {
                  _loc10_ = _loc8_ + 16;
                  do
                  {
                     _loc1_ = li32(_loc10_ - 16);
                     if(_loc1_ == 7)
                     {
                        _loc1_ = li32(_loc10_ + 12);
                        _loc11_ = li32(_loc10_ + 4);
                        _loc11_ = _loc11_ + _loc1_;
                        si32(int(_loc11_ + -1) & int(0 - _loc1_),wdnative_nternal._tls_static_space);
                        si32(li32(_loc10_),wdnative_nternal._tls_init_size);
                        si32(li32(_loc10_ - 8),wdnative_nternal._tls_init);
                     }
                     _loc10_ += 32;
                  }
                  while(_loc9_ += -1, _loc9_ != 0);
               }
               _loc1_ = li32(wdnative_nternal._tls_static_space);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_malloc_init();
               _loc1_ += 3;
               _loc9_ = _loc1_ & -4;
               _loc1_ = wdnative.eax;
               loop12:
               while(true)
               {
                  if(_loc1_ == 0)
                  {
                     while(true)
                     {
                        _loc10_ = _loc9_ + 12;
                        if(_loc10_ == 0)
                        {
                           _loc10_ = 1;
                           if(li8(wdnative_nternal._opt_sysv_2E_b) != 0)
                           {
                              break;
                           }
                        }
                        _loc1_ = li32(wdnative_nternal._arena_maxclass);
                        if(uint(_loc1_) < uint(_loc10_))
                        {
                           _loc11_ = li32(wdnative_nternal._chunksize_mask);
                           _loc10_ = int(_loc11_ + _loc10_) & (_loc11_ ^ -1);
                           if(_loc10_ != 0)
                           {
                              _loc8_ = li32(wdnative_nternal._base_nodes);
                              if(_loc8_ != 0)
                              {
                                 si32(li32(_loc8_),wdnative_nternal._base_nodes);
                              }
                              else
                              {
                                 _loc8_ = li32(wdnative_nternal._base_next_addr);
                                 var _temp_16:* = int(_loc8_ + 64);
                                 _loc1_ = li32(wdnative_nternal._base_past_addr);
                                 if(uint(_temp_16) > uint(_loc1_))
                                 {
                                    _loc2_ -= 16;
                                    si32(64,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F_base_pages_alloc();
                                    _loc2_ += 16;
                                    if(wdnative.eax != 0)
                                    {
                                       break;
                                    }
                                    _loc8_ = li32(wdnative_nternal._base_next_addr);
                                 }
                                 _loc1_ = _loc8_ + 64;
                                 si32(_loc1_,wdnative_nternal._base_next_addr);
                                 if(_loc8_ == 0)
                                 {
                                    break;
                                 }
                              }
                              _loc2_ -= 16;
                              si32(1,_loc2_ + 4);
                              si32(_loc10_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_chunk_alloc();
                              _loc2_ += 16;
                              _loc7_ = wdnative.eax;
                              if(_loc7_ == 0)
                              {
                                 si32(li32(wdnative_nternal._base_nodes),_loc8_);
                                 si32(_loc8_,wdnative_nternal._base_nodes);
                                 break;
                              }
                              si32(_loc7_,_loc8_ + 16);
                              si32(_loc10_,_loc8_ + 20);
                              _loc2_ -= 16;
                              si32(_loc8_,_loc2_ + 4);
                              si32(wdnative_nternal._huge,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_extent_tree_ad_insert();
                              _loc2_ += 16;
                              break loop12;
                           }
                           break;
                        }
                        var _temp_21:* = li32(li32(wdnative_nternal._arenas));
                        _loc2_ -= 16;
                        si32(1,_loc2_ + 8);
                        si32(_loc10_,_loc2_ + 4);
                        si32(_temp_21,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_arena_malloc();
                        _loc2_ += 16;
                        _loc7_ = wdnative.eax;
                        if(_loc7_ == 0)
                        {
                           break;
                        }
                        break loop12;
                     }
                  }
                  _loc1_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
                  if(_loc1_ == 1)
                  {
                     _loc9_ = li32(wdnative_nternal.___progname);
                     _loc8_ = _loc9_ & -4;
                     _loc11_ = li32(_loc8_);
                     var _temp_29:* = int(_loc11_ + -16843009);
                     if(((_loc11_ = (_loc11_ &= -2139062144) ^ -2139062144) & _temp_29) != 0)
                     {
                        _loc7_ = _loc8_ + 4;
                        _loc6_ = 0;
                        while(true)
                        {
                           _loc10_ = _loc9_ + _loc6_;
                           if((uint(_loc10_)) < uint(_loc7_))
                           {
                              if(li8(_loc10_) == 0)
                              {
                                 break;
                              }
                              _loc6_ += 1;
                              continue;
                           }
                        }
                        addr04a4:
                        _loc2_ -= 16;
                        si32(_loc6_,_loc2_ + 8);
                        si32(_loc9_,_loc2_ + 4);
                        si32(2,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F___sys_write();
                        _loc2_ += 16;
                        _loc10_ = wdnative_nternal.L__2E_str46661 & -4;
                        _loc11_ = li32(_loc10_);
                        _loc1_ = _loc11_ + -16843009;
                        _loc11_ &= -2139062144;
                        _loc11_ = _loc11_ ^ -2139062144;
                        _loc1_ = _loc11_ & _loc1_;
                        _loc8_ = _loc10_ + 4;
                        _loc9_ = 0;
                        if(_loc1_ != 0)
                        {
                           do
                           {
                              _loc1_ = wdnative_nternal.L__2E_str46661 + _loc9_;
                              _loc8_ = _loc10_ + 4;
                              if(uint(_loc1_) < uint(_loc8_))
                              {
                                 continue;
                              }
                           }
                           while(_loc8_ = _loc10_ + 4, _loc7_ = wdnative_nternal.L__2E_str46661, if(uint(wdnative_nternal.L__2E_str46661) <= uint(_loc8_))
                           {
                              _loc7_ = _loc8_;
                           }, _loc1_ = _loc7_ ^ -1, _loc8_ = wdnative_nternal.L__2E_str46661 + _loc1_, if((uint(_loc8_)) <= 4294967251)
                           {
                              _loc8_ = -45;
                           }, _loc8_ ^= -1, _loc9_ += 1, _loc9_ != 45);
                           addr0628:
                           _loc2_ -= 16;
                           si32(_loc8_,_loc2_ + 8);
                           si32(wdnative_nternal.L__2E_str46661,_loc2_ + 4);
                           si32(2,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F___sys_write();
                           _loc2_ += 16;
                           _loc10_ = wdnative_nternal.L__2E_str2617 & -4;
                           _loc11_ = li32(_loc10_);
                           _loc1_ = _loc11_ + -16843009;
                           _loc11_ &= -2139062144;
                           _loc11_ = _loc11_ ^ -2139062144;
                           _loc1_ = _loc11_ & _loc1_;
                           _loc8_ = _loc10_ + 4;
                           _loc9_ = 0;
                           loop14:
                           while(true)
                           {
                              if(_loc1_ != 0)
                              {
                                 var _temp_43:* = int(_loc10_ + 4);
                                 _loc7_ = _loc9_;
                                 if(uint(wdnative_nternal.L__2E_str2617) < uint(_temp_43))
                                 {
                                    break;
                                 }
                              }
                              while(true)
                              {
                                 _loc7_ = li32(_loc8_);
                                 _loc1_ = _loc7_ + -16843009;
                                 _loc11_ = _loc7_ & -2139062144;
                                 _loc11_ = _loc11_ ^ -2139062144;
                                 _loc1_ = _loc11_ & _loc1_;
                                 if(_loc1_ != 0)
                                 {
                                    if((_loc7_ & 0xFF) == 0)
                                    {
                                       _loc7_ = _loc8_ - wdnative_nternal.L__2E_str2617;
                                       break loop14;
                                    }
                                    if(li8(_loc8_ + 1) == 0)
                                    {
                                       var _temp_47:* = int(1 - wdnative_nternal.L__2E_str2617);
                                       _loc7_ = _loc8_ + _temp_47;
                                       break loop14;
                                    }
                                    if(li8(_loc8_ + 2) == 0)
                                    {
                                       var _temp_48:* = int(2 - wdnative_nternal.L__2E_str2617);
                                       _loc7_ = _loc8_ + _temp_48;
                                       break loop14;
                                    }
                                    if(li8(_loc8_ + 3) == 0)
                                    {
                                       var _temp_49:* = int(3 - wdnative_nternal.L__2E_str2617);
                                       _loc7_ = _loc8_ + _temp_49;
                                       break loop14;
                                    }
                                 }
                                 _loc8_ += 4;
                              }
                              break;
                           }
                           _loc2_ -= 16;
                           si32(_loc7_,_loc2_ + 8);
                           si32(2,_loc2_);
                           si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F___sys_write();
                           _loc2_ += 16;
                           _loc11_ = li32(_loc10_);
                           _loc1_ = _loc11_ + -16843009;
                           _loc11_ &= -2139062144;
                           _loc11_ = _loc11_ ^ -2139062144;
                           _loc1_ = _loc11_ & _loc1_;
                           _loc8_ = _loc10_ + 4;
                           loop15:
                           while(true)
                           {
                              if(_loc1_ != 0)
                              {
                                 var _temp_54:* = int(_loc10_ + 4);
                                 if(uint(wdnative_nternal.L__2E_str2617) < uint(_temp_54))
                                 {
                                    break;
                                 }
                              }
                              while(true)
                              {
                                 _loc9_ = li32(_loc8_);
                                 _loc1_ = _loc9_ + -16843009;
                                 _loc11_ = _loc9_ & -2139062144;
                                 _loc11_ = _loc11_ ^ -2139062144;
                                 _loc1_ = _loc11_ & _loc1_;
                                 if(_loc1_ != 0)
                                 {
                                    if((_loc9_ & 0xFF) == 0)
                                    {
                                       _loc9_ = _loc8_ - wdnative_nternal.L__2E_str2617;
                                       break loop15;
                                    }
                                    if(li8(_loc8_ + 1) == 0)
                                    {
                                       var _temp_58:* = int(1 - wdnative_nternal.L__2E_str2617);
                                       _loc9_ = _loc8_ + _temp_58;
                                       break loop15;
                                    }
                                    if(li8(_loc8_ + 2) == 0)
                                    {
                                       var _temp_59:* = int(2 - wdnative_nternal.L__2E_str2617);
                                       _loc9_ = _loc8_ + _temp_59;
                                       break loop15;
                                    }
                                    if(li8(_loc8_ + 3) == 0)
                                    {
                                       var _temp_60:* = int(3 - wdnative_nternal.L__2E_str2617);
                                       _loc9_ = _loc8_ + _temp_60;
                                       break loop15;
                                    }
                                 }
                                 _loc8_ += 4;
                              }
                              break;
                           }
                           _loc2_ -= 16;
                           si32(_loc9_,_loc2_ + 8);
                           si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                           si32(2,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F___sys_write();
                           _loc2_ += 16;
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_abort();
                           addr08af:
                           si32(12,wdnative_nternal._errno);
                           _loc7_ = 0;
                           break;
                        }
                        while(true)
                        {
                           _loc9_ = li32(_loc8_);
                           _loc1_ = _loc9_ + -16843009;
                           _loc11_ = _loc9_ & -2139062144;
                           _loc11_ = _loc11_ ^ -2139062144;
                           _loc1_ = _loc11_ & _loc1_;
                           if(_loc1_ != 0)
                           {
                              if((_loc9_ & 0xFF) == 0)
                              {
                                 _loc8_ -= wdnative_nternal.L__2E_str46661;
                                 break;
                              }
                              if(li8(_loc8_ + 1) == 0)
                              {
                                 var _temp_66:* = int(1 - wdnative_nternal.L__2E_str46661);
                                 _loc8_ += _temp_66;
                                 break;
                              }
                              if(li8(_loc8_ + 2) == 0)
                              {
                                 var _temp_67:* = int(2 - wdnative_nternal.L__2E_str46661);
                                 _loc8_ += _temp_67;
                                 break;
                              }
                              if(li8(_loc8_ + 3) == 0)
                              {
                                 var _temp_68:* = int(3 - wdnative_nternal.L__2E_str46661);
                                 _loc8_ += _temp_68;
                                 break;
                              }
                           }
                           _loc8_ += 4;
                        }
                        §§goto(addr0628);
                     }
                     _loc10_ = _loc8_ + 4;
                     while(true)
                     {
                        _loc8_ = li32(_loc10_);
                        _loc1_ = _loc8_ + -16843009;
                        _loc11_ = _loc8_ & -2139062144;
                        _loc11_ = _loc11_ ^ -2139062144;
                        _loc1_ = _loc11_ & _loc1_;
                        if(_loc1_ != 0)
                        {
                           if((_loc8_ & 0xFF) == 0)
                           {
                              _loc6_ = _loc10_ - _loc9_;
                              break;
                           }
                           if(li8(_loc10_ + 1) == 0)
                           {
                              _loc6_ = int(1 - _loc9_) + _loc10_;
                              break;
                           }
                           if(li8(_loc10_ + 2) == 0)
                           {
                              _loc6_ = int(2 - _loc9_) + _loc10_;
                              break;
                           }
                           if(li8(_loc10_ + 3) == 0)
                           {
                              _loc6_ = int(3 - _loc9_) + _loc10_;
                              break;
                           }
                        }
                        _loc10_ += 4;
                     }
                     §§goto(addr04a4);
                  }
                  §§goto(addr08af);
               }
               _loc2_ -= 16;
               si32(12,_loc2_);
               _loc1_ = _loc7_ + _loc9_;
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               var _loc5_:int = wdnative.eax;
               si32(_loc1_,_loc1_);
               si32(_loc5_,_loc1_ + 4);
               si32(1,_loc5_);
               si32(1,_loc5_ + 4);
               _loc11_ = li32(wdnative_nternal._tls_static_space);
               _loc11_ = _loc1_ - _loc11_;
               si32(_loc11_,_loc5_ + 8);
               _loc5_ = li32(wdnative_nternal._tls_init);
               var _loc4_:int = li32(wdnative_nternal._tls_init_size);
               _loc2_ -= 16;
               si32(_loc4_,_loc2_ + 8);
               si32(_loc5_,_loc2_ + 4);
               si32(_loc11_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.Fmemcpy();
               _loc2_ += 16;
               _loc11_ = li32(wdnative_nternal._tls_init_size);
               _loc4_ = li32(wdnative_nternal._tls_static_space);
               _loc5_ = _loc4_ - _loc11_;
               _loc2_ -= 16;
               si32(_loc5_,_loc2_ + 8);
               si32(0,_loc2_ + 4);
               _loc1_ -= _loc4_;
               _loc1_ += _loc11_;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.Fmemset();
               _loc2_ += 16;
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_abort();
            }
         }
      }
      _loc9_ = li32(wdnative_nternal.___atexit);
      if(_loc9_ == 0)
      {
         _loc9_ = wdnative_nternal.___atexit0_2E_2723;
         si32(_loc9_,wdnative_nternal.___atexit);
         _loc10_ = li32(wdnative_nternal.___atexit0_2E_2723 + 4);
      }
      else
      {
         while(true)
         {
            _loc10_ = li32(_loc9_ + 4);
            if(_loc10_ > 31)
            {
               _loc2_ -= 16;
               si32(520,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc8_ = wdnative.eax;
               if(_loc8_ == 0)
               {
                  break;
               }
               _loc10_ = li32(wdnative_nternal.___atexit);
               if(_loc9_ != _loc10_)
               {
                  _loc2_ -= 16;
                  si32(_loc8_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_idalloc();
                  _loc2_ += 16;
                  _loc9_ = li32(wdnative_nternal.___atexit);
               }
               else
               {
                  si32(0,_loc8_ + 4);
                  si32(_loc10_,_loc8_);
                  si32(_loc8_,wdnative_nternal.___atexit);
                  _loc9_ = _loc8_;
               }
               continue;
            }
         }
         §§goto(addr0a93);
      }
      _loc1_ = _loc10_ << 4;
      _loc1_ = _loc9_ + _loc1_;
      si32(1,_loc1_ + 8);
      si32(wdnative_nternal.__fini,_loc1_ + 12);
      si32(0,_loc1_ + 16);
      si32(0,_loc1_ + 20);
      _loc1_ = _loc10_ + 1;
      si32(_loc1_,_loc9_ + 4);
      addr0a93:
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_uiThreadIdRaw();
      _loc1_ = wdnative.eax;
      if(_loc1_ >= 0)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         if(wdnative.eax != int(realThreadId))
         {
            _loc2_ -= 16;
            si32(int(_loc3_ - 4),_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_uiThreadESPInit();
            _loc2_ += 16;
            _loc10_ = 0;
            si32(_loc10_,_loc3_ - 8);
            _loc9_ = int(workerClass.current.getSharedProperty("flascc.uiThread.tcbpp"));
            si32(-1,_loc9_);
            if(li8(wdnative_nternal._sIsThreaded_2E_b) == 1)
            {
               threadArbMutexLock();
               _loc10_ = 0;
               if(li8(wdnative_nternal._sIsThreaded_2E_b) == 1)
               {
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  threadArbCondsNotify(-1);
                  _loc10_ = li8(wdnative_nternal._sIsThreaded_2E_b);
               }
            }
            _loc1_ = li32(_loc9_);
            if(_loc1_ != 0)
            {
               do
               {
                  _loc8_ = 0;
                  if(_loc10_ != 0)
                  {
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                     _loc10_ = int(threadArbCondWait(1));
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                     _loc8_ = li8(wdnative_nternal._sIsThreaded_2E_b);
                  }
                  _loc1_ = li32(_loc9_);
                  _loc10_ = _loc8_;
               }
               while(_loc1_ != 0);
            }
            _loc1_ = _loc10_ & 1;
            if(_loc1_ != 0)
            {
               threadArbMutexUnlock();
            }
         }
      }
      wdnative.ESP = _loc2_ & -16;
      CModule.runCtors();
      _loc9_ = wdnative_nternal._sLock_2E_3932;
      _loc10_ = tcbp;
      if(_loc10_ != -1)
      {
         _loc9_ = _loc10_ + 16;
      }
      _loc10_ = li32(wdnative_nternal._sLock_2E_3932);
      if(_loc10_ == -1)
      {
         _loc10_ = int(realThreadId) + 1;
         si32(_loc10_,wdnative_nternal._sLock_2E_3932);
      }
      if(_loc10_ != 0)
      {
         if(_loc9_ != wdnative_nternal._sLock_2E_3932)
         {
            si32(_loc10_,_loc9_);
            si32(0,wdnative_nternal._sLock_2E_3932);
         }
      }
      _loc10_ = tcbp;
      if(_loc10_ == -1)
      {
         _loc10_ = li32(wdnative_nternal._sCounter_2E_3947);
         _loc10_ = wdnative_nternal._sCounter_2E_3947;
      }
      else
      {
         _loc10_ += 20;
         if(li32(wdnative_nternal._sCounter_2E_3947) != 0)
         {
            if(_loc10_ != wdnative_nternal._sCounter_2E_3947)
            {
               si32(li32(wdnative_nternal._sCounter_2E_3947),_loc10_);
               si32(0,wdnative_nternal._sCounter_2E_3947);
            }
         }
      }
      _loc1_ = li32(_loc10_);
      _loc1_ += -1;
      si32(_loc1_,_loc10_);
      if(_loc1_ == 0)
      {
         _loc2_ -= 16;
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_unlock();
         _loc2_ += 16;
      }
      throw new GoingAsync();
   }
}

