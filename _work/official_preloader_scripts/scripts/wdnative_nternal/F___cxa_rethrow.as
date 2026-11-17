package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_RaiseException;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.ptr2fun;
   import wdnative.setjmp;
   
   public function F___cxa_rethrow() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc12_:int = 0;
      var _loc17_:int = 0;
      var _loc35_:int = 0;
      var _loc31_:int = 0;
      var _loc14_:int = 0;
      var _loc22_:int = 0;
      var _loc23_:int = 0;
      var _loc19_:int = 0;
      var _loc21_:int = 0;
      var _loc20_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc24_:int = 0;
      var _loc30_:int = 0;
      var _loc32_:int = 0;
      var _loc34_:int = 0;
      var _loc40_:int = 0;
      var _loc39_:int = 0;
      var _loc36_:int = 0;
      var _loc29_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc41_:int = 0;
      var _loc33_:int = 0;
      var _loc1_:int = 0;
      var _loc28_:int = 0;
      var _loc38_:int = 0;
      var _loc37_:int = 0;
      var _loc27_:int = 0;
      var _loc25_:int = 0;
      var _loc18_:int = 0;
      var _loc15_:int = 0;
      var _loc13_:int = 0;
      var _loc16_:int = 0;
      var _loc2_:int = 0;
      var _loc6_:int = 0;
      var _loc26_:int = 0;
      var _loc3_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc12_)
            {
               _loc7_ = _loc3_;
               _loc3_ -= 64;
               _loc17_ = li8(wdnative_nternal.__ZL4init + 4);
               si32(wdnative_nternal.L_LSDA_348,_loc7_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc7_ - 32);
               _loc41_ = _loc7_;
               si32(_loc41_,_loc7_ - 24);
               _loc41_ = _loc3_;
               si32(_loc41_,_loc7_ - 16);
               _loc40_ = _loc7_ - 56;
               _loc39_ = _loc40_ + 32;
               wdnative.eax = setjmp(_loc39_,1,_loc3_);
            }
            else
            {
               switch(_loc12_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc41_ = wdnative.eax;
            if(_loc41_ == 0)
            {
               _loc3_ -= 16;
               si32(_loc40_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__Unwind_SjLj_Register();
               _loc3_ += 16;
               _loc41_ = _loc17_ & 0xFF;
               _loc37_ = wdnative_nternal.__ZL10eh_globals;
               if(_loc41_ != 0)
               {
                  while(true)
                  {
                     _loc35_ = li32(wdnative_nternal.__ZL4init);
                     if(_loc35_ >= 0)
                     {
                        _loc41_ = li32(wdnative_nternal._sEntryCount);
                        if(_loc41_ > _loc35_)
                        {
                           _loc41_ = _loc35_ << 3;
                           _loc33_ = li32(wdnative_nternal._sEntries);
                           _loc41_ = _loc33_ + _loc41_;
                           _loc37_ = li32(_loc41_);
                           if(_loc37_ != 0)
                           {
                              break;
                           }
                        }
                     }
                     _loc3_ -= 16;
                     si32(8,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative.F_malloc();
                     _loc3_ += 16;
                     _loc37_ = wdnative.eax;
                     if(_loc37_ != 0)
                     {
                        _loc31_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc31_ >= 0)
                        {
                           _loc41_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc41_ > _loc31_)
                           {
                              _loc41_ = _loc31_ << 3;
                              _loc33_ = li32(wdnative_nternal._sEntries);
                              _loc41_ = _loc33_ + _loc41_;
                              si32(_loc37_,_loc41_);
                              si32(0,_loc37_);
                              si32(0,_loc37_ + 4);
                              break;
                           }
                        }
                     }
                     _loc41_ = _loc40_ | 4;
                     si32(1,_loc41_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F__ZSt9terminatev();
                     _loc41_ = li32(_loc7_ - 48);
                     _loc29_ = li32(_loc7_ - 44);
                     _loc3_ -= 16;
                     si32(_loc41_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc3_ += 16;
                     break;
                  }
               }
               while(true)
               {
                  _loc14_ = li32(_loc37_);
                  _loc41_ = li32(_loc37_ + 4);
                  _loc41_ = _loc41_ + 1;
                  si32(_loc41_,_loc37_ + 4);
                  if(_loc14_ != 0)
                  {
                     _loc41_ = li32(_loc14_ + 52);
                     _loc41_ = _loc41_ ^ 0x474E5543;
                     _loc33_ = li32(_loc14_ + 48);
                     _loc33_ = _loc33_ ^ 0x432B2B00;
                     _loc41_ = _loc33_ | _loc41_;
                     if(_loc41_ != 0)
                     {
                        si32(0,_loc37_);
                     }
                     else
                     {
                        _loc41_ = li32(_loc14_ + 20);
                        _loc41_ = 0 - _loc41_;
                        si32(_loc41_,_loc14_ + 20);
                     }
                     _loc22_ = _loc14_ + 48;
                     _loc41_ = li32(_loc14_ + 60);
                     if(_loc41_ != 0)
                     {
                        while(true)
                        {
                           _loc23_ = li32(wdnative_nternal._use_fc_key);
                           if(_loc23_ <= -1)
                           {
                              _loc41_ = li32(wdnative_nternal._once_2E_2506);
                              if(_loc41_ == 0)
                              {
                                 _loc25_ = li32(wdnative_nternal._sFirstFree);
                                 if(_loc25_ <= -1)
                                 {
                                    _loc25_ = li32(wdnative_nternal._sEntryCount);
                                    _loc33_ = _loc25_ + 1;
                                    _loc41_ = li32(wdnative_nternal._sEntries);
                                    si32(_loc33_,wdnative_nternal._sEntryCount);
                                    _loc3_ -= 16;
                                    _loc33_ <<= 3;
                                    si32(_loc33_,_loc3_ + 4);
                                    si32(_loc41_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc27_ = wdnative.eax;
                                    si32(_loc27_,wdnative_nternal._sEntries);
                                 }
                                 else
                                 {
                                    _loc41_ = _loc25_ << 3;
                                    _loc27_ = li32(wdnative_nternal._sEntries);
                                    _loc41_ = _loc27_ + _loc41_;
                                    _loc41_ = li32(_loc41_ + 4);
                                    si32(_loc41_,wdnative_nternal._sFirstFree);
                                 }
                                 _loc41_ = _loc25_ << 3;
                                 _loc41_ = _loc27_ + _loc41_;
                                 si32(0,_loc41_);
                                 si32(0,_loc41_ + 4);
                                 si32(_loc25_,wdnative_nternal._fc_key);
                                 si32(1,wdnative_nternal._use_fc_key);
                                 si32(1,wdnative_nternal._once_2E_2506);
                                 addr03c1:
                                 _loc18_ = 0;
                                 _loc19_ = li32(wdnative_nternal._fc_key);
                                 if(_loc19_ >= 0)
                                 {
                                    _loc41_ = li32(wdnative_nternal._sEntryCount);
                                    if(_loc41_ > _loc19_)
                                    {
                                       _loc41_ = _loc19_ << 3;
                                       _loc33_ = li32(wdnative_nternal._sEntries);
                                       _loc41_ = _loc33_ + _loc41_;
                                       _loc18_ = li32(_loc41_);
                                    }
                                 }
                                 break;
                              }
                              si32(0,wdnative_nternal._use_fc_key);
                           }
                           else if(_loc23_ != 0)
                           {
                              §§goto(addr03c1);
                           }
                           _loc18_ = li32(wdnative_nternal._fc_static);
                           break;
                        }
                        si32(_loc18_,_loc7_ - 64);
                        _loc20_ = li32(_loc14_ + 64);
                        _loc21_ = li32(_loc14_ + 60);
                        while(true)
                        {
                           _loc16_ = 26;
                           _loc15_ = 1;
                           _loc13_ = 0;
                           if(_loc18_ != 0)
                           {
                              _loc13_ = li32(_loc18_ + 24);
                              _loc15_ = 0;
                              _loc16_ = 10;
                           }
                           _loc41_ = li32(_loc14_ + 48);
                           _loc33_ = li32(_loc14_ + 52);
                           _loc10_ = _loc40_ | 4;
                           si32(-1,_loc10_);
                           _loc3_ -= 32;
                           si32(_loc20_,_loc3_ + 24);
                           _loc11_ = _loc7_ - 64;
                           si32(_loc11_,_loc3_ + 20);
                           si32(_loc22_,_loc3_ + 16);
                           si32(_loc33_,_loc3_ + 12);
                           si32(_loc41_,_loc3_ + 8);
                           si32(_loc16_,_loc3_ + 4);
                           si32(1,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.ptr2fun[_loc21_]();
                           _loc3_ += 32;
                           _loc41_ = wdnative.eax;
                           if(_loc41_ == 0)
                           {
                              if(_loc15_ == 0)
                              {
                                 if(_loc13_ != 0)
                                 {
                                    _loc41_ = li32(_loc14_ + 48);
                                    _loc33_ = li32(_loc14_ + 52);
                                    si32(-1,_loc10_);
                                    _loc3_ -= 32;
                                    si32(_loc11_,_loc3_ + 20);
                                    si32(_loc22_,_loc3_ + 16);
                                    si32(_loc33_,_loc3_ + 12);
                                    si32(_loc41_,_loc3_ + 8);
                                    si32(10,_loc3_ + 4);
                                    si32(1,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative.ptr2fun[_loc13_]();
                                    _loc3_ += 32;
                                    _loc8_ = wdnative.eax;
                                    if(_loc8_ == 7)
                                    {
                                       break;
                                    }
                                    if(_loc8_ != 8)
                                    {
                                       addr0693:
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_abort();
                                       break;
                                    }
                                 }
                                 _loc41_ = li32(_loc7_ - 64);
                                 _loc9_ = li32(_loc41_);
                                 _loc5_ = li32(wdnative_nternal._use_fc_key);
                                 if(_loc5_ <= -1)
                                 {
                                    _loc41_ = li32(wdnative_nternal._once_2E_2506);
                                    if(_loc41_ == 0)
                                    {
                                       _loc6_ = li32(wdnative_nternal._sFirstFree);
                                       if(_loc6_ <= -1)
                                       {
                                          _loc6_ = li32(wdnative_nternal._sEntryCount);
                                          _loc33_ = _loc6_ + 1;
                                          _loc41_ = li32(wdnative_nternal._sEntries);
                                          si32(_loc33_,wdnative_nternal._sEntryCount);
                                          _loc3_ -= 16;
                                          _loc33_ <<= 3;
                                          si32(_loc33_,_loc3_ + 4);
                                          si32(_loc41_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc2_ = wdnative.eax;
                                          si32(_loc2_,wdnative_nternal._sEntries);
                                       }
                                       else
                                       {
                                          _loc41_ = _loc6_ << 3;
                                          _loc2_ = li32(wdnative_nternal._sEntries);
                                          _loc41_ = _loc2_ + _loc41_;
                                          _loc41_ = li32(_loc41_ + 4);
                                          si32(_loc41_,wdnative_nternal._sFirstFree);
                                       }
                                       _loc41_ = _loc6_ << 3;
                                       _loc41_ = _loc2_ + _loc41_;
                                       si32(0,_loc41_);
                                       si32(0,_loc41_ + 4);
                                       si32(_loc6_,wdnative_nternal._fc_key);
                                       si32(1,wdnative_nternal._use_fc_key);
                                       si32(1,wdnative_nternal._once_2E_2506);
                                       addr063a:
                                       _loc4_ = li32(wdnative_nternal._fc_key);
                                       if(_loc4_ >= 0)
                                       {
                                          _loc41_ = li32(wdnative_nternal._sEntryCount);
                                          if(_loc41_ > _loc4_)
                                          {
                                             _loc33_ = _loc4_ << 3;
                                             _loc41_ = li32(wdnative_nternal._sEntries);
                                             _loc41_ = _loc41_ + _loc33_;
                                             si32(_loc9_,_loc41_);
                                          }
                                       }
                                       continue;
                                    }
                                    si32(0,wdnative_nternal._use_fc_key);
                                 }
                                 else if(_loc5_ != 0)
                                 {
                                    §§goto(addr063a);
                                 }
                                 si32(_loc9_,wdnative_nternal._fc_static);
                                 continue;
                              }
                           }
                           §§goto(addr0693);
                           _loc41_ = li32(_loc7_ - 64);
                           _loc18_ = li32(_loc41_);
                           si32(_loc18_,_loc7_ - 64);
                        }
                        _loc3_ -= 16;
                        si32(_loc11_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_uw_install_context();
                        _loc3_ += 16;
                     }
                     _loc1_ = _loc40_ | 4;
                     si32(-1,_loc1_);
                     _loc3_ -= 16;
                     si32(_loc22_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative.F__Unwind_SjLj_RaiseException();
                     _loc3_ += 16;
                     _loc26_ = wdnative_nternal.__ZL10eh_globals;
                     _loc41_ = li8(wdnative_nternal.__ZL4init + 4);
                     if(_loc41_ != 0)
                     {
                        while(true)
                        {
                           _loc24_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc24_ >= 0)
                           {
                              _loc41_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc41_ > _loc24_)
                              {
                                 _loc33_ = _loc24_ << 3;
                                 _loc41_ = li32(wdnative_nternal._sEntries);
                                 _loc41_ = _loc41_ + _loc33_;
                                 _loc26_ = li32(_loc41_);
                                 if(_loc26_ != 0)
                                 {
                                    break;
                                 }
                              }
                           }
                           _loc3_ -= 16;
                           si32(8,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.F_malloc();
                           _loc3_ += 16;
                           _loc26_ = wdnative.eax;
                           if(_loc26_ != 0)
                           {
                              _loc30_ = li32(wdnative_nternal.__ZL4init);
                              if(_loc30_ >= 0)
                              {
                                 _loc41_ = li32(wdnative_nternal._sEntryCount);
                                 if(_loc41_ > _loc30_)
                                 {
                                    _loc41_ = _loc30_ << 3;
                                    _loc33_ = li32(wdnative_nternal._sEntries);
                                    _loc41_ = _loc33_ + _loc41_;
                                    si32(_loc26_,_loc41_);
                                    si32(0,_loc26_);
                                    si32(0,_loc26_ + 4);
                                    break;
                                 }
                              }
                           }
                           si32(2,_loc1_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F__ZSt9terminatev();
                           _loc41_ = li32(_loc7_ - 48);
                           _loc28_ = li32(_loc7_ - 44);
                           _loc3_ -= 16;
                           si32(_loc41_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___cxa_call_unexpected();
                           _loc3_ += 16;
                           break;
                        }
                     }
                     while(true)
                     {
                        _loc41_ = li32(_loc14_ + 52);
                        _loc41_ = _loc41_ ^ 0x474E5543;
                        _loc33_ = li32(_loc14_ + 48);
                        _loc33_ = _loc33_ ^ 0x432B2B00;
                        _loc41_ = _loc33_ | _loc41_;
                        _loc34_ = _loc22_ + -48;
                        _loc32_ = li32(_loc26_);
                        if(_loc41_ != 0)
                        {
                           if(_loc32_ != 0)
                           {
                              si32(3,_loc1_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZSt9terminatev();
                           }
                           si32(_loc34_,_loc26_);
                        }
                        else
                        {
                           _loc33_ = li32(_loc22_ - 28);
                           _loc41_ = _loc33_ >> 31;
                           _loc33_ += _loc41_;
                           _loc41_ = _loc33_ ^ _loc41_;
                           _loc41_ = _loc41_ + 1;
                           si32(_loc41_,_loc22_ - 28);
                           _loc41_ = li32(_loc26_ + 4);
                           _loc41_ = _loc41_ + -1;
                           si32(_loc41_,_loc26_ + 4);
                           if(_loc34_ != _loc32_)
                           {
                              si32(_loc32_,_loc22_ - 32);
                              si32(_loc34_,_loc26_);
                           }
                        }
                        _loc41_ = li32(_loc7_ - 48);
                        _loc28_ = li32(_loc7_ - 44);
                        _loc3_ -= 16;
                        si32(_loc41_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc3_ += 16;
                     }
                     break;
                  }
                  addr08eb:
                  while(true)
                  {
                     _loc41_ = _loc40_ | 4;
                     si32(-1,_loc41_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F__ZSt9terminatev();
                     _loc41_ = li32(_loc7_ - 48);
                     _loc38_ = li32(_loc7_ - 44);
                     _loc3_ -= 16;
                     si32(_loc41_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc3_ += 16;
                  }
                  break;
                  _loc41_ = li32(_loc7_ - 48);
                  _loc29_ = li32(_loc7_ - 44);
                  _loc3_ -= 16;
                  si32(_loc41_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___cxa_call_unexpected();
                  _loc3_ += 16;
               }
               §§goto(addr0968);
            }
            _loc41_ = _loc40_ | 4;
            _loc36_ = li32(_loc41_);
            if(_loc36_ != 0)
            {
               if(_loc36_ != 1)
               {
                  if(_loc36_ == 2)
                  {
                     _loc41_ = li32(_loc7_ - 48);
                     _loc38_ = li32(_loc7_ - 44);
                     _loc3_ -= 16;
                     si32(_loc41_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc3_ += 16;
                     §§goto(addr08eb);
                  }
                  while(true)
                  {
                  }
               }
               §§goto(addr07ca);
            }
            §§goto(addr021f);
         }
         catch(l:LongJmp)
         {
            var _temp_99:* = this;
            var _temp_100:* = l;
            if(l.esp < _loc7_)
            {
               continue;
            }
         }
         addr0968:
         throw l;
         wdnative.ESP = _loc3_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc12_ = int(l.sjid);
      }
   }
}

