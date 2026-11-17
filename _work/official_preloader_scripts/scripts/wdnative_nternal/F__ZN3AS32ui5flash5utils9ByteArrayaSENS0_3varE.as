package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import flash.utils.ByteArray;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.LongJmp;
   import wdnative.as3_id2rcv;
   import wdnative.as3_valAcquireId;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.setjmp;
   import wdnative.st0;
   
   public function F__ZN3AS32ui5flash5utils9ByteArrayaSENS0_3varE() : void
   {
      var _temp_1:* = this;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc1_:ByteArray = null;
      var _loc33_:int = 0;
      var _loc34_:int = 0;
      var _loc19_:int = 0;
      var _loc24_:int = 0;
      var _loc25_:int = 0;
      var _loc21_:int = 0;
      var _loc36_:int = 0;
      var _loc35_:int = 0;
      var _loc26_:int = 0;
      var _loc32_:int = 0;
      var _loc31_:int = 0;
      var _loc30_:int = 0;
      var _loc16_:int = 0;
      var _loc27_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc17_:int = 0;
      var _loc14_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc29_:int = 0;
      var _loc15_:Number = NaN;
      var _loc20_:int = 0;
      var _loc37_:int = 0;
      var _loc22_:int = 0;
      var _loc23_:int = 0;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = 0;
      var _loc28_:int = 0;
      var _loc18_:int = 0;
      var _loc4_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc13_)
            {
               _loc8_ = _loc4_;
               _loc4_ -= 96;
               _loc19_ = li32(wdnative_nternal._sUITID_2E_3986);
               si32(wdnative_nternal.L_LSDA_312,_loc8_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc8_ - 32);
               _loc37_ = _loc8_;
               si32(_loc37_,_loc8_ - 24);
               _loc37_ = _loc4_;
               si32(_loc37_,_loc8_ - 16);
               _loc36_ = _loc8_ - 56;
               _loc35_ = _loc36_ + 32;
               wdnative.eax = setjmp(_loc35_,1,_loc4_);
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
            _loc37_ = wdnative.eax;
            if(_loc37_ == 0)
            {
               _loc34_ = li32(_loc8_ + 4);
               _loc33_ = li32(_loc8_);
               _loc4_ -= 16;
               si32(_loc36_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative.F__Unwind_SjLj_Register();
               _loc4_ += 16;
               if(_loc19_ == -2)
               {
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F_uiThreadIdRaw();
                  _loc37_ = wdnative.eax;
                  si32(_loc37_,wdnative_nternal._sUITID_2E_3986);
                  if(_loc37_ >= 0)
                  {
                     si8(1,wdnative_nternal._sIsThreaded_2E_b);
                     addr017d:
                     _loc37_ = li32(wdnative_nternal._sUITID_2E_3986);
                     _loc32_ = int(realThreadId);
                     if(_loc32_ != _loc37_)
                     {
                        _loc31_ = _loc8_ - 96;
                        _loc30_ = _loc31_ | 4;
                        si32(0,_loc30_);
                        si32(0,_loc8_ - 68);
                        si32(0,_loc8_ - 72);
                        si32(0,_loc8_ - 76);
                        si32(0,_loc8_ - 80);
                        si32(0,_loc8_ - 84);
                        si32(0,_loc8_ - 88);
                        si32(0,_loc8_ - 96);
                        si32(8,_loc8_ - 88);
                        _loc4_ -= 16;
                        si32(0,_loc4_ + 4);
                        si32(wdnative_nternal.__ZN3AS32ui5flash5utils9ByteArrayaSENS0_3varE,_loc4_);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F__ZL9AS3_FPTR_cz();
                        _loc4_ += 16;
                        _loc37_ = wdnative.eax;
                        si32(_loc37_,_loc8_ - 96);
                        _loc37_ = _loc4_;
                        _loc37_ = _loc37_ + -16;
                        _loc32_ = _loc4_ = _loc37_ = _loc37_ & -16;
                        si32(_loc32_,_loc8_ - 16);
                        _loc32_ = _loc8_;
                        si32(_loc32_,_loc37_);
                        si32(_loc37_,_loc30_);
                        _loc16_ = _loc36_ | 4;
                        si32(-1,_loc16_);
                        _loc4_ -= 16;
                        si32(_loc31_,_loc4_ + 4);
                        si32(wdnative_nternal.__ZL18AS3_DELEGATE_THUNKPv,_loc4_);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F_avm2_ui_thunk();
                        _loc4_ += 16;
                        _loc24_ = wdnative.eax;
                        if(_loc24_ != -1)
                        {
                           si32(_loc24_,_loc8_ - 64);
                           _loc4_ -= 16;
                           si32(4,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative_nternal.F___cxa_allocate_exception();
                           _loc4_ += 16;
                           _loc25_ = wdnative.eax;
                           _loc37_ = li32(_loc8_ - 64);
                           si32(_loc37_,_loc25_);
                           _loc27_ = li32(_loc8_ - 64);
                           si32(1,_loc16_);
                           _loc4_ -= 16;
                           si32(_loc27_,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
                           _loc4_ += 16;
                           si32(2,_loc16_);
                           _loc4_ -= 16;
                           si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc4_ + 8);
                           si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc4_ + 4);
                           si32(_loc25_,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative_nternal.F___cxa_throw();
                           _loc4_ += 16;
                        }
                        _loc15_ = lf64(_loc8_ - 72);
                        _loc32_ = li32(_loc8_ - 76);
                        wdnative.eax = _loc29_ = li32(_loc8_ - 80);
                        wdnative.edx = _loc32_;
                        wdnative.st0 = _loc15_;
                        wdnative.ESP = _loc8_;
                        return;
                     }
                  }
               }
               else if(_loc19_ >= 0)
               {
                  §§goto(addr017d);
               }
               _loc37_ = li32(_loc34_);
               wdnative.ESP = _loc4_ & -16;
               try
               {
                  _loc1_ = wdnative.as3_id2rcv[_loc37_].val;
                  _loc20_ = wdnative.as3_valAcquireId(_loc1_);
                  _loc37_ = -1;
               }
               catch(e:*)
               {
                  var _temp_35:* = this;
                  var _temp_36:* = e;
                  _loc37_ = wdnative.as3_valAcquireId(e);
               }
               si32(_loc37_,_loc8_ - 60);
               _loc37_ = li32(_loc8_ - 60);
               if(_loc37_ != -1)
               {
                  _loc4_ -= 16;
                  si32(4,_loc4_);
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc4_ += 16;
                  _loc21_ = wdnative.eax;
                  _loc37_ = li32(_loc8_ - 60);
                  si32(_loc37_,_loc21_);
                  _loc22_ = _loc36_ | 4;
                  _loc23_ = li32(_loc8_ - 60);
                  si32(3,_loc22_);
                  _loc4_ -= 16;
                  si32(_loc23_,_loc4_);
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
                  _loc4_ += 16;
                  si32(4,_loc22_);
                  _loc4_ -= 16;
                  si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc4_ + 8);
                  si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc4_ + 4);
                  si32(_loc21_,_loc4_);
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F___cxa_throw();
                  _loc4_ += 16;
               }
               _loc32_ = li32(_loc33_);
               _loc37_ = _loc36_ | 4;
               si32(-1,_loc37_);
               _loc4_ -= 16;
               si32(_loc32_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
               _loc4_ += 16;
               si32(_loc20_,_loc33_);
               _loc4_ -= 16;
               si32(_loc36_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative.F__Unwind_SjLj_Unregister();
               _loc4_ += 16;
               wdnative.eax = _loc33_;
               wdnative.ESP = _loc4_ = _loc8_;
               return;
            }
            while(true)
            {
               _loc37_ = _loc36_ | 4;
               _loc26_ = li32(_loc37_);
               if(_loc26_ <= 2)
               {
                  if(_loc26_ != 0)
                  {
                     if(_loc26_ != 1)
                     {
                        if(_loc26_ != 2)
                        {
                           break;
                        }
                        _loc3_ = li32(_loc8_ - 48);
                        _loc5_ = li32(_loc8_ - 44);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F__ZSt9terminatev();
                        addr061b:
                        _loc2_ = li32(_loc8_ - 48);
                        _loc28_ = li32(_loc8_ - 44);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F__ZSt9terminatev();
                     }
                     else
                     {
                        _loc18_ = li32(_loc8_ - 48);
                        _loc17_ = li32(_loc8_ - 44);
                        _loc37_ = _loc36_ | 4;
                        _loc14_ = li32(_loc8_ - 64);
                        si32(5,_loc37_);
                        _loc4_ -= 16;
                        si32(_loc14_,_loc4_);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                        _loc4_ += 16;
                     }
                     continue;
                  }
                  _loc11_ = li32(_loc8_ - 48);
                  _loc12_ = li32(_loc8_ - 44);
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F__ZSt9terminatev();
                  addr0587:
                  _loc9_ = li32(_loc8_ - 48);
                  _loc10_ = li32(_loc8_ - 44);
                  wdnative.ESP = _loc4_;
                  wdnative_nternal.F__ZSt9terminatev();
               }
               else if(_loc26_ != 3)
               {
                  if(_loc26_ != 4)
                  {
                     if(_loc26_ != 5)
                     {
                        break;
                     }
                     §§goto(addr061b);
                  }
                  else
                  {
                     §§goto(addr0587);
                  }
               }
               _loc18_ = li32(_loc8_ - 48);
               _loc6_ = li32(_loc8_ - 44);
               _loc37_ = _loc36_ | 4;
               _loc7_ = li32(_loc8_ - 60);
               si32(6,_loc37_);
               _loc4_ -= 16;
               si32(_loc7_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
               _loc4_ += 16;
               _loc37_ = _loc36_ | 4;
               si32(-1,_loc37_);
               _loc4_ -= 16;
               si32(_loc18_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative.F__Unwind_SjLj_Resume();
               _loc4_ += 16;
            }
            while(true)
            {
            }
         }
         catch(l:LongJmp)
         {
            var _temp_57:* = this;
            var _temp_58:* = l;
            if(l.esp >= _loc8_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc4_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc13_ = int(l.sjid);
      }
   }
}

