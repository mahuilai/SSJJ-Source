package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Register;
   import wdnative.F__Unwind_SjLj_Resume;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.LongJmp;
   import wdnative.eax;
   import wdnative.setjmp;
   
   public function F__ZN3AS32ui5flash5utils9ByteArrayC1ENS0_3varE() : void
   {
      var _temp_1:* = this;
      var _loc9_:int = 0;
      var _loc14_:int = 0;
      var _loc5_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc19_:int = 0;
      var _loc18_:int = 0;
      var _loc2_:int = 0;
      var _loc17_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc22_:int = 0;
      var _loc13_:int = 0;
      var _loc3_:int = 0;
      var _loc16_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc15_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = wdnative.ESP;
      while(true)
      {
         try
         {
            if(!_loc14_)
            {
               _loc9_ = _loc4_;
               _loc4_ -= 80;
               _loc5_ = li32(_loc9_);
               si32(_loc5_,_loc9_ - 64);
               _loc22_ = li32(_loc9_ - 64);
               si32(1,_loc22_);
               _loc21_ = _loc9_ - 72;
               si32(_loc21_,_loc9_ - 60);
               _loc20_ = li32(_loc9_ + 4);
               _loc22_ = li32(_loc9_ - 60);
               si32(_loc20_,_loc22_);
               si32(wdnative_nternal.L_LSDA_313,_loc9_ - 28);
               si32(wdnative_nternal.___gxx_personality_sj0,_loc9_ - 32);
               _loc22_ = _loc9_;
               si32(_loc22_,_loc9_ - 24);
               _loc22_ = _loc4_;
               si32(_loc22_,_loc9_ - 16);
               _loc19_ = _loc9_ - 56;
               _loc18_ = _loc19_ + 32;
               wdnative.eax = setjmp(_loc18_,1,_loc4_);
            }
            else
            {
               switch(_loc14_ - 1)
               {
                  case 0:
                  default:
                     throw "bad longjmp";
               }
            }
            _loc22_ = wdnative.eax;
            if(_loc22_ == 0)
            {
               _loc4_ -= 16;
               si32(_loc19_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative.F__Unwind_SjLj_Register();
               _loc4_ += 16;
               _loc17_ = _loc19_ | 4;
               si32(1,_loc17_);
               _loc4_ -= 16;
               si32(_loc20_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7acquireEj();
               _loc4_ += 16;
               si32(2,_loc17_);
               _loc4_ -= 16;
               si32(_loc21_,_loc4_ + 4);
               si32(_loc5_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui5flash5utils9ByteArrayaSENS0_3varE();
               _loc4_ += 16;
               _loc22_ = li32(_loc9_ - 60);
               _loc16_ = li32(_loc22_);
               si32(3,_loc17_);
               _loc4_ -= 16;
               si32(_loc16_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
               _loc4_ += 16;
            }
            else
            {
               _loc22_ = _loc19_ | 4;
               _loc2_ = li32(_loc22_);
               while(true)
               {
                  if(_loc2_ <= 1)
                  {
                     if(_loc2_ != 0)
                     {
                        if(_loc2_ == 1)
                        {
                           _loc1_ = li32(_loc9_ - 48);
                           _loc11_ = li32(_loc9_ - 44);
                           _loc22_ = li32(_loc9_ - 60);
                           _loc12_ = li32(_loc22_);
                           _loc22_ = _loc19_ | 4;
                           si32(4,_loc22_);
                           _loc4_ -= 16;
                           si32(_loc12_,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
                           _loc4_ += 16;
                           break;
                        }
                        while(true)
                        {
                        }
                        addr035d:
                     }
                  }
                  else if(_loc2_ != 2)
                  {
                     if(_loc2_ != 3)
                     {
                        if(_loc2_ != 4)
                        {
                           §§goto(addr035d);
                        }
                     }
                     else
                     {
                        _loc13_ = li32(_loc9_ - 48);
                        _loc3_ = li32(_loc9_ - 44);
                        wdnative.ESP = _loc4_;
                        wdnative_nternal.F__ZSt9terminatev();
                     }
                     _loc6_ = li32(_loc9_ - 48);
                     _loc7_ = li32(_loc9_ - 44);
                     wdnative.ESP = _loc4_;
                     wdnative_nternal.F__ZSt9terminatev();
                     break;
                  }
                  _loc1_ = li32(_loc9_ - 48);
                  _loc10_ = li32(_loc9_ - 44);
                  break;
               }
               _loc22_ = li32(_loc9_ - 64);
               _loc8_ = li32(_loc22_);
               _loc15_ = _loc19_ | 4;
               si32(5,_loc15_);
               _loc4_ -= 16;
               si32(_loc8_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
               _loc4_ += 16;
               si32(-1,_loc15_);
               _loc4_ -= 16;
               si32(_loc1_,_loc4_);
               wdnative.ESP = _loc4_;
               wdnative.F__Unwind_SjLj_Resume();
               _loc4_ += 16;
            }
            _loc4_ -= 16;
            si32(_loc19_,_loc4_);
            wdnative.ESP = _loc4_;
            wdnative.F__Unwind_SjLj_Unregister();
            _loc4_ += 16;
            wdnative.ESP = _loc4_ = _loc9_;
            return;
         }
         catch(l:LongJmp)
         {
            var _temp_28:* = this;
            var _temp_29:* = l;
            if(l.esp >= _loc9_)
            {
               throw l;
            }
         }
         wdnative.ESP = _loc4_ = int(l.esp);
         wdnative.eax = l.retval;
         _loc14_ = int(l.sjid);
      }
   }
}

