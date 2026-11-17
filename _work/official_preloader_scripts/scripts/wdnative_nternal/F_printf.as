package wdnative_nternal
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_printf() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = _loc3_ + 4;
      si32(_loc1_,_loc3_ - 4);
      _loc5_ = li16(wdnative_nternal.___sF + 244);
      _loc5_ = _loc5_ & 0x1A;
      _loc4_ = li32(_loc3_);
      while(true)
      {
         if(_loc5_ == 10)
         {
            _loc5_ = li16(wdnative_nternal.___sF + 246);
            _loc5_ = _loc5_ << 16;
            _loc5_ = _loc5_ >> 16;
            if(_loc5_ >= 0)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_ + 8);
               si32(_loc4_,_loc2_ + 4);
               _loc5_ = wdnative_nternal.___sF + 232;
               si32(_loc5_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___sbprintf();
               _loc2_ += 16;
               break;
            }
         }
         _loc2_ -= 16;
         si32(_loc1_,_loc2_ + 8);
         si32(_loc4_,_loc2_ + 4);
         _loc5_ = wdnative_nternal.___sF + 232;
         si32(_loc5_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___vfprintf();
         _loc2_ += 16;
         break;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

