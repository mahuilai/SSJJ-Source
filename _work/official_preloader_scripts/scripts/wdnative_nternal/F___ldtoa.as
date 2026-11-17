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
   
   public function F___ldtoa() : void
   {
      var _temp_1:* = this;
      var _loc14_:int = 0;
      var _loc41_:int = 0;
      var _loc43_:int = 0;
      var _loc32_:int = 0;
      var _loc27_:int = 0;
      var _loc9_:int = 0;
      var _loc13_:int = 0;
      var _loc24_:Number = NaN;
      var _loc1_:Number = NaN;
      var _loc42_:int = 0;
      var _loc36_:int = 0;
      var _loc2_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc4_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc40_:int = 0;
      var _loc22_:Number = NaN;
      var _loc6_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc16_:int = 0;
      var _loc19_:int = 0;
      var _loc11_:int = 0;
      var _loc29_:int = 0;
      var _loc37_:int = 0;
      var _loc48_:int = 0;
      var _loc47_:int = 0;
      var _loc18_:int = 0;
      var _loc23_:Number = NaN;
      var _loc38_:int = 0;
      var _loc15_:int = 0;
      var _loc12_:int = 0;
      var _loc28_:int = 0;
      var _loc33_:int = 0;
      var _loc30_:int = 0;
      var _loc39_:int = 0;
      var _loc31_:int = 0;
      var _loc44_:int = 0;
      var _loc45_:int = 0;
      var _loc46_:int = 0;
      var _loc34_:int = 0;
      var _loc49_:int = 0;
      var _loc35_:int = 0;
      var _loc8_:int = 0;
      var _loc17_:int = 0;
      var _loc26_:int = 0;
      _loc14_ = wdnative.ESP;
      var _loc10_:int = _loc14_ - 208;
      _loc29_ = li32(_loc14_);
      _loc49_ = li32(_loc29_);
      _loc29_ = li32(_loc29_ + 4);
      _loc48_ = _loc29_ >>> 31;
      _loc47_ = li32(_loc14_ + 16);
      si32(_loc48_,_loc47_);
      si32(_loc49_,_loc14_ - 8);
      _loc46_ = _loc29_ & 0x0FFFFF;
      si32(_loc46_,_loc14_ - 4);
      _loc29_ >>>= 20;
      _loc45_ = _loc29_ & 0x07FF;
      _loc44_ = _loc45_ + -1075;
      _loc43_ = li32(_loc14_ + 20);
      _loc41_ = li32(_loc14_ + 12);
      _loc26_ = li32(_loc14_ + 8);
      _loc34_ = li32(_loc14_ + 4);
      loop25:
      while(true)
      {
         if(_loc45_ != 2047)
         {
            if(_loc45_ != 0)
            {
               break;
            }
            var _temp_8:* = _loc46_ | _loc49_;
            _loc49_ = 16;
            if(_temp_8 != 0)
            {
               _loc49_ = 8;
            }
         }
         else
         {
            var _temp_9:* = _loc46_ | _loc49_;
            _loc49_ = 1;
            if(_temp_9 != 0)
            {
               _loc49_ = 2;
            }
         }
         loop26:
         while(true)
         {
            if(_loc49_ <= 3)
            {
               while(true)
               {
                  if(_loc49_ != 1)
                  {
                     if(_loc49_ == 2)
                     {
                        si32(-32768,_loc41_);
                        _loc10_ -= 16;
                        si32(3,_loc10_ + 8);
                        si32(_loc43_,_loc10_ + 4);
                        si32(wdnative_nternal.L__2E_str1953,_loc10_);
                        wdnative.ESP = _loc10_;
                        wdnative_nternal.F___nrv_alloc_D2A();
                        _loc10_ += 16;
                        _loc26_ = wdnative.eax;
                        break;
                     }
                     wdnative.ESP = _loc10_;
                     wdnative_nternal.F_abort();
                  }
                  si32(-32768,_loc41_);
                  _loc10_ -= 16;
                  si32(8,_loc10_ + 8);
                  si32(_loc43_,_loc10_ + 4);
                  si32(wdnative_nternal.L__2E_str952,_loc10_);
                  wdnative.ESP = _loc10_;
                  wdnative_nternal.F___nrv_alloc_D2A();
                  _loc10_ += 16;
                  _loc26_ = wdnative.eax;
                  break;
               }
            }
            else
            {
               loop28:
               while(true)
               {
                  if(_loc49_ != 16)
                  {
                     if(_loc49_ != 8)
                     {
                        if(_loc49_ == 4)
                        {
                           break loop25;
                        }
                        §§goto(addr01d2);
                     }
                     else
                     {
                        _loc44_ = _loc45_ + -1074;
                        addr0277:
                        _loc45_ = li32(wdnative_nternal._freelist + 4);
                        if(_loc45_ != 0)
                        {
                           _loc29_ = li32(_loc45_);
                           si32(_loc29_,wdnative_nternal._freelist + 4);
                        }
                        else
                        {
                           _loc45_ = li32(wdnative_nternal._pmem_next);
                           _loc29_ = _loc45_ - wdnative_nternal._private_mem;
                           _loc29_ = _loc29_ >> 3;
                           _loc29_ = _loc29_ + 4;
                           if((uint(_loc29_)) <= 288)
                           {
                              _loc29_ = _loc45_ + 32;
                              si32(_loc29_,wdnative_nternal._pmem_next);
                           }
                           else
                           {
                              _loc10_ -= 16;
                              si32(32,_loc10_);
                              wdnative.ESP = _loc10_;
                              wdnative.F_malloc();
                              _loc10_ += 16;
                              _loc45_ = wdnative.eax;
                           }
                           si32(1,_loc45_ + 4);
                           si32(2,_loc45_ + 8);
                        }
                        si32(0,_loc45_ + 16);
                        si32(0,_loc45_ + 12);
                        _loc29_ = li32(_loc14_ - 8);
                        si32(_loc29_,_loc45_ + 20);
                        _loc29_ = li32(_loc14_ - 4);
                        si32(_loc29_,_loc45_ + 24);
                        _loc46_ = _loc45_ + 20;
                        _loc29_ = _loc45_ + 28;
                        _loc29_ = _loc29_ - _loc46_;
                        _loc49_ = _loc29_ >> 2;
                        _loc29_ = _loc49_ << 5;
                        _loc35_ = 0 - _loc29_;
                        while(true)
                        {
                           _loc37_ = _loc49_ << 2;
                           _loc29_ = _loc45_ + _loc37_;
                           _loc29_ = li32(_loc29_ + 16);
                           if(_loc29_ != 0)
                           {
                              si32(_loc49_,_loc45_ + 16);
                              _loc29_ = _loc45_ + 16;
                              _loc29_ = _loc29_ + _loc37_;
                              _loc39_ = li32(_loc29_);
                              _loc30_ = _loc39_ << 16;
                              if(uint(_loc39_) >= 65536)
                              {
                                 _loc30_ = _loc39_;
                              }
                              _loc31_ = _loc30_ << 8;
                              if(uint(_loc30_) >= 16777216)
                              {
                                 _loc31_ = _loc30_;
                              }
                              _loc32_ = _loc31_ << 4;
                              if(uint(_loc31_) >= 268435456)
                              {
                                 _loc32_ = _loc31_;
                              }
                              _loc37_ = _loc32_ << 2;
                              if(uint(_loc32_) >= 1073741824)
                              {
                                 _loc37_ = _loc32_;
                              }
                              _loc33_ = 16;
                              if(uint(_loc39_) >= 65536)
                              {
                                 _loc33_ = 0;
                              }
                              _loc39_ = _loc33_ | 8;
                              if(uint(_loc30_) >= 16777216)
                              {
                                 _loc39_ = _loc33_;
                              }
                              _loc33_ = _loc39_ | 4;
                              if(uint(_loc31_) >= 268435456)
                              {
                                 _loc33_ = _loc39_;
                              }
                              _loc31_ = _loc33_ | 2;
                              if(uint(_loc32_) >= 1073741824)
                              {
                                 _loc31_ = _loc33_;
                              }
                              while(true)
                              {
                                 if(_loc37_ >= 0)
                                 {
                                    _loc31_ += 1;
                                    var _temp_32:* = _loc37_ & 0x40000000;
                                    _loc37_ = 32;
                                    if(_temp_32 == 0)
                                    {
                                       break;
                                    }
                                 }
                                 _loc37_ = _loc31_;
                                 break;
                              }
                              _loc29_ = 0 - _loc37_;
                              _loc37_ = _loc29_ - _loc35_;
                              break;
                           }
                           _loc35_ += 32;
                           _loc49_ += -1;
                           if(_loc49_ == 0)
                           {
                              _loc49_ = 0;
                              si32(_loc49_,_loc45_ + 16);
                              _loc37_ = _loc49_;
                              break;
                           }
                        }
                        _loc31_ = _loc35_ = 0;
                        while(_loc31_ < _loc49_)
                        {
                           var _temp_35:* = _loc31_ << 2;
                           _loc29_ = _loc45_ + _temp_35;
                           _loc32_ = li32(_loc29_ + 20);
                           if(_loc32_ != 0)
                           {
                              _loc29_ = _loc32_ & 7;
                              if(_loc29_ != 0)
                              {
                                 var _temp_39:* = _loc32_ & 1;
                                 _loc33_ = 0;
                                 if(_temp_39 == 0)
                                 {
                                    var _temp_40:* = _loc32_ & 2;
                                    _loc33_ = 1;
                                    if(_temp_40 == 0)
                                    {
                                       _loc33_ = 2;
                                    }
                                 }
                              }
                              else
                              {
                                 _loc39_ = _loc32_ >>> 16;
                                 _loc31_ = _loc32_ & 0xFFFF;
                                 if(_loc31_ != 0)
                                 {
                                    _loc39_ = _loc32_;
                                 }
                                 _loc32_ = _loc39_ >>> 8;
                                 _loc33_ = _loc39_ & 0xFF;
                                 if(_loc33_ != 0)
                                 {
                                    _loc32_ = _loc39_;
                                 }
                                 _loc28_ = _loc32_ >>> 4;
                                 _loc39_ = _loc32_ & 0x0F;
                                 if(_loc39_ != 0)
                                 {
                                    _loc28_ = _loc32_;
                                 }
                                 _loc32_ = _loc28_ >>> 2;
                                 _loc30_ = _loc28_ & 3;
                                 if(_loc30_ != 0)
                                 {
                                    _loc32_ = _loc28_;
                                 }
                                 _loc28_ = 16;
                                 if(_loc31_ != 0)
                                 {
                                    _loc28_ = 0;
                                 }
                                 _loc31_ = _loc28_ | 8;
                                 if(_loc33_ != 0)
                                 {
                                    _loc31_ = _loc28_;
                                 }
                                 _loc33_ = _loc31_ | 4;
                                 if(_loc39_ != 0)
                                 {
                                    _loc33_ = _loc31_;
                                 }
                                 _loc31_ = _loc33_ | 2;
                                 if(_loc30_ != 0)
                                 {
                                    _loc31_ = _loc33_;
                                 }
                                 while(true)
                                 {
                                    _loc29_ = _loc32_ & 1;
                                    if(_loc29_ == 0)
                                    {
                                       _loc31_ += 1;
                                       _loc33_ = 32;
                                       if(uint(_loc32_) < 2)
                                       {
                                          break;
                                       }
                                    }
                                    _loc33_ = _loc31_;
                                    break;
                                 }
                              }
                              _loc35_ = _loc33_ + _loc35_;
                              break;
                           }
                           _loc35_ += 32;
                           _loc31_ += 1;
                        }
                        _loc27_ = _loc44_;
                        if(_loc35_ != 0)
                        {
                           _loc28_ = _loc35_ >> 5;
                           _loc31_ = _loc46_;
                           if(_loc49_ > _loc28_)
                           {
                              var _temp_46:* = _loc49_ << 2;
                              _loc29_ = _loc45_ + _temp_46;
                              _loc32_ = _loc29_ + 20;
                              _loc33_ = _loc35_ & 0x1F;
                              if(_loc33_ == 0)
                              {
                                 _loc31_ = _loc46_;
                                 if(_loc28_ < _loc49_)
                                 {
                                    _loc49_ = _loc28_ << 2;
                                    _loc31_ = _loc45_ + 20;
                                    do
                                    {
                                       _loc29_ = _loc31_ + _loc49_;
                                       _loc29_ = li32(_loc29_);
                                       si32(_loc29_,_loc31_);
                                    }
                                    while(_loc31_ += 4, _loc29_ = _loc31_ + _loc49_, (uint(_loc29_)) < uint(_loc32_));
                                 }
                              }
                              else
                              {
                                 var _temp_53:* = _loc28_ << 2;
                                 _loc30_ = _loc45_ + _temp_53;
                                 _loc29_ = li32(_loc30_ + 20);
                                 _loc39_ = _loc29_ >>> _loc33_;
                                 var _temp_56:* = int(_loc28_ + 1);
                                 _loc31_ = _loc46_;
                                 if(_temp_56 < _loc49_)
                                 {
                                    _loc49_ = 32 - _loc33_;
                                    _loc30_ += 24;
                                    _loc31_ = _loc45_ + 20;
                                    do
                                    {
                                       _loc29_ = li32(_loc30_);
                                       _loc29_ = _loc29_ << _loc49_;
                                       _loc29_ = _loc29_ | _loc39_;
                                       si32(_loc29_,_loc31_);
                                       _loc29_ = li32(_loc30_);
                                       _loc39_ = _loc29_ >>> _loc33_;
                                       _loc30_ += 4;
                                       _loc31_ += 4;
                                    }
                                    while(uint(_loc30_) < uint(_loc32_));
                                 }
                                 si32(_loc39_,_loc31_);
                                 if(_loc39_ != 0)
                                 {
                                    _loc31_ += 4;
                                 }
                              }
                           }
                           _loc29_ = _loc31_ - _loc46_;
                           _loc49_ = _loc29_ >> 2;
                           si32(_loc49_,_loc45_ + 16);
                           if(_loc49_ == 0)
                           {
                              si32(0,_loc46_);
                           }
                           _loc37_ -= _loc35_;
                           _loc27_ = _loc35_ + _loc44_;
                        }
                        if(_loc49_ == 0)
                        {
                           if(_loc45_ != 0)
                           {
                              _loc46_ = li32(_loc45_ + 4);
                              if(_loc46_ >= 10)
                              {
                                 _loc10_ -= 16;
                                 si32(_loc45_,_loc10_);
                                 wdnative.ESP = _loc10_;
                                 wdnative_nternal.F_idalloc();
                                 _loc10_ += 16;
                              }
                              else
                              {
                                 var _temp_65:* = _loc46_ << 2;
                                 _loc29_ = wdnative_nternal._freelist + _temp_65;
                                 _loc48_ = li32(_loc29_);
                                 si32(_loc48_,_loc45_);
                                 si32(_loc45_,_loc29_);
                              }
                           }
                        }
                        else
                        {
                           _loc32_ = _loc49_ + -1;
                           var _temp_69:* = _loc32_ << 2;
                           _loc33_ = _loc45_ + _temp_69;
                           _loc35_ = li32(_loc33_ + 20);
                           _loc19_ = _loc35_ << 16;
                           if(uint(_loc35_) >= 65536)
                           {
                              _loc19_ = _loc35_;
                           }
                           _loc39_ = _loc19_ << 8;
                           if(uint(_loc19_) >= 16777216)
                           {
                              _loc39_ = _loc19_;
                           }
                           _loc30_ = _loc39_ << 4;
                           if(uint(_loc39_) >= 268435456)
                           {
                              _loc30_ = _loc39_;
                           }
                           _loc31_ = _loc30_ << 2;
                           if(uint(_loc30_) >= 1073741824)
                           {
                              _loc31_ = _loc30_;
                           }
                           _loc17_ = 16;
                           if(uint(_loc35_) >= 65536)
                           {
                              _loc17_ = 0;
                           }
                           _loc28_ = _loc17_ | 8;
                           if(uint(_loc19_) >= 16777216)
                           {
                              _loc28_ = _loc17_;
                           }
                           _loc17_ = _loc28_ | 4;
                           if(uint(_loc39_) >= 268435456)
                           {
                              _loc17_ = _loc28_;
                           }
                           _loc39_ = _loc17_ | 2;
                           if(uint(_loc30_) >= 1073741824)
                           {
                              _loc39_ = _loc17_;
                           }
                           _loc33_ += 20;
                           while(true)
                           {
                              if(_loc31_ >= 0)
                              {
                                 _loc39_ += 1;
                                 var _temp_72:* = _loc31_ & 0x40000000;
                                 _loc31_ = 32;
                                 if(_temp_72 == 0)
                                 {
                                    break;
                                 }
                              }
                              _loc31_ = _loc39_;
                              if(_loc39_ <= 10)
                              {
                                 _loc31_ = 0;
                                 if(_loc32_ >= 1)
                                 {
                                    _loc29_ = _loc49_ << 2;
                                    _loc29_ = _loc29_ + _loc45_;
                                    _loc31_ = li32(_loc29_ + 12);
                                 }
                                 _loc48_ = 11 - _loc39_;
                                 _loc29_ = _loc35_ >>> _loc48_;
                                 _loc46_ = _loc29_ | 0x3FF00000;
                                 _loc29_ = _loc31_ >>> _loc48_;
                                 _loc48_ = _loc39_ + 21;
                                 _loc48_ = _loc35_ << _loc48_;
                                 _loc29_ |= _loc48_;
                                 _loc18_ = _loc29_ | 0;
                                 addr0a16:
                                 _loc29_ = _loc14_ - 16;
                                 _loc29_ = _loc29_ | 4;
                                 _loc48_ = _loc46_ & 0x0FFFFF;
                                 _loc49_ = _loc48_ | 0x3FF00000;
                                 si32(_loc49_,_loc29_);
                                 si32(_loc18_,_loc14_ - 16);
                                 _loc32_ = _loc27_ + _loc37_;
                                 _loc46_ = 1 - _loc32_;
                                 _loc35_ = _loc32_ + -1;
                                 if(_loc35_ >= 0)
                                 {
                                    _loc46_ = _loc35_;
                                 }
                                 _loc46_ += -1077;
                                 var _loc21_:Number = _loc35_;
                                 _loc21_ = _loc21_ * 0.301029995663981;
                                 var _loc20_:Number = lf64(_loc14_ - 16);
                                 _loc20_ = _loc20_ + -1.5;
                                 _loc20_ = _loc20_ * 0.289529654602168;
                                 _loc20_ = _loc20_ + 0.1760912590558;
                                 _loc23_ = _loc20_ + _loc21_;
                                 if(_loc46_ >= 1)
                                 {
                                    _loc21_ = _loc46_;
                                    _loc21_ = _loc21_ * 7e-17;
                                    _loc23_ = _loc21_ + _loc23_;
                                 }
                                 _loc46_ = _loc23_;
                                 if(!(_loc23_ >= 0 | _loc23_ != _loc23_ | false))
                                 {
                                    _loc21_ = _loc46_;
                                    if(_loc21_ != _loc23_)
                                    {
                                       _loc46_ += -1;
                                    }
                                 }
                                 _loc29_ = _loc32_ << 20;
                                 _loc29_ = _loc29_ + _loc49_;
                                 _loc29_ = _loc29_ + -1048576;
                                 _loc15_ = _loc29_ | 0;
                                 _loc16_ = 1;
                                 if(uint(_loc46_) <= 22)
                                 {
                                    _loc29_ = _loc14_ - 24;
                                    var _temp_93:* = _loc29_ | 4;
                                    si32(_loc15_,_temp_93);
                                    si32(_loc18_,_loc14_ - 24);
                                    var _temp_94:* = _loc46_ << 3;
                                    _loc29_ = wdnative_nternal.___tens_D2A + _temp_94;
                                    var _temp_97:* = lf64(_loc29_);
                                    _loc16_ = 0;
                                    _loc49_ = 1;
                                    _loc21_ = lf64(_loc14_ - 24);
                                    if(_loc21_ >= _temp_97)
                                    {
                                       _loc49_ = _loc16_;
                                    }
                                    _loc29_ = _loc49_ & 1;
                                    _loc46_ -= _loc29_;
                                 }
                                 _loc49_ = _loc37_ - _loc35_;
                                 _loc28_ = 0;
                                 if(_loc49_ <= 0)
                                 {
                                    _loc28_ = 1 - _loc49_;
                                 }
                                 _loc12_ = _loc49_ + -1;
                                 if(_loc49_ <= 0)
                                 {
                                    _loc12_ = 0;
                                 }
                                 if(_loc46_ >= 0)
                                 {
                                    _loc12_ = _loc46_ + _loc12_;
                                    _loc13_ = 0;
                                    _loc9_ = _loc46_;
                                 }
                                 else
                                 {
                                    _loc28_ -= _loc46_;
                                    _loc13_ = 0 - _loc46_;
                                    _loc9_ = 0;
                                 }
                                 _loc49_ = _loc31_ = 0;
                                 if(uint(_loc34_) <= 9)
                                 {
                                    _loc49_ = _loc34_;
                                 }
                                 _loc32_ = _loc49_ + -4;
                                 if(_loc49_ <= 5)
                                 {
                                    _loc32_ = _loc49_;
                                 }
                                 _loc19_ = 1;
                                 while(true)
                                 {
                                    if(_loc32_ <= 2)
                                    {
                                       _loc33_ = _loc11_ = -1;
                                       _loc39_ = _loc31_;
                                       if(uint(_loc32_) >= 2)
                                       {
                                          if(_loc32_ == 2)
                                          {
                                             _loc34_ = 0;
                                             addr0c4c:
                                             if(_loc26_ >= _loc19_)
                                             {
                                                _loc19_ = _loc26_;
                                             }
                                             _loc35_ = _loc19_;
                                             _loc19_ = _loc34_;
                                             _loc11_ = _loc35_;
                                             _loc30_ = _loc35_;
                                             _loc26_ = _loc35_;
                                          }
                                          addr0c9f:
                                          _loc34_ = 4;
                                          _loc31_ = 0;
                                          _loc33_ = _loc30_;
                                          _loc39_ = _loc26_;
                                          if(uint(_loc35_) >= 20)
                                          {
                                             do
                                             {
                                                _loc31_ += 1;
                                             }
                                             while(_loc34_ <<= 1, _loc29_ = _loc34_ + 16, (uint(_loc29_)) <= uint(_loc35_));
                                             _loc33_ = _loc30_;
                                             _loc39_ = _loc26_;
                                             if(_loc31_ >= 10)
                                             {
                                                _loc35_ = 1 << _loc31_;
                                                _loc29_ = _loc35_ << 2;
                                                _loc34_ = _loc29_ + 27;
                                                _loc33_ = _loc30_;
                                                _loc39_ = _loc26_;
                                                break;
                                             }
                                          }
                                       }
                                    }
                                    else
                                    {
                                       loop33:
                                       while(true)
                                       {
                                          while(true)
                                          {
                                             if(_loc32_ != 3)
                                             {
                                                _loc34_ = _loc19_;
                                                if(_loc32_ != 4)
                                                {
                                                   if(_loc32_ != 5)
                                                   {
                                                      break;
                                                   }
                                                }
                                                else
                                                {
                                                   §§goto(addr0c4c);
                                                }
                                             }
                                             else
                                             {
                                                _loc19_ = 0;
                                             }
                                             _loc11_ = _loc46_ + _loc26_;
                                             _loc35_ = _loc11_ + 1;
                                             _loc31_ = 0;
                                             _loc30_ = _loc35_;
                                             _loc33_ = _loc35_;
                                             _loc39_ = _loc26_;
                                             if(_loc11_ >= 0)
                                             {
                                                break;
                                             }
                                             break loop33;
                                          }
                                          §§goto(addr0c9f);
                                       }
                                    }
                                    break loop33;
                                 }
                                 _loc10_ -= 16;
                                 _loc29_ = _loc34_ & -8;
                                 si32(_loc29_,_loc10_);
                                 wdnative.ESP = _loc10_;
                                 wdnative.F_malloc();
                                 _loc10_ += 16;
                                 _loc30_ = wdnative.eax;
                                 si32(_loc31_,_loc30_ + 4);
                                 si32(_loc35_,_loc30_ + 8);
                                 si32(0,_loc30_ + 16);
                                 si32(0,_loc30_ + 12);
                                 si32(_loc31_,_loc30_);
                                 _loc26_ = 0;
                                 _loc31_ = 0;
                                 if(_loc26_ != 0)
                                 {
                                    _loc31_ = 2;
                                    if(_loc26_ >= 0)
                                    {
                                       _loc31_ = _loc26_;
                                    }
                                 }
                                 _loc34_ = _loc35_ = 1;
                                 if(_loc49_ >= 6)
                                 {
                                    _loc34_ = 0;
                                 }
                                 if(uint(_loc33_) >= 15)
                                 {
                                    _loc35_ = 0;
                                 }
                                 _loc26_ = _loc30_ + 4;
                                 loop35:
                                 while(true)
                                 {
                                    loop36:
                                    while(true)
                                    {
                                       loop37:
                                       while(true)
                                       {
                                          loop38:
                                          while(true)
                                          {
                                             loop39:
                                             while(true)
                                             {
                                                if(_loc31_ == 0)
                                                {
                                                   _loc29_ = _loc35_ & _loc34_;
                                                   _loc29_ = _loc29_ & 1;
                                                   if(_loc29_ != 0)
                                                   {
                                                      if(_loc46_ == 0)
                                                      {
                                                         if(_loc46_ >= 1)
                                                         {
                                                            _loc8_ = _loc46_ >> 4;
                                                            var _temp_131:* = _loc8_ & 0x10;
                                                            _loc17_ = 2;
                                                            _loc35_ = _loc18_;
                                                            _loc34_ = _loc15_;
                                                            if(_temp_131 != 0)
                                                            {
                                                               _loc29_ = _loc14_ - 64;
                                                               var _temp_133:* = _loc29_ | 4;
                                                               si32(_loc15_,_temp_133);
                                                               si32(_loc18_,_loc14_ - 64);
                                                               _loc21_ = lf64(_loc14_ - 64);
                                                               _loc21_ = _loc21_ / 1e+256;
                                                               sf64(_loc21_,_loc14_ - 72);
                                                               _loc8_ &= 15;
                                                               _loc29_ = _loc14_ - 72;
                                                               _loc29_ = _loc29_ | 4;
                                                               _loc34_ = li32(_loc29_);
                                                               _loc17_ = 3;
                                                               _loc35_ = li32(_loc14_ - 72);
                                                            }
                                                            _loc29_ = _loc46_ & 0x0F;
                                                            _loc29_ = _loc29_ << 3;
                                                            _loc29_ = wdnative_nternal.___tens_D2A + _loc29_;
                                                            _loc22_ = lf64(_loc29_);
                                                            _loc38_ = wdnative_nternal.___bigtens_D2A;
                                                            if(_loc8_ != 0)
                                                            {
                                                               do
                                                               {
                                                                  _loc29_ = _loc8_ & 1;
                                                                  if(_loc29_ != 0)
                                                                  {
                                                                     _loc21_ = lf64(_loc38_);
                                                                     _loc22_ = _loc21_ * _loc22_;
                                                                     _loc17_ += 1;
                                                                  }
                                                                  _loc38_ += 8;
                                                               }
                                                               while(_loc8_ >>= 1, _loc8_ != 0);
                                                            }
                                                         }
                                                         else
                                                         {
                                                            _loc22_ = 1;
                                                            _loc17_ = 2;
                                                            _loc35_ = _loc18_;
                                                            _loc34_ = _loc15_;
                                                            if(_loc46_ != 0)
                                                            {
                                                               var _temp_145:* = int(0 - _loc46_);
                                                               var _temp_144:* = (_loc48_ = _loc14_ - 32) | 4;
                                                               si32(_loc15_,_temp_144);
                                                               si32(_loc18_,_loc14_ - 32);
                                                               var _temp_147:* = (_loc48_ = _temp_145 & 0x0F) << 3;
                                                               _loc48_ = wdnative_nternal.___tens_D2A + _temp_147;
                                                               var _temp_150:* = lf64(_loc48_);
                                                               _loc20_ = (_loc20_ = lf64(_loc14_ - 32)) * _temp_150;
                                                               sf64(_loc20_,_loc14_ - 40);
                                                               _loc8_ = _temp_145 >> 4;
                                                               _loc29_ = _loc14_ - 40;
                                                               _loc29_ = _loc29_ | 4;
                                                               _loc34_ = li32(_loc29_);
                                                               _loc38_ = wdnative_nternal.___bigtens_D2A;
                                                               _loc22_ = 1;
                                                               _loc17_ = 2;
                                                               _loc35_ = li32(_loc14_ - 40);
                                                               if(_loc8_ != 0)
                                                               {
                                                                  do
                                                                  {
                                                                     _loc29_ = _loc8_ & 1;
                                                                     if(_loc29_ != 0)
                                                                     {
                                                                        _loc29_ = _loc14_ - 48;
                                                                        var _temp_156:* = _loc29_ | 4;
                                                                        si32(_loc34_,_temp_156);
                                                                        si32(_loc35_,_loc14_ - 48);
                                                                        var _temp_158:* = lf64(_loc38_);
                                                                        _loc21_ = (_loc20_ = lf64(_loc14_ - 48)) * _temp_158;
                                                                        sf64(_loc21_,_loc14_ - 56);
                                                                        _loc17_ += 1;
                                                                        _loc29_ = _loc14_ - 56;
                                                                        _loc29_ = _loc29_ | 4;
                                                                        _loc34_ = li32(_loc29_);
                                                                        _loc35_ = li32(_loc14_ - 56);
                                                                     }
                                                                     _loc38_ += 8;
                                                                     _loc8_ >>= 1;
                                                                     _loc22_ = 1;
                                                                  }
                                                                  while(_loc8_ != 0);
                                                               }
                                                            }
                                                         }
                                                         _loc8_ = _loc46_;
                                                         _loc38_ = _loc33_;
                                                         loop40:
                                                         while(true)
                                                         {
                                                            if(_loc16_ != 0)
                                                            {
                                                               _loc29_ = _loc14_ - 80;
                                                               var _temp_163:* = _loc29_ | 4;
                                                               si32(_loc34_,_temp_163);
                                                               si32(_loc35_,_loc14_ - 80);
                                                               _loc24_ = lf64(_loc14_ - 80);
                                                               _loc8_ = _loc46_;
                                                               _loc38_ = _loc33_;
                                                               if(!(_loc24_ >= 1 | _loc24_ != _loc24_ | false))
                                                               {
                                                                  _loc8_ = _loc46_;
                                                                  _loc38_ = _loc33_;
                                                                  if(_loc33_ >= 1)
                                                                  {
                                                                     if(_loc11_ < 1)
                                                                     {
                                                                        break;
                                                                     }
                                                                     _loc21_ = _loc24_ * 10;
                                                                     sf64(_loc21_,_loc14_ - 88);
                                                                     _loc17_ += 1;
                                                                     _loc8_ = _loc46_ + -1;
                                                                     _loc29_ = _loc14_ - 88;
                                                                     _loc29_ = _loc29_ | 4;
                                                                     _loc34_ = li32(_loc29_);
                                                                     _loc35_ = li32(_loc14_ - 88);
                                                                     _loc38_ = _loc11_;
                                                                  }
                                                               }
                                                            }
                                                            _loc29_ = _loc14_ - 96;
                                                            _loc29_ = _loc29_ | 4;
                                                            si32(_loc34_,_loc29_);
                                                            si32(_loc35_,_loc14_ - 96);
                                                            _loc21_ = _loc17_;
                                                            _loc1_ = lf64(_loc14_ - 96);
                                                            _loc21_ *= _loc1_;
                                                            _loc21_ = _loc21_ + 7;
                                                            sf64(_loc21_,_loc14_ - 104);
                                                            _loc29_ = _loc14_ - 104;
                                                            _loc29_ = _loc29_ | 4;
                                                            _loc29_ = li32(_loc29_);
                                                            _loc36_ = _loc29_ + -54525952;
                                                            _loc42_ = li32(_loc14_ - 104);
                                                            if(_loc38_ == 0)
                                                            {
                                                               _loc29_ = _loc14_ - 184;
                                                               var _temp_174:* = _loc29_ | 4;
                                                               si32(_loc36_,_temp_174);
                                                               si32(_loc42_,_loc14_ - 184);
                                                               _loc1_ += -5;
                                                               _loc49_ = 0;
                                                               _loc2_ = lf64(_loc14_ - 184);
                                                               _loc38_ = _loc49_;
                                                               if(_loc1_ <= _loc2_)
                                                               {
                                                                  var _temp_175:* = -_loc2_;
                                                                  _loc49_ = 0;
                                                                  _loc34_ = _loc45_;
                                                                  _loc35_ = _loc49_;
                                                                  if(_loc1_ >= _temp_175)
                                                                  {
                                                                     break;
                                                                  }
                                                                  break loop38;
                                                               }
                                                               break loop39;
                                                            }
                                                            if(_loc19_ != 0)
                                                            {
                                                               _loc29_ = _loc14_ - 112;
                                                               var _temp_177:* = _loc29_ | 4;
                                                               si32(_loc36_,_temp_177);
                                                               si32(_loc42_,_loc14_ - 112);
                                                               _loc29_ = _loc38_ << 3;
                                                               _loc29_ = _loc29_ + wdnative_nternal.___tens_D2A;
                                                               var _temp_181:* = lf64(_loc29_ - 8);
                                                               _loc24_ = (_loc21_ = _loc22_ * 0.5) / _temp_181 - lf64(_loc14_ - 112);
                                                               _loc17_ = _loc30_ + 5;
                                                               _loc36_ = 1;
                                                               while(true)
                                                               {
                                                                  _loc29_ = _loc14_ - 120;
                                                                  _loc29_ = _loc29_ | 4;
                                                                  si32(_loc34_,_loc29_);
                                                                  si32(_loc35_,_loc14_ - 120);
                                                                  _loc21_ = lf64(_loc14_ - 120);
                                                                  _loc48_ = _loc20_ = _loc21_ / _loc22_;
                                                                  _loc47_ = _loc48_ + 48;
                                                                  si8(_loc47_,_loc17_ - 1);
                                                                  _loc20_ = _loc48_;
                                                                  _loc20_ = _loc20_ * _loc22_;
                                                                  _loc3_ = _loc21_ - _loc20_;
                                                                  _loc34_ = _loc45_;
                                                                  if(_loc3_ < _loc24_)
                                                                  {
                                                                     break loop37;
                                                                  }
                                                                  _loc21_ = _loc22_ - _loc3_;
                                                                  if(_loc21_ < _loc24_)
                                                                  {
                                                                     break loop36;
                                                                  }
                                                                  if(_loc36_ >= _loc38_)
                                                                  {
                                                                     break loop40;
                                                                  }
                                                                  _loc21_ = _loc3_ * 10;
                                                                  sf64(_loc21_,_loc14_ - 128);
                                                                  _loc36_ += 1;
                                                                  _loc17_ += 1;
                                                                  _loc24_ *= 10;
                                                                  _loc29_ = _loc14_ - 128;
                                                                  _loc29_ = _loc29_ | 4;
                                                                  _loc34_ = li32(_loc29_);
                                                                  _loc35_ = li32(_loc14_ - 128);
                                                               }
                                                               break loop36;
                                                            }
                                                            _loc38_ += -1;
                                                            var _temp_193:* = _loc38_ << 3;
                                                            _loc29_ = wdnative_nternal.___tens_D2A + _temp_193;
                                                            _loc4_ = lf64(_loc29_);
                                                            _loc17_ = _loc30_ + 5;
                                                            while(true)
                                                            {
                                                               _loc29_ = _loc14_ - 136;
                                                               _loc29_ = _loc29_ | 4;
                                                               si32(_loc34_,_loc29_);
                                                               si32(_loc35_,_loc14_ - 136);
                                                               _loc7_ = lf64(_loc14_ - 136);
                                                               _loc40_ = _loc21_ = _loc7_ / _loc22_;
                                                               if(_loc40_ != 0)
                                                               {
                                                                  _loc21_ = _loc40_;
                                                                  var _temp_200:* = _loc21_ * _loc22_;
                                                                  _loc21_ = _loc7_ - _temp_200;
                                                                  sf64(_loc21_,_loc14_ - 144);
                                                                  _loc29_ = _loc14_ - 144;
                                                                  _loc29_ = _loc29_ | 4;
                                                                  _loc34_ = li32(_loc29_);
                                                                  _loc35_ = li32(_loc14_ - 144);
                                                               }
                                                               _loc29_ = _loc40_ + 48;
                                                               si8(_loc29_,_loc17_ - 1);
                                                               if(_loc38_ == 0)
                                                               {
                                                                  break;
                                                               }
                                                               _loc29_ = _loc14_ - 152;
                                                               var _temp_206:* = _loc29_ | 4;
                                                               si32(_loc34_,_temp_206);
                                                               si32(_loc35_,_loc14_ - 152);
                                                               _loc21_ = lf64(_loc14_ - 152);
                                                               _loc21_ = _loc21_ * 10;
                                                               sf64(_loc21_,_loc14_ - 160);
                                                               _loc38_ += -1;
                                                               _loc17_ += 1;
                                                               _loc29_ = _loc14_ - 160;
                                                               _loc29_ = _loc29_ | 4;
                                                               _loc34_ = li32(_loc29_);
                                                               _loc35_ = li32(_loc14_ - 160);
                                                            }
                                                            _loc29_ = _loc14_ - 168;
                                                            var _temp_212:* = _loc29_ | 4;
                                                            si32(_loc36_,_temp_212);
                                                            _loc29_ = _loc14_ - 176;
                                                            var _temp_214:* = _loc29_ | 4;
                                                            si32(_loc34_,_temp_214);
                                                            si32(_loc42_,_loc14_ - 168);
                                                            si32(_loc35_,_loc14_ - 176);
                                                            _loc21_ = lf64(_loc14_ - 168);
                                                            _loc2_ = _loc21_ * _loc4_;
                                                            _loc3_ = _loc22_ * 0.5;
                                                            var _temp_217:* = _loc2_ + _loc3_;
                                                            if((_loc22_ = lf64(_loc14_ - 176)) <= _temp_217)
                                                            {
                                                               var _temp_218:* = _loc3_ - _loc2_;
                                                               _loc34_ = _loc8_;
                                                               if(_loc22_ >= _temp_218)
                                                               {
                                                                  break;
                                                               }
                                                               break loop35;
                                                            }
                                                            break loop36;
                                                         }
                                                      }
                                                   }
                                                }
                                                if(_loc27_ >= 0)
                                                {
                                                   if(_loc46_ <= 14)
                                                   {
                                                      var _temp_219:* = _loc46_ << 3;
                                                      _loc29_ = wdnative_nternal.___tens_D2A + _temp_219;
                                                      _loc6_ = lf64(_loc29_);
                                                      if(_loc39_ <= -1)
                                                      {
                                                         if(_loc33_ < 1)
                                                         {
                                                            _loc49_ = 0;
                                                            _loc34_ = _loc45_;
                                                            _loc35_ = _loc49_;
                                                            if(_loc33_ >= 0)
                                                            {
                                                               _loc29_ = _loc14_ - 208;
                                                               var _temp_222:* = _loc29_ | 4;
                                                               si32(_loc15_,_temp_222);
                                                               si32(_loc18_,_loc14_ - 208);
                                                               _loc21_ = _loc6_ * 5;
                                                               _loc49_ = 0;
                                                               _loc20_ = lf64(_loc14_ - 208);
                                                               _loc34_ = _loc45_;
                                                               _loc35_ = _loc49_;
                                                               _loc8_ = _loc46_;
                                                               _loc38_ = _loc49_;
                                                               if(!(_loc20_ > _loc21_ | _loc20_ != _loc20_ | _loc21_ != _loc21_))
                                                               {
                                                                  break loop38;
                                                               }
                                                               break;
                                                            }
                                                            break loop38;
                                                         }
                                                      }
                                                      _loc49_ = _loc33_ + -1;
                                                      _loc17_ = _loc30_ + 5;
                                                      while(true)
                                                      {
                                                         _loc29_ = _loc14_ - 192;
                                                         _loc29_ = _loc29_ | 4;
                                                         si32(_loc15_,_loc29_);
                                                         si32(_loc18_,_loc14_ - 192);
                                                         _loc21_ = lf64(_loc14_ - 192);
                                                         _loc35_ = _loc20_ = _loc21_ / _loc6_;
                                                         _loc48_ = _loc35_ + 48;
                                                         si8(_loc48_,_loc17_ - 1);
                                                         _loc20_ = _loc35_;
                                                         _loc20_ = _loc20_ * _loc6_;
                                                         _loc5_ = _loc21_ - _loc20_;
                                                         _loc8_ = _loc46_;
                                                         _loc34_ = _loc45_;
                                                         if(_loc5_ == 0)
                                                         {
                                                            break loop37;
                                                         }
                                                         if(_loc49_ == 0)
                                                         {
                                                            _loc8_ = _loc46_;
                                                            if(_loc31_ != 1)
                                                            {
                                                               _loc8_ = _loc46_;
                                                               _loc34_ = _loc45_;
                                                               if(_loc31_ == 0)
                                                               {
                                                                  _loc22_ = _loc5_ + _loc5_;
                                                                  _loc8_ = _loc46_;
                                                                  if(_loc22_ <= _loc6_)
                                                                  {
                                                                     _loc34_ = _loc46_;
                                                                     if(_loc22_ != _loc6_)
                                                                     {
                                                                        break loop35;
                                                                     }
                                                                     var _temp_232:* = _loc35_ & 1;
                                                                     _loc34_ = _loc46_;
                                                                     _loc8_ = _loc46_;
                                                                     if(_temp_232 != 0)
                                                                     {
                                                                        break loop36;
                                                                     }
                                                                     break loop35;
                                                                  }
                                                                  break loop36;
                                                               }
                                                               break loop37;
                                                            }
                                                            break loop36;
                                                         }
                                                         _loc21_ = _loc5_ * 10;
                                                         sf64(_loc21_,_loc14_ - 200);
                                                         _loc49_ += -1;
                                                         _loc17_ += 1;
                                                         _loc29_ = _loc14_ - 200;
                                                         _loc29_ = _loc29_ | 4;
                                                         _loc15_ = li32(_loc29_);
                                                         _loc18_ = li32(_loc14_ - 200);
                                                      }
                                                      break loop37;
                                                   }
                                                }
                                                _loc49_ = 0;
                                                _loc35_ = _loc13_;
                                                _loc17_ = _loc28_;
                                                if(_loc19_ != 0)
                                                {
                                                   if(_loc32_ <= 1)
                                                   {
                                                      var _temp_233:* = int(53 - _loc37_);
                                                      var _temp_234:* = int(_loc27_ - _temp_233);
                                                      _loc49_ = _loc27_ + 1075;
                                                      if(_temp_234 >= -1074)
                                                      {
                                                         _loc49_ = 54 - _loc37_;
                                                      }
                                                      _loc27_ = _loc13_;
                                                      _loc34_ = _loc28_;
                                                      _loc35_ = _loc13_;
                                                   }
                                                   else
                                                   {
                                                      _loc35_ = _loc33_ + -1;
                                                      if(_loc13_ >= _loc35_)
                                                      {
                                                         _loc27_ = _loc13_ - _loc35_;
                                                         _loc35_ = _loc13_;
                                                      }
                                                      else
                                                      {
                                                         _loc29_ = _loc9_ - _loc13_;
                                                         _loc9_ = _loc29_ + _loc35_;
                                                         _loc27_ = 0;
                                                      }
                                                      _loc29_ = _loc33_ >> 31;
                                                      _loc29_ = _loc29_ & _loc33_;
                                                      _loc34_ = _loc28_ - _loc29_;
                                                      _loc49_ = _loc33_;
                                                      if(_loc33_ <= -1)
                                                      {
                                                         _loc49_ = 0;
                                                      }
                                                   }
                                                   _loc12_ = _loc49_ + _loc12_;
                                                   _loc17_ = _loc49_ + _loc28_;
                                                   _loc49_ = li32(wdnative_nternal._freelist + 4);
                                                   if(_loc49_ != 0)
                                                   {
                                                      _loc29_ = li32(_loc49_);
                                                      si32(_loc29_,wdnative_nternal._freelist + 4);
                                                   }
                                                   else
                                                   {
                                                      _loc49_ = li32(wdnative_nternal._pmem_next);
                                                      _loc29_ = _loc49_ - wdnative_nternal._private_mem;
                                                      _loc29_ = _loc29_ >> 3;
                                                      _loc29_ = _loc29_ + 4;
                                                      if((uint(_loc29_)) <= 288)
                                                      {
                                                         _loc29_ = _loc49_ + 32;
                                                         si32(_loc29_,wdnative_nternal._pmem_next);
                                                      }
                                                      else
                                                      {
                                                         _loc10_ -= 16;
                                                         si32(32,_loc10_);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative.F_malloc();
                                                         _loc10_ += 16;
                                                         _loc49_ = wdnative.eax;
                                                      }
                                                      si32(1,_loc49_ + 4);
                                                      si32(2,_loc49_ + 8);
                                                   }
                                                   si32(0,_loc49_ + 12);
                                                   si32(1,_loc49_ + 20);
                                                   si32(1,_loc49_ + 16);
                                                   _loc13_ = _loc27_;
                                                   _loc28_ = _loc34_;
                                                }
                                                if(_loc28_ >= 1)
                                                {
                                                   if(_loc12_ >= 1)
                                                   {
                                                      _loc34_ = _loc12_;
                                                      if(_loc12_ > _loc28_)
                                                      {
                                                         _loc34_ = _loc28_;
                                                      }
                                                      _loc12_ -= _loc34_;
                                                      _loc28_ -= _loc34_;
                                                      _loc17_ -= _loc34_;
                                                   }
                                                }
                                                _loc34_ = _loc45_;
                                                if(_loc35_ >= 1)
                                                {
                                                   if(_loc19_ != 0)
                                                   {
                                                      _loc34_ = _loc45_;
                                                      if(_loc13_ >= 1)
                                                      {
                                                         _loc10_ -= 16;
                                                         si32(_loc13_,_loc10_ + 4);
                                                         si32(_loc49_,_loc10_);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative_nternal.F___pow5mult_D2A();
                                                         _loc10_ += 16;
                                                         _loc49_ = wdnative.eax;
                                                         _loc10_ -= 16;
                                                         si32(_loc45_,_loc10_ + 4);
                                                         si32(_loc49_,_loc10_);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative_nternal.F___mult_D2A();
                                                         _loc10_ += 16;
                                                         _loc34_ = wdnative.eax;
                                                         if(_loc45_ != 0)
                                                         {
                                                            _loc27_ = li32(_loc45_ + 4);
                                                            if(_loc27_ >= 10)
                                                            {
                                                               _loc10_ -= 16;
                                                               si32(_loc45_,_loc10_);
                                                               wdnative.ESP = _loc10_;
                                                               wdnative_nternal.F_idalloc();
                                                               _loc10_ += 16;
                                                            }
                                                            else
                                                            {
                                                               var _temp_249:* = _loc27_ << 2;
                                                               _loc29_ = wdnative_nternal._freelist + _temp_249;
                                                               _loc48_ = li32(_loc29_);
                                                               si32(_loc48_,_loc45_);
                                                               si32(_loc45_,_loc29_);
                                                            }
                                                         }
                                                      }
                                                      if(_loc35_ != _loc13_)
                                                      {
                                                         _loc10_ -= 16;
                                                         si32(_loc34_,_loc10_);
                                                         _loc29_ = _loc35_ - _loc13_;
                                                         si32(_loc29_,_loc10_ + 4);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative_nternal.F___pow5mult_D2A();
                                                         _loc10_ += 16;
                                                         _loc34_ = wdnative.eax;
                                                      }
                                                   }
                                                   else
                                                   {
                                                      _loc10_ -= 16;
                                                      si32(_loc35_,_loc10_ + 4);
                                                      si32(_loc45_,_loc10_);
                                                      wdnative.ESP = _loc10_;
                                                      wdnative_nternal.F___pow5mult_D2A();
                                                      _loc10_ += 16;
                                                      _loc34_ = wdnative.eax;
                                                   }
                                                }
                                                _loc35_ = li32(wdnative_nternal._freelist + 4);
                                                if(_loc35_ != 0)
                                                {
                                                   _loc29_ = li32(_loc35_);
                                                   si32(_loc29_,wdnative_nternal._freelist + 4);
                                                }
                                                else
                                                {
                                                   _loc35_ = li32(wdnative_nternal._pmem_next);
                                                   _loc29_ = _loc35_ - wdnative_nternal._private_mem;
                                                   _loc29_ = _loc29_ >> 3;
                                                   _loc29_ = _loc29_ + 4;
                                                   if((uint(_loc29_)) <= 288)
                                                   {
                                                      _loc29_ = _loc35_ + 32;
                                                      si32(_loc29_,wdnative_nternal._pmem_next);
                                                   }
                                                   else
                                                   {
                                                      _loc10_ -= 16;
                                                      si32(32,_loc10_);
                                                      wdnative.ESP = _loc10_;
                                                      wdnative.F_malloc();
                                                      _loc10_ += 16;
                                                      _loc35_ = wdnative.eax;
                                                   }
                                                   si32(1,_loc35_ + 4);
                                                   si32(2,_loc35_ + 8);
                                                }
                                                si32(0,_loc35_ + 12);
                                                _loc18_ = 1;
                                                si32(_loc18_,_loc35_ + 20);
                                                si32(_loc18_,_loc35_ + 16);
                                                if(_loc9_ >= 1)
                                                {
                                                   _loc10_ -= 16;
                                                   si32(_loc9_,_loc10_ + 4);
                                                   si32(_loc35_,_loc10_);
                                                   wdnative.ESP = _loc10_;
                                                   wdnative_nternal.F___pow5mult_D2A();
                                                   _loc10_ += 16;
                                                   _loc35_ = wdnative.eax;
                                                }
                                                _loc45_ = _loc18_;
                                                if(_loc44_ <= -1073)
                                                {
                                                   _loc45_ = 0;
                                                }
                                                _loc44_ = _loc18_;
                                                if(_loc32_ >= 2)
                                                {
                                                   _loc44_ = 0;
                                                }
                                                _loc27_ = _loc18_;
                                                if(_loc37_ != _loc18_)
                                                {
                                                   _loc27_ = 0;
                                                }
                                                if(_loc9_ != 0)
                                                {
                                                   _loc29_ = li32(_loc35_ + 16);
                                                   _loc29_ = _loc29_ << 2;
                                                   _loc29_ = _loc29_ + _loc35_;
                                                   _loc8_ = li32(_loc29_ + 16);
                                                   _loc13_ = _loc8_ << 16;
                                                   if(uint(_loc8_) >= 65536)
                                                   {
                                                      _loc13_ = _loc8_;
                                                   }
                                                   _loc9_ = _loc13_ << 8;
                                                   if(uint(_loc13_) >= 16777216)
                                                   {
                                                      _loc9_ = _loc13_;
                                                   }
                                                   _loc37_ = _loc9_ << 4;
                                                   if(uint(_loc9_) >= 268435456)
                                                   {
                                                      _loc37_ = _loc9_;
                                                   }
                                                   _loc18_ = _loc37_ << 2;
                                                   if(uint(_loc37_) >= 1073741824)
                                                   {
                                                      _loc18_ = _loc37_;
                                                   }
                                                   _loc15_ = 16;
                                                   if(uint(_loc8_) >= 65536)
                                                   {
                                                      _loc15_ = 0;
                                                   }
                                                   _loc8_ = _loc15_ | 8;
                                                   if(uint(_loc13_) >= 16777216)
                                                   {
                                                      _loc8_ = _loc15_;
                                                   }
                                                   _loc13_ = _loc8_ | 4;
                                                   if(uint(_loc9_) >= 268435456)
                                                   {
                                                      _loc13_ = _loc8_;
                                                   }
                                                   _loc9_ = _loc13_ | 2;
                                                   if(uint(_loc37_) >= 1073741824)
                                                   {
                                                      _loc9_ = _loc13_;
                                                   }
                                                   while(true)
                                                   {
                                                      if(_loc18_ >= 0)
                                                      {
                                                         _loc9_ += 1;
                                                         var _temp_268:* = _loc18_ & 0x40000000;
                                                         _loc37_ = 32;
                                                         if(_temp_268 == 0)
                                                         {
                                                            break;
                                                         }
                                                      }
                                                      _loc37_ = _loc9_;
                                                      break;
                                                   }
                                                   _loc18_ = 32 - _loc37_;
                                                }
                                                _loc29_ = _loc44_ & _loc27_;
                                                _loc29_ = _loc29_ & _loc45_;
                                                _loc45_ = _loc29_ & 1;
                                                _loc44_ = _loc17_ + _loc45_;
                                                _loc37_ = _loc12_ + _loc45_;
                                                _loc29_ = _loc18_ + _loc37_;
                                                _loc27_ = _loc29_ & 0x1F;
                                                _loc17_ = 0;
                                                while(true)
                                                {
                                                   if(_loc27_ != 0)
                                                   {
                                                      _loc17_ = 32 - _loc27_;
                                                      if((uint(_loc17_)) >= 5)
                                                      {
                                                         _loc29_ = _loc17_ + -4;
                                                         _loc37_ = _loc29_ + _loc37_;
                                                         _loc28_ = _loc29_ + _loc28_;
                                                         _loc44_ = _loc29_ + _loc44_;
                                                         break;
                                                      }
                                                      if(uint(_loc17_) > 3)
                                                      {
                                                         break;
                                                      }
                                                   }
                                                   _loc29_ = _loc17_ + 28;
                                                   _loc37_ = _loc29_ + _loc37_;
                                                   _loc28_ = _loc29_ + _loc28_;
                                                   _loc44_ = _loc29_ + _loc44_;
                                                   break;
                                                }
                                                if(_loc44_ >= 1)
                                                {
                                                   _loc10_ -= 16;
                                                   si32(_loc44_,_loc10_ + 4);
                                                   si32(_loc34_,_loc10_);
                                                   wdnative.ESP = _loc10_;
                                                   wdnative_nternal.F___lshift_D2A();
                                                   _loc10_ += 16;
                                                   _loc34_ = wdnative.eax;
                                                }
                                                if(_loc37_ >= 1)
                                                {
                                                   _loc10_ -= 16;
                                                   si32(_loc37_,_loc10_ + 4);
                                                   si32(_loc35_,_loc10_);
                                                   wdnative.ESP = _loc10_;
                                                   wdnative_nternal.F___lshift_D2A();
                                                   _loc10_ += 16;
                                                   _loc35_ = wdnative.eax;
                                                }
                                                if(_loc16_ != 0)
                                                {
                                                   _loc37_ = li32(_loc35_ + 16);
                                                   _loc44_ = li32(_loc34_ + 16);
                                                   if(_loc44_ == _loc37_)
                                                   {
                                                      _loc48_ = _loc37_ << 2;
                                                      _loc29_ = _loc48_ + _loc34_;
                                                      _loc27_ = _loc29_ + 20;
                                                      _loc29_ = _loc48_ + _loc35_;
                                                      _loc17_ = _loc29_ + 16;
                                                      _loc16_ = _loc34_ + 20;
                                                      do
                                                      {
                                                         _loc44_ = li32(_loc17_);
                                                         _loc37_ = li32(_loc27_ - 4);
                                                         if(_loc37_ == _loc44_)
                                                         {
                                                            continue;
                                                         }
                                                         _loc17_ = -1;
                                                         if(uint(_loc37_) >= uint(_loc44_))
                                                         {
                                                            _loc17_ = 1;
                                                         }
                                                      }
                                                      while(_loc27_ += -4, _loc17_ += -4, uint(_loc27_) > uint(_loc16_));
                                                      addr1e05:
                                                      loop43:
                                                      while(true)
                                                      {
                                                         if(_loc33_ <= 0)
                                                         {
                                                            if(_loc32_ >= 3)
                                                            {
                                                               if(_loc33_ >= 0)
                                                               {
                                                                  _loc10_ -= 16;
                                                                  si32(5,_loc10_ + 4);
                                                                  si32(_loc35_,_loc10_);
                                                                  wdnative.ESP = _loc10_;
                                                                  wdnative_nternal.F___multadd_D2A();
                                                                  _loc10_ += 16;
                                                                  _loc35_ = wdnative.eax;
                                                                  _loc45_ = li32(_loc35_ + 16);
                                                                  _loc44_ = li32(_loc34_ + 16);
                                                                  if(_loc44_ == _loc45_)
                                                                  {
                                                                     _loc44_ = _loc34_ + 20;
                                                                     _loc32_ = _loc45_ << 2;
                                                                     while(true)
                                                                     {
                                                                        _loc29_ = _loc35_ + _loc32_;
                                                                        _loc45_ = li32(_loc29_ + 16);
                                                                        _loc29_ = _loc34_ + _loc32_;
                                                                        _loc37_ = li32(_loc29_ + 16);
                                                                        if(_loc37_ == _loc45_)
                                                                        {
                                                                           _loc32_ += -4;
                                                                           _loc29_ = _loc44_ + _loc32_;
                                                                           if((uint(_loc29_)) <= uint(_loc44_))
                                                                           {
                                                                              break loop38;
                                                                           }
                                                                           continue;
                                                                        }
                                                                        _loc44_ = -1;
                                                                        if(uint(_loc37_) >= uint(_loc45_))
                                                                        {
                                                                           _loc44_ = 1;
                                                                        }
                                                                     }
                                                                     break;
                                                                  }
                                                                  _loc44_ -= _loc45_;
                                                                  _loc8_ = _loc46_;
                                                                  _loc45_ = _loc34_;
                                                                  _loc38_ = _loc35_;
                                                                  if(_loc44_ <= 0)
                                                                  {
                                                                     break loop38;
                                                                  }
                                                                  break loop39;
                                                               }
                                                               break loop38;
                                                            }
                                                         }
                                                         if(_loc19_ == 0)
                                                         {
                                                            _loc10_ -= 16;
                                                            si32(_loc35_,_loc10_ + 4);
                                                            si32(_loc34_,_loc10_);
                                                            wdnative.ESP = _loc10_;
                                                            wdnative_nternal.F___quorem_D2A();
                                                            _loc10_ += 16;
                                                            _loc29_ = wdnative.eax;
                                                            _loc45_ = _loc29_ + 48;
                                                            si8(_loc45_,_loc26_);
                                                            _loc17_ = _loc26_ + 1;
                                                            _loc44_ = 0;
                                                            if(_loc33_ >= 2)
                                                            {
                                                               _loc44_ = _loc30_ + 5;
                                                               _loc37_ = _loc33_ + -1;
                                                               do
                                                               {
                                                                  _loc10_ -= 16;
                                                                  si32(10,_loc10_ + 4);
                                                                  si32(_loc34_,_loc10_);
                                                                  wdnative.ESP = _loc10_;
                                                                  wdnative_nternal.F___multadd_D2A();
                                                                  _loc10_ += 16;
                                                                  _loc34_ = wdnative.eax;
                                                                  _loc10_ -= 16;
                                                                  si32(_loc35_,_loc10_ + 4);
                                                                  si32(_loc34_,_loc10_);
                                                                  wdnative.ESP = _loc10_;
                                                                  wdnative_nternal.F___quorem_D2A();
                                                                  _loc10_ += 16;
                                                                  _loc29_ = wdnative.eax;
                                                                  _loc45_ = _loc29_ + 48;
                                                                  si8(_loc45_,_loc44_);
                                                                  _loc44_ += 1;
                                                               }
                                                               while(_loc37_ += -1, _loc37_ != 0);
                                                               _loc17_ = _loc26_ + _loc33_;
                                                               _loc44_ = 0;
                                                            }
                                                            addr29a6:
                                                            if(_loc31_ != 0)
                                                            {
                                                               if(_loc31_ == 2)
                                                               {
                                                                  addr2b2b:
                                                                  _loc45_ = _loc17_ + 1;
                                                                  while(true)
                                                                  {
                                                                     _loc17_ = _loc45_ + -1;
                                                                     _loc29_ = li8(_loc45_ - 2);
                                                                     _loc45_ = _loc17_;
                                                                     if(_loc29_ != 48)
                                                                     {
                                                                        break loop43;
                                                                     }
                                                                  }
                                                                  break;
                                                               }
                                                               _loc29_ = li32(_loc34_ + 16);
                                                               if(_loc29_ <= 1)
                                                               {
                                                                  _loc29_ = li32(_loc34_ + 20);
                                                                  if(_loc29_ == 0)
                                                                  {
                                                                     §§goto(addr2b2b);
                                                                  }
                                                               }
                                                            }
                                                            else
                                                            {
                                                               _loc10_ -= 16;
                                                               si32(1,_loc10_ + 4);
                                                               si32(_loc34_,_loc10_);
                                                               wdnative.ESP = _loc10_;
                                                               wdnative_nternal.F___lshift_D2A();
                                                               _loc10_ += 16;
                                                               _loc34_ = wdnative.eax;
                                                               _loc32_ = li32(_loc35_ + 16);
                                                               _loc37_ = li32(_loc34_ + 16);
                                                               if(_loc37_ == _loc32_)
                                                               {
                                                                  _loc48_ = _loc32_ << 2;
                                                                  _loc29_ = _loc48_ + _loc34_;
                                                                  _loc31_ = _loc29_ + 20;
                                                                  _loc29_ = _loc48_ + _loc35_;
                                                                  _loc33_ = _loc29_ + 16;
                                                                  _loc39_ = _loc34_ + 20;
                                                                  while(true)
                                                                  {
                                                                     _loc37_ = li32(_loc33_);
                                                                     loop44:
                                                                     while(true)
                                                                     {
                                                                        while(true)
                                                                        {
                                                                           _loc32_ = li32(_loc31_ - 4);
                                                                           if(_loc32_ != _loc37_)
                                                                           {
                                                                              _loc31_ = -1;
                                                                              if(uint(_loc32_) >= uint(_loc37_))
                                                                              {
                                                                                 _loc31_ = 1;
                                                                              }
                                                                              addr2ab2:
                                                                              if(_loc31_ > 0)
                                                                              {
                                                                                 break;
                                                                              }
                                                                              if(_loc31_ != 0)
                                                                              {
                                                                                 break loop44;
                                                                              }
                                                                           }
                                                                           else
                                                                           {
                                                                              _loc31_ += -4;
                                                                              _loc33_ += -4;
                                                                              if(uint(_loc31_) > uint(_loc39_))
                                                                              {
                                                                                 continue;
                                                                              }
                                                                           }
                                                                           _loc29_ = _loc45_ & 1;
                                                                           if(_loc29_ != 0)
                                                                           {
                                                                              break;
                                                                           }
                                                                           break loop44;
                                                                        }
                                                                        addr2ad3:
                                                                        while(true)
                                                                        {
                                                                           _loc45_ = _loc17_;
                                                                           _loc37_ = li8(_loc45_ - 1);
                                                                           if(_loc37_ != 57)
                                                                           {
                                                                              _loc29_ = _loc37_ + 1;
                                                                              si8(_loc29_,_loc45_ - 1);
                                                                              _loc17_ = _loc45_;
                                                                              break loop43;
                                                                           }
                                                                           _loc17_ = _loc45_ + -1;
                                                                           if(_loc26_ == _loc17_)
                                                                           {
                                                                              si8(49,_loc17_);
                                                                              _loc46_ += 1;
                                                                              _loc17_ = _loc45_;
                                                                              break loop43;
                                                                           }
                                                                        }
                                                                        break loop43;
                                                                     }
                                                                     §§goto(addr2b2a);
                                                                  }
                                                                  break;
                                                               }
                                                               _loc31_ = _loc37_ - _loc32_;
                                                               §§goto(addr2ab2);
                                                            }
                                                         }
                                                         else
                                                         {
                                                            if(_loc28_ >= 1)
                                                            {
                                                               _loc10_ -= 16;
                                                               si32(_loc28_,_loc10_ + 4);
                                                               si32(_loc49_,_loc10_);
                                                               wdnative.ESP = _loc10_;
                                                               wdnative_nternal.F___lshift_D2A();
                                                               _loc10_ += 16;
                                                               _loc49_ = wdnative.eax;
                                                            }
                                                            _loc39_ = _loc49_;
                                                            if(_loc45_ != 0)
                                                            {
                                                               while(true)
                                                               {
                                                                  _loc44_ = li32(_loc49_ + 4);
                                                                  if(_loc44_ >= 10)
                                                                  {
                                                                     _loc37_ = 1 << _loc44_;
                                                                     _loc29_ = _loc37_ << 2;
                                                                     _loc39_ = _loc29_ + 27;
                                                                  }
                                                                  else
                                                                  {
                                                                     var _temp_318:* = _loc44_ << 2;
                                                                     _loc37_ = wdnative_nternal._freelist + _temp_318;
                                                                     _loc45_ = li32(_loc37_);
                                                                     if(_loc45_ != 0)
                                                                     {
                                                                        _loc29_ = li32(_loc45_);
                                                                        si32(_loc29_,_loc37_);
                                                                        addr20d2:
                                                                        si32(0,_loc45_ + 16);
                                                                        si32(0,_loc45_ + 12);
                                                                        _loc29_ = li32(_loc49_ + 16);
                                                                        _loc10_ -= 16;
                                                                        _loc48_ = _loc49_ + 12;
                                                                        si32(_loc48_,_loc10_ + 4);
                                                                        _loc48_ = _loc45_ + 12;
                                                                        si32(_loc48_,_loc10_);
                                                                        _loc29_ <<= 2;
                                                                        _loc29_ = _loc29_ + 8;
                                                                        si32(_loc29_,_loc10_ + 8);
                                                                        wdnative.ESP = _loc10_;
                                                                        wdnative.Fmemcpy();
                                                                        _loc10_ += 16;
                                                                        _loc10_ = _loc10_ - 16;
                                                                        si32(1,_loc10_ + 4);
                                                                        si32(_loc45_,_loc10_);
                                                                        wdnative.ESP = _loc10_;
                                                                        wdnative_nternal.F___lshift_D2A();
                                                                        _loc10_ += 16;
                                                                        _loc39_ = wdnative.eax;
                                                                        addr216d:
                                                                        _loc37_ = _loc33_ + -1;
                                                                        _loc17_ = _loc30_ + 5;
                                                                        _loc44_ = _loc49_;
                                                                        _loc49_ = _loc39_;
                                                                        loop15:
                                                                        while(true)
                                                                        {
                                                                           _loc10_ -= 16;
                                                                           si32(_loc35_,_loc10_ + 4);
                                                                           si32(_loc34_,_loc10_);
                                                                           wdnative.ESP = _loc10_;
                                                                           wdnative_nternal.F___quorem_D2A();
                                                                           _loc10_ += 16;
                                                                           _loc33_ = wdnative.eax;
                                                                           _loc30_ = li32(_loc44_ + 16);
                                                                           _loc39_ = li32(_loc34_ + 16);
                                                                           _loc45_ = _loc33_ + 48;
                                                                           if(_loc39_ != _loc30_)
                                                                           {
                                                                              _loc39_ -= _loc30_;
                                                                           }
                                                                           else
                                                                           {
                                                                              _loc29_ = _loc30_ << 2;
                                                                              _loc27_ = _loc34_ + 20;
                                                                              _loc19_ = _loc27_ + _loc29_;
                                                                              _loc29_ = _loc44_ + _loc29_;
                                                                              _loc11_ = _loc29_ + 16;
                                                                              while(true)
                                                                              {
                                                                                 _loc30_ = li32(_loc11_);
                                                                                 _loc28_ = li32(_loc19_ - 4);
                                                                                 if(_loc28_ != _loc30_)
                                                                                 {
                                                                                    break;
                                                                                 }
                                                                                 _loc19_ += -4;
                                                                                 _loc11_ += -4;
                                                                                 _loc39_ = 0;
                                                                                 if(uint(_loc19_) > uint(_loc27_))
                                                                                 {
                                                                                    continue;
                                                                                 }
                                                                              }
                                                                              _loc39_ = -1;
                                                                              if(uint(_loc28_) >= uint(_loc30_))
                                                                              {
                                                                                 _loc39_ = 1;
                                                                              }
                                                                           }
                                                                           _loc10_ -= 16;
                                                                           si32(_loc49_,_loc10_ + 4);
                                                                           si32(_loc35_,_loc10_);
                                                                           wdnative.ESP = _loc10_;
                                                                           wdnative_nternal.F___diff_D2A();
                                                                           _loc10_ += 16;
                                                                           _loc30_ = wdnative.eax;
                                                                           _loc29_ = li32(_loc30_ + 12);
                                                                           _loc28_ = 1;
                                                                           loop47:
                                                                           while(true)
                                                                           {
                                                                              while(true)
                                                                              {
                                                                                 if(_loc29_ == 0)
                                                                                 {
                                                                                    _loc28_ = li32(_loc30_ + 16);
                                                                                    _loc19_ = li32(_loc34_ + 16);
                                                                                    if(_loc19_ == _loc28_)
                                                                                    {
                                                                                       _loc29_ = _loc28_ << 2;
                                                                                       _loc16_ = _loc34_ + 20;
                                                                                       _loc19_ = _loc16_ + _loc29_;
                                                                                       _loc29_ = _loc30_ + _loc29_;
                                                                                       _loc12_ = _loc29_ + 16;
                                                                                       while(true)
                                                                                       {
                                                                                          _loc11_ = li32(_loc12_);
                                                                                          _loc27_ = li32(_loc19_ - 4);
                                                                                          if(_loc27_ != _loc11_)
                                                                                          {
                                                                                             break;
                                                                                          }
                                                                                          _loc19_ += -4;
                                                                                          _loc12_ += -4;
                                                                                          _loc28_ = 0;
                                                                                          if(uint(_loc19_) > uint(_loc16_))
                                                                                          {
                                                                                             continue;
                                                                                          }
                                                                                       }
                                                                                       _loc28_ = -1;
                                                                                       if(uint(_loc27_) >= uint(_loc11_))
                                                                                       {
                                                                                          _loc28_ = 1;
                                                                                       }
                                                                                       break;
                                                                                    }
                                                                                    _loc28_ = _loc19_ - _loc28_;
                                                                                 }
                                                                                 if(_loc30_ != 0)
                                                                                 {
                                                                                    break;
                                                                                 }
                                                                                 break loop47;
                                                                              }
                                                                              _loc19_ = li32(_loc30_ + 4);
                                                                              if(_loc19_ >= 10)
                                                                              {
                                                                                 _loc10_ -= 16;
                                                                                 si32(_loc30_,_loc10_);
                                                                                 wdnative.ESP = _loc10_;
                                                                                 wdnative_nternal.F_idalloc();
                                                                                 _loc10_ += 16;
                                                                                 break;
                                                                              }
                                                                              var _temp_382:* = _loc19_ << 2;
                                                                              _loc48_ = wdnative_nternal._freelist + _temp_382;
                                                                              _loc29_ = li32(_loc48_);
                                                                              si32(_loc29_,_loc30_);
                                                                              si32(_loc30_,_loc48_);
                                                                              break;
                                                                           }
                                                                           loop49:
                                                                           while(true)
                                                                           {
                                                                              _loc29_ = _loc28_ | _loc32_;
                                                                              if(_loc29_ == 0)
                                                                              {
                                                                                 _loc29_ = li32(_loc14_ - 8);
                                                                                 _loc29_ = _loc29_ & 1;
                                                                                 _loc29_ = _loc29_ | _loc31_;
                                                                                 if(_loc29_ == 0)
                                                                                 {
                                                                                    _loc37_ = _loc17_ + -1;
                                                                                    if(_loc45_ != 57)
                                                                                    {
                                                                                       if(_loc39_ > 0)
                                                                                       {
                                                                                          _loc45_ = _loc33_ + 49;
                                                                                       }
                                                                                       si8(_loc45_,_loc17_ - 1);
                                                                                       break loop43;
                                                                                    }
                                                                                    break;
                                                                                 }
                                                                              }
                                                                              if(_loc39_ >= 0)
                                                                              {
                                                                                 _loc29_ = _loc39_ | _loc32_;
                                                                                 if(_loc29_ == 0)
                                                                                 {
                                                                                    _loc29_ = li8(_loc14_ - 8);
                                                                                    _loc29_ = _loc29_ & 1;
                                                                                    if(_loc29_ == 0)
                                                                                    {
                                                                                       addr2423:
                                                                                       _loc37_ = _loc17_ + -1;
                                                                                       loop50:
                                                                                       while(true)
                                                                                       {
                                                                                          if(_loc31_ != 0)
                                                                                          {
                                                                                             _loc29_ = li32(_loc34_ + 16);
                                                                                             if(_loc29_ <= 1)
                                                                                             {
                                                                                                _loc29_ = li32(_loc34_ + 20);
                                                                                                if(_loc29_ == 0)
                                                                                                {
                                                                                                   addr269f:
                                                                                                   if(_loc28_ > 0)
                                                                                                   {
                                                                                                      _loc10_ -= 16;
                                                                                                      si32(1,_loc10_ + 4);
                                                                                                      si32(_loc34_,_loc10_);
                                                                                                      wdnative.ESP = _loc10_;
                                                                                                      wdnative_nternal.F___lshift_D2A();
                                                                                                      _loc10_ += 16;
                                                                                                      _loc34_ = wdnative.eax;
                                                                                                      _loc31_ = li32(_loc35_ + 16);
                                                                                                      _loc32_ = li32(_loc34_ + 16);
                                                                                                      if(_loc32_ == _loc31_)
                                                                                                      {
                                                                                                         _loc29_ = _loc31_ << 2;
                                                                                                         _loc48_ = _loc29_ + _loc34_;
                                                                                                         _loc30_ = _loc48_ + 20;
                                                                                                         _loc29_ += _loc35_;
                                                                                                         _loc28_ = _loc29_ + 16;
                                                                                                         _loc39_ = _loc34_ + 20;
                                                                                                         while(true)
                                                                                                         {
                                                                                                            _loc32_ = li32(_loc28_);
                                                                                                            loop51:
                                                                                                            while(true)
                                                                                                            {
                                                                                                               while(true)
                                                                                                               {
                                                                                                                  _loc31_ = li32(_loc30_ - 4);
                                                                                                                  if(_loc31_ != _loc32_)
                                                                                                                  {
                                                                                                                     _loc39_ = -1;
                                                                                                                     if(uint(_loc31_) >= uint(_loc32_))
                                                                                                                     {
                                                                                                                        _loc39_ = 1;
                                                                                                                     }
                                                                                                                     addr277e:
                                                                                                                     if(_loc39_ > 0)
                                                                                                                     {
                                                                                                                        break;
                                                                                                                     }
                                                                                                                     if(_loc39_ != 0)
                                                                                                                     {
                                                                                                                        break loop51;
                                                                                                                     }
                                                                                                                  }
                                                                                                                  else
                                                                                                                  {
                                                                                                                     _loc30_ += -4;
                                                                                                                     _loc28_ += -4;
                                                                                                                     if(uint(_loc30_) > uint(_loc39_))
                                                                                                                     {
                                                                                                                        continue;
                                                                                                                     }
                                                                                                                  }
                                                                                                                  _loc29_ = _loc45_ & 1;
                                                                                                                  if(_loc29_ != 0)
                                                                                                                  {
                                                                                                                     break;
                                                                                                                  }
                                                                                                                  break loop51;
                                                                                                               }
                                                                                                               _loc45_ = _loc33_ + 49;
                                                                                                               if(_loc45_ != 58)
                                                                                                               {
                                                                                                                  break;
                                                                                                               }
                                                                                                               break loop49;
                                                                                                            }
                                                                                                            break loop50;
                                                                                                         }
                                                                                                         break loop43;
                                                                                                      }
                                                                                                      _loc39_ = _loc32_ - _loc31_;
                                                                                                      §§goto(addr277e);
                                                                                                   }
                                                                                                   break loop51;
                                                                                                }
                                                                                             }
                                                                                             if(_loc31_ == 2)
                                                                                             {
                                                                                                break;
                                                                                             }
                                                                                             _loc32_ = li32(_loc49_ + 16);
                                                                                             _loc31_ = li32(_loc35_ + 16);
                                                                                             if(_loc31_ == _loc32_)
                                                                                             {
                                                                                                _loc29_ = _loc32_ << 2;
                                                                                                _loc48_ = _loc29_ + _loc35_;
                                                                                                _loc33_ = _loc48_ + 20;
                                                                                                _loc29_ += _loc49_;
                                                                                                _loc30_ = _loc29_ + 16;
                                                                                                _loc39_ = _loc35_ + 20;
                                                                                                do
                                                                                                {
                                                                                                   _loc32_ = li32(_loc30_);
                                                                                                   _loc31_ = li32(_loc33_ - 4);
                                                                                                   if(_loc31_ == _loc32_)
                                                                                                   {
                                                                                                      continue;
                                                                                                   }
                                                                                                   _loc33_ = -1;
                                                                                                   if(uint(_loc31_) >= uint(_loc32_))
                                                                                                   {
                                                                                                      _loc33_ = 1;
                                                                                                   }
                                                                                                }
                                                                                                while(_loc33_ += -4, _loc30_ += -4, uint(_loc33_) > uint(_loc39_));
                                                                                                addr268a:
                                                                                                _loc45_ += 1;
                                                                                                if(_loc45_ != 58)
                                                                                                {
                                                                                                   break;
                                                                                                }
                                                                                                break loop49;
                                                                                             }
                                                                                             _loc33_ = _loc31_ - _loc32_;
                                                                                             if(_loc33_ >= 1)
                                                                                             {
                                                                                                _loc32_ = _loc35_ + 20;
                                                                                                _loc33_ = _loc49_;
                                                                                                _loc39_ = _loc44_;
                                                                                                loop21:
                                                                                                do
                                                                                                {
                                                                                                   _loc37_ = _loc17_;
                                                                                                   si8(_loc45_,_loc37_ - 1);
                                                                                                   _loc10_ -= 16;
                                                                                                   si32(10,_loc10_ + 4);
                                                                                                   si32(_loc33_,_loc10_);
                                                                                                   wdnative.ESP = _loc10_;
                                                                                                   wdnative_nternal.F___multadd_D2A();
                                                                                                   _loc10_ += 16;
                                                                                                   _loc49_ = wdnative.eax;
                                                                                                   _loc10_ -= 16;
                                                                                                   si32(10,_loc10_ + 4);
                                                                                                   si32(_loc34_,_loc10_);
                                                                                                   wdnative.ESP = _loc10_;
                                                                                                   wdnative_nternal.F___multadd_D2A();
                                                                                                   _loc10_ += 16;
                                                                                                   _loc34_ = wdnative.eax;
                                                                                                   _loc10_ -= 16;
                                                                                                   si32(_loc34_,_loc10_);
                                                                                                   _loc44_ = _loc49_;
                                                                                                   if(_loc39_ != _loc33_)
                                                                                                   {
                                                                                                      _loc44_ = _loc39_;
                                                                                                   }
                                                                                                   si32(_loc35_,_loc10_ + 4);
                                                                                                   wdnative.ESP = _loc10_;
                                                                                                   wdnative_nternal.F___quorem_D2A();
                                                                                                   _loc10_ += 16;
                                                                                                   _loc29_ = wdnative.eax;
                                                                                                   _loc31_ = li32(_loc49_ + 16);
                                                                                                   _loc33_ = li32(_loc35_ + 16);
                                                                                                   _loc45_ = _loc29_ + 48;
                                                                                                   if(_loc33_ == _loc31_)
                                                                                                   {
                                                                                                      _loc29_ = _loc31_ << 2;
                                                                                                      _loc31_ = _loc32_ + _loc29_;
                                                                                                      _loc29_ = _loc49_ + _loc29_;
                                                                                                      _loc30_ = _loc29_ + 16;
                                                                                                      while(true)
                                                                                                      {
                                                                                                         _loc39_ = li32(_loc30_);
                                                                                                         _loc33_ = li32(_loc31_ - 4);
                                                                                                         if(_loc33_ != _loc39_)
                                                                                                         {
                                                                                                            break;
                                                                                                         }
                                                                                                         _loc31_ += -4;
                                                                                                         _loc30_ += -4;
                                                                                                         if(uint(_loc31_) <= uint(_loc32_))
                                                                                                         {
                                                                                                            break loop21;
                                                                                                         }
                                                                                                      }
                                                                                                      _loc31_ = -1;
                                                                                                      if(uint(_loc33_) >= uint(_loc39_))
                                                                                                      {
                                                                                                         _loc31_ = 1;
                                                                                                      }
                                                                                                   }
                                                                                                   else
                                                                                                   {
                                                                                                      _loc31_ = _loc33_ - _loc31_;
                                                                                                   }
                                                                                                   _loc17_ = _loc37_ + 1;
                                                                                                   _loc33_ = _loc49_;
                                                                                                   _loc39_ = _loc44_;
                                                                                                }
                                                                                                while(_loc31_ > 0);
                                                                                             }
                                                                                             §§goto(addr268a);
                                                                                          }
                                                                                          §§goto(addr269f);
                                                                                       }
                                                                                       si8(_loc45_,_loc37_);
                                                                                       _loc17_ = _loc37_ + 1;
                                                                                       break loop43;
                                                                                    }
                                                                                 }
                                                                                 if(_loc28_ >= 1)
                                                                                 {
                                                                                    if(_loc31_ != 2)
                                                                                    {
                                                                                       _loc37_ = _loc17_ + -1;
                                                                                       if(_loc45_ == 57)
                                                                                       {
                                                                                          break;
                                                                                       }
                                                                                       _loc29_ = _loc45_ + 1;
                                                                                       si8(_loc29_,_loc17_ - 1);
                                                                                       break loop43;
                                                                                    }
                                                                                 }
                                                                                 si8(_loc45_,_loc17_ - 1);
                                                                                 if(_loc37_ != 0)
                                                                                 {
                                                                                    _loc10_ -= 16;
                                                                                    si32(10,_loc10_ + 4);
                                                                                    si32(_loc34_,_loc10_);
                                                                                    wdnative.ESP = _loc10_;
                                                                                    wdnative_nternal.F___multadd_D2A();
                                                                                    _loc10_ += 16;
                                                                                    _loc34_ = wdnative.eax;
                                                                                    if(_loc44_ == _loc49_)
                                                                                    {
                                                                                       _loc10_ -= 16;
                                                                                       si32(10,_loc10_ + 4);
                                                                                       si32(_loc49_,_loc10_);
                                                                                       wdnative.ESP = _loc10_;
                                                                                       wdnative_nternal.F___multadd_D2A();
                                                                                       _loc10_ += 16;
                                                                                       _loc49_ = _loc44_ = wdnative.eax;
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                       _loc10_ -= 16;
                                                                                       si32(10,_loc10_ + 4);
                                                                                       si32(_loc44_,_loc10_);
                                                                                       wdnative.ESP = _loc10_;
                                                                                       wdnative_nternal.F___multadd_D2A();
                                                                                       _loc10_ += 16;
                                                                                       _loc44_ = wdnative.eax;
                                                                                       _loc10_ -= 16;
                                                                                       si32(10,_loc10_ + 4);
                                                                                       si32(_loc49_,_loc10_);
                                                                                       wdnative.ESP = _loc10_;
                                                                                       wdnative_nternal.F___multadd_D2A();
                                                                                       _loc10_ += 16;
                                                                                       _loc49_ = wdnative.eax;
                                                                                    }
                                                                                    _loc37_ += -1;
                                                                                    _loc17_ += 1;
                                                                                    continue loop15;
                                                                                 }
                                                                                 §§goto(addr29a6);
                                                                              }
                                                                              §§goto(addr2423);
                                                                           }
                                                                           si8(57,_loc37_);
                                                                           _loc17_ = _loc37_ + 1;
                                                                           §§goto(addr2ad3);
                                                                        }
                                                                        break loop43;
                                                                     }
                                                                     _loc45_ = li32(wdnative_nternal._pmem_next);
                                                                     _loc29_ = _loc45_ - wdnative_nternal._private_mem;
                                                                     _loc29_ = (_loc29_ >> 3) + (_loc28_ = (_loc39_ = (_loc29_ = (_loc37_ = 1 << _loc44_) << 2) + 27) >>> 3);
                                                                     if((uint(_loc29_)) <= 288)
                                                                     {
                                                                        var _temp_392:* = _loc28_ << 3;
                                                                        _loc29_ = _loc45_ + _temp_392;
                                                                        si32(_loc29_,wdnative_nternal._pmem_next);
                                                                        break;
                                                                     }
                                                                  }
                                                                  _loc10_ -= 16;
                                                                  _loc29_ = _loc39_ & -8;
                                                                  si32(_loc29_,_loc10_);
                                                                  wdnative.ESP = _loc10_;
                                                                  wdnative.F_malloc();
                                                                  _loc10_ += 16;
                                                                  _loc45_ = wdnative.eax;
                                                                  break;
                                                               }
                                                               si32(_loc44_,_loc45_ + 4);
                                                               si32(_loc37_,_loc45_ + 8);
                                                               §§goto(addr20d2);
                                                            }
                                                            §§goto(addr216d);
                                                         }
                                                         §§goto(addr2ad3);
                                                      }
                                                      break loop19;
                                                   }
                                                   _loc17_ = _loc44_ - _loc37_;
                                                   if(_loc17_ <= -1)
                                                   {
                                                      _loc10_ -= 16;
                                                      si32(10,_loc10_ + 4);
                                                      si32(_loc34_,_loc10_);
                                                      wdnative.ESP = _loc10_;
                                                      wdnative_nternal.F___multadd_D2A();
                                                      _loc46_ += -1;
                                                      _loc10_ += 16;
                                                      _loc34_ = wdnative.eax;
                                                      _loc33_ = _loc11_;
                                                      if(_loc19_ != 0)
                                                      {
                                                         _loc10_ -= 16;
                                                         si32(10,_loc10_ + 4);
                                                         si32(_loc49_,_loc10_);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative_nternal.F___multadd_D2A();
                                                         _loc10_ += 16;
                                                         _loc49_ = wdnative.eax;
                                                         _loc33_ = _loc11_;
                                                      }
                                                   }
                                                }
                                                §§goto(addr1e05);
                                             }
                                             si8(49,_loc26_);
                                             _loc46_ = _loc8_ + 1;
                                             _loc17_ = _loc26_ + 1;
                                             _loc44_ = 0;
                                             _loc34_ = _loc45_;
                                             _loc35_ = _loc38_;
                                             break loop19;
                                          }
                                          _loc46_ = _loc39_ ^ -1;
                                          _loc44_ = 0;
                                          _loc17_ = _loc26_;
                                          if(_loc35_ != 0)
                                          {
                                             _loc45_ = li32(_loc35_ + 4);
                                             if(_loc45_ >= 10)
                                             {
                                                _loc10_ -= 16;
                                                si32(_loc35_,_loc10_);
                                                wdnative.ESP = _loc10_;
                                                wdnative_nternal.F_idalloc();
                                                _loc10_ += 16;
                                             }
                                             else
                                             {
                                                var _temp_115:* = _loc45_ << 2;
                                                _loc29_ = wdnative_nternal._freelist + _temp_115;
                                                _loc48_ = li32(_loc29_);
                                                si32(_loc48_,_loc35_);
                                                si32(_loc35_,_loc29_);
                                             }
                                          }
                                          _loc8_ = _loc46_;
                                          if(_loc49_ != 0)
                                          {
                                             if(_loc44_ != 0)
                                             {
                                                if(_loc44_ != _loc49_)
                                                {
                                                   if(_loc44_ != 0)
                                                   {
                                                      _loc45_ = li32(_loc44_ + 4);
                                                      if(_loc45_ >= 10)
                                                      {
                                                         _loc10_ -= 16;
                                                         si32(_loc44_,_loc10_);
                                                         wdnative.ESP = _loc10_;
                                                         wdnative_nternal.F_idalloc();
                                                         _loc10_ += 16;
                                                      }
                                                      else
                                                      {
                                                         var _temp_120:* = _loc45_ << 2;
                                                         _loc29_ = wdnative_nternal._freelist + _temp_120;
                                                         _loc48_ = li32(_loc29_);
                                                         si32(_loc48_,_loc44_);
                                                         si32(_loc44_,_loc29_);
                                                      }
                                                   }
                                                   _loc8_ = _loc46_;
                                                   if(_loc49_ == 0)
                                                   {
                                                      break;
                                                   }
                                                }
                                             }
                                             _loc45_ = li32(_loc49_ + 4);
                                             if(_loc45_ >= 10)
                                             {
                                                _loc10_ -= 16;
                                                si32(_loc49_,_loc10_);
                                                wdnative.ESP = _loc10_;
                                                wdnative_nternal.F_idalloc();
                                                _loc10_ += 16;
                                                _loc8_ = _loc46_;
                                                break;
                                             }
                                             var _temp_125:* = _loc45_ << 2;
                                             _loc48_ = wdnative_nternal._freelist + _temp_125;
                                             _loc29_ = li32(_loc48_);
                                             si32(_loc29_,_loc49_);
                                             si32(_loc49_,_loc48_);
                                             _loc8_ = _loc46_;
                                          }
                                          break;
                                       }
                                       §§goto(addr2c96);
                                    }
                                    while(true)
                                    {
                                       _loc46_ = _loc17_;
                                       _loc34_ = li8(_loc46_ - 1);
                                       if(_loc34_ != 57)
                                       {
                                          _loc34_ += 1;
                                          break;
                                       }
                                       _loc17_ = _loc46_ + -1;
                                       if(_loc26_ == _loc17_)
                                       {
                                          si8(48,_loc17_);
                                          _loc8_ += 1;
                                          _loc34_ = 49;
                                          break;
                                       }
                                    }
                                    si8(_loc34_,_loc46_ - 1);
                                    _loc34_ = _loc45_;
                                    _loc17_ = _loc46_;
                                    break loop37;
                                 }
                                 _loc8_ = _loc34_;
                                 _loc46_ = _loc17_ + 1;
                                 do
                                 {
                                    _loc17_ = _loc46_ + -1;
                                    _loc29_ = li8(_loc46_ - 2);
                                    _loc46_ = _loc17_;
                                    _loc34_ = _loc45_;
                                 }
                                 while(_loc29_ == 48);
                                 addr2c96:
                                 if(_loc34_ != 0)
                                 {
                                    _loc46_ = li32(_loc34_ + 4);
                                    if(_loc46_ >= 10)
                                    {
                                       _loc10_ -= 16;
                                       si32(_loc34_,_loc10_);
                                       wdnative.ESP = _loc10_;
                                       wdnative_nternal.F_idalloc();
                                       _loc10_ += 16;
                                    }
                                    else
                                    {
                                       var _temp_107:* = _loc46_ << 2;
                                       _loc29_ = wdnative_nternal._freelist + _temp_107;
                                       _loc48_ = li32(_loc29_);
                                       si32(_loc48_,_loc34_);
                                       si32(_loc34_,_loc29_);
                                    }
                                 }
                                 si8(0,_loc17_);
                                 _loc46_ = _loc8_ + 1;
                                 si32(_loc46_,_loc41_);
                                 if(_loc43_ != 0)
                                 {
                                    si32(_loc17_,_loc43_);
                                    break loop28;
                                 }
                                 break loop26;
                              }
                              break;
                           }
                           _loc18_ = 0;
                           if(_loc32_ >= 1)
                           {
                              _loc29_ = _loc49_ << 2;
                              _loc29_ = _loc29_ + _loc45_;
                              _loc18_ = li32(_loc29_ + 12);
                              _loc33_ = _loc29_ + 12;
                           }
                           _loc49_ = _loc31_ + -11;
                           if(_loc49_ != 0)
                           {
                              _loc32_ = 0;
                              if(uint(_loc33_) > uint(_loc46_))
                              {
                                 _loc32_ = li32(_loc33_ - 4);
                              }
                              _loc47_ = _loc35_ << _loc49_;
                              _loc29_ = 43 - _loc31_;
                              _loc48_ = _loc18_ >>> _loc29_;
                              _loc48_ = _loc47_ | _loc48_;
                              _loc46_ = _loc48_ | 0x3FF00000;
                              _loc48_ = _loc18_ << _loc49_;
                              _loc29_ = _loc32_ >>> _loc29_;
                              _loc29_ = _loc29_ | _loc48_;
                              _loc18_ = _loc29_ | 0;
                           }
                           else
                           {
                              _loc46_ = _loc35_ | 0x3FF00000;
                           }
                           §§goto(addr0a16);
                        }
                     }
                  }
                  si32(1,_loc41_);
                  _loc10_ -= 16;
                  si32(1,_loc10_ + 8);
                  si32(_loc43_,_loc10_ + 4);
                  si32(wdnative_nternal.L__2E_str2954,_loc10_);
                  wdnative.ESP = _loc10_;
                  wdnative_nternal.F___nrv_alloc_D2A();
                  _loc10_ += 16;
                  _loc26_ = wdnative.eax;
                  break;
               }
            }
            _loc46_ = li32(_loc41_);
            break;
         }
         if(_loc46_ == -32768)
         {
            si32(2147483647,_loc41_);
         }
         wdnative.eax = _loc26_;
         wdnative.ESP = _loc10_ = _loc14_;
         return;
      }
      _loc29_ = _loc46_ | 0x100000;
      si32(_loc29_,_loc14_ - 4);
      §§goto(addr0277);
   }
}

