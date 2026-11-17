package wdnative.animctrl
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Z15QuaternionSlerpPKfPffS1_;
   
   public function blend(param1:int, param2:int, param3:Number, param4:Vector.<Number>) : void
   {
      var _loc22_:* = undefined;
      var _loc7_:int = 0;
      var _loc21_:Number = NaN;
      var _loc13_:Number = NaN;
      var _loc23_:int = 0;
      var _loc27_:int = 0;
      var _loc20_:Number = NaN;
      var _loc10_:Number = NaN;
      var _loc19_:Number = NaN;
      _loc7_ = wdnative.ESP;
      var _loc6_:int = _loc7_ - 16;
      _loc10_ = _loc19_ = 0;
      _loc23_ = param1;
      _loc27_ = param2;
      var _loc9_:Number = _loc21_ = param3;
      if(_loc9_ >= _loc10_)
      {
         _loc10_ = _loc21_;
         _loc9_ = _loc20_ = 1;
         _loc19_ = _loc21_;
         if(!(_loc10_ <= _loc9_ | _loc10_ != _loc10_ | _loc9_ != _loc9_))
         {
            _loc19_ = _loc20_;
         }
      }
      while(true)
      {
         _loc13_ = _loc19_;
         if(_loc13_ >= 0.001)
         {
            if(_loc23_ != _loc27_)
            {
               if(!(_loc13_ <= 0.999 | _loc13_ != _loc13_ | false))
               {
                  var _loc16_:Number = lf32(_loc27_);
                  param4[0] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 4);
                  param4[1] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 8);
                  param4[2] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 12);
                  param4[3] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 16);
                  param4[4] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 20);
                  param4[5] = _loc16_;
                  _loc16_ = lf32(_loc27_ + 24);
                  param4[6] = _loc16_;
                  break;
               }
               _loc10_ = _loc16_ = 1;
               _loc10_ = _loc10_ - _loc13_;
               var _temp_13:* = _loc10_;
               var _temp_8:* = int(_loc27_ + 12);
               var _loc25_:int = _loc23_ + 12;
               _loc6_ -= 16;
               var _loc24_:int = _loc7_ - 16;
               si32(_loc24_,_loc6_ + 12);
               si32(_temp_8,_loc6_ + 4);
               si32(_loc25_,_loc6_);
               sf32(_loc19_,_loc6_ + 8);
               wdnative.ESP = _loc6_;
               wdnative.F__Z15QuaternionSlerpPKfPffS1_();
               _loc6_ += 16;
               _loc9_ = lf32(_loc27_);
               var _loc17_:Number;
               _loc9_ = _loc17_ = _loc9_ = _loc9_ * _loc13_;
               _loc10_ = _temp_13;
               var _loc11_:Number = lf32(_loc23_);
               var _loc12_:Number;
               _loc11_ = _loc12_ = _loc11_ = _loc11_ * _loc10_;
               var _loc14_:Number = _loc9_ = _loc11_ + _loc9_;
               var _temp_30:* = lf32(_loc23_ + 8);
               var _temp_27:* = lf32(_loc27_ + 8);
               var _temp_22:* = lf32(_loc23_ + 4);
               var _temp_19:* = lf32(_loc27_ + 4);
               param4[0] = _loc14_;
               var _loc5_:Number = _loc14_ = _loc5_ = _temp_19 * _loc13_;
               var _loc8_:Number;
               var _loc18_:Number = _loc8_ = _loc18_ = _temp_22 * _loc10_;
               _loc8_ = _loc18_ = _loc18_ + _loc5_;
               param4[1] = _loc8_;
               _loc11_ = _loc12_ = _loc11_ = _temp_27 * _loc13_;
               _loc10_ = _loc16_ = _loc10_ = _temp_30 * _loc10_;
               _loc16_ = _loc10_ = _loc10_ + _loc11_;
               param4[2] = _loc16_;
               _loc16_ = lf32(_loc7_ - 16);
               param4[3] = _loc16_;
               _loc16_ = lf32(_loc7_ - 12);
               param4[4] = _loc16_;
               _loc16_ = lf32(_loc7_ - 8);
               param4[5] = _loc16_;
               _loc16_ = lf32(_loc7_ - 4);
               param4[6] = _loc16_;
               break;
            }
         }
         _loc16_ = lf32(_loc23_);
         param4[0] = _loc16_;
         _loc16_ = lf32(_loc23_ + 4);
         param4[1] = _loc16_;
         _loc16_ = lf32(_loc23_ + 8);
         param4[2] = _loc16_;
         _loc16_ = lf32(_loc23_ + 12);
         param4[3] = _loc16_;
         _loc16_ = lf32(_loc23_ + 16);
         param4[4] = _loc16_;
         _loc16_ = lf32(_loc23_ + 20);
         param4[5] = _loc16_;
         _loc16_ = lf32(_loc23_ + 24);
         param4[6] = _loc16_;
         break;
      }
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc22_;
   }
}

