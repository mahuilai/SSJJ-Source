package wdnative.shoot_decoder
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   import wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj;
   import wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj;
   import wdnative_nternal.F__ZN3AS32ui5flash5utils9ByteArray4_newEPv;
   import wdnative_nternal.F__ZN3AS32ui5flash5utils9ByteArrayC1ENS0_3varE;
   import wdnative_nternal.F__ZN3AS32ui6StringaSENS0_3varE;
   import wdnative_nternal.F__ZN3AS32ui8internal10new_StringEPKci;
   import wdnative_nternal.F__ZN3AS32ui8internal13utf8_toStringENS0_3varE;
   import wdnative_nternal.F__ZN3AS32ui8internal7get_ramEv;
   import wdnative_nternal.F__ZNSs12_S_constructIPKcEEPcT_S3_RKSaIcESt20forward_iterator_tag;
   import wdnative_nternal.F__ZSt9terminatev;
   import wdnative_nternal.F_idalloc;
   import wdnative_nternal.L_LSDA_22;
   import wdnative_nternal.L__2E_str324;
   import wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE;
   import wdnative_nternal.___gxx_personality_sj0;
   
   public function load#286(param1:int, param2:int) : void
   {
      var _temp_1:* = this;
      var _loc29_:* = undefined;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc61_:int = 0;
      var _loc34_:int = 0;
      var _loc33_:int = 0;
      var _loc36_:int = 0;
      var _loc42_:int = 0;
      var _loc40_:int = 0;
      var _loc46_:int = 0;
      var _loc9_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc19_:int = 0;
      var _loc18_:int = 0;
      var _loc73_:int = 0;
      var _loc90_:int = 0;
      var _loc68_:int = 0;
      var _loc32_:int = 0;
      var _loc49_:int = 0;
      var _loc43_:int = 0;
      var _loc41_:int = 0;
      var _loc39_:int = 0;
      var _loc6_:int = 0;
      var _loc37_:int = 0;
      var _loc35_:int = 0;
      var _loc74_:int = 0;
      var _loc76_:int = 0;
      var _loc78_:int = 0;
      var _loc80_:int = 0;
      var _loc24_:int = 0;
      var _loc84_:int = 0;
      var _loc65_:int = 0;
      var _loc81_:int = 0;
      var _loc72_:int = 0;
      var _loc71_:int = 0;
      var _loc63_:int = 0;
      var _loc62_:int = 0;
      var _loc64_:int = 0;
      var _loc57_:int = 0;
      var _loc59_:int = 0;
      var _loc53_:int = 0;
      var _loc55_:int = 0;
      var _loc47_:int = 0;
      var _loc51_:int = 0;
      var _loc50_:int = 0;
      var _loc48_:int = 0;
      var _loc11_:int = 0;
      var _loc86_:int = 0;
      var _loc85_:int = 0;
      var _loc60_:int = 0;
      var _loc58_:int = 0;
      var _loc10_:int = 0;
      var _loc17_:int = 0;
      var _loc54_:int = 0;
      var _loc52_:int = 0;
      var _loc70_:int = 0;
      var _loc69_:int = 0;
      var _loc75_:int = 0;
      var _loc38_:int = 0;
      var _loc77_:int = 0;
      var _loc88_:int = 0;
      var _loc87_:int = 0;
      var _loc56_:int = 0;
      var _loc27_:int = 0;
      var _loc28_:int = 0;
      var _loc22_:int = 0;
      var _loc23_:int = 0;
      var _loc67_:int = 0;
      var _loc31_:int = 0;
      var _loc5_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc66_:int = 0;
      var _loc30_:int = 0;
      var _loc25_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc82_:int = 0;
      var _loc45_:int = 0;
      var _loc44_:int = 0;
      var _loc14_:int = 0;
      var _loc79_:int = 0;
      var _loc89_:int = 0;
      var _loc83_:int = 0;
      var _loc26_:int = 0;
      var _loc7_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc13_)
            {
               _loc8_ = _loc7_;
               _loc7_ -= 128;
               _loc32_ = param1;
               _loc49_ = param2;
               trace("load buffersize" + param2);
               _loc7_ -= 16;
               _loc47_ = _loc8_ - 120;
               si32(_loc47_,_loc7_);
               _loc45_ = 0;
               si32(_loc45_,_loc7_ + 4);
               wdnative.ESP = _loc7_;
               wdnative_nternal.F__ZN3AS32ui5flash5utils9ByteArray4_newEPv();
               _loc7_ += 16;
               _loc43_ = _loc8_ - 112;
               si32(_loc43_,_loc8_ - 76);
               _loc47_ = li32(_loc8_ - 76);
               si32(1,_loc47_);
               si32(wdnative_nternal.L_LSDA_22,_loc8_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc8_ - 32);
               _loc47_ = _loc8_;
               si32(_loc47_,_loc8_ - 24);
               _loc47_ = _loc7_;
               si32(_loc47_,_loc8_ - 16);
               _loc41_ = _loc8_ - 56;
               _loc39_ = _loc41_ + 32;
               wdnative.eax = setjmp(_loc39_,1,_loc7_);
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
            _loc47_ = wdnative.eax;
            if(_loc47_ != 0)
            {
               while(true)
               {
                  _loc47_ = _loc41_ | 4;
                  _loc6_ = li32(_loc47_);
                  if(_loc6_ <= 11)
                  {
                     if(_loc6_ <= 5)
                     {
                        if(_loc6_ <= 2)
                        {
                           if(_loc6_ != 0)
                           {
                              if(_loc6_ != 1)
                              {
                                 if(_loc6_ != 2)
                                 {
                                    while(true)
                                    {
                                    }
                                    addr10bc:
                                 }
                              }
                              else
                              {
                                 _loc82_ = li32(_loc8_ - 48);
                                 _loc74_ = li32(_loc8_ - 44);
                                 _loc47_ = _loc41_ | 4;
                                 _loc76_ = li32(_loc8_ - 104);
                                 si32(5,_loc47_);
                                 _loc7_ -= 16;
                                 si32(_loc76_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                                 _loc7_ += 16;
                                 _loc47_ = li32(_loc8_ - 76);
                                 _loc65_ = li32(_loc47_);
                                 _loc81_ = _loc41_ | 4;
                                 si32(6,_loc81_);
                                 _loc7_ -= 16;
                                 si32(_loc65_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                                 _loc7_ += 16;
                                 si32(4,_loc81_);
                                 _loc7_ -= 16;
                                 si32(_loc82_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative.F__Unwind_SjLj_Resume();
                                 _loc7_ += 16;
                              }
                           }
                           while(true)
                           {
                              _loc82_ = li32(_loc8_ - 48);
                              _loc84_ = li32(_loc8_ - 44);
                              _loc47_ = li32(_loc8_ - 76);
                              _loc65_ = li32(_loc47_);
                              _loc81_ = _loc41_ | 4;
                              si32(6,_loc81_);
                              _loc7_ -= 16;
                              si32(_loc65_,_loc7_);
                              wdnative.ESP = _loc7_;
                              wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                              _loc7_ += 16;
                              si32(4,_loc81_);
                              _loc7_ -= 16;
                              si32(_loc82_,_loc7_);
                              wdnative.ESP = _loc7_;
                              wdnative.F__Unwind_SjLj_Resume();
                              _loc7_ += 16;
                           }
                           break;
                        }
                        if(_loc6_ != 3)
                        {
                           if(_loc6_ != 4)
                           {
                              if(_loc6_ != 5)
                              {
                                 §§goto(addr10bc);
                              }
                           }
                           else
                           {
                              _loc78_ = li32(_loc8_ - 48);
                              _loc80_ = li32(_loc8_ - 44);
                              wdnative.ESP = _loc7_;
                              wdnative_nternal.F__ZSt9terminatev();
                           }
                           _loc72_ = li32(_loc8_ - 48);
                           _loc71_ = li32(_loc8_ - 44);
                           wdnative.ESP = _loc7_;
                           wdnative_nternal.F__ZSt9terminatev();
                           §§goto(addr0403);
                        }
                        else
                        {
                           _loc83_ = li32(_loc8_ - 120);
                        }
                     }
                     else
                     {
                        if(_loc6_ <= 8)
                        {
                           if(_loc6_ != 6)
                           {
                              if(_loc6_ != 7)
                              {
                                 if(_loc6_ != 8)
                                 {
                                    §§goto(addr10bc);
                                 }
                                 else
                                 {
                                    _loc59_ = li32(_loc8_ - 48);
                                    _loc53_ = li32(_loc8_ - 44);
                                    wdnative.ESP = _loc7_;
                                    wdnative_nternal.F__ZSt9terminatev();
                                    §§goto(addr0530);
                                 }
                              }
                              else
                              {
                                 addr0da7:
                                 _loc26_ = li32(_loc8_ - 48);
                                 _loc31_ = li32(_loc8_ - 44);
                              }
                           }
                           else
                           {
                              while(true)
                              {
                                 _loc61_ = li32(_loc8_ - 48);
                                 _loc62_ = li32(_loc8_ - 44);
                                 _loc64_ = _loc41_ | 4;
                                 _loc57_ = li32(_loc8_ - 72);
                                 si32(9,_loc64_);
                                 _loc7_ -= 16;
                                 si32(_loc57_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                                 _loc7_ += 16;
                                 si32(8,_loc64_);
                                 _loc7_ -= 16;
                                 si32(_loc61_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative.F__Unwind_SjLj_Resume();
                                 _loc7_ += 16;
                              }
                           }
                        }
                        else if(_loc6_ != 9)
                        {
                           if(_loc6_ != 10)
                           {
                              if(_loc6_ != 11)
                              {
                                 §§goto(addr10bc);
                              }
                              else
                              {
                                 _loc48_ = li32(_loc8_ - 48);
                                 _loc11_ = li32(_loc8_ - 44);
                                 _loc47_ = _loc41_ | 4;
                                 si32(13,_loc47_);
                                 _loc7_ -= 16;
                                 si32(_loc48_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative.F__Unwind_SjLj_Resume();
                                 _loc7_ += 16;
                                 §§goto(addr0794);
                              }
                           }
                           else
                           {
                              addr0b3d:
                              _loc89_ = li32(_loc8_ - 48);
                              _loc86_ = li32(_loc8_ - 44);
                              _loc47_ = li32(_loc8_ - 68);
                              _loc85_ = li32(_loc47_);
                              _loc47_ = _loc41_ | 4;
                              si32(19,_loc47_);
                              _loc7_ -= 16;
                              si32(_loc85_,_loc7_);
                              wdnative.ESP = _loc7_;
                              wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                              _loc7_ += 16;
                              addr0cb2:
                              _loc47_ = _loc41_ | 4;
                              si32(21,_loc47_);
                              _loc7_ -= 16;
                              si32(_loc89_,_loc7_);
                              wdnative.ESP = _loc7_;
                              wdnative.F__Unwind_SjLj_Resume();
                              _loc7_ += 16;
                           }
                           §§goto(addr0ce7);
                        }
                        else
                        {
                           addr0dbd:
                           _loc26_ = li32(_loc8_ - 48);
                           _loc27_ = li32(_loc8_ - 44);
                           _loc47_ = _loc41_ | 4;
                           _loc28_ = li32(_loc8_ - 72);
                           si32(24,_loc47_);
                           _loc7_ -= 16;
                           si32(_loc28_,_loc7_);
                           wdnative.ESP = _loc7_;
                           wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                           _loc7_ += 16;
                        }
                        addr0eab:
                        _loc47_ = li32(_loc8_ - 76);
                        _loc5_ = li32(_loc47_);
                        _loc47_ = _loc41_ | 4;
                        si32(26,_loc47_);
                        _loc7_ -= 16;
                        si32(_loc5_,_loc7_);
                        wdnative.ESP = _loc7_;
                        wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                        _loc7_ += 16;
                        _loc83_ = li32(_loc8_ - 72);
                        addr0e73:
                        _loc25_ = _loc41_ | 4;
                        si32(25,_loc25_);
                        _loc7_ -= 16;
                        si32(_loc83_,_loc7_);
                        wdnative.ESP = _loc7_;
                        wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                        _loc7_ += 16;
                        si32(-1,_loc25_);
                        _loc7_ -= 16;
                        si32(_loc26_,_loc7_);
                        wdnative.ESP = _loc7_;
                        wdnative.F__Unwind_SjLj_Resume();
                        _loc7_ += 16;
                     }
                     while(true)
                     {
                        _loc26_ = li32(_loc8_ - 48);
                        _loc30_ = li32(_loc8_ - 44);
                     }
                     break;
                     addr0d92:
                  }
                  else if(_loc6_ <= 18)
                  {
                     while(true)
                     {
                        if(_loc6_ <= 14)
                        {
                           if(_loc6_ != 12)
                           {
                              if(_loc6_ != 13)
                              {
                                 if(_loc6_ != 14)
                                 {
                                    §§goto(addr10bc);
                                 }
                                 else
                                 {
                                    addr0bb4:
                                    _loc89_ = li32(_loc8_ - 48);
                                    _loc56_ = li32(_loc8_ - 44);
                                 }
                              }
                              else
                              {
                                 §§goto(addr0dbd);
                              }
                           }
                           else
                           {
                              §§goto(addr0b3d);
                           }
                        }
                        else if(_loc6_ != 15)
                        {
                           _loc47_ = _loc6_ + -16;
                           if((uint(_loc47_)) >= 2)
                           {
                              if(_loc6_ != 18)
                              {
                                 §§goto(addr10bc);
                              }
                              else
                              {
                                 _loc60_ = li32(_loc8_ - 48);
                                 _loc58_ = li32(_loc8_ - 44);
                                 wdnative.ESP = _loc7_;
                                 wdnative_nternal.F__ZSt9terminatev();
                              }
                           }
                           §§goto(addr0bb4);
                        }
                        else
                        {
                           _loc89_ = li32(_loc8_ - 48);
                           _loc54_ = li32(_loc8_ - 44);
                           _loc47_ = _loc41_ | 4;
                           _loc52_ = li32(_loc8_ - 60);
                           si32(20,_loc47_);
                           _loc7_ -= 16;
                           si32(_loc52_,_loc7_);
                           wdnative.ESP = _loc7_;
                           wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                           _loc7_ += 16;
                        }
                        addr0c3d:
                        _loc47_ = li32(_loc8_ - 64);
                        _loc68_ = _loc47_ + -12;
                        if(_loc68_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
                        {
                           _loc38_ = li32(_loc8_ - 64);
                           _loc47_ = li32(_loc38_ - 4);
                           _loc77_ = li32(_loc38_ - 4);
                           _loc77_ = _loc77_ + -1;
                           si32(_loc77_,_loc38_ - 4);
                           if(_loc47_ <= 0)
                           {
                              if(_loc68_ != 0)
                              {
                                 _loc7_ -= 16;
                                 si32(_loc68_,_loc7_);
                                 wdnative.ESP = _loc7_;
                                 wdnative_nternal.F_idalloc();
                                 _loc7_ += 16;
                              }
                           }
                        }
                        break;
                     }
                     §§goto(addr0cb2);
                  }
                  else if(_loc6_ <= 21)
                  {
                     if(_loc6_ != 19)
                     {
                        if(_loc6_ != 20)
                        {
                           if(_loc6_ != 21)
                           {
                              §§goto(addr10bc);
                           }
                           else
                           {
                              §§goto(addr0da7);
                           }
                        }
                        else
                        {
                           §§goto(addr0dbd);
                        }
                        §§goto(addr0eab);
                     }
                     else
                     {
                        _loc70_ = li32(_loc8_ - 48);
                        _loc69_ = li32(_loc8_ - 44);
                        wdnative.ESP = _loc7_;
                        wdnative_nternal.F__ZSt9terminatev();
                        §§goto(addr0c3d);
                     }
                  }
                  else
                  {
                     while(true)
                     {
                        if(_loc6_ <= 23)
                        {
                           if(_loc6_ == 22)
                           {
                              _loc83_ = li32(_loc8_ - 72);
                              break;
                           }
                           if(_loc6_ != 23)
                           {
                              §§goto(addr10bc);
                           }
                           else
                           {
                              _loc22_ = li32(_loc8_ - 48);
                              _loc23_ = li32(_loc8_ - 44);
                              wdnative.ESP = _loc7_;
                              wdnative_nternal.F__ZSt9terminatev();
                              addr0e30:
                              _loc20_ = li32(_loc8_ - 48);
                              _loc21_ = li32(_loc8_ - 44);
                              wdnative.ESP = _loc7_;
                              wdnative_nternal.F__ZSt9terminatev();
                           }
                        }
                        else if(_loc6_ != 24)
                        {
                           if(_loc6_ != 25)
                           {
                              §§goto(addr10bc);
                           }
                           else
                           {
                              §§goto(addr0e30);
                           }
                        }
                        _loc3_ = li32(_loc8_ - 48);
                        _loc4_ = li32(_loc8_ - 44);
                        wdnative.ESP = _loc7_;
                        wdnative_nternal.F__ZSt9terminatev();
                     }
                     §§goto(addr0d92);
                  }
                  §§goto(addr0e73);
               }
               §§goto(addr10f8);
            }
            _loc7_ -= 16;
            si32(_loc41_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__Unwind_SjLj_Register();
            _loc7_ += 16;
            _loc37_ = _loc41_ | 4;
            si32(1,_loc37_);
            _loc7_ -= 16;
            si32(-1,_loc7_ + 8);
            si32(wdnative_nternal.L__2E_str324,_loc7_ + 4);
            _loc35_ = _loc8_ - 104;
            si32(_loc35_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui8internal10new_StringEPKci();
            _loc7_ += 16;
            si32(2,_loc37_);
            _loc7_ -= 16;
            si32(_loc35_,_loc7_ + 4);
            si32(_loc43_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui6StringaSENS0_3varE();
            _loc7_ += 16;
            _loc24_ = li32(_loc8_ - 104);
            si32(3,_loc37_);
            _loc7_ -= 16;
            si32(_loc24_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc47_ = li32(_loc8_ - 120);
            si32(_loc47_,_loc8_ - 72);
            _loc63_ = li32(_loc8_ - 72);
            si32(7,_loc37_);
            _loc7_ -= 16;
            si32(_loc63_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
            _loc7_ += 16;
            addr0530:
            trace("allocate string");
            _loc55_ = _loc8_ - 88;
            si32(_loc55_,_loc8_ - 68);
            _loc47_ = li32(_loc8_ - 76);
            _loc51_ = li32(_loc47_);
            _loc47_ = li32(_loc8_ - 68);
            si32(_loc51_,_loc47_);
            si32(10,_loc37_);
            _loc7_ -= 16;
            si32(_loc51_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
            _loc7_ += 16;
            si32(11,_loc37_);
            _loc7_ -= 16;
            si32(_loc55_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui8internal13utf8_toStringENS0_3varE();
            _loc7_ += 16;
            _loc34_ = wdnative.eax;
            if(_loc34_ != 0)
            {
               _loc33_ = _loc34_ & -4;
               _loc38_ = li32(_loc33_);
               _loc47_ = _loc38_ + -16843009;
               _loc38_ &= -2139062144;
               _loc38_ = _loc38_ ^ -2139062144;
               _loc47_ = _loc38_ & _loc47_;
               if(_loc47_ != 0)
               {
                  _loc36_ = _loc33_ + 4;
                  while(true)
                  {
                     _loc42_ = _loc34_ + _loc45_;
                     if((uint(_loc42_)) < uint(_loc36_))
                     {
                        _loc47_ = li8(_loc42_);
                        if(_loc47_ == 0)
                        {
                           break;
                        }
                        _loc45_ += 1;
                        continue;
                     }
                  }
                  §§goto(addr06f9);
               }
               _loc40_ = _loc33_ + 4;
               while(true)
               {
                  _loc46_ = li32(_loc40_);
                  _loc47_ = _loc46_ + -16843009;
                  _loc38_ = _loc46_ & -2139062144;
                  _loc38_ = _loc38_ ^ -2139062144;
                  _loc47_ = _loc38_ & _loc47_;
                  if(_loc47_ != 0)
                  {
                     _loc47_ = _loc46_ & 0xFF;
                     if(_loc47_ == 0)
                     {
                        _loc45_ = _loc40_ - _loc34_;
                        break;
                     }
                     _loc47_ = li8(_loc40_ + 1);
                     if(_loc47_ == 0)
                     {
                        _loc47_ = 1 - _loc34_;
                        _loc45_ = _loc47_ + _loc40_;
                        break;
                     }
                     _loc47_ = li8(_loc40_ + 2);
                     if(_loc47_ == 0)
                     {
                        _loc47_ = 2 - _loc34_;
                        _loc45_ = _loc47_ + _loc40_;
                        break;
                     }
                     _loc47_ = li8(_loc40_ + 3);
                     if(_loc47_ == 0)
                     {
                        _loc47_ = 3 - _loc34_;
                        _loc45_ = _loc47_ + _loc40_;
                        break;
                     }
                  }
                  _loc40_ += 4;
               }
               addr06f9:
               _loc44_ = _loc34_ + _loc45_;
               §§goto(addr070f);
            }
            else
            {
               _loc44_ = _loc34_ + -1;
            }
            addr070f:
            si32(12,_loc37_);
            _loc7_ -= 16;
            si32(_loc44_,_loc7_ + 4);
            si32(_loc34_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZNSs12_S_constructIPKcEEPcT_S3_RKSaIcESt20forward_iterator_tag();
            _loc7_ += 16;
            _loc50_ = wdnative.eax;
            addr0794:
            si32(_loc50_,_loc8_ - 64);
            if(_loc34_ != 0)
            {
               _loc7_ -= 16;
               si32(_loc34_,_loc7_);
               wdnative.ESP = _loc7_;
               wdnative_nternal.F_idalloc();
               _loc7_ += 16;
            }
            _loc47_ = li32(_loc8_ - 68);
            _loc10_ = li32(_loc47_);
            si32(14,_loc37_);
            _loc7_ -= 16;
            si32(_loc10_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc9_ = li32(_loc8_ - 64);
            _loc16_ = _loc9_ & -4;
            _loc38_ = li32(_loc16_);
            _loc47_ = _loc38_ + -16843009;
            _loc38_ &= -2139062144;
            _loc38_ = _loc38_ ^ -2139062144;
            _loc47_ = _loc38_ & _loc47_;
            if(_loc47_ != 0)
            {
               _loc15_ = _loc16_ + 4;
               _loc14_ = 0;
               while(true)
               {
                  _loc47_ = li32(_loc8_ - 64);
                  _loc12_ = _loc47_ + _loc14_;
                  if((uint(_loc12_)) < uint(_loc15_))
                  {
                     _loc47_ = li8(_loc12_);
                     if(_loc47_ == 0)
                     {
                        break;
                     }
                     _loc14_ += 1;
                     continue;
                  }
               }
               §§goto(addr0944);
            }
            _loc19_ = _loc16_ + 4;
            while(true)
            {
               _loc18_ = li32(_loc19_);
               _loc47_ = _loc18_ + -16843009;
               _loc38_ = _loc18_ & -2139062144;
               _loc38_ = _loc38_ ^ -2139062144;
               _loc47_ = _loc38_ & _loc47_;
               if(_loc47_ != 0)
               {
                  _loc47_ = _loc18_ & 0xFF;
                  if(_loc47_ == 0)
                  {
                     _loc14_ = _loc19_ - _loc9_;
                     break;
                  }
                  _loc47_ = li8(_loc19_ + 1);
                  if(_loc47_ == 0)
                  {
                     _loc47_ = 1 - _loc9_;
                     _loc14_ = _loc47_ + _loc19_;
                     break;
                  }
                  _loc47_ = li8(_loc19_ + 2);
                  if(_loc47_ == 0)
                  {
                     _loc47_ = 2 - _loc9_;
                     _loc14_ = _loc47_ + _loc19_;
                     break;
                  }
                  _loc47_ = li8(_loc19_ + 3);
                  if(_loc47_ == 0)
                  {
                     _loc47_ = 3 - _loc9_;
                     _loc14_ = _loc47_ + _loc19_;
                     break;
                  }
               }
               _loc19_ += 4;
            }
            addr0944:
            si32(15,_loc37_);
            _loc7_ -= 16;
            _loc47_ = _loc8_ - 80;
            si32(_loc47_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui8internal7get_ramEv();
            _loc7_ += 16;
            _loc47_ = li32(_loc8_ - 80);
            si32(_loc47_,_loc8_ - 60);
            _loc17_ = li32(_loc8_ - 60);
            si32(16,_loc37_);
            _loc7_ -= 16;
            si32(_loc17_,_loc7_ + 4);
            _loc47_ = _loc8_ - 96;
            si32(_loc47_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui5flash5utils9ByteArrayC1ENS0_3varE();
            _loc7_ += 16;
            _loc75_ = li32(_loc8_ - 60);
            si32(17,_loc37_);
            _loc7_ -= 16;
            si32(_loc75_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            trace("start decode");
            if(_loc49_ >= 1)
            {
               _loc73_ = _loc14_ + -1;
               _loc79_ = 0;
               do
               {
                  _loc38_ = _loc73_ - _loc79_;
                  _loc47_ = li8(_loc32_);
                  _loc77_ = li32(_loc8_ - 64);
                  _loc38_ = _loc77_ + _loc38_;
                  _loc38_ = li8(_loc38_);
                  _loc47_ = _loc38_ ^ _loc47_;
                  si8(_loc47_,_loc32_);
                  _loc88_ = _loc79_ + 1;
                  _loc79_ = 0;
                  if(_loc88_ != _loc14_)
                  {
                     _loc79_ = _loc88_;
                  }
                  _loc32_ += 1;
               }
               while(_loc49_ += -1, _loc49_ != 0);
            }
            trace("start read Bytes");
            trace("read Bytes end");
            _loc87_ = li32(_loc8_ - 96);
            si32(18,_loc37_);
            _loc7_ -= 16;
            si32(_loc87_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc47_ = li32(_loc8_ - 64);
            _loc90_ = _loc47_ + -12;
            if(_loc90_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
            {
               _loc38_ = li32(_loc8_ - 64);
               _loc47_ = li32(_loc38_ - 4);
               _loc77_ = li32(_loc38_ - 4);
               _loc77_ = _loc77_ + -1;
               si32(_loc77_,_loc38_ - 4);
               if(_loc47_ <= 0)
               {
                  if(_loc90_ != 0)
                  {
                     _loc7_ -= 16;
                     si32(_loc90_,_loc7_);
                     wdnative.ESP = _loc7_;
                     wdnative_nternal.F_idalloc();
                     _loc7_ += 16;
                  }
               }
            }
            addr0ce7:
            _loc67_ = li32(_loc8_ - 72);
            si32(22,_loc37_);
            _loc7_ -= 16;
            si32(_loc67_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc47_ = li32(_loc8_ - 76);
            _loc66_ = li32(_loc47_);
            si32(23,_loc37_);
            _loc7_ -= 16;
            si32(_loc66_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc47_ = li32(_loc8_ - 72);
            si32(-1,_loc37_);
            _loc7_ -= 16;
            si32(_loc47_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc7_ += 16;
            _loc7_ = _loc7_ - 16;
            si32(_loc41_,_loc7_);
            wdnative.ESP = _loc7_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc7_ += 16;
            wdnative.ESP = _loc7_ = _loc8_;
            return _loc29_;
            §§goto(addr0ce7);
         }
         catch(l:LongJmp)
         {
            var _temp_131:* = this;
            var _temp_132:* = l;
            if(l.esp < _loc8_)
            {
               continue;
            }
         }
         addr10f8:
         throw l;
         wdnative.ESP = _loc7_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc13_ = int(l.sjid);
      }
   }
}

