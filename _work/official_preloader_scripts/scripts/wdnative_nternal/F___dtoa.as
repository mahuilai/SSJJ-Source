package wdnative_nternal
{
   import avm2.intrinsics.memory.lf64;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.sf64;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   
   public function F___dtoa() : void
   {
      var _temp_1:* = this;
      var _loc12_:int = 0;
      var _loc41_:int = 0;
      var _loc44_:int = 0;
      var _loc45_:int = 0;
      var _loc46_:int = 0;
      var _loc39_:int = 0;
      var _loc47_:int = 0;
      var _loc48_:int = 0;
      var _loc19_:Number = NaN;
      var _loc24_:int = 0;
      var _loc32_:int = 0;
      var _loc33_:int = 0;
      var _loc29_:int = 0;
      var _loc35_:int = 0;
      var _loc26_:int = 0;
      var _loc25_:int = 0;
      var _loc15_:int = 0;
      var _loc20_:Number = NaN;
      var _loc13_:int = 0;
      var _loc11_:int = 0;
      var _loc14_:int = 0;
      var _loc22_:Number = NaN;
      var _loc1_:Number = NaN;
      var _loc36_:int = 0;
      var _loc23_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc43_:int = 0;
      var _loc42_:int = 0;
      var _loc2_:Number = NaN;
      var _loc10_:int = 0;
      var _loc31_:int = 0;
      var _loc30_:int = 0;
      var _loc28_:int = 0;
      var _loc37_:int = 0;
      var _loc17_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc34_:int = 0;
      var _loc38_:int = 0;
      var _loc4_:Number = NaN;
      _loc12_ = wdnative.ESP;
      var _loc8_:int = _loc12_ - 160;
      var _loc27_:int = _loc12_;
      _loc27_ = _loc27_ | 4;
      _loc48_ = li32(_loc27_);
      _loc47_ = li32(_loc12_);
      _loc46_ = li32(_loc12_ + 24);
      _loc45_ = li32(_loc12_ + 20);
      _loc44_ = li32(_loc12_ + 16);
      _loc42_ = li32(_loc12_ + 12);
      _loc41_ = li32(_loc12_ + 8);
      if(_loc48_ <= -1)
      {
         _loc39_ = 1;
         si32(_loc39_,_loc45_);
         _loc48_ &= 2147483647;
      }
      else
      {
         _loc39_ = 0;
         si32(_loc39_,_loc45_);
      }
      _loc27_ = _loc48_ & 0x7FF00000;
      if(_loc27_ == 2146435072)
      {
         si32(9999,_loc44_);
         while(true)
         {
            if(_loc47_ == 0)
            {
               var _temp_6:* = _loc48_ & 0x0FFFFF;
               _loc27_ = 0 | _temp_6;
               if(_loc27_ == 0)
               {
                  _loc8_ -= 16;
                  si32(8,_loc8_ + 8);
                  si32(_loc46_,_loc8_ + 4);
                  si32(wdnative_nternal.L__2E_str948,_loc8_);
                  wdnative.ESP = _loc8_;
                  wdnative_nternal.F___nrv_alloc_D2A();
                  _loc8_ += 16;
                  _loc42_ = wdnative.eax;
                  break;
               }
            }
            _loc8_ -= 16;
            si32(3,_loc8_ + 8);
            si32(_loc46_,_loc8_ + 4);
            si32(wdnative_nternal.L__2E_str1949,_loc8_);
            wdnative.ESP = _loc8_;
            wdnative_nternal.F___nrv_alloc_D2A();
            _loc8_ += 16;
            _loc42_ = wdnative.eax;
            break;
         }
      }
      else
      {
         _loc27_ = _loc12_ - 8;
         var _temp_11:* = _loc27_ | 4;
         si32(_loc48_,_temp_11);
         si32(_loc47_,_loc12_ - 8);
         _loc19_ = lf64(_loc12_ - 8);
         if(!(_loc19_ != 0 | _loc19_ != _loc19_ | false))
         {
            si32(1,_loc44_);
            _loc8_ -= 16;
            si32(1,_loc8_ + 8);
            si32(_loc46_,_loc8_ + 4);
            si32(wdnative_nternal.L__2E_str2950,_loc8_);
            wdnative.ESP = _loc8_;
            wdnative_nternal.F___nrv_alloc_D2A();
            _loc8_ += 16;
            _loc42_ = wdnative.eax;
         }
         else
         {
            _loc45_ = 1;
            _loc39_ = li32(wdnative_nternal._freelist + 4);
            if(_loc39_ != 0)
            {
               _loc27_ = li32(_loc39_);
               si32(_loc27_,wdnative_nternal._freelist + 4);
            }
            else
            {
               _loc39_ = li32(wdnative_nternal._pmem_next);
               _loc27_ = _loc39_ - wdnative_nternal._private_mem;
               _loc27_ = _loc27_ >> 3;
               _loc27_ = _loc27_ + 4;
               if((uint(_loc27_)) <= 288)
               {
                  _loc27_ = _loc39_ + 32;
                  si32(_loc27_,wdnative_nternal._pmem_next);
               }
               else
               {
                  _loc8_ -= 16;
                  si32(32,_loc8_);
                  wdnative.ESP = _loc8_;
                  wdnative.F_malloc();
                  _loc8_ += 16;
                  _loc39_ = wdnative.eax;
               }
               si32(1,_loc39_ + 4);
               si32(2,_loc39_ + 8);
            }
            si32(0,_loc39_ + 16);
            si32(0,_loc39_ + 12);
            _loc24_ = _loc48_ & 0x0FFFFF;
            _loc27_ = _loc48_ >>> 20;
            _loc32_ = _loc27_ & 0x07FF;
            _loc33_ = _loc24_;
            if(_loc32_ != 0)
            {
               _loc33_ = _loc24_ | 0x100000;
            }
            if(_loc47_ != 0)
            {
               while(true)
               {
                  _loc27_ = _loc47_ & 7;
                  if(_loc27_ != 0)
                  {
                     var _temp_24:* = _loc47_ & 1;
                     _loc35_ = _loc47_;
                     if(_temp_24 == 0)
                     {
                        _loc27_ = _loc47_ & 2;
                        if(_loc27_ != 0)
                        {
                           _loc37_ = _loc47_ >>> 1;
                           _loc28_ = 1;
                        }
                        else
                        {
                           _loc37_ = _loc47_ >>> 2;
                           _loc28_ = 2;
                        }
                        addr046e:
                        _loc27_ = 32 - _loc28_;
                        _loc27_ = _loc33_ << _loc27_;
                        _loc27_ = _loc27_ | _loc37_;
                        si32(_loc27_,_loc39_ + 20);
                        _loc33_ >>>= _loc28_;
                        break;
                     }
                  }
                  else
                  {
                     _loc29_ = _loc47_ >>> 16;
                     _loc30_ = _loc47_ & 0xFFFF;
                     if(_loc30_ != 0)
                     {
                        _loc29_ = _loc47_;
                     }
                     _loc35_ = _loc29_ >>> 8;
                     _loc28_ = _loc29_ & 0xFF;
                     if(_loc28_ != 0)
                     {
                        _loc35_ = _loc29_;
                     }
                     _loc31_ = _loc35_ >>> 4;
                     _loc29_ = _loc35_ & 0x0F;
                     if(_loc29_ != 0)
                     {
                        _loc31_ = _loc35_;
                     }
                     _loc35_ = _loc31_ >>> 2;
                     _loc37_ = _loc31_ & 3;
                     if(_loc37_ != 0)
                     {
                        _loc35_ = _loc31_;
                     }
                     _loc31_ = 16;
                     if(_loc30_ != 0)
                     {
                        _loc31_ = 0;
                     }
                     _loc30_ = _loc31_ | 8;
                     if(_loc28_ != 0)
                     {
                        _loc30_ = _loc31_;
                     }
                     _loc28_ = _loc30_ | 4;
                     if(_loc29_ != 0)
                     {
                        _loc28_ = _loc30_;
                     }
                     _loc29_ = _loc28_ | 2;
                     if(_loc37_ != 0)
                     {
                        _loc29_ = _loc28_;
                     }
                     while(true)
                     {
                        _loc27_ = _loc35_ & 1;
                        if(_loc27_ == 0)
                        {
                           _loc35_ >>>= 1;
                           _loc29_ += 1;
                           _loc28_ = 32;
                           _loc37_ = _loc47_;
                           if(_loc35_ == 0)
                           {
                              break;
                           }
                        }
                        _loc28_ = _loc29_;
                        _loc37_ = _loc35_;
                        if(_loc29_ != 0)
                        {
                           break;
                        }
                     }
                     §§goto(addr046e);
                  }
                  si32(_loc35_,_loc39_ + 20);
                  _loc28_ = 0;
                  break;
               }
               si32(_loc33_,_loc39_ + 24);
               _loc35_ = 1;
               if(_loc33_ != 0)
               {
                  _loc35_ = 2;
               }
               si32(_loc35_,_loc39_ + 16);
            }
            else
            {
               _loc27_ = _loc33_ & 7;
               if(_loc27_ != 0)
               {
                  var _temp_34:* = _loc33_ & 1;
                  _loc29_ = 0;
                  if(_temp_34 == 0)
                  {
                     _loc27_ = _loc33_ & 2;
                     if(_loc27_ != 0)
                     {
                        _loc33_ >>>= 1;
                        _loc29_ = 1;
                     }
                     else
                     {
                        _loc33_ >>>= 2;
                        _loc29_ = 2;
                     }
                  }
               }
               else
               {
                  _loc35_ = _loc33_ >>> 16;
                  _loc30_ = _loc33_ & 0xFFFF;
                  if(_loc30_ != 0)
                  {
                     _loc35_ = _loc33_;
                  }
                  _loc28_ = _loc35_ >>> 8;
                  _loc29_ = _loc35_ & 0xFF;
                  if(_loc29_ != 0)
                  {
                     _loc28_ = _loc35_;
                  }
                  _loc31_ = _loc28_ >>> 4;
                  _loc37_ = _loc28_ & 0x0F;
                  if(_loc37_ != 0)
                  {
                     _loc31_ = _loc28_;
                  }
                  _loc28_ = _loc31_ >>> 2;
                  _loc35_ = _loc31_ & 3;
                  if(_loc35_ != 0)
                  {
                     _loc28_ = _loc31_;
                  }
                  _loc31_ = 16;
                  if(_loc30_ != 0)
                  {
                     _loc31_ = 0;
                  }
                  _loc30_ = _loc31_ | 8;
                  if(_loc29_ != 0)
                  {
                     _loc30_ = _loc31_;
                  }
                  _loc29_ = _loc30_ | 4;
                  if(_loc37_ != 0)
                  {
                     _loc29_ = _loc30_;
                  }
                  _loc37_ = _loc29_ | 2;
                  if(_loc35_ != 0)
                  {
                     _loc37_ = _loc29_;
                  }
                  while(true)
                  {
                     _loc27_ = _loc28_ & 1;
                     if(_loc27_ == 0)
                     {
                        _loc28_ >>>= 1;
                        _loc37_ += 1;
                        _loc29_ = 32;
                        if(_loc28_ == 0)
                        {
                           break;
                        }
                     }
                     _loc33_ = _loc28_;
                     _loc29_ = _loc37_;
                     break;
                  }
               }
               si32(_loc33_,_loc39_ + 20);
               _loc35_ = 1;
               si32(_loc35_,_loc39_ + 16);
               _loc28_ = _loc29_ + 32;
            }
            while(true)
            {
               if(_loc32_ != 0)
               {
                  _loc27_ = _loc32_ + _loc28_;
                  _loc26_ = _loc27_ + -1075;
                  _loc25_ = 53 - _loc28_;
               }
               else
               {
                  _loc27_ = _loc35_ << 2;
                  _loc27_ = _loc27_ + _loc39_;
                  _loc30_ = li32(_loc27_ + 16);
                  _loc17_ = _loc30_ << 16;
                  if(uint(_loc30_) >= 65536)
                  {
                     _loc17_ = _loc30_;
                  }
                  _loc37_ = _loc17_ << 8;
                  if(uint(_loc17_) >= 16777216)
                  {
                     _loc37_ = _loc17_;
                  }
                  _loc29_ = _loc37_ << 4;
                  if(uint(_loc37_) >= 268435456)
                  {
                     _loc29_ = _loc37_;
                  }
                  _loc33_ = _loc29_ << 2;
                  if(uint(_loc29_) >= 1073741824)
                  {
                     _loc33_ = _loc29_;
                  }
                  _loc31_ = 16;
                  if(uint(_loc30_) >= 65536)
                  {
                     _loc31_ = 0;
                  }
                  _loc30_ = _loc31_ | 8;
                  if(uint(_loc17_) >= 16777216)
                  {
                     _loc30_ = _loc31_;
                  }
                  _loc31_ = _loc30_ | 4;
                  if(uint(_loc37_) >= 268435456)
                  {
                     _loc31_ = _loc30_;
                  }
                  _loc37_ = _loc31_ | 2;
                  if(uint(_loc29_) >= 1073741824)
                  {
                     _loc37_ = _loc31_;
                  }
                  _loc35_ <<= 5;
                  _loc29_ = _loc32_ + -1074;
                  while(true)
                  {
                     if(_loc33_ >= 0)
                     {
                        _loc37_ += 1;
                        var _temp_45:* = _loc33_ & 0x40000000;
                        _loc33_ = 32;
                        if(_temp_45 == 0)
                        {
                           break;
                        }
                     }
                     _loc33_ = _loc37_;
                     break;
                  }
                  _loc26_ = _loc29_ + _loc28_;
                  _loc25_ = _loc35_ - _loc33_;
                  if(_loc32_ == 0)
                  {
                     _loc24_ = _loc26_ + _loc25_;
                     _loc27_ = _loc24_ + 1074;
                     if(_loc27_ >= 33)
                     {
                        var _temp_48:* = int(_loc24_ + 1042);
                        var _temp_51:* = _loc47_ >>> _temp_48;
                        var _temp_49:* = int(-1010 - _loc24_);
                        var _loc16_:int = _loc48_ << _temp_49;
                        _loc32_ = _loc16_ | _temp_51;
                     }
                     else
                     {
                        var _temp_52:* = int(-1042 - _loc24_);
                        _loc32_ = _loc47_ << _temp_52;
                     }
                     var _loc18_:Number = uint(_loc32_);
                     sf64(_loc18_,_loc12_ - 16);
                     _loc33_ = _loc24_ + -1;
                     _loc27_ = _loc12_ - 16;
                     _loc27_ = _loc27_ | 4;
                     _loc27_ = li32(_loc27_);
                     _loc24_ = _loc27_ + -32505856;
                     _loc15_ = 1;
                     _loc32_ = li32(_loc12_ - 16);
                     break;
                  }
               }
               _loc24_ |= 1072693248;
               _loc33_ = _loc32_ + -1023;
               _loc15_ = 0;
               _loc32_ = _loc47_;
               break;
            }
            _loc27_ = _loc12_ - 24;
            _loc27_ = _loc27_ | 4;
            si32(_loc24_,_loc27_);
            si32(_loc32_,_loc12_ - 24);
            _loc18_ = _loc33_;
            _loc18_ = _loc18_ * 0.301029995663981;
            var _loc21_:Number = lf64(_loc12_ - 24);
            _loc21_ = _loc21_ + -1.5;
            _loc21_ = _loc21_ * 0.289529654602168;
            _loc21_ = _loc21_ + 0.1760912590558;
            _loc32_ = _loc20_ = _loc21_ + _loc18_;
            if(!(_loc20_ >= 0 | _loc20_ != _loc20_ | false))
            {
               _loc18_ = _loc32_;
               if(_loc18_ != _loc20_)
               {
                  _loc32_ += -1;
               }
            }
            _loc13_ = 1;
            if(uint(_loc32_) <= 22)
            {
               var _temp_65:* = _loc32_ << 3;
               _loc27_ = wdnative_nternal.___tens_D2A + _temp_65;
               var _temp_67:* = lf64(_loc27_);
               _loc13_ = 0;
               _loc24_ = 1;
               if(_loc19_ >= _temp_67)
               {
                  _loc24_ = _loc13_;
               }
               _loc27_ = _loc24_ & 1;
               _loc32_ -= _loc27_;
            }
            _loc24_ = _loc25_ - _loc33_;
            _loc30_ = 0;
            if(_loc24_ <= 0)
            {
               _loc30_ = 1 - _loc24_;
            }
            _loc14_ = _loc24_ + -1;
            if(_loc24_ <= 0)
            {
               _loc14_ = 0;
            }
            if(_loc32_ >= 0)
            {
               _loc14_ = _loc32_ + _loc14_;
               _loc10_ = 0;
               _loc11_ = _loc32_;
            }
            else
            {
               _loc30_ -= _loc32_;
               _loc10_ = 0 - _loc32_;
               _loc11_ = 0;
            }
            _loc24_ = _loc29_ = 0;
            if(uint(_loc41_) <= 9)
            {
               _loc24_ = _loc41_;
            }
            _loc41_ = _loc24_ + -4;
            if(_loc24_ <= 5)
            {
               _loc41_ = _loc24_;
            }
            _loc17_ = 1;
            while(true)
            {
               if(_loc41_ <= 2)
               {
                  _loc28_ = _loc31_ = -1;
                  _loc37_ = _loc29_;
                  if(uint(_loc41_) >= 2)
                  {
                     if(_loc41_ == 2)
                     {
                        _loc28_ = 0;
                        addr09a6:
                        if(_loc42_ >= _loc17_)
                        {
                           _loc17_ = _loc42_;
                        }
                        _loc31_ = _loc17_;
                        _loc17_ = _loc28_;
                        _loc28_ = _loc31_;
                        _loc33_ = _loc31_;
                        _loc42_ = _loc31_;
                     }
                     addr09f5:
                     _loc35_ = 4;
                     _loc29_ = 0;
                     _loc37_ = _loc42_;
                     if(uint(_loc33_) >= 20)
                     {
                        do
                        {
                           _loc29_ += 1;
                        }
                        while(_loc35_ <<= 1, _loc27_ = _loc35_ + 16, (uint(_loc27_)) <= uint(_loc33_));
                        _loc37_ = _loc42_;
                        if(_loc29_ >= 10)
                        {
                           _loc33_ = 1 << _loc29_;
                           _loc27_ = _loc33_ << 2;
                           _loc7_ = _loc27_ + 27;
                           _loc37_ = _loc42_;
                           break;
                        }
                     }
                  }
               }
               else
               {
                  loop25:
                  while(true)
                  {
                     while(true)
                     {
                        if(_loc41_ != 3)
                        {
                           _loc28_ = _loc17_;
                           if(_loc41_ != 4)
                           {
                              if(_loc41_ != 5)
                              {
                                 break;
                              }
                           }
                           else
                           {
                              §§goto(addr09a6);
                           }
                        }
                        else
                        {
                           _loc17_ = 0;
                        }
                        _loc31_ = _loc32_ + _loc42_;
                        _loc28_ = _loc31_ + 1;
                        _loc29_ = 0;
                        _loc33_ = _loc28_;
                        _loc37_ = _loc42_;
                        if(_loc31_ >= 0)
                        {
                           break;
                        }
                        break loop25;
                     }
                     §§goto(addr09f5);
                  }
               }
               break loop25;
            }
            _loc8_ -= 16;
            _loc27_ = _loc7_ & -8;
            si32(_loc27_,_loc8_);
            wdnative.ESP = _loc8_;
            wdnative.F_malloc();
            _loc8_ += 16;
            _loc35_ = wdnative.eax;
            si32(_loc29_,_loc35_ + 4);
            si32(_loc33_,_loc35_ + 8);
            si32(0,_loc35_ + 16);
            si32(0,_loc35_ + 12);
            si32(_loc29_,_loc35_);
            _loc29_ = 1;
            _loc33_ = 2;
            _loc42_ = _loc29_;
            if(_loc41_ >= _loc33_)
            {
               _loc42_ = 0;
            }
            _loc7_ = _loc29_;
            if(_loc45_ != _loc29_)
            {
               _loc7_ = 0;
            }
            _loc27_ = _loc42_ | _loc7_;
            if(_loc27_ == 0)
            {
               _loc17_ = 0;
            }
            if(_loc45_ == _loc29_)
            {
               _loc29_ = 0;
            }
            _loc42_ = _loc35_ + 4;
            loop27:
            while(true)
            {
               loop28:
               while(true)
               {
                  loop29:
                  while(true)
                  {
                     loop30:
                     while(true)
                     {
                        if(uint(_loc28_) <= 14)
                        {
                           if(_loc24_ <= 5)
                           {
                              if(_loc29_ == 0)
                              {
                                 if(_loc32_ >= 1)
                                 {
                                    _loc9_ = _loc32_ >> 4;
                                    var _temp_100:* = _loc9_ & 0x10;
                                    _loc33_ = 2;
                                    _loc29_ = _loc47_;
                                    _loc24_ = _loc48_;
                                    if(_temp_100 != 0)
                                    {
                                       _loc18_ = _loc19_ / 1e+256;
                                       sf64(_loc18_,_loc12_ - 56);
                                       _loc9_ &= 15;
                                       _loc27_ = _loc12_ - 56;
                                       _loc27_ = _loc27_ | 4;
                                       _loc24_ = li32(_loc27_);
                                       _loc33_ = 3;
                                       _loc29_ = li32(_loc12_ - 56);
                                    }
                                    _loc27_ = _loc32_ & 0x0F;
                                    _loc27_ = _loc27_ << 3;
                                    _loc27_ = wdnative_nternal.___tens_D2A + _loc27_;
                                    _loc23_ = lf64(_loc27_);
                                    _loc7_ = wdnative_nternal.___bigtens_D2A;
                                    if(_loc9_ != 0)
                                    {
                                       do
                                       {
                                          _loc27_ = _loc9_ & 1;
                                          if(_loc27_ != 0)
                                          {
                                             _loc18_ = lf64(_loc7_);
                                             _loc23_ = _loc18_ * _loc23_;
                                             _loc33_ += 1;
                                          }
                                          _loc7_ += 8;
                                       }
                                       while(_loc9_ >>= 1, _loc9_ != 0);
                                    }
                                    _loc27_ = _loc12_ - 64;
                                    _loc27_ = _loc27_ | 4;
                                    si32(_loc24_,_loc27_);
                                    si32(_loc29_,_loc12_ - 64);
                                    _loc18_ = lf64(_loc12_ - 64);
                                    _loc18_ = _loc18_ / _loc23_;
                                    sf64(_loc18_,_loc12_ - 72);
                                    _loc27_ = _loc12_ - 72;
                                    _loc27_ = _loc27_ | 4;
                                    _loc9_ = li32(_loc27_);
                                    _loc6_ = li32(_loc12_ - 72);
                                 }
                                 else
                                 {
                                    _loc6_ = _loc47_;
                                    _loc9_ = _loc48_;
                                    if(_loc32_ != 0)
                                    {
                                       _loc27_ = 0 - _loc32_;
                                       _loc16_ = _loc27_ & 0x0F;
                                       var _temp_116:* = _loc16_ << 3;
                                       _loc16_ = wdnative_nternal.___tens_D2A + _temp_116;
                                       var _temp_118:* = lf64(_loc16_);
                                       _loc21_ = _loc19_ * _temp_118;
                                       sf64(_loc21_,_loc12_ - 32);
                                       _loc24_ = _loc27_ >> 4;
                                       _loc27_ = _loc12_ - 32;
                                       _loc27_ = _loc27_ | 4;
                                       _loc9_ = li32(_loc27_);
                                       _loc29_ = wdnative_nternal.___bigtens_D2A;
                                       _loc33_ = 2;
                                       _loc6_ = li32(_loc12_ - 32);
                                       if(_loc24_ != 0)
                                       {
                                          do
                                          {
                                             _loc27_ = _loc24_ & 1;
                                             if(_loc27_ != 0)
                                             {
                                                _loc27_ = _loc12_ - 40;
                                                var _temp_124:* = _loc27_ | 4;
                                                si32(_loc9_,_temp_124);
                                                si32(_loc6_,_loc12_ - 40);
                                                var _temp_126:* = lf64(_loc29_);
                                                _loc18_ = (_loc18_ = lf64(_loc12_ - 40)) * _temp_126;
                                                sf64(_loc18_,_loc12_ - 48);
                                                _loc33_ += 1;
                                                _loc27_ = _loc12_ - 48;
                                                _loc27_ = _loc27_ | 4;
                                                _loc9_ = li32(_loc27_);
                                                _loc6_ = li32(_loc12_ - 48);
                                             }
                                             _loc29_ += 8;
                                          }
                                          while(_loc24_ >>= 1, _loc24_ != 0);
                                       }
                                    }
                                 }
                                 _loc7_ = _loc32_;
                                 _loc24_ = _loc28_;
                                 loop31:
                                 while(true)
                                 {
                                    if(_loc13_ != 0)
                                    {
                                       _loc27_ = _loc12_ - 80;
                                       var _temp_132:* = _loc27_ | 4;
                                       si32(_loc9_,_temp_132);
                                       si32(_loc6_,_loc12_ - 80);
                                       _loc22_ = lf64(_loc12_ - 80);
                                       _loc7_ = _loc32_;
                                       _loc24_ = _loc28_;
                                       if(!(_loc22_ >= 1 | _loc22_ != _loc22_ | false))
                                       {
                                          _loc7_ = _loc32_;
                                          _loc24_ = _loc28_;
                                          if(_loc28_ >= 1)
                                          {
                                             if(_loc31_ < 1)
                                             {
                                                break;
                                             }
                                             _loc18_ = _loc22_ * 10;
                                             sf64(_loc18_,_loc12_ - 88);
                                             _loc33_ += 1;
                                             _loc7_ = _loc32_ + -1;
                                             _loc27_ = _loc12_ - 88;
                                             _loc27_ = _loc27_ | 4;
                                             _loc9_ = li32(_loc27_);
                                             _loc6_ = li32(_loc12_ - 88);
                                             _loc24_ = _loc31_;
                                          }
                                       }
                                    }
                                    _loc27_ = _loc12_ - 96;
                                    _loc27_ = _loc27_ | 4;
                                    si32(_loc9_,_loc27_);
                                    si32(_loc6_,_loc12_ - 96);
                                    _loc18_ = _loc33_;
                                    _loc1_ = lf64(_loc12_ - 96);
                                    _loc18_ *= _loc1_;
                                    _loc18_ = _loc18_ + 7;
                                    sf64(_loc18_,_loc12_ - 104);
                                    _loc27_ = _loc12_ - 104;
                                    _loc27_ = _loc27_ | 4;
                                    _loc27_ = li32(_loc27_);
                                    _loc36_ = _loc27_ + -54525952;
                                    _loc29_ = li32(_loc12_ - 104);
                                    if(_loc24_ == 0)
                                    {
                                       _loc27_ = _loc12_ - 144;
                                       var _temp_143:* = _loc27_ | 4;
                                       si32(_loc36_,_temp_143);
                                       si32(_loc29_,_loc12_ - 144);
                                       _loc22_ = _loc1_ + -5;
                                       _loc24_ = 0;
                                       _loc1_ = lf64(_loc12_ - 144);
                                       _loc6_ = _loc24_;
                                       if(_loc22_ <= _loc1_)
                                       {
                                          var _temp_144:* = -_loc1_;
                                          _loc33_ = _loc24_ = 0;
                                          if(_loc22_ >= _temp_144)
                                          {
                                             break;
                                          }
                                          break loop29;
                                       }
                                       break loop30;
                                    }
                                    if(_loc17_ != 0)
                                    {
                                       _loc27_ = _loc12_ - 112;
                                       var _temp_146:* = _loc27_ | 4;
                                       si32(_loc36_,_temp_146);
                                       si32(_loc29_,_loc12_ - 112);
                                       _loc27_ = _loc24_ << 3;
                                       _loc27_ = _loc27_ + wdnative_nternal.___tens_D2A;
                                       var _temp_149:* = lf64(_loc27_ - 8);
                                       _loc2_ = 0.5 / _temp_149 - lf64(_loc12_ - 112);
                                       _loc29_ = _loc35_ + 5;
                                       _loc34_ = 1;
                                       while(true)
                                       {
                                          _loc27_ = _loc12_ - 120;
                                          _loc27_ = _loc27_ | 4;
                                          si32(_loc9_,_loc27_);
                                          si32(_loc6_,_loc12_ - 120);
                                          _loc16_ = _loc18_ = lf64(_loc12_ - 120);
                                          var _loc40_:int = _loc16_ + 48;
                                          si8(_loc40_,_loc29_ - 1);
                                          _loc21_ = _loc16_;
                                          _loc23_ = _loc18_ - _loc21_;
                                          if(_loc23_ < _loc2_)
                                          {
                                             break loop27;
                                          }
                                          var _temp_158:* = 1 - _loc23_;
                                          _loc33_ = _loc7_;
                                          if(_temp_158 < _loc2_)
                                          {
                                             break loop28;
                                          }
                                          if(_loc34_ >= _loc24_)
                                          {
                                             break loop31;
                                          }
                                          _loc18_ = _loc23_ * 10;
                                          sf64(_loc18_,_loc12_ - 128);
                                          _loc34_ += 1;
                                          _loc29_ += 1;
                                          _loc2_ *= 10;
                                          _loc27_ = _loc12_ - 128;
                                          _loc27_ = _loc27_ | 4;
                                          _loc9_ = li32(_loc27_);
                                          _loc6_ = li32(_loc12_ - 128);
                                       }
                                       break loop28;
                                    }
                                    _loc27_ = _loc12_ - 136;
                                    var _temp_160:* = _loc27_ | 4;
                                    si32(_loc36_,_temp_160);
                                    _loc27_ = _loc1_;
                                    _loc16_ = _loc27_ + 48;
                                    si8(_loc16_,_loc42_);
                                    si32(_loc29_,_loc12_ - 136);
                                    var _temp_163:* = _loc27_;
                                    _loc23_ = _loc1_ - _temp_163;
                                    _loc33_ = 1;
                                    if(_loc23_ != 0)
                                    {
                                       _loc33_ = _loc24_;
                                    }
                                    _loc2_ = lf64(_loc12_ - 136);
                                    _loc29_ = _loc42_ + 1;
                                    if(_loc33_ != 1)
                                    {
                                       _loc29_ = _loc35_ + 5;
                                       _loc9_ = 1;
                                       _loc38_ = 2;
                                       do
                                       {
                                          _loc40_ = _loc18_ = _loc23_ * 10;
                                          _loc16_ = _loc40_ + 48;
                                          si8(_loc16_,_loc29_);
                                          _loc21_ = _loc40_;
                                          _loc23_ = _loc18_ - _loc21_;
                                          _loc34_ = _loc38_;
                                          if(_loc23_ != 0)
                                          {
                                             _loc34_ = _loc33_;
                                          }
                                          _loc38_ += 1;
                                          _loc9_ += 1;
                                          _loc29_ += 1;
                                          _loc33_ = _loc34_;
                                       }
                                       while(_loc9_ != _loc34_);
                                    }
                                    _loc27_ = _loc24_ << 3;
                                    _loc27_ = _loc27_ + wdnative_nternal.___tens_D2A;
                                    _loc18_ = lf64(_loc27_ - 8);
                                    _loc20_ = _loc2_ * _loc18_;
                                    _loc18_ = _loc20_ + 0.5;
                                    _loc33_ = _loc7_;
                                    if(_loc23_ <= _loc18_)
                                    {
                                       _loc18_ = 0.5 - _loc20_;
                                       if(!(_loc23_ >= _loc18_ | _loc23_ != _loc23_ | _loc18_ != _loc18_))
                                       {
                                          _loc45_ = _loc29_ + 1;
                                          do
                                          {
                                             _loc29_ = _loc45_ + -1;
                                             _loc27_ = li8(_loc45_ - 2);
                                             _loc45_ = _loc29_;
                                          }
                                          while(_loc27_ == 48);
                                          break loop27;
                                       }
                                       break;
                                    }
                                    break loop28;
                                 }
                              }
                           }
                        }
                        if(_loc26_ >= 0)
                        {
                           if(_loc32_ <= 14)
                           {
                              var _temp_170:* = _loc32_ << 3;
                              _loc27_ = wdnative_nternal.___tens_D2A + _temp_170;
                              _loc3_ = lf64(_loc27_);
                              if(_loc37_ <= -1)
                              {
                                 if(_loc28_ < 1)
                                 {
                                    _loc33_ = _loc24_ = 0;
                                    if(_loc28_ >= 0)
                                    {
                                       _loc18_ = _loc3_ * 5;
                                       _loc33_ = _loc24_ = 0;
                                       _loc7_ = _loc32_;
                                       _loc6_ = _loc24_;
                                       if(!(_loc19_ > _loc18_ | _loc19_ != _loc19_ | _loc18_ != _loc18_))
                                       {
                                          break loop29;
                                       }
                                       break;
                                    }
                                    break loop29;
                                 }
                              }
                              _loc24_ = _loc28_ + -1;
                              _loc29_ = _loc35_ + 5;
                              while(true)
                              {
                                 _loc27_ = _loc12_ - 152;
                                 _loc27_ = _loc27_ | 4;
                                 si32(_loc48_,_loc27_);
                                 si32(_loc47_,_loc12_ - 152);
                                 _loc18_ = lf64(_loc12_ - 152);
                                 _loc21_ = _loc47_ = _loc21_ = _loc18_ / _loc3_;
                                 _loc21_ = _loc21_ * _loc3_;
                                 _loc4_ = _loc18_ - _loc21_;
                                 if(!(_loc4_ >= 0 | _loc4_ != _loc4_ | false))
                                 {
                                    _loc4_ += _loc3_;
                                    _loc47_ += 255;
                                 }
                                 _loc27_ = _loc47_ + 48;
                                 si8(_loc27_,_loc29_ - 1);
                                 _loc7_ = _loc32_;
                                 if(_loc4_ == 0)
                                 {
                                    break loop27;
                                 }
                                 if(_loc24_ == 0)
                                 {
                                    if(_loc41_ >= 2)
                                    {
                                       _loc7_ = _loc32_;
                                       if(_loc45_ == 0)
                                       {
                                          break loop27;
                                       }
                                       _loc33_ = _loc32_;
                                       if(_loc45_ == 2)
                                       {
                                          break loop28;
                                       }
                                    }
                                    _loc5_ = _loc4_ + _loc4_;
                                    _loc33_ = _loc32_;
                                    if(_loc5_ <= _loc3_)
                                    {
                                       _loc7_ = _loc32_;
                                       if(!(_loc5_ != _loc3_ | _loc5_ != _loc5_ | _loc3_ != _loc3_))
                                       {
                                          var _temp_182:* = _loc47_ & 1;
                                          _loc33_ = _loc32_;
                                          _loc7_ = _loc32_;
                                          if(_temp_182 != 0)
                                          {
                                             break loop28;
                                          }
                                       }
                                       break loop27;
                                    }
                                    break loop28;
                                 }
                                 _loc18_ = _loc4_ * 10;
                                 sf64(_loc18_,_loc12_ - 160);
                                 _loc24_ += -1;
                                 _loc29_ += 1;
                                 _loc27_ = _loc12_ - 160;
                                 _loc27_ = _loc27_ | 4;
                                 _loc48_ = li32(_loc27_);
                                 _loc47_ = li32(_loc12_ - 160);
                              }
                              break loop27;
                           }
                        }
                        _loc24_ = 0;
                        _loc29_ = _loc30_;
                        if(_loc17_ != 0)
                        {
                           _loc24_ = 54 - _loc25_;
                           if(_loc15_ != 0)
                           {
                              _loc24_ = _loc26_ + 1075;
                           }
                           _loc14_ += _loc24_;
                           _loc29_ = _loc30_ + _loc24_;
                           _loc24_ = li32(wdnative_nternal._freelist + 4);
                           if(_loc24_ != 0)
                           {
                              _loc27_ = li32(_loc24_);
                              si32(_loc27_,wdnative_nternal._freelist + 4);
                           }
                           else
                           {
                              _loc24_ = li32(wdnative_nternal._pmem_next);
                              _loc27_ = _loc24_ - wdnative_nternal._private_mem;
                              _loc27_ = _loc27_ >> 3;
                              _loc27_ = _loc27_ + 4;
                              if((uint(_loc27_)) <= 288)
                              {
                                 _loc27_ = _loc24_ + 32;
                                 si32(_loc27_,wdnative_nternal._pmem_next);
                              }
                              else
                              {
                                 _loc8_ -= 16;
                                 si32(32,_loc8_);
                                 wdnative.ESP = _loc8_;
                                 wdnative.F_malloc();
                                 _loc8_ += 16;
                                 _loc24_ = wdnative.eax;
                              }
                              si32(1,_loc24_ + 4);
                              si32(2,_loc24_ + 8);
                           }
                           si32(0,_loc24_ + 12);
                           si32(1,_loc24_ + 20);
                           si32(1,_loc24_ + 16);
                        }
                        if(_loc30_ >= 1)
                        {
                           if(_loc14_ >= 1)
                           {
                              _loc43_ = _loc14_;
                              if(_loc14_ > _loc30_)
                              {
                                 _loc43_ = _loc30_;
                              }
                              _loc14_ -= _loc43_;
                              _loc30_ -= _loc43_;
                              _loc29_ -= _loc43_;
                           }
                        }
                        _loc26_ = _loc39_;
                        if(_loc10_ >= 1)
                        {
                           if(_loc17_ != 0)
                           {
                              _loc8_ -= 16;
                              si32(_loc10_,_loc8_ + 4);
                              si32(_loc24_,_loc8_);
                              wdnative.ESP = _loc8_;
                              wdnative_nternal.F___pow5mult_D2A();
                              _loc8_ += 16;
                              _loc24_ = wdnative.eax;
                              _loc8_ -= 16;
                              si32(_loc39_,_loc8_ + 4);
                              si32(_loc24_,_loc8_);
                              wdnative.ESP = _loc8_;
                              wdnative_nternal.F___mult_D2A();
                              _loc8_ += 16;
                              _loc26_ = wdnative.eax;
                              if(_loc39_ != 0)
                              {
                                 _loc43_ = li32(_loc39_ + 4);
                                 if(_loc43_ >= 10)
                                 {
                                    _loc8_ -= 16;
                                    si32(_loc39_,_loc8_);
                                    wdnative.ESP = _loc8_;
                                    wdnative_nternal.F_idalloc();
                                    _loc8_ += 16;
                                 }
                                 else
                                 {
                                    var _temp_195:* = _loc43_ << 2;
                                    _loc27_ = wdnative_nternal._freelist + _temp_195;
                                    _loc16_ = li32(_loc27_);
                                    si32(_loc16_,_loc39_);
                                    si32(_loc39_,_loc27_);
                                 }
                              }
                           }
                           else
                           {
                              _loc8_ -= 16;
                              si32(_loc10_,_loc8_ + 4);
                              si32(_loc39_,_loc8_);
                              wdnative.ESP = _loc8_;
                              wdnative_nternal.F___pow5mult_D2A();
                              _loc8_ += 16;
                              _loc26_ = wdnative.eax;
                           }
                        }
                        _loc33_ = li32(wdnative_nternal._freelist + 4);
                        if(_loc33_ != 0)
                        {
                           _loc27_ = li32(_loc33_);
                           si32(_loc27_,wdnative_nternal._freelist + 4);
                        }
                        else
                        {
                           _loc33_ = li32(wdnative_nternal._pmem_next);
                           _loc27_ = _loc33_ - wdnative_nternal._private_mem;
                           _loc27_ = _loc27_ >> 3;
                           _loc27_ = _loc27_ + 4;
                           if((uint(_loc27_)) <= 288)
                           {
                              _loc27_ = _loc33_ + 32;
                              si32(_loc27_,wdnative_nternal._pmem_next);
                           }
                           else
                           {
                              _loc8_ -= 16;
                              si32(32,_loc8_);
                              wdnative.ESP = _loc8_;
                              wdnative.F_malloc();
                              _loc8_ += 16;
                              _loc33_ = wdnative.eax;
                           }
                           si32(1,_loc33_ + 4);
                           si32(2,_loc33_ + 8);
                        }
                        _loc43_ = 0;
                        si32(_loc43_,_loc33_ + 12);
                        _loc39_ = 1;
                        si32(_loc39_,_loc33_ + 20);
                        si32(_loc39_,_loc33_ + 16);
                        if(_loc11_ >= 1)
                        {
                           _loc8_ -= 16;
                           si32(_loc11_,_loc8_ + 4);
                           si32(_loc33_,_loc8_);
                           wdnative.ESP = _loc8_;
                           wdnative_nternal.F___pow5mult_D2A();
                           _loc8_ += 16;
                           _loc33_ = wdnative.eax;
                        }
                        _loc25_ = _loc39_;
                        if(_loc41_ >= 2)
                        {
                           _loc25_ = _loc43_;
                        }
                        if(_loc17_ == _loc43_)
                        {
                           _loc39_ = _loc43_;
                        }
                        if(_loc45_ == 1)
                        {
                           _loc27_ = _loc25_ | _loc39_;
                           _loc27_ = _loc27_ & 1;
                           if(_loc27_ != 0)
                           {
                              var _temp_210:* = _loc48_ & 0x0FFFFF;
                              _loc43_ = 0;
                              if(_temp_210 == 0)
                              {
                                 if(_loc47_ == 0)
                                 {
                                    var _temp_211:* = _loc48_ & 0x7FE00000;
                                    _loc27_ = _loc43_ | _temp_211;
                                    if(_loc27_ != 0)
                                    {
                                       _loc14_ += 1;
                                       _loc29_ += 1;
                                       _loc43_ = 1;
                                    }
                                 }
                              }
                           }
                        }
                        _loc39_ = 1;
                        if(_loc11_ != 0)
                        {
                           _loc27_ = li32(_loc33_ + 16);
                           _loc27_ = _loc27_ << 2;
                           _loc27_ = _loc27_ + _loc33_;
                           _loc10_ = li32(_loc27_ + 16);
                           _loc11_ = _loc10_ << 16;
                           if(uint(_loc10_) >= 65536)
                           {
                              _loc11_ = _loc10_;
                           }
                           _loc25_ = _loc11_ << 8;
                           if(uint(_loc11_) >= 16777216)
                           {
                              _loc25_ = _loc11_;
                           }
                           _loc48_ = _loc25_ << 4;
                           if(uint(_loc25_) >= 268435456)
                           {
                              _loc48_ = _loc25_;
                           }
                           _loc39_ = _loc48_ << 2;
                           if(uint(_loc48_) >= 1073741824)
                           {
                              _loc39_ = _loc48_;
                           }
                           _loc15_ = 16;
                           if(uint(_loc10_) >= 65536)
                           {
                              _loc15_ = 0;
                           }
                           _loc10_ = _loc15_ | 8;
                           if(uint(_loc11_) >= 16777216)
                           {
                              _loc10_ = _loc15_;
                           }
                           _loc11_ = _loc10_ | 4;
                           if(uint(_loc25_) >= 268435456)
                           {
                              _loc11_ = _loc10_;
                           }
                           _loc25_ = _loc11_ | 2;
                           if(uint(_loc48_) >= 1073741824)
                           {
                              _loc25_ = _loc11_;
                           }
                           while(true)
                           {
                              if(_loc39_ >= 0)
                              {
                                 _loc25_ += 1;
                                 var _temp_217:* = _loc39_ & 0x40000000;
                                 _loc39_ = 32;
                                 if(_temp_217 == 0)
                                 {
                                    break;
                                 }
                              }
                              _loc39_ = _loc25_;
                              break;
                           }
                           _loc39_ = 32 - _loc39_;
                        }
                        _loc27_ = _loc39_ + _loc14_;
                        _loc39_ = _loc27_ & 0x1F;
                        if(_loc39_ != 0)
                        {
                           _loc39_ = 32 - _loc39_;
                        }
                        if(uint(_loc39_) >= 5)
                        {
                           _loc27_ = _loc39_ + -4;
                           _loc14_ = _loc27_ + _loc14_;
                           _loc30_ = _loc27_ + _loc30_;
                           _loc29_ = _loc27_ + _loc29_;
                        }
                        else if(uint(_loc39_) <= 3)
                        {
                           _loc27_ = _loc39_ + 28;
                           _loc14_ = _loc27_ + _loc14_;
                           _loc30_ = _loc27_ + _loc30_;
                           _loc29_ = _loc27_ + _loc29_;
                        }
                        if(_loc29_ >= 1)
                        {
                           _loc8_ -= 16;
                           si32(_loc29_,_loc8_ + 4);
                           si32(_loc26_,_loc8_);
                           wdnative.ESP = _loc8_;
                           wdnative_nternal.F___lshift_D2A();
                           _loc8_ += 16;
                           _loc26_ = wdnative.eax;
                        }
                        _loc39_ = _loc26_;
                        if(_loc14_ >= 1)
                        {
                           _loc8_ -= 16;
                           si32(_loc14_,_loc8_ + 4);
                           si32(_loc33_,_loc8_);
                           wdnative.ESP = _loc8_;
                           wdnative_nternal.F___lshift_D2A();
                           _loc8_ += 16;
                           _loc33_ = wdnative.eax;
                        }
                        if(_loc13_ != 0)
                        {
                           _loc29_ = li32(_loc33_ + 16);
                           _loc48_ = li32(_loc39_ + 16);
                           if(_loc48_ == _loc29_)
                           {
                              _loc27_ = _loc29_ << 2;
                              _loc16_ = _loc27_ + _loc39_;
                              _loc14_ = _loc16_ + 20;
                              _loc27_ += _loc33_;
                              _loc26_ = _loc27_ + 16;
                              _loc13_ = _loc39_ + 20;
                              do
                              {
                                 _loc29_ = li32(_loc26_);
                                 _loc48_ = li32(_loc14_ - 4);
                                 if(_loc48_ == _loc29_)
                                 {
                                    continue;
                                 }
                                 _loc13_ = -1;
                                 if(uint(_loc48_) >= uint(_loc29_))
                                 {
                                    _loc13_ = 1;
                                 }
                              }
                              while(_loc14_ += -4, _loc26_ += -4, uint(_loc14_) > uint(_loc13_));
                              addr1a0f:
                              loop33:
                              while(true)
                              {
                                 if(_loc28_ <= 0)
                                 {
                                    if(_loc41_ != 3)
                                    {
                                       if(_loc41_ != 5)
                                       {
                                          addr1b3d:
                                          if(_loc17_ == 0)
                                          {
                                             _loc29_ = _loc35_ + 5;
                                             _loc41_ = 1;
                                             while(true)
                                             {
                                                _loc8_ -= 16;
                                                si32(_loc33_,_loc8_ + 4);
                                                si32(_loc39_,_loc8_);
                                                wdnative.ESP = _loc8_;
                                                wdnative_nternal.F___quorem_D2A();
                                                _loc8_ += 16;
                                                _loc27_ = wdnative.eax;
                                                _loc35_ = _loc27_ + 48;
                                                si8(_loc35_,_loc29_ - 1);
                                                _loc27_ = li32(_loc39_ + 20);
                                                if(_loc27_ == 0)
                                                {
                                                   var _temp_234:* = li32(_loc39_ + 16);
                                                   _loc47_ = 0;
                                                   if(_temp_234 < 2)
                                                   {
                                                      break loop33;
                                                   }
                                                }
                                                _loc47_ = 0;
                                                if(_loc41_ >= _loc28_)
                                                {
                                                   addr23e3:
                                                   if(_loc45_ != 0)
                                                   {
                                                      if(_loc45_ != 2)
                                                      {
                                                         _loc8_ -= 16;
                                                         si32(1,_loc8_ + 4);
                                                         si32(_loc39_,_loc8_);
                                                         wdnative.ESP = _loc8_;
                                                         wdnative_nternal.F___lshift_D2A();
                                                         _loc8_ += 16;
                                                         _loc39_ = wdnative.eax;
                                                         _loc45_ = li32(_loc33_ + 16);
                                                         _loc41_ = li32(_loc39_ + 16);
                                                         if(_loc41_ == _loc45_)
                                                         {
                                                            _loc16_ = _loc45_ << 2;
                                                            _loc27_ = _loc16_ + _loc39_;
                                                            _loc43_ = _loc27_ + 20;
                                                            _loc27_ = _loc16_ + _loc33_;
                                                            _loc28_ = _loc27_ + 16;
                                                            _loc48_ = _loc39_ + 20;
                                                            while(true)
                                                            {
                                                               _loc45_ = li32(_loc28_);
                                                               loop34:
                                                               while(true)
                                                               {
                                                                  while(true)
                                                                  {
                                                                     _loc41_ = li32(_loc43_ - 4);
                                                                     if(_loc41_ != _loc45_)
                                                                     {
                                                                        _loc48_ = -1;
                                                                        if(uint(_loc41_) >= uint(_loc45_))
                                                                        {
                                                                           _loc48_ = 1;
                                                                        }
                                                                        addr24c6:
                                                                        if(_loc48_ > 0)
                                                                        {
                                                                           break;
                                                                        }
                                                                        if(_loc48_ != 0)
                                                                        {
                                                                           break loop34;
                                                                        }
                                                                     }
                                                                     else
                                                                     {
                                                                        _loc43_ += -4;
                                                                        _loc28_ += -4;
                                                                        if(uint(_loc43_) > uint(_loc48_))
                                                                        {
                                                                           continue;
                                                                        }
                                                                     }
                                                                     _loc27_ = _loc35_ & 1;
                                                                     if(_loc27_ != 0)
                                                                     {
                                                                        break;
                                                                     }
                                                                     break loop34;
                                                                  }
                                                                  addr24e7:
                                                                  while(true)
                                                                  {
                                                                     _loc45_ = _loc29_;
                                                                     _loc41_ = li8(_loc45_ - 1);
                                                                     if(_loc41_ != 57)
                                                                     {
                                                                        _loc27_ = _loc41_ + 1;
                                                                        si8(_loc27_,_loc45_ - 1);
                                                                        _loc29_ = _loc45_;
                                                                        break loop33;
                                                                     }
                                                                     _loc29_ = _loc45_ + -1;
                                                                     if(_loc42_ == _loc29_)
                                                                     {
                                                                        si8(49,_loc29_);
                                                                        _loc32_ += 1;
                                                                        _loc29_ = _loc45_;
                                                                        break loop33;
                                                                     }
                                                                  }
                                                                  break loop33;
                                                               }
                                                               _loc45_ = _loc29_ + 1;
                                                               while(true)
                                                               {
                                                                  _loc29_ = _loc45_ + -1;
                                                                  _loc27_ = li8(_loc45_ - 2);
                                                                  _loc45_ = _loc29_;
                                                                  if(_loc27_ != 48)
                                                                  {
                                                                     break loop33;
                                                                  }
                                                               }
                                                               break loop33;
                                                            }
                                                            break loop33;
                                                         }
                                                         _loc48_ = _loc41_ - _loc45_;
                                                         §§goto(addr24c6);
                                                      }
                                                      §§goto(addr24e7);
                                                   }
                                                   break loop34;
                                                }
                                                _loc8_ -= 16;
                                                si32(10,_loc8_ + 4);
                                                si32(_loc39_,_loc8_);
                                                wdnative.ESP = _loc8_;
                                                wdnative_nternal.F___multadd_D2A();
                                                _loc41_ += 1;
                                                _loc29_ += 1;
                                                _loc8_ += 16;
                                                _loc39_ = wdnative.eax;
                                             }
                                             break;
                                          }
                                          if(_loc30_ >= 1)
                                          {
                                             _loc8_ -= 16;
                                             si32(_loc30_,_loc8_ + 4);
                                             si32(_loc24_,_loc8_);
                                             wdnative.ESP = _loc8_;
                                             wdnative_nternal.F___lshift_D2A();
                                             _loc8_ += 16;
                                             _loc24_ = wdnative.eax;
                                          }
                                          _loc48_ = _loc24_;
                                          if(_loc43_ != 0)
                                          {
                                             while(true)
                                             {
                                                _loc48_ = li32(_loc24_ + 4);
                                                if(_loc48_ >= 10)
                                                {
                                                   _loc37_ = 1 << _loc48_;
                                                   _loc27_ = _loc37_ << 2;
                                                   _loc29_ = _loc27_ + 27;
                                                }
                                                else
                                                {
                                                   var _temp_253:* = _loc48_ << 2;
                                                   _loc29_ = wdnative_nternal._freelist + _temp_253;
                                                   _loc43_ = li32(_loc29_);
                                                   if(_loc43_ != 0)
                                                   {
                                                      _loc27_ = li32(_loc43_);
                                                      si32(_loc27_,_loc29_);
                                                      addr1c86:
                                                      si32(0,_loc43_ + 16);
                                                      si32(0,_loc43_ + 12);
                                                      _loc27_ = li32(_loc24_ + 16);
                                                      _loc8_ -= 16;
                                                      _loc16_ = _loc24_ + 12;
                                                      si32(_loc16_,_loc8_ + 4);
                                                      _loc16_ = _loc43_ + 12;
                                                      si32(_loc16_,_loc8_);
                                                      _loc27_ <<= 2;
                                                      _loc27_ = _loc27_ + 8;
                                                      si32(_loc27_,_loc8_ + 8);
                                                      wdnative.ESP = _loc8_;
                                                      wdnative.Fmemcpy();
                                                      _loc8_ += 16;
                                                      _loc8_ = _loc8_ - 16;
                                                      si32(1,_loc8_ + 4);
                                                      si32(_loc43_,_loc8_);
                                                      wdnative.ESP = _loc8_;
                                                      wdnative_nternal.F___lshift_D2A();
                                                      _loc8_ += 16;
                                                      _loc48_ = wdnative.eax;
                                                      addr1d21:
                                                      _loc43_ = 1;
                                                      if(_loc45_ >= _loc43_)
                                                      {
                                                         _loc43_ = 0;
                                                      }
                                                      _loc37_ = _loc47_ & 1;
                                                      _loc30_ = _loc37_ | _loc43_;
                                                      _loc28_ += -1;
                                                      _loc29_ = _loc35_ + 5;
                                                      _loc47_ = _loc24_;
                                                      _loc24_ = _loc48_;
                                                      loop11:
                                                      while(true)
                                                      {
                                                         _loc8_ -= 16;
                                                         si32(_loc33_,_loc8_ + 4);
                                                         si32(_loc39_,_loc8_);
                                                         wdnative.ESP = _loc8_;
                                                         wdnative_nternal.F___quorem_D2A();
                                                         _loc8_ += 16;
                                                         _loc48_ = wdnative.eax;
                                                         _loc31_ = li32(_loc47_ + 16);
                                                         _loc35_ = li32(_loc39_ + 16);
                                                         _loc43_ = _loc48_ + 48;
                                                         if(_loc35_ != _loc31_)
                                                         {
                                                            _loc35_ -= _loc31_;
                                                         }
                                                         else
                                                         {
                                                            _loc27_ = _loc31_ << 2;
                                                            _loc26_ = _loc39_ + 20;
                                                            _loc31_ = _loc26_ + _loc27_;
                                                            _loc27_ = _loc47_ + _loc27_;
                                                            _loc17_ = _loc27_ + 16;
                                                            while(true)
                                                            {
                                                               _loc14_ = li32(_loc17_);
                                                               _loc13_ = li32(_loc31_ - 4);
                                                               if(_loc13_ != _loc14_)
                                                               {
                                                                  break;
                                                               }
                                                               _loc31_ += -4;
                                                               _loc17_ += -4;
                                                               _loc35_ = 0;
                                                               if(uint(_loc31_) > uint(_loc26_))
                                                               {
                                                                  continue;
                                                               }
                                                            }
                                                            _loc35_ = -1;
                                                            if(uint(_loc13_) >= uint(_loc14_))
                                                            {
                                                               _loc35_ = 1;
                                                            }
                                                         }
                                                         _loc8_ -= 16;
                                                         si32(_loc24_,_loc8_ + 4);
                                                         si32(_loc33_,_loc8_);
                                                         wdnative.ESP = _loc8_;
                                                         wdnative_nternal.F___diff_D2A();
                                                         _loc8_ += 16;
                                                         loop37:
                                                         while(true)
                                                         {
                                                            _loc17_ = wdnative.eax;
                                                            _loc27_ = li32(_loc17_ + 12);
                                                            if(_loc27_ != 0)
                                                            {
                                                               _loc31_ = 1;
                                                               if(_loc17_ != 0)
                                                               {
                                                                  _loc31_ = li32(_loc17_ + 4);
                                                                  if(_loc31_ >= 10)
                                                                  {
                                                                     _loc8_ -= 16;
                                                                     si32(_loc17_,_loc8_);
                                                                     wdnative.ESP = _loc8_;
                                                                     wdnative_nternal.F_idalloc();
                                                                     _loc8_ += 16;
                                                                     _loc31_ = 1;
                                                                  }
                                                                  else
                                                                  {
                                                                     var _temp_279:* = _loc31_ << 2;
                                                                     _loc16_ = wdnative_nternal._freelist + _temp_279;
                                                                     _loc27_ = li32(_loc16_);
                                                                     si32(_loc27_,_loc17_);
                                                                     si32(_loc17_,_loc16_);
                                                                     _loc31_ = 1;
                                                                  }
                                                               }
                                                            }
                                                            else
                                                            {
                                                               _loc13_ = li32(_loc17_ + 16);
                                                               loop38:
                                                               while(true)
                                                               {
                                                                  while(true)
                                                                  {
                                                                     _loc31_ = li32(_loc39_ + 16);
                                                                     if(_loc31_ == _loc13_)
                                                                     {
                                                                        _loc27_ = _loc13_ << 2;
                                                                        _loc26_ = _loc39_ + 20;
                                                                        _loc13_ = _loc26_ + _loc27_;
                                                                        _loc27_ = _loc17_ + _loc27_;
                                                                        _loc14_ = _loc27_ + 16;
                                                                        while(true)
                                                                        {
                                                                           _loc11_ = li32(_loc14_);
                                                                           _loc25_ = li32(_loc13_ - 4);
                                                                           if(_loc25_ != _loc11_)
                                                                           {
                                                                              break;
                                                                           }
                                                                           _loc13_ += -4;
                                                                           _loc14_ += -4;
                                                                           _loc31_ = 0;
                                                                           if(uint(_loc13_) > uint(_loc26_))
                                                                           {
                                                                              continue;
                                                                           }
                                                                        }
                                                                        _loc31_ = -1;
                                                                        if(uint(_loc25_) >= uint(_loc11_))
                                                                        {
                                                                           _loc31_ = 1;
                                                                        }
                                                                        break;
                                                                     }
                                                                     _loc31_ -= _loc13_;
                                                                     if(_loc17_ != 0)
                                                                     {
                                                                        break;
                                                                     }
                                                                     break loop38;
                                                                  }
                                                                  _loc13_ = li32(_loc17_ + 4);
                                                                  if(_loc13_ >= 10)
                                                                  {
                                                                     _loc8_ -= 16;
                                                                     si32(_loc17_,_loc8_);
                                                                     wdnative.ESP = _loc8_;
                                                                     wdnative_nternal.F_idalloc();
                                                                     _loc8_ += 16;
                                                                     break;
                                                                  }
                                                                  var _temp_290:* = _loc13_ << 2;
                                                                  _loc27_ = wdnative_nternal._freelist + _temp_290;
                                                                  _loc16_ = li32(_loc27_);
                                                                  si32(_loc16_,_loc17_);
                                                                  si32(_loc17_,_loc27_);
                                                                  break;
                                                               }
                                                               _loc13_ = _loc17_ = 1;
                                                               if(_loc41_ != _loc17_)
                                                               {
                                                                  _loc13_ = 0;
                                                               }
                                                               if(_loc31_ == 0)
                                                               {
                                                                  _loc17_ = 0;
                                                               }
                                                               _loc27_ = _loc17_ | _loc13_;
                                                               _loc27_ = _loc27_ | _loc30_;
                                                               if(_loc27_ == 0)
                                                               {
                                                                  if(_loc43_ != 57)
                                                                  {
                                                                     if(_loc35_ >= 1)
                                                                     {
                                                                        _loc43_ = _loc48_ + 49;
                                                                     }
                                                                     si8(_loc43_,_loc29_ - 1);
                                                                     break loop33;
                                                                  }
                                                                  break;
                                                               }
                                                            }
                                                            loop40:
                                                            while(true)
                                                            {
                                                               if(_loc35_ >= 0)
                                                               {
                                                                  _loc17_ = _loc13_ = 1;
                                                                  if(_loc41_ != _loc13_)
                                                                  {
                                                                     _loc17_ = 0;
                                                                  }
                                                                  if(_loc35_ == 0)
                                                                  {
                                                                     _loc13_ = 0;
                                                                  }
                                                                  _loc27_ = _loc13_ | _loc17_;
                                                                  _loc27_ = _loc27_ | _loc37_;
                                                                  if(_loc27_ == 0)
                                                                  {
                                                                     addr206d:
                                                                     _loc27_ = li32(_loc39_ + 20);
                                                                     if(_loc27_ != 0)
                                                                     {
                                                                        _loc35_ = _loc43_;
                                                                     }
                                                                     else
                                                                     {
                                                                        var _temp_296:* = li32(_loc39_ + 16);
                                                                        _loc35_ = _loc43_;
                                                                        _loc17_ = _loc43_;
                                                                        if(_temp_296 < 2)
                                                                        {
                                                                           break;
                                                                        }
                                                                     }
                                                                     if(_loc41_ >= 2)
                                                                     {
                                                                        _loc17_ = _loc35_;
                                                                        if(_loc45_ == 0)
                                                                        {
                                                                           break;
                                                                        }
                                                                        if(_loc45_ == 2)
                                                                        {
                                                                           addr2228:
                                                                           si8(_loc35_,_loc29_ - 1);
                                                                           if(_loc28_ != 0)
                                                                           {
                                                                              _loc8_ -= 16;
                                                                              si32(10,_loc8_ + 4);
                                                                              si32(_loc39_,_loc8_);
                                                                              wdnative.ESP = _loc8_;
                                                                              wdnative_nternal.F___multadd_D2A();
                                                                              _loc8_ += 16;
                                                                              _loc39_ = wdnative.eax;
                                                                              if(_loc47_ == _loc24_)
                                                                              {
                                                                                 _loc8_ -= 16;
                                                                                 si32(10,_loc8_ + 4);
                                                                                 si32(_loc24_,_loc8_);
                                                                                 wdnative.ESP = _loc8_;
                                                                                 wdnative_nternal.F___multadd_D2A();
                                                                                 _loc8_ += 16;
                                                                                 _loc24_ = _loc47_ = wdnative.eax;
                                                                              }
                                                                              else
                                                                              {
                                                                                 _loc8_ -= 16;
                                                                                 si32(10,_loc8_ + 4);
                                                                                 si32(_loc47_,_loc8_);
                                                                                 wdnative.ESP = _loc8_;
                                                                                 wdnative_nternal.F___multadd_D2A();
                                                                                 _loc8_ += 16;
                                                                                 _loc47_ = wdnative.eax;
                                                                                 _loc8_ -= 16;
                                                                                 si32(10,_loc8_ + 4);
                                                                                 si32(_loc24_,_loc8_);
                                                                                 wdnative.ESP = _loc8_;
                                                                                 wdnative_nternal.F___multadd_D2A();
                                                                                 _loc8_ += 16;
                                                                                 _loc24_ = wdnative.eax;
                                                                              }
                                                                              _loc28_ += -1;
                                                                              _loc29_ += 1;
                                                                              continue loop11;
                                                                           }
                                                                           §§goto(addr23e3);
                                                                        }
                                                                     }
                                                                     _loc17_ = _loc35_;
                                                                     if(_loc31_ < 1)
                                                                     {
                                                                        break;
                                                                     }
                                                                     _loc8_ -= 16;
                                                                     si32(1,_loc8_ + 4);
                                                                     si32(_loc39_,_loc8_);
                                                                     wdnative.ESP = _loc8_;
                                                                     wdnative_nternal.F___lshift_D2A();
                                                                     _loc8_ += 16;
                                                                     _loc39_ = wdnative.eax;
                                                                     _loc41_ = li32(_loc33_ + 16);
                                                                     _loc45_ = li32(_loc39_ + 16);
                                                                     if(_loc45_ == _loc41_)
                                                                     {
                                                                        _loc27_ = _loc41_ << 2;
                                                                        _loc16_ = _loc27_ + _loc39_;
                                                                        _loc30_ = _loc16_ + 20;
                                                                        _loc27_ += _loc33_;
                                                                        _loc37_ = _loc27_ + 16;
                                                                        _loc28_ = _loc39_ + 20;
                                                                        while(true)
                                                                        {
                                                                           _loc41_ = li32(_loc37_);
                                                                           while(true)
                                                                           {
                                                                              _loc45_ = li32(_loc30_ - 4);
                                                                              if(_loc45_ != _loc41_)
                                                                              {
                                                                                 _loc28_ = -1;
                                                                                 if(uint(_loc45_) >= uint(_loc41_))
                                                                                 {
                                                                                    _loc28_ = 1;
                                                                                 }
                                                                                 addr2198:
                                                                                 if(_loc28_ > 0)
                                                                                 {
                                                                                    break;
                                                                                 }
                                                                                 _loc17_ = _loc35_;
                                                                                 if(_loc28_ != 0)
                                                                                 {
                                                                                    break loop40;
                                                                                 }
                                                                              }
                                                                              else
                                                                              {
                                                                                 _loc30_ += -4;
                                                                                 _loc37_ += -4;
                                                                                 if(uint(_loc30_) > uint(_loc28_))
                                                                                 {
                                                                                    continue;
                                                                                 }
                                                                              }
                                                                              _loc27_ = _loc43_ & 1;
                                                                              _loc17_ = _loc35_;
                                                                              if(_loc27_ != 0)
                                                                              {
                                                                                 break;
                                                                              }
                                                                              break loop40;
                                                                           }
                                                                           _loc17_ = _loc48_ + 49;
                                                                           if(_loc17_ != 58)
                                                                           {
                                                                              break loop40;
                                                                           }
                                                                           break loop37;
                                                                        }
                                                                        break loop33;
                                                                     }
                                                                     _loc28_ = _loc45_ - _loc41_;
                                                                     §§goto(addr2198);
                                                                  }
                                                                  else
                                                                  {
                                                                     if(_loc31_ > 0)
                                                                     {
                                                                        _loc17_ = _loc43_;
                                                                        if(_loc45_ != 0)
                                                                        {
                                                                           if(_loc43_ == 57)
                                                                           {
                                                                              break loop37;
                                                                           }
                                                                           _loc27_ = _loc43_ + 1;
                                                                           si8(_loc27_,_loc29_ - 1);
                                                                           break loop33;
                                                                        }
                                                                        break;
                                                                     }
                                                                     _loc35_ = _loc43_;
                                                                  }
                                                                  §§goto(addr2228);
                                                               }
                                                               §§goto(addr206d);
                                                            }
                                                            si8(_loc17_,_loc29_ - 1);
                                                            break loop33;
                                                         }
                                                         si8(57,_loc29_ - 1);
                                                         §§goto(addr24e7);
                                                      }
                                                      break loop33;
                                                   }
                                                   _loc43_ = li32(wdnative_nternal._pmem_next);
                                                   _loc27_ = _loc43_ - wdnative_nternal._private_mem;
                                                   _loc27_ = (_loc27_ >> 3) + (_loc30_ = (_loc29_ = (_loc16_ = (_loc37_ = 1 << _loc48_) << 2) + 27) >>> 3);
                                                   if((uint(_loc27_)) <= 288)
                                                   {
                                                      var _temp_318:* = _loc30_ << 3;
                                                      _loc27_ = _loc43_ + _temp_318;
                                                      si32(_loc27_,wdnative_nternal._pmem_next);
                                                      break;
                                                   }
                                                }
                                                _loc8_ -= 16;
                                                _loc27_ = _loc29_ & -8;
                                                si32(_loc27_,_loc8_);
                                                wdnative.ESP = _loc8_;
                                                wdnative.F_malloc();
                                                _loc8_ += 16;
                                                _loc43_ = wdnative.eax;
                                                break;
                                             }
                                             si32(_loc48_,_loc43_ + 4);
                                             si32(_loc37_,_loc43_ + 8);
                                             §§goto(addr1c86);
                                          }
                                          §§goto(addr1d21);
                                          §§goto(addr24e7);
                                       }
                                    }
                                    if(_loc28_ >= 0)
                                    {
                                       _loc8_ -= 16;
                                       si32(5,_loc8_ + 4);
                                       si32(_loc33_,_loc8_);
                                       wdnative.ESP = _loc8_;
                                       wdnative_nternal.F___multadd_D2A();
                                       _loc8_ += 16;
                                       _loc33_ = wdnative.eax;
                                       _loc47_ = li32(_loc33_ + 16);
                                       _loc45_ = li32(_loc39_ + 16);
                                       if(_loc45_ == _loc47_)
                                       {
                                          _loc45_ = _loc39_ + 20;
                                          _loc48_ = _loc47_ << 2;
                                          while(true)
                                          {
                                             _loc27_ = _loc33_ + _loc48_;
                                             _loc47_ = li32(_loc27_ + 16);
                                             _loc27_ = _loc39_ + _loc48_;
                                             _loc41_ = li32(_loc27_ + 16);
                                             if(_loc41_ == _loc47_)
                                             {
                                                _loc48_ += -4;
                                                _loc27_ = _loc45_ + _loc48_;
                                                if((uint(_loc27_)) <= uint(_loc45_))
                                                {
                                                   break loop29;
                                                }
                                                continue;
                                             }
                                             _loc45_ = -1;
                                             if(uint(_loc41_) >= uint(_loc47_))
                                             {
                                                _loc45_ = 1;
                                             }
                                          }
                                          break;
                                       }
                                       _loc45_ -= _loc47_;
                                       _loc7_ = _loc32_;
                                       _loc6_ = _loc33_;
                                       if(_loc45_ <= 0)
                                       {
                                          break loop29;
                                       }
                                       break loop30;
                                    }
                                    break loop29;
                                 }
                                 §§goto(addr1b3d);
                              }
                              break loop15;
                           }
                           _loc13_ = _loc48_ - _loc29_;
                           if(_loc13_ <= -1)
                           {
                              _loc8_ -= 16;
                              si32(10,_loc8_ + 4);
                              si32(_loc39_,_loc8_);
                              wdnative.ESP = _loc8_;
                              wdnative_nternal.F___multadd_D2A();
                              _loc32_ += -1;
                              _loc8_ += 16;
                              _loc39_ = wdnative.eax;
                              _loc28_ = _loc31_;
                              if(_loc17_ != 0)
                              {
                                 _loc8_ -= 16;
                                 si32(10,_loc8_ + 4);
                                 si32(_loc24_,_loc8_);
                                 wdnative.ESP = _loc8_;
                                 wdnative_nternal.F___multadd_D2A();
                                 _loc8_ += 16;
                                 _loc24_ = wdnative.eax;
                                 _loc28_ = _loc31_;
                              }
                           }
                        }
                        §§goto(addr1a0f);
                     }
                     si8(49,_loc42_);
                     _loc32_ = _loc7_ + 1;
                     _loc29_ = _loc42_ + 1;
                     _loc47_ = 0;
                     _loc33_ = _loc6_;
                     break loop15;
                  }
                  _loc32_ = _loc37_ ^ -1;
                  _loc47_ = 0;
                  _loc29_ = _loc42_;
                  if(_loc33_ != 0)
                  {
                     _loc45_ = li32(_loc33_ + 4);
                     if(_loc45_ >= 10)
                     {
                        _loc8_ -= 16;
                        si32(_loc33_,_loc8_);
                        wdnative.ESP = _loc8_;
                        wdnative_nternal.F_idalloc();
                        _loc8_ += 16;
                     }
                     else
                     {
                        var _temp_86:* = _loc45_ << 2;
                        _loc27_ = wdnative_nternal._freelist + _temp_86;
                        _loc16_ = li32(_loc27_);
                        si32(_loc16_,_loc33_);
                        si32(_loc33_,_loc27_);
                     }
                  }
                  _loc7_ = _loc32_;
                  if(_loc24_ != 0)
                  {
                     if(_loc47_ != 0)
                     {
                        if(_loc47_ != _loc24_)
                        {
                           if(_loc47_ != 0)
                           {
                              _loc45_ = li32(_loc47_ + 4);
                              if(_loc45_ >= 10)
                              {
                                 _loc8_ -= 16;
                                 si32(_loc47_,_loc8_);
                                 wdnative.ESP = _loc8_;
                                 wdnative_nternal.F_idalloc();
                                 _loc8_ += 16;
                              }
                              else
                              {
                                 var _temp_91:* = _loc45_ << 2;
                                 _loc27_ = wdnative_nternal._freelist + _temp_91;
                                 _loc16_ = li32(_loc27_);
                                 si32(_loc16_,_loc47_);
                                 si32(_loc47_,_loc27_);
                              }
                           }
                           _loc7_ = _loc32_;
                           if(_loc24_ == 0)
                           {
                              break loop27;
                           }
                        }
                     }
                     _loc45_ = li32(_loc24_ + 4);
                     if(_loc45_ >= 10)
                     {
                        _loc8_ -= 16;
                        si32(_loc24_,_loc8_);
                        wdnative.ESP = _loc8_;
                        wdnative_nternal.F_idalloc();
                        _loc8_ += 16;
                        _loc7_ = _loc32_;
                        break loop27;
                     }
                     var _temp_96:* = _loc45_ << 2;
                     _loc16_ = wdnative_nternal._freelist + _temp_96;
                     _loc27_ = li32(_loc16_);
                     si32(_loc27_,_loc24_);
                     si32(_loc24_,_loc16_);
                     _loc7_ = _loc32_;
                  }
                  break loop27;
               }
               while(true)
               {
                  _loc45_ = _loc29_;
                  _loc32_ = li8(_loc45_ - 1);
                  if(_loc32_ != 57)
                  {
                     _loc32_ += 1;
                     _loc7_ = _loc33_;
                     break;
                  }
                  _loc29_ = _loc45_ + -1;
                  if(_loc42_ == _loc29_)
                  {
                     si8(48,_loc29_);
                     _loc7_ = _loc33_ + 1;
                     _loc32_ = 49;
                     break;
                  }
               }
               si8(_loc32_,_loc45_ - 1);
               _loc29_ = _loc45_;
               break;
            }
            if(_loc39_ != 0)
            {
               _loc45_ = li32(_loc39_ + 4);
               if(_loc45_ >= 10)
               {
                  _loc8_ -= 16;
                  si32(_loc39_,_loc8_);
                  wdnative.ESP = _loc8_;
                  wdnative_nternal.F_idalloc();
                  _loc8_ += 16;
               }
               else
               {
                  var _temp_78:* = _loc45_ << 2;
                  _loc16_ = wdnative_nternal._freelist + _temp_78;
                  _loc27_ = li32(_loc16_);
                  si32(_loc27_,_loc39_);
                  si32(_loc39_,_loc16_);
               }
            }
            si8(0,_loc29_);
            _loc27_ = _loc7_ + 1;
            si32(_loc27_,_loc44_);
            if(_loc46_ != 0)
            {
               si32(_loc29_,_loc46_);
            }
         }
      }
      wdnative.eax = _loc42_;
      wdnative.ESP = _loc8_ = _loc12_;
   }
}

