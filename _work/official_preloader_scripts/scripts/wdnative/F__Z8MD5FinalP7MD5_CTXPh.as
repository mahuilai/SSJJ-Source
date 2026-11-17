package wdnative
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   
   public function F__Z8MD5FinalP7MD5_CTXPh() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc11_ = li32(_loc1_ + 12);
      si8(_loc11_,_loc3_ - 8);
      var _loc10_:int = _loc11_ >>> 8;
      si8(_loc10_,_loc3_ - 7);
      _loc10_ = _loc11_ >>> 16;
      si8(_loc10_,_loc3_ - 6);
      _loc10_ = _loc11_ >>> 24;
      si8(_loc10_,_loc3_ - 5);
      _loc9_ = li32(_loc1_ + 16);
      si8(_loc9_,_loc3_ - 4);
      _loc10_ = _loc9_ >>> 8;
      si8(_loc10_,_loc3_ - 3);
      _loc10_ = _loc9_ >>> 16;
      si8(_loc10_,_loc3_ - 2);
      _loc10_ = _loc9_ >>> 24;
      si8(_loc10_,_loc3_ - 1);
      _loc8_ = _loc11_ >>> 3;
      _loc7_ = _loc8_ & 0x3F;
      _loc6_ = 56;
      if(uint(_loc7_) >= uint(_loc6_))
      {
         _loc6_ = 120;
      }
      _loc6_ -= _loc7_;
      _loc10_ = _loc6_ << 3;
      _loc10_ = _loc11_ + _loc10_;
      si32(_loc10_,_loc1_ + 12);
      _loc5_ = 1;
      if(uint(_loc10_) >= uint(_loc11_))
      {
         _loc5_ = 0;
      }
      _loc10_ = _loc5_ & 1;
      if(_loc10_ != 0)
      {
         _loc9_ += 1;
         si32(_loc9_,_loc1_ + 16);
      }
      _loc11_ = 64 - _loc7_;
      _loc10_ = _loc6_ >>> 29;
      _loc10_ = _loc9_ + _loc10_;
      si32(_loc10_,_loc1_ + 16);
      _loc9_ = 0;
      if(uint(_loc11_) <= uint(_loc6_))
      {
         _loc2_ -= 16;
         si32(wdnative._PADDING,_loc2_ + 4);
         _loc10_ = _loc1_ + 36;
         var _loc4_:int = _loc10_ + _loc7_;
         si32(_loc4_,_loc2_);
         si32(_loc11_,_loc2_ + 8);
         wdnative.ESP = _loc2_;
         wdnative.Fmemcpy();
         _loc2_ += 16;
         _loc2_ -= 16;
         si32(_loc10_,_loc2_ + 4);
         _loc5_ = _loc1_ + 20;
         si32(_loc5_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F__Z12MD5TransformPjPh();
         _loc2_ += 16;
         var _temp_21:* = int(_loc11_ + 64);
         _loc7_ = 0;
         _loc9_ = _loc11_;
         if(uint(_temp_21) <= uint(_loc6_))
         {
            _loc10_ = _loc8_ & 0x3F;
            _loc8_ = 128 - _loc10_;
            _loc9_ = 64 - _loc10_;
            do
            {
               _loc2_ -= 16;
               si32(_loc5_,_loc2_);
               _loc10_ = wdnative._PADDING + _loc9_;
               si32(_loc10_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative.F__Z12MD5TransformPjPh();
               _loc2_ += 16;
               _loc8_ += 64;
               _loc9_ += 64;
               _loc7_ = 0;
            }
            while(uint(_loc8_) <= uint(_loc6_));
         }
      }
      _loc10_ = _loc6_ - _loc9_;
      _loc2_ -= 16;
      si32(_loc10_,_loc2_ + 8);
      _loc10_ = wdnative._PADDING + _loc9_;
      si32(_loc10_,_loc2_ + 4);
      _loc10_ = _loc1_ + _loc7_;
      _loc10_ = _loc10_ + 36;
      si32(_loc10_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.Fmemcpy();
      _loc2_ += 16;
      _loc6_ = li32(_loc1_ + 12);
      _loc10_ = _loc6_ + 64;
      si32(_loc10_,_loc1_ + 12);
      _loc7_ = 1;
      if(uint(_loc10_) >= uint(_loc6_))
      {
         _loc7_ = 0;
      }
      _loc10_ = _loc7_ & 1;
      _loc9_ = li32(_loc1_ + 16);
      if(_loc10_ != 0)
      {
         _loc9_ += 1;
         si32(_loc9_,_loc1_ + 16);
      }
      _loc7_ = li32(_loc3_ + 4);
      _loc5_ = _loc6_ >>> 3;
      _loc6_ = _loc5_ & 0x3F;
      _loc8_ = 64 - _loc6_;
      si32(_loc9_,_loc1_ + 16);
      if(uint(_loc8_) >= 9)
      {
         _loc9_ = _loc1_ + 20;
         _loc8_ = 0;
      }
      else
      {
         _loc2_ -= 16;
         _loc11_ = _loc3_ - 8;
         si32(_loc11_,_loc2_ + 4);
         _loc10_ = _loc1_ + 36;
         _loc4_ = _loc10_ + _loc6_;
         si32(_loc4_,_loc2_);
         si32(_loc8_,_loc2_ + 8);
         wdnative.ESP = _loc2_;
         wdnative.Fmemcpy();
         _loc2_ += 16;
         _loc2_ -= 16;
         si32(_loc10_,_loc2_ + 4);
         _loc9_ = _loc1_ + 20;
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F__Z12MD5TransformPjPh();
         _loc2_ += 16;
         var _temp_38:* = int(_loc8_ + 64);
         _loc6_ = 0;
         if(uint(_temp_38) <= 8)
         {
            _loc10_ = _loc5_ & 0x3F;
            _loc5_ = 128 - _loc10_;
            _loc8_ = 64 - _loc10_;
            do
            {
               _loc2_ -= 16;
               si32(_loc9_,_loc2_);
               _loc10_ = _loc11_ + _loc8_;
               si32(_loc10_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative.F__Z12MD5TransformPjPh();
               _loc2_ += 16;
               _loc5_ += 64;
               _loc8_ += 64;
               _loc6_ = 0;
            }
            while(uint(_loc5_) < 9);
         }
      }
      _loc2_ -= 16;
      _loc10_ = 8 - _loc8_;
      si32(_loc10_,_loc2_ + 8);
      _loc10_ = _loc3_ - 8;
      _loc10_ = _loc10_ + _loc8_;
      si32(_loc10_,_loc2_ + 4);
      _loc10_ = _loc1_ + _loc6_;
      _loc10_ = _loc10_ + 36;
      si32(_loc10_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.Fmemcpy();
      _loc2_ += 16;
      _loc10_ = li32(_loc9_);
      si8(_loc10_,_loc7_);
      _loc10_ = li32(_loc9_);
      _loc10_ = _loc10_ >>> 8;
      si8(_loc10_,_loc7_ + 1);
      _loc10_ = li16(_loc9_ + 2);
      si8(_loc10_,_loc7_ + 2);
      _loc10_ = li8(_loc9_ + 3);
      si8(_loc10_,_loc7_ + 3);
      _loc10_ = li32(_loc1_ + 24);
      si8(_loc10_,_loc7_ + 4);
      _loc10_ = li32(_loc1_ + 24);
      _loc10_ = _loc10_ >>> 8;
      si8(_loc10_,_loc7_ + 5);
      _loc10_ = li16(_loc1_ + 26);
      si8(_loc10_,_loc7_ + 6);
      _loc10_ = li8(_loc1_ + 27);
      si8(_loc10_,_loc7_ + 7);
      _loc10_ = li32(_loc1_ + 28);
      si8(_loc10_,_loc7_ + 8);
      _loc10_ = li32(_loc1_ + 28);
      _loc10_ = _loc10_ >>> 8;
      si8(_loc10_,_loc7_ + 9);
      _loc10_ = li16(_loc1_ + 30);
      si8(_loc10_,_loc7_ + 10);
      _loc10_ = li8(_loc1_ + 31);
      si8(_loc10_,_loc7_ + 11);
      _loc10_ = li32(_loc1_ + 32);
      si8(_loc10_,_loc7_ + 12);
      _loc10_ = li32(_loc1_ + 32);
      _loc10_ = _loc10_ >>> 8;
      si8(_loc10_,_loc7_ + 13);
      _loc10_ = li16(_loc1_ + 34);
      si8(_loc10_,_loc7_ + 14);
      _loc10_ = li8(_loc1_ + 35);
      si8(_loc10_,_loc7_ + 15);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

