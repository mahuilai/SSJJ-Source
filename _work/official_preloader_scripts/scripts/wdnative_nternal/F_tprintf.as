package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ram;
   
   public function F_tprintf() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16400;
      _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
      if(_loc1_ == -1)
      {
         _loc1_ = int(Boolean(workerClass));
         si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
      }
      while(true)
      {
         if(_loc1_ != 0)
         {
            var _loc8_:int = int(threadId);
            _loc8_ = _loc8_ + 8;
            _loc7_ = _loc8_ & 0xFF;
            var _temp_5:* = _loc7_ << 2;
            var _temp_6:* = int(wdnative_nternal._sEntered_2E_5481 + _temp_5);
            _loc8_ = int(ram.atomicCompareAndSwapIntAt(_temp_6,0,1));
            if(_loc8_ != 0)
            {
               break;
            }
         }
         _loc8_ = li32(_loc3_);
         var _loc6_:int = _loc3_ + 4;
         si32(_loc6_,_loc3_ - 16388);
         _loc2_ -= 16;
         si32(_loc6_,_loc2_ + 12);
         si32(_loc8_,_loc2_ + 8);
         si32(16384,_loc2_ + 4);
         _loc1_ = _loc3_ - 16384;
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_vsnprintf();
         _loc2_ += 16;
         _loc5_ = wdnative.eax;
         if(_loc5_ >= 1)
         {
            _loc4_ = _loc5_ + -1;
            _loc8_ = _loc1_ + _loc4_;
            _loc8_ = li8(_loc8_);
            if(_loc8_ != 10)
            {
               _loc4_ = _loc5_;
            }
            if(_loc4_ >= 1)
            {
               trace(CModule.readString(_loc1_,_loc4_));
            }
         }
         _loc8_ = _loc7_ << 2;
         _loc8_ = wdnative_nternal._sEntered_2E_5481 + _loc8_;
         si32(0,_loc8_);
         break;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

