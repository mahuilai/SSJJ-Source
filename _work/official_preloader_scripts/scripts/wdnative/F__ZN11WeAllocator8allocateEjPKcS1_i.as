package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___sys_write;
   import wdnative_nternal.F_abort;
   import wdnative_nternal.F_arena_malloc;
   import wdnative_nternal.F_arena_run_alloc;
   import wdnative_nternal.F_arena_run_dalloc;
   import wdnative_nternal.F_base_pages_alloc;
   import wdnative_nternal.F_chunk_alloc;
   import wdnative_nternal.F_chunk_dealloc;
   import wdnative_nternal.F_extent_tree_ad_insert;
   import wdnative_nternal.F_malloc_init;
   import wdnative_nternal.L__2E_str2617;
   import wdnative_nternal.L__2E_str48663;
   import wdnative_nternal.___progname;
   import wdnative_nternal._arena_maxclass;
   import wdnative_nternal._arenas;
   import wdnative_nternal._base_next_addr;
   import wdnative_nternal._base_nodes;
   import wdnative_nternal._base_past_addr;
   import wdnative_nternal._chunksize;
   import wdnative_nternal._chunksize_mask;
   import wdnative_nternal._huge;
   import wdnative_nternal._opt_junk_2E_b;
   import wdnative_nternal._opt_sysv_2E_b;
   import wdnative_nternal._opt_xmalloc_2E_b;
   import wdnative_nternal._opt_zero_2E_b;
   
   public function F__ZN11WeAllocator8allocateEjPKcS1_i() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_malloc_init();
      _loc1_ = wdnative.eax;
      loop6:
      while(true)
      {
         loop7:
         while(true)
         {
            if(_loc1_ == 0)
            {
               _loc14_ = li32(_loc3_);
               if(_loc14_ == 0)
               {
                  _loc14_ = 1;
                  if(li8(wdnative_nternal._opt_sysv_2E_b) != 0)
                  {
                     break;
                  }
               }
               _loc1_ = _loc14_ + 15;
               _loc13_ = _loc1_ & -16;
               if((uint(_loc13_)) >= uint(_loc14_))
               {
                  while(true)
                  {
                     if(uint(_loc13_) >= 4097)
                     {
                        _loc12_ = li32(wdnative_nternal._arena_maxclass);
                        if(uint(_loc13_) > uint(_loc12_))
                        {
                           _loc11_ = _loc14_ + 4095;
                           _loc13_ = _loc11_ & -4096;
                           if((uint(_loc13_)) >= uint(_loc14_))
                           {
                              if(_loc13_ != -4096)
                              {
                                 _loc14_ = 4096;
                                 if(uint(_loc13_) >= uint(_loc14_))
                                 {
                                    _loc14_ = _loc13_;
                                 }
                                 if(uint(_loc14_) <= uint(_loc12_))
                                 {
                                    _loc10_ = li32(li32(wdnative_nternal._arenas));
                                    _loc2_ -= 16;
                                    si32(0,_loc2_ + 12);
                                    si32(1,_loc2_ + 8);
                                    si32(_loc14_,_loc2_ + 4);
                                    si32(_loc10_,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F_arena_run_alloc();
                                    _loc2_ += 16;
                                    _loc12_ = wdnative.eax;
                                    if(_loc12_ != 0)
                                    {
                                       var _temp_11:* = li32(wdnative_nternal._chunksize_mask) ^ -1;
                                       _loc9_ = _loc12_ & _temp_11;
                                       _loc8_ = _loc12_ & 0x0FFF;
                                       if(_loc8_ == 0)
                                       {
                                          var _loc7_:int = int(_loc12_ - _loc9_) >>> 12;
                                          var _temp_14:* = int(_loc7_ * 12);
                                          _loc1_ = _loc9_ + 16;
                                          var _temp_16:* = int(_loc1_ + _temp_14);
                                          var _loc6_:int;
                                          si32(_loc6_ = _loc13_ | 3,_temp_16 + 8);
                                          var _temp_17:* = _loc11_ >>> 12;
                                          _loc7_ += _temp_17;
                                          var _temp_19:* = int(_loc7_ * 12);
                                          var _temp_22:* = int(_loc1_ + _temp_19);
                                          si32(_loc7_ = (_loc7_ = _loc14_ - _loc13_) | 3,_temp_22 + 8);
                                          _loc2_ -= 16;
                                          si32(0,_loc2_ + 8);
                                          si32(int(_loc12_ + _loc13_),_loc2_ + 4);
                                          si32(_loc10_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_arena_run_dalloc();
                                          _loc2_ += 16;
                                       }
                                       else
                                       {
                                          _loc7_ = int(_loc12_ - _loc9_) >>> 12;
                                          var _temp_26:* = int(_loc7_ * 12);
                                          var _temp_28:* = int((_loc5_ = _loc9_ + 16) + _temp_26);
                                          _loc1_ = 4096 - _loc8_;
                                          var _loc4_:int = _loc1_ | 3;
                                          si32(_loc4_,_temp_28 + 8);
                                          var _temp_29:* = _loc1_ >>> 12;
                                          _loc7_ += _temp_29;
                                          var _temp_31:* = int(_loc7_ * 12);
                                          var _temp_34:* = int(_loc5_ + _temp_31);
                                          si32(_loc7_ = (_loc14_ -= _loc1_) | 3,_temp_34 + 8);
                                          _loc2_ -= 16;
                                          si32(0,_loc2_ + 8);
                                          si32(_loc12_,_loc2_ + 4);
                                          si32(_loc10_,_loc2_);
                                          _loc12_ = _loc1_ + _loc12_;
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_arena_run_dalloc();
                                          _loc2_ += 16;
                                          if(_loc14_ != _loc13_)
                                          {
                                             var _temp_36:* = int(_loc12_ - _loc9_) >>> 12;
                                             var _temp_37:* = int(_temp_36 * 12);
                                             var _temp_39:* = int(_loc5_ + _temp_37);
                                             si32(_loc7_ = _loc13_ | 3,_temp_39 + 8);
                                             var _temp_40:* = int((int(_temp_36 + (_loc11_ >>> 12))) * 12);
                                             var _temp_43:* = int(_loc5_ + _temp_40);
                                             si32(_loc7_ = (_loc7_ = _loc14_ - _loc13_) | 3,_temp_43 + 8);
                                             _loc2_ -= 16;
                                             si32(0,_loc2_ + 8);
                                             si32(int(_loc12_ + _loc13_),_loc2_ + 4);
                                             si32(_loc10_,_loc2_);
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_arena_run_dalloc();
                                             _loc2_ += 16;
                                          }
                                       }
                                       _loc1_ = li8(wdnative_nternal._opt_junk_2E_b);
                                       if(_loc1_ == 1)
                                       {
                                          _loc2_ -= 16;
                                          si32(_loc13_,_loc2_ + 8);
                                          si32(165,_loc2_ + 4);
                                          si32(_loc12_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative.Fmemset();
                                          _loc2_ += 16;
                                          break;
                                       }
                                       if(li8(wdnative_nternal._opt_zero_2E_b) == 1)
                                       {
                                          _loc2_ -= 16;
                                          si32(_loc13_,_loc2_ + 8);
                                          si32(0,_loc2_ + 4);
                                          si32(_loc12_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative.Fmemset();
                                          _loc2_ += 16;
                                       }
                                       break;
                                    }
                                 }
                                 else
                                 {
                                    _loc7_ = li32(wdnative_nternal._chunksize_mask);
                                    _loc11_ = int(_loc7_ + _loc13_) & (_loc7_ ^ -1);
                                    _loc14_ = li32(wdnative_nternal._chunksize);
                                    if((uint(_loc14_)) >= 4096)
                                    {
                                       if(_loc11_ != 0)
                                       {
                                          _loc13_ = li32(wdnative_nternal._base_nodes);
                                          if(_loc13_ != 0)
                                          {
                                             si32(li32(_loc13_),wdnative_nternal._base_nodes);
                                             addr0443:
                                             _loc2_ -= 16;
                                             si32(0,_loc2_ + 4);
                                             si32(_loc11_,_loc2_);
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_chunk_alloc();
                                             _loc2_ += 16;
                                             _loc12_ = wdnative.eax;
                                             if(_loc12_ != 0)
                                             {
                                                si32(_loc12_,_loc13_ + 16);
                                                si32(_loc11_,_loc13_ + 20);
                                                _loc2_ -= 16;
                                                si32(_loc13_,_loc2_ + 4);
                                                si32(wdnative_nternal._huge,_loc2_);
                                                wdnative.ESP = _loc2_;
                                                wdnative_nternal.F_extent_tree_ad_insert();
                                                _loc2_ += 16;
                                                if(li8(wdnative_nternal._opt_junk_2E_b) == 1)
                                                {
                                                   _loc2_ -= 16;
                                                   si32(_loc11_,_loc2_ + 8);
                                                   si32(165,_loc2_ + 4);
                                                   si32(_loc12_,_loc2_);
                                                   wdnative.ESP = _loc2_;
                                                   wdnative.Fmemset();
                                                   _loc2_ += 16;
                                                   break loop6;
                                                }
                                                if(li8(wdnative_nternal._opt_zero_2E_b) == 1)
                                                {
                                                   _loc2_ -= 16;
                                                   si32(_loc11_,_loc2_ + 8);
                                                   si32(0,_loc2_ + 4);
                                                   si32(_loc12_,_loc2_);
                                                   wdnative.ESP = _loc2_;
                                                   wdnative.Fmemset();
                                                   _loc2_ += 16;
                                                }
                                                break;
                                             }
                                             si32(li32(wdnative_nternal._base_nodes),_loc13_);
                                             si32(_loc13_,wdnative_nternal._base_nodes);
                                          }
                                          else
                                          {
                                             _loc13_ = li32(wdnative_nternal._base_next_addr);
                                             var _temp_56:* = int(_loc13_ + 64);
                                             _loc7_ = li32(wdnative_nternal._base_past_addr);
                                             while(true)
                                             {
                                                if(uint(_temp_56) > uint(_loc7_))
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
                                                   _loc13_ = li32(wdnative_nternal._base_next_addr);
                                                }
                                                _loc1_ = _loc13_ + 64;
                                                si32(_loc1_,wdnative_nternal._base_next_addr);
                                                if(_loc13_ == 0)
                                                {
                                                   break;
                                                }
                                                §§goto(addr0443);
                                             }
                                          }
                                       }
                                    }
                                    else
                                    {
                                       _loc12_ = 8192;
                                       if(uint(_loc13_) >= 4096)
                                       {
                                          _loc12_ = _loc11_ + 4096;
                                       }
                                       _loc9_ = _loc12_ - _loc14_;
                                       _loc14_ = li32(wdnative_nternal._base_nodes);
                                       if(_loc14_ != 0)
                                       {
                                          si32(li32(_loc14_),wdnative_nternal._base_nodes);
                                          addr05d6:
                                          _loc2_ -= 16;
                                          si32(0,_loc2_ + 4);
                                          si32(_loc9_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_chunk_alloc();
                                          _loc2_ += 16;
                                          _loc12_ = wdnative.eax;
                                          if(_loc12_ != 0)
                                          {
                                             _loc13_ = _loc12_ & 0x0FFF;
                                             if(_loc13_ == 0)
                                             {
                                                var _temp_62:* = int(_loc9_ - _loc11_);
                                                _loc2_ -= 16;
                                                si32(_temp_62,_loc2_ + 4);
                                                si32(int(_loc12_ + _loc11_),_loc2_);
                                                wdnative.ESP = _loc2_;
                                                wdnative_nternal.F_chunk_dealloc();
                                                _loc2_ += 16;
                                             }
                                             else
                                             {
                                                _loc2_ -= 16;
                                                si32(_loc12_,_loc2_);
                                                _loc9_ = (_loc12_ | -4096) + _loc9_;
                                                var _temp_64:* = int(4096 - _loc13_);
                                                si32(_temp_64,_loc2_ + 4);
                                                _loc12_ = _temp_64 + _loc12_;
                                                wdnative.ESP = _loc2_;
                                                wdnative_nternal.F_chunk_dealloc();
                                                _loc2_ += 16;
                                                if(_loc9_ != _loc11_)
                                                {
                                                   var _temp_66:* = int(_loc9_ - _loc11_);
                                                   _loc2_ -= 16;
                                                   si32(_temp_66,_loc2_ + 4);
                                                   si32(int(_loc12_ + _loc11_),_loc2_);
                                                   wdnative.ESP = _loc2_;
                                                   wdnative_nternal.F_chunk_dealloc();
                                                   _loc2_ += 16;
                                                }
                                             }
                                             si32(_loc12_,_loc14_ + 16);
                                             si32(_loc11_,_loc14_ + 20);
                                             _loc2_ -= 16;
                                             si32(_loc14_,_loc2_ + 4);
                                             si32(wdnative_nternal._huge,_loc2_);
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_extent_tree_ad_insert();
                                             _loc2_ += 16;
                                             _loc1_ = li8(wdnative_nternal._opt_junk_2E_b);
                                             if(_loc1_ == 1)
                                             {
                                                _loc2_ -= 16;
                                                si32(_loc11_,_loc2_ + 8);
                                                si32(165,_loc2_ + 4);
                                                si32(_loc12_,_loc2_);
                                                wdnative.ESP = _loc2_;
                                                wdnative.Fmemset();
                                                _loc2_ += 16;
                                                break;
                                             }
                                             if(li8(wdnative_nternal._opt_zero_2E_b) == 1)
                                             {
                                                _loc2_ -= 16;
                                                si32(_loc11_,_loc2_ + 8);
                                                si32(0,_loc2_ + 4);
                                                si32(_loc12_,_loc2_);
                                                wdnative.ESP = _loc2_;
                                                wdnative.Fmemset();
                                                _loc2_ += 16;
                                             }
                                             break;
                                          }
                                          si32(li32(wdnative_nternal._base_nodes),_loc14_);
                                          si32(_loc14_,wdnative_nternal._base_nodes);
                                       }
                                       else
                                       {
                                          _loc14_ = li32(wdnative_nternal._base_next_addr);
                                          var _temp_72:* = int(_loc14_ + 64);
                                          _loc7_ = li32(wdnative_nternal._base_past_addr);
                                          while(true)
                                          {
                                             if(uint(_temp_72) > uint(_loc7_))
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
                                                _loc14_ = li32(wdnative_nternal._base_next_addr);
                                             }
                                             _loc1_ = _loc14_ + 64;
                                             si32(_loc1_,wdnative_nternal._base_next_addr);
                                             if(_loc14_ == 0)
                                             {
                                                break;
                                             }
                                             §§goto(addr05d6);
                                          }
                                       }
                                    }
                                 }
                              }
                           }
                           addr0791:
                           _loc1_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
                           if(_loc1_ != 1)
                           {
                              break loop7;
                           }
                           _loc12_ = li32(wdnative_nternal.___progname);
                           _loc14_ = _loc12_ & -4;
                           _loc7_ = li32(_loc14_);
                           var _temp_79:* = int(_loc7_ + -16843009);
                           if(((_loc7_ = (_loc7_ &= -2139062144) ^ -2139062144) & _temp_79) != 0)
                           {
                              _loc11_ = _loc14_ + 4;
                              _loc9_ = 0;
                              while(true)
                              {
                                 _loc13_ = _loc12_ + _loc9_;
                                 if((uint(_loc13_)) < uint(_loc11_))
                                 {
                                    if(li8(_loc13_) == 0)
                                    {
                                       break;
                                    }
                                    _loc9_ += 1;
                                    continue;
                                 }
                              }
                              addr08b4:
                              _loc2_ -= 16;
                              si32(_loc9_,_loc2_ + 8);
                              si32(_loc12_,_loc2_ + 4);
                              si32(2,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F___sys_write();
                              _loc2_ += 16;
                              _loc12_ = wdnative_nternal.L__2E_str48663 & -4;
                              _loc7_ = li32(_loc12_);
                              _loc1_ = _loc7_ + -16843009;
                              _loc7_ &= -2139062144;
                              _loc7_ = _loc7_ ^ -2139062144;
                              _loc1_ = _loc7_ & _loc1_;
                              _loc11_ = _loc12_ + 4;
                              _loc13_ = 0;
                              if(_loc1_ != 0)
                              {
                                 do
                                 {
                                    _loc1_ = wdnative_nternal.L__2E_str48663 + _loc13_;
                                    _loc11_ = _loc12_ + 4;
                                    if(uint(_loc1_) < uint(_loc11_))
                                    {
                                       continue;
                                    }
                                 }
                                 while(_loc14_ = _loc12_ + 4, _loc11_ = wdnative_nternal.L__2E_str48663, if(uint(wdnative_nternal.L__2E_str48663) <= uint(_loc14_))
                                 {
                                    _loc11_ = _loc14_;
                                 }, _loc1_ = _loc11_ ^ -1, _loc11_ = wdnative_nternal.L__2E_str48663 + _loc1_, if((uint(_loc11_)) <= 4294967243)
                                 {
                                    _loc11_ = -53;
                                 }, _loc11_ ^= -1, _loc13_ += 1, _loc13_ != 53);
                                 addr0a38:
                                 _loc2_ -= 16;
                                 si32(_loc11_,_loc2_ + 8);
                                 si32(wdnative_nternal.L__2E_str48663,_loc2_ + 4);
                                 si32(2,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F___sys_write();
                                 _loc2_ += 16;
                                 _loc13_ = wdnative_nternal.L__2E_str2617 & -4;
                                 _loc7_ = li32(_loc13_);
                                 _loc1_ = _loc7_ + -16843009;
                                 _loc7_ &= -2139062144;
                                 _loc7_ = _loc7_ ^ -2139062144;
                                 _loc1_ = _loc7_ & _loc1_;
                                 _loc11_ = _loc13_ + 4;
                                 _loc12_ = 0;
                                 loop11:
                                 while(true)
                                 {
                                    if(_loc1_ != 0)
                                    {
                                       var _temp_93:* = int(_loc13_ + 4);
                                       _loc14_ = _loc12_;
                                       if(uint(wdnative_nternal.L__2E_str2617) < uint(_temp_93))
                                       {
                                          break;
                                       }
                                    }
                                    while(true)
                                    {
                                       _loc14_ = li32(_loc11_);
                                       _loc1_ = _loc14_ + -16843009;
                                       _loc7_ = _loc14_ & -2139062144;
                                       _loc7_ = _loc7_ ^ -2139062144;
                                       _loc1_ = _loc7_ & _loc1_;
                                       if(_loc1_ != 0)
                                       {
                                          if((_loc14_ & 0xFF) == 0)
                                          {
                                             _loc14_ = _loc11_ - wdnative_nternal.L__2E_str2617;
                                             break loop11;
                                          }
                                          if(li8(_loc11_ + 1) == 0)
                                          {
                                             var _temp_97:* = int(1 - wdnative_nternal.L__2E_str2617);
                                             _loc14_ = _loc11_ + _temp_97;
                                             break loop11;
                                          }
                                          if(li8(_loc11_ + 2) == 0)
                                          {
                                             var _temp_98:* = int(2 - wdnative_nternal.L__2E_str2617);
                                             _loc14_ = _loc11_ + _temp_98;
                                             break loop11;
                                          }
                                          if(li8(_loc11_ + 3) == 0)
                                          {
                                             var _temp_99:* = int(3 - wdnative_nternal.L__2E_str2617);
                                             _loc14_ = _loc11_ + _temp_99;
                                             break loop11;
                                          }
                                       }
                                       _loc11_ += 4;
                                    }
                                    break;
                                 }
                                 _loc2_ -= 16;
                                 si32(_loc14_,_loc2_ + 8);
                                 si32(2,_loc2_);
                                 si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F___sys_write();
                                 _loc2_ += 16;
                                 _loc7_ = li32(_loc13_);
                                 _loc1_ = _loc7_ + -16843009;
                                 _loc7_ &= -2139062144;
                                 _loc7_ = _loc7_ ^ -2139062144;
                                 _loc1_ = _loc7_ & _loc1_;
                                 _loc11_ = _loc13_ + 4;
                                 loop12:
                                 while(true)
                                 {
                                    if(_loc1_ != 0)
                                    {
                                       var _temp_104:* = int(_loc13_ + 4);
                                       if(uint(wdnative_nternal.L__2E_str2617) < uint(_temp_104))
                                       {
                                          break;
                                       }
                                    }
                                    while(true)
                                    {
                                       _loc12_ = li32(_loc11_);
                                       _loc1_ = _loc12_ + -16843009;
                                       _loc7_ = _loc12_ & -2139062144;
                                       _loc7_ = _loc7_ ^ -2139062144;
                                       _loc1_ = _loc7_ & _loc1_;
                                       if(_loc1_ != 0)
                                       {
                                          if((_loc12_ & 0xFF) == 0)
                                          {
                                             _loc12_ = _loc11_ - wdnative_nternal.L__2E_str2617;
                                             break loop12;
                                          }
                                          if(li8(_loc11_ + 1) == 0)
                                          {
                                             var _temp_108:* = int(1 - wdnative_nternal.L__2E_str2617);
                                             _loc12_ = _loc11_ + _temp_108;
                                             break loop12;
                                          }
                                          if(li8(_loc11_ + 2) == 0)
                                          {
                                             var _temp_109:* = int(2 - wdnative_nternal.L__2E_str2617);
                                             _loc12_ = _loc11_ + _temp_109;
                                             break loop12;
                                          }
                                          if(li8(_loc11_ + 3) == 0)
                                          {
                                             var _temp_110:* = int(3 - wdnative_nternal.L__2E_str2617);
                                             _loc12_ = _loc11_ + _temp_110;
                                             break loop12;
                                          }
                                       }
                                       _loc11_ += 4;
                                    }
                                    break;
                                 }
                                 _loc2_ -= 16;
                                 si32(_loc12_,_loc2_ + 8);
                                 si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                                 si32(2,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F___sys_write();
                                 _loc2_ += 16;
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_abort();
                                 break loop7;
                              }
                              while(true)
                              {
                                 _loc12_ = li32(_loc11_);
                                 _loc1_ = _loc12_ + -16843009;
                                 _loc7_ = _loc12_ & -2139062144;
                                 _loc7_ = _loc7_ ^ -2139062144;
                                 _loc1_ = _loc7_ & _loc1_;
                                 if(_loc1_ != 0)
                                 {
                                    if((_loc12_ & 0xFF) == 0)
                                    {
                                       _loc11_ -= wdnative_nternal.L__2E_str48663;
                                       break;
                                    }
                                    if(li8(_loc11_ + 1) == 0)
                                    {
                                       var _temp_116:* = int(1 - wdnative_nternal.L__2E_str48663);
                                       _loc11_ += _temp_116;
                                       break;
                                    }
                                    if(li8(_loc11_ + 2) == 0)
                                    {
                                       var _temp_117:* = int(2 - wdnative_nternal.L__2E_str48663);
                                       _loc11_ += _temp_117;
                                       break;
                                    }
                                    if(li8(_loc11_ + 3) == 0)
                                    {
                                       var _temp_118:* = int(3 - wdnative_nternal.L__2E_str48663);
                                       _loc11_ += _temp_118;
                                       break;
                                    }
                                 }
                                 _loc11_ += 4;
                              }
                              §§goto(addr0a38);
                           }
                           _loc11_ = _loc14_ + 4;
                           while(true)
                           {
                              _loc13_ = li32(_loc11_);
                              _loc1_ = _loc13_ + -16843009;
                              _loc7_ = _loc13_ & -2139062144;
                              _loc7_ = _loc7_ ^ -2139062144;
                              _loc1_ = _loc7_ & _loc1_;
                              if(_loc1_ != 0)
                              {
                                 if((_loc13_ & 0xFF) == 0)
                                 {
                                    _loc9_ = _loc11_ - _loc12_;
                                    break;
                                 }
                                 if(li8(_loc11_ + 1) == 0)
                                 {
                                    _loc9_ = int(1 - _loc12_) + _loc11_;
                                    break;
                                 }
                                 if(li8(_loc11_ + 2) == 0)
                                 {
                                    _loc9_ = int(2 - _loc12_) + _loc11_;
                                    break;
                                 }
                                 if(li8(_loc11_ + 3) == 0)
                                 {
                                    _loc9_ = int(3 - _loc12_) + _loc11_;
                                    break;
                                 }
                              }
                              _loc11_ += 4;
                           }
                           §§goto(addr08b4);
                        }
                     }
                     _loc1_ = li32(wdnative_nternal._arenas);
                     _loc1_ = li32(_loc1_);
                     _loc2_ -= 16;
                     si32(0,_loc2_ + 8);
                     si32(_loc13_,_loc2_ + 4);
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_arena_malloc();
                     _loc2_ += 16;
                     _loc12_ = wdnative.eax;
                     break;
                  }
                  if(_loc12_ != 0)
                  {
                     break loop6;
                  }
               }
            }
            §§goto(addr0791);
         }
         wdnative.ESP = _loc2_;
         wdnative.F__ZN14WeErrorHandler11errorHandleEN11WeErrorCode4EnumEPKciS3_z();
         _loc12_ = 0;
         break;
      }
      wdnative.eax = _loc12_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

