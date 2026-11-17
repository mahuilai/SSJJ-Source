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
   
   public function F__ZN9__gnu_cxx27__verbose_terminate_handlerEv() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc7_:int = 0;
      var _loc15_:int = 0;
      var _loc18_:int = 0;
      var _loc14_:int = 0;
      var _loc56_:int = 0;
      var _loc57_:int = 0;
      var _loc58_:int = 0;
      var _loc46_:int = 0;
      var _loc45_:int = 0;
      var _loc42_:int = 0;
      var _loc43_:int = 0;
      var _loc40_:int = 0;
      var _loc37_:int = 0;
      var _loc38_:int = 0;
      var _loc36_:int = 0;
      var _loc34_:int = 0;
      var _loc17_:int = 0;
      var _loc23_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc47_:int = 0;
      var _loc53_:int = 0;
      var _loc61_:int = 0;
      var _loc62_:int = 0;
      var _loc27_:int = 0;
      var _loc30_:int = 0;
      var _loc28_:int = 0;
      var _loc26_:int = 0;
      var _loc39_:int = 0;
      var _loc55_:int = 0;
      var _loc52_:int = 0;
      var _loc54_:int = 0;
      var _loc16_:int = 0;
      var _loc41_:int = 0;
      var _loc32_:int = 0;
      var _loc24_:int = 0;
      var _loc21_:int = 0;
      var _loc51_:int = 0;
      var _loc64_:int = 0;
      var _loc19_:int = 0;
      var _loc25_:int = 0;
      var _loc63_:int = 0;
      var _loc29_:int = 0;
      var _loc60_:int = 0;
      var _loc59_:int = 0;
      var _loc33_:int = 0;
      var _loc31_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc22_:int = 0;
      var _loc20_:int = 0;
      var _loc48_:int = 0;
      var _loc50_:int = 0;
      var _loc44_:int = 0;
      var _loc35_:int = 0;
      var _loc3_:int = 0;
      var _loc49_:int = 0;
      var _loc1_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc7_)
            {
               _loc2_ = _loc1_;
               _loc1_ -= 256;
               _loc15_ = li8(wdnative_nternal.__ZZN9__gnu_cxx27__verbose_terminate_handlerEvE11terminating_2E_b);
               si32(wdnative_nternal.L_LSDA_370,_loc2_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc2_ - 32);
               _loc32_ = _loc2_;
               si32(_loc32_,_loc2_ - 24);
               _loc32_ = _loc1_;
               si32(_loc32_,_loc2_ - 16);
               _loc30_ = _loc2_ - 56;
               _loc28_ = _loc30_ + 32;
               _loc26_ = 0;
               wdnative.eax = setjmp(_loc28_,1,_loc1_);
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
            _loc32_ = wdnative.eax;
            if(_loc32_ == 0)
            {
               _loc1_ -= 16;
               si32(_loc30_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative.F__Unwind_SjLj_Register();
               _loc1_ += 16;
               _loc32_ = _loc15_ & 1;
               if(_loc32_ != 0)
               {
                  si32(wdnative_nternal.L__2E_str358,_loc2_ - 248);
                  _loc24_ = _loc2_ - 248;
                  _loc32_ = _loc24_ | 4;
                  si32(29,_loc32_);
                  si32(29,_loc2_ - 232);
                  si32(_loc24_,_loc2_ - 240);
                  _loc22_ = _loc2_ - 240;
                  _loc32_ = _loc22_ | 4;
                  si32(1,_loc32_);
                  _loc32_ = li32(wdnative_nternal.___sF + 564);
                  if(_loc32_ == 0)
                  {
                     si32(-1,wdnative_nternal.___sF + 564);
                  }
                  _loc1_ -= 16;
                  si32(_loc22_,_loc1_ + 4);
                  _loc32_ = wdnative_nternal.___sF + 464;
                  si32(_loc32_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sfvwrite();
                  _loc1_ += 16;
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_abort();
               }
               si8(1,wdnative_nternal.__ZZN9__gnu_cxx27__verbose_terminate_handlerEvE11terminating_2E_b);
               _loc20_ = wdnative_nternal.__ZL10eh_globals;
               _loc32_ = li8(wdnative_nternal.__ZL4init + 4);
               if(_loc32_ != 0)
               {
                  while(true)
                  {
                     _loc18_ = li32(wdnative_nternal.__ZL4init);
                     if(_loc18_ >= 0)
                     {
                        _loc32_ = li32(wdnative_nternal._sEntryCount);
                        if(_loc32_ > _loc18_)
                        {
                           _loc24_ = _loc18_ << 3;
                           _loc32_ = li32(wdnative_nternal._sEntries);
                           _loc32_ = _loc32_ + _loc24_;
                           _loc20_ = li32(_loc32_);
                           if(_loc20_ != 0)
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
                     _loc20_ = wdnative.eax;
                     if(_loc20_ != 0)
                     {
                        _loc14_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc14_ >= 0)
                        {
                           _loc32_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc32_ > _loc14_)
                           {
                              _loc24_ = _loc14_ << 3;
                              _loc32_ = li32(wdnative_nternal._sEntries);
                              _loc32_ = _loc32_ + _loc24_;
                              si32(_loc20_,_loc32_);
                              si32(0,_loc20_);
                              si32(0,_loc20_ + 4);
                              break;
                           }
                        }
                     }
                     _loc32_ = _loc30_ | 4;
                     si32(1,_loc32_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F__ZSt9terminatev();
                     addr0326:
                     _loc32_ = li32(_loc2_ - 48);
                     _loc55_ = li32(_loc2_ - 44);
                     _loc1_ -= 16;
                     si32(_loc32_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc1_ += 16;
                     break;
                  }
               }
               loop12:
               while(true)
               {
                  _loc56_ = li32(_loc20_);
                  if(_loc56_ != 0)
                  {
                     _loc57_ = li32(_loc56_);
                     if(_loc57_ != 0)
                     {
                        _loc58_ = li32(_loc57_ + 4);
                        _loc48_ = -1;
                        si32(_loc48_,_loc2_ - 252);
                        if(_loc58_ == 0)
                        {
                           _loc48_ = -3;
                           si32(_loc48_,_loc2_ - 252);
                           _loc50_ = 0;
                        }
                        else
                        {
                           _loc1_ -= 16;
                           _loc32_ = _loc2_ - 228;
                           si32(_loc32_,_loc1_ + 4);
                           si32(_loc58_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F_d_demangle();
                           _loc1_ += 16;
                           _loc50_ = wdnative.eax;
                           if(_loc50_ == 0)
                           {
                              _loc32_ = li32(_loc2_ - 228);
                              if(_loc32_ == 1)
                              {
                                 si32(_loc48_,_loc2_ - 252);
                                 _loc50_ = 0;
                              }
                              else
                              {
                                 _loc48_ = -2;
                                 si32(_loc48_,_loc2_ - 252);
                                 _loc50_ = 0;
                              }
                           }
                           else
                           {
                              _loc48_ = 0;
                              si32(_loc48_,_loc2_ - 252);
                           }
                        }
                        si32(wdnative_nternal.L__2E_str1359,_loc2_ - 224);
                        _loc24_ = _loc2_ - 224;
                        _loc32_ = _loc24_ | 4;
                        si32(48,_loc32_);
                        si32(48,_loc2_ - 208);
                        si32(_loc24_,_loc2_ - 216);
                        _loc52_ = _loc2_ - 216;
                        _loc32_ = _loc52_ | 4;
                        si32(1,_loc32_);
                        _loc32_ = li32(wdnative_nternal.___sF + 564);
                        if(_loc32_ == 0)
                        {
                           si32(-1,wdnative_nternal.___sF + 564);
                        }
                        _loc1_ -= 16;
                        si32(_loc52_,_loc1_ + 4);
                        _loc54_ = wdnative_nternal.___sF + 464;
                        si32(_loc54_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F___sfvwrite();
                        _loc1_ += 16;
                        if(_loc48_ == 0)
                        {
                           si32(_loc50_,_loc2_ - 200);
                           _loc46_ = _loc50_ & -4;
                           _loc24_ = li32(_loc46_);
                           _loc32_ = _loc24_ + -16843009;
                           _loc24_ &= -2139062144;
                           _loc24_ = _loc24_ ^ -2139062144;
                           _loc32_ = _loc24_ & _loc32_;
                           if(_loc32_ != 0)
                           {
                              _loc45_ = _loc46_ + 4;
                              _loc44_ = 0;
                              while(true)
                              {
                                 _loc42_ = _loc50_ + _loc44_;
                                 if((uint(_loc42_)) < uint(_loc45_))
                                 {
                                    _loc32_ = li8(_loc42_);
                                    if(_loc32_ == 0)
                                    {
                                       break;
                                    }
                                    _loc44_ += 1;
                                    continue;
                                 }
                              }
                              addr05e9:
                              si32(_loc44_,_loc2_ - 184);
                              _loc24_ = _loc2_ - 200;
                              _loc32_ = _loc24_ | 4;
                              si32(_loc44_,_loc32_);
                              si32(_loc24_,_loc2_ - 192);
                              _loc41_ = _loc2_ - 192;
                              _loc32_ = _loc41_ | 4;
                              si32(1,_loc32_);
                              _loc32_ = li32(wdnative_nternal.___sF + 564);
                              if(_loc32_ == 0)
                              {
                                 si32(-1,wdnative_nternal.___sF + 564);
                              }
                              _loc1_ -= 16;
                              si32(_loc41_,_loc1_ + 4);
                              si32(_loc54_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F___sfvwrite();
                              _loc1_ += 16;
                              addr081b:
                              si32(wdnative_nternal.L__2E_str2360,_loc2_ - 152);
                              _loc24_ = _loc2_ - 152;
                              _loc32_ = _loc24_ | 4;
                              si32(2,_loc32_);
                              si32(2,_loc2_ - 136);
                              si32(_loc24_,_loc2_ - 144);
                              _loc21_ = _loc2_ - 144;
                              _loc32_ = _loc21_ | 4;
                              si32(1,_loc32_);
                              _loc32_ = li32(wdnative_nternal.___sF + 564);
                              if(_loc32_ == 0)
                              {
                                 si32(-1,wdnative_nternal.___sF + 564);
                              }
                              _loc1_ -= 16;
                              si32(_loc21_,_loc1_ + 4);
                              si32(_loc54_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F___sfvwrite();
                              _loc1_ += 16;
                              if(_loc48_ == 0)
                              {
                                 if(_loc50_ != 0)
                                 {
                                    _loc1_ -= 16;
                                    si32(_loc50_,_loc1_);
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F_idalloc();
                                    _loc1_ += 16;
                                 }
                              }
                              _loc32_ = _loc30_ | 4;
                              si32(2,_loc32_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F___cxa_rethrow();
                              while(true)
                              {
                                 _loc32_ = li32(_loc26_);
                                 _loc19_ = li32(_loc32_ + 8);
                                 _loc25_ = _loc30_ | 4;
                                 si32(3,_loc25_);
                                 _loc1_ -= 16;
                                 si32(_loc26_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative.ptr2fun[_loc19_]();
                                 _loc1_ += 16;
                                 _loc23_ = wdnative.eax;
                                 addr095d:
                                 si32(wdnative_nternal.L__2E_str3361,_loc2_ - 128);
                                 _loc32_ = _loc2_ - 128;
                                 _loc24_ = _loc32_ | 4;
                                 si32(11,_loc24_);
                                 si32(11,_loc2_ - 112);
                                 si32(_loc32_,_loc2_ - 120);
                                 _loc33_ = _loc2_ - 120;
                                 _loc32_ = _loc33_ | 4;
                                 si32(1,_loc32_);
                                 _loc32_ = li32(wdnative_nternal.___sF + 564);
                                 if(_loc32_ == 0)
                                 {
                                    si32(-1,wdnative_nternal.___sF + 564);
                                 }
                                 _loc1_ -= 16;
                                 si32(_loc33_,_loc1_ + 4);
                                 _loc31_ = wdnative_nternal.___sF + 464;
                                 si32(_loc31_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F___sfvwrite();
                                 _loc1_ += 16;
                                 si32(_loc23_,_loc2_ - 104);
                                 _loc5_ = _loc23_ & -4;
                                 _loc24_ = li32(_loc5_);
                                 _loc32_ = _loc24_ + -16843009;
                                 _loc24_ &= -2139062144;
                                 _loc24_ = _loc24_ ^ -2139062144;
                                 _loc32_ = _loc24_ & _loc32_;
                                 if(_loc32_ != 0)
                                 {
                                    _loc4_ = _loc5_ + 4;
                                    _loc3_ = 0;
                                    while(true)
                                    {
                                       _loc10_ = _loc23_ + _loc3_;
                                       if((uint(_loc10_)) >= uint(_loc4_))
                                       {
                                          break;
                                       }
                                       _loc32_ = li8(_loc10_);
                                       if(_loc32_ == 0)
                                       {
                                          addr0b16:
                                          si32(_loc3_,_loc2_ - 88);
                                          _loc32_ = _loc2_ - 104;
                                          _loc24_ = _loc32_ | 4;
                                          si32(_loc3_,_loc24_);
                                          si32(_loc32_,_loc2_ - 96);
                                          _loc6_ = _loc2_ - 96;
                                          _loc32_ = _loc6_ | 4;
                                          si32(1,_loc32_);
                                          _loc32_ = li32(wdnative_nternal.___sF + 564);
                                          if(_loc32_ == 0)
                                          {
                                             si32(-1,wdnative_nternal.___sF + 564);
                                          }
                                          _loc1_ -= 16;
                                          si32(_loc6_,_loc1_ + 4);
                                          si32(_loc31_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F___sfvwrite();
                                          _loc1_ += 16;
                                          _loc24_ = li32(wdnative_nternal.___sF + 472);
                                          _loc32_ = _loc24_ + -1;
                                          si32(_loc32_,wdnative_nternal.___sF + 472);
                                          if(_loc24_ <= 0)
                                          {
                                             _loc1_ -= 16;
                                             si32(10,_loc1_);
                                             si32(_loc31_,_loc1_ + 4);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F___swbuf();
                                             _loc1_ += 16;
                                          }
                                          else
                                          {
                                             _loc32_ = li32(wdnative_nternal.___sF + 464);
                                             si8(10,_loc32_);
                                             _loc32_ += 1;
                                             si32(_loc32_,wdnative_nternal.___sF + 464);
                                          }
                                          si32(-1,_loc25_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F___cxa_end_catch();
                                          break loop12;
                                       }
                                       _loc3_ += 1;
                                    }
                                 }
                                 _loc9_ = _loc5_ + 4;
                                 while(true)
                                 {
                                    _loc8_ = li32(_loc9_);
                                    _loc32_ = _loc8_ + -16843009;
                                    _loc24_ = _loc8_ & -2139062144;
                                    _loc24_ = _loc24_ ^ -2139062144;
                                    _loc32_ = _loc24_ & _loc32_;
                                    if(_loc32_ != 0)
                                    {
                                       _loc32_ = _loc8_ & 0xFF;
                                       if(_loc32_ == 0)
                                       {
                                          _loc3_ = _loc9_ - _loc23_;
                                          break;
                                       }
                                       _loc32_ = li8(_loc9_ + 1);
                                       if(_loc32_ == 0)
                                       {
                                          _loc32_ = 1 - _loc23_;
                                          _loc3_ = _loc32_ + _loc9_;
                                          break;
                                       }
                                       _loc32_ = li8(_loc9_ + 2);
                                       if(_loc32_ == 0)
                                       {
                                          _loc32_ = 2 - _loc23_;
                                          _loc3_ = _loc32_ + _loc9_;
                                          break;
                                       }
                                       _loc32_ = li8(_loc9_ + 3);
                                       if(_loc32_ == 0)
                                       {
                                          _loc32_ = 3 - _loc23_;
                                          _loc3_ = _loc32_ + _loc9_;
                                          break;
                                       }
                                    }
                                    _loc9_ += 4;
                                 }
                                 §§goto(addr0b16);
                              }
                              addr0fcd:
                              throw l;
                              addr08ee:
                           }
                           _loc43_ = _loc46_ + 4;
                           while(true)
                           {
                              _loc40_ = li32(_loc43_);
                              _loc32_ = _loc40_ + -16843009;
                              _loc24_ = _loc40_ & -2139062144;
                              _loc24_ = _loc24_ ^ -2139062144;
                              _loc32_ = _loc24_ & _loc32_;
                              if(_loc32_ != 0)
                              {
                                 _loc32_ = _loc40_ & 0xFF;
                                 if(_loc32_ == 0)
                                 {
                                    _loc44_ = _loc43_ - _loc50_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc43_ + 1);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 1 - _loc50_;
                                    _loc44_ = _loc32_ + _loc43_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc43_ + 2);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 2 - _loc50_;
                                    _loc44_ = _loc32_ + _loc43_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc43_ + 3);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 3 - _loc50_;
                                    _loc44_ = _loc32_ + _loc43_;
                                    break;
                                 }
                              }
                              _loc43_ += 4;
                           }
                           §§goto(addr05e9);
                        }
                        else
                        {
                           si32(_loc58_,_loc2_ - 176);
                           _loc37_ = _loc58_ & -4;
                           _loc24_ = li32(_loc37_);
                           _loc32_ = _loc24_ + -16843009;
                           _loc24_ &= -2139062144;
                           _loc24_ = _loc24_ ^ -2139062144;
                           _loc32_ = _loc24_ & _loc32_;
                           if(_loc32_ != 0)
                           {
                              _loc38_ = _loc37_ + 4;
                              _loc35_ = 0;
                              while(true)
                              {
                                 _loc36_ = _loc58_ + _loc35_;
                                 if((uint(_loc36_)) < uint(_loc38_))
                                 {
                                    _loc32_ = li8(_loc36_);
                                    if(_loc32_ == 0)
                                    {
                                       break;
                                    }
                                    _loc35_ += 1;
                                    continue;
                                 }
                              }
                              addr07a1:
                              si32(_loc35_,_loc2_ - 160);
                              _loc32_ = _loc2_ - 176;
                              _loc24_ = _loc32_ | 4;
                              si32(_loc35_,_loc24_);
                              si32(_loc32_,_loc2_ - 168);
                              _loc16_ = _loc2_ - 168;
                              _loc32_ = _loc16_ | 4;
                              si32(1,_loc32_);
                              _loc32_ = li32(wdnative_nternal.___sF + 564);
                              if(_loc32_ == 0)
                              {
                                 si32(-1,wdnative_nternal.___sF + 564);
                              }
                              _loc1_ -= 16;
                              si32(_loc16_,_loc1_ + 4);
                              si32(_loc54_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F___sfvwrite();
                              _loc1_ += 16;
                              §§goto(addr081b);
                           }
                           _loc34_ = _loc37_ + 4;
                           while(true)
                           {
                              _loc17_ = li32(_loc34_);
                              _loc32_ = _loc17_ + -16843009;
                              _loc24_ = _loc17_ & -2139062144;
                              _loc24_ = _loc24_ ^ -2139062144;
                              _loc32_ = _loc24_ & _loc32_;
                              if(_loc32_ != 0)
                              {
                                 _loc32_ = _loc17_ & 0xFF;
                                 if(_loc32_ == 0)
                                 {
                                    _loc35_ = _loc34_ - _loc58_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc34_ + 1);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 1 - _loc58_;
                                    _loc35_ = _loc32_ + _loc34_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc34_ + 2);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 2 - _loc58_;
                                    _loc35_ = _loc32_ + _loc34_;
                                    break;
                                 }
                                 _loc32_ = li8(_loc34_ + 3);
                                 if(_loc32_ == 0)
                                 {
                                    _loc32_ = 3 - _loc58_;
                                    _loc35_ = _loc32_ + _loc34_;
                                    break;
                                 }
                              }
                              _loc34_ += 4;
                           }
                           §§goto(addr07a1);
                        }
                     }
                  }
                  si32(wdnative_nternal.L__2E_str4362,_loc2_ - 80);
                  _loc32_ = _loc2_ - 80;
                  _loc24_ = _loc32_ | 4;
                  si32(45,_loc24_);
                  si32(45,_loc2_ - 64);
                  si32(_loc32_,_loc2_ - 72);
                  _loc13_ = _loc2_ - 72;
                  _loc32_ = _loc13_ | 4;
                  si32(1,_loc32_);
                  _loc32_ = li32(wdnative_nternal.___sF + 564);
                  if(_loc32_ == 0)
                  {
                     si32(-1,wdnative_nternal.___sF + 564);
                  }
                  _loc1_ -= 16;
                  si32(_loc13_,_loc1_ + 4);
                  _loc32_ = wdnative_nternal.___sF + 464;
                  si32(_loc32_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sfvwrite();
                  _loc1_ += 16;
                  break;
               }
               while(true)
               {
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_abort();
                  addr0ca8:
                  _loc12_ = li32(_loc2_ - 48);
                  _loc11_ = li32(_loc2_ - 44);
                  _loc49_ = wdnative_nternal.__ZL10eh_globals;
                  _loc32_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc32_ != 0)
                  {
                     while(true)
                     {
                        _loc47_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc47_ >= 0)
                        {
                           _loc32_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc32_ > _loc47_)
                           {
                              _loc24_ = _loc47_ << 3;
                              _loc32_ = li32(wdnative_nternal._sEntries);
                              _loc32_ = _loc32_ + _loc24_;
                              _loc49_ = li32(_loc32_);
                              if(_loc49_ != 0)
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
                        _loc49_ = wdnative.eax;
                        if(_loc49_ != 0)
                        {
                           _loc53_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc53_ >= 0)
                           {
                              _loc32_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc32_ > _loc53_)
                              {
                                 _loc32_ = _loc53_ << 3;
                                 _loc24_ = li32(wdnative_nternal._sEntries);
                                 _loc32_ = _loc24_ + _loc32_;
                                 si32(_loc49_,_loc32_);
                                 si32(_loc26_,_loc49_);
                                 si32(_loc26_,_loc49_ + 4);
                                 break;
                              }
                           }
                        }
                        _loc32_ = _loc30_ | 4;
                        si32(4,_loc32_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                        addr0d9d:
                        _loc32_ = li32(_loc2_ - 48);
                        _loc51_ = li32(_loc2_ - 44);
                        _loc1_ -= 16;
                        si32(_loc32_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc1_ += 16;
                        break;
                     }
                  }
                  _loc32_ = li32(_loc12_ + 4);
                  _loc32_ = _loc32_ ^ 0x474E5543;
                  _loc24_ = li32(_loc12_);
                  _loc24_ = _loc24_ ^ 0x432B2B00;
                  _loc32_ = _loc24_ | _loc32_;
                  _loc62_ = _loc12_ + -48;
                  _loc61_ = li32(_loc49_);
                  addr0ec8:
                  if(_loc32_ != 0)
                  {
                     if(_loc61_ != 0)
                     {
                        _loc32_ = _loc30_ | 4;
                        si32(5,_loc32_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                     }
                     si32(_loc62_,_loc49_);
                  }
                  else
                  {
                     _loc24_ = li32(_loc12_ - 28);
                     _loc32_ = _loc24_ >> 31;
                     _loc24_ += _loc32_;
                     _loc32_ = _loc24_ ^ _loc32_;
                     _loc32_ = _loc32_ + 1;
                     si32(_loc32_,_loc12_ - 28);
                     _loc32_ = li32(_loc49_ + 4);
                     _loc32_ = _loc32_ + -1;
                     si32(_loc32_,_loc49_ + 4);
                     if(_loc62_ != _loc61_)
                     {
                        si32(_loc61_,_loc12_ - 32);
                        si32(_loc62_,_loc49_);
                     }
                     _loc26_ = li32(_loc12_ - 8);
                  }
                  if(_loc11_ != 2)
                  {
                     continue;
                  }
                  §§goto(addr08ee);
                  _loc32_ = _loc30_ | 4;
                  si32(-1,_loc32_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___cxa_end_catch();
               }
               §§goto(addr0fcd);
               addr0c98:
            }
            else
            {
               _loc32_ = _loc30_ | 4;
               _loc39_ = li32(_loc32_);
               if(_loc39_ <= 2)
               {
                  if(_loc39_ != 0)
                  {
                     if(_loc39_ != 1)
                     {
                        if(_loc39_ != 2)
                        {
                           while(true)
                           {
                           }
                           addr0f92:
                        }
                        else
                        {
                           _loc27_ = li32(_loc2_ - 48);
                           _loc63_ = li32(_loc2_ - 44);
                           _loc29_ = _loc30_ | 4;
                           si32(6,_loc29_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F___cxa_end_catch();
                           si32(-1,_loc29_);
                           _loc1_ -= 16;
                           si32(_loc27_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative.F__Unwind_SjLj_Resume();
                           _loc1_ += 16;
                           §§goto(addr095d);
                        }
                     }
                     §§goto(addr0ca8);
                  }
                  else
                  {
                     §§goto(addr0326);
                  }
               }
               else if(_loc39_ != 3)
               {
                  if(_loc39_ != 4)
                  {
                     if(_loc39_ != 5)
                     {
                        §§goto(addr0f92);
                     }
                     else
                     {
                        _loc60_ = li32(_loc2_ - 48);
                        _loc59_ = li32(_loc2_ - 44);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZSt9terminatev();
                        _loc32_ = _loc30_ | 4;
                        si32(-1,_loc32_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F___cxa_end_catch();
                        §§goto(addr0c98);
                     }
                  }
                  else
                  {
                     _loc32_ = li32(_loc2_ - 48);
                     _loc64_ = li32(_loc2_ - 44);
                     _loc1_ -= 16;
                     si32(_loc32_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc1_ += 16;
                  }
                  §§goto(addr0ec8);
               }
            }
            §§goto(addr0d9d);
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
         §§goto(addr0fcd);
         wdnative.ESP = _loc1_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc7_ = int(l.sjid);
      }
   }
}

