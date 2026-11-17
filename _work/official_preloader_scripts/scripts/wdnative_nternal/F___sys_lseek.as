package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.st0;
   
   public function F___sys_lseek() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(_loc3_ + 8);
      _loc12_ = li32(_loc3_ + 4);
      _loc11_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc10_ = li32(_loc3_ + 12);
      _loc8_ = li32(_loc3_);
      if(_loc11_ == -2)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         var _loc7_:int = wdnative.eax;
         si32(_loc7_,wdnative_nternal._sUITID_2E_3986);
         if(_loc7_ >= 0)
         {
            si8(1,wdnative_nternal._sIsThreaded_2E_b);
            addr0084:
            var _loc5_:int = li32(wdnative_nternal._sUITID_2E_3986);
            _loc7_ = int(realThreadId);
            if(_loc7_ != _loc5_)
            {
               _loc7_ = _loc2_;
               _loc7_ = _loc7_ + -16;
               _loc2_ = _loc7_ = _loc7_ & -16;
               _loc5_ = _loc3_;
               si32(_loc5_,_loc7_);
               _loc5_ = _loc3_ - 32;
               var _loc4_:int = _loc5_ | 4;
               si32(0,_loc4_);
               si32(0,_loc3_ - 4);
               si32(0,_loc3_ - 8);
               si32(0,_loc3_ - 12);
               si32(0,_loc3_ - 16);
               si32(0,_loc3_ - 20);
               si32(0,_loc3_ - 24);
               si32(0,_loc3_ - 32);
               si32(wdnative_nternal.___sys_lseek,_loc3_ - 32);
               si32(_loc7_,_loc4_);
               si32(16,_loc3_ - 24);
               _loc2_ -= 16;
               si32(_loc5_,_loc2_ + 4);
               si32(wdnative_nternal._applyThunk,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_avm2_ui_thunk();
               _loc2_ += 16;
               var _temp_14:* = lf64(_loc3_ - 8);
               var _temp_13:* = li32(_loc3_ - 12);
               wdnative.eax = _loc4_ = li32(_loc3_ - 16);
               wdnative.edx = _temp_13;
               wdnative.st0 = _temp_14;
               wdnative.ESP = _loc3_;
               return;
            }
         }
      }
      else if(_loc11_ >= 0)
      {
         §§goto(addr0084);
      }
      wdnative.ESP = _loc2_ & -16;
      var _loc9_:* = CModule.kernel.lseek(_loc8_,_loc1_,_loc12_,_loc10_,wdnative_nternal._errno);
      _loc5_ = int(_loc9_[0]);
      wdnative.eax = _loc7_ = int(_loc9_[1]);
      wdnative.edx = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

