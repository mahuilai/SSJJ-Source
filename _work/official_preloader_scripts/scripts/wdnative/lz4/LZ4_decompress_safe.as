package wdnative.lz4
{
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_LZ4_decompress_safe;
   import wdnative.eax;
   
   public function LZ4_decompress_safe(param1:int, param2:int, param3:int, param4:int) : int
   {
      var _loc10_:* = undefined;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int;
      _loc8_ = _loc7_ = wdnative.ESP;
      _loc6_ = param1;
      _loc12_ = param2;
      _loc11_ = param3;
      _loc9_ = param4;
      _loc7_ -= 16;
      si32(_loc9_,_loc7_ + 12);
      si32(_loc11_,_loc7_ + 8);
      si32(_loc12_,_loc7_ + 4);
      si32(_loc6_,_loc7_);
      wdnative.ESP = _loc7_;
      wdnative.F_LZ4_decompress_safe();
      _loc7_ += 16;
      var _loc5_:int;
      _loc10_ = _loc5_ = _loc6_ = wdnative.eax;
      wdnative.ESP = _loc7_ = _loc8_;
      return _loc10_;
   }
}

