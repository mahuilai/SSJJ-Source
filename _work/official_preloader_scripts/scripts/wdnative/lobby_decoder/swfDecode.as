package wdnative.lobby_decoder
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative_nternal.L__2E_str324;
   
   public function swfDecode(param1:int, param2:int) : void
   {
      var _loc13_:* = undefined;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc3_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc14_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int;
      _loc5_ = _loc4_ = wdnative.ESP;
      _loc3_ = param1;
      _loc15_ = param2;
      _loc14_ = _loc15_ >> 31;
      _loc14_ = _loc14_ >>> 22;
      _loc12_ = _loc15_ + _loc14_;
      _loc11_ = _loc12_ >> 10;
      trace("decode buffersize" + param2);
      trace("allocate string");
      trace("start decode new");
      _loc10_ = 5;
      if(_loc15_ >= 1024)
      {
         _loc9_ = 0;
         _loc10_ = 0;
         _loc8_ = 0;
         do
         {
            _loc14_ = _loc9_ + wdnative_nternal.L__2E_str324;
            _loc14_ = li8(_loc14_ + 5);
            var _loc7_:int = _loc10_ << 10;
            _loc7_ = _loc3_ + _loc7_;
            var _loc6_:int = li8(_loc7_ + 91);
            _loc14_ ^= _loc6_;
            si8(_loc14_,_loc7_ + 91);
            _loc9_ = _loc8_ + 1;
            _loc8_ = 0;
            if(_loc9_ != 6)
            {
               _loc8_ = _loc9_;
            }
            _loc9_ = 0 - _loc8_;
         }
         while(_loc10_ += 1, _loc10_ < _loc11_);
         _loc10_ = 5 - _loc8_;
      }
      _loc14_ = _loc12_ & -1024;
      _loc14_ = _loc15_ - _loc14_;
      if(_loc14_ >= 91)
      {
         _loc14_ = wdnative_nternal.L__2E_str324 + _loc10_;
         var _temp_14:* = li8(_loc14_);
         var _temp_12:* = (_loc7_ = _loc11_ << 10) | 0x5B;
         _loc7_ = _loc3_ + _temp_12;
         _loc14_ = _temp_14 ^ li8(_loc7_);
         si8(_loc14_,_loc7_);
      }
      trace("start read Bytes");
      trace("read Bytes end");
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc13_;
   }
}

