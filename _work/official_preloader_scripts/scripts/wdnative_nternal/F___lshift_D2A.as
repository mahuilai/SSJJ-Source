package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F___lshift_D2A() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc13_:int = 0;
      var _loc14_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc14_ = _loc1_ >> 5;
      _loc13_ = li32(_loc3_);
      var _loc12_:int = li32(_loc13_ + 16);
      _loc11_ = _loc12_ + _loc14_;
      _loc10_ = _loc11_ + 1;
      _loc9_ = li32(_loc13_ + 8);
      _loc8_ = li32(_loc13_ + 4);
      if(_loc10_ > _loc9_)
      {
         do
         {
            _loc8_ += 1;
            _loc9_ <<= 1;
         }
         while(_loc10_ > _loc9_);
      }
      while(true)
      {
         if(_loc8_ >= 10)
         {
            _loc7_ = 1 << _loc8_;
            _loc12_ = _loc7_ << 2;
            _loc6_ = _loc12_ + 27;
         }
         else
         {
            var _temp_7:* = _loc8_ << 2;
            _loc4_ = wdnative_nternal._freelist + _temp_7;
            _loc9_ = li32(_loc4_);
            if(_loc9_ != 0)
            {
               _loc12_ = li32(_loc9_);
               si32(_loc12_,_loc4_);
               §§goto(addr0162);
            }
            _loc9_ = li32(wdnative_nternal._pmem_next);
            _loc12_ = _loc9_ - wdnative_nternal._private_mem;
            _loc12_ = (_loc12_ >> 3) + (_loc4_ = (_loc6_ = (_loc12_ = (_loc7_ = 1 << _loc8_) << 2) + 27) >>> 3);
            if((uint(_loc12_)) <= 288)
            {
               var _temp_38:* = _loc4_ << 3;
               _loc12_ = _loc9_ + _temp_38;
               si32(_loc12_,wdnative_nternal._pmem_next);
               break;
            }
         }
         _loc2_ -= 16;
         _loc12_ = _loc6_ & -8;
         si32(_loc12_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F_malloc();
         _loc2_ += 16;
         _loc9_ = wdnative.eax;
         break;
      }
      si32(_loc8_,_loc9_ + 4);
      si32(_loc7_,_loc9_ + 8);
      addr0162:
      _loc4_ = 0;
      si32(_loc4_,_loc9_ + 16);
      si32(_loc4_,_loc9_ + 12);
      _loc8_ = _loc9_ + 20;
      if(_loc14_ >= 1)
      {
         _loc2_ -= 16;
         si32(0,_loc2_ + 4);
         si32(_loc8_,_loc2_);
         _loc12_ = _loc1_ >> 3;
         _loc12_ = _loc12_ & -4;
         si32(_loc12_,_loc2_ + 8);
         _loc12_ += _loc9_;
         _loc8_ = _loc12_ + 20;
         wdnative.ESP = _loc2_;
         wdnative.Fmemset();
         _loc2_ += 16;
      }
      _loc12_ = li32(_loc13_ + 16);
      _loc12_ = _loc12_ << 2;
      _loc12_ = _loc13_ + _loc12_;
      _loc14_ = _loc12_ + 20;
      _loc7_ = _loc1_ & 0x1F;
      if(_loc7_ == 0)
      {
         _loc10_ = _loc13_ + 20;
         do
         {
            _loc12_ = li32(_loc10_);
            si32(_loc12_,_loc8_);
            _loc8_ += 4;
         }
         while(_loc10_ += 4, (uint(_loc10_)) < uint(_loc14_));
      }
      else
      {
         _loc6_ = _loc13_ + 20;
         _loc1_ = 32 - _loc7_;
         do
         {
            _loc12_ = li32(_loc6_);
            _loc12_ = _loc12_ << _loc7_;
            _loc12_ = _loc12_ | _loc4_;
            si32(_loc12_,_loc8_);
            _loc12_ = li32(_loc6_);
            _loc4_ = _loc12_ >>> _loc1_;
            _loc6_ += 4;
            _loc8_ += 4;
         }
         while(uint(_loc6_) < uint(_loc14_));
         si32(_loc4_,_loc8_);
         if(_loc4_ != 0)
         {
            _loc10_ = _loc11_ + 2;
         }
         _loc11_ = _loc10_ + -1;
      }
      si32(_loc11_,_loc9_ + 16);
      _loc11_ = li32(_loc13_ + 4);
      if(_loc11_ >= 10)
      {
         if(_loc13_ != 0)
         {
            _loc2_ -= 16;
            si32(_loc13_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_idalloc();
            _loc2_ += 16;
         }
      }
      else
      {
         var _temp_26:* = _loc11_ << 2;
         var _loc5_:int = wdnative_nternal._freelist + _temp_26;
         _loc12_ = li32(_loc5_);
         si32(_loc12_,_loc13_);
         si32(_loc13_,_loc5_);
      }
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

