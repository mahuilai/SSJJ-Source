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
   import wdnative.F_malloc;
   import wdnative.Fmemcpy;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F__ZNSs4_Rep9_S_createEjjRKSaIcE() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc7_:int = 0;
      var _loc17_:int = 0;
      var _loc49_:int = 0;
      var _loc43_:int = 0;
      var _loc44_:int = 0;
      var _loc46_:int = 0;
      var _loc40_:int = 0;
      var _loc39_:int = 0;
      var _loc22_:int = 0;
      var _loc30_:int = 0;
      var _loc9_:int = 0;
      var _loc29_:int = 0;
      var _loc27_:int = 0;
      var _loc6_:int = 0;
      var _loc26_:int = 0;
      var _loc28_:int = 0;
      var _loc5_:int = 0;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc21_:int = 0;
      var _loc15_:int = 0;
      var _loc50_:int = 0;
      var _loc12_:int = 0;
      var _loc13_:int = 0;
      var _loc19_:int = 0;
      var _loc42_:int = 0;
      var _loc41_:int = 0;
      var _loc37_:int = 0;
      var _loc34_:int = 0;
      var _loc35_:int = 0;
      var _loc32_:int = 0;
      var _loc16_:int = 0;
      var _loc18_:int = 0;
      var _loc20_:int = 0;
      var _loc33_:int = 0;
      var _loc45_:int = 0;
      var _loc31_:int = 0;
      var _loc11_:int = 0;
      var _loc47_:int = 0;
      var _loc25_:int = 0;
      var _loc48_:int = 0;
      var _loc38_:int = 0;
      var _loc36_:int = 0;
      var _loc14_:int = 0;
      var _loc24_:int = 0;
      var _loc23_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc7_)
            {
               _loc2_ = _loc1_;
               _loc1_ -= 80;
               si32(wdnative_nternal.L_LSDA_327,_loc2_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc2_ - 32);
               _loc12_ = _loc2_;
               si32(_loc12_,_loc2_ - 24);
               _loc12_ = _loc1_;
               si32(_loc12_,_loc2_ - 16);
               _loc29_ = _loc2_ - 56;
               _loc27_ = _loc29_ + 32;
               _loc25_ = 0;
               wdnative.eax = setjmp(_loc27_,1,_loc1_);
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
            while(true)
            {
               _loc12_ = wdnative.eax;
               if(_loc12_ == 0)
               {
                  _loc23_ = li32(_loc2_);
                  _loc1_ -= 16;
                  si32(_loc29_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative.F__Unwind_SjLj_Register();
                  _loc1_ += 16;
                  if(uint(_loc23_) < 1073741821)
                  {
                     break;
                  }
                  _loc21_ = wdnative_nternal.L__2E_str306 & -4;
                  _loc19_ = li32(_loc21_);
                  _loc12_ = _loc19_ + -16843009;
                  _loc19_ &= -2139062144;
                  _loc19_ = _loc19_ ^ -2139062144;
                  _loc12_ = _loc19_ & _loc12_;
                  _loc17_ = _loc21_ + 4;
                  if(_loc12_ != 0)
                  {
                     do
                     {
                        _loc12_ = wdnative_nternal.L__2E_str306 + _loc25_;
                        _loc17_ = _loc21_ + 4;
                        if(uint(_loc12_) < uint(_loc17_))
                        {
                           continue;
                        }
                     }
                     while(_loc15_ = _loc21_ + 4, _loc11_ = wdnative_nternal.L__2E_str306, if(uint(wdnative_nternal.L__2E_str306) <= uint(_loc15_))
                     {
                        _loc11_ = _loc15_;
                     }, _loc12_ = _loc11_ ^ -1, _loc47_ = wdnative_nternal.L__2E_str306 + _loc12_, if((uint(_loc47_)) <= 4294967272)
                     {
                        _loc47_ = -24;
                     }, _loc48_ = _loc47_ ^ -1, _loc25_ += 1, _loc25_ != 24);
                     addr02d2:
                     _loc50_ = _loc29_ | 4;
                     si32(1,_loc50_);
                     _loc1_ -= 16;
                     si32(wdnative_nternal.L__2E_str306,_loc1_);
                     _loc12_ = wdnative_nternal.L__2E_str306 + _loc48_;
                     si32(_loc12_,_loc1_ + 4);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F__ZNSs12_S_constructIPKcEEPcT_S3_RKSaIcESt20forward_iterator_tag();
                     _loc1_ += 16;
                     _loc43_ = wdnative.eax;
                     _loc1_ -= 16;
                     si32(8,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_allocate_exception();
                     _loc1_ += 16;
                     _loc12_ = wdnative.eax;
                     si32(_loc12_,_loc2_ - 72);
                     _loc12_ = li32(_loc2_ - 72);
                     si32(_loc12_,_loc2_ - 68);
                     _loc12_ = wdnative_nternal.__ZTVSt11logic_error + 8;
                     _loc19_ = li32(_loc2_ - 68);
                     si32(_loc12_,_loc19_);
                     _loc12_ = _loc43_ + -12;
                     _loc44_ = li32(_loc2_ - 72);
                     si32(_loc12_,_loc2_ - 64);
                     _loc12_ = _loc43_ + -4;
                     si32(_loc12_,_loc2_ - 60);
                     _loc12_ = li32(_loc2_ - 60);
                     _loc12_ = li32(_loc12_);
                     if(_loc12_ >= 0)
                     {
                        _loc12_ = li32(_loc2_ - 64);
                        if(_loc12_ == wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                        {
                           si32(_loc43_,_loc44_ + 4);
                           _loc12_ = wdnative_nternal.__ZTVSt12length_error + 8;
                           _loc19_ = li32(_loc2_ - 68);
                           si32(_loc12_,_loc19_);
                        }
                        else
                        {
                           _loc12_ = li32(_loc2_ - 60);
                           _loc45_ = li32(_loc12_);
                           _loc12_ = li32(_loc2_ - 60);
                           _loc12_ = li32(_loc12_);
                           _loc12_ = _loc12_ + 1;
                           _loc19_ = li32(_loc2_ - 60);
                           si32(_loc12_,_loc19_);
                           si32(_loc43_,_loc44_ + 4);
                           _loc12_ = wdnative_nternal.__ZTVSt12length_error + 8;
                           _loc19_ = li32(_loc2_ - 68);
                           si32(_loc12_,_loc19_);
                           addr05a0:
                           _loc12_ = li32(_loc2_ - 60);
                           _loc12_ = li32(_loc12_);
                           _loc19_ = li32(_loc2_ - 60);
                           _loc19_ = li32(_loc19_);
                           _loc33_ = _loc19_ + -1;
                           _loc19_ = li32(_loc2_ - 60);
                           si32(_loc33_,_loc19_);
                           _loc31_ = li32(_loc2_ - 64);
                           if(_loc12_ <= 0)
                           {
                              if(_loc31_ != 0)
                              {
                                 _loc12_ = li32(_loc2_ - 64);
                                 _loc1_ -= 16;
                                 si32(_loc12_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F_idalloc();
                                 _loc1_ += 16;
                              }
                           }
                        }
                     }
                     else
                     {
                        _loc46_ = li32(_loc2_ - 64);
                        _loc42_ = li32(_loc46_);
                        _loc41_ = li32(_loc43_ - 8);
                        si32(2,_loc50_);
                        _loc1_ -= 16;
                        si32(_loc41_,_loc1_ + 4);
                        si32(_loc42_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F__ZNSs4_Rep9_S_createEjjRKSaIcE();
                        _loc1_ += 16;
                        _loc40_ = wdnative.eax;
                        _loc38_ = _loc40_ + 12;
                        _loc39_ = li32(_loc46_);
                        _loc36_ = 0;
                        if(_loc39_ != 0)
                        {
                           if(_loc39_ == 1)
                           {
                              _loc12_ = li8(_loc43_);
                              si8(_loc12_,_loc38_);
                           }
                           else
                           {
                              _loc1_ -= 16;
                              si32(_loc39_,_loc1_ + 8);
                              si32(_loc43_,_loc1_ + 4);
                              si32(_loc38_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative.Fmemcpy();
                              _loc1_ += 16;
                           }
                           _loc36_ = li32(_loc46_);
                        }
                        addr0558:
                        si32(0,_loc40_ + 8);
                        si32(_loc36_,_loc40_);
                        _loc12_ = _loc38_ + _loc36_;
                        si8(0,_loc12_);
                        _loc12_ = li32(_loc2_ - 64);
                        si32(_loc38_,_loc44_ + 4);
                        _loc19_ = wdnative_nternal.__ZTVSt12length_error + 8;
                        _loc33_ = li32(_loc2_ - 68);
                        si32(_loc19_,_loc33_);
                        if(_loc12_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                        {
                           §§goto(addr05a0);
                        }
                     }
                     _loc12_ = li32(_loc2_ - 72);
                     si32(-1,_loc50_);
                     _loc1_ -= 16;
                     si32(wdnative_nternal.__ZNSt12length_errorD1Ev,_loc1_ + 8);
                     si32(wdnative_nternal.__ZTISt12length_error,_loc1_ + 4);
                     si32(_loc12_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F___cxa_throw();
                     _loc1_ += 16;
                     addr0645:
                     _loc14_ = li32(_loc2_ - 48);
                     _loc13_ = li32(_loc2_ - 44);
                     addr0780:
                     _loc12_ = _loc29_ | 4;
                     si32(-1,_loc12_);
                     _loc1_ -= 16;
                     si32(_loc14_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative.F__Unwind_SjLj_Resume();
                     _loc1_ += 16;
                     break;
                  }
                  while(true)
                  {
                     _loc49_ = li32(_loc17_);
                     _loc12_ = _loc49_ + -16843009;
                     _loc19_ = _loc49_ & -2139062144;
                     _loc19_ = _loc19_ ^ -2139062144;
                     _loc12_ = _loc19_ & _loc12_;
                     if(_loc12_ != 0)
                     {
                        _loc12_ = _loc49_ & 0xFF;
                        if(_loc12_ == 0)
                        {
                           _loc48_ = _loc17_ - wdnative_nternal.L__2E_str306;
                           break;
                        }
                        _loc12_ = li8(_loc17_ + 1);
                        if(_loc12_ == 0)
                        {
                           _loc12_ = 1 - wdnative_nternal.L__2E_str306;
                           _loc48_ = _loc17_ + _loc12_;
                           break;
                        }
                        _loc12_ = li8(_loc17_ + 2);
                        if(_loc12_ == 0)
                        {
                           _loc12_ = 2 - wdnative_nternal.L__2E_str306;
                           _loc48_ = _loc17_ + _loc12_;
                           break;
                        }
                        _loc12_ = li8(_loc17_ + 3);
                        if(_loc12_ == 0)
                        {
                           _loc12_ = 3 - wdnative_nternal.L__2E_str306;
                           _loc48_ = _loc17_ + _loc12_;
                           break;
                        }
                     }
                     _loc17_ += 4;
                  }
                  §§goto(addr02d2);
               }
               else
               {
                  while(true)
                  {
                     _loc12_ = _loc29_ | 4;
                     _loc6_ = li32(_loc12_);
                     if(_loc6_ <= 2)
                     {
                        if(_loc6_ != 0)
                        {
                           if(_loc6_ != 1)
                           {
                              if(_loc6_ != 2)
                              {
                                 break;
                              }
                           }
                           else
                           {
                              _loc37_ = li32(_loc2_ - 48);
                              _loc34_ = li32(_loc2_ - 44);
                              _loc12_ = _loc29_ | 4;
                              si32(3,_loc12_);
                              _loc1_ -= 16;
                              si32(_loc37_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative.F__Unwind_SjLj_Resume();
                              _loc1_ += 16;
                           }
                           _loc35_ = li32(_loc2_ - 48);
                           _loc32_ = li32(_loc2_ - 44);
                           _loc12_ = wdnative_nternal.__ZTVSt9exception + 8;
                           _loc19_ = li32(_loc2_ - 68);
                           si32(_loc12_,_loc19_);
                           _loc12_ = _loc29_ | 4;
                           si32(4,_loc12_);
                           _loc1_ -= 16;
                           si32(_loc35_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative.F__Unwind_SjLj_Resume();
                           _loc1_ += 16;
                           §§goto(addr0558);
                        }
                        §§goto(addr0645);
                     }
                     else
                     {
                        if(_loc6_ != 3)
                        {
                           if(_loc6_ == 4)
                           {
                              _loc9_ = li32(_loc2_ - 48);
                              _loc12_ = li32(_loc2_ - 44);
                              if(_loc12_ < 0)
                              {
                                 while(true)
                                 {
                                    _loc12_ = _loc29_ | 4;
                                    si32(6,_loc12_);
                                    _loc1_ -= 16;
                                    si32(_loc9_,_loc1_);
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F___cxa_call_unexpected();
                                    _loc1_ += 16;
                                    §§goto(addr0908);
                                    addr0908:
                                 }
                                 addr0a5a:
                                 throw l;
                                 addr08d9:
                              }
                              _loc12_ = _loc29_ | 4;
                              si32(7,_loc12_);
                              _loc1_ -= 16;
                              si32(_loc9_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative.F__Unwind_SjLj_Resume();
                              _loc1_ += 16;
                              §§goto(addr094e);
                           }
                           _loc12_ = _loc6_ + -5;
                           if((uint(_loc12_)) >= 2)
                           {
                              break;
                           }
                           _loc19_ = li32(_loc2_ - 48);
                           _loc8_ = li32(_loc2_ - 44);
                           _loc12_ = _loc29_ | 4;
                           si32(-1,_loc12_);
                           _loc1_ -= 16;
                           si32(_loc19_,_loc1_);
                           wdnative.ESP = _loc1_;
                           wdnative.F__Unwind_SjLj_Resume();
                           _loc1_ += 16;
                           continue;
                        }
                        _loc14_ = li32(_loc2_ - 48);
                        _loc18_ = li32(_loc2_ - 44);
                        _loc12_ = li32(_loc2_ - 72);
                        _loc16_ = li32(_loc2_ - 72);
                        while(true)
                        {
                           if(uint(_loc12_) >= uint(wdnative_nternal.__ZL16emergency_buffer))
                           {
                              _loc12_ = wdnative_nternal.__ZL16emergency_buffer + 16384;
                              if(uint(_loc16_) < uint(_loc12_))
                              {
                                 _loc12_ = li32(_loc2_ - 72);
                                 _loc12_ = _loc12_ - wdnative_nternal.__ZL16emergency_buffer;
                                 _loc12_ = _loc12_ >>> 9;
                                 _loc12_ = 1 << _loc12_;
                                 _loc19_ = _loc12_ ^ -1;
                                 _loc12_ = li32(wdnative_nternal.__ZL14emergency_used);
                                 _loc12_ = _loc12_ & _loc19_;
                                 si32(_loc12_,wdnative_nternal.__ZL14emergency_used);
                                 break;
                              }
                           }
                           _loc12_ = li32(_loc2_ - 72);
                           _loc22_ = _loc12_ + -80;
                           if(_loc22_ != 0)
                           {
                              _loc1_ -= 16;
                              si32(_loc22_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F_idalloc();
                              _loc1_ += 16;
                           }
                           break;
                        }
                        _loc12_ = li32(_loc2_ - 64);
                        if(_loc12_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                        {
                           _loc12_ = li32(_loc2_ - 60);
                           _loc12_ = li32(_loc12_);
                           _loc19_ = li32(_loc2_ - 60);
                           _loc19_ = li32(_loc19_);
                           _loc33_ = _loc19_ + -1;
                           _loc19_ = li32(_loc2_ - 60);
                           si32(_loc33_,_loc19_);
                           _loc20_ = li32(_loc2_ - 64);
                           if(_loc12_ <= 0)
                           {
                              if(_loc20_ != 0)
                              {
                                 _loc12_ = li32(_loc2_ - 64);
                                 _loc1_ -= 16;
                                 si32(_loc12_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F_idalloc();
                                 _loc1_ += 16;
                              }
                           }
                        }
                     }
                  }
                  while(true)
                  {
                  }
               }
               §§goto(addr0780);
            }
            _loc26_ = li32(_loc2_ + 4);
            if(uint(_loc23_) > uint(_loc26_))
            {
               _loc24_ = _loc26_ << 1;
               if((uint(_loc24_)) <= uint(_loc23_))
               {
                  _loc24_ = _loc23_;
               }
               _loc23_ = _loc24_;
            }
            _loc30_ = _loc23_ + 29;
            if((uint(_loc30_)) >= 4097)
            {
               if(uint(_loc23_) > uint(_loc26_))
               {
                  _loc12_ = _loc30_ & 0x0FFF;
                  _loc12_ = 4096 - _loc12_;
                  _loc28_ = _loc12_ + _loc23_;
                  _loc23_ = 1073741820;
                  if(uint(_loc28_) <= uint(_loc23_))
                  {
                     _loc23_ = _loc28_;
                  }
               }
            }
            _loc5_ = _loc23_ + 13;
            _loc4_ = 1;
            if(_loc5_ != _loc25_)
            {
               _loc4_ = _loc5_;
            }
            _loc1_ -= 16;
            si32(_loc4_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative.F_malloc();
            _loc1_ += 16;
            _loc3_ = wdnative.eax;
            if(_loc3_ == 0)
            {
               _loc1_ -= 16;
               si32(4,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F___cxa_allocate_exception();
               _loc12_ = wdnative_nternal.__ZTVSt9bad_alloc + 8;
               _loc1_ += 16;
               _loc10_ = wdnative.eax;
               si32(_loc12_,_loc10_);
               _loc12_ = _loc29_ | 4;
               si32(5,_loc12_);
               _loc1_ -= 16;
               si32(wdnative_nternal.__ZNSt9bad_allocD1Ev,_loc1_ + 8);
               si32(wdnative_nternal.__ZTISt9bad_alloc,_loc1_ + 4);
               si32(_loc10_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F___cxa_throw();
               _loc1_ += 16;
               §§goto(addr08d9);
            }
            addr094e:
            si32(_loc23_,_loc3_ + 4);
            si32(_loc25_,_loc3_ + 8);
            _loc1_ -= 16;
            si32(_loc29_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc1_ += 16;
            wdnative.eax = _loc3_;
            _loc1_ = _loc2_;
            wdnative.ESP = _loc1_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_81:* = this;
            var _temp_82:* = l;
            if(l.esp < _loc2_)
            {
               continue;
            }
         }
         §§goto(addr0a5a);
         wdnative.ESP = _loc1_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc7_ = int(l.sjid);
      }
   }
}

