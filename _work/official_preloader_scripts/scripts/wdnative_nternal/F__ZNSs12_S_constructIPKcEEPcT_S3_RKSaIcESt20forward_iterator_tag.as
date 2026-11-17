package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.Fmemcpy;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F__ZNSs12_S_constructIPKcEEPcT_S3_RKSaIcESt20forward_iterator_tag() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc13_:int = 0;
      var _loc36_:int = 0;
      var _loc38_:int = 0;
      var _loc32_:int = 0;
      var _loc30_:int = 0;
      var _loc24_:int = 0;
      var _loc21_:int = 0;
      var _loc17_:int = 0;
      var _loc16_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc43_:int = 0;
      var _loc44_:int = 0;
      var _loc42_:int = 0;
      var _loc10_:int = 0;
      var _loc15_:int = 0;
      var _loc26_:int = 0;
      var _loc22_:int = 0;
      var _loc33_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc27_:int = 0;
      var _loc25_:int = 0;
      var _loc37_:int = 0;
      var _loc39_:int = 0;
      var _loc18_:int = 0;
      var _loc23_:int = 0;
      var _loc41_:int = 0;
      var _loc31_:int = 0;
      var _loc14_:int = 0;
      var _loc29_:int = 0;
      var _loc28_:int = 0;
      var _loc19_:int = 0;
      var _loc40_:int = 0;
      var _loc20_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = 0;
      var _loc35_:int = 0;
      var _loc34_:int = 0;
      var _loc3_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc13_)
            {
               _loc7_ = _loc3_;
               _loc3_ -= 80;
               si32(wdnative_nternal.L_LSDA_328,_loc7_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc7_ - 32);
               _loc18_ = _loc7_;
               si32(_loc18_,_loc7_ - 24);
               _loc18_ = _loc3_;
               si32(_loc18_,_loc7_ - 16);
               _loc44_ = _loc7_ - 56;
               _loc42_ = _loc44_ + 32;
               _loc40_ = 0;
               wdnative.eax = setjmp(_loc42_,1,_loc3_);
            }
            else
            {
               switch(_loc13_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            loop5:
            while(true)
            {
               loop6:
               while(true)
               {
                  loop7:
                  while(true)
                  {
                     while(true)
                     {
                        _loc18_ = wdnative.eax;
                        if(_loc18_ == 0)
                        {
                           _loc38_ = li32(_loc7_ + 4);
                           _loc36_ = li32(_loc7_);
                           _loc3_ -= 16;
                           si32(_loc44_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.F__Unwind_SjLj_Register();
                           _loc3_ += 16;
                           _loc34_ = wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE + 12;
                           if(_loc36_ == _loc38_)
                           {
                              break loop7;
                           }
                           if(_loc36_ != _loc38_)
                           {
                              if(_loc36_ == 0)
                              {
                                 _loc15_ = wdnative_nternal.L__2E_str11317 & -4;
                                 _loc23_ = li32(_loc15_);
                                 _loc18_ = _loc23_ + -16843009;
                                 _loc23_ &= -2139062144;
                                 _loc23_ = _loc23_ ^ -2139062144;
                                 _loc18_ = _loc23_ & _loc18_;
                                 _loc24_ = _loc15_ + 4;
                                 if(_loc18_ != 0)
                                 {
                                    do
                                    {
                                       _loc18_ = wdnative_nternal.L__2E_str11317 + _loc40_;
                                       _loc24_ = _loc15_ + 4;
                                       if(uint(_loc18_) < uint(_loc24_))
                                       {
                                          continue;
                                       }
                                    }
                                    while(_loc26_ = _loc15_ + 4, _loc28_ = wdnative_nternal.L__2E_str11317, if(uint(wdnative_nternal.L__2E_str11317) <= uint(_loc26_))
                                    {
                                       _loc28_ = _loc26_;
                                    }, _loc18_ = _loc28_ ^ -1, _loc19_ = wdnative_nternal.L__2E_str11317 + _loc18_, if((uint(_loc19_)) <= 4294967254)
                                    {
                                       _loc19_ = -42;
                                    }, _loc20_ = _loc19_ ^ -1, _loc40_ += 1, _loc40_ != 42);
                                    addr0373:
                                    _loc22_ = _loc44_ | 4;
                                    si32(1,_loc22_);
                                    _loc3_ -= 16;
                                    si32(wdnative_nternal.L__2E_str11317,_loc3_);
                                    _loc18_ = wdnative_nternal.L__2E_str11317 + _loc20_;
                                    si32(_loc18_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F__ZNSs12_S_constructIPKcEEPcT_S3_RKSaIcESt20forward_iterator_tag();
                                    _loc3_ += 16;
                                    _loc17_ = wdnative.eax;
                                    _loc3_ -= 16;
                                    si32(8,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F___cxa_allocate_exception();
                                    _loc3_ += 16;
                                    _loc18_ = wdnative.eax;
                                    si32(_loc18_,_loc7_ - 72);
                                    _loc18_ = li32(_loc7_ - 72);
                                    si32(_loc18_,_loc7_ - 68);
                                    _loc18_ = wdnative_nternal.__ZTVSt11logic_error + 8;
                                    _loc23_ = li32(_loc7_ - 68);
                                    si32(_loc18_,_loc23_);
                                    _loc18_ = _loc17_ + -12;
                                    _loc16_ = li32(_loc7_ - 72);
                                    si32(_loc18_,_loc7_ - 64);
                                    _loc18_ = _loc17_ + -4;
                                    si32(_loc18_,_loc7_ - 60);
                                    _loc18_ = li32(_loc7_ - 60);
                                    _loc18_ = li32(_loc18_);
                                    if(_loc18_ >= 0)
                                    {
                                       _loc18_ = li32(_loc7_ - 64);
                                       if(_loc18_ == wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                                       {
                                          si32(_loc17_,_loc16_ + 4);
                                          break loop5;
                                       }
                                       _loc18_ = li32(_loc7_ - 60);
                                       _loc14_ = li32(_loc18_);
                                       _loc18_ = li32(_loc7_ - 60);
                                       _loc18_ = li32(_loc18_);
                                       _loc23_ = _loc18_ + 1;
                                       _loc18_ = li32(_loc7_ - 60);
                                       si32(_loc23_,_loc18_);
                                       si32(_loc17_,_loc16_ + 4);
                                       break loop6;
                                    }
                                    _loc11_ = li32(_loc7_ - 64);
                                    _loc12_ = li32(_loc11_);
                                    _loc8_ = li32(_loc17_ - 8);
                                    si32(2,_loc22_);
                                    _loc3_ -= 16;
                                    si32(_loc8_,_loc3_ + 4);
                                    si32(_loc12_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F__ZNSs4_Rep9_S_createEjjRKSaIcE();
                                    _loc3_ += 16;
                                    _loc9_ = wdnative.eax;
                                    _loc5_ = _loc9_ + 12;
                                    _loc6_ = li32(_loc11_);
                                    _loc2_ = 0;
                                    if(_loc6_ != 0)
                                    {
                                       if(_loc6_ == 1)
                                       {
                                          _loc18_ = li8(_loc17_);
                                          si8(_loc18_,_loc5_);
                                       }
                                       else
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc6_,_loc3_ + 8);
                                          si32(_loc17_,_loc3_ + 4);
                                          si32(_loc5_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative.Fmemcpy();
                                          _loc3_ += 16;
                                       }
                                       _loc2_ = li32(_loc11_);
                                    }
                                    addr05de:
                                    si32(0,_loc9_ + 8);
                                    si32(_loc2_,_loc9_);
                                    _loc18_ = _loc5_ + _loc2_;
                                    si8(0,_loc18_);
                                    _loc18_ = li32(_loc7_ - 64);
                                    si32(_loc5_,_loc16_ + 4);
                                    if(_loc18_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                                    {
                                       break loop6;
                                    }
                                    break loop5;
                                 }
                                 while(true)
                                 {
                                    _loc21_ = li32(_loc24_);
                                    _loc18_ = _loc21_ + -16843009;
                                    _loc23_ = _loc21_ & -2139062144;
                                    _loc23_ = _loc23_ ^ -2139062144;
                                    _loc18_ = _loc23_ & _loc18_;
                                    if(_loc18_ != 0)
                                    {
                                       _loc18_ = _loc21_ & 0xFF;
                                       if(_loc18_ == 0)
                                       {
                                          _loc20_ = _loc24_ - wdnative_nternal.L__2E_str11317;
                                          break;
                                       }
                                       _loc18_ = li8(_loc24_ + 1);
                                       if(_loc18_ == 0)
                                       {
                                          _loc18_ = 1 - wdnative_nternal.L__2E_str11317;
                                          _loc20_ = _loc24_ + _loc18_;
                                          break;
                                       }
                                       _loc18_ = li8(_loc24_ + 2);
                                       if(_loc18_ == 0)
                                       {
                                          _loc18_ = 2 - wdnative_nternal.L__2E_str11317;
                                          _loc20_ = _loc24_ + _loc18_;
                                          break;
                                       }
                                       _loc18_ = li8(_loc24_ + 3);
                                       if(_loc18_ == 0)
                                       {
                                          _loc18_ = 3 - wdnative_nternal.L__2E_str11317;
                                          _loc20_ = _loc24_ + _loc18_;
                                          break;
                                       }
                                    }
                                    _loc24_ += 4;
                                 }
                                 §§goto(addr0373);
                              }
                           }
                           _loc18_ = _loc44_ | 4;
                           si32(-1,_loc18_);
                           _loc3_ -= 16;
                           si32(0,_loc3_ + 4);
                           _loc32_ = _loc38_ - _loc36_;
                           si32(_loc32_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F__ZNSs4_Rep9_S_createEjjRKSaIcE();
                           _loc3_ += 16;
                           _loc30_ = wdnative.eax;
                           _loc34_ = _loc30_ + 12;
                           if(_loc32_ == 1)
                           {
                              _loc18_ = li8(_loc36_);
                              si8(_loc18_,_loc34_);
                           }
                           else
                           {
                              _loc3_ -= 16;
                              si32(_loc32_,_loc3_ + 8);
                              si32(_loc36_,_loc3_ + 4);
                              si32(_loc34_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemcpy();
                              _loc3_ += 16;
                           }
                           §§goto(addr0830);
                        }
                        else
                        {
                           _loc18_ = _loc44_ | 4;
                           _loc10_ = li32(_loc18_);
                           if(_loc10_ <= 1)
                           {
                              if(_loc10_ == 0)
                              {
                                 break;
                              }
                              if(_loc10_ != 1)
                              {
                                 while(true)
                                 {
                                 }
                                 addr08bb:
                              }
                              else
                              {
                                 _loc4_ = li32(_loc7_ - 48);
                                 _loc1_ = li32(_loc7_ - 44);
                                 _loc18_ = _loc44_ | 4;
                                 si32(3,_loc18_);
                                 _loc3_ -= 16;
                                 si32(_loc4_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative.F__Unwind_SjLj_Resume();
                                 _loc3_ += 16;
                              }
                           }
                           else if(_loc10_ != 2)
                           {
                              if(_loc10_ != 3)
                              {
                                 §§goto(addr08bb);
                              }
                              else
                              {
                                 _loc35_ = li32(_loc7_ - 48);
                                 _loc39_ = li32(_loc7_ - 44);
                                 _loc18_ = li32(_loc7_ - 72);
                                 _loc37_ = li32(_loc7_ - 72);
                                 while(true)
                                 {
                                    if(uint(_loc18_) >= uint(wdnative_nternal.__ZL16emergency_buffer))
                                    {
                                       _loc18_ = wdnative_nternal.__ZL16emergency_buffer + 16384;
                                       if(uint(_loc37_) < uint(_loc18_))
                                       {
                                          _loc18_ = li32(_loc7_ - 72);
                                          _loc18_ = _loc18_ - wdnative_nternal.__ZL16emergency_buffer;
                                          _loc18_ = _loc18_ >>> 9;
                                          _loc18_ = 1 << _loc18_;
                                          _loc18_ = _loc18_ ^ -1;
                                          _loc23_ = li32(wdnative_nternal.__ZL14emergency_used);
                                          _loc18_ = _loc23_ & _loc18_;
                                          si32(_loc18_,wdnative_nternal.__ZL14emergency_used);
                                          break;
                                       }
                                    }
                                    _loc18_ = li32(_loc7_ - 72);
                                    _loc43_ = _loc18_ + -80;
                                    if(_loc43_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc43_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    break;
                                 }
                                 _loc18_ = li32(_loc7_ - 64);
                                 if(_loc18_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                                 {
                                    _loc18_ = li32(_loc7_ - 60);
                                    _loc18_ = li32(_loc18_);
                                    _loc23_ = li32(_loc7_ - 60);
                                    _loc23_ = li32(_loc23_);
                                    _loc23_ = _loc23_ + -1;
                                    _loc31_ = li32(_loc7_ - 60);
                                    si32(_loc23_,_loc31_);
                                    _loc41_ = li32(_loc7_ - 64);
                                    if(_loc18_ <= 0)
                                    {
                                       if(_loc41_ != 0)
                                       {
                                          _loc18_ = li32(_loc7_ - 64);
                                          _loc3_ -= 16;
                                          si32(_loc18_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                    }
                                 }
                                 §§goto(addr0804);
                              }
                           }
                           _loc27_ = li32(_loc7_ - 48);
                           _loc25_ = li32(_loc7_ - 44);
                           _loc18_ = wdnative_nternal.__ZTVSt9exception + 8;
                           _loc23_ = li32(_loc7_ - 68);
                           si32(_loc18_,_loc23_);
                           _loc18_ = _loc44_ | 4;
                           si32(4,_loc18_);
                           _loc3_ -= 16;
                           si32(_loc27_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.F__Unwind_SjLj_Resume();
                           _loc3_ += 16;
                        }
                        §§goto(addr05de);
                     }
                     §§goto(addr06bb);
                  }
                  §§goto(addr084b);
               }
               _loc18_ = li32(_loc7_ - 60);
               _loc18_ = li32(_loc18_);
               _loc23_ = li32(_loc7_ - 60);
               _loc23_ = li32(_loc23_);
               _loc31_ = _loc23_ + -1;
               _loc23_ = li32(_loc7_ - 60);
               si32(_loc31_,_loc23_);
               _loc29_ = li32(_loc7_ - 64);
               if(_loc18_ <= 0)
               {
                  if(_loc29_ != 0)
                  {
                     _loc18_ = li32(_loc7_ - 64);
                     _loc3_ -= 16;
                     si32(_loc18_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_idalloc();
                     _loc3_ += 16;
                  }
               }
               break;
            }
            _loc18_ = li32(_loc7_ - 72);
            si32(-1,_loc22_);
            _loc3_ -= 16;
            si32(wdnative_nternal.__ZNSt11logic_errorD1Ev,_loc3_ + 8);
            si32(wdnative_nternal.__ZTISt11logic_error,_loc3_ + 4);
            si32(_loc18_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F___cxa_throw();
            _loc3_ += 16;
            addr06bb:
            _loc35_ = li32(_loc7_ - 48);
            _loc33_ = li32(_loc7_ - 44);
            addr0804:
            _loc18_ = _loc44_ | 4;
            si32(-1,_loc18_);
            _loc3_ -= 16;
            si32(_loc35_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__Unwind_SjLj_Resume();
            _loc3_ += 16;
            addr0830:
            si32(0,_loc30_ + 8);
            si32(_loc32_,_loc30_);
            _loc18_ = _loc34_ + _loc32_;
            si8(0,_loc18_);
            addr084b:
            _loc3_ -= 16;
            si32(_loc44_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc3_ += 16;
            wdnative.eax = _loc34_;
            _loc3_ = _loc7_;
            wdnative.ESP = _loc3_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_72:* = this;
            var _temp_73:* = l;
            if(l.esp >= _loc7_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc3_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc13_ = int(l.sjid);
      }
   }
}

