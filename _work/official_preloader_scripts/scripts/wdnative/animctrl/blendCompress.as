package wdnative.animctrl
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Z15QuaternionSlerpPKfPffS1_;
   
   public function blendCompress(param1:int, param2:int, param3:Number, param4:Vector.<Number>) : void
   {
      var _loc27_:* = undefined;
      var _loc10_:int = 0;
      var _loc18_:Number = NaN;
      var _loc28_:int = 0;
      var _loc35_:int = 0;
      var _loc25_:Number = NaN;
      var _loc16_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc15_:Number = NaN;
      var _loc24_:Number = NaN;
      var _loc26_:Number = NaN;
      var _loc32_:Number = NaN;
      var _loc22_:Number = NaN;
      var _loc34_:Number = NaN;
      var _loc29_:Number = NaN;
      _loc10_ = wdnative.ESP;
      var _loc9_:int = _loc10_ - 80;
      _loc15_ = _loc24_ = 0;
      _loc28_ = param1;
      _loc35_ = param2;
      var _loc13_:Number = _loc26_ = param3;
      if(_loc13_ >= _loc15_)
      {
         _loc13_ = _loc26_;
         _loc15_ = _loc25_ = 1;
         _loc24_ = _loc26_;
         if(!(_loc13_ <= _loc15_ | _loc13_ != _loc13_ | _loc15_ != _loc15_))
         {
            _loc24_ = _loc25_;
         }
      }
      _loc18_ = _loc24_;
      var _loc21_:Number;
      _loc16_ = _loc21_ = 1;
      while(true)
      {
         if(_loc18_ >= 0.001)
         {
            if(_loc28_ != _loc35_)
            {
               if(!(_loc18_ <= 0.999 | _loc18_ != _loc18_ | false))
               {
                  var _loc33_:int = li16(_loc35_ + 12);
                  _loc15_ = _loc33_ = _loc33_ + -32768;
                  _loc24_ = _loc15_ = _loc15_ * 0.000030517578125;
                  sf32(_loc24_,_loc10_ - 32);
                  _loc33_ = li16(_loc35_ + 14);
                  _loc15_ = _loc33_ = _loc33_ + -32768;
                  _loc26_ = _loc15_ = _loc15_ * 0.000030517578125;
                  sf32(_loc26_,_loc10_ - 28);
                  _loc33_ = si16(li16(_loc35_ + 16));
                  var _loc31_:int = _loc33_ & 0x7FFF;
                  _loc13_ = _loc31_ = _loc31_ + -16384;
                  _loc32_ = _loc13_ = _loc13_ * 0.00006103515625;
                  sf32(_loc32_,_loc10_ - 24);
                  _loc13_ = _loc24_;
                  var _loc17_:Number = _loc13_ *= _loc13_;
                  var _temp_23:* = _loc17_;
                  _loc17_ = _loc13_ = _loc16_ - _temp_23;
                  var _temp_29:* = _loc17_;
                  var _loc23_:Number = _loc26_;
                  var _loc19_:Number = _loc23_ *= _loc23_;
                  _loc17_ = _loc13_ = _temp_29 - _loc19_;
                  var _temp_35:* = _loc17_;
                  _loc23_ = _loc32_;
                  _loc19_ = _loc23_ *= _loc23_;
                  _loc17_ = _loc13_ = _temp_35 - _loc19_;
                  sf32(_loc17_,_loc10_ - 68);
                  var _loc30_:int = li32(_loc10_ - 68);
                  var _temp_39:* = _loc30_ >> 1;
                  _loc30_ = 1597463174 - _temp_39;
                  si32(_loc30_,_loc10_ - 72);
                  _loc13_ = _loc17_;
                  _loc19_ = 0.5;
                  var _temp_41:* = _loc19_;
                  _loc19_ = _loc23_ = _loc13_ * _temp_41;
                  var _temp_44:* = _loc19_;
                  var _loc20_:Number = lf32(_loc10_ - 72);
                  var _temp_51:* = _loc19_ = _loc23_ = (_loc23_ = _loc19_ = _loc23_ = _temp_44 * _loc20_) * _loc20_;
                  var _loc14_:Number;
                  var _loc6_:Number = _loc14_ = _loc6_ = (_loc23_ = _loc19_ = 1.5) - _temp_51;
                  var _loc11_:Number;
                  _loc20_ = _loc11_ = _loc20_ = _loc6_ * _loc20_;
                  var _temp_62:* = _loc14_ = _loc6_ = (_loc6_ = _loc14_ = _loc6_ = _temp_44 * _loc20_) * _loc20_;
                  _loc6_ = _loc14_ = _loc6_ = _loc23_ - _temp_62;
                  _loc20_ = _loc11_ = _loc20_ = _loc6_ * _loc20_;
                  var _loc12_:Number;
                  var _loc5_:Number = _loc12_ = _loc5_ = _temp_44 * _loc20_;
                  _loc12_ = _loc5_ = _loc5_ * _loc20_;
                  var _temp_74:* = _loc12_;
                  _loc23_ = _loc19_ = _loc23_ -= _temp_74;
                  _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc20_;
                  _loc25_ = _loc13_ = _loc23_ * _loc13_;
                  if(_loc33_ <= -1)
                  {
                     _loc15_ = _loc25_;
                     _loc25_ = _loc15_ = -_loc15_;
                  }
                  sf32(_loc25_,_loc10_ - 20);
                  _loc21_ = lf32(_loc35_);
                  param4[0] = _loc21_;
                  _loc21_ = lf32(_loc35_ + 4);
                  param4[1] = _loc21_;
                  _loc21_ = lf32(_loc35_ + 8);
                  param4[2] = _loc21_;
                  param4[3] = _loc24_;
                  param4[4] = _loc26_;
                  param4[5] = _loc32_;
                  param4[6] = _loc25_;
                  break;
               }
               _loc33_ = li16(_loc28_ + 12);
               _loc15_ = _loc33_ = _loc33_ + -32768;
               _loc21_ = _loc15_ = _loc15_ * 0.000030517578125;
               sf32(_loc21_,_loc10_ - 16);
               _loc15_ = _loc21_;
               _loc21_ = _loc15_ *= _loc15_;
               var _temp_92:* = _loc21_;
               _loc21_ = _loc15_ = _loc16_ - _temp_92;
               var _temp_103:* = _loc21_;
               sf32(_loc17_ = _loc13_ = (_loc13_ = _loc31_ = (_loc31_ = li16(_loc28_ + 14)) + -32768) * 0.000030517578125,_loc10_ - 12);
               _loc13_ = _loc17_;
               _loc17_ = _loc13_ *= _loc13_;
               _loc21_ = _loc15_ = _temp_103 - _loc17_;
               var _temp_115:* = _loc21_;
               sf32(_loc19_ = _loc23_ = (_loc23_ = _loc30_ = (_loc30_ = (_loc33_ = si16(li16(_loc28_ + 16))) & 0x7FFF) + -16384) * 0.00006103515625,_loc10_ - 8);
               _loc23_ = _loc19_;
               _loc19_ = _loc23_ *= _loc23_;
               _loc17_ = _loc13_ = _temp_115 - _loc19_;
               sf32(_loc17_,_loc10_ - 52);
               _loc30_ = li32(_loc10_ - 52);
               var _temp_119:* = _loc30_ >> 1;
               _loc30_ = 1597463174 - _temp_119;
               si32(_loc30_,_loc10_ - 56);
               _loc13_ = _loc17_;
               _loc7_ = _loc19_ = 0.5;
               _loc19_ = _loc23_ = _loc13_ * _loc7_;
               var _temp_123:* = _loc19_;
               _loc5_ = lf32(_loc10_ - 56);
               var _temp_130:* = _loc11_ = _loc20_ = (_loc20_ = _loc11_ = _loc20_ = _temp_123 * _loc5_) * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = (_loc8_ = _loc14_ = 1.5) - _temp_130;
               _loc5_ = _loc12_ = _loc5_ = _loc20_ * _loc5_;
               var _temp_141:* = _loc11_ = _loc20_ = (_loc20_ = _loc11_ = _loc20_ = _temp_123 * _loc5_) * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc8_ - _temp_141;
               _loc5_ = _loc12_ = _loc5_ = _loc20_ * _loc5_;
               _loc23_ = _loc19_ = _loc23_ = _temp_123 * _loc5_;
               _loc19_ = _loc23_ = _loc23_ * _loc5_;
               var _temp_153:* = _loc19_;
               _loc23_ = _loc19_ = _loc23_ = _loc8_ - _temp_153;
               _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc5_;
               _loc34_ = _loc13_ = _loc23_ * _loc13_;
               if(_loc33_ <= -1)
               {
                  _loc15_ = _loc34_;
                  _loc34_ = _loc15_ = -_loc15_;
               }
               sf32(_loc34_,_loc10_ - 4);
               _loc33_ = li16(_loc35_ + 12);
               _loc15_ = _loc33_ = _loc33_ + -32768;
               _loc21_ = _loc15_ = _loc15_ * 0.000030517578125;
               sf32(_loc21_,_loc10_ - 32);
               _loc15_ = _loc21_;
               _loc15_ = _loc21_ = _loc15_ *= _loc15_;
               _loc15_ = _loc21_ = _loc15_ = _loc16_ - _loc15_;
               _loc31_ = li16(_loc35_ + 14);
               _loc13_ = _loc31_ = _loc31_ + -32768;
               _loc17_ = _loc13_ = _loc13_ * 0.000030517578125;
               sf32(_loc17_,_loc10_ - 28);
               _loc13_ = _loc17_;
               _loc13_ = _loc17_ = _loc13_ *= _loc13_;
               _loc13_ = _loc21_ = _loc15_ -= _loc13_;
               _loc33_ = si16(li16(_loc35_ + 16));
               _loc30_ = _loc33_ & 0x7FFF;
               _loc23_ = _loc30_ = _loc30_ + -16384;
               _loc19_ = _loc23_ = _loc23_ * 0.00006103515625;
               sf32(_loc19_,_loc10_ - 24);
               _loc23_ = _loc19_;
               _loc23_ = _loc19_ = _loc23_ *= _loc23_;
               _loc17_ = _loc13_ -= _loc23_;
               sf32(_loc17_,_loc10_ - 60);
               _loc30_ = li32(_loc10_ - 60);
               _loc30_ = _loc30_ >> 1;
               _loc30_ = 1597463174 - _loc30_;
               si32(_loc30_,_loc10_ - 64);
               _loc13_ = _loc17_;
               _loc23_ = _loc19_ = _loc23_ = _loc13_ * _loc7_;
               _loc5_ = lf32(_loc10_ - 64);
               _loc20_ = _loc11_ = _loc20_ = _loc23_ * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc20_ * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc8_ - _loc20_;
               _loc5_ = _loc12_ = _loc5_ = _loc20_ * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc23_ * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc20_ * _loc5_;
               _loc20_ = _loc11_ = _loc20_ = _loc8_ - _loc20_;
               _loc5_ = _loc12_ = _loc5_ = _loc20_ * _loc5_;
               _loc23_ = _loc19_ = _loc23_ *= _loc5_;
               _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc5_;
               _loc23_ = _loc19_ = _loc23_ = _loc8_ - _loc23_;
               _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc5_;
               _loc29_ = _loc13_ = _loc23_ * _loc13_;
               if(_loc33_ <= -1)
               {
                  _loc15_ = _loc29_;
                  _loc29_ = _loc15_ = -_loc15_;
               }
               _loc21_ = _loc15_ = _loc16_ - _loc18_;
               sf32(_loc29_,_loc10_ - 20);
               _loc9_ -= 16;
               _loc31_ = _loc10_ - 48;
               si32(_loc31_,_loc9_ + 12);
               _loc31_ = _loc10_ - 32;
               si32(_loc31_,_loc9_ + 4);
               _loc31_ = _loc10_ - 16;
               si32(_loc31_,_loc9_);
               sf32(_loc24_,_loc9_ + 8);
               wdnative.ESP = _loc9_;
               wdnative.F__Z15QuaternionSlerpPKfPffS1_();
               _loc9_ += 16;
               _loc13_ = lf32(_loc35_);
               _loc13_ = _loc17_ = _loc13_ = _loc13_ * _loc18_;
               _loc15_ = _loc21_;
               _loc23_ = lf32(_loc28_);
               _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc15_;
               _loc11_ = _loc13_ = _loc23_ + _loc13_;
               _loc13_ = lf32(_loc28_ + 8);
               _loc23_ = lf32(_loc35_ + 8);
               _loc5_ = lf32(_loc28_ + 4);
               _loc6_ = lf32(_loc35_ + 4);
               param4[0] = _loc11_;
               _loc20_ = _loc11_ = _loc20_ = _loc6_ * _loc18_;
               _loc5_ = _loc12_ = _loc5_ *= _loc15_;
               _loc12_ = _loc5_ = _loc5_ + _loc20_;
               param4[1] = _loc12_;
               _loc23_ = _loc19_ = _loc23_ *= _loc18_;
               _loc15_ = _loc21_ = _loc15_ = _loc13_ * _loc15_;
               _loc21_ = _loc15_ = _loc15_ + _loc23_;
               param4[2] = _loc21_;
               _loc21_ = lf32(_loc10_ - 48);
               param4[3] = _loc21_;
               _loc21_ = lf32(_loc10_ - 44);
               param4[4] = _loc21_;
               _loc21_ = lf32(_loc10_ - 40);
               param4[5] = _loc21_;
               _loc21_ = lf32(_loc10_ - 36);
               param4[6] = _loc21_;
               break;
            }
         }
         _loc33_ = li16(_loc28_ + 12);
         _loc15_ = _loc33_ = _loc33_ + -32768;
         _loc26_ = _loc15_ = _loc15_ * 0.000030517578125;
         sf32(_loc26_,_loc10_ - 16);
         _loc33_ = li16(_loc28_ + 14);
         _loc15_ = _loc33_ = _loc33_ + -32768;
         _loc24_ = _loc15_ = _loc15_ * 0.000030517578125;
         sf32(_loc24_,_loc10_ - 12);
         _loc33_ = si16(li16(_loc28_ + 16));
         _loc31_ = _loc33_ & 0x7FFF;
         _loc13_ = _loc31_ = _loc31_ + -16384;
         _loc22_ = _loc13_ = _loc13_ * 0.00006103515625;
         sf32(_loc22_,_loc10_ - 8);
         _loc13_ = _loc26_;
         _loc13_ = _loc17_ = _loc13_ *= _loc13_;
         _loc13_ = _loc17_ = _loc13_ = _loc16_ - _loc13_;
         _loc23_ = _loc24_;
         _loc23_ = _loc19_ = _loc23_ *= _loc23_;
         _loc13_ = _loc17_ = _loc13_ -= _loc23_;
         _loc23_ = _loc22_;
         _loc23_ = _loc19_ = _loc23_ *= _loc23_;
         _loc17_ = _loc13_ -= _loc23_;
         sf32(_loc17_,_loc10_ - 76);
         _loc30_ = li32(_loc10_ - 76);
         _loc30_ = _loc30_ >> 1;
         _loc30_ = 1597463174 - _loc30_;
         si32(_loc30_,_loc10_ - 80);
         _loc13_ = _loc17_;
         _loc23_ = _loc19_ = 0.5;
         _loc23_ = _loc19_ = _loc23_ = _loc13_ * _loc23_;
         _loc20_ = lf32(_loc10_ - 80);
         _loc5_ = _loc12_ = _loc5_ = _loc23_ * _loc20_;
         _loc6_ = _loc12_ = _loc5_ = _loc5_ * _loc20_;
         _loc5_ = _loc12_ = 1.5;
         _loc6_ = _loc14_ = _loc6_ = _loc5_ - _loc6_;
         _loc20_ = _loc11_ = _loc20_ = _loc6_ * _loc20_;
         _loc6_ = _loc14_ = _loc6_ = _loc23_ * _loc20_;
         _loc6_ = _loc14_ = _loc6_ = _loc6_ * _loc20_;
         _loc6_ = _loc14_ = _loc6_ = _loc5_ - _loc6_;
         _loc20_ = _loc11_ = _loc20_ = _loc6_ * _loc20_;
         _loc23_ = _loc19_ = _loc23_ *= _loc20_;
         _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc20_;
         _loc23_ = _loc19_ = _loc23_ = _loc5_ - _loc23_;
         _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc20_;
         _loc25_ = _loc13_ = _loc23_ * _loc13_;
         if(_loc33_ <= -1)
         {
            _loc15_ = _loc25_;
            _loc25_ = _loc15_ = -_loc15_;
         }
         sf32(_loc25_,_loc10_ - 4);
         _loc21_ = lf32(_loc28_);
         param4[0] = _loc21_;
         _loc21_ = lf32(_loc28_ + 4);
         param4[1] = _loc21_;
         _loc21_ = lf32(_loc28_ + 8);
         param4[2] = _loc21_;
         param4[3] = _loc26_;
         param4[4] = _loc24_;
         param4[5] = _loc22_;
         param4[6] = _loc25_;
         break;
      }
      wdnative.ESP = _loc9_ = _loc10_;
      return _loc27_;
   }
}

