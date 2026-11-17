package wdnative.animctrl
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.sf32;
   import avm2.intrinsics.memory.si16;
   import wdnative.ESP;
   
   public function compressAnim(param1:int, param2:int) : void
   {
      var _loc28_:* = undefined;
      var _loc14_:int = 0;
      var _loc38_:int = 0;
      var _loc34_:int = 0;
      var _loc30_:int = 0;
      var _loc31_:int = 0;
      var _loc29_:int = 0;
      var _loc40_:int = 0;
      var _loc3_:Number = NaN;
      var _loc4_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc6_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc12_:Number = NaN;
      var _loc10_:Number = NaN;
      var _loc37_:int = 0;
      var _loc27_:int = 0;
      var _loc33_:int = 0;
      var _loc32_:int = 0;
      var _loc13_:int;
      _loc14_ = _loc13_ = wdnative.ESP;
      _loc29_ = param1;
      _loc40_ = param2;
      if(_loc40_ >= 4)
      {
         var _loc39_:int = _loc40_ >> 31;
         var _temp_4:* = _loc39_ >>> 30;
         _loc39_ = _loc40_ + _temp_4;
         _loc38_ = _loc39_ >> 2;
         _loc37_ = 0;
         do
         {
            _loc39_ = _loc37_ << 2;
            var _loc36_:int = _loc29_ + _loc39_;
            var _loc16_:Number = lf32(_loc36_ + 20);
            var _loc24_:Number;
            var _loc15_:Number = _loc24_ = 0.5;
            var _loc26_:Number;
            _loc16_ = _loc26_ = _loc16_ *= _loc15_;
            var _loc19_:Number = Math.sin(_loc16_);
            _loc16_ = Math.cos(_loc16_);
            var _loc17_:Number = lf32(_loc36_ + 16);
            var _loc25_:Number;
            _loc17_ = _loc25_ = _loc17_ = _loc17_ * _loc15_;
            var _loc22_:Number = Math.sin(_loc17_);
            _loc17_ = Math.cos(_loc17_);
            var _loc20_:Number = lf32(_loc36_ + 12);
            var _loc21_:Number;
            _loc15_ = _loc21_ = _loc15_ = _loc20_ * _loc15_;
            _loc20_ = Math.sin(_loc15_);
            _loc15_ = Math.cos(_loc15_);
            var _loc35_:int = _loc37_ * 3;
            _loc40_ = _loc29_ + _loc35_;
            var _loc23_:Number = lf32(_loc36_);
            sf32(_loc23_,_loc40_);
            _loc23_ = lf32(_loc36_ + 4);
            sf32(_loc23_,_loc40_ + 4);
            var _loc18_:Number = lf32(_loc36_ + 8);
            sf32(_loc18_,_loc40_ + 8);
            _loc3_ = _loc18_ = _loc22_;
            _loc4_ = _loc18_ = _loc20_;
            _loc5_ = _loc18_ = _loc19_;
            _loc6_ = _loc18_ = _loc17_;
            _loc9_ = _loc18_ = _loc15_;
            _loc8_ = _loc26_ = _loc16_;
            _loc7_ = _loc26_ = _loc16_ = _loc4_ * _loc6_;
            _loc12_ = _loc26_ = _loc16_ = _loc9_ * _loc3_;
            _loc16_ = _loc26_ = _loc16_ = _loc7_ * _loc8_;
            var _loc11_:Number = _loc18_ = _loc11_ = _loc12_ * _loc5_;
            _loc11_ = _loc26_ = _loc16_ -= _loc11_;
            _loc10_ = _loc26_ = 32768;
            _loc34_ = _loc26_ = _loc16_ = _loc11_ * _loc10_;
            _loc27_ = _loc33_ = 65535;
            if(_loc34_ <= 32767)
            {
               _loc27_ = 0;
               if(_loc34_ >= -32768)
               {
                  _loc27_ = _loc34_ ^ -32768;
               }
            }
            _loc16_ = _loc26_ = _loc16_ = _loc7_ * _loc5_;
            _loc11_ = _loc18_ = _loc11_ = _loc12_ * _loc8_;
            _loc26_ = _loc16_ = _loc11_ + _loc16_;
            si16(_loc27_,_loc40_ + 12);
            _loc16_ = _loc26_;
            _loc30_ = _loc26_ = _loc16_ = _loc16_ * _loc10_;
            if(_loc30_ <= 32767)
            {
               _loc33_ = 0;
               if(_loc30_ >= -32768)
               {
                  _loc33_ = _loc30_ ^ -32768;
               }
            }
            _loc3_ = _loc26_ = _loc16_ = _loc4_ * _loc3_;
            _loc6_ = _loc26_ = _loc16_ = _loc9_ * _loc6_;
            _loc16_ = _loc26_ = _loc16_ = _loc3_ * _loc8_;
            _loc11_ = _loc18_ = _loc11_ = _loc6_ * _loc5_;
            _loc26_ = _loc16_ = _loc11_ - _loc16_;
            si16(_loc33_,_loc40_ + 14);
            _loc16_ = _loc26_;
            _loc11_ = _loc18_ = 16384;
            _loc31_ = _loc26_ = _loc16_ *= _loc11_;
            _loc33_ = 32767;
            if(_loc31_ <= 16383)
            {
               _loc33_ = 0;
               if(_loc31_ >= -16384)
               {
                  _loc39_ = _loc31_ ^ 0x4000;
                  _loc33_ = _loc39_ & 0x7FFF;
               }
            }
            _loc16_ = _loc26_ = _loc16_ = _loc3_ * _loc5_;
            _loc11_ = _loc18_ = _loc11_ = _loc6_ * _loc8_;
            _loc16_ = _loc26_ = _loc16_ = _loc11_ + _loc16_;
            _loc11_ = _loc18_ = 0;
            _loc32_ = 1;
            if(_loc16_ >= _loc11_)
            {
               _loc32_ = 0;
            }
            _loc39_ = _loc32_ << 15;
            _loc39_ = _loc33_ | _loc39_;
            si16(_loc39_,_loc40_ + 16);
         }
         while(_loc37_ += 6, _loc37_ < _loc38_);
      }
      wdnative.ESP = _loc13_ = _loc14_;
      return _loc28_;
   }
}

