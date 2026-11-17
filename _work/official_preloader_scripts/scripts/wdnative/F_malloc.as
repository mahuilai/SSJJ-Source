package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___sys_write;
   import wdnative_nternal.F_abort;
   import wdnative_nternal.F_arena_malloc;
   import wdnative_nternal.F_base_pages_alloc;
   import wdnative_nternal.F_chunk_alloc;
   import wdnative_nternal.F_extent_tree_ad_insert;
   import wdnative_nternal.F_malloc_init;
   import wdnative_nternal.L__2E_str2617;
   import wdnative_nternal.L__2E_str49664;
   import wdnative_nternal.___progname;
   import wdnative_nternal._arena_maxclass;
   import wdnative_nternal._arenas;
   import wdnative_nternal._base_next_addr;
   import wdnative_nternal._base_nodes;
   import wdnative_nternal._base_past_addr;
   import wdnative_nternal._chunksize_mask;
   import wdnative_nternal._errno;
   import wdnative_nternal._huge;
   import wdnative_nternal._opt_junk_2E_b;
   import wdnative_nternal._opt_sysv_2E_b;
   import wdnative_nternal._opt_xmalloc_2E_b;
   import wdnative_nternal._opt_zero_2E_b;
   
   public function F_malloc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_malloc_init();
      _loc1_ = wdnative.eax;
      loop6:
      while(true)
      {
         if(_loc1_ == 0)
         {
            while(true)
            {
               _loc9_ = li32(_loc3_);
               if(_loc9_ == 0)
               {
                  _loc9_ = 1;
                  if(li8(wdnative_nternal._opt_sysv_2E_b) != 0)
                  {
                     break;
                  }
               }
               _loc1_ = li32(wdnative_nternal._arena_maxclass);
               if(uint(_loc1_) >= uint(_loc9_))
               {
                  var _temp_4:* = li32(li32(wdnative_nternal._arenas));
                  _loc2_ -= 16;
                  si32(0,_loc2_ + 8);
                  si32(_loc9_,_loc2_ + 4);
                  si32(_temp_4,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_arena_malloc();
                  _loc2_ += 16;
                  _loc9_ = wdnative.eax;
               }
               else
               {
                  var _loc8_:int = li32(wdnative_nternal._chunksize_mask);
                  _loc7_ = int(_loc8_ + _loc9_) & (_loc8_ ^ -1);
                  if(_loc7_ == 0)
                  {
                     break;
                  }
                  _loc6_ = li32(wdnative_nternal._base_nodes);
                  if(_loc6_ != 0)
                  {
                     si32(li32(_loc6_),wdnative_nternal._base_nodes);
                  }
                  else
                  {
                     _loc6_ = li32(wdnative_nternal._base_next_addr);
                     var _temp_10:* = int(_loc6_ + 64);
                     _loc8_ = li32(wdnative_nternal._base_past_addr);
                     if(uint(_temp_10) > uint(_loc8_))
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
                        _loc6_ = li32(wdnative_nternal._base_next_addr);
                     }
                     _loc1_ = _loc6_ + 64;
                     si32(_loc1_,wdnative_nternal._base_next_addr);
                     if(_loc6_ == 0)
                     {
                        break;
                     }
                  }
                  _loc2_ -= 16;
                  si32(0,_loc2_ + 4);
                  si32(_loc7_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_chunk_alloc();
                  _loc2_ += 16;
                  _loc9_ = wdnative.eax;
                  if(_loc9_ == 0)
                  {
                     si32(li32(wdnative_nternal._base_nodes),_loc6_);
                     si32(_loc6_,wdnative_nternal._base_nodes);
                     break;
                  }
                  si32(_loc9_,_loc6_ + 16);
                  si32(_loc7_,_loc6_ + 20);
                  _loc2_ -= 16;
                  si32(_loc6_,_loc2_ + 4);
                  si32(wdnative_nternal._huge,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_extent_tree_ad_insert();
                  _loc2_ += 16;
                  if(li8(wdnative_nternal._opt_junk_2E_b) == 1)
                  {
                     _loc2_ -= 16;
                     si32(_loc7_,_loc2_ + 8);
                     si32(165,_loc2_ + 4);
                     si32(_loc9_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.Fmemset();
                     _loc2_ += 16;
                     break loop6;
                  }
                  if(li8(wdnative_nternal._opt_zero_2E_b) == 1)
                  {
                     _loc2_ -= 16;
                     si32(_loc7_,_loc2_ + 8);
                     si32(0,_loc2_ + 4);
                     si32(_loc9_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.Fmemset();
                     _loc2_ += 16;
                  }
               }
               if(_loc9_ == 0)
               {
                  break;
               }
               break loop6;
            }
         }
         _loc1_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
         if(_loc1_ == 1)
         {
            _loc9_ = li32(wdnative_nternal.___progname);
            _loc5_ = _loc9_ & -4;
            _loc8_ = li32(_loc5_);
            var _temp_22:* = int(_loc8_ + -16843009);
            if(((_loc8_ = (_loc8_ &= -2139062144) ^ -2139062144) & _temp_22) != 0)
            {
               _loc6_ = _loc5_ + 4;
               _loc4_ = 0;
               while(true)
               {
                  _loc7_ = _loc9_ + _loc4_;
                  if((uint(_loc7_)) < uint(_loc6_))
                  {
                     if(li8(_loc7_) == 0)
                     {
                        break;
                     }
                     _loc4_ += 1;
                     continue;
                  }
               }
               addr035a:
               _loc2_ -= 16;
               si32(_loc4_,_loc2_ + 8);
               si32(_loc9_,_loc2_ + 4);
               si32(2,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___sys_write();
               _loc2_ += 16;
               _loc9_ = wdnative_nternal.L__2E_str49664 & -4;
               _loc8_ = li32(_loc9_);
               _loc1_ = _loc8_ + -16843009;
               _loc8_ &= -2139062144;
               _loc8_ = _loc8_ ^ -2139062144;
               _loc1_ = _loc8_ & _loc1_;
               _loc6_ = _loc9_ + 4;
               _loc7_ = 0;
               if(_loc1_ != 0)
               {
                  do
                  {
                     _loc1_ = wdnative_nternal.L__2E_str49664 + _loc7_;
                     _loc6_ = _loc9_ + 4;
                     if(uint(_loc1_) < uint(_loc6_))
                     {
                        continue;
                     }
                  }
                  while(_loc5_ = _loc9_ + 4, _loc6_ = wdnative_nternal.L__2E_str49664, if(uint(wdnative_nternal.L__2E_str49664) <= uint(_loc5_))
                  {
                     _loc6_ = _loc5_;
                  }, _loc1_ = _loc6_ ^ -1, _loc6_ = wdnative_nternal.L__2E_str49664 + _loc1_, if((uint(_loc6_)) <= 4294967251)
                  {
                     _loc6_ = -45;
                  }, _loc6_ ^= -1, _loc7_ += 1, _loc7_ != 45);
                  addr04de:
                  _loc2_ -= 16;
                  si32(_loc6_,_loc2_ + 8);
                  si32(wdnative_nternal.L__2E_str49664,_loc2_ + 4);
                  si32(2,_loc2_);
                  _loc9_ = wdnative_nternal.L__2E_str2617 & -4;
                  _loc6_ = _loc9_ + 4;
                  _loc7_ = 0;
                  _loc5_ = 1;
                  if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc6_))
                  {
                     _loc5_ = _loc7_;
                  }
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc8_ = li32(_loc9_);
                  _loc1_ = _loc8_ + -16843009;
                  _loc8_ &= -2139062144;
                  _loc8_ = _loc8_ ^ -2139062144;
                  _loc1_ = _loc8_ & _loc1_;
                  loop8:
                  while(true)
                  {
                     if(_loc1_ != 0)
                     {
                        var _temp_36:* = _loc5_ & 1;
                        _loc5_ = _loc7_;
                        if(_temp_36 == 0)
                        {
                           break;
                        }
                     }
                     while(true)
                     {
                        _loc5_ = li32(_loc6_);
                        _loc1_ = _loc5_ + -16843009;
                        _loc8_ = _loc5_ & -2139062144;
                        _loc8_ = _loc8_ ^ -2139062144;
                        _loc1_ = _loc8_ & _loc1_;
                        if(_loc1_ != 0)
                        {
                           if((_loc5_ & 0xFF) == 0)
                           {
                              _loc5_ = _loc6_ - wdnative_nternal.L__2E_str2617;
                              break loop8;
                           }
                           if(li8(_loc6_ + 1) == 0)
                           {
                              var _temp_40:* = int(1 - wdnative_nternal.L__2E_str2617);
                              _loc5_ = _loc6_ + _temp_40;
                              break loop8;
                           }
                           if(li8(_loc6_ + 2) == 0)
                           {
                              var _temp_41:* = int(2 - wdnative_nternal.L__2E_str2617);
                              _loc5_ = _loc6_ + _temp_41;
                              break loop8;
                           }
                           if(li8(_loc6_ + 3) == 0)
                           {
                              var _temp_42:* = int(3 - wdnative_nternal.L__2E_str2617);
                              _loc5_ = _loc6_ + _temp_42;
                              break loop8;
                           }
                        }
                        _loc6_ += 4;
                     }
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc5_,_loc2_ + 8);
                  si32(2,_loc2_);
                  si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                  _loc6_ = _loc9_ + 4;
                  _loc5_ = 1;
                  if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc6_))
                  {
                     _loc5_ = _loc7_;
                  }
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc8_ = li32(_loc9_);
                  _loc1_ = _loc8_ + -16843009;
                  _loc8_ &= -2139062144;
                  _loc8_ = _loc8_ ^ -2139062144;
                  _loc1_ = _loc8_ & _loc1_;
                  loop9:
                  while(true)
                  {
                     if(_loc1_ != 0)
                     {
                        if((_loc5_ & 1) == 0)
                        {
                           break;
                        }
                     }
                     while(true)
                     {
                        _loc9_ = li32(_loc6_);
                        _loc1_ = _loc9_ + -16843009;
                        _loc8_ = _loc9_ & -2139062144;
                        _loc8_ = _loc8_ ^ -2139062144;
                        _loc1_ = _loc8_ & _loc1_;
                        if(_loc1_ != 0)
                        {
                           if((_loc9_ & 0xFF) == 0)
                           {
                              _loc7_ = _loc6_ - wdnative_nternal.L__2E_str2617;
                              break loop9;
                           }
                           if(li8(_loc6_ + 1) == 0)
                           {
                              var _temp_50:* = int(1 - wdnative_nternal.L__2E_str2617);
                              _loc7_ = _loc6_ + _temp_50;
                              break loop9;
                           }
                           if(li8(_loc6_ + 2) == 0)
                           {
                              var _temp_51:* = int(2 - wdnative_nternal.L__2E_str2617);
                              _loc7_ = _loc6_ + _temp_51;
                              break loop9;
                           }
                           if(li8(_loc6_ + 3) == 0)
                           {
                              var _temp_52:* = int(3 - wdnative_nternal.L__2E_str2617);
                              _loc7_ = _loc6_ + _temp_52;
                              break loop9;
                           }
                        }
                        _loc6_ += 4;
                     }
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc7_,_loc2_ + 8);
                  si32(wdnative_nternal.L__2E_str2617,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_abort();
                  addr0783:
                  si32(12,wdnative_nternal._errno);
                  _loc9_ = 0;
                  break;
               }
               while(true)
               {
                  _loc9_ = li32(_loc6_);
                  _loc1_ = _loc9_ + -16843009;
                  _loc8_ = _loc9_ & -2139062144;
                  _loc8_ = _loc8_ ^ -2139062144;
                  _loc1_ = _loc8_ & _loc1_;
                  if(_loc1_ != 0)
                  {
                     if((_loc9_ & 0xFF) == 0)
                     {
                        _loc6_ -= wdnative_nternal.L__2E_str49664;
                        break;
                     }
                     if(li8(_loc6_ + 1) == 0)
                     {
                        var _temp_58:* = int(1 - wdnative_nternal.L__2E_str49664);
                        _loc6_ += _temp_58;
                        break;
                     }
                     if(li8(_loc6_ + 2) == 0)
                     {
                        var _temp_59:* = int(2 - wdnative_nternal.L__2E_str49664);
                        _loc6_ += _temp_59;
                        break;
                     }
                     if(li8(_loc6_ + 3) == 0)
                     {
                        var _temp_60:* = int(3 - wdnative_nternal.L__2E_str49664);
                        _loc6_ += _temp_60;
                        break;
                     }
                  }
                  _loc6_ += 4;
               }
               §§goto(addr04de);
            }
            _loc6_ = _loc5_ + 4;
            while(true)
            {
               _loc7_ = li32(_loc6_);
               _loc1_ = _loc7_ + -16843009;
               _loc8_ = _loc7_ & -2139062144;
               _loc8_ = _loc8_ ^ -2139062144;
               _loc1_ = _loc8_ & _loc1_;
               if(_loc1_ != 0)
               {
                  if((_loc7_ & 0xFF) == 0)
                  {
                     _loc4_ = _loc6_ - _loc9_;
                     break;
                  }
                  if(li8(_loc6_ + 1) == 0)
                  {
                     _loc4_ = int(1 - _loc9_) + _loc6_;
                     break;
                  }
                  if(li8(_loc6_ + 2) == 0)
                  {
                     _loc4_ = int(2 - _loc9_) + _loc6_;
                     break;
                  }
                  if(li8(_loc6_ + 3) == 0)
                  {
                     _loc4_ = int(3 - _loc9_) + _loc6_;
                     break;
                  }
               }
               _loc6_ += 4;
            }
            §§goto(addr035a);
         }
         §§goto(addr0783);
      }
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

