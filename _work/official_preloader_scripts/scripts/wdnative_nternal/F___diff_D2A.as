package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F___diff_D2A() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc12_:int = 0;
      var _loc16_:int = 0;
      var _loc10_:int = 0;
      var _loc17_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = 0;
      var _loc15_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc4_ = li32(_loc5_ + 4);
      _loc17_ = li32(_loc4_ + 16);
      _loc16_ = li32(_loc5_);
      _loc15_ = li32(_loc16_ + 16);
      if(_loc15_ == _loc17_)
      {
         var _loc14_:int = _loc17_ << 2;
         var _loc13_:int = _loc14_ + _loc16_;
         _loc12_ = _loc13_ + 20;
         _loc14_ += _loc4_;
         _loc11_ = _loc14_ + 16;
         _loc10_ = _loc16_ + 20;
         while(true)
         {
            _loc17_ = li32(_loc11_);
            _loc15_ = li32(_loc12_ - 4);
            if(_loc15_ == _loc17_)
            {
               _loc12_ += -4;
               _loc11_ += -4;
               if(uint(_loc12_) <= uint(_loc10_))
               {
                  _loc16_ = li32(wdnative_nternal._freelist);
                  if(_loc16_ != 0)
                  {
                     _loc14_ = li32(_loc16_);
                     si32(_loc14_,wdnative_nternal._freelist);
                  }
                  else
                  {
                     _loc16_ = li32(wdnative_nternal._pmem_next);
                     _loc14_ = _loc16_ - wdnative_nternal._private_mem;
                     _loc14_ = _loc14_ >> 3;
                     _loc14_ = _loc14_ + 3;
                     if((uint(_loc14_)) <= 288)
                     {
                        _loc14_ = _loc16_ + 24;
                        si32(_loc14_,wdnative_nternal._pmem_next);
                     }
                     else
                     {
                        _loc3_ -= 16;
                        si32(24,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative.F_malloc();
                        _loc3_ += 16;
                        _loc16_ = wdnative.eax;
                     }
                     si32(0,_loc16_ + 4);
                     si32(1,_loc16_ + 8);
                  }
                  si32(0,_loc16_ + 12);
                  si32(1,_loc16_ + 16);
                  si32(0,_loc16_ + 20);
                  break;
               }
               continue;
            }
            _loc10_ = -1;
            if(uint(_loc15_) >= uint(_loc17_))
            {
               _loc10_ = 1;
            }
         }
         §§goto(addr0429);
      }
      else
      {
         _loc10_ = _loc15_ - _loc17_;
      }
      _loc17_ = _loc16_;
      if(_loc10_ >= 0)
      {
         _loc17_ = _loc4_;
      }
      if(_loc10_ >= 0)
      {
         _loc4_ = _loc16_;
      }
      _loc15_ = li32(_loc4_ + 4);
      _loc10_ >>>= 31;
      while(true)
      {
         if(_loc15_ >= 10)
         {
            _loc12_ = 1 << _loc15_;
            _loc14_ = _loc12_ << 2;
            _loc1_ = _loc14_ + 27;
         }
         else
         {
            var _temp_30:* = _loc15_ << 2;
            _loc11_ = wdnative_nternal._freelist + _temp_30;
            _loc16_ = li32(_loc11_);
            if(_loc16_ != 0)
            {
               _loc14_ = li32(_loc16_);
               si32(_loc14_,_loc11_);
               §§goto(addr0290);
            }
            else
            {
               _loc16_ = li32(wdnative_nternal._pmem_next);
               _loc14_ = _loc16_ - wdnative_nternal._private_mem;
               var _temp_55:* = _loc14_ >> 3;
               _loc1_ = (_loc14_ = (_loc12_ = 1 << _loc15_) << 2) + 27;
               _loc11_ = _loc1_ >>> 3;
               _loc14_ = _temp_55 + _loc11_;
               if((uint(_loc14_)) <= 288)
               {
                  var _temp_57:* = _loc11_ << 3;
                  _loc14_ = _loc16_ + _temp_57;
                  si32(_loc14_,wdnative_nternal._pmem_next);
                  break;
               }
            }
         }
         _loc3_ -= 16;
         _loc14_ = _loc1_ & -8;
         si32(_loc14_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative.F_malloc();
         _loc3_ += 16;
         _loc16_ = wdnative.eax;
         break;
      }
      si32(_loc15_,_loc16_ + 4);
      si32(_loc12_,_loc16_ + 8);
      addr0290:
      si32(0,_loc16_ + 16);
      si32(_loc10_,_loc16_ + 12);
      _loc14_ = li32(_loc17_ + 16);
      _loc14_ = _loc14_ << 2;
      _loc14_ = _loc17_ + _loc14_;
      _loc6_ = _loc14_ + 20;
      _loc15_ = li32(_loc4_ + 16);
      _loc11_ = 20;
      _loc10_ = 0;
      _loc7_ = 0;
      do
      {
         _loc14_ = _loc17_ + _loc11_;
         _loc8_ = li32(_loc14_);
         _loc14_ = _loc4_ + _loc11_;
         _loc12_ = li32(_loc14_);
         var _loc9_:int = _loc12_ - _loc8_;
         _loc13_ = _loc9_ - _loc10_;
         _loc14_ = _loc16_ + _loc11_;
         si32(_loc13_,_loc14_);
         _loc1_ = 1;
         _loc2_ = _loc1_;
         if(uint(_loc9_) >= uint(_loc10_))
         {
            _loc2_ = 0;
         }
         if(uint(_loc12_) >= uint(_loc8_))
         {
            _loc1_ = 0;
         }
         _loc14_ = 0 - _loc1_;
         _loc14_ = _loc14_ - _loc7_;
         _loc14_ = _loc14_ - _loc2_;
         _loc10_ = _loc14_ & 1;
         _loc11_ += 4;
         _loc14_ = _loc17_ + _loc11_;
         _loc7_ = 0;
      }
      while(uint(_loc14_) < uint(_loc6_));
      _loc17_ = _loc16_ + _loc11_;
      _loc11_ = _loc4_ + _loc11_;
      var _temp_43:* = _loc15_ << 2;
      _loc14_ = _loc4_ + _temp_43;
      _loc1_ = _loc14_ + 20;
      _loc4_ = 0;
      if(uint(_loc11_) < uint(_loc1_))
      {
         do
         {
            _loc14_ = li32(_loc11_);
            _loc13_ = _loc14_ - _loc10_;
            si32(_loc13_,_loc17_);
            _loc12_ = 1;
            if(uint(_loc14_) >= uint(_loc10_))
            {
               _loc12_ = 0;
            }
            _loc14_ = 0 - _loc4_;
            _loc14_ = _loc14_ - _loc12_;
            _loc10_ = _loc14_ & 1;
            _loc11_ += 4;
            _loc17_ += 4;
            _loc4_ = 0;
         }
         while(uint(_loc11_) < uint(_loc1_));
      }
      _loc14_ = li32(_loc17_ - 4);
      if(_loc14_ == 0)
      {
         _loc4_ = _loc17_ + -8;
         do
         {
            _loc13_ = _loc4_ + -4;
            _loc15_ += -1;
            _loc14_ = li32(_loc4_);
            _loc4_ = _loc13_;
         }
         while(_loc14_ == 0);
      }
      si32(_loc15_,_loc16_ + 16);
      addr0429:
      wdnative.eax = _loc16_;
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

