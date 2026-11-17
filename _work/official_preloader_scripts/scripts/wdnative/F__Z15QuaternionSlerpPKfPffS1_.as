package wdnative
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.lf64;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.sf32;
   import avm2.intrinsics.memory.sf64;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal._pio2_lo;
   
   public function F__Z15QuaternionSlerpPKfPffS1_() : void
   {
      var _loc12_:int = 0;
      var _loc43_:int = 0;
      var _loc29_:int = 0;
      var _loc40_:int = 0;
      var _loc10_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc38_:int = 0;
      var _loc36_:int = 0;
      var _loc16_:Number = NaN;
      var _loc24_:Number = NaN;
      var _loc1_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc4_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc14_:Number = NaN;
      var _loc20_:Number = NaN;
      var _loc23_:* = NaN;
      var _loc18_:Number = NaN;
      var _loc42_:Number = NaN;
      var _loc31_:Number = NaN;
      var _loc17_:Number = NaN;
      var _loc13_:Number = NaN;
      var _loc26_:Number = NaN;
      var _loc28_:Number = NaN;
      var _loc22_:Number = NaN;
      var _loc25_:Number = NaN;
      var _loc2_:Number = NaN;
      var _loc30_:Number = NaN;
      var _loc37_:Number = NaN;
      _loc12_ = wdnative.ESP;
      var _loc11_:int = _loc12_ - 24;
      _loc29_ = li32(_loc12_ + 4);
      _loc16_ = _loc26_ = lf32(_loc29_ + 4);
      _loc43_ = li32(_loc12_);
      _loc14_ = _loc28_ = lf32(_loc43_ + 4);
      var _loc27_:Number;
      _loc20_ = _loc27_ = _loc20_ = _loc14_ + _loc16_;
      _loc18_ = _loc27_ = _loc20_ *= _loc20_;
      _loc24_ = _loc22_ = lf32(_loc29_);
      _loc20_ = _loc25_ = lf32(_loc43_);
      var _loc19_:Number;
      _loc23_ = _loc19_ = _loc23_ = _loc20_ + _loc24_;
      _loc1_ = _loc19_ = _loc23_ *= _loc23_;
      _loc2_ = 0;
      _loc23_ = _loc19_ = _loc2_;
      _loc1_ += _loc23_;
      var _loc21_:Number;
      _loc1_ = _loc21_ = _loc1_;
      var _loc15_:Number;
      _loc1_ = _loc15_ = _loc18_ += _loc1_;
      _loc3_ = _loc17_ = lf32(_loc29_ + 8);
      _loc18_ = _loc13_ = lf32(_loc43_ + 8);
      var _loc41_:Number;
      _loc4_ = _loc41_ = _loc4_ = _loc18_ + _loc3_;
      _loc4_ = _loc41_ = _loc4_ *= _loc4_;
      _loc1_ = _loc4_ + _loc1_;
      _loc1_ = _loc21_ = _loc1_;
      _loc7_ = _loc42_ = lf32(_loc29_ + 12);
      _loc4_ = _loc31_ = lf32(_loc43_ + 12);
      var _loc33_:Number;
      var _loc6_:Number = _loc33_ = _loc6_ = _loc4_ + _loc7_;
      _loc6_ = _loc33_ = _loc6_ *= _loc6_;
      _loc1_ = _loc6_ + _loc1_;
      _loc1_ = _loc21_ = _loc1_;
      var _loc35_:Number;
      _loc14_ = _loc35_ = _loc14_ -= _loc16_;
      _loc14_ = _loc35_ = _loc14_ *= _loc14_;
      _loc20_ = _loc27_ = _loc20_ -= _loc24_;
      _loc20_ = _loc27_ = _loc20_ *= _loc20_;
      _loc20_ = _loc27_ = _loc20_ = _loc20_ + _loc23_;
      _loc20_ = _loc27_ = _loc20_ = _loc14_ + _loc20_;
      _loc23_ = _loc19_ = _loc23_ = _loc18_ - _loc3_;
      _loc23_ = _loc19_ = _loc23_ *= _loc23_;
      _loc20_ = _loc27_ = _loc20_ = _loc23_ + _loc20_;
      _loc23_ = _loc19_ = _loc23_ = _loc4_ - _loc7_;
      _loc23_ = _loc19_ = _loc23_ *= _loc23_;
      _loc20_ = _loc27_ = _loc20_ = _loc23_ + _loc20_;
      if(!(_loc20_ <= _loc1_ | _loc20_ != _loc20_ | _loc1_ != _loc1_))
      {
         _loc22_ = _loc20_ = -_loc24_;
         sf32(_loc22_,_loc29_);
         _loc26_ = _loc20_ = -_loc16_;
         sf32(_loc26_,_loc29_ + 4);
         _loc17_ = _loc20_ = -_loc3_;
         sf32(_loc17_,_loc29_ + 8);
         _loc42_ = _loc20_ = -_loc7_;
         sf32(_loc42_,_loc29_ + 12);
         _loc31_ = lf32(_loc43_ + 12);
         _loc13_ = lf32(_loc43_ + 8);
         _loc28_ = lf32(_loc43_ + 4);
         _loc25_ = lf32(_loc43_);
      }
      _loc40_ = li32(_loc12_ + 12);
      _loc37_ = lf32(_loc12_ + 8);
      _loc20_ = _loc26_;
      _loc5_ = _loc28_;
      _loc20_ = _loc27_ = _loc20_ = _loc5_ * _loc20_;
      _loc23_ = _loc22_;
      _loc14_ = _loc25_;
      _loc23_ = _loc19_ = _loc23_ = _loc14_ * _loc23_;
      _loc20_ = _loc27_ = _loc20_ = _loc23_ + _loc20_;
      _loc23_ = _loc17_;
      _loc14_ = _loc13_;
      _loc23_ = _loc19_ = _loc23_ = _loc14_ * _loc23_;
      _loc20_ = _loc27_ = _loc20_ += _loc23_;
      _loc14_ = _loc42_;
      _loc23_ = _loc31_;
      _loc23_ = _loc19_ = _loc23_ = _loc23_ * _loc14_;
      _loc10_ = _loc27_ = _loc20_ += _loc23_;
      _loc9_ = _loc10_ + 1;
      if(!(_loc9_ <= 1e-8 | _loc9_ != _loc9_ | false))
      {
         _loc8_ = 1 - _loc10_;
         if(!(_loc8_ <= 1e-8 | _loc8_ != _loc8_ | false))
         {
            sf64(_loc10_,_loc12_ - 8);
            var _loc39_:int = _loc12_ - 8;
            _loc39_ = _loc39_ | 4;
            _loc38_ = li32(_loc39_);
            _loc36_ = _loc38_ & 0x7FFFFFFF;
            if((uint(_loc36_)) >= 1072693248)
            {
               var _temp_111:* = li32(_loc12_ - 8);
               _loc39_ = (_loc39_ = _loc36_ + -1072693248) | _temp_111;
               if(_loc39_ == 0)
               {
                  if(_loc38_ <= 0)
                  {
                     _loc20_ = lf64(wdnative_nternal._pio2_lo);
                     _loc20_ += _loc20_;
                     _loc2_ = _loc20_ + 3.141592653589793;
                  }
               }
               else
               {
                  _loc20_ = _loc10_ - _loc10_;
                  _loc2_ = _loc20_ / _loc20_;
               }
            }
            else if(uint(_loc36_) <= 1071644671)
            {
               if(uint(_loc36_) <= 1012924416)
               {
                  _loc20_ = lf64(wdnative_nternal._pio2_lo);
                  _loc2_ = _loc20_ + 1.5707963267948966;
               }
               else
               {
                  _loc20_ = _loc10_ * _loc10_;
                  _loc23_ = _loc20_ * 0.00003479331075960212;
                  _loc23_ = _loc23_ + 0.0007915349942898145;
                  _loc23_ = _loc23_ * _loc20_;
                  _loc23_ = _loc23_ + -0.04005553450067941;
                  _loc23_ = _loc23_ * _loc20_;
                  _loc23_ = _loc23_ + 0.20121253213486293;
                  _loc23_ = _loc23_ * _loc20_;
                  _loc23_ = _loc23_ + -0.3255658186224009;
                  _loc23_ = _loc23_ * _loc20_;
                  _loc23_ = _loc23_ + 0.16666666666666666;
                  _loc20_ = _loc23_ * _loc20_ / ((_loc20_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = _loc20_ * 0.07703815055590194) + -0.6882839716054533) * _loc20_) + 2.0209457602335057) * _loc20_) + -2.403394911734414) * _loc20_) + 1);
                  var _temp_137:* = _loc20_ * _loc10_;
                  var _temp_138:* = (_loc23_ = lf64(wdnative_nternal._pio2_lo)) - _temp_137;
                  var _temp_139:* = _loc10_ - _temp_138;
                  _loc2_ = 1.5707963267948966 - _temp_139;
               }
            }
            else if(_loc38_ <= -1)
            {
               _loc20_ = _loc9_ * 0.5;
               _loc23_ = _loc20_ * 0.00003479331075960212;
               _loc23_ = _loc23_ + 0.0007915349942898145;
               _loc23_ = _loc23_ * _loc20_;
               _loc23_ = _loc23_ + -0.04005553450067941;
               _loc23_ = _loc23_ * _loc20_;
               _loc23_ = _loc23_ + 0.20121253213486293;
               _loc23_ = _loc23_ * _loc20_;
               _loc23_ = _loc23_ + -0.3255658186224009;
               _loc23_ = _loc23_ * _loc20_;
               _loc23_ = _loc23_ + 0.16666666666666666;
               var _temp_159:* = _loc23_ * _loc20_ / ((_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = (_loc14_ = _loc20_ * 0.07703815055590194) + -0.6882839716054533) * _loc20_) + 2.0209457602335057) * _loc20_) + -2.403394911734414) * _loc20_) + 1) * (_loc20_ = Math.sqrt(_loc20_)) - lf64(wdnative_nternal._pio2_lo);
               _loc20_ += _temp_159;
               _loc20_ = _loc20_ * -2;
               _loc2_ = _loc20_ + 3.141592653589793;
            }
            else
            {
               _loc14_ = _loc8_ * 0.5;
               _loc20_ = Math.sqrt(_loc14_);
               sf64(_loc20_,_loc12_ - 16);
               var _loc34_:int = _loc12_ - 24;
               var _temp_167:* = _loc34_ | 4;
               var _loc32_:int;
               si32(_loc32_ = li32(_loc32_ = (_loc32_ = _loc12_ - 16) | 4),_temp_167);
               si32(0,_loc12_ - 24);
               _loc23_ = lf64(_loc12_ - 24);
               var _temp_169:* = _loc20_ + _loc23_;
               var _temp_168:* = _loc23_ * _loc23_;
               var _temp_179:* = (_loc14_ - _temp_168) / _temp_169;
               var _temp_180:* = (_loc20_ = (_loc14_ = (((((_loc14_ * 0.00003479331075960212 + 0.0007915349942898145) * _loc14_ + -0.04005553450067941) * _loc14_ + 0.20121253213486293) * _loc14_ + -0.3255658186224009) * _loc14_ + 0.16666666666666666) * _loc14_ / ((_loc14_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = (_loc4_ = _loc14_ * 0.07703815055590194) + -0.6882839716054533) * _loc14_) + 2.0209457602335057) * _loc14_) + -2.403394911734414) * _loc14_) + 1)) * _loc20_) + _temp_179;
               _loc20_ = _loc23_ + _temp_180;
               _loc2_ = _loc20_ + _loc20_;
            }
            _loc20_ = _loc27_ = _loc2_;
            _loc23_ = _loc37_;
            _loc14_ = 1 - _loc23_;
            _loc18_ = _loc14_ * _loc20_;
            _loc14_ = Math.sin(_loc20_);
            _loc18_ = Math.sin(_loc18_);
            _loc14_ = _loc35_ = _loc14_;
            _loc30_ = _loc18_ /= _loc14_;
            _loc20_ = _loc27_ = _loc20_ *= _loc23_;
            _loc20_ = Math.sin(_loc20_);
            _loc37_ = _loc20_ = _loc20_ / _loc14_;
            _loc22_ = lf32(_loc29_);
            _loc25_ = lf32(_loc43_);
         }
         else
         {
            var _temp_191:* = _loc37_;
            _loc30_ = _loc20_ = (_loc23_ = _loc19_ = 1) - _temp_191;
         }
         _loc23_ = _loc37_;
         _loc20_ = _loc22_;
         _loc14_ = _loc27_ = _loc20_ = _loc20_ * _loc23_;
         _loc20_ = _loc30_;
         _loc18_ = _loc25_;
         _loc18_ = _loc15_ = _loc18_ = _loc18_ * _loc20_;
         _loc14_ = _loc18_ + _loc14_;
         sf32(_loc14_,_loc40_);
         _loc14_ = lf32(_loc29_ + 4);
         _loc14_ = _loc35_ = _loc14_ = _loc14_ * _loc23_;
         _loc18_ = lf32(_loc43_ + 4);
         _loc18_ = _loc15_ = _loc18_ = _loc18_ * _loc20_;
         _loc14_ = _loc18_ + _loc14_;
         sf32(_loc14_,_loc40_ + 4);
         _loc14_ = lf32(_loc29_ + 8);
         _loc14_ = _loc35_ = _loc14_ = _loc14_ * _loc23_;
         _loc18_ = lf32(_loc43_ + 8);
         _loc18_ = _loc15_ = _loc18_ = _loc18_ * _loc20_;
         _loc14_ = _loc18_ + _loc14_;
         sf32(_loc14_,_loc40_ + 8);
         _loc14_ = lf32(_loc29_ + 12);
         _loc23_ = _loc19_ = _loc23_ = _loc14_ * _loc23_;
         _loc14_ = lf32(_loc43_ + 12);
         _loc20_ = _loc27_ = _loc20_ = _loc14_ * _loc20_;
         _loc20_ = _loc20_ + _loc23_;
         sf32(_loc20_,_loc40_ + 12);
      }
      else
      {
         _loc20_ = -_loc5_;
         sf32(_loc20_,_loc40_);
         _loc35_ = lf32(_loc43_);
         sf32(_loc35_,_loc40_ + 4);
         _loc20_ = lf32(_loc43_ + 12);
         _loc23_ = -_loc20_;
         sf32(_loc23_,_loc40_ + 8);
         _loc19_ = lf32(_loc43_ + 8);
         sf32(_loc19_,_loc40_ + 12);
         _loc23_ = _loc37_;
         _loc18_ = 1 - _loc23_;
         _loc18_ = _loc18_ * 0.5;
         var _temp_232:* = _loc18_ * 3.141592653589793;
         var _temp_235:* = Math.sin(_temp_232);
         var _temp_234:* = (_loc23_ *= 0.5) * 3.141592653589793;
         _loc18_ = Math.sin(_temp_234);
         _loc19_ = _temp_235;
         _loc23_ = §§pop();
         _loc21_ = lf32(_loc43_) * _loc23_;
         sf32(_loc21_ - (_loc41_ = _loc4_ = (_loc18_ = _loc15_ = _loc18_) * _loc5_),_loc40_);
         _loc14_ = _loc35_;
         _loc35_ = _loc14_ = _loc14_ * _loc18_;
         var _temp_245:* = _loc35_;
         _loc14_ = (_loc21_ = lf32(_loc43_ + 4) * _loc23_) + _temp_245;
         sf32(_loc14_,_loc40_ + 4);
         _loc27_ = _loc20_ = _loc18_ * _loc20_;
         var _temp_253:* = _loc27_;
         _loc20_ = (_loc23_ = _loc19_ = _loc23_ = (_loc14_ = lf32(_loc43_ + 8)) * _loc23_) - _temp_253;
         sf32(_loc20_,_loc40_ + 8);
      }
      wdnative.ESP = _loc11_ = _loc12_;
   }
}

