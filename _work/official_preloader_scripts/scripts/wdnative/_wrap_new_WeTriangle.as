package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___cxa_allocate_exception;
   import wdnative_nternal.F___cxa_call_unexpected;
   import wdnative_nternal.F___cxa_throw;
   import wdnative_nternal.L_LSDA_271;
   import wdnative_nternal.__ZNSt9bad_allocD1Ev;
   import wdnative_nternal.__ZTISt9bad_alloc;
   import wdnative_nternal.__ZTVSt9bad_alloc;
   import wdnative_nternal.___gxx_personality_sj0;
   
   public function _wrap_new_WeTriangle() : int
   {
      var _loc9_:* = undefined;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc11_:int = 0;
      var _loc3_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc5_)
            {
               _loc4_ = _loc3_;
               _loc3_ -= 64;
               _loc3_ -= 16;
               si32(16,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F_malloc();
               _loc3_ += 16;
               _loc2_ = wdnative.eax;
               si32(wdnative_nternal.L_LSDA_271,_loc4_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc4_ - 32);
               _loc11_ = _loc4_;
               si32(_loc11_,_loc4_ - 24);
               _loc11_ = _loc3_;
               si32(_loc11_,_loc4_ - 16);
               _loc10_ = _loc4_ - 56;
               _loc8_ = _loc10_ + 32;
               wdnative.eax = setjmp(_loc8_,1,_loc3_);
            }
            else
            {
               switch(_loc5_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            while(true)
            {
               _loc11_ = wdnative.eax;
               if(_loc11_ == 0)
               {
                  _loc3_ -= 16;
                  si32(_loc10_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__Unwind_SjLj_Register();
                  _loc3_ += 16;
                  if(_loc2_ != 0)
                  {
                     break;
                  }
                  _loc3_ -= 16;
                  si32(4,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc11_ = wdnative_nternal.__ZTVSt9bad_alloc + 8;
                  _loc3_ += 16;
                  _loc7_ = wdnative.eax;
                  si32(_loc11_,_loc7_);
                  _loc11_ = _loc10_ | 4;
                  si32(1,_loc11_);
                  _loc3_ -= 16;
                  si32(wdnative_nternal.__ZNSt9bad_allocD1Ev,_loc3_ + 8);
                  si32(wdnative_nternal.__ZTISt9bad_alloc,_loc3_ + 4);
                  si32(_loc7_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___cxa_throw();
                  _loc3_ += 16;
               }
               else
               {
                  _loc11_ = _loc10_ | 4;
                  _loc11_ = li32(_loc11_);
                  if(_loc11_ == 0)
                  {
                     _loc6_ = li32(_loc4_ - 48);
                     _loc11_ = li32(_loc4_ - 44);
                     if(_loc11_ < 0)
                     {
                        while(true)
                        {
                           _loc11_ = _loc10_ | 4;
                           si32(-1,_loc11_);
                           _loc3_ -= 16;
                           si32(_loc6_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___cxa_call_unexpected();
                           _loc3_ += 16;
                           §§goto(addr017f);
                           addr017f:
                        }
                        addr0260:
                        throw l;
                        addr0153:
                     }
                     _loc11_ = _loc10_ | 4;
                     si32(-1,_loc11_);
                     _loc3_ -= 16;
                     si32(_loc6_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative.F__Unwind_SjLj_Resume();
                     _loc3_ += 16;
                     break;
                  }
                  while(true)
                  {
                  }
               }
               §§goto(addr0153);
            }
            si32(0,_loc2_);
            si32(0,_loc2_ + 4);
            si32(0,_loc2_ + 8);
            si32(0,_loc2_ + 12);
            _loc1_ = _loc2_;
            _loc9_ = _loc1_;
            _loc3_ -= 16;
            si32(_loc10_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc3_ += 16;
            _loc3_ = _loc4_;
            wdnative.ESP = _loc3_;
            return _loc9_;
         }
         catch(l:LongJmp)
         {
            if(l.esp < _loc4_)
            {
               continue;
            }
         }
         §§goto(addr0260);
         wdnative.ESP = _loc3_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc5_ = int(l.sjid);
      }
   }
}

