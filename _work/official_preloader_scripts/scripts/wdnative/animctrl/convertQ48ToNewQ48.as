package wdnative.animctrl
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.sxi16;
   import wdnative.ESP;
   
   public function convertQ48ToNewQ48(param1:int, param2:int) : void
   {
      var _loc7_:* = undefined;
      var _loc10_:int = 0;
      var _loc22_:int = 0;
      var _loc20_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc23_:int = 0;
      var _loc19_:Number = NaN;
      var _loc9_:int = 0;
      var _loc4_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc8_:int;
      _loc10_ = _loc8_ = wdnative.ESP;
      _loc9_ = 0;
      _loc23_ = param1;
      _loc22_ = param2;
      if(_loc22_ >= 1)
      {
         do
         {
            _loc20_ = _loc23_ + _loc9_;
            var _loc18_:int = li16(_loc20_ + 14);
            var _loc17_:Number = _loc18_ = _loc18_ + -32768;
            _loc3_ = _loc17_ = _loc17_ * 0.000030517578125;
            _loc18_ = li16(_loc20_ + 12);
            _loc17_ = _loc18_ = _loc18_ + -32768;
            _loc5_ = _loc17_ = _loc17_ * 0.000030517578125;
            _loc18_ = si16(li16(_loc20_ + 16));
            var _loc16_:int = _loc18_ & 0x7FFF;
            var _loc15_:Number = _loc16_ = _loc16_ + -16384;
            _loc4_ = _loc15_ = _loc15_ * 0.00006103515625;
            if(_loc18_ <= -1)
            {
               _loc17_ = _loc4_;
               _loc4_ = _loc17_ = -_loc17_;
               _loc17_ = _loc3_;
               _loc3_ = _loc17_ = -_loc17_;
               _loc17_ = _loc5_;
               _loc5_ = _loc17_ = -_loc17_;
            }
            _loc15_ = _loc5_;
            var _loc21_:Number;
            _loc19_ = _loc21_ = 32768;
            _loc14_ = _loc21_ = _loc17_ = _loc15_ * _loc19_;
            _loc12_ = _loc13_ = 65535;
            if(_loc14_ <= 32767)
            {
               _loc12_ = 0;
               if(_loc14_ >= -32768)
               {
                  _loc12_ = _loc14_ ^ -32768;
               }
            }
            si16(_loc12_,_loc20_ + 12);
            _loc17_ = _loc3_;
            _loc12_ = _loc21_ = _loc17_ = _loc17_ * _loc19_;
            _loc6_ = _loc13_;
            if(_loc12_ <= 32767)
            {
               _loc6_ = 0;
               if(_loc12_ >= -32768)
               {
                  _loc6_ = _loc12_ ^ -32768;
               }
            }
            si16(_loc6_,_loc20_ + 14);
            _loc17_ = _loc4_;
            _loc11_ = _loc21_ = _loc17_ = _loc17_ * _loc19_;
            if(_loc11_ <= 32767)
            {
               _loc13_ = 0;
               if(_loc11_ >= -32768)
               {
                  _loc13_ = _loc11_ ^ -32768;
               }
            }
            si16(_loc13_,_loc20_ + 16);
         }
         while(_loc9_ += 18, _loc9_ < _loc22_);
      }
      wdnative.ESP = _loc8_ = _loc10_;
      return _loc7_;
   }
}

