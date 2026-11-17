package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.ptr2fun;
   import wdnative.setjmp;
   
   public function F___cxa_call_unexpected() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc7_:int = 0;
      var _loc14_:int = 0;
      var _loc21_:int = 0;
      var _loc30_:int = 0;
      var _loc26_:int = 0;
      var _loc71_:int = 0;
      var _loc70_:int = 0;
      var _loc54_:int = 0;
      var _loc69_:int = 0;
      var _loc61_:int = 0;
      var _loc48_:int = 0;
      var _loc44_:int = 0;
      var _loc22_:int = 0;
      var _loc25_:int = 0;
      var _loc31_:int = 0;
      var _loc33_:int = 0;
      var _loc5_:int = 0;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc62_:int = 0;
      var _loc66_:int = 0;
      var _loc79_:int = 0;
      var _loc78_:int = 0;
      var _loc49_:int = 0;
      var _loc74_:int = 0;
      var _loc45_:int = 0;
      var _loc68_:int = 0;
      var _loc59_:int = 0;
      var _loc58_:int = 0;
      var _loc57_:int = 0;
      var _loc56_:int = 0;
      var _loc15_:int = 0;
      var _loc36_:int = 0;
      var _loc34_:int = 0;
      var _loc18_:int = 0;
      var _loc24_:int = 0;
      var _loc72_:int = 0;
      var _loc73_:int = 0;
      var _loc77_:int = 0;
      var _loc75_:int = 0;
      var _loc47_:int = 0;
      var _loc38_:int = 0;
      var _loc28_:int = 0;
      var _loc63_:int = 0;
      var _loc42_:int = 0;
      var _loc40_:int = 0;
      var _loc23_:int = 0;
      var _loc27_:int = 0;
      var _loc35_:int = 0;
      var _loc39_:int = 0;
      var _loc37_:int = 0;
      var _loc4_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc43_:int = 0;
      var _loc16_:int = 0;
      var _loc19_:int = 0;
      var _loc20_:int = 0;
      var _loc17_:int = 0;
      var _loc32_:int = 0;
      var _loc65_:int = 0;
      var _loc67_:int = 0;
      var _loc52_:int = 0;
      var _loc53_:int = 0;
      var _loc46_:int = 0;
      var _loc50_:int = 0;
      var _loc60_:int = 0;
      var _loc51_:int = 0;
      var _loc29_:int = 0;
      var _loc8_:int = 0;
      var _loc64_:int = 0;
      var _loc76_:int = 0;
      var _loc41_:int = 0;
      var _loc55_:int = 0;
      var _loc1_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc7_)
            {
               _loc2_ = _loc1_;
               _loc1_ -= 112;
               _loc21_ = li8(wdnative_nternal.__ZL4init + 4);
               si32(wdnative_nternal.L_LSDA_343,_loc2_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc2_ - 32);
               _loc38_ = _loc2_;
               si32(_loc38_,_loc2_ - 24);
               _loc38_ = _loc1_;
               si32(_loc38_,_loc2_ - 16);
               _loc36_ = _loc2_ - 56;
               _loc34_ = _loc36_ + 32;
               wdnative.eax = setjmp(_loc34_,1,_loc1_);
            }
            else
            {
               switch(_loc7_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc38_ = wdnative.eax;
            if(_loc38_ == 0)
            {
               _loc1_ -= 16;
               si32(_loc36_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative.F__Unwind_SjLj_Register();
               _loc1_ += 16;
               _loc38_ = _loc21_ & 0xFF;
               _loc32_ = wdnative_nternal.__ZL10eh_globals;
               if(_loc38_ != 0)
               {
                  while(true)
                  {
                     _loc30_ = li32(wdnative_nternal.__ZL4init);
                     if(_loc30_ >= 0)
                     {
                        _loc38_ = li32(wdnative_nternal._sEntryCount);
                        if(_loc38_ > _loc30_)
                        {
                           _loc38_ = _loc30_ << 3;
                           _loc28_ = li32(wdnative_nternal._sEntries);
                           _loc38_ = _loc28_ + _loc38_;
                           _loc32_ = li32(_loc38_);
                           if(_loc32_ != 0)
                           {
                              break;
                           }
                        }
                     }
                     _loc1_ -= 16;
                     si32(8,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative.F_malloc();
                     _loc1_ += 16;
                     _loc32_ = wdnative.eax;
                     if(_loc32_ != 0)
                     {
                        _loc26_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc26_ >= 0)
                        {
                           _loc38_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc38_ > _loc26_)
                           {
                              _loc38_ = _loc26_ << 3;
                              _loc28_ = li32(wdnative_nternal._sEntries);
                              _loc38_ = _loc28_ + _loc38_;
                              si32(_loc32_,_loc38_);
                              si32(0,_loc32_);
                              si32(0,_loc32_ + 4);
                              break;
                           }
                        }
                     }
                     _loc38_ = _loc36_ | 4;
                     si32(1,_loc38_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F__ZSt9terminatev();
                     addr02b0:
                     _loc38_ = li32(_loc2_ - 48);
                     _loc24_ = li32(_loc2_ - 44);
                     _loc1_ -= 16;
                     si32(_loc38_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc1_ += 16;
                     break;
                  }
               }
               _loc14_ = li32(_loc2_);
               _loc38_ = li32(_loc14_ + 4);
               _loc38_ = _loc38_ ^ 0x474E5543;
               _loc28_ = li32(_loc14_);
               _loc28_ = _loc28_ ^ 0x432B2B00;
               _loc38_ = _loc28_ | _loc38_;
               _loc70_ = _loc14_ + -48;
               _loc71_ = li32(_loc32_);
               if(_loc38_ != 0)
               {
                  if(_loc71_ != 0)
                  {
                     _loc38_ = _loc36_ | 4;
                     si32(2,_loc38_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F__ZSt9terminatev();
                  }
                  si32(_loc70_,_loc32_);
               }
               else
               {
                  _loc28_ = li32(_loc14_ - 28);
                  _loc38_ = _loc28_ >> 31;
                  _loc28_ += _loc38_;
                  _loc38_ = _loc28_ ^ _loc38_;
                  _loc38_ = _loc38_ + 1;
                  si32(_loc38_,_loc14_ - 28);
                  _loc38_ = li32(_loc32_ + 4);
                  _loc38_ = _loc38_ + -1;
                  si32(_loc38_,_loc32_ + 4);
                  if(_loc70_ != _loc71_)
                  {
                     si32(_loc71_,_loc14_ - 32);
                     si32(_loc70_,_loc32_);
                  }
               }
               addr03d5:
               _loc38_ = li32(_loc14_ - 16);
               si32(_loc38_,_loc2_ - 72);
               _loc38_ = li32(_loc14_ - 24);
               si32(_loc38_,_loc2_ - 68);
               _loc38_ = li32(_loc14_ - 36);
               si32(_loc38_,_loc2_ - 64);
               _loc38_ = li32(_loc14_ - 12);
               _loc28_ = _loc2_ - 112;
               _loc28_ = _loc28_ + 8;
               si32(_loc28_,_loc2_ - 60);
               _loc28_ = li32(_loc2_ - 60);
               si32(_loc38_,_loc28_);
               _loc73_ = li32(_loc14_ - 40);
               _loc38_ = _loc36_ | 4;
               si32(3,_loc38_);
               _loc1_ -= 16;
               si32(_loc73_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F__ZN10__cxxabiv112__unexpectedEPFvvE();
               _loc1_ += 16;
               while(true)
               {
                  _loc63_ = li32(_loc65_);
                  _loc28_ = li32(_loc2_ - 72);
                  _loc1_ -= 16;
                  _loc38_ = _loc2_ - 112;
                  si32(_loc38_,_loc1_ + 8);
                  si32(_loc28_,_loc1_ + 4);
                  _loc67_ = 0;
                  si32(_loc67_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F__ZL17parse_lsda_headerP15_Unwind_ContextPKhP16lsda_header_info();
                  _loc1_ += 16;
                  _loc69_ = li32(_loc63_);
                  _loc61_ = li32(_loc2_ - 100);
                  _loc38_ = li32(_loc2_ - 68);
                  _loc38_ = _loc38_ ^ -1;
                  _loc60_ = _loc61_ + _loc38_;
                  _loc54_ = _loc63_ + 80;
                  _loc52_ = _loc60_;
                  _loc53_ = _loc67_;
                  while(true)
                  {
                     _loc38_ = si8(li8(_loc52_));
                     _loc28_ = _loc38_ & 0x7F;
                     _loc28_ = _loc28_ << _loc67_;
                     _loc53_ = _loc28_ | _loc53_;
                     _loc67_ += 7;
                     _loc52_ += 1;
                     if(_loc38_ >= 0)
                     {
                        _loc51_ = _loc50_ = 0;
                        if(_loc53_ == 0)
                        {
                           break;
                        }
                        _loc46_ = 0;
                        _loc48_ = li8(_loc2_ - 92);
                        if(_loc48_ != 255)
                        {
                           _loc42_ = _loc48_ & 7;
                           if(_loc42_ <= 2)
                           {
                              _loc46_ = 4;
                              if(_loc42_ != 0)
                              {
                                 if(_loc42_ != 2)
                                 {
                                    addr057c:
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F_abort();
                                 }
                                 else
                                 {
                                    _loc46_ = 2;
                                 }
                              }
                           }
                           else
                           {
                              _loc46_ = 4;
                              if(_loc42_ != 3)
                              {
                                 if(_loc42_ != 4)
                                 {
                                    §§goto(addr057c);
                                 }
                                 else
                                 {
                                    _loc46_ = 8;
                                 }
                              }
                           }
                        }
                        _loc38_ = li32(_loc2_ - 60);
                        _loc28_ = li32(_loc38_);
                        _loc1_ -= 16;
                        _loc38_ = _loc2_ - 88;
                        si32(_loc38_,_loc1_ + 12);
                        si32(_loc28_,_loc1_ + 4);
                        si32(_loc48_,_loc1_);
                        _loc38_ = 0 - _loc53_;
                        _loc38_ = _loc46_ * _loc38_;
                        _loc38_ = _loc61_ + _loc38_;
                        si32(_loc38_,_loc1_ + 8);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZL28read_encoded_value_with_basehjPKhPj();
                        _loc1_ += 16;
                        _loc44_ = li32(_loc2_ - 88);
                        si32(_loc54_,_loc2_ - 80);
                        _loc38_ = li32(_loc69_);
                        _loc40_ = li32(_loc38_ + 8);
                        _loc23_ = _loc36_ | 4;
                        si32(4,_loc23_);
                        _loc1_ -= 16;
                        si32(_loc69_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative.ptr2fun[_loc40_]();
                        _loc1_ += 16;
                        _loc22_ = wdnative.eax;
                        if(_loc22_ != 0)
                        {
                           _loc38_ = li32(_loc2_ - 80);
                           _loc38_ = li32(_loc38_);
                           si32(_loc38_,_loc2_ - 80);
                        }
                        _loc38_ = li32(_loc44_);
                        _loc27_ = li32(_loc38_ + 16);
                        si32(5,_loc23_);
                        _loc1_ -= 16;
                        si32(1,_loc1_ + 12);
                        _loc38_ = _loc2_ - 80;
                        si32(_loc38_,_loc1_ + 8);
                        si32(_loc69_,_loc1_ + 4);
                        si32(_loc44_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative.ptr2fun[_loc27_]();
                        _loc1_ += 16;
                        _loc25_ = wdnative.eax;
                        _loc53_ = _loc67_ = 0;
                        if(_loc25_ != 0)
                        {
                           si32(6,_loc23_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F___cxa_rethrow();
                           break;
                        }
                     }
                  }
                  while(true)
                  {
                     _loc38_ = si8(li8(_loc60_));
                     _loc28_ = _loc38_ & 0x7F;
                     _loc28_ = _loc28_ << _loc50_;
                     _loc51_ = _loc28_ | _loc51_;
                     _loc50_ += 7;
                     _loc60_ += 1;
                     if(_loc38_ >= 0)
                     {
                        if(_loc51_ == 0)
                        {
                           break;
                        }
                        _loc31_ = li8(_loc2_ - 92);
                        _loc29_ = 0;
                        if(_loc31_ != 255)
                        {
                           _loc35_ = _loc31_ & 7;
                           _loc29_ = 4;
                           if(_loc35_ <= 2)
                           {
                              if(_loc35_ != 0)
                              {
                                 if(_loc35_ != 2)
                                 {
                                    addr077a:
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F_abort();
                                 }
                                 else
                                 {
                                    _loc29_ = 2;
                                 }
                              }
                           }
                           else if(_loc35_ != 3)
                           {
                              if(_loc35_ != 4)
                              {
                                 §§goto(addr077a);
                              }
                              else
                              {
                                 _loc29_ = 8;
                              }
                           }
                        }
                        _loc38_ = li32(_loc2_ - 60);
                        _loc38_ = li32(_loc38_);
                        _loc1_ -= 16;
                        _loc28_ = _loc2_ - 84;
                        si32(_loc28_,_loc1_ + 12);
                        si32(_loc38_,_loc1_ + 4);
                        si32(_loc31_,_loc1_);
                        _loc38_ = 0 - _loc51_;
                        _loc38_ = _loc29_ * _loc38_;
                        _loc38_ = _loc61_ + _loc38_;
                        si32(_loc38_,_loc1_ + 8);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZL28read_encoded_value_with_basehjPKhPj();
                        _loc1_ += 16;
                        _loc33_ = li32(_loc2_ - 84);
                        si32(0,_loc2_ - 76);
                        _loc38_ = li32(wdnative_nternal.__ZTISt13bad_exception);
                        _loc39_ = li32(_loc38_ + 8);
                        _loc37_ = _loc36_ | 4;
                        si32(7,_loc37_);
                        _loc1_ -= 16;
                        si32(wdnative_nternal.__ZTISt13bad_exception,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative.ptr2fun[_loc39_]();
                        _loc1_ += 16;
                        _loc5_ = wdnative.eax;
                        if(_loc5_ != 0)
                        {
                           _loc38_ = li32(_loc2_ - 76);
                           _loc38_ = li32(_loc38_);
                           si32(_loc38_,_loc2_ - 76);
                        }
                        _loc38_ = li32(_loc33_);
                        _loc4_ = li32(_loc38_ + 16);
                        si32(8,_loc37_);
                        _loc1_ -= 16;
                        si32(1,_loc1_ + 12);
                        _loc38_ = _loc2_ - 76;
                        si32(_loc38_,_loc1_ + 8);
                        si32(wdnative_nternal.__ZTISt13bad_exception,_loc1_ + 4);
                        si32(_loc33_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative.ptr2fun[_loc4_]();
                        _loc1_ += 16;
                        _loc3_ = wdnative.eax;
                        _loc51_ = _loc50_ = 0;
                        if(_loc3_ != 0)
                        {
                           _loc1_ -= 16;
                           si32(4,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F___cxa_allocate_exception();
                           _loc38_ = wdnative_nternal.__ZTVSt13bad_exception + 8;
                           _loc1_ += 16;
                           _loc10_ = wdnative.eax;
                           si32(_loc38_,_loc10_);
                           si32(9,_loc37_);
                           _loc1_ -= 16;
                           si32(wdnative_nternal.__ZNSt13bad_exceptionD1Ev,_loc1_ + 8);
                           si32(wdnative_nternal.__ZTISt13bad_exception,_loc1_ + 4);
                           si32(_loc10_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F___cxa_throw();
                           _loc1_ += 16;
                           break;
                        }
                     }
                  }
                  _loc38_ = _loc36_ | 4;
                  _loc9_ = li32(_loc2_ - 64);
                  si32(10,_loc38_);
                  _loc1_ -= 16;
                  si32(_loc9_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F__ZN10__cxxabiv111__terminateEPFvvE();
                  _loc1_ += 16;
                  addr0961:
                  _loc8_ = wdnative_nternal.__ZL10eh_globals;
                  _loc38_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc38_ != 0)
                  {
                     _loc8_ = 0;
                     _loc6_ = li32(wdnative_nternal.__ZL4init);
                     if(_loc6_ >= 0)
                     {
                        _loc38_ = li32(wdnative_nternal._sEntryCount);
                        if(_loc38_ > _loc6_)
                        {
                           _loc38_ = _loc6_ << 3;
                           _loc28_ = li32(wdnative_nternal._sEntries);
                           _loc38_ = _loc28_ + _loc38_;
                           _loc8_ = li32(_loc38_);
                        }
                     }
                  }
                  _loc13_ = li32(_loc8_);
                  if(_loc13_ != 0)
                  {
                     _loc38_ = li32(_loc13_ + 52);
                     _loc38_ = _loc38_ ^ 0x474E5543;
                     _loc28_ = li32(_loc13_ + 48);
                     _loc28_ = _loc28_ ^ 0x432B2B00;
                     _loc38_ = _loc28_ | _loc38_;
                     if(_loc38_ != 0)
                     {
                        si32(0,_loc8_);
                        _loc12_ = li32(_loc13_ + 56);
                        if(_loc12_ != 0)
                        {
                           _loc38_ = _loc36_ | 4;
                           si32(11,_loc38_);
                           _loc1_ -= 16;
                           _loc38_ = _loc13_ + 48;
                           si32(_loc38_,_loc1_ + 4);
                           si32(1,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative.ptr2fun[_loc12_]();
                           _loc1_ += 16;
                        }
                     }
                     else
                     {
                        while(true)
                        {
                           _loc11_ = li32(_loc13_ + 20);
                           if(_loc11_ <= -1)
                           {
                              _loc64_ = _loc11_ + 1;
                              if(_loc64_ == 0)
                              {
                                 _loc38_ = li32(_loc13_ + 16);
                                 si32(_loc38_,_loc8_);
                                 _loc64_ = 0;
                              }
                           }
                           else
                           {
                              _loc64_ = _loc11_ + -1;
                              if(_loc64_ == 0)
                              {
                                 _loc38_ = li32(_loc13_ + 16);
                                 si32(_loc38_,_loc8_);
                                 _loc62_ = li32(_loc13_ + 56);
                                 if(_loc62_ != 0)
                                 {
                                    _loc38_ = _loc36_ | 4;
                                    si32(12,_loc38_);
                                    _loc1_ -= 16;
                                    _loc38_ = _loc13_ + 48;
                                    si32(_loc38_,_loc1_ + 4);
                                    si32(1,_loc1_);
                                    wdnative.ESP = _loc1_;
                                    wdnative.ptr2fun[_loc62_]();
                                    _loc1_ += 16;
                                 }
                                 break;
                              }
                              if(_loc64_ <= -1)
                              {
                                 _loc38_ = _loc36_ | 4;
                                 si32(13,_loc38_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F__ZSt9terminatev();
                              }
                           }
                           si32(_loc64_,_loc13_ + 20);
                           break;
                        }
                     }
                  }
                  _loc38_ = _loc36_ | 4;
                  si32(-1,_loc38_);
                  _loc1_ -= 16;
                  si32(_loc68_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative.F__Unwind_SjLj_Resume();
                  addr0b49:
                  _loc1_ += 16;
                  _loc66_ = li32(_loc2_ - 48);
                  _loc77_ = li32(_loc2_ - 44);
                  _loc76_ = wdnative_nternal.__ZL10eh_globals;
                  _loc38_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc38_ != 0)
                  {
                     while(true)
                     {
                        _loc79_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc79_ >= 0)
                        {
                           _loc38_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc38_ > _loc79_)
                           {
                              _loc38_ = _loc79_ << 3;
                              _loc28_ = li32(wdnative_nternal._sEntries);
                              _loc38_ = _loc28_ + _loc38_;
                              _loc76_ = li32(_loc38_);
                              if(_loc76_ != 0)
                              {
                                 break;
                              }
                           }
                        }
                        _loc1_ -= 16;
                        si32(8,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative.F_malloc();
                        _loc1_ += 16;
                        _loc76_ = wdnative.eax;
                        if(_loc76_ != 0)
                        {
                           _loc78_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc78_ >= 0)
                           {
                              _loc38_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc38_ > _loc78_)
                              {
                                 _loc38_ = _loc78_ << 3;
                                 _loc28_ = li32(wdnative_nternal._sEntries);
                                 _loc38_ = _loc28_ + _loc38_;
                                 si32(_loc76_,_loc38_);
                                 si32(0,_loc76_);
                                 si32(0,_loc76_ + 4);
                                 break;
                              }
                           }
                        }
                        _loc38_ = _loc36_ | 4;
                        si32(14,_loc38_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                        addr0c3e:
                        _loc38_ = li32(_loc2_ - 48);
                        _loc75_ = li32(_loc2_ - 44);
                        _loc1_ -= 16;
                        si32(_loc38_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc1_ += 16;
                        break;
                     }
                  }
                  _loc38_ = li32(_loc66_ + 4);
                  _loc38_ = _loc38_ ^ 0x474E5543;
                  _loc28_ = li32(_loc66_);
                  _loc28_ = _loc28_ ^ 0x432B2B00;
                  _loc38_ = _loc28_ | _loc38_;
                  _loc74_ = _loc66_ + -48;
                  _loc49_ = li32(_loc76_);
                  if(_loc38_ != 0)
                  {
                     if(_loc49_ != 0)
                     {
                        _loc38_ = _loc36_ | 4;
                        si32(15,_loc38_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                     }
                     si32(_loc74_,_loc76_);
                  }
                  else
                  {
                     _loc28_ = li32(_loc66_ - 28);
                     _loc38_ = _loc28_ >> 31;
                     _loc28_ += _loc38_;
                     _loc38_ = _loc28_ ^ _loc38_;
                     _loc38_ = _loc38_ + 1;
                     si32(_loc38_,_loc66_ - 28);
                     _loc38_ = li32(_loc76_ + 4);
                     _loc38_ = _loc38_ + -1;
                     si32(_loc38_,_loc76_ + 4);
                     if(_loc74_ != _loc49_)
                     {
                        si32(_loc49_,_loc66_ - 32);
                        si32(_loc74_,_loc76_);
                     }
                  }
               }
               addr1093:
               throw l;
               addr045e:
            }
            else
            {
               while(true)
               {
                  _loc38_ = _loc36_ | 4;
                  _loc18_ = li32(_loc38_);
                  if(_loc18_ <= 9)
                  {
                     if(_loc18_ <= 1)
                     {
                        if(_loc18_ != 0)
                        {
                           if(_loc18_ != 1)
                           {
                              break;
                           }
                           _loc38_ = li32(_loc2_ - 48);
                           _loc72_ = li32(_loc2_ - 44);
                           _loc1_ -= 16;
                           si32(_loc38_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F___cxa_call_unexpected();
                           _loc1_ += 16;
                        }
                        else
                        {
                           §§goto(addr02b0);
                        }
                        §§goto(addr03d5);
                     }
                     else if(_loc18_ != 2)
                     {
                        _loc38_ = _loc18_ + -3;
                        if((uint(_loc38_)) >= 7)
                        {
                           break;
                        }
                        _loc68_ = li32(_loc2_ - 48);
                        _loc43_ = li32(_loc2_ - 44);
                        _loc41_ = wdnative_nternal.__ZL10eh_globals;
                        _loc38_ = li8(wdnative_nternal.__ZL4init + 4);
                        if(_loc38_ != 0)
                        {
                           _loc59_ = li32(wdnative_nternal.__ZL4init);
                           _loc41_ = 0;
                           if(_loc59_ >= 0)
                           {
                              _loc38_ = li32(wdnative_nternal._sEntryCount);
                              _loc41_ = 0;
                              if(_loc38_ > _loc59_)
                              {
                                 _loc28_ = _loc59_ << 3;
                                 _loc38_ = li32(wdnative_nternal._sEntries);
                                 _loc38_ = _loc38_ + _loc28_;
                                 _loc41_ = li32(_loc38_);
                              }
                           }
                        }
                        _loc58_ = li32(_loc41_);
                        if(_loc58_ != 0)
                        {
                           _loc38_ = li32(_loc58_ + 52);
                           _loc38_ = _loc38_ ^ 0x474E5543;
                           _loc28_ = li32(_loc58_ + 48);
                           _loc28_ = _loc28_ ^ 0x432B2B00;
                           _loc38_ = _loc28_ | _loc38_;
                           if(_loc38_ != 0)
                           {
                              si32(0,_loc41_);
                              _loc57_ = li32(_loc58_ + 56);
                              if(_loc57_ != 0)
                              {
                                 _loc38_ = _loc36_ | 4;
                                 si32(16,_loc38_);
                                 _loc1_ -= 16;
                                 _loc38_ = _loc58_ + 48;
                                 si32(_loc38_,_loc1_ + 4);
                                 si32(1,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative.ptr2fun[_loc57_]();
                                 _loc1_ += 16;
                              }
                           }
                           else
                           {
                              while(true)
                              {
                                 _loc56_ = li32(_loc58_ + 20);
                                 if(_loc56_ <= -1)
                                 {
                                    _loc55_ = _loc56_ + 1;
                                    if(_loc55_ == 0)
                                    {
                                       _loc38_ = li32(_loc58_ + 16);
                                       si32(_loc38_,_loc41_);
                                       _loc55_ = 0;
                                    }
                                 }
                                 else
                                 {
                                    _loc55_ = _loc56_ + -1;
                                    if(_loc55_ == 0)
                                    {
                                       _loc38_ = li32(_loc58_ + 16);
                                       si32(_loc38_,_loc41_);
                                       _loc15_ = li32(_loc58_ + 56);
                                       if(_loc15_ != 0)
                                       {
                                          _loc38_ = _loc36_ | 4;
                                          si32(17,_loc38_);
                                          _loc1_ -= 16;
                                          _loc38_ = _loc58_ + 48;
                                          si32(_loc38_,_loc1_ + 4);
                                          si32(1,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.ptr2fun[_loc15_]();
                                          _loc1_ += 16;
                                       }
                                       break;
                                    }
                                    if(_loc55_ <= -1)
                                    {
                                       _loc38_ = _loc36_ | 4;
                                       si32(18,_loc38_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F__ZSt9terminatev();
                                    }
                                 }
                                 si32(_loc55_,_loc58_ + 20);
                                 break;
                              }
                           }
                        }
                        §§goto(addr0961);
                     }
                     §§goto(addr0b49);
                  }
                  else if(_loc18_ <= 13)
                  {
                     _loc38_ = _loc18_ + -10;
                     if((uint(_loc38_)) < 3)
                     {
                        continue;
                     }
                     if(_loc18_ != 13)
                     {
                        break;
                     }
                     §§goto(addr0c3e);
                  }
                  else
                  {
                     if(_loc18_ != 14)
                     {
                        _loc38_ = _loc18_ + -15;
                        if((uint(_loc38_)) >= 3)
                        {
                           break;
                        }
                        _loc16_ = li32(_loc2_ - 48);
                        _loc19_ = li32(_loc2_ - 44);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                        continue;
                     }
                     _loc38_ = li32(_loc2_ - 48);
                     _loc47_ = li32(_loc2_ - 44);
                     _loc1_ -= 16;
                     si32(_loc38_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc1_ += 16;
                  }
                  _loc20_ = li32(_loc2_ - 48);
                  _loc17_ = li32(_loc2_ - 44);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F__ZSt9terminatev();
               }
               while(true)
               {
               }
            }
            _loc65_ = wdnative_nternal.__ZL10eh_globals;
            _loc38_ = li8(wdnative_nternal.__ZL4init + 4);
            if(_loc38_ != 0)
            {
               _loc65_ = 0;
               _loc45_ = li32(wdnative_nternal.__ZL4init);
               if(_loc45_ >= 0)
               {
                  _loc38_ = li32(wdnative_nternal._sEntryCount);
                  if(_loc38_ > _loc45_)
                  {
                     _loc38_ = _loc45_ << 3;
                     _loc28_ = li32(wdnative_nternal._sEntries);
                     _loc38_ = _loc28_ + _loc38_;
                     _loc65_ = li32(_loc38_);
                  }
               }
            }
            §§goto(addr045e);
         }
         catch(l:LongJmp)
         {
            var _temp_167:* = this;
            var _temp_168:* = l;
            if(l.esp < _loc2_)
            {
               continue;
            }
         }
         §§goto(addr1093);
         wdnative.ESP = _loc1_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc7_ = int(l.sjid);
      }
   }
}

