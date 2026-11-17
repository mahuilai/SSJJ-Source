package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   
   public function F__ZN3AS32ui3var8internal7acquireEj() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      if(uint(_loc1_) >= 4)
      {
         while(true)
         {
            var _loc7_:int = int(threadId);
            _loc2_ -= 16;
            _loc7_ += 8;
            si32(_loc7_,_loc2_ + 4);
            si32(wdnative_nternal.__ZN3AS32uiL10sUIRCQLockE,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_lock_id();
            _loc2_ += 16;
            _loc6_ = li32(wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
            if(_loc6_ >= 1)
            {
               _loc5_ = _loc6_ + -1;
               var _temp_8:* = _loc5_ << 3;
               _loc7_ = wdnative_nternal.__ZN3AS32uiL6sUIRCQE + _temp_8;
               _loc7_ = li32(_loc7_);
               if(_loc7_ == _loc1_)
               {
                  var _temp_11:* = _loc6_ << 3;
                  _loc7_ = wdnative_nternal.__ZN3AS32uiL6sUIRCQE + _temp_11;
                  var _loc4_:int = li32(_loc7_ - 4);
                  _loc4_ = _loc4_ + -1;
                  si32(_loc4_,_loc7_ - 4);
                  if(_loc4_ == 0)
                  {
                     si32(_loc5_,wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
                  }
                  break;
               }
               if(_loc6_ == 127)
               {
                  continue;
               }
            }
            _loc7_ = _loc6_ + 1;
            si32(_loc7_,wdnative_nternal.__ZN3AS32uiL10sUIRCQSizeE);
            _loc7_ = _loc6_ << 3;
            _loc7_ = wdnative_nternal.__ZN3AS32uiL6sUIRCQE + _loc7_;
            si32(_loc1_,_loc7_);
            si32(-1,_loc7_ + 4);
            break;
            _loc2_ -= 16;
            si32(wdnative_nternal.__ZN3AS32uiL10sUIRCQLockE,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_unlock();
            _loc2_ += 16;
            _loc2_ -= 16;
            si32(0,_loc2_ + 4);
            si32(wdnative_nternal.__ZN3AS32uiL12UIRCQProcessEPv,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_ui_thunk();
            _loc2_ += 16;
         }
         _loc2_ -= 16;
         si32(wdnative_nternal.__ZN3AS32uiL10sUIRCQLockE,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_unlock();
         _loc2_ += 16;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

