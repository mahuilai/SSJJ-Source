package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.as3_id2rcv;
   import wdnative.as3_valAcquireId;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.st0;
   
   public function F__ZN3AS32ui8internal13utf8_toStringENS0_3varE() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:Number = NaN;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc12_ = li32(_loc3_);
      if(_loc1_ == -2)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         _loc11_ = wdnative.eax;
         si32(_loc11_,wdnative_nternal._sUITID_2E_3986);
         if(_loc11_ >= 0)
         {
            si8(1,wdnative_nternal._sIsThreaded_2E_b);
            addr0080:
            _loc10_ = li32(wdnative_nternal._sUITID_2E_3986);
            _loc11_ = int(realThreadId);
            if(_loc11_ != _loc10_)
            {
               _loc11_ = _loc3_ - 32;
               _loc10_ = _loc11_ | 4;
               si32(0,_loc10_);
               si32(0,_loc3_ - 4);
               si32(0,_loc3_ - 8);
               si32(0,_loc3_ - 12);
               si32(0,_loc3_ - 16);
               si32(0,_loc3_ - 20);
               si32(0,_loc3_ - 24);
               si32(0,_loc3_ - 32);
               si32(wdnative_nternal.__ZN3AS32ui8internal13utf8_toStringENS0_3varE,_loc3_ - 32);
               _loc9_ = _loc2_;
               _loc9_ = _loc9_ + -16;
               _loc2_ = _loc9_ = _loc9_ & -16;
               _loc8_ = _loc3_;
               si32(_loc8_,_loc9_);
               si32(_loc9_,_loc10_);
               si32(4,_loc3_ - 24);
               _loc2_ -= 16;
               si32(_loc11_,_loc2_ + 4);
               si32(wdnative_nternal.__ZN3AS32ui3var8internal7uiThunkEPv,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_ui_thunk();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
               if(_loc6_ != -1)
               {
                  _loc2_ -= 16;
                  si32(4,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc2_ += 16;
                  _loc11_ = wdnative.eax;
                  si32(_loc6_,_loc11_);
                  _loc2_ -= 16;
                  si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc2_ + 8);
                  si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc2_ + 4);
                  si32(_loc11_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_throw();
                  _loc2_ += 16;
               }
               _loc7_ = lf64(_loc3_ - 8);
               _loc10_ = li32(_loc3_ - 12);
               wdnative.eax = _loc11_ = li32(_loc3_ - 16);
               wdnative.edx = _loc10_;
               wdnative.st0 = _loc7_;
               wdnative.ESP = _loc3_;
               return;
            }
         }
      }
      else if(_loc1_ >= 0)
      {
         §§goto(addr0080);
      }
      _loc11_ = li32(_loc12_);
      wdnative.ESP = _loc2_ & -16;
      try
      {
         _loc5_ = CModule.mallocString(String(wdnative.as3_id2rcv[_loc11_].val));
         _loc4_ = -1;
      }
      catch(e:*)
      {
         var _temp_20:* = this;
         var _temp_21:* = e;
         _loc4_ = wdnative.as3_valAcquireId(e);
      }
      if(_loc4_ != -1)
      {
         _loc2_ -= 16;
         si32(4,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___cxa_allocate_exception();
         _loc2_ += 16;
         _loc11_ = wdnative.eax;
         si32(_loc4_,_loc11_);
         _loc2_ -= 16;
         si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc2_ + 8);
         si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc2_ + 4);
         si32(_loc11_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___cxa_throw();
         _loc2_ += 16;
      }
      wdnative.eax = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

