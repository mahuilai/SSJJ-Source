package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_arena_bin_run_size_calc() : void
   {
      var _temp_1:* = this;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc20_:int = 0;
      var _loc13_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc18_:int = 0;
      var _loc17_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc19_:int = 0;
      var _loc16_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc8_ = _loc3_;
      _loc4_ = li32(_loc8_);
      _loc20_ = li32(_loc4_ + 20);
      _loc19_ = li32(_loc8_ + 4);
      _loc18_ = _loc19_ + -16;
      _loc17_ = (uint(_loc18_)) / uint(_loc20_);
      _loc18_ = _loc17_ ^ -1;
      _loc18_ = _loc20_ * _loc18_;
      _loc16_ = _loc19_ + _loc18_;
      do
      {
         _loc18_ = _loc17_ & 0x1F;
         _loc15_ = 1;
         if(_loc18_ == 0)
         {
            _loc15_ = 0;
         }
         _loc18_ = _loc15_ & 1;
         var _loc14_:int = _loc17_ >>> 5;
         _loc15_ = _loc18_ + _loc14_;
         _loc18_ = _loc15_ << 2;
         _loc18_ = _loc18_ + 12;
         _loc16_ += _loc20_;
         _loc17_ += -1;
      }
      while(uint(_loc18_) > uint(_loc16_));
      _loc17_ += 1;
      _loc18_ = _loc20_ * 488;
      if((uint(_loc18_)) >= 6145)
      {
         _loc13_ = li32(wdnative_nternal._arena_maxclass);
         _loc1_ = _loc19_ * 61;
         _loc9_ = 16 - _loc20_;
         _loc10_ = _loc20_ << 12;
         _loc11_ = 65536 - _loc10_;
         _loc12_ = _loc19_;
         _loc2_ = _loc17_;
         _loc5_ = _loc15_;
         _loc6_ = _loc16_;
         do
         {
            _loc19_ = _loc12_;
            _loc17_ = _loc2_;
            _loc15_ = _loc5_;
            _loc16_ = _loc6_;
            _loc18_ = _loc19_ + 4080;
            _loc2_ = (uint(_loc18_)) / uint(_loc20_);
            _loc18_ %= uint(_loc20_);
            _loc6_ = _loc9_ + _loc18_;
            _loc18_ <<= 12;
            _loc7_ = _loc11_ + _loc18_;
            _loc12_ = _loc19_ + 4096;
            do
            {
               _loc18_ = _loc2_ & 0x1F;
               _loc5_ = 1;
               if(_loc18_ == 0)
               {
                  _loc5_ = 0;
               }
               _loc14_ = _loc5_ & 1;
               _loc18_ = _loc2_ >>> 5;
               _loc5_ = _loc14_ + _loc18_;
               _loc18_ = _loc5_ << 2;
               _loc18_ = _loc18_ + 12;
               _loc6_ += _loc20_;
               _loc7_ += _loc10_;
               _loc2_ += -1;
            }
            while(uint(_loc18_) > uint(_loc6_));
            if(uint(_loc12_) > uint(_loc13_))
            {
               break;
            }
            if(uint(_loc12_) > 49152)
            {
               break;
            }
            _loc2_ += 1;
            _loc1_ += 249856;
         }
         while(uint(_loc7_) > uint(_loc1_));
      }
      else
      {
         _loc18_ = _loc19_ + 4080;
         _loc12_ = (uint(_loc18_)) / uint(_loc20_);
         _loc18_ %= uint(_loc20_);
         _loc18_ = _loc18_ + 16;
         _loc1_ = _loc18_ - _loc20_;
         do
         {
            _loc18_ = _loc12_ & 0x1F;
            _loc9_ = 1;
            if(_loc18_ == 0)
            {
               _loc9_ = 0;
            }
            _loc14_ = _loc9_ & 1;
            _loc18_ = _loc12_ >>> 5;
            _loc18_ = _loc14_ + _loc18_;
            _loc18_ = _loc18_ << 2;
            _loc18_ = _loc18_ + 12;
            _loc1_ += _loc20_;
            _loc12_ += -1;
         }
         while(uint(_loc18_) > uint(_loc1_));
      }
      si32(_loc19_,_loc4_ + 24);
      si32(_loc17_,_loc4_ + 28);
      si32(_loc15_,_loc4_ + 32);
      si32(_loc16_,_loc4_ + 36);
      wdnative.eax = _loc19_;
      _loc3_ = _loc8_;
      wdnative.ESP = _loc3_;
   }
}

