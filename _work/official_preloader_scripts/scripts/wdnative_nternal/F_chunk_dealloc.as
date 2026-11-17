package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_chunk_dealloc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 64;
      _loc1_ = li32(_loc3_ + 4);
      _loc14_ = li32(_loc3_);
      var _loc13_:int = li8(wdnative_nternal._opt_dss_2E_b);
      if(_loc13_ == 0)
      {
         while(true)
         {
            _loc13_ = li32(wdnative_nternal._dss_base);
            if((uint(_loc13_)) <= uint(_loc14_))
            {
               _loc13_ = li32(wdnative_nternal._dss_max);
               if((uint(_loc13_)) > uint(_loc14_))
               {
                  _loc12_ = _loc14_ + _loc1_;
                  _loc11_ = 0;
                  _loc10_ = wdnative_nternal._dss_chunks_ad;
                  loop0:
                  while(true)
                  {
                     _loc9_ = li32(_loc10_);
                     while(true)
                     {
                        _loc13_ = wdnative_nternal._dss_chunks_ad + 4;
                        _loc10_ = _loc11_;
                        if(_loc9_ == _loc13_)
                        {
                           break loop0;
                        }
                        _loc8_ = li32(_loc9_ + 16);
                        _loc10_ = _loc7_ = 1;
                        if(uint(_loc12_) >= uint(_loc8_))
                        {
                           _loc10_ = 0;
                        }
                        if(uint(_loc12_) <= uint(_loc8_))
                        {
                           _loc7_ = 0;
                        }
                        var _loc6_:int = _loc10_ & 1;
                        _loc13_ = _loc7_ & 1;
                        _loc7_ = _loc13_ - _loc6_;
                        if(_loc7_ <= -1)
                        {
                           break;
                        }
                        _loc10_ = _loc9_;
                        if(_loc7_ < 1)
                        {
                           break loop0;
                        }
                        _loc13_ = li32(_loc9_ + 12);
                        _loc9_ = _loc13_ & -2;
                     }
                     _loc10_ = _loc9_ + 8;
                     _loc11_ = _loc9_;
                  }
                  loop14:
                  while(true)
                  {
                     while(true)
                     {
                        if(_loc10_ != 0)
                        {
                           _loc13_ = li32(_loc10_ + 16);
                           if(_loc13_ == _loc12_)
                           {
                              _loc2_ -= 16;
                              si32(_loc10_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_extent_tree_szad_remove();
                              _loc2_ += 16;
                              si32(_loc14_,_loc10_ + 16);
                              _loc13_ = li32(_loc10_ + 20);
                              _loc13_ = _loc13_ + _loc1_;
                              si32(_loc13_,_loc10_ + 20);
                              _loc2_ -= 16;
                              si32(_loc10_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_extent_tree_szad_insert();
                              _loc2_ += 16;
                              break;
                           }
                        }
                        _loc10_ = li32(wdnative_nternal._base_nodes);
                        if(_loc10_ != 0)
                        {
                           _loc13_ = li32(_loc10_);
                           si32(_loc13_,wdnative_nternal._base_nodes);
                        }
                        else
                        {
                           _loc10_ = li32(wdnative_nternal._base_next_addr);
                           var _temp_26:* = int(_loc10_ + 64);
                           _loc6_ = li32(wdnative_nternal._base_past_addr);
                           if(uint(_temp_26) > uint(_loc6_))
                           {
                              _loc2_ -= 16;
                              si32(64,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_base_pages_alloc();
                              _loc11_ = 0;
                              _loc9_ = 1;
                              _loc2_ += 16;
                              _loc13_ = wdnative.eax;
                              if(_loc13_ != 0)
                              {
                                 break loop14;
                              }
                              _loc10_ = li32(wdnative_nternal._base_next_addr);
                           }
                           _loc13_ = _loc10_ + 64;
                           si32(_loc13_,wdnative_nternal._base_next_addr);
                           _loc11_ = 0;
                           _loc9_ = 1;
                           if(_loc10_ == 0)
                           {
                              break loop14;
                           }
                        }
                        si32(_loc14_,_loc10_ + 16);
                        si32(_loc1_,_loc10_ + 20);
                        _loc2_ -= 16;
                        si32(_loc10_,_loc2_ + 4);
                        si32(wdnative_nternal._dss_chunks_ad,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_extent_tree_ad_insert();
                        _loc2_ += 16;
                        _loc2_ -= 16;
                        si32(_loc10_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_extent_tree_szad_insert();
                        _loc2_ += 16;
                        break;
                     }
                     _loc12_ = li32(_loc10_ + 8);
                     _loc9_ = wdnative_nternal._dss_chunks_ad + 4;
                     if(_loc12_ != _loc9_)
                     {
                        while(true)
                        {
                           _loc11_ = _loc12_;
                           _loc13_ = li32(_loc11_ + 12);
                           _loc12_ = _loc13_ & -2;
                           if(_loc12_ == _loc9_)
                           {
                              break;
                           }
                        }
                     }
                     else
                     {
                        _loc12_ = li32(_loc10_ + 16);
                        _loc7_ = li32(wdnative_nternal._dss_chunks_ad);
                        _loc11_ = _loc9_;
                        while(true)
                        {
                           _loc4_ = li32(_loc7_ + 16);
                           _loc8_ = _loc5_ = 1;
                           if(uint(_loc12_) >= uint(_loc4_))
                           {
                              _loc8_ = 0;
                           }
                           if(uint(_loc12_) <= uint(_loc4_))
                           {
                              _loc5_ = 0;
                           }
                           _loc6_ = _loc8_ & 1;
                           _loc13_ = _loc5_ & 1;
                           _loc8_ = _loc13_ - _loc6_;
                           if(_loc8_ <= -1)
                           {
                              do
                              {
                                 _loc7_ = li32(_loc7_ + 8);
                                 _loc5_ = li32(_loc7_ + 16);
                                 _loc8_ = _loc4_ = 1;
                                 if(uint(_loc12_) >= uint(_loc5_))
                                 {
                                    _loc8_ = 0;
                                 }
                                 if(uint(_loc12_) <= uint(_loc5_))
                                 {
                                    _loc4_ = 0;
                                 }
                                 _loc6_ = _loc8_ & 1;
                              }
                              while(_loc13_ = _loc4_ & 1, _loc8_ = _loc13_ - _loc6_, _loc8_ < 0);
                           }
                           if(_loc8_ < 1)
                           {
                              break;
                           }
                           _loc13_ = li32(_loc7_ + 12);
                           var _temp_41:* = _loc13_ & -2;
                           _loc11_ = _loc7_;
                           _loc7_ = _temp_41;
                        }
                     }
                     _loc12_ = 0;
                     if(_loc11_ != _loc9_)
                     {
                        _loc12_ = _loc11_;
                     }
                     if(_loc12_ != 0)
                     {
                        var _temp_43:* = li32(_loc12_ + 20);
                        _loc13_ = (_loc6_ = li32(_loc12_ + 16)) + _temp_43;
                        if(_loc13_ == _loc14_)
                        {
                           _loc2_ -= 16;
                           si32(_loc12_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_szad_remove();
                           _loc2_ += 16;
                           _loc2_ -= 16;
                           si32(_loc12_,_loc2_ + 4);
                           si32(wdnative_nternal._dss_chunks_ad,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_ad_remove();
                           _loc2_ += 16;
                           _loc2_ -= 16;
                           si32(_loc10_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_szad_remove();
                           _loc2_ += 16;
                           _loc13_ = li32(_loc12_ + 16);
                           si32(_loc13_,_loc10_ + 16);
                           var _temp_50:* = li32(_loc10_ + 20);
                           _loc13_ = (_loc13_ = li32(_loc12_ + 20)) + _temp_50;
                           si32(_loc13_,_loc10_ + 20);
                           _loc2_ -= 16;
                           si32(_loc10_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_szad_insert();
                           _loc2_ += 16;
                           _loc13_ = li32(wdnative_nternal._base_nodes);
                           si32(_loc13_,_loc12_);
                           si32(_loc12_,wdnative_nternal._base_nodes);
                        }
                     }
                     _loc11_ = 0;
                     _loc9_ = 1;
                     if(_loc10_ != 0)
                     {
                        _loc1_ = li32(_loc10_ + 20);
                        _loc14_ = li32(_loc10_ + 16);
                        _loc9_ = 0;
                        _loc11_ = _loc10_;
                     }
                     break;
                  }
                  _loc10_ = int(ramGetLength());
                  if(_loc10_ == -1)
                  {
                     _loc2_ -= 16;
                     si32(_loc10_,_loc2_ + 8);
                     si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                     si32(wdnative_nternal.L__2E_str239,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_tprintf();
                     _loc2_ += 16;
                     si32(12,wdnative_nternal._errno);
                  }
                  si32(_loc10_,wdnative_nternal._dss_max);
                  _loc13_ = _loc14_ + _loc1_;
                  if(_loc13_ == _loc10_)
                  {
                     if(_loc1_ == 0)
                     {
                        _loc14_ = int(ramGetLength());
                     }
                     else
                     {
                        _loc13_ = 4095 - _loc1_;
                        var _temp_12:* = _loc13_ & -4096;
                        _loc14_ = int(sbrk(_temp_12,4096));
                     }
                     if(_loc14_ == -1)
                     {
                        _loc2_ -= 16;
                        si32(_loc14_,_loc2_ + 8);
                        si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                        si32(wdnative_nternal.L__2E_str239,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_tprintf();
                        _loc2_ += 16;
                        si32(12,wdnative_nternal._errno);
                     }
                     si32(_loc14_,wdnative_nternal._dss_prev);
                     _loc13_ = li32(wdnative_nternal._dss_max);
                     if(_loc14_ == _loc13_)
                     {
                        _loc13_ = _loc14_ - _loc1_;
                        si32(_loc13_,wdnative_nternal._dss_max);
                        if(_loc9_ == 0)
                        {
                           _loc2_ -= 16;
                           si32(_loc11_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_szad_remove();
                           _loc2_ += 16;
                           _loc2_ -= 16;
                           si32(_loc11_,_loc2_ + 4);
                           si32(wdnative_nternal._dss_chunks_ad,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_extent_tree_ad_remove();
                           _loc2_ += 16;
                           _loc13_ = li32(wdnative_nternal._base_nodes);
                           si32(_loc13_,_loc11_);
                           si32(_loc11_,wdnative_nternal._base_nodes);
                        }
                     }
                  }
                  break;
               }
            }
            _loc13_ = li8(wdnative_nternal._opt_mmap_2E_b);
            if(_loc13_ != 0)
            {
               break;
            }
            _loc2_ -= 16;
            si32(_loc1_,_loc2_ + 4);
            si32(_loc14_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_munmap();
            _loc2_ += 16;
            _loc13_ = wdnative.eax;
            if(_loc13_ != -1)
            {
               break;
            }
            var _temp_57:* = li32(wdnative_nternal._errno);
            _loc2_ -= 16;
            _loc1_ = _loc3_ - 64;
            si32(_loc1_,_loc2_ + 4);
            si32(_temp_57,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_strerror_r();
            _loc2_ += 16;
            _loc14_ = li32(wdnative_nternal.___progname);
            _loc9_ = _loc14_ & -4;
            _loc6_ = li32(_loc9_);
            var _temp_64:* = int(_loc6_ + -16843009);
            _loc13_ = (_loc6_ = (_loc6_ &= -2139062144) ^ -2139062144) & _temp_64;
            if(_loc13_ != 0)
            {
               _loc11_ = _loc9_ + 4;
               _loc10_ = 0;
               while(true)
               {
                  _loc12_ = _loc14_ + _loc10_;
                  if((uint(_loc12_)) < uint(_loc11_))
                  {
                     _loc13_ = li8(_loc12_);
                     if(_loc13_ == 0)
                     {
                        break;
                     }
                     _loc10_ += 1;
                     continue;
                  }
               }
               addr07a9:
               _loc2_ -= 16;
               si32(_loc10_,_loc2_ + 8);
               si32(_loc14_,_loc2_ + 4);
               si32(2,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___sys_write();
               _loc2_ += 16;
               _loc14_ = wdnative_nternal.L__2E_str39654 & -4;
               _loc6_ = li32(_loc14_);
               _loc13_ = _loc6_ + -16843009;
               _loc6_ &= -2139062144;
               _loc6_ = _loc6_ ^ -2139062144;
               _loc13_ = _loc6_ & _loc13_;
               _loc11_ = _loc14_ + 4;
               _loc10_ = 0;
               if(_loc13_ != 0)
               {
                  do
                  {
                     _loc13_ = wdnative_nternal.L__2E_str39654 + _loc10_;
                     _loc11_ = _loc14_ + 4;
                     if(uint(_loc13_) < uint(_loc11_))
                     {
                        continue;
                     }
                  }
                  while(_loc11_ = _loc14_ + 4, _loc9_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc11_))
                  {
                     _loc9_ = _loc11_;
                  }, _loc13_ = _loc9_ ^ -1, _loc11_ = wdnative_nternal.L__2E_str39654 + _loc13_, if((uint(_loc11_)) <= 4294967265)
                  {
                     _loc11_ = -31;
                  }, _loc11_ ^= -1, _loc10_ += 1, _loc10_ != 31);
                  addr0944:
                  _loc2_ -= 16;
                  si32(_loc11_,_loc2_ + 8);
                  si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc14_ = _loc1_ & -4;
                  _loc6_ = li32(_loc14_);
                  _loc13_ = _loc6_ + -16843009;
                  _loc6_ &= -2139062144;
                  _loc6_ = _loc6_ ^ -2139062144;
                  _loc13_ = _loc6_ & _loc13_;
                  if(_loc13_ != 0)
                  {
                     _loc10_ = _loc14_ + 4;
                     _loc9_ = 0;
                     while(true)
                     {
                        _loc11_ = _loc1_ + _loc9_;
                        if((uint(_loc11_)) < uint(_loc10_))
                        {
                           _loc13_ = li8(_loc11_);
                           if(_loc13_ == 0)
                           {
                              break;
                           }
                           _loc9_ += 1;
                           continue;
                        }
                     }
                     addr0a9e:
                     _loc2_ -= 16;
                     si32(_loc9_,_loc2_ + 8);
                     si32(_loc1_,_loc2_ + 4);
                     si32(2,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F___sys_write();
                     _loc2_ += 16;
                     _loc1_ = wdnative_nternal.L__2E_str5620 & -4;
                     _loc6_ = li32(_loc1_);
                     _loc13_ = _loc6_ + -16843009;
                     _loc6_ &= -2139062144;
                     _loc6_ = _loc6_ ^ -2139062144;
                     _loc13_ = _loc6_ & _loc13_;
                     _loc10_ = _loc1_ + 4;
                     _loc14_ = 0;
                     if(_loc13_ != 0)
                     {
                        do
                        {
                           _loc13_ = wdnative_nternal.L__2E_str5620 + _loc14_;
                           _loc10_ = _loc1_ + 4;
                           if(uint(_loc13_) < uint(_loc10_))
                           {
                              continue;
                           }
                        }
                        while(_loc11_ = _loc1_ + 4, _loc10_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc11_))
                        {
                           _loc10_ = _loc11_;
                        }, _loc13_ = _loc10_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str5620 + _loc13_, if(_loc10_ != -1)
                        {
                           _loc10_ = -2;
                        }, _loc10_ ^= -1, _loc14_ += 1, _loc14_ != 2);
                        addr0c30:
                        _loc2_ -= 16;
                        si32(_loc10_,_loc2_ + 8);
                        si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                        si32(2,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F___sys_write();
                        _loc2_ += 16;
                        _loc13_ = li8(wdnative_nternal._opt_abort_2E_b);
                        if(_loc13_ == 1)
                        {
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_abort();
                        }
                        break;
                     }
                     while(true)
                     {
                        _loc1_ = li32(_loc10_);
                        _loc13_ = _loc1_ + -16843009;
                        _loc6_ = _loc1_ & -2139062144;
                        _loc6_ = _loc6_ ^ -2139062144;
                        _loc13_ = _loc6_ & _loc13_;
                        if(_loc13_ != 0)
                        {
                           _loc13_ = _loc1_ & 0xFF;
                           if(_loc13_ == 0)
                           {
                              _loc10_ -= wdnative_nternal.L__2E_str5620;
                              break;
                           }
                           _loc13_ = li8(_loc10_ + 1);
                           if(_loc13_ == 0)
                           {
                              var _temp_99:* = int(1 - wdnative_nternal.L__2E_str5620);
                              _loc10_ += _temp_99;
                              break;
                           }
                           _loc13_ = li8(_loc10_ + 2);
                           if(_loc13_ == 0)
                           {
                              var _temp_101:* = int(2 - wdnative_nternal.L__2E_str5620);
                              _loc10_ += _temp_101;
                              break;
                           }
                           _loc13_ = li8(_loc10_ + 3);
                           if(_loc13_ == 0)
                           {
                              var _temp_103:* = int(3 - wdnative_nternal.L__2E_str5620);
                              _loc10_ += _temp_103;
                              break;
                           }
                        }
                        _loc10_ += 4;
                     }
                     §§goto(addr0c30);
                  }
                  _loc10_ = _loc14_ + 4;
                  while(true)
                  {
                     _loc14_ = li32(_loc10_);
                     _loc13_ = _loc14_ + -16843009;
                     _loc6_ = _loc14_ & -2139062144;
                     _loc6_ = _loc6_ ^ -2139062144;
                     _loc13_ = _loc6_ & _loc13_;
                     if(_loc13_ != 0)
                     {
                        _loc13_ = _loc14_ & 0xFF;
                        if(_loc13_ == 0)
                        {
                           _loc9_ = _loc10_ - _loc1_;
                           break;
                        }
                        _loc13_ = li8(_loc10_ + 1);
                        if(_loc13_ == 0)
                        {
                           _loc13_ = 1 - _loc1_;
                           _loc9_ = _loc13_ + _loc10_;
                           break;
                        }
                        _loc13_ = li8(_loc10_ + 2);
                        if(_loc13_ == 0)
                        {
                           _loc13_ = 2 - _loc1_;
                           _loc9_ = _loc13_ + _loc10_;
                           break;
                        }
                        _loc13_ = li8(_loc10_ + 3);
                        if(_loc13_ == 0)
                        {
                           _loc13_ = 3 - _loc1_;
                           _loc9_ = _loc13_ + _loc10_;
                           break;
                        }
                     }
                     _loc10_ += 4;
                  }
                  §§goto(addr0a9e);
               }
               while(true)
               {
                  _loc14_ = li32(_loc11_);
                  _loc13_ = _loc14_ + -16843009;
                  _loc6_ = _loc14_ & -2139062144;
                  _loc6_ = _loc6_ ^ -2139062144;
                  _loc13_ = _loc6_ & _loc13_;
                  if(_loc13_ != 0)
                  {
                     _loc13_ = _loc14_ & 0xFF;
                     if(_loc13_ == 0)
                     {
                        _loc11_ -= wdnative_nternal.L__2E_str39654;
                        break;
                     }
                     _loc13_ = li8(_loc11_ + 1);
                     if(_loc13_ == 0)
                     {
                        var _temp_121:* = int(1 - wdnative_nternal.L__2E_str39654);
                        _loc11_ += _temp_121;
                        break;
                     }
                     _loc13_ = li8(_loc11_ + 2);
                     if(_loc13_ == 0)
                     {
                        var _temp_123:* = int(2 - wdnative_nternal.L__2E_str39654);
                        _loc11_ += _temp_123;
                        break;
                     }
                     _loc13_ = li8(_loc11_ + 3);
                     if(_loc13_ == 0)
                     {
                        var _temp_125:* = int(3 - wdnative_nternal.L__2E_str39654);
                        _loc11_ += _temp_125;
                        break;
                     }
                  }
                  _loc11_ += 4;
               }
               §§goto(addr0944);
            }
            _loc10_ = _loc9_ + 4;
            while(true)
            {
               _loc11_ = li32(_loc10_);
               _loc13_ = _loc11_ + -16843009;
               _loc6_ = _loc11_ & -2139062144;
               _loc6_ = _loc6_ ^ -2139062144;
               _loc13_ = _loc6_ & _loc13_;
               if(_loc13_ != 0)
               {
                  _loc13_ = _loc11_ & 0xFF;
                  if(_loc13_ == 0)
                  {
                     _loc10_ -= _loc14_;
                     break;
                  }
                  _loc13_ = li8(_loc10_ + 1);
                  if(_loc13_ == 0)
                  {
                     _loc13_ = 1 - _loc14_;
                     _loc10_ = _loc13_ + _loc10_;
                     break;
                  }
                  _loc13_ = li8(_loc10_ + 2);
                  if(_loc13_ == 0)
                  {
                     _loc13_ = 2 - _loc14_;
                     _loc10_ = _loc13_ + _loc10_;
                     break;
                  }
                  _loc13_ = li8(_loc10_ + 3);
                  if(_loc13_ == 0)
                  {
                     _loc13_ = 3 - _loc14_;
                     _loc10_ = _loc13_ + _loc10_;
                     break;
                  }
               }
               _loc10_ += 4;
            }
            §§goto(addr07a9);
         }
      }
      else
      {
         _loc13_ = li8(wdnative_nternal._opt_mmap_2E_b);
         if(_loc13_ == 0)
         {
            §§goto(addr0615);
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

