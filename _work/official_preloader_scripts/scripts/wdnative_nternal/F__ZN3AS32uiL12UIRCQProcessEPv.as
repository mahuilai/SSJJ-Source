package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.as3_id2rcv;
   
   public function F__ZN3AS32uiL12UIRCQProcessEPv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = int(threadId);
      _loc2_ -= 16;
      _loc1_ += 8;
      si32(_loc1_,_loc2_ + 4);
      si32(wdnative_nternal.__ZN3AS32uiL10sUIRCQLockE,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_avm2_lock_id();
      _loc2_ += 16;
      _loc5_ = 0;
      _loc1_ = li32(wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
      if(_loc1_ >= 1)
      {
         do
         {
            _loc1_ = _loc5_ << 3;
            var _loc4_:int = wdnative_nternal.__ZN3AS32uiL6sUIRCQE + _loc1_;
            _loc1_ = li32(_loc4_ + 4);
            _loc4_ = li32(_loc4_);
            wdnative.ESP = _loc2_ & -16;
            wdnative.as3_id2rcv[_loc4_].release(_loc1_);
            _loc5_ += 1;
            _loc1_ = li32(wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
         }
         while(_loc5_ < _loc1_);
      }
      si32(0,wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
      _loc2_ -= 16;
      si32(wdnative_nternal.__ZN3AS32uiL10sUIRCQLockE,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_avm2_unlock();
      _loc2_ += 16;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

