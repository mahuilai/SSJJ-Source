package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.as3_valAcquireId;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ram;
   import wdnative.st0;
   
   public function F__ZN3AS32ui8internal7get_ramEv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc10_ = li32(_loc3_);
      if(_loc1_ == -2)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         var _loc9_:int = wdnative.eax;
         si32(_loc9_,wdnative_nternal._sUITID_2E_3986);
         if(_loc9_ >= 0)
         {
            si8(1,wdnative_nternal._sIsThreaded_2E_b);
            addr0065:
            var _loc8_:int = li32(wdnative_nternal._sUITID_2E_3986);
            _loc9_ = int(realThreadId);
            if(_loc9_ != _loc8_)
            {
               _loc9_ = _loc3_ - 32;
               _loc8_ = _loc9_ | 4;
               si32(0,_loc8_);
               si32(0,_loc3_ - 4);
               si32(0,_loc3_ - 8);
               si32(0,_loc3_ - 12);
               si32(0,_loc3_ - 16);
               si32(0,_loc3_ - 20);
               si32(0,_loc3_ - 24);
               si32(0,_loc3_ - 32);
               si32(wdnative_nternal.__ZN3AS32ui8internal7get_ramEv,_loc3_ - 32);
               var _loc7_:int = _loc2_;
               _loc7_ = _loc7_ + -16;
               var _loc6_:int;
               _loc2_ = _loc6_ = _loc7_ & -16;
               _loc7_ = _loc3_;
               si32(_loc7_,_loc6_);
               si32(_loc6_,_loc8_);
               si32(4,_loc3_ - 24);
               _loc2_ -= 16;
               si32(_loc9_,_loc2_ + 4);
               si32(wdnative_nternal.__ZN3AS32ui3var8internal7uiThunkEPv,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_ui_thunk();
               _loc2_ += 16;
               _loc4_ = wdnative.eax;
               if(_loc4_ != -1)
               {
                  _loc2_ -= 16;
                  si32(4,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc2_ += 16;
                  _loc9_ = wdnative.eax;
                  si32(_loc4_,_loc9_);
                  _loc2_ -= 16;
                  si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc2_ + 8);
                  si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc2_ + 4);
                  si32(_loc9_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_throw();
                  _loc2_ += 16;
               }
               var _loc5_:Number = lf64(_loc3_ - 8);
               _loc8_ = li32(_loc3_ - 12);
               wdnative.eax = _loc9_ = li32(_loc3_ - 16);
               wdnative.edx = _loc8_;
               wdnative.st0 = _loc5_;
               wdnative.ESP = _loc3_;
               return;
            }
         }
      }
      else if(_loc1_ >= 0)
      {
         §§goto(addr0065);
      }
      wdnative.ESP = _loc2_ & -16;
      _loc9_ = wdnative.as3_valAcquireId(ram);
      si32(_loc9_,_loc10_);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

