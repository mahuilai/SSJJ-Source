package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.ptr2fun;
   import wdnative.setjmp;
   
   public function F__ZN3AS32ui3var8internal7uiThunkEPv() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc4_:int = 0;
      var _loc9_:int = 0;
      var _loc25_:int = 0;
      var _loc23_:int = 0;
      var _loc18_:int = 0;
      var _loc17_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc22_:int = 0;
      var _loc21_:int = 0;
      var _loc20_:int = 0;
      var _loc3_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc24_:int = 0;
      var _loc5_:int = 0;
      var _loc19_:int = 0;
      var _loc16_:int = 0;
      var _loc7_:int = 0;
      var _loc15_:int = 0;
      var _loc1_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc4_)
            {
               _loc2_ = _loc1_;
               _loc1_ -= 80;
               _loc9_ = li32(_loc2_);
               _loc25_ = li32(_loc9_);
               _loc24_ = li32(_loc9_ + 4);
               _loc23_ = li32(_loc24_);
               _loc22_ = li32(_loc9_ + 8);
               si32(wdnative_nternal.L_LSDA_318,_loc2_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc2_ - 32);
               _loc24_ = _loc2_;
               si32(_loc24_,_loc2_ - 24);
               _loc24_ = _loc1_;
               si32(_loc24_,_loc2_ - 16);
               _loc21_ = _loc2_ - 56;
               _loc20_ = _loc21_ + 32;
               wdnative.eax = setjmp(_loc20_,1,_loc1_);
            }
            else
            {
               switch(_loc4_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc24_ = wdnative.eax;
            if(_loc24_ == 0)
            {
               _loc24_ = _loc22_ + 3;
               _loc19_ = _loc24_ >> 31;
               _loc19_ = _loc19_ >>> 30;
               _loc24_ += _loc19_;
               _loc18_ = _loc24_ >> 2;
               _loc6_ = wdnative_nternal.___avm2_apply3;
               _loc1_ -= 16;
               si32(_loc21_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative.F__Unwind_SjLj_Register();
               _loc1_ += 16;
               _loc24_ = _loc21_ | 4;
               si32(1,_loc24_);
               _loc1_ -= 16;
               si32(_loc18_,_loc1_ + 12);
               si32(_loc23_,_loc1_ + 8);
               si32(_loc25_,_loc1_ + 4);
               _loc14_ = _loc2_ - 72;
               si32(_loc14_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative.ptr2fun[_loc6_]();
               _loc1_ += 16;
               _loc24_ = li32(_loc2_ - 60);
               si32(_loc24_,_loc9_ + 28);
               _loc24_ = li32(_loc2_ - 64);
               si32(_loc24_,_loc9_ + 24);
               _loc24_ = li32(_loc2_ - 72);
               si32(_loc24_,_loc9_ + 16);
               _loc24_ = _loc14_ | 4;
               _loc24_ = li32(_loc24_);
               si32(_loc24_,_loc9_ + 20);
               _loc15_ = -1;
            }
            else
            {
               loop1:
               while(true)
               {
                  _loc24_ = _loc21_ | 4;
                  _loc3_ = li32(_loc24_);
                  if(_loc3_ != 0)
                  {
                     if(_loc3_ == 1)
                     {
                        break;
                     }
                     if(_loc3_ != 2)
                     {
                        while(true)
                        {
                        }
                     }
                     else
                     {
                        _loc24_ = li32(_loc2_ - 48);
                        _loc5_ = li32(_loc2_ - 44);
                        _loc1_ -= 16;
                        si32(_loc24_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc1_ += 16;
                     }
                  }
                  else
                  {
                     _loc12_ = li32(_loc2_ - 48);
                     _loc24_ = li32(_loc2_ - 44);
                     if(_loc24_ != 1)
                     {
                        continue;
                     }
                     addr02d7:
                     _loc16_ = wdnative_nternal.__ZL10eh_globals;
                     _loc24_ = li8(wdnative_nternal.__ZL4init + 4);
                     if(_loc24_ != 0)
                     {
                        while(true)
                        {
                           _loc17_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc17_ >= 0)
                           {
                              _loc24_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc24_ > _loc17_)
                              {
                                 _loc24_ = _loc17_ << 3;
                                 _loc19_ = li32(wdnative_nternal._sEntries);
                                 _loc24_ = _loc19_ + _loc24_;
                                 _loc16_ = li32(_loc24_);
                                 if(_loc16_ != 0)
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
                           _loc16_ = wdnative.eax;
                           if(_loc16_ != 0)
                           {
                              _loc10_ = li32(wdnative_nternal.__ZL4init);
                              if(_loc10_ >= 0)
                              {
                                 _loc24_ = li32(wdnative_nternal._sEntryCount);
                                 if(_loc24_ > _loc10_)
                                 {
                                    _loc24_ = _loc10_ << 3;
                                    _loc19_ = li32(wdnative_nternal._sEntries);
                                    _loc24_ = _loc19_ + _loc24_;
                                    si32(_loc16_,_loc24_);
                                    si32(0,_loc16_);
                                    si32(0,_loc16_ + 4);
                                    break;
                                 }
                              }
                           }
                           _loc24_ = _loc21_ | 4;
                           si32(2,_loc24_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F__ZSt9terminatev();
                           break loop1;
                        }
                     }
                     _loc24_ = li32(_loc12_ + 4);
                     _loc24_ = _loc24_ ^ 0x474E5543;
                     _loc19_ = li32(_loc12_);
                     _loc19_ = _loc19_ ^ 0x432B2B00;
                     _loc24_ = _loc19_ | _loc24_;
                     _loc13_ = _loc12_ + -48;
                     _loc8_ = li32(_loc16_);
                     if(_loc24_ != 0)
                     {
                        if(_loc8_ != 0)
                        {
                           _loc24_ = _loc21_ | 4;
                           si32(3,_loc24_);
                           wdnative.ESP = _loc1_;
                           wdnative_nternal.F__ZSt9terminatev();
                        }
                        si32(_loc13_,_loc16_);
                        _loc7_ = 0;
                     }
                     else
                     {
                        _loc19_ = li32(_loc12_ - 28);
                        _loc24_ = _loc19_ >> 31;
                        _loc19_ += _loc24_;
                        _loc24_ = _loc19_ ^ _loc24_;
                        _loc24_ = _loc24_ + 1;
                        si32(_loc24_,_loc12_ - 28);
                        _loc24_ = li32(_loc16_ + 4);
                        _loc24_ = _loc24_ + -1;
                        si32(_loc24_,_loc16_ + 4);
                        if(_loc13_ != _loc8_)
                        {
                           si32(_loc8_,_loc12_ - 32);
                           si32(_loc13_,_loc16_);
                        }
                        _loc7_ = li32(_loc12_ - 8);
                     }
                  }
                  _loc15_ = li32(_loc7_);
                  si32(0,_loc7_);
                  _loc24_ = _loc21_ | 4;
                  si32(-1,_loc24_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___cxa_end_catch();
                  _loc24_ = _loc21_ | 4;
                  si32(-1,_loc24_);
                  _loc1_ -= 16;
                  si32(_loc12_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative.F__Unwind_SjLj_Resume();
                  _loc1_ += 16;
               }
               _loc24_ = li32(_loc2_ - 48);
               _loc11_ = li32(_loc2_ - 44);
               _loc1_ -= 16;
               si32(_loc24_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F___cxa_call_unexpected();
               _loc1_ += 16;
               §§goto(addr02d7);
            }
            _loc1_ -= 16;
            si32(_loc21_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc1_ += 16;
            wdnative.eax = _loc15_;
            _loc1_ = _loc2_;
            wdnative.ESP = _loc1_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_55:* = this;
            var _temp_56:* = l;
            if(l.esp >= _loc2_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc1_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc4_ = int(l.sjid);
      }
   }
}

