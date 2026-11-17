package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.tcbp;
   
   public function F_avm2_self_lock() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative_nternal._sLock_2E_3932;
      _loc5_ = tcbp;
      if(_loc5_ != -1)
      {
         _loc1_ = _loc5_ + 16;
      }
      _loc5_ = li32(wdnative_nternal._sLock_2E_3932);
      if(_loc5_ == -1)
      {
         var _loc4_:int = int(realThreadId);
         _loc5_ = _loc4_ + 1;
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
      _loc4_ = int(realThreadId);
      _loc5_ = _loc4_ + 1;
      _loc4_ = li32(_loc1_);
      _loc4_ = _loc4_ & 0x7FFFFFFF;
      if(_loc4_ != _loc5_)
      {
         _loc2_ -= 16;
         si32(_loc5_,_loc2_ + 4);
         si32(_loc1_,_loc2_);
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
         _loc4_ = li32(wdnative_nternal._sCounter_2E_3947);
         if(_loc4_ != 0)
         {
            if(_loc1_ != wdnative_nternal._sCounter_2E_3947)
            {
               _loc4_ = li32(wdnative_nternal._sCounter_2E_3947);
               si32(_loc4_,_loc1_);
               si32(0,wdnative_nternal._sCounter_2E_3947);
            }
         }
      }
      _loc4_ = li32(_loc1_);
      _loc4_ = _loc4_ + 1;
      si32(_loc4_,_loc1_);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

