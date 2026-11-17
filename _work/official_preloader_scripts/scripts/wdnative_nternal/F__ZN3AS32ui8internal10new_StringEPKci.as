package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.as3_valAcquireId;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.st0;
   
   public function F__ZN3AS32ui8internal10new_StringEPKci() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc15_:int = 0;
      var _loc16_:int = 0;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc17_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 32;
      _loc3_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc17_ = li32(_loc4_ + 8);
      _loc16_ = li32(_loc4_ + 4);
      _loc15_ = li32(_loc4_);
      if(_loc3_ == -2)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         var _loc14_:int = wdnative.eax;
         si32(_loc14_,wdnative_nternal._sUITID_2E_3986);
         if(_loc14_ >= 0)
         {
            si8(1,wdnative_nternal._sIsThreaded_2E_b);
            addr0093:
            _loc14_ = li32(wdnative_nternal._sUITID_2E_3986);
            var _loc12_:int = int(realThreadId);
            if(_loc12_ != _loc14_)
            {
               _loc12_ = _loc4_ - 32;
               _loc14_ = _loc12_ | 4;
               si32(0,_loc14_);
               si32(0,_loc4_ - 4);
               si32(0,_loc4_ - 8);
               si32(0,_loc4_ - 12);
               si32(0,_loc4_ - 16);
               si32(0,_loc4_ - 20);
               si32(0,_loc4_ - 24);
               si32(0,_loc4_ - 32);
               si32(wdnative_nternal.__ZN3AS32ui8internal10new_StringEPKci,_loc4_ - 32);
               var _loc11_:int = _loc2_;
               _loc11_ = _loc11_ + -16;
               _loc2_ = _loc11_ = _loc11_ & -16;
               var _loc10_:int = _loc4_;
               si32(_loc10_,_loc11_);
               si32(_loc11_,_loc14_);
               si32(12,_loc4_ - 24);
               _loc2_ -= 16;
               si32(_loc12_,_loc2_ + 4);
               si32(wdnative_nternal.__ZN3AS32ui3var8internal7uiThunkEPv,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_ui_thunk();
               _loc2_ += 16;
               _loc9_ = wdnative.eax;
               if(_loc9_ != -1)
               {
                  _loc2_ -= 16;
                  si32(4,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_allocate_exception();
                  _loc2_ += 16;
                  _loc14_ = wdnative.eax;
                  si32(_loc9_,_loc14_);
                  _loc2_ -= 16;
                  si32(wdnative_nternal.__ZN3AS32ui3varD1Ev,_loc2_ + 8);
                  si32(wdnative_nternal.__ZTIN3AS32ui3varE,_loc2_ + 4);
                  si32(_loc14_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F___cxa_throw();
                  _loc2_ += 16;
               }
               var _loc13_:Number = lf64(_loc4_ - 8);
               _loc12_ = li32(_loc4_ - 12);
               wdnative.eax = _loc11_ = li32(_loc4_ - 16);
               wdnative.edx = _loc12_;
               wdnative.st0 = _loc13_;
               wdnative.ESP = _loc4_;
               return;
            }
         }
      }
      else if(_loc3_ >= 0)
      {
         §§goto(addr0093);
      }
      if(_loc17_ <= -1)
      {
         _loc1_ = _loc16_ & -4;
         _loc12_ = li32(_loc1_);
         var _temp_22:* = int(_loc12_ + -16843009);
         _loc14_ = (_loc12_ = (_loc12_ &= -2139062144) ^ -2139062144) & _temp_22;
         if(_loc14_ != 0)
         {
            _loc5_ = _loc1_ + 4;
            _loc17_ = 0;
            while(true)
            {
               _loc6_ = _loc16_ + _loc17_;
               if((uint(_loc6_)) < uint(_loc5_))
               {
                  _loc14_ = li8(_loc6_);
                  if(_loc14_ == 0)
                  {
                     break;
                  }
                  _loc17_ += 1;
                  continue;
               }
            }
            §§goto(addr0323);
         }
         _loc7_ = _loc1_ + 4;
         while(true)
         {
            _loc8_ = li32(_loc7_);
            _loc14_ = _loc8_ + -16843009;
            _loc12_ = _loc8_ & -2139062144;
            _loc12_ = _loc12_ ^ -2139062144;
            _loc14_ = _loc12_ & _loc14_;
            if(_loc14_ != 0)
            {
               _loc14_ = _loc8_ & 0xFF;
               if(_loc14_ == 0)
               {
                  _loc17_ = _loc7_ - _loc16_;
                  break;
               }
               _loc14_ = li8(_loc7_ + 1);
               if(_loc14_ == 0)
               {
                  _loc14_ = 1 - _loc16_;
                  _loc17_ = _loc14_ + _loc7_;
                  break;
               }
               _loc14_ = li8(_loc7_ + 2);
               if(_loc14_ == 0)
               {
                  _loc14_ = 2 - _loc16_;
                  _loc17_ = _loc14_ + _loc7_;
                  break;
               }
               _loc14_ = li8(_loc7_ + 3);
               if(_loc14_ == 0)
               {
                  _loc14_ = 3 - _loc16_;
                  _loc17_ = _loc14_ + _loc7_;
                  break;
               }
            }
            _loc7_ += 4;
         }
      }
      addr0323:
      wdnative.ESP = _loc2_ & -16;
      _loc14_ = wdnative.as3_valAcquireId(_loc17_ ? CModule.readString(_loc16_,_loc17_) : "");
      si32(_loc14_,_loc15_);
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

