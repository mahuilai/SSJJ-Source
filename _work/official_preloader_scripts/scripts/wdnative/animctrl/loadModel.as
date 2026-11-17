package wdnative.animctrl
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.sf32;
   import wdnative.ESP;
   
   public function loadModel(param1:int, param2:int, param3:int, param4:int) : int
   {
      var _loc11_:int = 0;
      var _loc32_:int = 0;
      var _loc33_:int = 0;
      var _loc38_:int = 0;
      var _loc30_:int = 0;
      var _loc34_:int = 0;
      var _loc37_:int = 0;
      var _loc39_:int = 0;
      var _loc28_:int = 0;
      var _loc31_:int = 0;
      var _loc35_:int = 0;
      var _loc10_:int;
      _loc11_ = _loc10_ = wdnative.ESP;
      _loc30_ = param1;
      _loc39_ = param2;
      _loc38_ = param3;
      _loc37_ = param4;
      if(_loc38_ >= 1)
      {
         if(_loc37_ >= 1)
         {
            var _loc36_:int = _loc38_ * _loc37_;
            _loc36_ = _loc36_ * 28;
            _loc36_ = _loc36_ + _loc39_;
            _loc35_ = _loc36_ + -28;
            _loc30_ += 12;
            _loc34_ = _loc39_ + 16;
            _loc33_ = _loc37_ * 28;
            _loc32_ = _loc37_ * 24;
            do
            {
               _loc39_ = _loc30_;
               _loc28_ = _loc34_;
               _loc31_ = _loc37_;
               do
               {
                  var _loc25_:Number = lf32(_loc39_ - 12);
                  sf32(_loc25_,_loc28_ - 16);
                  _loc25_ = lf32(_loc39_ - 8);
                  sf32(_loc25_,_loc28_ - 12);
                  _loc25_ = lf32(_loc39_ - 4);
                  sf32(_loc25_,_loc28_ - 8);
                  var _loc16_:Number = _loc25_ = 0.5;
                  var _loc14_:Number = lf32(_loc39_ + 8);
                  _loc14_ = _loc25_ = _loc14_ = _loc14_ * _loc16_;
                  var _loc20_:Number = Math.sin(_loc14_);
                  _loc14_ = Math.cos(_loc14_);
                  var _loc18_:Number = lf32(_loc39_ + 4);
                  var _loc27_:Number;
                  _loc18_ = _loc27_ = _loc18_ = _loc18_ * _loc16_;
                  var _loc24_:Number = Math.sin(_loc18_);
                  _loc18_ = _loc27_ = _loc18_ = Math.cos(_loc18_);
                  var _loc22_:Number = lf32(_loc39_);
                  var _loc26_:Number;
                  var _loc5_:Number = _loc26_ = _loc16_ = _loc22_ * _loc16_;
                  _loc16_ = _loc26_ = _loc16_ = Math.sin(_loc5_);
                  var _loc21_:Number;
                  var _loc7_:Number = _loc21_ = _loc22_ = _loc16_ * _loc18_;
                  _loc14_ = _loc25_ = _loc14_;
                  var _loc8_:Number = _loc21_ = _loc22_ = _loc7_ * _loc14_;
                  var _loc23_:Number;
                  _loc22_ = _loc23_ = _loc24_;
                  _loc24_ = _loc23_ = _loc24_ = Math.cos(_loc5_);
                  var _loc17_:Number;
                  _loc5_ = _loc17_ = _loc5_ = _loc24_ * _loc22_;
                  var _loc19_:Number;
                  _loc20_ = _loc19_ = _loc20_;
                  var _loc13_:Number;
                  var _loc9_:Number = _loc13_ = _loc9_ = _loc5_ * _loc20_;
                  _loc8_ -= _loc9_;
                  sf32(_loc8_,_loc28_ - 4);
                  var _loc15_:Number;
                  _loc7_ = _loc15_ = _loc7_ *= _loc20_;
                  var _loc12_:Number;
                  _loc8_ = _loc12_ = _loc8_ = _loc5_ * _loc14_;
                  _loc7_ = _loc8_ + _loc7_;
                  sf32(_loc7_,_loc28_);
                  _loc16_ = _loc26_ = _loc16_ *= _loc22_;
                  _loc22_ = _loc21_ = _loc22_ = _loc16_ * _loc14_;
                  _loc18_ = _loc27_ = _loc18_ = _loc24_ * _loc18_;
                  _loc24_ = _loc23_ = _loc24_ = _loc18_ * _loc20_;
                  _loc24_ = _loc24_ - _loc22_;
                  sf32(_loc24_,_loc28_ + 4);
                  _loc20_ = _loc19_ = _loc20_ = _loc16_ * _loc20_;
                  _loc14_ = _loc25_ = _loc14_ = _loc18_ * _loc14_;
                  _loc14_ = _loc14_ + _loc20_;
                  sf32(_loc14_,_loc28_ + 8);
                  _loc39_ += 24;
                  _loc28_ += 28;
               }
               while(_loc31_ += -1, _loc31_ != 0);
               _loc30_ += _loc32_;
               _loc34_ += _loc33_;
            }
            while(_loc38_ += -1, _loc38_ != 0);
         }
      }
      var _loc6_:int;
      var _loc29_:int = _loc6_ = _loc36_ = _loc35_ + 28;
      wdnative.ESP = _loc10_ = _loc11_;
      return _loc29_;
   }
}

