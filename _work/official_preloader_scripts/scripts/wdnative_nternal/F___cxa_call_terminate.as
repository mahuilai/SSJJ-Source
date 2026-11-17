package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F___cxa_call_terminate() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc7_:int = 0;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc2_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc8_)
            {
               _loc4_ = _loc2_;
               _loc2_ -= 64;
               si32(wdnative_nternal.L_LSDA_395,_loc4_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc4_ - 32);
               _loc3_ = _loc4_;
               si32(_loc3_,_loc4_ - 24);
               _loc3_ = _loc2_;
               si32(_loc3_,_loc4_ - 16);
               _loc16_ = _loc4_ - 56;
               _loc15_ = _loc16_ + 32;
               wdnative.eax = setjmp(_loc15_,1,_loc2_);
            }
            else
            {
               switch(_loc8_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc3_ = wdnative.eax;
            if(_loc3_ == 0)
            {
               _loc14_ = li32(_loc4_);
               _loc2_ -= 16;
               si32(_loc16_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F__Unwind_SjLj_Register();
               _loc2_ += 16;
               if(_loc14_ != 0)
               {
                  _loc13_ = wdnative_nternal.__ZL10eh_globals;
                  _loc3_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc3_ != 0)
                  {
                     while(true)
                     {
                        _loc12_ = li32(wdnative_nternal.__ZL4init);
                        if(_loc12_ >= 0)
                        {
                           _loc3_ = li32(wdnative_nternal._sEntryCount);
                           if(_loc3_ > _loc12_)
                           {
                              _loc3_ = _loc12_ << 3;
                              _loc11_ = li32(wdnative_nternal._sEntries);
                              _loc3_ = _loc11_ + _loc3_;
                              _loc13_ = li32(_loc3_);
                              if(_loc13_ != 0)
                              {
                                 break;
                              }
                           }
                        }
                        _loc2_ -= 16;
                        si32(8,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative.F_malloc();
                        _loc2_ += 16;
                        _loc13_ = wdnative.eax;
                        if(_loc13_ != 0)
                        {
                           _loc10_ = li32(wdnative_nternal.__ZL4init);
                           if(_loc10_ >= 0)
                           {
                              _loc3_ = li32(wdnative_nternal._sEntryCount);
                              if(_loc3_ > _loc10_)
                              {
                                 _loc11_ = _loc10_ << 3;
                                 _loc3_ = li32(wdnative_nternal._sEntries);
                                 _loc3_ += _loc11_;
                                 si32(_loc13_,_loc3_);
                                 si32(0,_loc13_);
                                 si32(0,_loc13_ + 4);
                                 break;
                              }
                           }
                        }
                        _loc3_ = _loc16_ | 4;
                        si32(1,_loc3_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F__ZSt9terminatev();
                        _loc3_ = li32(_loc4_ - 48);
                        _loc9_ = li32(_loc4_ - 44);
                        _loc2_ -= 16;
                        si32(_loc3_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc2_ += 16;
                        break;
                     }
                  }
                  while(true)
                  {
                     _loc3_ = li32(_loc14_ + 4);
                     _loc3_ ^= 1196315971;
                     _loc11_ = li32(_loc14_);
                     _loc11_ = _loc11_ ^ 0x432B2B00;
                     _loc3_ = _loc11_ | _loc3_;
                     _loc1_ = _loc14_ + -48;
                     _loc5_ = li32(_loc13_);
                     if(_loc3_ != 0)
                     {
                        if(_loc5_ != 0)
                        {
                           _loc3_ = _loc16_ | 4;
                           si32(2,_loc3_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F__ZSt9terminatev();
                        }
                        si32(_loc1_,_loc13_);
                     }
                     else
                     {
                        _loc11_ = li32(_loc14_ - 28);
                        _loc3_ = _loc11_ >> 31;
                        _loc11_ += _loc3_;
                        _loc3_ = _loc11_ ^ _loc3_;
                        _loc3_ += 1;
                        si32(_loc3_,_loc14_ - 28);
                        _loc3_ = li32(_loc13_ + 4);
                        _loc3_ += -1;
                        si32(_loc3_,_loc13_ + 4);
                        if(_loc1_ != _loc5_)
                        {
                           si32(_loc5_,_loc14_ - 32);
                           si32(_loc1_,_loc13_);
                        }
                     }
                     addr02c2:
                     while(true)
                     {
                        _loc3_ = li32(_loc14_ + 4);
                        _loc3_ ^= 1196315971;
                        _loc11_ = li32(_loc14_);
                        _loc11_ = _loc11_ ^ 0x432B2B00;
                        _loc3_ = _loc11_ | _loc3_;
                        if(_loc3_ == 0)
                        {
                           _loc3_ = li32(_loc1_ + 12);
                           _loc11_ = _loc16_ | 4;
                           si32(-1,_loc11_);
                           _loc2_ -= 16;
                           si32(_loc3_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F__ZN10__cxxabiv111__terminateEPFvvE();
                           _loc2_ += 16;
                        }
                        _loc3_ = li32(_loc4_ - 48);
                        _loc6_ = li32(_loc4_ - 44);
                        _loc2_ -= 16;
                        si32(_loc3_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc2_ += 16;
                     }
                     break;
                     _loc3_ = li32(_loc4_ - 48);
                     _loc9_ = li32(_loc4_ - 44);
                     _loc2_ -= 16;
                     si32(_loc3_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc2_ += 16;
                  }
                  §§goto(addr0389);
               }
               _loc3_ = _loc16_ | 4;
               si32(-1,_loc3_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F__ZSt9terminatev();
            }
            _loc3_ = _loc16_ | 4;
            _loc7_ = li32(_loc3_);
            if(_loc7_ != 0)
            {
               if(_loc7_ == 1)
               {
                  _loc3_ = li32(_loc4_ - 48);
                  _loc6_ = li32(_loc4_ - 44);
                  _loc2_ -= 16;
                  si32(_loc3_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_call_unexpected();
                  _loc2_ += 16;
                  §§goto(addr02c2);
               }
               while(true)
               {
               }
            }
            §§goto(addr01b2);
         }
         catch(l:LongJmp)
         {
            var _temp_29:* = this;
            var _temp_30:* = l;
            if(l.esp < _loc4_)
            {
               continue;
            }
         }
         addr0389:
         throw l;
         wdnative.ESP = _loc2_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc8_ = int(l.sjid);
      }
   }
}

