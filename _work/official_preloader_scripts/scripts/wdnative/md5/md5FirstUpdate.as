package wdnative.md5
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F__Z12MD5TransformPjPh;
   import wdnative.Fmemcpy;
   
   public function md5FirstUpdate(param1:int, param2:int, param3:int) : void
   {
      var _loc12_:* = undefined;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc13_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int;
      _loc6_ = _loc5_ = wdnative.ESP;
      _loc4_ = param1;
      _loc14_ = param2;
      _loc13_ = param3;
      si32(0,_loc4_);
      _loc11_ = li32(_loc4_ + 12);
      _loc10_ = _loc11_ >>> 3;
      _loc9_ = _loc10_ & 0x3F;
      si32(_loc9_,_loc4_ + 4);
      _loc8_ = 64 - _loc9_;
      si32(_loc8_,_loc4_ + 8);
      _loc10_ = _loc13_ << 3;
      _loc10_ = _loc11_ + _loc10_;
      si32(_loc10_,_loc4_ + 12);
      _loc7_ = 1;
      if(uint(_loc10_) >= uint(_loc11_))
      {
         _loc7_ = 0;
      }
      _loc11_ = _loc7_ & 1;
      _loc7_ = li32(_loc4_ + 16);
      if(_loc11_ != 0)
      {
         _loc7_ += 1;
         si32(_loc7_,_loc4_ + 16);
      }
      _loc11_ = _loc13_ >>> 29;
      _loc11_ = _loc7_ + _loc11_;
      si32(_loc11_,_loc4_ + 16);
      if(uint(_loc8_) <= uint(_loc13_))
      {
         _loc5_ -= 16;
         si32(_loc8_,_loc5_ + 8);
         si32(_loc14_,_loc5_ + 4);
         _loc10_ = _loc4_ + 36;
         _loc11_ = _loc10_ + _loc9_;
         si32(_loc11_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative.Fmemcpy();
         _loc5_ += 16;
         _loc5_ = _loc5_ - 16;
         si32(_loc10_,_loc5_ + 4);
         _loc11_ = _loc4_ + 20;
         si32(_loc11_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative.F__Z12MD5TransformPjPh();
         _loc5_ += 16;
         _loc11_ = li32(_loc4_ + 8);
         si32(_loc11_,_loc4_);
      }
      wdnative.ESP = _loc5_ = _loc6_;
      return _loc12_;
   }
}

