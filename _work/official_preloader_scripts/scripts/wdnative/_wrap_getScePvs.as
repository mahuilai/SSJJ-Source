package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.L__2E_str561;
   import wdnative_nternal.__ZZ9getScePvsPvPhiE8__func__;
   
   public function _wrap_getScePvs(param1:int, param2:int, param3:int) : int
   {
      var _loc10_:int = 0;
      var _loc18_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc22_:int = 0;
      var _loc21_:int = 0;
      var _loc14_:int = 0;
      var _loc16_:int = 0;
      var _loc13_:int = 0;
      var _loc4_:int = 0;
      var _loc7_:int = 0;
      var _loc19_:int = 0;
      var _loc8_:int;
      _loc10_ = _loc8_ = wdnative.ESP;
      _loc9_ = param1;
      _loc22_ = param2;
      _loc21_ = param3;
      if(_loc22_ == 0)
      {
         _loc8_ -= 16;
         si32(wdnative_nternal.L__2E_str561,_loc8_ + 12);
         si32(78,_loc8_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc8_ + 4);
         si32(wdnative_nternal.__ZZ9getScePvsPvPhiE8__func__,_loc8_);
         wdnative.ESP = _loc8_;
         wdnative_nternal.F___assert();
         _loc8_ += 16;
      }
      var _loc20_:int = li8(_loc9_ + 36);
      _loc20_ = _loc20_ & 0x80;
      _loc19_ = 0;
      if(_loc20_ != 0)
      {
         _loc18_ = li32(_loc9_ + 212);
         _loc19_ = 0;
         if(_loc18_ != 0)
         {
            if(_loc18_ <= _loc21_)
            {
               _loc20_ = li32(_loc9_ + 204);
               si32(_loc20_,_loc9_ + 88);
               var _temp_5:* = li32(_loc9_ + 84);
               if(_loc20_ >= _temp_5)
               {
                  si32(1,_loc9_ + 44);
                  si32(1,_loc9_ + 48);
               }
               _loc16_ = _loc21_;
               if(_loc18_ <= _loc21_)
               {
                  _loc16_ = _loc18_;
               }
               _loc15_ = _loc9_ + 40;
               _loc4_ = 0;
               while(true)
               {
                  if(_loc4_ < _loc16_)
                  {
                     _loc20_ = li32(_loc15_);
                     var _loc11_:int = li32(_loc20_ + 8);
                     _loc8_ -= 16;
                     si32(_loc15_,_loc8_);
                     wdnative.ESP = _loc8_;
                     wdnative.ptr2fun[_loc11_]();
                     _loc8_ += 16;
                     _loc20_ = wdnative.eax;
                     if(_loc20_ == 0)
                     {
                        _loc12_ = li32(_loc9_ + 88);
                        var _temp_14:* = li32(_loc9_ + 84);
                        if(_loc12_ >= _temp_14)
                        {
                           si32(1,_loc9_ + 44);
                           si32(1,_loc9_ + 48);
                           _loc13_ = 0;
                        }
                        else
                        {
                           _loc20_ = li32(_loc9_ + 76);
                           _loc20_ = _loc20_ + _loc12_;
                           _loc13_ = li8(_loc20_);
                           _loc20_ = _loc12_ + 1;
                           si32(_loc20_,_loc9_ + 88);
                        }
                        _loc20_ = _loc22_ + _loc4_;
                        si8(_loc13_,_loc20_);
                        _loc4_ += 1;
                        continue;
                     }
                     _loc14_ = _loc18_ ^ -1;
                     _loc7_ = _loc21_ ^ -1;
                     if(_loc7_ <= _loc14_)
                     {
                        _loc7_ = _loc14_;
                     }
                     _loc20_ = -2 - _loc7_;
                     _loc19_ = 0;
                     if(_loc20_ != _loc4_)
                     {
                        break;
                     }
                  }
                  _loc19_ = li32(_loc9_ + 212);
                  break;
               }
            }
         }
      }
      var _loc6_:int;
      var _loc5_:int = _loc6_ = _loc19_;
      wdnative.ESP = _loc8_ = _loc10_;
      return _loc5_;
   }
}

