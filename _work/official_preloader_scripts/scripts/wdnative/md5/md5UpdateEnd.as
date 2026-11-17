package wdnative.md5
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   
   public function md5UpdateEnd(param1:int, param2:int, param3:int, param4:int) : void
   {
      var _loc12_:* = undefined;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc14_:int = 0;
      var _loc10_:int = 0;
      var _loc13_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int;
      _loc7_ = _loc6_ = wdnative.ESP;
      _loc5_ = param1;
      _loc14_ = param2;
      _loc13_ = param3;
      _loc11_ = param4;
      _loc10_ = _loc11_ + _loc14_;
      _loc11_ = li32(_loc5_ + 8);
      if(uint(_loc10_) >= uint(_loc11_))
      {
         _loc9_ = 0;
         si32(_loc9_,_loc5_ + 4);
         _loc8_ = li32(_loc5_);
      }
      else
      {
         _loc8_ = 0;
         si32(_loc8_,_loc5_);
         _loc9_ = li32(_loc5_ + 4);
      }
      _loc11_ = _loc10_ - _loc8_;
      _loc6_ -= 16;
      si32(_loc11_,_loc6_ + 8);
      _loc11_ = _loc8_ - _loc14_;
      _loc11_ = _loc13_ + _loc11_;
      si32(_loc11_,_loc6_ + 4);
      _loc11_ = _loc5_ + _loc9_;
      _loc11_ = _loc11_ + 36;
      si32(_loc11_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.Fmemcpy();
      _loc6_ += 16;
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc12_;
   }
}

