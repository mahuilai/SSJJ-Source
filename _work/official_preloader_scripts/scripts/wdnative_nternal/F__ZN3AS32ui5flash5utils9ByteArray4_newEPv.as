package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import flash.utils.ByteArray;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.LongJmp;
   import wdnative.as3_valAcquireId;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.setjmp;
   import wdnative.st0;
   
   public function F__ZN3AS32ui5flash5utils9ByteArray4_newEPv() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc15_:int = 0;
      var _loc41_:int = 0;
      var _loc21_:int = 0;
      var _loc18_:int = 0;
      var _loc26_:int = 0;
      var _loc22_:int = 0;
      var _loc16_:int = 0;
      var _loc45_:int = 0;
      var _loc43_:int = 0;
      var _loc8_:int = 0;
      var _loc39_:int = 0;
      var _loc37_:int = 0;
      var _loc35_:int = 0;
      var _loc33_:int = 0;
      var _loc27_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc30_:int = 0;
      var _loc28_:int = 0;
      var _loc29_:int = 0;
      var _loc17_:Number = NaN;
      var _loc31_:int = 0;
      var _loc47_:int = 0;
      var _loc23_:int = 0;
      var _loc24_:int = 0;
      var _loc38_:int = 0;
      var _loc36_:int = 0;
      var _loc34_:int = 0;
      var _loc32_:int = 0;
      var _loc42_:int = 0;
      var _loc40_:int = 0;
      var _loc25_:int = 0;
      var _loc20_:int = 0;
      var _loc13_:int = 0;
      var _loc19_:int = 0;
      var _loc14_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc46_:int = 0;
      var _loc44_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc3_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc15_)
            {
               _loc7_ = _loc3_;
               _loc3_ -= 112;
               _loc21_ = li32(wdnative_nternal._sUITID_2E_3986);
               si32(wdnative_nternal.L_LSDA_315,_loc7_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc7_ - 32);
               _loc47_ = _loc7_;
               si32(_loc47_,_loc7_ - 24);
               _loc47_ = _loc3_;
               si32(_loc47_,_loc7_ - 16);
               _loc45_ = _loc7_ - 56;
               _loc43_ = _loc45_ + 32;
               wdnative.eax = setjmp(_loc43_,1,_loc3_);
            }
            else
            {
               switch(_loc15_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc47_ = wdnative.eax;
            if(_loc47_ == 0)
            {
               _loc41_ = li32(_loc7_);
               _loc3_ -= 16;
               si32(_loc45_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__Unwind_SjLj_Register();
               _loc3_ += 16;
               if(_loc21_ == -2)
               {
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_uiThreadIdRaw();
                  _loc47_ = wdnative.eax;
                  si32(_loc47_,wdnative_nternal._sUITID_2E_3986);
                  if(_loc47_ >= 0)
                  {
                     si8(1,wdnative_nternal._sIsThreaded_2E_b);
                     addr0192:
                     _loc39_ = li32(wdnative_nternal._sUITID_2E_3986);
                     _loc47_ = int(realThreadId);
                     if(_loc47_ != _loc39_)
                     {
                        _loc37_ = _loc7_ - 104;
                        _loc35_ = _loc37_ | 4;
                        si32(0,_loc35_);
                        si32(0,_loc7_ - 76);
                        si32(0,_loc7_ - 80);
                        si32(0,_loc7_ - 84);
                        si32(0,_loc7_ - 88);
                        si32(0,_loc7_ - 92);
                        si32(0,_loc7_ - 96);
                        si32(0,_loc7_ - 104);
                        si32(4,_loc7_ - 96);
                        _loc3_ -= 16;
                        si32(wdnative_nternal.__ZN3AS32ui5flash5utils9ByteArray4_newEPv,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F__ZL9AS3_FPTR_cz();
                        _loc3_ += 16;
                        _loc47_ = wdnative.eax;
                        si32(_loc47_,_loc7_ - 104);
                        _loc47_ = _loc3_;
                        _loc47_ = _loc47_ + -16;
                        _loc3_ = _loc47_ = _loc47_ & -16;
                        _loc39_ = _loc3_;
                        si32(_loc39_,_loc7_ - 16);
                        _loc39_ = _loc7_;
                        si32(_loc39_,_loc47_);
                        si32(_loc47_,_loc35_);
                        _loc33_ = _loc45_ | 4;
                        si32(-1,_loc33_);
                        _loc3_ -= 16;
                        si32(_loc37_,_loc3_ + 4);
                        si32(wdnative_nternal.__ZL18AS3_DELEGATE_THUNKPv,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_avm2_ui_thunk();
                        _loc3_ += 16;
                        _loc18_ = wdnative.eax;
                        if(_loc18_ != -1)
                        {
                           si32(_loc18_,_loc7_ - 68);
                           _loc3_ -= 16;
                           si32(4,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___cxa_allocate_exception();
                           _loc3_ += 16;
                           _loc26_ = wdnative.eax;
                           _loc47_ = li32(_loc7_ - 68);
                           si32(_loc47_,_loc26_);
                           _loc27_ = li32(_loc7_ - 68);
                           si32(1,_loc33_);
                           _loc3_ -= 16;
                           si32(_loc27_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
                           _loc3_ += 16;
                           si32(2,_loc33_);
                           _loc3_ -= 16;
                           si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc3_ + 8);
                           si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc3_ + 4);
                           si32(_loc26_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___cxa_throw();
                           _loc3_ += 16;
                        }
                        _loc17_ = lf64(_loc7_ - 80);
                        _loc39_ = li32(_loc7_ - 84);
                        wdnative.eax = _loc29_ = li32(_loc7_ - 88);
                        wdnative.edx = _loc39_;
                        wdnative.st0 = _loc17_;
                        wdnative.ESP = _loc7_;
                        return;
                     }
                  }
               }
               else if(_loc21_ >= 0)
               {
                  §§goto(addr0192);
               }
               wdnative.ESP = _loc3_ & -16;
               try
               {
                  _loc31_ = wdnative.as3_valAcquireId(new ByteArray());
                  _loc47_ = -1;
               }
               catch(e:*)
               {
                  var _temp_34:* = this;
                  var _temp_35:* = e;
                  _loc47_ = wdnative.as3_valAcquireId(e);
               }
               si32(_loc47_,_loc7_ - 64);
               _loc47_ = li32(_loc7_ - 64);
               if(_loc47_ != -1)
               {
                  _loc3_ -= 16;
                  si32(4,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc3_ += 16;
                  _loc22_ = wdnative.eax;
                  _loc47_ = li32(_loc7_ - 64);
                  si32(_loc47_,_loc22_);
                  _loc23_ = _loc45_ | 4;
                  _loc24_ = li32(_loc7_ - 64);
                  si32(3,_loc23_);
                  _loc3_ -= 16;
                  si32(_loc24_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
                  _loc3_ += 16;
                  si32(4,_loc23_);
                  _loc3_ -= 16;
                  si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc3_ + 8);
                  si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc3_ + 4);
                  si32(_loc22_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___cxa_throw();
                  _loc3_ += 16;
               }
               si32(_loc31_,_loc7_ - 60);
               _loc47_ = li32(_loc7_ - 60);
               si32(_loc47_,_loc41_);
               _loc25_ = _loc45_ | 4;
               _loc20_ = li32(_loc7_ - 60);
               si32(5,_loc25_);
               _loc3_ -= 16;
               si32(_loc20_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
               _loc3_ += 16;
            }
            else
            {
               loop1:
               while(true)
               {
                  while(true)
                  {
                     _loc47_ = _loc45_ | 4;
                     _loc8_ = li32(_loc47_);
                     if(_loc8_ <= 4)
                     {
                        if(_loc8_ <= 1)
                        {
                           if(_loc8_ != 0)
                           {
                              if(_loc8_ != 1)
                              {
                                 break loop1;
                              }
                              _loc5_ = li32(_loc7_ - 48);
                              _loc6_ = li32(_loc7_ - 44);
                              _loc47_ = _loc45_ | 4;
                              _loc2_ = li32(_loc7_ - 68);
                              si32(8,_loc47_);
                              _loc3_ -= 16;
                              si32(_loc2_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                              _loc3_ += 16;
                              continue loop1;
                           }
                           _loc4_ = li32(_loc7_ - 48);
                           _loc1_ = li32(_loc7_ - 44);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F__ZSt9terminatev();
                        }
                        else
                        {
                           if(_loc8_ == 2)
                           {
                              _loc38_ = li32(_loc7_ - 48);
                              _loc36_ = li32(_loc7_ - 44);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZSt9terminatev();
                              addr0694:
                              _loc42_ = li32(_loc7_ - 48);
                              _loc40_ = li32(_loc7_ - 44);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZSt9terminatev();
                              addr06b5:
                              _loc5_ = li32(_loc7_ - 48);
                              _loc46_ = li32(_loc7_ - 44);
                              _loc47_ = _loc45_ | 4;
                              _loc44_ = li32(_loc7_ - 60);
                              si32(10,_loc47_);
                              _loc3_ -= 16;
                              si32(_loc44_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                              _loc3_ += 16;
                              continue loop1;
                           }
                           if(_loc8_ == 3)
                           {
                              break;
                           }
                           if(_loc8_ != 4)
                           {
                              break loop1;
                           }
                           while(true)
                           {
                              _loc16_ = li32(_loc7_ - 48);
                              _loc13_ = li32(_loc7_ - 44);
                              _loc19_ = _loc45_ | 4;
                              _loc14_ = li32(_loc7_ - 60);
                              si32(7,_loc19_);
                              _loc3_ -= 16;
                              si32(_loc14_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                              _loc3_ += 16;
                              si32(6,_loc19_);
                              _loc3_ -= 16;
                              si32(_loc16_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.F__Unwind_SjLj_Resume();
                              _loc3_ += 16;
                           }
                        }
                     }
                     else
                     {
                        if(_loc8_ <= 6)
                        {
                           if(_loc8_ != 5)
                           {
                              if(_loc8_ != 6)
                              {
                                 break loop1;
                              }
                              §§goto(addr0546);
                           }
                        }
                        else
                        {
                           if(_loc8_ == 7)
                           {
                              addr0607:
                              _loc30_ = li32(_loc7_ - 48);
                              _loc28_ = li32(_loc7_ - 44);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZSt9terminatev();
                              break;
                           }
                           if(_loc8_ != 8)
                           {
                              if(_loc8_ != 9)
                              {
                                 break loop1;
                              }
                              _loc12_ = li32(_loc7_ - 48);
                              _loc10_ = li32(_loc7_ - 44);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__ZSt9terminatev();
                              continue loop1;
                           }
                           §§goto(addr0694);
                        }
                        §§goto(addr06b5);
                     }
                     §§goto(addr0607);
                  }
                  _loc47_ = _loc45_ | 4;
                  si32(-1,_loc47_);
                  _loc3_ -= 16;
                  si32(_loc5_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__Unwind_SjLj_Resume();
                  _loc3_ += 16;
                  _loc5_ = li32(_loc7_ - 48);
                  _loc34_ = li32(_loc7_ - 44);
                  _loc47_ = _loc45_ | 4;
                  _loc32_ = li32(_loc7_ - 64);
                  si32(9,_loc47_);
                  _loc3_ -= 16;
                  si32(_loc32_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                  _loc3_ += 16;
               }
               while(true)
               {
               }
            }
            addr0546:
            _loc9_ = li32(_loc7_ - 48);
            _loc11_ = li32(_loc7_ - 44);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F__ZSt9terminatev();
            _loc47_ = li32(_loc7_ - 60);
            si32(-1,_loc25_);
            _loc3_ -= 16;
            si32(_loc47_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
            _loc3_ += 16;
            _loc3_ -= 16;
            si32(_loc45_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc3_ += 16;
            _loc3_ = _loc7_;
            wdnative.ESP = _loc3_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_61:* = this;
            var _temp_62:* = l;
            if(l.esp >= _loc7_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc3_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc15_ = int(l.sjid);
      }
   }
}

