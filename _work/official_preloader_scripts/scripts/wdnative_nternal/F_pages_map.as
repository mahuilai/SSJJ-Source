package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_pages_map() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 64;
      _loc2_ -= 32;
      si32(-1,_loc2_ + 16);
      si32(4098,_loc2_ + 12);
      si32(3,_loc2_ + 8);
      _loc1_ = li32(_loc3_ + 4);
      si32(_loc1_,_loc2_ + 4);
      _loc10_ = li32(_loc3_);
      si32(_loc10_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_mmap();
      _loc9_ = 0;
      _loc2_ += 32;
      _loc8_ = wdnative.eax;
      if(_loc8_ != -1)
      {
         _loc9_ = _loc8_;
         if(_loc10_ != 0)
         {
            _loc9_ = _loc8_;
            if(_loc8_ != _loc10_)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_ + 4);
               si32(_loc8_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_munmap();
               _loc9_ = 0;
               _loc2_ += 16;
               var _loc7_:int = wdnative.eax;
               if(_loc7_ == -1)
               {
                  var _temp_8:* = li32(wdnative_nternal._errno);
                  _loc2_ -= 16;
                  _loc8_ = _loc3_ - 64;
                  si32(_loc8_,_loc2_ + 4);
                  si32(_temp_8,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_strerror_r();
                  _loc2_ += 16;
                  _loc9_ = li32(wdnative_nternal.___progname);
                  _loc6_ = _loc9_ & -4;
                  var _loc5_:int = li32(_loc6_);
                  var _temp_15:* = int(_loc5_ + -16843009);
                  _loc7_ = (_loc5_ = (_loc5_ &= -2139062144) ^ -2139062144) & _temp_15;
                  if(_loc7_ != 0)
                  {
                     _loc4_ = _loc6_ + 4;
                     _loc10_ = 0;
                     while(true)
                     {
                        _loc1_ = _loc9_ + _loc10_;
                        if(uint(_loc1_) < uint(_loc4_))
                        {
                           _loc7_ = li8(_loc1_);
                           if(_loc7_ == 0)
                           {
                              break;
                           }
                           _loc10_ += 1;
                           continue;
                        }
                     }
                     §§goto(addr022e);
                  }
                  _loc10_ = _loc6_ + 4;
                  while(true)
                  {
                     _loc1_ = li32(_loc10_);
                     _loc7_ = _loc1_ + -16843009;
                     _loc5_ = _loc1_ & -2139062144;
                     _loc5_ = _loc5_ ^ -2139062144;
                     _loc7_ = _loc5_ & _loc7_;
                     if(_loc7_ != 0)
                     {
                        _loc7_ = _loc1_ & 0xFF;
                        if(_loc7_ == 0)
                        {
                           _loc10_ -= _loc9_;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 1);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 1 - _loc9_;
                           _loc10_ = _loc7_ + _loc10_;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 2);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 2 - _loc9_;
                           _loc10_ = _loc7_ + _loc10_;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 3);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 3 - _loc9_;
                           _loc10_ = _loc7_ + _loc10_;
                           break;
                        }
                     }
                     _loc10_ += 4;
                  }
                  addr022e:
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_ + 8);
                  si32(_loc9_,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc9_ = wdnative_nternal.L__2E_str39654 & -4;
                  _loc5_ = li32(_loc9_);
                  _loc7_ = _loc5_ + -16843009;
                  _loc5_ &= -2139062144;
                  _loc5_ = _loc5_ ^ -2139062144;
                  _loc7_ = _loc5_ & _loc7_;
                  _loc1_ = _loc9_ + 4;
                  _loc10_ = 0;
                  if(_loc7_ != 0)
                  {
                     do
                     {
                        _loc7_ = wdnative_nternal.L__2E_str39654 + _loc10_;
                        _loc1_ = _loc9_ + 4;
                        if(uint(_loc7_) < uint(_loc1_))
                        {
                           continue;
                        }
                     }
                     while(_loc1_ = _loc9_ + 4, _loc4_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc1_))
                     {
                        _loc4_ = _loc1_;
                     }, _loc7_ = _loc4_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str39654 + _loc7_, if(uint(_loc1_) <= 4294967265)
                     {
                        _loc1_ = -31;
                     }, _loc1_ ^= -1, _loc10_ += 1, _loc10_ != 31);
                     §§goto(addr03b1);
                  }
                  while(true)
                  {
                     _loc9_ = li32(_loc1_);
                     _loc7_ = _loc9_ + -16843009;
                     _loc5_ = _loc9_ & -2139062144;
                     _loc5_ = _loc5_ ^ -2139062144;
                     _loc7_ = _loc5_ & _loc7_;
                     if(_loc7_ != 0)
                     {
                        _loc7_ = _loc9_ & 0xFF;
                        if(_loc7_ == 0)
                        {
                           _loc1_ -= wdnative_nternal.L__2E_str39654;
                           break;
                        }
                        _loc7_ = li8(_loc1_ + 1);
                        if(_loc7_ == 0)
                        {
                           var _temp_73:* = int(1 - wdnative_nternal.L__2E_str39654);
                           _loc1_ += _temp_73;
                           break;
                        }
                        _loc7_ = li8(_loc1_ + 2);
                        if(_loc7_ == 0)
                        {
                           var _temp_75:* = int(2 - wdnative_nternal.L__2E_str39654);
                           _loc1_ += _temp_75;
                           break;
                        }
                        _loc7_ = li8(_loc1_ + 3);
                        if(_loc7_ == 0)
                        {
                           var _temp_77:* = int(3 - wdnative_nternal.L__2E_str39654);
                           _loc1_ += _temp_77;
                           break;
                        }
                     }
                     _loc1_ += 4;
                  }
                  addr03b1:
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_ + 8);
                  si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc1_ = _loc8_ & -4;
                  _loc5_ = li32(_loc1_);
                  _loc7_ = _loc5_ + -16843009;
                  _loc5_ &= -2139062144;
                  _loc5_ = _loc5_ ^ -2139062144;
                  _loc7_ = _loc5_ & _loc7_;
                  if(_loc7_ != 0)
                  {
                     _loc10_ = _loc1_ + 4;
                     _loc4_ = 0;
                     while(true)
                     {
                        _loc9_ = _loc8_ + _loc4_;
                        if((uint(_loc9_)) < uint(_loc10_))
                        {
                           _loc7_ = li8(_loc9_);
                           if(_loc7_ == 0)
                           {
                              break;
                           }
                           _loc4_ += 1;
                           continue;
                        }
                     }
                     §§goto(addr050d);
                  }
                  _loc9_ = _loc1_ + 4;
                  while(true)
                  {
                     _loc10_ = li32(_loc9_);
                     _loc7_ = _loc10_ + -16843009;
                     _loc5_ = _loc10_ & -2139062144;
                     _loc5_ = _loc5_ ^ -2139062144;
                     _loc7_ = _loc5_ & _loc7_;
                     if(_loc7_ != 0)
                     {
                        _loc7_ = _loc10_ & 0xFF;
                        if(_loc7_ == 0)
                        {
                           _loc4_ = _loc9_ - _loc8_;
                           break;
                        }
                        _loc7_ = li8(_loc9_ + 1);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 1 - _loc8_;
                           _loc4_ = _loc7_ + _loc9_;
                           break;
                        }
                        _loc7_ = li8(_loc9_ + 2);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 2 - _loc8_;
                           _loc4_ = _loc7_ + _loc9_;
                           break;
                        }
                        _loc7_ = li8(_loc9_ + 3);
                        if(_loc7_ == 0)
                        {
                           _loc7_ = 3 - _loc8_;
                           _loc4_ = _loc7_ + _loc9_;
                           break;
                        }
                     }
                     _loc9_ += 4;
                  }
                  addr050d:
                  _loc2_ -= 16;
                  si32(_loc4_,_loc2_ + 8);
                  si32(_loc8_,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc8_ = wdnative_nternal.L__2E_str5620 & -4;
                  _loc5_ = li32(_loc8_);
                  _loc7_ = _loc5_ + -16843009;
                  _loc5_ &= -2139062144;
                  _loc5_ = _loc5_ ^ -2139062144;
                  _loc7_ = _loc5_ & _loc7_;
                  _loc10_ = _loc8_ + 4;
                  _loc9_ = 0;
                  if(_loc7_ != 0)
                  {
                     do
                     {
                        _loc7_ = wdnative_nternal.L__2E_str5620 + _loc9_;
                        _loc10_ = _loc8_ + 4;
                        if(uint(_loc7_) < uint(_loc10_))
                        {
                           continue;
                        }
                     }
                     while(_loc10_ = _loc8_ + 4, _loc1_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc10_))
                     {
                        _loc1_ = _loc10_;
                     }, _loc7_ = _loc1_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str5620 + _loc7_, if(_loc10_ != -1)
                     {
                        _loc10_ = -2;
                     }, _loc10_ ^= -1, _loc9_ += 1, _loc9_ != 2);
                     §§goto(addr06a4);
                  }
                  while(true)
                  {
                     _loc8_ = li32(_loc10_);
                     _loc7_ = _loc8_ + -16843009;
                     _loc5_ = _loc8_ & -2139062144;
                     _loc5_ = _loc5_ ^ -2139062144;
                     _loc7_ = _loc5_ & _loc7_;
                     if(_loc7_ != 0)
                     {
                        _loc7_ = _loc8_ & 0xFF;
                        if(_loc7_ == 0)
                        {
                           _loc10_ -= wdnative_nternal.L__2E_str5620;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 1);
                        if(_loc7_ == 0)
                        {
                           var _temp_51:* = int(1 - wdnative_nternal.L__2E_str5620);
                           _loc10_ += _temp_51;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 2);
                        if(_loc7_ == 0)
                        {
                           var _temp_53:* = int(2 - wdnative_nternal.L__2E_str5620);
                           _loc10_ += _temp_53;
                           break;
                        }
                        _loc7_ = li8(_loc10_ + 3);
                        if(_loc7_ == 0)
                        {
                           var _temp_55:* = int(3 - wdnative_nternal.L__2E_str5620);
                           _loc10_ += _temp_55;
                           break;
                        }
                     }
                     _loc10_ += 4;
                  }
                  addr06a4:
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_ + 8);
                  si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                  si32(2,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___sys_write();
                  _loc2_ += 16;
                  _loc9_ = 0;
                  _loc7_ = li8(wdnative_nternal._opt_abort_2E_b);
                  if(_loc7_ == 1)
                  {
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_abort();
                  }
                  §§goto(addr06f4);
               }
            }
         }
      }
      addr06f4:
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

