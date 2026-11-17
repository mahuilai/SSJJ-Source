package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F___nrv_alloc_D2A() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 4;
      _loc11_ = 0;
      _loc10_ = li32(_loc3_ + 8);
      _loc9_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc3_);
      while(true)
      {
         if(uint(_loc10_) >= 20)
         {
            var _loc7_:int;
            do
            {
               _loc11_ += 1;
               _loc1_ <<= 1;
            }
            while(_loc7_ = _loc1_ + 16, (uint(_loc7_)) <= uint(_loc10_));
            if(_loc11_ >= 10)
            {
               _loc6_ = 1 << _loc11_;
               _loc7_ = _loc6_ << 2;
               _loc5_ = _loc7_ + 27;
               break;
            }
         }
         _loc7_ = _loc11_ << 2;
         _loc1_ = wdnative_nternal._freelist + _loc7_;
         _loc10_ = li32(_loc1_);
         if(_loc10_ != 0)
         {
            _loc7_ = li32(_loc10_);
            si32(_loc7_,_loc1_);
         }
         else
         {
            _loc10_ = li32(wdnative_nternal._pmem_next);
            _loc7_ = _loc10_ - wdnative_nternal._private_mem;
            var _temp_12:* = _loc7_ >> 3;
            var _loc4_:int;
            _loc1_ = (_loc5_ = (_loc4_ = (_loc6_ = 1 << _loc11_) << 2) + 27) >>> 3;
            _loc7_ = _temp_12 + _loc1_;
            if((uint(_loc7_)) > 288)
            {
               break;
            }
            var _temp_14:* = _loc1_ << 3;
            _loc7_ = _loc10_ + _temp_14;
            si32(_loc7_,wdnative_nternal._pmem_next);
            si32(_loc11_,_loc10_ + 4);
            si32(_loc6_,_loc10_ + 8);
         }
         si32(0,_loc10_ + 16);
         si32(0,_loc10_ + 12);
         si32(_loc11_,_loc10_);
         _loc7_ = li8(_loc8_);
         si8(_loc7_,_loc10_ + 4);
         _loc1_ = _loc11_ = _loc10_ + 4;
         if(_loc7_ != 0)
         {
            _loc1_ = _loc10_ + 4;
            _loc8_ += 1;
            do
            {
               _loc7_ = li8(_loc8_);
               si8(_loc7_,_loc1_ + 1);
               _loc1_ += 1;
               _loc8_ += 1;
            }
            while(_loc7_ != 0);
         }
         if(_loc9_ != 0)
         {
            si32(_loc1_,_loc9_);
         }
         wdnative.eax = _loc11_;
         _loc2_ = _loc3_;
         wdnative.ESP = _loc2_;
         return;
      }
      _loc2_ -= 16;
      _loc7_ = _loc5_ & -8;
      si32(_loc7_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.F_malloc();
      _loc2_ += 16;
      _loc10_ = wdnative.eax;
      §§goto(addr012f);
   }
}

