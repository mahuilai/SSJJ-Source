package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str42;
   import wdnative_nternal.L__2E_str547;
   import wdnative_nternal.__ZZN11WeSceParser11WeSceLoader7getMeshEiR9WeSceMeshE8__func__;
   
   public function F__ZN11WeSceParser11WeSceLoader7getMeshEiR9WeSceMesh() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc22_:int = 0;
      var _loc46_:int = 0;
      var _loc40_:int = 0;
      var _loc38_:int = 0;
      var _loc36_:int = 0;
      var _loc34_:int = 0;
      var _loc19_:int = 0;
      var _loc28_:int = 0;
      var _loc30_:int = 0;
      var _loc32_:int = 0;
      var _loc23_:int = 0;
      var _loc25_:int = 0;
      var _loc24_:int = 0;
      var _loc26_:int = 0;
      var _loc20_:int = 0;
      var _loc31_:int = 0;
      var _loc29_:int = 0;
      var _loc35_:int = 0;
      var _loc43_:int = 0;
      var _loc44_:int = 0;
      var _loc21_:int = 0;
      var _loc48_:int = 0;
      var _loc42_:int = 0;
      var _loc16_:Number = NaN;
      var _loc18_:Number = NaN;
      var _loc17_:Number = NaN;
      var _loc14_:Number = NaN;
      var _loc15_:Number = NaN;
      var _loc13_:Number = NaN;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc10_:int = 0;
      var _loc41_:int = 0;
      var _loc33_:int = 0;
      var _loc47_:int = 0;
      var _loc45_:int = 0;
      var _loc39_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc7_ = _loc3_;
      _loc3_ -= 32;
      _loc22_ = li32(_loc7_);
      _loc48_ = li32(_loc22_ + 172);
      _loc46_ = li32(_loc7_ + 4);
      if(_loc48_ <= _loc46_)
      {
         _loc3_ -= 16;
         si32(wdnative_nternal.L__2E_str547,_loc3_ + 12);
         si32(586,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str42,_loc3_ + 4);
         si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader7getMeshEiR9WeSceMeshE8__func__,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___assert();
         _loc3_ += 16;
      }
      _loc44_ = li32(_loc22_ + 96);
      _loc42_ = 4;
      if(_loc44_ <= 105)
      {
         _loc42_ = 3;
      }
      _loc40_ = li32(_loc7_ + 8);
      loop1:
      while(true)
      {
         _loc48_ = _loc44_ + -104;
         if((uint(_loc48_)) <= 1)
         {
            _loc38_ = li32(_loc22_ + 424);
            _loc36_ = li32(_loc22_ + 428);
            var _temp_12:* = int(_loc36_ + _loc38_);
            _loc34_ = li32(_loc22_ + 432);
            _loc19_ = li32(_loc22_ + 436);
            _loc24_ = int(int(int(int(_loc19_ + _loc34_) + (_loc28_ = li32(_loc22_ + 440))) + (_loc30_ = li32(_loc22_ + 444))) + (_loc32_ = li32(_loc22_ + 448))) + (_loc23_ = li32(_loc22_ + 452));
            _loc48_ = int(_temp_12 + _loc24_) + (_loc25_ = li32(_loc22_ + 456));
            _loc48_ = int(_loc48_ * _loc46_) + li32(_loc22_ + 168);
            si32(_loc48_,_loc22_ + 88);
            var _temp_16:* = li32(_loc22_ + 84);
            if(_loc48_ >= _temp_16)
            {
               si32(1,_loc22_ + 44);
               si32(1,_loc22_ + 48);
            }
            _loc26_ = _loc22_ + 40;
            _loc3_ -= 16;
            si32(_loc38_,_loc3_ + 4);
            si32(_loc26_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
            _loc3_ += 16;
            _loc48_ = wdnative.eax;
            si32(_loc48_,_loc40_);
            _loc3_ -= 16;
            si32(_loc36_,_loc3_ + 4);
            si32(_loc26_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
            _loc3_ += 16;
            _loc48_ = wdnative.eax;
            si32(_loc48_,_loc40_ + 4);
            _loc48_ = li8(_loc22_ + 36);
            _loc48_ = _loc48_ & 1;
            if(_loc48_ != 0)
            {
               if(_loc34_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 4);
                  _loc16_ = lf32(_loc7_ - 4);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  _loc48_ = _loc48_ + _loc34_;
                  si32(_loc48_,_loc22_ + 88);
                  _loc16_ = 0;
                  var _temp_27:* = li32(_loc22_ + 84);
                  if(_loc48_ >= _temp_27)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc16_ = 0;
                  }
               }
               sf32(_loc16_,_loc40_ + 8);
               if(_loc19_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 8);
                  _loc18_ = lf32(_loc7_ - 8);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  _loc48_ = _loc48_ + _loc19_;
                  si32(_loc48_,_loc22_ + 88);
                  _loc18_ = 0;
                  var _temp_32:* = li32(_loc22_ + 84);
                  if(_loc48_ >= _temp_32)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc18_ = 0;
                  }
               }
               sf32(_loc18_,_loc40_ + 12);
               if(_loc28_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 12);
                  _loc17_ = lf32(_loc7_ - 12);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  var _loc27_:int = _loc48_ + _loc28_;
                  si32(_loc27_,_loc22_ + 88);
                  _loc17_ = 0;
                  var _temp_37:* = li32(_loc22_ + 84);
                  if(_loc27_ >= _temp_37)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc17_ = 0;
                  }
               }
               sf32(_loc17_,_loc40_ + 16);
               if(_loc30_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 16);
                  _loc14_ = lf32(_loc7_ - 16);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  _loc27_ = _loc48_ + _loc30_;
                  si32(_loc27_,_loc22_ + 88);
                  _loc14_ = 0;
                  var _temp_42:* = li32(_loc22_ + 84);
                  if(_loc27_ >= _temp_42)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc14_ = 0;
                  }
               }
               sf32(_loc14_,_loc40_ + 20);
               if(_loc32_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 20);
                  _loc15_ = lf32(_loc7_ - 20);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  _loc48_ = _loc48_ + _loc32_;
                  si32(_loc48_,_loc22_ + 88);
                  _loc15_ = 0;
                  var _temp_47:* = li32(_loc22_ + 84);
                  if(_loc48_ >= _temp_47)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc15_ = 0;
                  }
               }
               sf32(_loc15_,_loc40_ + 24);
               if(_loc23_ == 4)
               {
                  _loc3_ -= 16;
                  si32(_loc26_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc7_ - 24);
                  _loc13_ = lf32(_loc7_ - 24);
               }
               else
               {
                  _loc48_ = li32(_loc22_ + 88);
                  _loc27_ = _loc48_ + _loc23_;
                  si32(_loc27_,_loc22_ + 88);
                  _loc13_ = 0;
                  var _temp_52:* = li32(_loc22_ + 84);
                  if(_loc27_ >= _temp_52)
                  {
                     si32(1,_loc22_ + 44);
                     si32(1,_loc22_ + 48);
                     _loc13_ = 0;
                  }
               }
               sf32(_loc13_,_loc40_ + 28);
            }
            else
            {
               _loc48_ = li32(_loc22_ + 88);
               _loc48_ = _loc48_ + _loc24_;
               si32(_loc48_,_loc22_ + 88);
               var _temp_55:* = li32(_loc22_ + 84);
               if(_loc48_ >= _temp_55)
               {
                  si32(1,_loc22_ + 44);
                  si32(1,_loc22_ + 48);
               }
            }
            _loc3_ -= 16;
            si32(_loc25_,_loc3_ + 4);
            si32(_loc26_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
            _loc3_ += 16;
            _loc48_ = wdnative.eax;
            si32(_loc48_,_loc40_ + 32);
         }
         else
         {
            var _temp_58:* = int(_loc42_ * 68);
            _loc21_ = _loc22_ + _temp_58;
            _loc20_ = li32(_loc21_ + 220);
            _loc12_ = 16;
            _loc10_ = 0;
            if(_loc20_ != _loc10_)
            {
               _loc12_ = 20;
            }
            _loc48_ = li32(_loc21_ + 224);
            _loc11_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc11_ = 4;
            }
            _loc48_ = li32(_loc21_ + 228);
            _loc8_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc8_ = 4;
            }
            _loc48_ = li32(_loc21_ + 232);
            _loc9_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc9_ = 4;
            }
            _loc48_ = li32(_loc21_ + 236);
            _loc5_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc5_ = 4;
            }
            _loc48_ = li32(_loc21_ + 240);
            _loc6_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc6_ = 4;
            }
            _loc48_ = li32(_loc21_ + 244);
            _loc2_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc2_ = 4;
            }
            _loc48_ = li32(_loc21_ + 248);
            _loc4_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc4_ = 4;
            }
            _loc48_ = li32(_loc21_ + 252);
            _loc1_ = _loc10_;
            if(_loc48_ != _loc10_)
            {
               _loc1_ = 4;
            }
            _loc48_ = li32(_loc21_ + 256);
            if(_loc48_ != _loc10_)
            {
               _loc10_ = 4;
            }
            _loc48_ = _loc11_ + _loc12_;
            _loc27_ = _loc9_ + _loc8_;
            _loc27_ = _loc27_ + _loc5_;
            _loc27_ = _loc27_ + _loc6_;
            _loc27_ = _loc27_ + _loc2_;
            _loc31_ = _loc27_ + _loc4_;
            _loc48_ += _loc31_;
            _loc48_ = _loc48_ + _loc1_;
            _loc48_ = _loc48_ + _loc10_;
            _loc48_ = _loc48_ * _loc46_;
            _loc27_ = li32(_loc22_ + 168);
            _loc48_ += _loc27_;
            si32(_loc48_,_loc22_ + 88);
            _loc27_ = li32(_loc22_ + 84);
            if(_loc48_ >= _loc27_)
            {
               si32(1,_loc22_ + 44);
               si32(1,_loc22_ + 48);
            }
            _loc29_ = _loc22_ + 40;
            if(_loc20_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc29_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc48_ = wdnative.eax;
               si32(_loc48_,_loc40_);
            }
            _loc48_ = li32(_loc21_ + 224);
            if(_loc48_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc29_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc48_ = wdnative.eax;
               si32(_loc48_,_loc40_ + 4);
            }
            _loc48_ = li8(_loc22_ + 36);
            _loc48_ = _loc48_ & 1;
            if(_loc48_ != 0)
            {
               _loc48_ = li32(_loc21_ + 228);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 8);
               }
               _loc48_ = li32(_loc21_ + 232);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 12);
               }
               _loc48_ = li32(_loc21_ + 236);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 16);
               }
               _loc48_ = li32(_loc21_ + 240);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 20);
               }
               _loc48_ = li32(_loc21_ + 244);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 24);
               }
               _loc48_ = li32(_loc21_ + 248);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 28);
               }
            }
            else
            {
               _loc48_ = li32(_loc22_ + 88);
               _loc48_ = _loc48_ + _loc31_;
               si32(_loc48_,_loc22_ + 88);
               var _temp_96:* = li32(_loc22_ + 84);
               if(_loc48_ >= _temp_96)
               {
                  si32(1,_loc22_ + 44);
                  si32(1,_loc22_ + 48);
               }
            }
            _loc48_ = li32(_loc21_ + 252);
            if(_loc48_ != 0)
            {
               _loc3_ -= 16;
               si32(_loc29_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc3_ += 16;
               _loc48_ = wdnative.eax;
               si32(_loc48_,_loc40_ + 32);
            }
            _loc48_ = li8(_loc22_ + 36);
            _loc48_ = _loc48_ & 1;
            if(_loc48_ != 0)
            {
               _loc48_ = li32(_loc21_ + 256);
               if(_loc48_ != 0)
               {
                  _loc3_ -= 16;
                  si32(_loc29_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc3_ += 16;
                  _loc48_ = wdnative.eax;
                  si32(_loc48_,_loc40_ + 36);
               }
               _loc35_ = _loc40_ + 40;
               _loc33_ = 0;
               _loc39_ = 1;
               while(true)
               {
                  if(_loc33_ < 16)
                  {
                     _loc48_ = li32(_loc22_ + 40);
                     var _loc37_:int = li32(_loc48_ + 8);
                     _loc3_ -= 16;
                     si32(_loc29_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative.ptr2fun[_loc37_]();
                     _loc3_ += 16;
                     _loc48_ = wdnative.eax;
                     if(_loc48_ == 0)
                     {
                        _loc43_ = li32(_loc22_ + 88);
                        var _temp_113:* = li32(_loc22_ + 84);
                        if(_loc43_ >= _temp_113)
                        {
                           si32(_loc39_,_loc22_ + 44);
                           si32(_loc39_,_loc22_ + 48);
                           _loc41_ = 0;
                        }
                        else
                        {
                           _loc48_ = li32(_loc22_ + 76);
                           _loc48_ = _loc48_ + _loc43_;
                           _loc41_ = li8(_loc48_);
                           _loc48_ = _loc43_ + 1;
                           si32(_loc48_,_loc22_ + 88);
                        }
                        _loc48_ = _loc35_ + _loc33_;
                        si8(_loc41_,_loc48_);
                        _loc33_ += 1;
                        continue;
                     }
                     _loc47_ = 1;
                     if(_loc33_ != 15)
                     {
                        _loc47_ = 0;
                     }
                     _loc39_ = _loc47_ & 1;
                     if(_loc33_ != 15)
                     {
                        break loop1;
                     }
                  }
                  si8(0,_loc40_ + 56);
                  break loop1;
               }
               break;
            }
         }
         _loc48_ = li32(_loc22_ + 44);
         _loc45_ = 1;
         if(_loc48_ == _loc45_)
         {
            _loc45_ = 0;
         }
         _loc39_ = _loc45_ & 1;
         break;
      }
      wdnative.eax = _loc39_;
      _loc3_ = _loc7_;
      wdnative.ESP = _loc3_;
   }
}

