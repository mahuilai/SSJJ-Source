package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.F_malloc;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F__Znaj() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc12_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc13_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc4_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc6_)
            {
               _loc3_ = _loc2_;
               _loc2_ -= 64;
               _loc1_ = 1;
               _loc13_ = li32(_loc3_);
               if(_loc13_ != 0)
               {
                  _loc1_ = _loc13_;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc12_ = wdnative.eax;
               si32(wdnative_nternal.L_LSDA_350,_loc3_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc3_ - 32);
               _loc11_ = _loc3_;
               si32(_loc11_,_loc3_ - 24);
               _loc11_ = _loc2_;
               si32(_loc11_,_loc3_ - 16);
               _loc10_ = _loc3_ - 56;
               _loc9_ = _loc10_ + 32;
               wdnative.eax = setjmp(_loc9_,1,_loc2_);
            }
            else
            {
               switch(_loc6_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            loop6:
            while(true)
            {
               _loc11_ = wdnative.eax;
               if(_loc11_ == 0)
               {
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.F__Unwind_SjLj_Register();
                  _loc2_ += 16;
                  if(_loc12_ != 0)
                  {
                     break;
                  }
                  _loc2_ -= 16;
                  si32(4,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc11_ = wdnative_nternal.__ZTVSt9bad_alloc + 8;
                  _loc2_ += 16;
                  _loc8_ = wdnative.eax;
                  si32(_loc11_,_loc8_);
                  _loc11_ = _loc10_ | 4;
                  si32(1,_loc11_);
                  _loc2_ -= 16;
                  si32(wdnative_nternal.__ZNSt9bad_allocD1Ev,_loc2_ + 8);
                  si32(wdnative_nternal.__ZTISt9bad_alloc,_loc2_ + 4);
                  si32(_loc8_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_throw();
                  _loc2_ += 16;
               }
               else
               {
                  while(true)
                  {
                     _loc11_ = _loc10_ | 4;
                     _loc4_ = li32(_loc11_);
                     if(_loc4_ == 0)
                     {
                        _loc7_ = li32(_loc3_ - 48);
                        _loc11_ = li32(_loc3_ - 44);
                        if(_loc11_ < 0)
                        {
                           while(true)
                           {
                              _loc11_ = _loc10_ | 4;
                              si32(2,_loc11_);
                              _loc2_ -= 16;
                              si32(_loc7_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F___cxa_call_unexpected();
                              _loc2_ += 16;
                              §§goto(addr0199);
                              addr0199:
                           }
                           addr02e1:
                           throw l;
                           addr016a:
                        }
                        _loc11_ = _loc10_ | 4;
                        si32(3,_loc11_);
                        _loc2_ -= 16;
                        si32(_loc7_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative.F__Unwind_SjLj_Resume();
                        _loc2_ += 16;
                        break loop6;
                     }
                     _loc11_ = _loc4_ + -1;
                     if((uint(_loc11_)) >= 2)
                     {
                        break;
                     }
                     while(true)
                     {
                        _loc5_ = li32(_loc3_ - 48);
                        _loc11_ = li32(_loc3_ - 44);
                        if(_loc11_ >= 0)
                        {
                           break;
                        }
                        _loc11_ = _loc10_ | 4;
                        si32(-1,_loc11_);
                        _loc2_ -= 16;
                        si32(_loc5_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F___cxa_call_unexpected();
                        _loc2_ += 16;
                     }
                     _loc11_ = _loc10_ | 4;
                     si32(-1,_loc11_);
                     _loc2_ -= 16;
                     si32(_loc5_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.F__Unwind_SjLj_Resume();
                     _loc2_ += 16;
                  }
                  while(true)
                  {
                  }
               }
               §§goto(addr016a);
            }
            _loc2_ -= 16;
            si32(_loc10_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc2_ += 16;
            wdnative.eax = _loc12_;
            _loc2_ = _loc3_;
            wdnative.ESP = _loc2_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_31:* = this;
            var _temp_32:* = l;
            if(l.esp < _loc3_)
            {
               continue;
            }
         }
         §§goto(addr02e1);
         wdnative.ESP = _loc2_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc6_ = int(l.sjid);
      }
   }
}

