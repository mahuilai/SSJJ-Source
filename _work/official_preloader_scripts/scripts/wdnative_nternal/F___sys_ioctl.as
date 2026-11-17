package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.st0;
   
   public function F___sys_ioctl() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc10_ = li32(_loc3_ + 8);
      _loc9_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc3_);
      if(_loc1_ == -2)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_uiThreadIdRaw();
         var _loc7_:int = wdnative.eax;
         si32(_loc7_,wdnative_nternal._sUITID_2E_3986);
         if(_loc7_ >= 0)
         {
            si8(1,wdnative_nternal._sIsThreaded_2E_b);
            addr0077:
            _loc7_ = li32(wdnative_nternal._sUITID_2E_3986);
            var _loc6_:int = int(realThreadId);
            if(_loc6_ != _loc7_)
            {
               _loc7_ = _loc2_;
               _loc7_ = _loc7_ + -16;
               _loc2_ = _loc7_ = _loc7_ & -16;
               _loc6_ = _loc3_;
               si32(_loc6_,_loc7_);
               _loc6_ = _loc3_ - 32;
               var _loc4_:int = _loc6_ | 4;
               si32(0,_loc4_);
               si32(0,_loc3_ - 4);
               si32(0,_loc3_ - 8);
               si32(0,_loc3_ - 12);
               si32(0,_loc3_ - 16);
               si32(0,_loc3_ - 20);
               si32(0,_loc3_ - 24);
               si32(0,_loc3_ - 32);
               si32(wdnative_nternal.___sys_ioctl,_loc3_ - 32);
               si32(_loc7_,_loc4_);
               si32(12,_loc3_ - 24);
               _loc2_ -= 16;
               si32(_loc6_,_loc2_ + 4);
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
      else if(_loc1_ >= 0)
      {
         §§goto(addr0077);
      }
      wdnative.ESP = _loc2_ & -16;
      wdnative.eax = _loc7_ = int(CModule.kernel.ioctl(_loc8_,_loc9_,_loc10_,wdnative_nternal._errno));
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

