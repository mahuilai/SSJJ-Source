package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.F_malloc;
   import wdnative.Fmemset;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F___cxa_allocate_exception() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc4_)
            {
               _loc3_ = _loc2_;
               _loc2_ -= 64;
               _loc2_ -= 16;
               _loc1_ = li32(_loc3_);
               _loc11_ = _loc1_ + 80;
               si32(_loc11_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc10_ = wdnative.eax;
               si32(wdnative_nternal.L_LSDA_329,_loc3_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc3_ - 32);
               _loc1_ = _loc3_;
               si32(_loc1_,_loc3_ - 24);
               _loc1_ = _loc2_;
               si32(_loc1_,_loc3_ - 16);
               _loc9_ = _loc3_ - 56;
               _loc8_ = _loc9_ + 32;
               wdnative.eax = setjmp(_loc8_,1,_loc2_);
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
            _loc1_ = wdnative.eax;
            while(true)
            {
               if(_loc1_ == 0)
               {
                  _loc2_ -= 16;
                  si32(_loc9_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.F__Unwind_SjLj_Register();
                  _loc2_ += 16;
                  if(_loc10_ == 0)
                  {
                     while(true)
                     {
                        if(uint(_loc11_) <= 512)
                        {
                           _loc7_ = wdnative_nternal.__ZL16emergency_buffer;
                           _loc11_ = _loc6_ = li32(wdnative_nternal.__ZL14emergency_used);
                           _loc8_ = 0;
                           do
                           {
                              _loc1_ = _loc11_ & 1;
                              if(_loc1_ == 0)
                              {
                                 _loc1_ = 1 << _loc8_;
                                 _loc1_ |= _loc6_;
                                 si32(_loc1_,wdnative_nternal.__ZL14emergency_used);
                                 _loc10_ = _loc7_;
                                 break;
                              }
                              _loc7_ += 512;
                              _loc11_ >>>= 1;
                           }
                           while(_loc8_ += 1, (uint(_loc8_)) <= 31);
                           if(_loc10_ != 0)
                           {
                              break;
                           }
                        }
                        _loc1_ = _loc9_ | 4;
                        si32(1,_loc1_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F__ZSt9terminatev();
                        break;
                     }
                  }
                  _loc8_ = wdnative_nternal.__ZL10eh_globals;
                  _loc1_ = li8(wdnative_nternal.__ZL4init + 4);
                  if(_loc1_ == 0)
                  {
                     break;
                  }
                  _loc8_ = li32(wdnative_nternal.__ZL4init);
                  if(_loc8_ >= 0)
                  {
                     _loc1_ = li32(wdnative_nternal._sEntryCount);
                     if(_loc1_ > _loc8_)
                     {
                        _loc1_ = _loc8_ << 3;
                        _loc5_ = li32(wdnative_nternal._sEntries);
                        _loc1_ = _loc5_ + _loc1_;
                        _loc8_ = li32(_loc1_);
                        if(_loc8_ != 0)
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
                  _loc8_ = wdnative.eax;
                  if(_loc8_ != 0)
                  {
                     _loc11_ = li32(wdnative_nternal.__ZL4init);
                     if(_loc11_ >= 0)
                     {
                        _loc1_ = li32(wdnative_nternal._sEntryCount);
                        if(_loc1_ > _loc11_)
                        {
                           _loc5_ = _loc11_ << 3;
                           _loc1_ = li32(wdnative_nternal._sEntries);
                           _loc1_ += _loc5_;
                           si32(_loc8_,_loc1_);
                           si32(0,_loc8_);
                           si32(0,_loc8_ + 4);
                           break;
                        }
                     }
                  }
                  _loc1_ = _loc9_ | 4;
                  si32(2,_loc1_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F__ZSt9terminatev();
               }
               else
               {
                  while(true)
                  {
                     _loc1_ = _loc9_ | 4;
                     _loc10_ = li32(_loc1_);
                     if(_loc10_ != 0)
                     {
                        break;
                     }
                     _loc1_ = li32(_loc3_ - 48);
                     _loc10_ = li32(_loc3_ - 44);
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F___cxa_call_unexpected();
                     _loc2_ += 16;
                  }
                  if(_loc10_ != 1)
                  {
                     while(true)
                     {
                     }
                  }
               }
               _loc1_ = li32(_loc3_ - 48);
               _loc10_ = li32(_loc3_ - 44);
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___cxa_call_unexpected();
               _loc2_ += 16;
               break;
            }
            _loc1_ = li32(_loc8_ + 4);
            _loc1_ += 1;
            si32(_loc1_,_loc8_ + 4);
            _loc2_ -= 16;
            si32(80,_loc2_ + 8);
            si32(0,_loc2_ + 4);
            si32(_loc10_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.Fmemset();
            _loc2_ += 16;
            _loc2_ -= 16;
            si32(_loc9_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc2_ += 16;
            _loc1_ = _loc10_ + 80;
            wdnative.eax = _loc1_;
            _loc2_ = _loc3_;
            wdnative.ESP = _loc2_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_27:* = this;
            var _temp_28:* = l;
            if(l.esp >= _loc3_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc2_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc4_ = int(l.sjid);
      }
   }
}

