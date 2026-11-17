package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.tcbp;
   
   public function F_avm2_self_msleep() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative_nternal._sLock_2E_3932;
      _loc8_ = tcbp;
      if(_loc8_ != -1)
      {
         _loc1_ = _loc8_ + 16;
      }
      _loc8_ = li32(wdnative_nternal._sLock_2E_3932);
      if(_loc8_ == -1)
      {
         var _loc7_:int = int(realThreadId);
         _loc8_ = _loc7_ + 1;
         si32(_loc8_,wdnative_nternal._sLock_2E_3932);
      }
      if(_loc8_ != 0)
      {
         if(_loc1_ != wdnative_nternal._sLock_2E_3932)
         {
            si32(_loc8_,_loc1_);
            si32(0,wdnative_nternal._sLock_2E_3932);
         }
      }
      _loc6_ = li32(_loc3_ + 4);
      _loc5_ = li32(_loc3_);
      _loc8_ = tcbp;
      if(_loc8_ == -1)
      {
         _loc8_ = li32(wdnative_nternal._sCounter_2E_3947);
         _loc8_ = wdnative_nternal._sCounter_2E_3947;
      }
      else
      {
         _loc8_ += 20;
         _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
         if(_loc7_ != 0)
         {
            if(_loc8_ != wdnative_nternal._sCounter_2E_3947)
            {
               _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
               si32(_loc7_,_loc8_);
               si32(0,wdnative_nternal._sCounter_2E_3947);
            }
         }
      }
      _loc8_ = li32(_loc8_);
      _loc4_ = tcbp;
      if(_loc4_ == -1)
      {
         _loc4_ = li32(wdnative_nternal._sCounter_2E_3947);
         _loc4_ = wdnative_nternal._sCounter_2E_3947;
      }
      else
      {
         _loc4_ += 20;
         _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
         if(_loc7_ != 0)
         {
            if(_loc4_ != wdnative_nternal._sCounter_2E_3947)
            {
               _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
               si32(_loc7_,_loc4_);
               si32(0,wdnative_nternal._sCounter_2E_3947);
            }
         }
      }
      si32(0,_loc4_);
      _loc2_ -= 16;
      si32(_loc6_,_loc2_ + 8);
      si32(_loc1_,_loc2_ + 4);
      si32(_loc5_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_avm2_msleep();
      _loc2_ += 16;
      _loc5_ = wdnative_nternal._sLock_2E_3932;
      _loc6_ = tcbp;
      if(_loc6_ != -1)
      {
         _loc5_ = _loc6_ + 16;
      }
      _loc6_ = li32(wdnative_nternal._sLock_2E_3932);
      if(_loc6_ == -1)
      {
         _loc7_ = int(realThreadId);
         _loc6_ = _loc7_ + 1;
         si32(_loc6_,wdnative_nternal._sLock_2E_3932);
      }
      if(_loc6_ != 0)
      {
         if(_loc5_ != wdnative_nternal._sLock_2E_3932)
         {
            si32(_loc6_,_loc5_);
            si32(0,wdnative_nternal._sLock_2E_3932);
         }
      }
      if(_loc5_ != _loc1_)
      {
         _loc1_ = wdnative_nternal._sLock_2E_3932;
         _loc5_ = tcbp;
         if(_loc5_ != -1)
         {
            _loc1_ = _loc5_ + 16;
         }
         _loc5_ = li32(wdnative_nternal._sLock_2E_3932);
         if(_loc5_ == -1)
         {
            _loc7_ = int(realThreadId);
            _loc5_ = _loc7_ + 1;
            si32(_loc5_,wdnative_nternal._sLock_2E_3932);
         }
         if(_loc5_ != 0)
         {
            if(_loc1_ != wdnative_nternal._sLock_2E_3932)
            {
               si32(_loc5_,_loc1_);
               si32(0,wdnative_nternal._sLock_2E_3932);
            }
         }
         _loc2_ -= 16;
         si32(_loc1_,_loc2_);
         _loc7_ = int(realThreadId);
         _loc7_ = _loc7_ + 1;
         si32(_loc7_,_loc2_ + 4);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_lock_id();
         _loc2_ += 16;
      }
      _loc1_ = tcbp;
      if(_loc1_ == -1)
      {
         _loc1_ = li32(wdnative_nternal._sCounter_2E_3947);
         _loc1_ = wdnative_nternal._sCounter_2E_3947;
      }
      else
      {
         _loc1_ += 20;
         _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
         if(_loc7_ != 0)
         {
            if(_loc1_ != wdnative_nternal._sCounter_2E_3947)
            {
               _loc7_ = li32(wdnative_nternal._sCounter_2E_3947);
               si32(_loc7_,_loc1_);
               si32(0,wdnative_nternal._sCounter_2E_3947);
            }
         }
      }
      si32(_loc8_,_loc1_);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

