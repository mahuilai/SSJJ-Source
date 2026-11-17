package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F_realloc() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc15_:int = 0;
      var _loc6_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      var _loc17_:int = 0;
      var _loc10_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc4_ = li32(_loc5_ + 4);
      _loc17_ = li32(_loc5_);
      while(true)
      {
         if(_loc4_ == 0)
         {
            _loc4_ = 1;
            var _loc16_:int = li8(wdnative_nternal._opt_sysv_2E_b);
            if(_loc16_ == 1)
            {
               _loc15_ = 0;
               if(_loc17_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_idalloc();
                  _loc3_ += 16;
                  _loc15_ = 0;
               }
               break;
            }
         }
         if(_loc17_ != 0)
         {
            _loc14_ = li32(wdnative_nternal._chunksize_mask);
            _loc13_ = _loc14_ ^ -1;
            _loc15_ = _loc17_ & _loc13_;
            if(_loc15_ != _loc17_)
            {
               _loc16_ = _loc17_ - _loc15_;
               _loc16_ = _loc16_ >>> 12;
               var _temp_9:* = int(_loc16_ * 12);
               _loc16_ = _loc15_ + _temp_9;
               _loc16_ = li32(_loc16_ + 24);
               _loc12_ = _loc16_ & -4096;
               _loc16_ &= 2;
               if(_loc16_ == 0)
               {
                  _loc16_ = li32(_loc12_);
                  _loc12_ = li32(_loc16_ + 20);
               }
            }
            else
            {
               _loc11_ = li32(wdnative_nternal._huge);
               _loc12_ = wdnative_nternal._huge + 4;
               while(_loc11_ != _loc12_)
               {
                  _loc6_ = li32(_loc11_ + 16);
                  if(_loc6_ == _loc17_)
                  {
                     break;
                  }
                  _loc1_ = _loc10_ = 1;
                  if(uint(_loc6_) <= uint(_loc17_))
                  {
                     _loc1_ = 0;
                  }
                  if(uint(_loc6_) >= uint(_loc17_))
                  {
                     _loc10_ = 0;
                  }
                  _loc16_ = _loc1_ & 1;
                  var _loc7_:int = _loc10_ & 1;
                  _loc16_ = _loc7_ - _loc16_;
                  if(_loc16_ <= -1)
                  {
                     _loc11_ = li32(_loc11_ + 8);
                  }
                  else
                  {
                     _loc16_ = li32(_loc11_ + 12);
                     _loc11_ = _loc16_ & -2;
                  }
               }
               _loc1_ = 0;
               if(_loc11_ != _loc12_)
               {
                  _loc1_ = _loc11_;
               }
               _loc12_ = li32(_loc1_ + 20);
            }
            _loc11_ = li32(wdnative_nternal._arena_maxclass);
            if((uint(_loc11_)) >= uint(_loc4_))
            {
               _loc14_ = 3840;
               _loc16_ = li8(wdnative_nternal._sspace_max_2E_b);
               if(_loc16_ == 0)
               {
                  _loc14_ = 0;
               }
               if(uint(_loc14_) >= uint(_loc4_))
               {
                  if(uint(_loc14_) >= uint(_loc12_))
                  {
                     _loc7_ = li32(wdnative_nternal._size2bin);
                     _loc16_ = _loc7_ + _loc12_;
                     var _temp_24:* = li8(_loc16_);
                     if((_loc7_ = li8(_loc7_ += _loc4_)) == _temp_24)
                     {
                        _loc16_ = li8(wdnative_nternal._opt_junk_2E_b);
                        if(_loc16_ == 1)
                        {
                           if(uint(_loc12_) > uint(_loc4_))
                           {
                              _loc3_ -= 16;
                              si32(90,_loc3_ + 4);
                              _loc16_ = _loc12_ - _loc4_;
                              si32(_loc16_,_loc3_ + 8);
                              _loc16_ = _loc4_ + _loc17_;
                              si32(_loc16_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                              _loc15_ = _loc17_;
                              break;
                           }
                        }
                        _loc16_ = li8(wdnative_nternal._opt_zero_2E_b);
                        _loc15_ = _loc17_;
                        if(_loc16_ == 1)
                        {
                           _loc15_ = _loc17_;
                           if(uint(_loc12_) < uint(_loc4_))
                           {
                              _loc3_ -= 16;
                              si32(0,_loc3_ + 4);
                              _loc16_ = _loc4_ - _loc12_;
                              si32(_loc16_,_loc3_ + 8);
                              _loc16_ = _loc12_ + _loc17_;
                              si32(_loc16_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                              _loc15_ = _loc17_;
                           }
                        }
                        break;
                     }
                  }
               }
               else
               {
                  _loc13_ = 1;
                  if(uint(_loc14_) < uint(_loc12_))
                  {
                     _loc13_ = 0;
                  }
                  if(uint(_loc11_) >= uint(_loc12_))
                  {
                     if(_loc13_ == 0)
                     {
                        _loc11_ = _loc4_ + 4095;
                        _loc13_ = _loc11_ & -4096;
                        if(_loc13_ == _loc12_)
                        {
                           var _temp_34:* = li8(wdnative_nternal._opt_junk_2E_b);
                           _loc15_ = _loc17_;
                           if(_temp_34 == 1)
                           {
                              _loc15_ = _loc17_;
                              if(uint(_loc12_) > uint(_loc4_))
                              {
                                 _loc3_ -= 16;
                                 si32(90,_loc3_ + 4);
                                 _loc16_ = _loc12_ - _loc4_;
                                 si32(_loc16_,_loc3_ + 8);
                                 _loc16_ = _loc4_ + _loc17_;
                                 si32(_loc16_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative.Fmemset();
                                 _loc3_ += 16;
                                 _loc15_ = _loc17_;
                              }
                           }
                           break;
                        }
                        _loc14_ = li32(_loc15_);
                        if(uint(_loc13_) < uint(_loc12_))
                        {
                           _loc16_ = li8(wdnative_nternal._opt_junk_2E_b);
                           if(_loc16_ == 1)
                           {
                              _loc3_ -= 16;
                              si32(90,_loc3_ + 4);
                              _loc16_ = _loc12_ - _loc4_;
                              si32(_loc16_,_loc3_ + 8);
                              _loc16_ = _loc4_ + _loc17_;
                              si32(_loc16_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                           }
                           _loc16_ = _loc17_ - _loc15_;
                           _loc7_ = _loc16_ >>> 12;
                           var _loc8_:int = _loc7_ * 12;
                           _loc16_ = _loc15_ + 16;
                           var _loc9_:int = _loc16_ + _loc8_;
                           _loc8_ = _loc13_ | 3;
                           si32(_loc8_,_loc9_ + 8);
                           _loc8_ = _loc11_ >>> 12;
                           _loc7_ += _loc8_;
                           _loc7_ = _loc7_ * 12;
                           _loc16_ += _loc7_;
                           _loc7_ = _loc12_ - _loc13_;
                           _loc7_ = _loc7_ | 3;
                           si32(_loc7_,_loc16_ + 8);
                           _loc3_ -= 16;
                           si32(1,_loc3_ + 8);
                           _loc16_ = _loc13_ + _loc17_;
                           si32(_loc16_,_loc3_ + 4);
                           si32(_loc14_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_arena_run_dalloc();
                           _loc3_ += 16;
                           _loc15_ = _loc17_;
                           break;
                        }
                        _loc16_ = _loc17_ - _loc15_;
                        _loc11_ = _loc16_ >>> 12;
                        var _temp_52:* = _loc12_ >>> 12;
                        _loc1_ = _loc11_ + _temp_52;
                        var _temp_53:* = li32(wdnative_nternal._chunk_npages);
                        if(uint(_loc1_) < uint(_temp_53))
                        {
                           var _temp_54:* = int(_loc1_ * 12);
                           _loc10_ = _loc15_ + _temp_54;
                           _loc6_ = li32(_loc10_ + 24);
                           _loc16_ = _loc6_ & 1;
                           if(_loc16_ == 0)
                           {
                              _loc2_ = _loc13_ - _loc12_;
                              _loc16_ = _loc6_ & -4096;
                              if((uint(_loc16_)) >= uint(_loc2_))
                              {
                                 _loc3_ -= 32;
                                 si32(0,_loc3_ + 16);
                                 si32(1,_loc3_ + 12);
                                 si32(_loc2_,_loc3_ + 8);
                                 si32(_loc14_,_loc3_);
                                 _loc16_ = _loc1_ << 12;
                                 _loc16_ = _loc16_ + _loc15_;
                                 si32(_loc16_,_loc3_ + 4);
                                 var _temp_61:* = int(_loc11_ * 12);
                                 var _temp_64:* = int(_loc15_ + _temp_61);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_arena_run_split();
                                 _loc3_ += 32;
                                 _loc7_ = _loc13_ | 3;
                                 si32(_loc7_,_temp_64 + 24);
                                 si32(3,_loc10_ + 24);
                                 var _temp_65:* = li8(wdnative_nternal._opt_zero_2E_b);
                                 _loc15_ = _loc17_;
                                 if(_temp_65 == 1)
                                 {
                                    _loc3_ -= 16;
                                    si32(0,_loc3_ + 4);
                                    _loc16_ = _loc4_ - _loc12_;
                                    si32(_loc16_,_loc3_ + 8);
                                    _loc16_ = _loc12_ + _loc17_;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative.Fmemset();
                                    _loc3_ += 16;
                                    _loc15_ = _loc17_;
                                 }
                                 break;
                              }
                           }
                        }
                     }
                  }
               }
               _loc16_ = li32(wdnative_nternal._arenas);
               _loc16_ = li32(_loc16_);
               _loc3_ -= 16;
               si32(0,_loc3_ + 8);
               si32(_loc4_,_loc3_ + 4);
               si32(_loc16_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_arena_malloc();
               _loc3_ += 16;
               _loc15_ = wdnative.eax;
               if(_loc15_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_ + 4);
                  si32(_loc15_,_loc3_);
                  if(uint(_loc12_) > uint(_loc4_))
                  {
                     _loc12_ = _loc4_;
                  }
                  si32(_loc12_,_loc3_ + 8);
                  wdnative.ESP = _loc3_;
                  wdnative.Fmemcpy();
                  _loc3_ += 16;
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_idalloc();
                  _loc3_ += 16;
                  break;
               }
            }
            else
            {
               _loc15_ = _loc14_ + _loc4_;
               if(uint(_loc11_) < uint(_loc12_))
               {
                  var _temp_74:* = int(_loc14_ + _loc12_);
                  _loc16_ = _loc15_ ^ _temp_74;
                  _loc16_ = _loc16_ & _loc13_;
                  if(_loc16_ == 0)
                  {
                     _loc16_ = li8(wdnative_nternal._opt_junk_2E_b);
                     if(_loc16_ == 1)
                     {
                        if(uint(_loc12_) > uint(_loc4_))
                        {
                           _loc3_ -= 16;
                           si32(90,_loc3_ + 4);
                           _loc16_ = _loc12_ - _loc4_;
                           si32(_loc16_,_loc3_ + 8);
                           _loc16_ = _loc4_ + _loc17_;
                           si32(_loc16_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.Fmemset();
                           _loc3_ += 16;
                           _loc15_ = _loc17_;
                           break;
                        }
                     }
                     _loc16_ = li8(wdnative_nternal._opt_zero_2E_b);
                     _loc15_ = _loc17_;
                     if(_loc16_ == 1)
                     {
                        _loc15_ = _loc17_;
                        if(uint(_loc12_) < uint(_loc4_))
                        {
                           _loc3_ -= 16;
                           si32(0,_loc3_ + 4);
                           _loc16_ = _loc4_ - _loc12_;
                           si32(_loc16_,_loc3_ + 8);
                           _loc16_ = _loc12_ + _loc17_;
                           si32(_loc16_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.Fmemset();
                           _loc3_ += 16;
                           _loc15_ = _loc17_;
                        }
                     }
                     break;
                  }
               }
               _loc14_ = _loc15_ & _loc13_;
               if(_loc14_ != 0)
               {
                  _loc13_ = li32(wdnative_nternal._base_nodes);
                  if(_loc13_ != 0)
                  {
                     _loc16_ = li32(_loc13_);
                     si32(_loc16_,wdnative_nternal._base_nodes);
                     addr07ae:
                     _loc3_ -= 16;
                     si32(0,_loc3_ + 4);
                     si32(_loc14_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_chunk_alloc();
                     _loc3_ += 16;
                     _loc15_ = wdnative.eax;
                     if(_loc15_ != 0)
                     {
                        si32(_loc15_,_loc13_ + 16);
                        si32(_loc14_,_loc13_ + 20);
                        _loc3_ -= 16;
                        si32(_loc13_,_loc3_ + 4);
                        si32(wdnative_nternal._huge,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_extent_tree_ad_insert();
                        _loc3_ += 16;
                        _loc16_ = li8(wdnative_nternal._opt_junk_2E_b);
                        if(_loc16_ == 1)
                        {
                           _loc3_ -= 16;
                           si32(_loc14_,_loc3_ + 8);
                           si32(165,_loc3_ + 4);
                           si32(_loc15_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.Fmemset();
                           _loc3_ += 16;
                        }
                        else
                        {
                           _loc16_ = li8(wdnative_nternal._opt_zero_2E_b);
                           if(_loc16_ == 1)
                           {
                              _loc3_ -= 16;
                              si32(_loc14_,_loc3_ + 8);
                              si32(0,_loc3_ + 4);
                              si32(_loc15_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                           }
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_ + 4);
                        si32(_loc15_,_loc3_);
                        if(uint(_loc12_) > uint(_loc4_))
                        {
                           _loc12_ = _loc4_;
                        }
                        si32(_loc12_,_loc3_ + 8);
                        wdnative.ESP = _loc3_;
                        wdnative.Fmemcpy();
                        _loc3_ += 16;
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_idalloc();
                        _loc3_ += 16;
                        break;
                     }
                     _loc16_ = li32(wdnative_nternal._base_nodes);
                     si32(_loc16_,_loc13_);
                     si32(_loc13_,wdnative_nternal._base_nodes);
                  }
                  else
                  {
                     _loc13_ = li32(wdnative_nternal._base_next_addr);
                     var _temp_98:* = int(_loc13_ + 64);
                     _loc7_ = li32(wdnative_nternal._base_past_addr);
                     while(true)
                     {
                        if(uint(_temp_98) > uint(_loc7_))
                        {
                           _loc3_ -= 16;
                           si32(64,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_base_pages_alloc();
                           _loc3_ += 16;
                           _loc16_ = wdnative.eax;
                           if(_loc16_ != 0)
                           {
                              break;
                           }
                           _loc13_ = li32(wdnative_nternal._base_next_addr);
                        }
                        _loc16_ = _loc13_ + 64;
                        si32(_loc16_,wdnative_nternal._base_next_addr);
                        if(_loc13_ == 0)
                        {
                           break;
                        }
                        §§goto(addr07ae);
                     }
                  }
               }
            }
            _loc16_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
            if(_loc16_ == 1)
            {
               _loc17_ = li32(wdnative_nternal.___progname);
               _loc14_ = _loc17_ & -4;
               _loc7_ = li32(_loc14_);
               var _temp_108:* = int(_loc7_ + -16843009);
               _loc16_ = (_loc7_ = (_loc7_ &= -2139062144) ^ -2139062144) & _temp_108;
               if(_loc16_ != 0)
               {
                  _loc12_ = _loc14_ + 4;
                  _loc4_ = 0;
                  while(true)
                  {
                     _loc15_ = _loc17_ + _loc4_;
                     if((uint(_loc15_)) < uint(_loc12_))
                     {
                        _loc16_ = li8(_loc15_);
                        if(_loc16_ == 0)
                        {
                           break;
                        }
                        _loc4_ += 1;
                        continue;
                     }
                  }
                  addr0a4d:
                  _loc3_ -= 16;
                  si32(_loc4_,_loc3_ + 8);
                  si32(_loc17_,_loc3_ + 4);
                  si32(2,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___sys_write();
                  _loc3_ += 16;
                  _loc17_ = wdnative_nternal.L__2E_str45660 & -4;
                  _loc7_ = li32(_loc17_);
                  _loc16_ = _loc7_ + -16843009;
                  _loc7_ &= -2139062144;
                  _loc7_ = _loc7_ ^ -2139062144;
                  _loc16_ = _loc7_ & _loc16_;
                  _loc15_ = _loc17_ + 4;
                  _loc4_ = 0;
                  if(_loc16_ != 0)
                  {
                     do
                     {
                        _loc16_ = wdnative_nternal.L__2E_str45660 + _loc4_;
                        _loc15_ = _loc17_ + 4;
                        if(uint(_loc16_) < uint(_loc15_))
                        {
                           continue;
                        }
                     }
                     while(_loc12_ = _loc17_ + 4, _loc15_ = wdnative_nternal.L__2E_str45660, if(uint(wdnative_nternal.L__2E_str45660) <= uint(_loc12_))
                     {
                        _loc15_ = _loc12_;
                     }, _loc16_ = _loc15_ ^ -1, _loc15_ = wdnative_nternal.L__2E_str45660 + _loc16_, if((uint(_loc15_)) <= 4294967250)
                     {
                        _loc15_ = -46;
                     }, _loc15_ ^= -1, _loc4_ += 1, _loc4_ != 46);
                     addr0be8:
                     _loc3_ -= 16;
                     si32(_loc15_,_loc3_ + 8);
                     si32(wdnative_nternal.L__2E_str45660,_loc3_ + 4);
                     si32(2,_loc3_);
                     _loc17_ = wdnative_nternal.L__2E_str2617 & -4;
                     _loc15_ = _loc17_ + 4;
                     _loc4_ = 0;
                     _loc12_ = 1;
                     if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
                     {
                        _loc12_ = _loc4_;
                     }
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     _loc7_ = li32(_loc17_);
                     _loc16_ = _loc7_ + -16843009;
                     loop15:
                     while(true)
                     {
                        _loc7_ &= -2139062144;
                        _loc7_ = _loc7_ ^ -2139062144;
                        _loc16_ = _loc7_ & _loc16_;
                        if(_loc16_ != 0)
                        {
                           var _temp_126:* = _loc12_ & 1;
                           _loc12_ = _loc4_;
                           if(_temp_126 == 0)
                           {
                              break;
                           }
                        }
                        while(true)
                        {
                           _loc12_ = li32(_loc15_);
                           _loc16_ = _loc12_ + -16843009;
                           _loc7_ = _loc12_ & -2139062144;
                           _loc7_ = _loc7_ ^ -2139062144;
                           _loc16_ = _loc7_ & _loc16_;
                           if(_loc16_ != 0)
                           {
                              _loc16_ = _loc12_ & 0xFF;
                              if(_loc16_ == 0)
                              {
                                 _loc12_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                                 break loop15;
                              }
                              _loc16_ = li8(_loc15_ + 1);
                              if(_loc16_ == 0)
                              {
                                 var _temp_133:* = int(1 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_133;
                                 break loop15;
                              }
                              _loc16_ = li8(_loc15_ + 2);
                              if(_loc16_ == 0)
                              {
                                 var _temp_135:* = int(2 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_135;
                                 break loop15;
                              }
                              _loc16_ = li8(_loc15_ + 3);
                              if(_loc16_ == 0)
                              {
                                 var _temp_137:* = int(3 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_137;
                                 break loop15;
                              }
                           }
                           _loc15_ += 4;
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc12_,_loc3_ + 8);
                     si32(2,_loc3_);
                     si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
                     _loc15_ = _loc17_ + 4;
                     _loc12_ = 1;
                     if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
                     {
                        _loc12_ = _loc4_;
                     }
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     _loc7_ = li32(_loc17_);
                     _loc16_ = _loc7_ + -16843009;
                     loop16:
                     while(true)
                     {
                        _loc7_ &= -2139062144;
                        _loc7_ = _loc7_ ^ -2139062144;
                        _loc16_ = _loc7_ & _loc16_;
                        if(_loc16_ != 0)
                        {
                           _loc16_ = _loc12_ & 1;
                           if(_loc16_ == 0)
                           {
                              break;
                           }
                        }
                        while(true)
                        {
                           _loc17_ = li32(_loc15_);
                           _loc16_ = _loc17_ + -16843009;
                           _loc7_ = _loc17_ & -2139062144;
                           _loc7_ = _loc7_ ^ -2139062144;
                           _loc16_ = _loc7_ & _loc16_;
                           if(_loc16_ != 0)
                           {
                              _loc16_ = _loc17_ & 0xFF;
                              if(_loc16_ == 0)
                              {
                                 _loc4_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                                 break loop16;
                              }
                              _loc16_ = li8(_loc15_ + 1);
                              if(_loc16_ == 0)
                              {
                                 var _temp_150:* = int(1 - wdnative_nternal.L__2E_str2617);
                                 _loc4_ = _loc15_ + _temp_150;
                                 break loop16;
                              }
                              _loc16_ = li8(_loc15_ + 2);
                              if(_loc16_ == 0)
                              {
                                 var _temp_152:* = int(2 - wdnative_nternal.L__2E_str2617);
                                 _loc4_ = _loc15_ + _temp_152;
                                 break loop16;
                              }
                              _loc16_ = li8(_loc15_ + 3);
                              if(_loc16_ == 0)
                              {
                                 var _temp_154:* = int(3 - wdnative_nternal.L__2E_str2617);
                                 _loc4_ = _loc15_ + _temp_154;
                                 break loop16;
                              }
                           }
                           _loc15_ += 4;
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc4_,_loc3_ + 8);
                     si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
                     si32(2,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_abort();
                     addr0eb4:
                     si32(12,wdnative_nternal._errno);
                     _loc15_ = 0;
                     break;
                  }
                  while(true)
                  {
                     _loc17_ = li32(_loc15_);
                     _loc16_ = _loc17_ + -16843009;
                     _loc7_ = _loc17_ & -2139062144;
                     _loc7_ = _loc7_ ^ -2139062144;
                     _loc16_ = _loc7_ & _loc16_;
                     if(_loc16_ != 0)
                     {
                        _loc16_ = _loc17_ & 0xFF;
                        if(_loc16_ == 0)
                        {
                           _loc15_ -= wdnative_nternal.L__2E_str45660;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 1);
                        if(_loc16_ == 0)
                        {
                           var _temp_163:* = int(1 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_163;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 2);
                        if(_loc16_ == 0)
                        {
                           var _temp_165:* = int(2 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_165;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 3);
                        if(_loc16_ == 0)
                        {
                           var _temp_167:* = int(3 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_167;
                           break;
                        }
                     }
                     _loc15_ += 4;
                  }
                  §§goto(addr0be8);
               }
               _loc15_ = _loc14_ + 4;
               while(true)
               {
                  _loc4_ = li32(_loc15_);
                  _loc16_ = _loc4_ + -16843009;
                  _loc7_ = _loc4_ & -2139062144;
                  _loc7_ = _loc7_ ^ -2139062144;
                  _loc16_ = _loc7_ & _loc16_;
                  if(_loc16_ != 0)
                  {
                     _loc16_ = _loc4_ & 0xFF;
                     if(_loc16_ == 0)
                     {
                        _loc4_ = _loc15_ - _loc17_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 1);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 1 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 2);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 2 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 3);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 3 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                  }
                  _loc15_ += 4;
               }
               §§goto(addr0a4d);
            }
            §§goto(addr0eb4);
         }
         else
         {
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_malloc_init();
            _loc16_ = wdnative.eax;
            if(_loc16_ == 0)
            {
               _loc16_ = li32(wdnative_nternal._arena_maxclass);
               if((uint(_loc16_)) >= uint(_loc4_))
               {
                  _loc16_ = li32(wdnative_nternal._arenas);
                  var _temp_183:* = li32(_loc16_);
                  _loc3_ -= 16;
                  si32(0,_loc3_ + 8);
                  si32(_loc4_,_loc3_ + 4);
                  si32(_temp_183,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_arena_malloc();
                  _loc3_ += 16;
                  _loc15_ = wdnative.eax;
                  addr10c7:
                  if(_loc15_ != 0)
                  {
                     break;
                  }
               }
               else
               {
                  _loc7_ = li32(wdnative_nternal._chunksize_mask);
                  _loc4_ = int(_loc7_ + _loc4_) & (_loc7_ ^ -1);
                  if(_loc4_ != 0)
                  {
                     _loc17_ = li32(wdnative_nternal._base_nodes);
                     if(_loc17_ != 0)
                     {
                        _loc16_ = li32(_loc17_);
                        si32(_loc16_,wdnative_nternal._base_nodes);
                        addr0fca:
                        _loc3_ -= 16;
                        si32(0,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_chunk_alloc();
                        _loc3_ += 16;
                        _loc15_ = wdnative.eax;
                        if(_loc15_ == 0)
                        {
                           _loc16_ = li32(wdnative_nternal._base_nodes);
                           si32(_loc16_,_loc17_);
                           si32(_loc17_,wdnative_nternal._base_nodes);
                        }
                        else
                        {
                           si32(_loc15_,_loc17_ + 16);
                           si32(_loc4_,_loc17_ + 20);
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_ + 4);
                           si32(wdnative_nternal._huge,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_extent_tree_ad_insert();
                           _loc3_ += 16;
                           _loc16_ = li8(wdnative_nternal._opt_junk_2E_b);
                           if(_loc16_ == 1)
                           {
                              _loc3_ -= 16;
                              si32(_loc4_,_loc3_ + 8);
                              si32(165,_loc3_ + 4);
                              si32(_loc15_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                              break;
                           }
                           _loc16_ = li8(wdnative_nternal._opt_zero_2E_b);
                           if(_loc16_ == 1)
                           {
                              _loc3_ -= 16;
                              si32(_loc4_,_loc3_ + 8);
                              si32(0,_loc3_ + 4);
                              si32(_loc15_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemset();
                              _loc3_ += 16;
                           }
                           §§goto(addr10c7);
                        }
                     }
                     else
                     {
                        _loc17_ = li32(wdnative_nternal._base_next_addr);
                        var _temp_198:* = int(_loc17_ + 64);
                        _loc16_ = li32(wdnative_nternal._base_past_addr);
                        while(true)
                        {
                           if(uint(_temp_198) > uint(_loc16_))
                           {
                              _loc3_ -= 16;
                              si32(64,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_base_pages_alloc();
                              _loc3_ += 16;
                              _loc16_ = wdnative.eax;
                              if(_loc16_ != 0)
                              {
                                 break;
                              }
                              _loc17_ = li32(wdnative_nternal._base_next_addr);
                           }
                           _loc16_ = _loc17_ + 64;
                           si32(_loc16_,wdnative_nternal._base_next_addr);
                           if(_loc17_ == 0)
                           {
                              break;
                           }
                           §§goto(addr0fca);
                        }
                     }
                  }
               }
            }
            _loc16_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
            if(_loc16_ == 1)
            {
               _loc17_ = li32(wdnative_nternal.___progname);
               _loc15_ = _loc17_ & -4;
               _loc7_ = li32(_loc15_);
               var _temp_208:* = int(_loc7_ + -16843009);
               _loc16_ = (_loc7_ = (_loc7_ &= -2139062144) ^ -2139062144) & _temp_208;
               if(_loc16_ != 0)
               {
                  _loc12_ = _loc15_ + 4;
                  _loc4_ = 0;
                  while(true)
                  {
                     _loc14_ = _loc17_ + _loc4_;
                     if((uint(_loc14_)) < uint(_loc12_))
                     {
                        _loc16_ = li8(_loc14_);
                        if(_loc16_ == 0)
                        {
                           break;
                        }
                        _loc4_ += 1;
                        continue;
                     }
                  }
                  addr1212:
                  _loc3_ -= 16;
                  si32(_loc4_,_loc3_ + 8);
                  si32(_loc17_,_loc3_ + 4);
                  si32(2,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___sys_write();
                  _loc3_ += 16;
                  _loc17_ = wdnative_nternal.L__2E_str45660 & -4;
                  _loc7_ = li32(_loc17_);
                  _loc16_ = _loc7_ + -16843009;
                  _loc7_ &= -2139062144;
                  _loc7_ = _loc7_ ^ -2139062144;
                  _loc16_ = _loc7_ & _loc16_;
                  _loc15_ = _loc17_ + 4;
                  _loc4_ = 0;
                  if(_loc16_ != 0)
                  {
                     do
                     {
                        _loc16_ = wdnative_nternal.L__2E_str45660 + _loc4_;
                        _loc15_ = _loc17_ + 4;
                        if(uint(_loc16_) < uint(_loc15_))
                        {
                           continue;
                        }
                     }
                     while(_loc15_ = _loc17_ + 4, _loc12_ = wdnative_nternal.L__2E_str45660, if(uint(wdnative_nternal.L__2E_str45660) <= uint(_loc15_))
                     {
                        _loc12_ = _loc15_;
                     }, _loc16_ = _loc12_ ^ -1, _loc15_ = wdnative_nternal.L__2E_str45660 + _loc16_, if((uint(_loc15_)) <= 4294967250)
                     {
                        _loc15_ = -46;
                     }, _loc15_ ^= -1, _loc4_ += 1, _loc4_ != 46);
                     addr13ad:
                     _loc3_ -= 16;
                     si32(_loc15_,_loc3_ + 8);
                     si32(wdnative_nternal.L__2E_str45660,_loc3_ + 4);
                     si32(2,_loc3_);
                     _loc4_ = wdnative_nternal.L__2E_str2617 & -4;
                     _loc15_ = _loc4_ + 4;
                     _loc17_ = 0;
                     _loc12_ = 1;
                     if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
                     {
                        _loc12_ = _loc17_;
                     }
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     _loc7_ = li32(_loc4_);
                     _loc16_ = _loc7_ + -16843009;
                     loop18:
                     while(true)
                     {
                        _loc7_ &= -2139062144;
                        _loc7_ = _loc7_ ^ -2139062144;
                        _loc16_ = _loc7_ & _loc16_;
                        if(_loc16_ != 0)
                        {
                           var _temp_226:* = _loc12_ & 1;
                           _loc12_ = _loc17_;
                           if(_temp_226 == 0)
                           {
                              break;
                           }
                        }
                        while(true)
                        {
                           _loc12_ = li32(_loc15_);
                           _loc16_ = _loc12_ + -16843009;
                           _loc7_ = _loc12_ & -2139062144;
                           _loc7_ = _loc7_ ^ -2139062144;
                           _loc16_ = _loc7_ & _loc16_;
                           if(_loc16_ != 0)
                           {
                              _loc16_ = _loc12_ & 0xFF;
                              if(_loc16_ == 0)
                              {
                                 _loc12_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                                 break loop18;
                              }
                              _loc16_ = li8(_loc15_ + 1);
                              if(_loc16_ == 0)
                              {
                                 var _temp_233:* = int(1 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_233;
                                 break loop18;
                              }
                              _loc16_ = li8(_loc15_ + 2);
                              if(_loc16_ == 0)
                              {
                                 var _temp_235:* = int(2 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_235;
                                 break loop18;
                              }
                              _loc16_ = li8(_loc15_ + 3);
                              if(_loc16_ == 0)
                              {
                                 var _temp_237:* = int(3 - wdnative_nternal.L__2E_str2617);
                                 _loc12_ = _loc15_ + _temp_237;
                                 break loop18;
                              }
                           }
                           _loc15_ += 4;
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc12_,_loc3_ + 8);
                     si32(2,_loc3_);
                     si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
                     _loc15_ = _loc4_ + 4;
                     _loc12_ = 1;
                     if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
                     {
                        _loc12_ = _loc17_;
                     }
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     _loc7_ = li32(_loc4_);
                     _loc16_ = _loc7_ + -16843009;
                     loop19:
                     while(true)
                     {
                        _loc7_ &= -2139062144;
                        _loc7_ = _loc7_ ^ -2139062144;
                        _loc16_ = _loc7_ & _loc16_;
                        if(_loc16_ != 0)
                        {
                           _loc16_ = _loc12_ & 1;
                           if(_loc16_ == 0)
                           {
                              break;
                           }
                        }
                        while(true)
                        {
                           _loc17_ = li32(_loc15_);
                           _loc16_ = _loc17_ + -16843009;
                           _loc7_ = _loc17_ & -2139062144;
                           _loc7_ = _loc7_ ^ -2139062144;
                           _loc16_ = _loc7_ & _loc16_;
                           if(_loc16_ != 0)
                           {
                              _loc16_ = _loc17_ & 0xFF;
                              if(_loc16_ == 0)
                              {
                                 _loc17_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                                 break loop19;
                              }
                              _loc16_ = li8(_loc15_ + 1);
                              if(_loc16_ == 0)
                              {
                                 var _temp_250:* = int(1 - wdnative_nternal.L__2E_str2617);
                                 _loc17_ = _loc15_ + _temp_250;
                                 break loop19;
                              }
                              _loc16_ = li8(_loc15_ + 2);
                              if(_loc16_ == 0)
                              {
                                 var _temp_252:* = int(2 - wdnative_nternal.L__2E_str2617);
                                 _loc17_ = _loc15_ + _temp_252;
                                 break loop19;
                              }
                              _loc16_ = li8(_loc15_ + 3);
                              if(_loc16_ == 0)
                              {
                                 var _temp_254:* = int(3 - wdnative_nternal.L__2E_str2617);
                                 _loc17_ = _loc15_ + _temp_254;
                                 break loop19;
                              }
                           }
                           _loc15_ += 4;
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc17_,_loc3_ + 8);
                     si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
                     si32(2,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___sys_write();
                     _loc3_ += 16;
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_abort();
                     addr1679:
                     si32(12,wdnative_nternal._errno);
                     _loc15_ = 0;
                     break;
                  }
                  while(true)
                  {
                     _loc17_ = li32(_loc15_);
                     _loc16_ = _loc17_ + -16843009;
                     _loc7_ = _loc17_ & -2139062144;
                     _loc7_ = _loc7_ ^ -2139062144;
                     _loc16_ = _loc7_ & _loc16_;
                     if(_loc16_ != 0)
                     {
                        _loc16_ = _loc17_ & 0xFF;
                        if(_loc16_ == 0)
                        {
                           _loc15_ -= wdnative_nternal.L__2E_str45660;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 1);
                        if(_loc16_ == 0)
                        {
                           var _temp_263:* = int(1 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_263;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 2);
                        if(_loc16_ == 0)
                        {
                           var _temp_265:* = int(2 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_265;
                           break;
                        }
                        _loc16_ = li8(_loc15_ + 3);
                        if(_loc16_ == 0)
                        {
                           var _temp_267:* = int(3 - wdnative_nternal.L__2E_str45660);
                           _loc15_ += _temp_267;
                           break;
                        }
                     }
                     _loc15_ += 4;
                  }
                  §§goto(addr13ad);
               }
               _loc15_ += 4;
               while(true)
               {
                  _loc4_ = li32(_loc15_);
                  _loc16_ = _loc4_ + -16843009;
                  _loc7_ = _loc4_ & -2139062144;
                  _loc7_ = _loc7_ ^ -2139062144;
                  _loc16_ = _loc7_ & _loc16_;
                  if(_loc16_ != 0)
                  {
                     _loc16_ = _loc4_ & 0xFF;
                     if(_loc16_ == 0)
                     {
                        _loc4_ = _loc15_ - _loc17_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 1);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 1 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 2);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 2 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                     _loc16_ = li8(_loc15_ + 3);
                     if(_loc16_ == 0)
                     {
                        _loc16_ = 3 - _loc17_;
                        _loc4_ = _loc16_ + _loc15_;
                        break;
                     }
                  }
                  _loc15_ += 4;
               }
               §§goto(addr1212);
            }
            §§goto(addr1679);
         }
      }
      wdnative.eax = _loc15_;
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

