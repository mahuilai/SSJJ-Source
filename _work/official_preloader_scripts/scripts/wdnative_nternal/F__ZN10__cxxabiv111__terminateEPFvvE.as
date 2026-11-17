package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.ptr2fun;
   import wdnative.setjmp;
   
   public function F__ZN10__cxxabiv111__terminateEPFvvE() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc10_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc18_:int = 0;
      var _loc17_:int = 0;
      var _loc2_:int = 0;
      var _loc14_:int = 0;
      var _loc4_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc13_:int = 0;
      var _loc3_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc10_)
            {
               _loc5_ = _loc3_;
               _loc3_ -= 64;
               si32(wdnative_nternal.L_LSDA_344,_loc5_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc5_ - 32);
               _loc4_ = _loc5_;
               si32(_loc4_,_loc5_ - 24);
               _loc4_ = _loc3_;
               si32(_loc4_,_loc5_ - 16);
               _loc18_ = _loc5_ - 56;
               _loc17_ = _loc18_ + 32;
               wdnative.eax = setjmp(_loc17_,1,_loc3_);
            }
            else
            {
               switch(_loc10_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc4_ = wdnative.eax;
            if(_loc4_ == 0)
            {
               _loc16_ = li32(_loc5_);
               _loc3_ -= 16;
               si32(_loc18_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__Unwind_SjLj_Register();
               _loc3_ += 16;
               _loc4_ = _loc18_ | 4;
               si32(1,_loc4_);
               wdnative.ESP = _loc3_;
               wdnative.ptr2fun[_loc16_]();
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_abort();
               loop1:
               while(true)
               {
                  _loc15_ = li32(_loc5_ - 48);
                  _loc14_ = li32(_loc5_ - 44);
                  _loc13_ = wdnative_nternal.__ZL10eh_globals;
                  _loc4_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc4_ != 0)
                  {
                     while(true)
                     {
                        _loc12_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc12_ >= 0)
                        {
                           _loc4_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc4_ > _loc12_)
                           {
                              _loc4_ = _loc12_ << 3;
                              _loc11_ = li32(wdnative_nternal._sEntries);
                              _loc4_ = _loc11_ + _loc4_;
                              _loc13_ = li32(_loc4_);
                              if(_loc13_ != 0)
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
                        _loc13_ = wdnative.eax;
                        if(_loc13_ != 0)
                        {
                           _loc1_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc1_ >= 0)
                           {
                              _loc4_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc4_ > _loc1_)
                              {
                                 _loc4_ = _loc1_ << 3;
                                 _loc11_ = li32(wdnative_nternal._sEntries);
                                 _loc4_ = _loc11_ + _loc4_;
                                 si32(_loc13_,_loc4_);
                                 si32(0,_loc13_);
                                 si32(0,_loc13_ + 4);
                                 break;
                              }
                           }
                        }
                        _loc4_ = _loc18_ | 4;
                        si32(2,_loc4_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F__ZSt9terminatev();
                        _loc4_ = li32(_loc5_ - 48);
                        _loc6_ = li32(_loc5_ - 44);
                        _loc3_ -= 16;
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc3_ += 16;
                        break;
                     }
                  }
                  while(true)
                  {
                     _loc4_ = li32(_loc15_ + 4);
                     _loc4_ = _loc4_ ^ 0x474E5543;
                     _loc11_ = li32(_loc15_);
                     _loc11_ = _loc11_ ^ 0x432B2B00;
                     _loc4_ = _loc11_ | _loc4_;
                     _loc7_ = _loc15_ + -48;
                     _loc8_ = li32(_loc13_);
                     if(_loc4_ != 0)
                     {
                        if(_loc8_ != 0)
                        {
                           _loc4_ = _loc18_ | 4;
                           si32(3,_loc4_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F__ZSt9terminatev();
                        }
                        si32(_loc7_,_loc13_);
                     }
                     else
                     {
                        _loc11_ = li32(_loc15_ - 28);
                        _loc4_ = _loc11_ >> 31;
                        _loc11_ += _loc4_;
                        _loc4_ = _loc11_ ^ _loc4_;
                        _loc4_ = _loc4_ + 1;
                        si32(_loc4_,_loc15_ - 28);
                        _loc4_ = li32(_loc13_ + 4);
                        _loc4_ = _loc4_ + -1;
                        si32(_loc4_,_loc13_ + 4);
                        if(_loc7_ != _loc8_)
                        {
                           si32(_loc8_,_loc15_ - 32);
                           si32(_loc7_,_loc13_);
                        }
                     }
                     addr0327:
                     while(true)
                     {
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_abort();
                        continue loop1;
                        _loc4_ = li32(_loc5_ - 48);
                        _loc9_ = li32(_loc5_ - 44);
                        _loc3_ -= 16;
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc3_ += 16;
                     }
                     break;
                     _loc4_ = li32(_loc5_ - 48);
                     _loc6_ = li32(_loc5_ - 44);
                     _loc3_ -= 16;
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc3_ += 16;
                  }
                  break;
               }
               addr0395:
               throw l;
               addr010d:
            }
            _loc4_ = _loc18_ | 4;
            _loc2_ = li32(_loc4_);
            if(_loc2_ != 0)
            {
               if(_loc2_ != 1)
               {
                  if(_loc2_ == 2)
                  {
                     _loc4_ = li32(_loc5_ - 48);
                     _loc9_ = li32(_loc5_ - 44);
                     _loc3_ -= 16;
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc3_ += 16;
                     §§goto(addr0327);
                  }
                  while(true)
                  {
                  }
               }
               §§goto(addr0201);
            }
            §§goto(addr010d);
         }
         catch(l:LongJmp)
         {
            var _temp_41:* = this;
            var _temp_42:* = l;
            if(l.esp < _loc5_)
            {
               continue;
            }
         }
         §§goto(addr0395);
         wdnative.ESP = _loc3_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc10_ = int(l.sjid);
      }
   }
}

