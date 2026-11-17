package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemcpy;
   import wdnative.Fmemset;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F___vfprintf() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc9_:int = 0;
      var _loc20_:int = 0;
      var _loc26_:int = 0;
      var _loc12_:int = 0;
      var _loc46_:int = 0;
      var _loc48_:int = 0;
      var _loc49_:int = 0;
      var _loc8_:int = 0;
      var _loc40_:int = 0;
      var _loc41_:int = 0;
      var _loc43_:int = 0;
      var _loc25_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc23_:int = 0;
      var _loc17_:int = 0;
      var _loc27_:int = 0;
      var _loc29_:int = 0;
      var _loc37_:int = 0;
      var _loc30_:int = 0;
      var _loc33_:int = 0;
      var _loc32_:int = 0;
      var _loc11_:int = 0;
      var _loc6_:int = 0;
      var _loc16_:int = 0;
      var _loc14_:int = 0;
      var _loc42_:int = 0;
      var _loc44_:int = 0;
      var _loc45_:int = 0;
      var _loc38_:Number = NaN;
      var _loc24_:int = 0;
      var _loc18_:int = 0;
      var _loc35_:int = 0;
      var _loc31_:int = 0;
      var _loc15_:int = 0;
      var _loc13_:int = 0;
      var _loc21_:int = 0;
      var _loc36_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc34_:int = 0;
      var _loc22_:int = 0;
      var _loc7_:int = 0;
      var _loc19_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      _loc1_ -= 528;
      _loc9_ = li32(_loc2_);
      _loc26_ = li16(_loc9_ + 12);
      _loc24_ = _loc26_ & 8;
      _loc22_ = li32(_loc2_ + 8);
      _loc20_ = li32(_loc2_ + 4);
      while(true)
      {
         if(_loc24_ != 0)
         {
            _loc24_ = li32(_loc9_ + 16);
            if(_loc24_ != 0)
            {
               break;
            }
            _loc24_ = _loc26_ & 0x0200;
            if(_loc24_ != 0)
            {
               break;
            }
         }
         _loc1_ -= 16;
         si32(_loc9_,_loc1_);
         wdnative.ESP = _loc1_;
         wdnative_nternal.F___swsetup();
         _loc18_ = -1;
         _loc1_ += 16;
         _loc24_ = wdnative.eax;
         if(_loc24_ == 0)
         {
            break;
         }
         §§goto(addr45db);
      }
      si32(0,_loc2_ - 320);
      si32(_loc22_,_loc2_ - 392);
      si32(_loc22_,_loc2_ - 388);
      _loc16_ = _loc2_ - 280;
      _loc14_ = _loc16_ + 16;
      _loc26_ = _loc16_ | 4;
      si32(_loc14_,_loc26_);
      si32(0,_loc26_ + 8);
      si32(0,_loc2_ - 272);
      si32(_loc9_,_loc2_ - 280);
      wdnative.ESP = _loc1_;
      wdnative_nternal.F_localeconv();
      _loc12_ = li32(wdnative_nternal._ret_2E_1143);
      _loc24_ = li8(_loc12_ + 1);
      _loc8_ = 1;
      if(_loc24_ != 0)
      {
         _loc46_ = _loc12_ & -4;
         var _loc47_:int = li32(_loc46_);
         var _temp_17:* = int(_loc47_ + -16843009);
         _loc24_ = (_loc47_ = (_loc47_ &= -2139062144) ^ -2139062144) & _temp_17;
         if(_loc24_ != 0)
         {
            _loc48_ = _loc46_ + 4;
            _loc8_ = 0;
            while(true)
            {
               _loc49_ = _loc12_ + _loc8_;
               if((uint(_loc49_)) < uint(_loc48_))
               {
                  _loc24_ = li8(_loc49_);
                  if(_loc24_ == 0)
                  {
                     break;
                  }
                  _loc8_ += 1;
                  continue;
               }
            }
            §§goto(addr02de);
         }
         _loc49_ = _loc46_ + 4;
         while(true)
         {
            _loc8_ = li32(_loc49_);
            _loc24_ = _loc8_ + -16843009;
            _loc47_ = _loc8_ & -2139062144;
            _loc47_ = _loc47_ ^ -2139062144;
            _loc24_ = _loc47_ & _loc24_;
            if(_loc24_ != 0)
            {
               _loc24_ = _loc8_ & 0xFF;
               if(_loc24_ == 0)
               {
                  _loc8_ = _loc49_ - _loc12_;
                  break;
               }
               _loc24_ = li8(_loc49_ + 1);
               if(_loc24_ == 0)
               {
                  _loc24_ = 1 - _loc12_;
                  _loc8_ = _loc24_ + _loc49_;
                  break;
               }
               _loc24_ = li8(_loc49_ + 2);
               if(_loc24_ == 0)
               {
                  _loc24_ = 2 - _loc12_;
                  _loc8_ = _loc24_ + _loc49_;
                  break;
               }
               _loc24_ = li8(_loc49_ + 3);
               if(_loc24_ == 0)
               {
                  _loc24_ = 3 - _loc12_;
                  _loc8_ = _loc24_ + _loc49_;
                  break;
               }
            }
            _loc49_ += 4;
         }
      }
      addr02de:
      _loc42_ = _loc2_ - 138;
      _loc43_ = _loc42_ + 5;
      _loc44_ = _loc2_ - 200;
      _loc48_ = _loc44_ + 3;
      _loc45_ = _loc2_ - 312;
      _loc49_ = _loc45_ + 32;
      _loc41_ = _loc45_ + 31;
      _loc40_ = _loc42_ + 6;
      _loc46_ = _loc44_ + 2;
      _loc37_ = _loc20_;
      _loc35_ = 0;
      _loc36_ = 0;
      _loc33_ = 1;
      _loc34_ = 0;
      loop2:
      while(true)
      {
         _loc31_ = 0;
         while(true)
         {
            _loc32_ = _loc37_ - _loc31_;
            _loc29_ = li8(_loc32_);
            if(_loc29_ == 0)
            {
               break;
            }
            if(_loc29_ == 37)
            {
               break;
            }
            _loc31_ += -1;
         }
         _loc30_ = _loc35_;
         if(_loc31_ != 0)
         {
            _loc30_ = _loc35_ - _loc31_;
            _loc18_ = -1;
            if(_loc30_ < 0)
            {
               break;
            }
            var _temp_33:* = int(0 - _loc31_);
            var _temp_28:* = (_loc47_ = li32(_loc2_ - 272)) << 3;
            var _temp_29:* = int(_loc14_ + _temp_28);
            si32(_loc37_,_temp_29);
            _loc47_ = li32(_loc2_ - 272);
            var _temp_31:* = _loc47_ << 3;
            var _loc28_:int = _loc14_ + _temp_31;
            si32(_temp_33,_loc28_ | 4);
            _loc37_ = li32(_loc2_ - 268);
            _loc24_ = _loc37_ - _loc31_;
            si32(_loc24_,_loc2_ - 268);
            _loc24_ = _loc47_ + 1;
            si32(_loc24_,_loc2_ - 272);
            if(_loc24_ >= 8)
            {
               if(_loc37_ == _loc31_)
               {
                  si32(0,_loc2_ - 272);
               }
               else
               {
                  var _temp_37:* = li32(_loc2_ - 280);
                  _loc1_ -= 16;
                  si32(_loc26_,_loc1_ + 4);
                  si32(_temp_37,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sfvwrite();
                  _loc1_ += 16;
                  var _temp_39:* = wdnative.eax;
                  si32(0,_loc2_ - 268);
                  si32(0,_loc2_ - 272);
                  _loc18_ = _loc35_;
                  if(_temp_39 != 0)
                  {
                     break;
                  }
               }
            }
         }
         if(_loc29_ != 0)
         {
            _loc35_ = 0;
            si32(_loc35_,_loc2_ - 160);
            si8(_loc35_,_loc2_ - 139);
            si8(_loc35_,_loc2_ - 313);
            _loc37_ = _loc32_ + 1;
            _loc29_ = -1;
            _loc32_ = _loc35_;
            loop4:
            while(true)
            {
               _loc31_ = _loc37_ + 1;
               _loc11_ = si8(li8(_loc37_));
               _loc10_ = _loc32_;
               loop5:
               while(true)
               {
                  _loc32_ = _loc10_;
                  loop6:
                  while(true)
                  {
                     _loc37_ = _loc31_;
                     _loc10_ = 0;
                     loop36:
                     while(true)
                     {
                        if(_loc11_ <= 87)
                        {
                           if(_loc11_ <= 64)
                           {
                              if(_loc11_ <= 42)
                              {
                                 if(_loc11_ <= 38)
                                 {
                                    if(_loc11_ == 32)
                                    {
                                       _loc24_ = li8(_loc2_ - 139);
                                       if(_loc24_ == 0)
                                       {
                                          si8(32,_loc2_ - 139);
                                       }
                                       break loop6;
                                    }
                                    if(_loc11_ == 35)
                                    {
                                       _loc35_ |= 1;
                                       break loop6;
                                    }
                                 }
                                 else
                                 {
                                    if(_loc11_ == 39)
                                    {
                                       _loc35_ |= 512;
                                       break loop6;
                                    }
                                    if(_loc11_ == 42)
                                    {
                                       _loc11_ = si8(li8(_loc37_));
                                       _loc15_ = _loc11_ + -48;
                                       _loc31_ = 0;
                                       _loc32_ = _loc37_;
                                       if(uint(_loc15_) < 10)
                                       {
                                          do
                                          {
                                             _loc24_ = _loc31_ * 10;
                                             _loc31_ = _loc24_ + _loc15_;
                                             _loc24_ = _loc32_ + 1;
                                             _loc11_ = si8(li8(_loc32_ + 1));
                                             _loc15_ = _loc11_ + -48;
                                             _loc32_ = _loc24_;
                                          }
                                          while(uint(_loc15_) < 10);
                                       }
                                       _loc24_ = _loc11_ & 0xFF;
                                       _loc15_ = li32(_loc2_ - 320);
                                       if(_loc24_ == 36)
                                       {
                                          while(true)
                                          {
                                             if(_loc15_ == 0)
                                             {
                                                _loc24_ = _loc2_ - 384;
                                                si32(_loc24_,_loc2_ - 320);
                                                var _temp_55:* = li32(_loc2_ - 388);
                                                _loc1_ -= 16;
                                                _loc24_ = _loc2_ - 320;
                                                si32(_loc24_,_loc1_ + 8);
                                                si32(_temp_55,_loc1_ + 4);
                                                si32(_loc20_,_loc1_);
                                                wdnative.ESP = _loc1_;
                                                wdnative_nternal.F___find_arguments();
                                                _loc18_ = -1;
                                                _loc1_ += 16;
                                                _loc24_ = wdnative.eax;
                                                if(_loc24_ != 0)
                                                {
                                                   break loop2;
                                                }
                                                _loc15_ = li32(_loc2_ - 320);
                                                if(_loc15_ == 0)
                                                {
                                                   var _temp_59:* = int(_loc22_ + 4);
                                                   _loc31_ = _loc22_;
                                                   _loc22_ += 4;
                                                   break;
                                                }
                                             }
                                             _loc24_ = _loc31_ << 3;
                                             _loc31_ = _loc15_ + _loc24_;
                                             break;
                                          }
                                          _loc37_ = _loc32_ + 1;
                                       }
                                       else
                                       {
                                          if(_loc15_ != 0)
                                          {
                                             var _temp_60:* = _loc33_ << 3;
                                             _loc31_ = _loc15_ + _temp_60;
                                          }
                                          else
                                          {
                                             var _temp_61:* = int(_loc22_ + 4);
                                             _loc31_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc33_ += 1;
                                       }
                                       _loc32_ = li32(_loc31_);
                                       if(_loc32_ <= -1)
                                       {
                                          _loc32_ = 0 - _loc32_;
                                          addr084c:
                                          _loc35_ |= 4;
                                       }
                                       break loop6;
                                    }
                                 }
                              }
                              else if(_loc11_ <= 45)
                              {
                                 if(_loc11_ == 43)
                                 {
                                    si8(43,_loc2_ - 139);
                                    break loop6;
                                 }
                                 if(_loc11_ == 45)
                                 {
                                    §§goto(addr084c);
                                 }
                              }
                              else
                              {
                                 if(_loc11_ == 46)
                                 {
                                    _loc31_ = _loc37_ + 1;
                                    _loc29_ = li8(_loc37_);
                                    if(_loc29_ == 42)
                                    {
                                       _loc11_ = si8(li8(_loc31_));
                                       _loc13_ = _loc11_ + -48;
                                       _loc29_ = 0;
                                       _loc15_ = _loc31_;
                                       if(uint(_loc13_) <= 9)
                                       {
                                          do
                                          {
                                             _loc24_ = _loc29_ * 10;
                                             _loc29_ = _loc24_ + _loc13_;
                                             _loc15_ = _loc37_ + 1;
                                             _loc11_ = si8(li8(_loc37_ + 2));
                                             _loc13_ = _loc11_ + -48;
                                             _loc37_ = _loc15_;
                                          }
                                          while(uint(_loc13_) < 10);
                                          _loc15_ += 1;
                                       }
                                       _loc24_ = _loc11_ & 0xFF;
                                       _loc37_ = li32(_loc2_ - 320);
                                       if(_loc24_ == 36)
                                       {
                                          while(true)
                                          {
                                             if(_loc37_ == 0)
                                             {
                                                _loc24_ = _loc2_ - 384;
                                                si32(_loc24_,_loc2_ - 320);
                                                var _temp_83:* = li32(_loc2_ - 388);
                                                _loc1_ -= 16;
                                                _loc24_ = _loc2_ - 320;
                                                si32(_loc24_,_loc1_ + 8);
                                                si32(_temp_83,_loc1_ + 4);
                                                si32(_loc20_,_loc1_);
                                                wdnative.ESP = _loc1_;
                                                wdnative_nternal.F___find_arguments();
                                                _loc18_ = -1;
                                                _loc1_ += 16;
                                                _loc24_ = wdnative.eax;
                                                if(_loc24_ != 0)
                                                {
                                                   break loop2;
                                                }
                                                _loc37_ = li32(_loc2_ - 320);
                                                if(_loc37_ == 0)
                                                {
                                                   var _temp_87:* = int(_loc22_ + 4);
                                                   _loc29_ = _loc22_;
                                                   _loc22_ += 4;
                                                   break;
                                                }
                                             }
                                             _loc24_ = _loc29_ << 3;
                                             _loc29_ = _loc37_ + _loc24_;
                                             break;
                                          }
                                          _loc37_ = _loc15_ + 1;
                                          _loc29_ = li32(_loc29_);
                                          break loop6;
                                       }
                                       if(_loc37_ != 0)
                                       {
                                          var _temp_88:* = _loc33_ << 3;
                                          _loc37_ += _temp_88;
                                       }
                                       else
                                       {
                                          var _temp_89:* = int(_loc22_ + 4);
                                          _loc37_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc29_ = li32(_loc37_);
                                       _loc33_ += 1;
                                       _loc37_ = _loc31_;
                                       break loop6;
                                    }
                                    _loc24_ = _loc29_ << 24;
                                    _loc11_ = _loc24_ >> 24;
                                    _loc15_ = _loc11_ + -48;
                                    _loc29_ = 0;
                                    if(uint(_loc15_) <= 9)
                                    {
                                       _loc37_ += 1;
                                       _loc29_ = 0;
                                       do
                                       {
                                          _loc24_ = _loc29_ * 10;
                                          _loc29_ = _loc24_ + _loc15_;
                                          _loc31_ = _loc37_ + 1;
                                          _loc11_ = si8(li8(_loc37_));
                                          _loc15_ = _loc11_ + -48;
                                          _loc37_ = _loc31_;
                                       }
                                       while(uint(_loc15_) < 10);
                                    }
                                    continue;
                                 }
                                 if(_loc11_ == 48)
                                 {
                                    _loc35_ |= 128;
                                    break loop6;
                                 }
                                 _loc24_ = _loc11_ + -49;
                                 if((uint(_loc24_)) < 9)
                                 {
                                    do
                                    {
                                       _loc24_ = _loc10_ * 10;
                                       _loc24_ = _loc11_ + _loc24_;
                                       _loc10_ = _loc24_ + -48;
                                       _loc31_ = _loc37_ + 1;
                                       _loc11_ = si8(li8(_loc37_));
                                       _loc24_ = _loc11_ + -48;
                                       _loc37_ = _loc31_;
                                    }
                                    while(uint(_loc24_) < 10);
                                    _loc24_ = _loc11_ & 0xFF;
                                    if(_loc24_ == 36)
                                    {
                                       var _temp_67:* = li32(_loc2_ - 320);
                                       _loc37_ = _loc31_;
                                       _loc33_ = _loc10_;
                                       if(_temp_67 == 0)
                                       {
                                          _loc24_ = _loc2_ - 384;
                                          si32(_loc24_,_loc2_ - 320);
                                          var _temp_70:* = li32(_loc2_ - 388);
                                          _loc1_ -= 16;
                                          _loc24_ = _loc2_ - 320;
                                          si32(_loc24_,_loc1_ + 8);
                                          si32(_temp_70,_loc1_ + 4);
                                          si32(_loc20_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F___find_arguments();
                                          _loc18_ = -1;
                                          _loc1_ += 16;
                                          var _temp_72:* = wdnative.eax;
                                          _loc37_ = _loc31_;
                                          _loc33_ = _loc10_;
                                          if(_temp_72 != 0)
                                          {
                                             break loop2;
                                          }
                                       }
                                       break loop6;
                                    }
                                    continue loop5;
                                 }
                              }
                              addr2f9b:
                              if(_loc11_ == 0)
                              {
                                 addr447d:
                                 _loc24_ = li32(_loc2_ - 268);
                                 if(_loc24_ == 0)
                                 {
                                    si32(0,_loc2_ - 272);
                                    _loc18_ = _loc30_;
                                    break loop2;
                                 }
                                 var _temp_91:* = li32(_loc2_ - 280);
                                 _loc1_ -= 16;
                                 si32(_loc26_,_loc1_ + 4);
                                 si32(_temp_91,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F___sfvwrite();
                                 _loc1_ += 16;
                                 si32(0,_loc2_ - 268);
                                 si32(0,_loc2_ - 272);
                                 _loc18_ = _loc30_;
                                 break loop2;
                              }
                              si8(_loc11_,_loc2_ - 312);
                              _loc19_ = 0;
                              si8(_loc19_,_loc2_ - 139);
                              _loc13_ = 1;
                              _loc15_ = _loc2_ - 312;
                              _loc31_ = _loc35_;
                           }
                           else if(_loc11_ <= 70)
                           {
                              if(_loc11_ <= 67)
                              {
                                 if(_loc11_ != 65)
                                 {
                                    if(_loc11_ != 67)
                                    {
                                       §§goto(addr2f9b);
                                    }
                                    else
                                    {
                                       _loc35_ |= 16;
                                       addr0bbc:
                                       _loc24_ = _loc35_ & 0x10;
                                       if(_loc24_ != 0)
                                       {
                                          _loc1_ -= 16;
                                          si32(128,_loc1_ + 8);
                                          si32(0,_loc1_ + 4);
                                          _loc31_ = _loc2_ - 520;
                                          si32(_loc31_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.Fmemset();
                                          _loc1_ += 16;
                                          _loc15_ = li32(_loc2_ - 320);
                                          if(_loc15_ != 0)
                                          {
                                             var _temp_97:* = _loc33_ << 3;
                                             _loc15_ += _temp_97;
                                          }
                                          else
                                          {
                                             var _temp_98:* = int(_loc22_ + 4);
                                             _loc15_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc47_ = li32(_loc15_);
                                          _loc24_ = li32(wdnative_nternal.___wcrtomb);
                                          _loc1_ -= 16;
                                          si32(_loc31_,_loc1_ + 8);
                                          si32(_loc47_,_loc1_ + 4);
                                          si32(_loc45_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.ptr2fun[_loc24_]();
                                          _loc1_ += 16;
                                          _loc13_ = wdnative.eax;
                                          if(_loc13_ == -1)
                                          {
                                             _loc24_ = li16(_loc9_ + 12);
                                             _loc24_ = _loc24_ | 0x40;
                                             si16(_loc24_,_loc9_ + 12);
                                             _loc18_ = _loc30_;
                                             break loop2;
                                          }
                                       }
                                       else
                                       {
                                          _loc31_ = li32(_loc2_ - 320);
                                          if(_loc31_ != 0)
                                          {
                                             var _temp_105:* = _loc33_ << 3;
                                             _loc24_ = _loc31_ + _temp_105;
                                             _loc31_ = li32(_loc24_);
                                          }
                                          else
                                          {
                                             _loc31_ = li32(_loc22_);
                                             _loc22_ += 4;
                                          }
                                          si8(_loc31_,_loc2_ - 312);
                                          _loc13_ = 1;
                                       }
                                       _loc19_ = 0;
                                       si8(_loc19_,_loc2_ - 139);
                                       _loc33_ += 1;
                                       _loc15_ = _loc45_;
                                       _loc31_ = _loc35_;
                                    }
                                 }
                                 else
                                 {
                                    addr0fae:
                                    _loc27_ = 120;
                                    if(_loc11_ != 97)
                                    {
                                       _loc27_ = 88;
                                    }
                                    si8(_loc27_,_loc2_ - 313);
                                    _loc27_ = wdnative_nternal._xdigs_lower_2E_4543;
                                    if(_loc11_ != 97)
                                    {
                                       _loc27_ = wdnative_nternal._xdigs_upper_2E_4544;
                                    }
                                    _loc10_ = 112;
                                    if(_loc11_ != 97)
                                    {
                                       _loc10_ = 80;
                                    }
                                    if(_loc36_ != 0)
                                    {
                                       _loc25_ = li32(_loc36_ - 4);
                                       si32(_loc25_,_loc36_);
                                       _loc24_ = 1 << _loc25_;
                                       si32(_loc24_,_loc36_ + 4);
                                       _loc36_ += -4;
                                       if(_loc36_ != 0)
                                       {
                                          if(_loc25_ >= 10)
                                          {
                                             _loc1_ -= 16;
                                             si32(_loc36_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F_idalloc();
                                             _loc1_ += 16;
                                          }
                                          else
                                          {
                                             var _temp_111:* = _loc25_ << 2;
                                             _loc47_ = wdnative_nternal._freelist + _temp_111;
                                             _loc24_ = li32(_loc47_);
                                             si32(_loc24_,_loc36_);
                                             si32(_loc36_,_loc47_);
                                          }
                                       }
                                    }
                                    _loc24_ = _loc29_ >>> 31;
                                    _loc24_ = _loc24_ ^ 1;
                                    _loc18_ = _loc24_ + _loc29_;
                                    _loc24_ = _loc35_ & 8;
                                    _loc36_ = li32(_loc2_ - 320);
                                    if(_loc24_ != 0)
                                    {
                                       if(_loc36_ != 0)
                                       {
                                          var _temp_116:* = _loc33_ << 3;
                                          _loc36_ += _temp_116;
                                       }
                                       else
                                       {
                                          var _temp_117:* = int(_loc22_ + 8);
                                          _loc36_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       var _loc39_:Number = lf64(_loc36_);
                                       sf64(_loc39_,_loc2_ - 184);
                                       _loc1_ -= 32;
                                       _loc47_ = _loc2_ - 192;
                                       si32(_loc47_,_loc1_ + 24);
                                       _loc47_ = _loc2_ - 172;
                                       si32(_loc47_,_loc1_ + 20);
                                       _loc47_ = _loc2_ - 188;
                                       si32(_loc47_,_loc1_ + 16);
                                       si32(_loc18_,_loc1_ + 12);
                                       si32(_loc27_,_loc1_ + 8);
                                       sf64(_loc39_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F___hdtoa();
                                       _loc1_ += 32;
                                       _loc36_ = wdnative.eax;
                                    }
                                    else
                                    {
                                       if(_loc36_ != 0)
                                       {
                                          var _temp_123:* = _loc33_ << 3;
                                          _loc36_ += _temp_123;
                                       }
                                       else
                                       {
                                          var _temp_124:* = int(_loc22_ + 8);
                                          _loc36_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc39_ = lf64(_loc36_);
                                       sf64(_loc39_,_loc2_ - 184);
                                       _loc1_ -= 32;
                                       _loc47_ = _loc2_ - 192;
                                       si32(_loc47_,_loc1_ + 24);
                                       _loc47_ = _loc2_ - 172;
                                       si32(_loc47_,_loc1_ + 20);
                                       _loc47_ = _loc2_ - 188;
                                       si32(_loc47_,_loc1_ + 16);
                                       si32(_loc18_,_loc1_ + 12);
                                       si32(_loc27_,_loc1_ + 8);
                                       sf64(_loc39_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F___hdtoa();
                                       _loc1_ += 32;
                                       _loc36_ = wdnative.eax;
                                    }
                                    if(_loc18_ <= -1)
                                    {
                                       _loc24_ = li32(_loc2_ - 192);
                                       _loc18_ = _loc24_ - _loc36_;
                                    }
                                    _loc33_ += 1;
                                    _loc24_ = li32(_loc2_ - 188);
                                    if(_loc24_ == 2147483647)
                                    {
                                       si8(0,_loc2_ - 313);
                                    }
                                    addr145d:
                                    _loc24_ = li32(_loc2_ - 172);
                                    if(_loc24_ != 0)
                                    {
                                       si8(45,_loc2_ - 139);
                                    }
                                    _loc5_ = li32(_loc2_ - 188);
                                    if(_loc5_ == 2147483647)
                                    {
                                       _loc24_ = li8(_loc36_);
                                       if(_loc24_ == 78)
                                       {
                                          si8(0,_loc2_ - 139);
                                          _loc15_ = wdnative_nternal.L__2E_str1728;
                                          if(_loc11_ <= 96)
                                          {
                                             _loc15_ = wdnative_nternal.L__2E_str2729;
                                          }
                                       }
                                       else
                                       {
                                          _loc15_ = wdnative_nternal.L__2E_str3730;
                                          if(_loc11_ <= 96)
                                          {
                                             _loc15_ = wdnative_nternal.L__2E_str4731;
                                          }
                                       }
                                       _loc31_ = _loc35_ & -129;
                                       _loc13_ = 3;
                                       _loc19_ = 0;
                                       _loc29_ = _loc18_;
                                       _loc25_ = _loc10_;
                                    }
                                    else
                                    {
                                       _loc24_ = li32(_loc2_ - 192);
                                       _loc4_ = _loc24_ - _loc36_;
                                       _loc31_ = _loc35_ | 0x0100;
                                       while(true)
                                       {
                                          _loc24_ = _loc11_ | 0x20;
                                          if(_loc24_ == 103)
                                          {
                                             _loc29_ = _loc35_ & 1;
                                             if(_loc5_ >= -3)
                                             {
                                                if(_loc5_ <= _loc18_)
                                                {
                                                   _loc25_ = 0;
                                                   _loc15_ = _loc4_;
                                                   if(_loc29_ != _loc25_)
                                                   {
                                                      _loc15_ = _loc18_;
                                                   }
                                                   _loc29_ = _loc15_ - _loc5_;
                                                   if(_loc29_ >= _loc25_)
                                                   {
                                                      _loc25_ = _loc29_;
                                                   }
                                                   _loc18_ = _loc25_;
                                                   break;
                                                }
                                             }
                                             if(_loc29_ == 0)
                                             {
                                                _loc18_ = _loc4_;
                                             }
                                          }
                                          _loc24_ = _loc10_ & 0xFF;
                                          if(_loc24_ == 0)
                                          {
                                             break;
                                          }
                                          si8(_loc10_,_loc2_ - 200);
                                          _loc25_ = _loc5_ + -1;
                                          _loc3_ = 0;
                                          _loc29_ = 45;
                                          if(_loc25_ >= _loc3_)
                                          {
                                             _loc29_ = 43;
                                          }
                                          si8(_loc29_,_loc2_ - 199);
                                          _loc29_ = 1 - _loc5_;
                                          if(_loc25_ >= _loc3_)
                                          {
                                             _loc29_ = _loc25_;
                                          }
                                          if(_loc29_ >= 10)
                                          {
                                             do
                                             {
                                                _loc24_ = _loc29_;
                                                _loc25_ = _loc42_ - _loc3_;
                                                _loc47_ = _loc24_ % 10;
                                                _loc47_ = _loc47_ + 48;
                                                si8(_loc47_,_loc25_ + 5);
                                                _loc3_ += 1;
                                                _loc29_ = _loc24_ / 10;
                                             }
                                             while(_loc24_ > 99);
                                             _loc24_ = _loc29_ + 48;
                                             si8(_loc24_,_loc25_ + 4);
                                             var _temp_142:* = int(_loc43_ - _loc3_);
                                             _loc25_ = _loc46_;
                                             if(uint(_loc40_) > uint(_temp_142))
                                             {
                                                _loc1_ -= 16;
                                                si32(_loc46_,_loc1_);
                                                _loc24_ = _loc3_ + 1;
                                                si32(_loc24_,_loc1_ + 8);
                                                _loc24_ = _loc43_ - _loc3_;
                                                si32(_loc24_,_loc1_ + 4);
                                                _loc25_ = _loc48_ + _loc3_;
                                                wdnative.ESP = _loc1_;
                                                wdnative.Fmemcpy();
                                                _loc1_ += 16;
                                             }
                                          }
                                          else
                                          {
                                             _loc24_ = _loc10_ | 0x20;
                                             var _temp_147:* = _loc24_ & 0xFF;
                                             _loc3_ = _loc46_;
                                             if(_temp_147 == 101)
                                             {
                                                si8(48,_loc2_ - 198);
                                                _loc3_ = _loc48_;
                                             }
                                             _loc24_ = _loc29_ + 48;
                                             si8(_loc24_,_loc3_);
                                             _loc25_ = _loc3_ + 1;
                                          }
                                          _loc3_ = _loc25_ - _loc44_;
                                          _loc13_ = _loc3_ + _loc18_;
                                          while(true)
                                          {
                                             if(_loc18_ <= 1)
                                             {
                                                var _temp_149:* = _loc35_ & 1;
                                                _loc19_ = 0;
                                                _loc15_ = _loc36_;
                                                _loc29_ = _loc18_;
                                                _loc25_ = _loc10_;
                                                if(_temp_149 == 0)
                                                {
                                                   break;
                                                }
                                             }
                                             _loc13_ += _loc8_;
                                             _loc19_ = 0;
                                             _loc15_ = _loc36_;
                                             _loc29_ = _loc18_;
                                             _loc25_ = _loc10_;
                                             break;
                                          }
                                       }
                                       _loc11_ = 1;
                                       if(_loc5_ >= _loc11_)
                                       {
                                          _loc11_ = _loc5_;
                                       }
                                       while(true)
                                       {
                                          if(_loc18_ == 0)
                                          {
                                             var _temp_150:* = _loc35_ & 1;
                                             _loc29_ = 0;
                                             if(_temp_150 == 0)
                                             {
                                                break;
                                             }
                                          }
                                          _loc24_ = _loc11_ + _loc8_;
                                          _loc11_ = _loc24_ + _loc18_;
                                          _loc29_ = _loc18_;
                                          break;
                                       }
                                       _loc24_ = _loc35_ & 0x0200;
                                       _loc25_ = 0;
                                       _loc15_ = _loc36_;
                                       _loc19_ = _loc25_;
                                       _loc13_ = _loc11_;
                                       if(_loc24_ != 0)
                                       {
                                          _loc15_ = _loc36_;
                                          _loc19_ = _loc25_;
                                          _loc13_ = _loc11_;
                                          if(_loc5_ >= 1)
                                          {
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F_localeconv();
                                             _loc35_ = li32(wdnative_nternal._ret_2E_1143 + 8);
                                             si32(_loc35_,_loc2_ - 160);
                                             _loc25_ = li32(wdnative_nternal._ret_2E_1143 + 4);
                                             si32(_loc25_,_loc2_ - 168);
                                             _loc15_ = _loc25_ & -4;
                                             _loc47_ = li32(_loc15_);
                                             var _temp_159:* = int(_loc47_ + -16843009);
                                             _loc24_ = (_loc47_ = (_loc47_ &= -2139062144) ^ -2139062144) & _temp_159;
                                             if(_loc24_ != 0)
                                             {
                                                _loc13_ = _loc15_ + 4;
                                                _loc18_ = 0;
                                                while(true)
                                                {
                                                   _loc19_ = _loc25_ + _loc18_;
                                                   if((uint(_loc19_)) < uint(_loc13_))
                                                   {
                                                      _loc24_ = li8(_loc19_);
                                                      if(_loc24_ == 0)
                                                      {
                                                         break;
                                                      }
                                                      _loc18_ += 1;
                                                      continue;
                                                   }
                                                }
                                                addr18b8:
                                                _loc24_ = _loc2_ - 168;
                                                _loc24_ = _loc24_ | 4;
                                                si32(_loc18_,_loc24_);
                                                _loc10_ = 0;
                                                si32(_loc10_,_loc2_ - 148);
                                                si32(_loc10_,_loc2_ - 152);
                                                si32(_loc5_,_loc2_ - 156);
                                                _loc7_ = _loc10_;
                                                loop21:
                                                while(true)
                                                {
                                                   _loc24_ = _loc7_ + _loc10_;
                                                   _loc24_ = _loc18_ * _loc24_;
                                                   _loc13_ = _loc11_ + _loc24_;
                                                   _loc10_ += 1;
                                                   while(true)
                                                   {
                                                      _loc6_ = li8(_loc35_);
                                                      _loc25_ = 0;
                                                      _loc15_ = _loc36_;
                                                      _loc19_ = _loc25_;
                                                      if(_loc6_ == 127)
                                                      {
                                                         break loop21;
                                                      }
                                                      _loc24_ = _loc6_ << 24;
                                                      _loc6_ = _loc24_ >> 24;
                                                      _loc25_ = 0;
                                                      _loc15_ = _loc36_;
                                                      _loc19_ = _loc25_;
                                                      if(_loc5_ <= _loc6_)
                                                      {
                                                         break loop21;
                                                      }
                                                      _loc25_ = _loc35_ + 1;
                                                      _loc5_ -= _loc6_;
                                                      si32(_loc5_,_loc2_ - 156);
                                                      _loc24_ = li8(_loc25_);
                                                      if(_loc24_ == 0)
                                                      {
                                                         break;
                                                      }
                                                      _loc7_ += 1;
                                                      si32(_loc7_,_loc2_ - 152);
                                                      si32(_loc25_,_loc2_ - 160);
                                                      _loc13_ += _loc18_;
                                                      _loc35_ = _loc25_;
                                                   }
                                                   si32(_loc10_,_loc2_ - 148);
                                                }
                                                addr2fc8:
                                                _loc11_ = 1;
                                                _loc5_ = li8(_loc2_ - 139);
                                                if(_loc5_ == 0)
                                                {
                                                   _loc11_ = 0;
                                                }
                                                _loc35_ = _loc13_;
                                                if(_loc13_ < _loc19_)
                                                {
                                                   _loc35_ = _loc19_;
                                                }
                                                _loc24_ = _loc11_ & 1;
                                                _loc11_ = _loc24_ + _loc35_;
                                                _loc24_ = li8(_loc2_ - 313);
                                                if(_loc24_ != 0)
                                                {
                                                   _loc11_ += 2;
                                                }
                                                _loc35_ = _loc11_;
                                                if(_loc11_ < _loc32_)
                                                {
                                                   _loc35_ = _loc32_;
                                                }
                                                _loc35_ += _loc30_;
                                                _loc18_ = -1;
                                                if(_loc35_ >= 0)
                                                {
                                                   _loc10_ = _loc31_ & 0x84;
                                                   if(_loc10_ == 0)
                                                   {
                                                      _loc7_ = _loc32_ - _loc11_;
                                                      while(_loc7_ > 0)
                                                      {
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_177:* = _loc24_ << 3;
                                                         var _temp_178:* = int(_loc14_ + _temp_177);
                                                         si32(wdnative_nternal._blanks,_temp_178);
                                                         _loc5_ = 16;
                                                         if(_loc7_ <= _loc5_)
                                                         {
                                                            _loc5_ = _loc7_;
                                                         }
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         _loc47_ = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _loc47_;
                                                         _loc47_ = _loc47_ | 4;
                                                         si32(_loc5_,_loc47_);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc18_ = _loc47_ + _loc5_;
                                                         si32(_loc18_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc18_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_184:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_184,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_186:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_186 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                         _loc7_ -= _loc5_;
                                                      }
                                                      _loc5_ = li8(_loc2_ - 139);
                                                   }
                                                   _loc24_ = _loc5_ & 0xFF;
                                                   if(_loc24_ != 0)
                                                   {
                                                      _loc24_ = li32(_loc2_ - 272);
                                                      var _temp_189:* = _loc24_ << 3;
                                                      var _temp_191:* = int(_loc14_ + _temp_189);
                                                      si32(_loc24_ = _loc2_ - 139,_temp_191);
                                                      _loc24_ = li32(_loc2_ - 272);
                                                      var _temp_193:* = _loc24_ << 3;
                                                      _loc47_ = _loc14_ + _temp_193;
                                                      var _temp_195:* = _loc47_ | 4;
                                                      si32(1,_temp_195);
                                                      _loc47_ = li32(_loc2_ - 268);
                                                      _loc18_ = _loc47_ + 1;
                                                      si32(_loc18_,_loc2_ - 268);
                                                      _loc24_ += 1;
                                                      si32(_loc24_,_loc2_ - 272);
                                                      if(_loc24_ >= 8)
                                                      {
                                                         if(_loc18_ == 0)
                                                         {
                                                            si32(0,_loc2_ - 272);
                                                         }
                                                         else
                                                         {
                                                            var _temp_199:* = li32(_loc2_ - 280);
                                                            _loc1_ -= 16;
                                                            si32(_loc26_,_loc1_ + 4);
                                                            si32(_temp_199,_loc1_);
                                                            wdnative.ESP = _loc1_;
                                                            wdnative_nternal.F___sfvwrite();
                                                            _loc1_ += 16;
                                                            var _temp_201:* = wdnative.eax;
                                                            si32(0,_loc2_ - 268);
                                                            si32(0,_loc2_ - 272);
                                                            _loc18_ = _loc30_;
                                                            if(_temp_201 != 0)
                                                            {
                                                               break loop2;
                                                            }
                                                         }
                                                      }
                                                   }
                                                   _loc24_ = li8(_loc2_ - 313);
                                                   if(_loc24_ != 0)
                                                   {
                                                      si8(48,_loc2_ - 314);
                                                      _loc24_ = li32(_loc2_ - 272);
                                                      var _temp_204:* = _loc24_ << 3;
                                                      var _temp_206:* = int(_loc14_ + _temp_204);
                                                      si32(_loc24_ = _loc2_ - 314,_temp_206);
                                                      _loc24_ = li32(_loc2_ - 272);
                                                      var _temp_208:* = _loc24_ << 3;
                                                      _loc47_ = _loc14_ + _temp_208;
                                                      var _temp_210:* = _loc47_ | 4;
                                                      si32(2,_temp_210);
                                                      _loc47_ = li32(_loc2_ - 268);
                                                      _loc18_ = _loc47_ + 2;
                                                      si32(_loc18_,_loc2_ - 268);
                                                      _loc24_ += 1;
                                                      si32(_loc24_,_loc2_ - 272);
                                                      if(_loc24_ >= 8)
                                                      {
                                                         if(_loc18_ == 0)
                                                         {
                                                            si32(0,_loc2_ - 272);
                                                         }
                                                         else
                                                         {
                                                            var _temp_214:* = li32(_loc2_ - 280);
                                                            _loc1_ -= 16;
                                                            si32(_loc26_,_loc1_ + 4);
                                                            si32(_temp_214,_loc1_);
                                                            wdnative.ESP = _loc1_;
                                                            wdnative_nternal.F___sfvwrite();
                                                            _loc1_ += 16;
                                                            var _temp_216:* = wdnative.eax;
                                                            si32(0,_loc2_ - 268);
                                                            si32(0,_loc2_ - 272);
                                                            _loc18_ = _loc30_;
                                                            if(_temp_216 != 0)
                                                            {
                                                               break loop2;
                                                            }
                                                         }
                                                      }
                                                   }
                                                   if(_loc10_ == 128)
                                                   {
                                                      _loc5_ = _loc32_ - _loc11_;
                                                      while(_loc5_ > 0)
                                                      {
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_218:* = _loc24_ << 3;
                                                         var _temp_219:* = int(_loc14_ + _temp_218);
                                                         si32(wdnative_nternal._zeroes,_temp_219);
                                                         _loc10_ = 16;
                                                         if(_loc5_ <= _loc10_)
                                                         {
                                                            _loc10_ = _loc5_;
                                                         }
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         _loc47_ = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _loc47_;
                                                         _loc47_ = _loc47_ | 4;
                                                         si32(_loc10_,_loc47_);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc18_ = _loc47_ + _loc10_;
                                                         si32(_loc18_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc18_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_225:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_225,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_227:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_227 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                         _loc5_ -= _loc10_;
                                                      }
                                                   }
                                                   _loc24_ = _loc31_ & 0x0100;
                                                   if(_loc24_ == 0)
                                                   {
                                                      _loc19_ -= _loc13_;
                                                      while(_loc19_ > 0)
                                                      {
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_230:* = _loc24_ << 3;
                                                         var _temp_231:* = int(_loc14_ + _temp_230);
                                                         si32(wdnative_nternal._zeroes,_temp_231);
                                                         _loc29_ = 16;
                                                         if(_loc19_ <= _loc29_)
                                                         {
                                                            _loc29_ = _loc19_;
                                                         }
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         _loc47_ = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _loc47_;
                                                         _loc47_ = _loc47_ | 4;
                                                         si32(_loc29_,_loc47_);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc18_ = _loc47_ + _loc29_;
                                                         si32(_loc18_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc18_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_237:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_237,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_239:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_239 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                         _loc19_ -= _loc29_;
                                                      }
                                                      _loc24_ = li32(_loc2_ - 160);
                                                      if(_loc24_ != 0)
                                                      {
                                                         _loc1_ -= 16;
                                                         si32(_loc49_,_loc1_ + 12);
                                                         si32(_loc15_,_loc1_ + 8);
                                                         si32(_loc16_,_loc1_ + 4);
                                                         _loc24_ = _loc2_ - 168;
                                                         si32(_loc24_,_loc1_);
                                                         wdnative.ESP = _loc1_;
                                                         wdnative_nternal.F_grouping_print();
                                                         _loc1_ += 16;
                                                         var _temp_243:* = wdnative.eax;
                                                         _loc18_ = _loc30_;
                                                         if(_temp_243 < 0)
                                                         {
                                                            break loop2;
                                                         }
                                                      }
                                                      else
                                                      {
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_245:* = _loc24_ << 3;
                                                         var _temp_246:* = int(_loc14_ + _temp_245);
                                                         si32(_loc15_,_temp_246);
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_248:* = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _temp_248;
                                                         var _temp_250:* = _loc47_ | 4;
                                                         si32(_loc13_,_temp_250);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc29_ = _loc47_ + _loc13_;
                                                         si32(_loc29_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc29_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_254:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_254,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_256:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_256 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                      }
                                                   }
                                                   else
                                                   {
                                                      _loc24_ = _loc25_ & 0xFF;
                                                      if(_loc24_ == 0)
                                                      {
                                                         _loc13_ = li32(_loc2_ - 188);
                                                         if(_loc13_ <= 0)
                                                         {
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            var _temp_260:* = _loc24_ << 3;
                                                            var _temp_261:* = int(_loc14_ + _temp_260);
                                                            si32(wdnative_nternal._zeroes,_temp_261);
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            var _temp_263:* = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _temp_263;
                                                            var _temp_265:* = _loc47_ | 4;
                                                            si32(1,_temp_265);
                                                            _loc47_ = li32(_loc2_ - 268);
                                                            _loc18_ = _loc47_ + 1;
                                                            si32(_loc18_,_loc2_ - 268);
                                                            _loc19_ = _loc24_ + 1;
                                                            si32(_loc19_,_loc2_ - 272);
                                                            if(_loc19_ >= 8)
                                                            {
                                                               if(_loc18_ == 0)
                                                               {
                                                                  _loc19_ = 0;
                                                                  si32(_loc19_,_loc2_ - 272);
                                                               }
                                                               else
                                                               {
                                                                  var _temp_269:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_269,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_271:* = wdnative.eax;
                                                                  si32(_loc19_ = 0,_loc2_ - 268);
                                                                  si32(_loc19_,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_271 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                            while(true)
                                                            {
                                                               if(_loc29_ == 0)
                                                               {
                                                                  _loc24_ = _loc31_ & 1;
                                                                  if(_loc24_ == 0)
                                                                  {
                                                                     break;
                                                                  }
                                                               }
                                                               _loc24_ = _loc19_ << 3;
                                                               _loc24_ = _loc14_ + _loc24_;
                                                               si32(_loc12_,_loc24_);
                                                               _loc24_ = li32(_loc2_ - 272);
                                                               _loc47_ = _loc24_ << 3;
                                                               _loc47_ = _loc14_ + _loc47_;
                                                               _loc47_ = _loc47_ | 4;
                                                               si32(_loc8_,_loc47_);
                                                               _loc47_ = li32(_loc2_ - 268);
                                                               _loc18_ = _loc47_ + _loc8_;
                                                               si32(_loc18_,_loc2_ - 268);
                                                               _loc19_ = _loc24_ + 1;
                                                               si32(_loc19_,_loc2_ - 272);
                                                               if(_loc19_ >= 8)
                                                               {
                                                                  if(_loc18_ == 0)
                                                                  {
                                                                     _loc19_ = 0;
                                                                     si32(_loc19_,_loc2_ - 272);
                                                                     break;
                                                                  }
                                                                  var _temp_278:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_278,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_280:* = wdnative.eax;
                                                                  si32(_loc19_ = 0,_loc2_ - 268);
                                                                  si32(_loc19_,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_280 == 0)
                                                                  {
                                                                     break;
                                                                  }
                                                                  break loop2;
                                                               }
                                                               break;
                                                            }
                                                            _loc5_ = 0 - _loc13_;
                                                            while(_loc5_ > 0)
                                                            {
                                                               var _temp_281:* = _loc19_ << 3;
                                                               var _temp_282:* = int(_loc14_ + _temp_281);
                                                               si32(wdnative_nternal._zeroes,_temp_282);
                                                               _loc10_ = 16;
                                                               if(_loc5_ <= _loc10_)
                                                               {
                                                                  _loc10_ = _loc5_;
                                                               }
                                                               _loc24_ = li32(_loc2_ - 272);
                                                               _loc47_ = _loc24_ << 3;
                                                               _loc47_ = _loc14_ + _loc47_;
                                                               _loc47_ = _loc47_ | 4;
                                                               si32(_loc10_,_loc47_);
                                                               _loc47_ = li32(_loc2_ - 268);
                                                               _loc18_ = _loc47_ + _loc10_;
                                                               si32(_loc18_,_loc2_ - 268);
                                                               _loc19_ = _loc24_ + 1;
                                                               si32(_loc19_,_loc2_ - 272);
                                                               if(_loc19_ >= 8)
                                                               {
                                                                  if(_loc18_ == 0)
                                                                  {
                                                                     _loc19_ = 0;
                                                                     si32(_loc19_,_loc2_ - 272);
                                                                  }
                                                                  else
                                                                  {
                                                                     var _temp_288:* = li32(_loc2_ - 280);
                                                                     _loc1_ -= 16;
                                                                     si32(_loc26_,_loc1_ + 4);
                                                                     si32(_temp_288,_loc1_);
                                                                     wdnative.ESP = _loc1_;
                                                                     wdnative_nternal.F___sfvwrite();
                                                                     _loc1_ += 16;
                                                                     var _temp_290:* = wdnative.eax;
                                                                     si32(_loc19_ = 0,_loc2_ - 268);
                                                                     si32(_loc19_,_loc2_ - 272);
                                                                     _loc18_ = _loc30_;
                                                                     if(_temp_290 != 0)
                                                                     {
                                                                        break loop2;
                                                                     }
                                                                  }
                                                               }
                                                               _loc5_ -= _loc10_;
                                                            }
                                                            _loc13_ += _loc29_;
                                                         }
                                                         else
                                                         {
                                                            _loc18_ = li32(_loc2_ - 192);
                                                            _loc24_ = li32(_loc2_ - 160);
                                                            if(_loc24_ != 0)
                                                            {
                                                               _loc1_ -= 16;
                                                               si32(_loc18_,_loc1_ + 12);
                                                               si32(_loc15_,_loc1_ + 8);
                                                               si32(_loc16_,_loc1_ + 4);
                                                               _loc24_ = _loc2_ - 168;
                                                               si32(_loc24_,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F_grouping_print();
                                                               _loc1_ += 16;
                                                               _loc13_ = wdnative.eax;
                                                               _loc18_ = _loc30_;
                                                               if(_loc13_ < 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                            else
                                                            {
                                                               _loc19_ = _loc18_ - _loc15_;
                                                               _loc18_ = _loc13_;
                                                               if(_loc19_ <= _loc13_)
                                                               {
                                                                  _loc18_ = _loc19_;
                                                               }
                                                               _loc19_ = 0;
                                                               if(_loc18_ >= 1)
                                                               {
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  var _temp_295:* = _loc24_ << 3;
                                                                  var _temp_296:* = int(_loc14_ + _temp_295);
                                                                  si32(_loc15_,_temp_296);
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  var _temp_298:* = _loc24_ << 3;
                                                                  _loc47_ = _loc14_ + _temp_298;
                                                                  var _temp_300:* = _loc47_ | 4;
                                                                  si32(_loc18_,_temp_300);
                                                                  _loc47_ = li32(_loc2_ - 268);
                                                                  _loc10_ = _loc47_ + _loc18_;
                                                                  si32(_loc10_,_loc2_ - 268);
                                                                  _loc24_ += 1;
                                                                  si32(_loc24_,_loc2_ - 272);
                                                                  _loc19_ = _loc18_;
                                                                  if(_loc24_ >= 8)
                                                                  {
                                                                     if(_loc10_ == 0)
                                                                     {
                                                                        si32(0,_loc2_ - 272);
                                                                        _loc19_ = _loc18_;
                                                                     }
                                                                     else
                                                                     {
                                                                        var _temp_304:* = li32(_loc2_ - 280);
                                                                        _loc1_ -= 16;
                                                                        si32(_loc26_,_loc1_ + 4);
                                                                        si32(_temp_304,_loc1_);
                                                                        wdnative.ESP = _loc1_;
                                                                        wdnative_nternal.F___sfvwrite();
                                                                        _loc1_ += 16;
                                                                        var _temp_306:* = wdnative.eax;
                                                                        si32(0,_loc2_ - 268);
                                                                        si32(0,_loc2_ - 272);
                                                                        _loc19_ = _loc18_;
                                                                        _loc18_ = _loc30_;
                                                                        if(_temp_306 != 0)
                                                                        {
                                                                           break loop2;
                                                                        }
                                                                     }
                                                                  }
                                                               }
                                                               _loc10_ = _loc13_ - _loc19_;
                                                               while(_loc10_ > 0)
                                                               {
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  var _temp_308:* = _loc24_ << 3;
                                                                  var _temp_309:* = int(_loc14_ + _temp_308);
                                                                  si32(wdnative_nternal._zeroes,_temp_309);
                                                                  _loc19_ = 16;
                                                                  if(_loc10_ <= _loc19_)
                                                                  {
                                                                     _loc19_ = _loc10_;
                                                                  }
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  _loc47_ = _loc24_ << 3;
                                                                  _loc47_ = _loc14_ + _loc47_;
                                                                  _loc47_ = _loc47_ | 4;
                                                                  si32(_loc19_,_loc47_);
                                                                  _loc47_ = li32(_loc2_ - 268);
                                                                  _loc18_ = _loc47_ + _loc19_;
                                                                  si32(_loc18_,_loc2_ - 268);
                                                                  _loc24_ += 1;
                                                                  si32(_loc24_,_loc2_ - 272);
                                                                  if(_loc24_ >= 8)
                                                                  {
                                                                     if(_loc18_ == 0)
                                                                     {
                                                                        si32(0,_loc2_ - 272);
                                                                     }
                                                                     else
                                                                     {
                                                                        var _temp_315:* = li32(_loc2_ - 280);
                                                                        _loc1_ -= 16;
                                                                        si32(_loc26_,_loc1_ + 4);
                                                                        si32(_temp_315,_loc1_);
                                                                        wdnative.ESP = _loc1_;
                                                                        wdnative_nternal.F___sfvwrite();
                                                                        _loc1_ += 16;
                                                                        var _temp_317:* = wdnative.eax;
                                                                        si32(0,_loc2_ - 268);
                                                                        si32(0,_loc2_ - 272);
                                                                        _loc18_ = _loc30_;
                                                                        if(_temp_317 != 0)
                                                                        {
                                                                           break loop2;
                                                                        }
                                                                     }
                                                                  }
                                                                  _loc10_ -= _loc19_;
                                                               }
                                                            }
                                                            _loc15_ += _loc13_;
                                                            while(true)
                                                            {
                                                               if(_loc29_ == 0)
                                                               {
                                                                  var _temp_318:* = _loc31_ & 1;
                                                                  _loc13_ = 0;
                                                                  if(_temp_318 == 0)
                                                                  {
                                                                     break;
                                                                  }
                                                               }
                                                               _loc24_ = li32(_loc2_ - 272);
                                                               _loc24_ = _loc24_ << 3;
                                                               _loc24_ = _loc14_ + _loc24_;
                                                               si32(_loc12_,_loc24_);
                                                               _loc24_ = li32(_loc2_ - 272);
                                                               _loc47_ = _loc24_ << 3;
                                                               _loc47_ = _loc14_ + _loc47_;
                                                               _loc47_ = _loc47_ | 4;
                                                               si32(_loc8_,_loc47_);
                                                               _loc47_ = li32(_loc2_ - 268);
                                                               _loc18_ = _loc47_ + _loc8_;
                                                               si32(_loc18_,_loc2_ - 268);
                                                               _loc24_ += 1;
                                                               si32(_loc24_,_loc2_ - 272);
                                                               _loc13_ = _loc29_;
                                                               if(_loc24_ >= 8)
                                                               {
                                                                  if(_loc18_ == 0)
                                                                  {
                                                                     si32(0,_loc2_ - 272);
                                                                     _loc13_ = _loc29_;
                                                                     break;
                                                                  }
                                                                  var _temp_325:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_325,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_327:* = wdnative.eax;
                                                                  si32(0,_loc2_ - 268);
                                                                  si32(0,_loc2_ - 272);
                                                                  _loc13_ = _loc29_;
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_327 == 0)
                                                                  {
                                                                     break;
                                                                  }
                                                                  break loop2;
                                                               }
                                                               break;
                                                            }
                                                         }
                                                         _loc24_ = li32(_loc2_ - 192);
                                                         _loc18_ = _loc24_ - _loc15_;
                                                         _loc29_ = _loc13_;
                                                         if(_loc18_ <= _loc13_)
                                                         {
                                                            _loc29_ = _loc18_;
                                                         }
                                                         _loc19_ = 0;
                                                         if(_loc29_ >= 1)
                                                         {
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            var _temp_330:* = _loc24_ << 3;
                                                            var _temp_331:* = int(_loc14_ + _temp_330);
                                                            si32(_loc15_,_temp_331);
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            var _temp_333:* = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _temp_333;
                                                            var _temp_335:* = _loc47_ | 4;
                                                            si32(_loc29_,_temp_335);
                                                            _loc47_ = li32(_loc2_ - 268);
                                                            _loc15_ = _loc47_ + _loc29_;
                                                            si32(_loc15_,_loc2_ - 268);
                                                            _loc24_ += 1;
                                                            si32(_loc24_,_loc2_ - 272);
                                                            _loc19_ = _loc29_;
                                                            if(_loc24_ >= 8)
                                                            {
                                                               if(_loc15_ == 0)
                                                               {
                                                                  si32(0,_loc2_ - 272);
                                                                  _loc19_ = _loc29_;
                                                               }
                                                               else
                                                               {
                                                                  var _temp_339:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_339,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_341:* = wdnative.eax;
                                                                  si32(0,_loc2_ - 268);
                                                                  si32(0,_loc2_ - 272);
                                                                  _loc19_ = _loc29_;
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_341 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                         }
                                                         _loc29_ = _loc13_ - _loc19_;
                                                         while(_loc29_ > 0)
                                                         {
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            var _temp_343:* = _loc24_ << 3;
                                                            var _temp_344:* = int(_loc14_ + _temp_343);
                                                            si32(wdnative_nternal._zeroes,_temp_344);
                                                            _loc15_ = 16;
                                                            if(_loc29_ <= _loc15_)
                                                            {
                                                               _loc15_ = _loc29_;
                                                            }
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            _loc47_ = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _loc47_;
                                                            _loc47_ = _loc47_ | 4;
                                                            si32(_loc15_,_loc47_);
                                                            _loc47_ = li32(_loc2_ - 268);
                                                            _loc13_ = _loc47_ + _loc15_;
                                                            si32(_loc13_,_loc2_ - 268);
                                                            _loc24_ += 1;
                                                            si32(_loc24_,_loc2_ - 272);
                                                            if(_loc24_ >= 8)
                                                            {
                                                               if(_loc13_ == 0)
                                                               {
                                                                  si32(0,_loc2_ - 272);
                                                               }
                                                               else
                                                               {
                                                                  var _temp_350:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_350,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_352:* = wdnative.eax;
                                                                  si32(0,_loc2_ - 268);
                                                                  si32(0,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_352 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                            _loc29_ -= _loc15_;
                                                         }
                                                      }
                                                      else
                                                      {
                                                         while(true)
                                                         {
                                                            if(_loc29_ <= 1)
                                                            {
                                                               _loc24_ = _loc31_ & 1;
                                                               if(_loc24_ == 0)
                                                               {
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  var _temp_355:* = _loc24_ << 3;
                                                                  var _temp_356:* = int(_loc14_ + _temp_355);
                                                                  si32(_loc15_,_temp_356);
                                                                  _loc24_ = li32(_loc2_ - 272);
                                                                  var _temp_358:* = _loc24_ << 3;
                                                                  _loc47_ = _loc14_ + _temp_358;
                                                                  var _temp_360:* = _loc47_ | 4;
                                                                  si32(1,_temp_360);
                                                                  _loc47_ = li32(_loc2_ - 268);
                                                                  _loc29_ = _loc47_ + 1;
                                                                  si32(_loc29_,_loc2_ - 268);
                                                                  _loc15_ = _loc24_ + 1;
                                                                  si32(_loc15_,_loc2_ - 272);
                                                                  if(_loc15_ >= 8)
                                                                  {
                                                                     if(_loc29_ == 0)
                                                                     {
                                                                        _loc15_ = 0;
                                                                        si32(_loc15_,_loc2_ - 272);
                                                                        break;
                                                                     }
                                                                     var _temp_364:* = li32(_loc2_ - 280);
                                                                     _loc1_ -= 16;
                                                                     si32(_loc26_,_loc1_ + 4);
                                                                     si32(_temp_364,_loc1_);
                                                                     wdnative.ESP = _loc1_;
                                                                     wdnative_nternal.F___sfvwrite();
                                                                     _loc1_ += 16;
                                                                     var _temp_366:* = wdnative.eax;
                                                                     si32(_loc15_ = 0,_loc2_ - 268);
                                                                     si32(_loc15_,_loc2_ - 272);
                                                                     _loc18_ = _loc30_;
                                                                     if(_temp_366 == 0)
                                                                     {
                                                                        break;
                                                                     }
                                                                     break loop2;
                                                                  }
                                                                  break;
                                                               }
                                                            }
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            _loc24_ = _loc24_ << 3;
                                                            _loc24_ = _loc14_ + _loc24_;
                                                            si32(_loc15_,_loc24_);
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            _loc47_ = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _loc47_;
                                                            _loc47_ = _loc47_ | 4;
                                                            si32(1,_loc47_);
                                                            _loc47_ = li32(_loc2_ - 268);
                                                            _loc18_ = _loc47_ + 1;
                                                            si32(_loc18_,_loc2_ - 268);
                                                            _loc13_ = _loc24_ + 1;
                                                            si32(_loc13_,_loc2_ - 272);
                                                            if(_loc13_ >= 8)
                                                            {
                                                               if(_loc18_ == 0)
                                                               {
                                                                  _loc13_ = 0;
                                                                  si32(_loc13_,_loc2_ - 272);
                                                               }
                                                               else
                                                               {
                                                                  var _temp_373:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_373,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_375:* = wdnative.eax;
                                                                  si32(_loc13_ = 0,_loc2_ - 268);
                                                                  si32(_loc13_,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_375 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                            _loc24_ = _loc13_ << 3;
                                                            _loc24_ = _loc14_ + _loc24_;
                                                            si32(_loc12_,_loc24_);
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            _loc47_ = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _loc47_;
                                                            _loc47_ = _loc47_ | 4;
                                                            si32(_loc8_,_loc47_);
                                                            _loc47_ = li32(_loc2_ - 268);
                                                            _loc18_ = _loc47_ + _loc8_;
                                                            si32(_loc18_,_loc2_ - 268);
                                                            _loc13_ = _loc24_ + 1;
                                                            si32(_loc13_,_loc2_ - 272);
                                                            if(_loc13_ >= 8)
                                                            {
                                                               if(_loc18_ == 0)
                                                               {
                                                                  _loc13_ = 0;
                                                                  si32(_loc13_,_loc2_ - 272);
                                                               }
                                                               else
                                                               {
                                                                  var _temp_381:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_381,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_383:* = wdnative.eax;
                                                                  si32(_loc13_ = 0,_loc2_ - 268);
                                                                  si32(_loc13_,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_383 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                            _loc24_ = _loc15_ + 1;
                                                            _loc47_ = _loc13_ << 3;
                                                            _loc47_ = _loc14_ + _loc47_;
                                                            si32(_loc24_,_loc47_);
                                                            _loc24_ = li32(_loc2_ - 272);
                                                            _loc47_ = _loc24_ << 3;
                                                            _loc47_ = _loc14_ + _loc47_;
                                                            _loc28_ = _loc47_ | 4;
                                                            _loc47_ = _loc4_ + -1;
                                                            si32(_loc47_,_loc28_);
                                                            _loc28_ = li32(_loc2_ - 268);
                                                            _loc13_ = _loc28_ + _loc47_;
                                                            si32(_loc13_,_loc2_ - 268);
                                                            _loc15_ = _loc24_ + 1;
                                                            si32(_loc15_,_loc2_ - 272);
                                                            if(_loc15_ >= 8)
                                                            {
                                                               if(_loc13_ == 0)
                                                               {
                                                                  _loc15_ = 0;
                                                                  si32(_loc15_,_loc2_ - 272);
                                                               }
                                                               else
                                                               {
                                                                  var _temp_390:* = li32(_loc2_ - 280);
                                                                  _loc1_ -= 16;
                                                                  si32(_loc26_,_loc1_ + 4);
                                                                  si32(_temp_390,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F___sfvwrite();
                                                                  _loc1_ += 16;
                                                                  var _temp_392:* = wdnative.eax;
                                                                  si32(_loc15_ = 0,_loc2_ - 268);
                                                                  si32(_loc15_,_loc2_ - 272);
                                                                  _loc18_ = _loc30_;
                                                                  if(_temp_392 != 0)
                                                                  {
                                                                     break loop2;
                                                                  }
                                                               }
                                                            }
                                                            _loc13_ = _loc29_ - _loc4_;
                                                            while(_loc13_ > 0)
                                                            {
                                                               var _temp_393:* = _loc15_ << 3;
                                                               var _temp_394:* = int(_loc14_ + _temp_393);
                                                               si32(wdnative_nternal._zeroes,_temp_394);
                                                               _loc29_ = 16;
                                                               if(_loc13_ <= _loc29_)
                                                               {
                                                                  _loc29_ = _loc13_;
                                                               }
                                                               _loc24_ = li32(_loc2_ - 272);
                                                               _loc47_ = _loc24_ << 3;
                                                               _loc47_ = _loc14_ + _loc47_;
                                                               _loc47_ = _loc47_ | 4;
                                                               si32(_loc29_,_loc47_);
                                                               _loc47_ = li32(_loc2_ - 268);
                                                               _loc18_ = _loc47_ + _loc29_;
                                                               si32(_loc18_,_loc2_ - 268);
                                                               _loc15_ = _loc24_ + 1;
                                                               si32(_loc15_,_loc2_ - 272);
                                                               if(_loc15_ >= 8)
                                                               {
                                                                  if(_loc18_ == 0)
                                                                  {
                                                                     _loc15_ = 0;
                                                                     si32(_loc15_,_loc2_ - 272);
                                                                  }
                                                                  else
                                                                  {
                                                                     var _temp_400:* = li32(_loc2_ - 280);
                                                                     _loc1_ -= 16;
                                                                     si32(_loc26_,_loc1_ + 4);
                                                                     si32(_temp_400,_loc1_);
                                                                     wdnative.ESP = _loc1_;
                                                                     wdnative_nternal.F___sfvwrite();
                                                                     _loc1_ += 16;
                                                                     var _temp_402:* = wdnative.eax;
                                                                     si32(_loc15_ = 0,_loc2_ - 268);
                                                                     si32(_loc15_,_loc2_ - 272);
                                                                     _loc18_ = _loc30_;
                                                                     if(_temp_402 != 0)
                                                                     {
                                                                        break loop2;
                                                                     }
                                                                  }
                                                               }
                                                               _loc13_ -= _loc29_;
                                                            }
                                                            break;
                                                         }
                                                         _loc24_ = _loc15_ << 3;
                                                         _loc24_ = _loc14_ + _loc24_;
                                                         si32(_loc44_,_loc24_);
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         _loc47_ = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _loc47_;
                                                         _loc47_ = _loc47_ | 4;
                                                         si32(_loc3_,_loc47_);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc29_ = _loc47_ + _loc3_;
                                                         si32(_loc29_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc29_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_408:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_408,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_410:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_410 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                      }
                                                   }
                                                   _loc24_ = _loc31_ & 4;
                                                   if(_loc24_ != 0)
                                                   {
                                                      _loc29_ = _loc32_ - _loc11_;
                                                      while(_loc29_ > 0)
                                                      {
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         var _temp_413:* = _loc24_ << 3;
                                                         var _temp_414:* = int(_loc14_ + _temp_413);
                                                         si32(wdnative_nternal._blanks,_temp_414);
                                                         _loc32_ = 16;
                                                         if(_loc29_ <= _loc32_)
                                                         {
                                                            _loc32_ = _loc29_;
                                                         }
                                                         _loc24_ = li32(_loc2_ - 272);
                                                         _loc47_ = _loc24_ << 3;
                                                         _loc47_ = _loc14_ + _loc47_;
                                                         _loc47_ = _loc47_ | 4;
                                                         si32(_loc32_,_loc47_);
                                                         _loc47_ = li32(_loc2_ - 268);
                                                         _loc31_ = _loc47_ + _loc32_;
                                                         si32(_loc31_,_loc2_ - 268);
                                                         _loc24_ += 1;
                                                         si32(_loc24_,_loc2_ - 272);
                                                         if(_loc24_ >= 8)
                                                         {
                                                            if(_loc31_ == 0)
                                                            {
                                                               si32(0,_loc2_ - 272);
                                                            }
                                                            else
                                                            {
                                                               var _temp_420:* = li32(_loc2_ - 280);
                                                               _loc1_ -= 16;
                                                               si32(_loc26_,_loc1_ + 4);
                                                               si32(_temp_420,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F___sfvwrite();
                                                               _loc1_ += 16;
                                                               var _temp_422:* = wdnative.eax;
                                                               si32(0,_loc2_ - 268);
                                                               si32(0,_loc2_ - 272);
                                                               _loc18_ = _loc30_;
                                                               if(_temp_422 != 0)
                                                               {
                                                                  break loop2;
                                                               }
                                                            }
                                                         }
                                                         _loc29_ -= _loc32_;
                                                      }
                                                   }
                                                   _loc24_ = li32(_loc2_ - 268);
                                                   if(_loc24_ == 0)
                                                   {
                                                      si32(0,_loc2_ - 272);
                                                      break loop5;
                                                   }
                                                   var _temp_424:* = li32(_loc2_ - 280);
                                                   _loc1_ -= 16;
                                                   si32(_loc26_,_loc1_ + 4);
                                                   si32(_temp_424,_loc1_);
                                                   wdnative.ESP = _loc1_;
                                                   wdnative_nternal.F___sfvwrite();
                                                   _loc1_ += 16;
                                                   var _temp_426:* = wdnative.eax;
                                                   si32(0,_loc2_ - 268);
                                                   si32(0,_loc2_ - 272);
                                                   _loc18_ = _loc35_;
                                                   if(_temp_426 != 0)
                                                   {
                                                      break loop2;
                                                   }
                                                   break loop5;
                                                }
                                                break loop2;
                                             }
                                             _loc15_ += 4;
                                             while(true)
                                             {
                                                _loc13_ = li32(_loc15_);
                                                _loc24_ = _loc13_ + -16843009;
                                                _loc47_ = _loc13_ & -2139062144;
                                                _loc47_ = _loc47_ ^ -2139062144;
                                                _loc24_ = _loc47_ & _loc24_;
                                                if(_loc24_ != 0)
                                                {
                                                   _loc24_ = _loc13_ & 0xFF;
                                                   if(_loc24_ == 0)
                                                   {
                                                      _loc18_ = _loc15_ - _loc25_;
                                                      break;
                                                   }
                                                   _loc24_ = li8(_loc15_ + 1);
                                                   if(_loc24_ == 0)
                                                   {
                                                      _loc24_ = 1 - _loc25_;
                                                      _loc18_ = _loc24_ + _loc15_;
                                                      break;
                                                   }
                                                   _loc24_ = li8(_loc15_ + 2);
                                                   if(_loc24_ == 0)
                                                   {
                                                      _loc24_ = 2 - _loc25_;
                                                      _loc18_ = _loc24_ + _loc15_;
                                                      break;
                                                   }
                                                   _loc24_ = li8(_loc15_ + 3);
                                                   if(_loc24_ == 0)
                                                   {
                                                      _loc24_ = 3 - _loc25_;
                                                      _loc18_ = _loc24_ + _loc15_;
                                                      break;
                                                   }
                                                }
                                                _loc15_ += 4;
                                             }
                                             §§goto(addr18b8);
                                          }
                                       }
                                    }
                                 }
                              }
                              else if(_loc11_ != 68)
                              {
                                 while(true)
                                 {
                                    if(_loc11_ != 69)
                                    {
                                       if(_loc11_ != 70)
                                       {
                                          §§goto(addr2f9b);
                                       }
                                    }
                                    else
                                    {
                                       addr11f9:
                                       _loc25_ = 7;
                                       if(_loc29_ >= 0)
                                       {
                                          _loc25_ = _loc29_ + 1;
                                       }
                                       _loc29_ = _loc25_;
                                       _loc10_ = _loc11_;
                                    }
                                    addr1231:
                                    _loc18_ = 6;
                                    if(_loc29_ >= 0)
                                    {
                                       _loc18_ = _loc29_;
                                    }
                                    if(_loc36_ != 0)
                                    {
                                       _loc25_ = li32(_loc36_ - 4);
                                       si32(_loc25_,_loc36_);
                                       _loc24_ = 1 << _loc25_;
                                       si32(_loc24_,_loc36_ + 4);
                                       _loc36_ += -4;
                                       if(_loc36_ != 0)
                                       {
                                          if(_loc25_ >= 10)
                                          {
                                             _loc1_ -= 16;
                                             si32(_loc36_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F_idalloc();
                                             _loc1_ += 16;
                                          }
                                          else
                                          {
                                             var _temp_442:* = _loc25_ << 2;
                                             _loc47_ = wdnative_nternal._freelist + _temp_442;
                                             _loc24_ = li32(_loc47_);
                                             si32(_loc24_,_loc36_);
                                             si32(_loc36_,_loc47_);
                                          }
                                       }
                                    }
                                    _loc24_ = _loc35_ & 8;
                                    _loc36_ = li32(_loc2_ - 320);
                                    if(_loc24_ != 0)
                                    {
                                       if(_loc36_ != 0)
                                       {
                                          var _temp_445:* = _loc33_ << 3;
                                          _loc36_ += _temp_445;
                                       }
                                       else
                                       {
                                          var _temp_446:* = int(_loc22_ + 8);
                                          _loc36_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc39_ = lf64(_loc36_);
                                       sf64(_loc39_,_loc2_ - 184);
                                       _loc1_ -= 32;
                                       _loc24_ = _loc2_ - 192;
                                       si32(_loc24_,_loc1_ + 20);
                                       _loc24_ = _loc2_ - 172;
                                       si32(_loc24_,_loc1_ + 16);
                                       _loc24_ = _loc2_ - 188;
                                       si32(_loc24_,_loc1_ + 12);
                                       si32(_loc18_,_loc1_ + 8);
                                       _loc24_ = _loc10_ & 0xFF;
                                       _loc36_ = 3;
                                       if(_loc24_ != 0)
                                       {
                                          _loc36_ = 2;
                                       }
                                       si32(_loc36_,_loc1_ + 4);
                                       _loc24_ = _loc2_ - 184;
                                       si32(_loc24_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F___ldtoa();
                                       _loc33_ += 1;
                                       _loc1_ += 32;
                                       _loc36_ = wdnative.eax;
                                    }
                                    else
                                    {
                                       if(_loc36_ != 0)
                                       {
                                          var _temp_453:* = _loc33_ << 3;
                                          _loc36_ += _temp_453;
                                       }
                                       else
                                       {
                                          var _temp_454:* = int(_loc22_ + 8);
                                          _loc36_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc38_ = lf64(_loc36_);
                                       sf64(_loc38_,_loc2_ - 184);
                                       _loc1_ -= 32;
                                       _loc24_ = _loc2_ - 192;
                                       si32(_loc24_,_loc1_ + 24);
                                       _loc24_ = _loc2_ - 172;
                                       si32(_loc24_,_loc1_ + 20);
                                       _loc24_ = _loc2_ - 188;
                                       si32(_loc24_,_loc1_ + 16);
                                       si32(_loc18_,_loc1_ + 12);
                                       _loc24_ = _loc10_ & 0xFF;
                                       _loc36_ = 3;
                                       if(_loc24_ != 0)
                                       {
                                          _loc36_ = 2;
                                       }
                                       si32(_loc36_,_loc1_ + 8);
                                       sf64(_loc38_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F___dtoa();
                                       _loc33_ += 1;
                                       _loc1_ += 32;
                                       _loc36_ = wdnative.eax;
                                       _loc24_ = li32(_loc2_ - 188);
                                       if(_loc24_ == 9999)
                                       {
                                          si32(2147483647,_loc2_ - 188);
                                       }
                                    }
                                    §§goto(addr145d);
                                 }
                              }
                              else
                              {
                                 _loc35_ |= 16;
                                 addr0d00:
                                 _loc24_ = _loc35_ & 0x1C20;
                                 if(_loc24_ != 0)
                                 {
                                    _loc24_ = _loc35_ & 0x1000;
                                    if(_loc24_ != 0)
                                    {
                                       _loc17_ = li32(_loc2_ - 320);
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_464:* = _loc33_ << 3;
                                          _loc23_ = _loc17_ + _temp_464;
                                       }
                                       else
                                       {
                                          var _temp_465:* = int(_loc22_ + 8);
                                          _loc23_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc17_ = li32(_loc23_ + 4);
                                       _loc23_ = li32(_loc23_);
                                    }
                                    else
                                    {
                                       _loc24_ = _loc35_ & 0x0400;
                                       if(_loc24_ != 0)
                                       {
                                          _loc17_ = li32(_loc2_ - 320);
                                          if(_loc17_ != 0)
                                          {
                                             var _temp_468:* = _loc33_ << 3;
                                             _loc17_ += _temp_468;
                                          }
                                          else
                                          {
                                             var _temp_469:* = int(_loc22_ + 4);
                                             _loc17_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc23_ = li32(_loc17_);
                                          _loc17_ = _loc23_ >> 31;
                                       }
                                       else
                                       {
                                          var _temp_471:* = _loc35_ & 0x0800;
                                          _loc17_ = li32(_loc2_ - 320);
                                          if(_temp_471 != 0)
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_472:* = _loc33_ << 3;
                                                _loc17_ += _temp_472;
                                             }
                                             else
                                             {
                                                var _temp_473:* = int(_loc22_ + 4);
                                                _loc17_ = _loc22_;
                                                _loc22_ += 4;
                                             }
                                             _loc23_ = li32(_loc17_);
                                             _loc17_ = _loc23_ >> 31;
                                          }
                                          else
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_475:* = _loc33_ << 3;
                                                _loc23_ = _loc17_ + _temp_475;
                                             }
                                             else
                                             {
                                                var _temp_476:* = int(_loc22_ + 8);
                                                _loc23_ = _loc22_;
                                                _loc22_ += 8;
                                             }
                                             _loc17_ = li32(_loc23_ + 4);
                                             _loc23_ = li32(_loc23_);
                                          }
                                       }
                                    }
                                    _loc33_ += 1;
                                    _loc11_ = 10;
                                    if(_loc17_ <= -1)
                                    {
                                       si8(45,_loc2_ - 139);
                                       _loc31_ = 1;
                                       if(_loc23_ == 0)
                                       {
                                          _loc31_ = 0;
                                       }
                                       _loc24_ = 0 - _loc17_;
                                       _loc17_ = _loc24_ - _loc31_;
                                       _loc23_ = 0 - _loc23_;
                                       _loc11_ = 10;
                                    }
                                 }
                                 else
                                 {
                                    _loc24_ = _loc35_ & 0x10;
                                    if(_loc24_ != 0)
                                    {
                                       _loc21_ = li32(_loc2_ - 320);
                                       if(_loc21_ != 0)
                                       {
                                          var _temp_480:* = _loc33_ << 3;
                                          _loc21_ += _temp_480;
                                       }
                                       else
                                       {
                                          var _temp_481:* = int(_loc22_ + 4);
                                          _loc21_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc21_ = li32(_loc21_);
                                    }
                                    else
                                    {
                                       _loc24_ = _loc35_ & 0x40;
                                       if(_loc24_ != 0)
                                       {
                                          _loc21_ = li32(_loc2_ - 320);
                                          if(_loc21_ != 0)
                                          {
                                             var _temp_484:* = _loc33_ << 3;
                                             _loc21_ += _temp_484;
                                          }
                                          else
                                          {
                                             var _temp_485:* = int(_loc22_ + 4);
                                             _loc21_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc21_ = si16(li16(_loc21_));
                                       }
                                       else
                                       {
                                          var _temp_486:* = _loc35_ & 0x2000;
                                          _loc21_ = li32(_loc2_ - 320);
                                          if(_temp_486 != 0)
                                          {
                                             if(_loc21_ != 0)
                                             {
                                                var _temp_487:* = _loc33_ << 3;
                                                _loc21_ += _temp_487;
                                             }
                                             else
                                             {
                                                var _temp_488:* = int(_loc22_ + 4);
                                                _loc21_ = _loc22_;
                                                _loc22_ += 4;
                                             }
                                             _loc21_ = si8(li8(_loc21_));
                                          }
                                          else
                                          {
                                             if(_loc21_ != 0)
                                             {
                                                var _temp_489:* = _loc33_ << 3;
                                                _loc21_ += _temp_489;
                                             }
                                             else
                                             {
                                                var _temp_490:* = int(_loc22_ + 4);
                                                _loc21_ = _loc22_;
                                                _loc22_ += 4;
                                             }
                                             _loc21_ = li32(_loc21_);
                                          }
                                       }
                                    }
                                    _loc33_ += 1;
                                    _loc11_ = 10;
                                    if(_loc21_ <= -1)
                                    {
                                       si8(45,_loc2_ - 139);
                                       _loc21_ = 0 - _loc21_;
                                       _loc11_ = 10;
                                    }
                                 }
                                 addr2938:
                                 _loc31_ = _loc35_ & -129;
                                 if(_loc29_ <= -1)
                                 {
                                    _loc31_ = _loc35_;
                                 }
                                 loop46:
                                 while(true)
                                 {
                                    _loc24_ = _loc31_ & 0x1C20;
                                    if(_loc24_ != 0)
                                    {
                                       var _temp_492:* = _loc23_ | _loc17_;
                                       _loc19_ = _loc31_ & 1;
                                       if(_temp_492 == 0)
                                       {
                                          if(_loc29_ == 0)
                                          {
                                             _loc15_ = _loc49_;
                                             if(_loc19_ == 0)
                                             {
                                                break;
                                             }
                                             _loc15_ = _loc49_;
                                             if(_loc11_ != 8)
                                             {
                                                break;
                                             }
                                          }
                                       }
                                       if(_loc17_ == 0)
                                       {
                                          _loc1_ -= 32;
                                          si32(_loc27_,_loc1_ + 16);
                                          si32(_loc19_,_loc1_ + 12);
                                          si32(_loc11_,_loc1_ + 8);
                                          si32(_loc49_,_loc1_ + 4);
                                          si32(_loc23_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F___ultoa();
                                          _loc1_ += 32;
                                          _loc15_ = wdnative.eax;
                                          break;
                                       }
                                       _loc15_ = _loc49_;
                                       _loc18_ = _loc41_;
                                       _loc13_ = _loc23_;
                                       _loc35_ = _loc17_;
                                       if(_loc11_ == 8)
                                       {
                                          do
                                          {
                                             _loc24_ = _loc13_ & 7;
                                             _loc11_ = _loc24_ | 0x30;
                                             si8(_loc11_,_loc18_);
                                             _loc47_ = _loc13_ >>> 3;
                                             _loc24_ = _loc35_ << 29;
                                             _loc13_ = _loc47_ | _loc24_;
                                             _loc35_ >>>= 3;
                                             _loc24_ = _loc13_ | _loc35_;
                                             _loc15_ += -1;
                                             _loc18_ += -1;
                                          }
                                          while(_loc24_ != 0);
                                          if(_loc19_ != 0)
                                          {
                                             _loc24_ = _loc11_ & 0xFF;
                                             if(_loc24_ != 48)
                                             {
                                                si8(48,_loc18_);
                                                _loc15_ = _loc18_;
                                             }
                                          }
                                          break;
                                       }
                                       _loc15_ = _loc49_;
                                       _loc35_ = _loc23_;
                                       _loc13_ = _loc17_;
                                       if(_loc11_ == 16)
                                       {
                                          while(true)
                                          {
                                             _loc24_ = _loc35_ & 0x0F;
                                             _loc24_ = _loc27_ + _loc24_;
                                             _loc24_ = li8(_loc24_);
                                             si8(_loc24_,_loc15_ - 1);
                                             _loc47_ = _loc35_ >>> 4;
                                             _loc24_ = _loc13_ << 28;
                                             _loc35_ = _loc47_ | _loc24_;
                                             _loc13_ >>>= 4;
                                             _loc24_ = _loc35_ | _loc13_;
                                             _loc15_ += -1;
                                             if(_loc24_ == 0)
                                             {
                                                break loop46;
                                             }
                                          }
                                          break;
                                       }
                                       if(_loc11_ == 10)
                                       {
                                          _loc15_ = _loc49_;
                                          _loc7_ = _loc23_;
                                          _loc19_ = _loc17_;
                                          if(_loc17_ <= -1)
                                          {
                                             _loc1_ -= 16;
                                             si32(0,_loc1_ + 12);
                                             si32(10,_loc1_ + 8);
                                             si32(_loc23_,_loc1_);
                                             si32(_loc17_,_loc1_ + 4);
                                             wdnative.ESP = _loc1_;
                                             F___udivdi3();
                                             _loc1_ += 16;
                                             _loc7_ = wdnative.eax;
                                             _loc19_ = wdnative.edx;
                                             _loc1_ -= 16;
                                             si32(0,_loc1_ + 12);
                                             si32(10,_loc1_ + 8);
                                             si32(_loc17_,_loc1_ + 4);
                                             si32(_loc23_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             F___umoddi3();
                                             _loc1_ += 16;
                                             _loc24_ = wdnative.eax;
                                             _loc24_ = _loc24_ | 0x30;
                                             si8(_loc24_,_loc2_ - 281);
                                             _loc15_ = _loc41_;
                                          }
                                          do
                                          {
                                             _loc1_ -= 16;
                                             si32(0,_loc1_ + 12);
                                             si32(10,_loc1_ + 8);
                                             si32(_loc7_,_loc1_);
                                             si32(_loc19_,_loc1_ + 4);
                                             wdnative.ESP = _loc1_;
                                             F___divdi3();
                                             _loc1_ += 16;
                                             _loc13_ = wdnative.eax;
                                             _loc35_ = wdnative.edx;
                                             _loc1_ -= 16;
                                             si32(0,_loc1_ + 12);
                                             si32(10,_loc1_ + 8);
                                             si32(_loc19_,_loc1_ + 4);
                                             si32(_loc7_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             F___moddi3();
                                             _loc1_ += 16;
                                             _loc24_ = wdnative.eax;
                                             _loc24_ = _loc24_ + 48;
                                             si8(_loc24_,_loc15_ - 1);
                                             _loc10_ = _loc7_ + 9;
                                             _loc11_ = _loc18_ = 1;
                                             if(uint(_loc10_) <= 18)
                                             {
                                                _loc11_ = 0;
                                             }
                                             _loc5_ = _loc18_;
                                             if(uint(_loc10_) >= uint(_loc7_))
                                             {
                                                _loc5_ = 0;
                                             }
                                             _loc7_ = _loc18_;
                                             if(uint(_loc10_) >= 9)
                                             {
                                                _loc7_ = _loc5_;
                                             }
                                             _loc19_ += _loc7_;
                                             if(_loc19_ == 0)
                                             {
                                                _loc18_ = 0;
                                             }
                                             if(_loc19_ != 0)
                                             {
                                                _loc11_ = _loc18_;
                                             }
                                             _loc15_ += -1;
                                             _loc7_ = _loc13_;
                                             _loc19_ = _loc35_;
                                          }
                                          while(_loc11_ != 0);
                                          break;
                                       }
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F_abort();
                                    }
                                    _loc24_ = _loc21_ | _loc29_;
                                    _loc35_ = _loc31_ & 1;
                                    if(_loc24_ == 0)
                                    {
                                       _loc15_ = _loc49_;
                                       if(_loc35_ == 0)
                                       {
                                          break;
                                       }
                                       _loc15_ = _loc49_;
                                       if(_loc11_ != 8)
                                       {
                                          break;
                                       }
                                    }
                                    _loc1_ -= 32;
                                    si32(_loc27_,_loc1_ + 16);
                                    si32(_loc35_,_loc1_ + 12);
                                    si32(_loc11_,_loc1_ + 8);
                                    si32(_loc49_,_loc1_ + 4);
                                    si32(_loc21_,_loc1_);
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F___ultoa();
                                    _loc1_ += 32;
                                    _loc15_ = wdnative.eax;
                                    break;
                                 }
                                 _loc35_ = _loc49_ - _loc15_;
                                 if(_loc35_ >= 33)
                                 {
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F_abort();
                                 }
                                 _loc24_ = _loc31_ & 0x0200;
                                 _loc19_ = _loc29_;
                                 _loc13_ = _loc35_;
                                 if(_loc24_ != 0)
                                 {
                                    _loc19_ = _loc29_;
                                    _loc13_ = _loc35_;
                                    if(_loc49_ != _loc15_)
                                    {
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F_localeconv();
                                       _loc11_ = li32(wdnative_nternal._ret_2E_1143 + 8);
                                       si32(_loc11_,_loc2_ - 160);
                                       _loc13_ = li32(wdnative_nternal._ret_2E_1143 + 4);
                                       si32(_loc13_,_loc2_ - 168);
                                       _loc5_ = _loc13_ & -4;
                                       _loc47_ = li32(_loc5_);
                                       var _temp_519:* = int(_loc47_ + -16843009);
                                       _loc24_ = (_loc47_ = (_loc47_ &= -2139062144) ^ -2139062144) & _temp_519;
                                       if(_loc24_ != 0)
                                       {
                                          _loc10_ = _loc5_ + 4;
                                          _loc18_ = 0;
                                          while(true)
                                          {
                                             _loc19_ = _loc13_ + _loc18_;
                                             if((uint(_loc19_)) < uint(_loc10_))
                                             {
                                                _loc24_ = li8(_loc19_);
                                                if(_loc24_ == 0)
                                                {
                                                   break;
                                                }
                                                _loc18_ += 1;
                                                continue;
                                             }
                                          }
                                          addr2eba:
                                          _loc24_ = _loc2_ - 168;
                                          _loc24_ = _loc24_ | 4;
                                          si32(_loc18_,_loc24_);
                                          _loc7_ = 0;
                                          si32(_loc7_,_loc2_ - 148);
                                          si32(_loc7_,_loc2_ - 152);
                                          si32(_loc35_,_loc2_ - 156);
                                          _loc5_ = _loc35_;
                                          _loc10_ = _loc7_;
                                          loop25:
                                          while(true)
                                          {
                                             _loc24_ = _loc10_ + _loc7_;
                                             _loc24_ = _loc18_ * _loc24_;
                                             _loc13_ = _loc35_ + _loc24_;
                                             _loc7_ += 1;
                                             while(true)
                                             {
                                                _loc6_ = li8(_loc11_);
                                                _loc19_ = _loc29_;
                                                if(_loc6_ == 127)
                                                {
                                                   break loop25;
                                                }
                                                _loc24_ = _loc6_ << 24;
                                                _loc6_ = _loc24_ >> 24;
                                                _loc19_ = _loc29_;
                                                if(_loc5_ <= _loc6_)
                                                {
                                                   break loop25;
                                                }
                                                _loc19_ = _loc11_ + 1;
                                                _loc5_ -= _loc6_;
                                                si32(_loc5_,_loc2_ - 156);
                                                _loc24_ = li8(_loc19_);
                                                if(_loc24_ == 0)
                                                {
                                                   break;
                                                }
                                                _loc10_ += 1;
                                                si32(_loc10_,_loc2_ - 152);
                                                si32(_loc19_,_loc2_ - 160);
                                                _loc13_ += _loc18_;
                                                _loc11_ = _loc19_;
                                             }
                                             si32(_loc7_,_loc2_ - 148);
                                          }
                                          §§goto(addr2fc8);
                                       }
                                       _loc19_ = _loc5_ + 4;
                                       while(true)
                                       {
                                          _loc18_ = li32(_loc19_);
                                          _loc24_ = _loc18_ + -16843009;
                                          _loc47_ = _loc18_ & -2139062144;
                                          _loc47_ = _loc47_ ^ -2139062144;
                                          _loc24_ = _loc47_ & _loc24_;
                                          if(_loc24_ != 0)
                                          {
                                             _loc24_ = _loc18_ & 0xFF;
                                             if(_loc24_ == 0)
                                             {
                                                _loc18_ = _loc19_ - _loc13_;
                                                break;
                                             }
                                             _loc24_ = li8(_loc19_ + 1);
                                             if(_loc24_ == 0)
                                             {
                                                _loc24_ = 1 - _loc13_;
                                                _loc18_ = _loc24_ + _loc19_;
                                                break;
                                             }
                                             _loc24_ = li8(_loc19_ + 2);
                                             if(_loc24_ == 0)
                                             {
                                                _loc24_ = 2 - _loc13_;
                                                _loc18_ = _loc24_ + _loc19_;
                                                break;
                                             }
                                             _loc24_ = li8(_loc19_ + 3);
                                             if(_loc24_ == 0)
                                             {
                                                _loc24_ = 3 - _loc13_;
                                                _loc18_ = _loc24_ + _loc19_;
                                                break;
                                             }
                                          }
                                          _loc19_ += 4;
                                       }
                                       §§goto(addr2eba);
                                    }
                                 }
                              }
                           }
                           else if(_loc11_ <= 78)
                           {
                              if(_loc11_ == 71)
                              {
                                 break loop4;
                              }
                              if(_loc11_ == 76)
                              {
                                 _loc35_ |= 8;
                                 break loop6;
                              }
                              §§goto(addr2f9b);
                           }
                           else
                           {
                              if(_loc11_ == 79)
                              {
                                 _loc35_ |= 16;
                                 addr1c75:
                                 _loc24_ = _loc35_ & 0x1C20;
                                 if(_loc24_ != 0)
                                 {
                                    _loc24_ = _loc35_ & 0x1000;
                                    if(_loc24_ != 0)
                                    {
                                       _loc17_ = li32(_loc2_ - 320);
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_635:* = _loc33_ << 3;
                                          _loc23_ = _loc17_ + _temp_635;
                                       }
                                       else
                                       {
                                          var _temp_636:* = int(_loc22_ + 8);
                                          _loc23_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc17_ = li32(_loc23_ + 4);
                                       _loc23_ = li32(_loc23_);
                                       _loc11_ = 8;
                                       break;
                                    }
                                    _loc24_ = _loc35_ & 0x0400;
                                    if(_loc24_ != 0)
                                    {
                                       _loc17_ = li32(_loc2_ - 320);
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_639:* = _loc33_ << 3;
                                          _loc17_ += _temp_639;
                                       }
                                       else
                                       {
                                          var _temp_640:* = int(_loc22_ + 4);
                                          _loc17_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc23_ = li32(_loc17_);
                                       _loc17_ = 0;
                                       _loc11_ = 8;
                                       break;
                                    }
                                    var _temp_641:* = _loc35_ & 0x0800;
                                    _loc17_ = li32(_loc2_ - 320);
                                    if(_temp_641 != 0)
                                    {
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_642:* = _loc33_ << 3;
                                          _loc17_ += _temp_642;
                                       }
                                       else
                                       {
                                          var _temp_643:* = int(_loc22_ + 4);
                                          _loc17_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc23_ = li32(_loc17_);
                                       _loc17_ = _loc23_ >> 31;
                                       _loc11_ = 8;
                                       break;
                                    }
                                    if(_loc17_ != 0)
                                    {
                                       var _temp_645:* = _loc33_ << 3;
                                       _loc23_ = _loc17_ + _temp_645;
                                    }
                                    else
                                    {
                                       var _temp_646:* = int(_loc22_ + 8);
                                       _loc23_ = _loc22_;
                                       _loc22_ += 8;
                                    }
                                    _loc17_ = li32(_loc23_ + 4);
                                    _loc23_ = li32(_loc23_);
                                    _loc11_ = 8;
                                    break;
                                 }
                                 _loc24_ = _loc35_ & 0x10;
                                 if(_loc24_ != 0)
                                 {
                                    _loc21_ = li32(_loc2_ - 320);
                                    if(_loc21_ != 0)
                                    {
                                       var _temp_649:* = _loc33_ << 3;
                                       _loc21_ += _temp_649;
                                    }
                                    else
                                    {
                                       var _temp_650:* = int(_loc22_ + 4);
                                       _loc21_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc21_ = li32(_loc21_);
                                    _loc11_ = 8;
                                    break;
                                 }
                                 _loc24_ = _loc35_ & 0x40;
                                 if(_loc24_ != 0)
                                 {
                                    _loc21_ = li32(_loc2_ - 320);
                                    if(_loc21_ != 0)
                                    {
                                       var _temp_653:* = _loc33_ << 3;
                                       _loc21_ += _temp_653;
                                    }
                                    else
                                    {
                                       var _temp_654:* = int(_loc22_ + 4);
                                       _loc21_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc21_ = li16(_loc21_);
                                    _loc11_ = 8;
                                    break;
                                 }
                                 var _temp_655:* = _loc35_ & 0x2000;
                                 _loc21_ = li32(_loc2_ - 320);
                                 if(_temp_655 != 0)
                                 {
                                    if(_loc21_ != 0)
                                    {
                                       var _temp_656:* = _loc33_ << 3;
                                       _loc21_ += _temp_656;
                                    }
                                    else
                                    {
                                       var _temp_657:* = int(_loc22_ + 4);
                                       _loc21_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc21_ = li8(_loc21_);
                                    _loc11_ = 8;
                                    break;
                                 }
                                 if(_loc21_ != 0)
                                 {
                                    var _temp_658:* = _loc33_ << 3;
                                    _loc21_ += _temp_658;
                                 }
                                 else
                                 {
                                    var _temp_659:* = int(_loc22_ + 4);
                                    _loc21_ = _loc22_;
                                    _loc22_ += 4;
                                 }
                                 _loc21_ = li32(_loc21_);
                                 _loc11_ = 8;
                                 break;
                              }
                              if(_loc11_ != 83)
                              {
                                 if(_loc11_ == 85)
                                 {
                                    _loc35_ |= 16;
                                    addr2422:
                                    _loc24_ = _loc35_ & 0x1C20;
                                    if(_loc24_ != 0)
                                    {
                                       _loc24_ = _loc35_ & 0x1000;
                                       if(_loc24_ != 0)
                                       {
                                          _loc17_ = li32(_loc2_ - 320);
                                          if(_loc17_ != 0)
                                          {
                                             var _temp_546:* = _loc33_ << 3;
                                             _loc23_ = _loc17_ + _temp_546;
                                          }
                                          else
                                          {
                                             var _temp_547:* = int(_loc22_ + 8);
                                             _loc23_ = _loc22_;
                                             _loc22_ += 8;
                                          }
                                          _loc17_ = li32(_loc23_ + 4);
                                          _loc23_ = li32(_loc23_);
                                          _loc11_ = 10;
                                          break;
                                       }
                                       _loc24_ = _loc35_ & 0x0400;
                                       if(_loc24_ != 0)
                                       {
                                          _loc17_ = li32(_loc2_ - 320);
                                          if(_loc17_ != 0)
                                          {
                                             var _temp_550:* = _loc33_ << 3;
                                             _loc17_ += _temp_550;
                                          }
                                          else
                                          {
                                             var _temp_551:* = int(_loc22_ + 4);
                                             _loc17_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc23_ = li32(_loc17_);
                                          _loc17_ = 0;
                                          _loc11_ = 10;
                                          break;
                                       }
                                       var _temp_552:* = _loc35_ & 0x0800;
                                       _loc17_ = li32(_loc2_ - 320);
                                       if(_temp_552 != 0)
                                       {
                                          if(_loc17_ != 0)
                                          {
                                             var _temp_553:* = _loc33_ << 3;
                                             _loc17_ += _temp_553;
                                          }
                                          else
                                          {
                                             var _temp_554:* = int(_loc22_ + 4);
                                             _loc17_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc23_ = li32(_loc17_);
                                          _loc17_ = _loc23_ >> 31;
                                          _loc11_ = 10;
                                          break;
                                       }
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_556:* = _loc33_ << 3;
                                          _loc23_ = _loc17_ + _temp_556;
                                       }
                                       else
                                       {
                                          var _temp_557:* = int(_loc22_ + 8);
                                          _loc23_ = _loc22_;
                                          _loc22_ += 8;
                                       }
                                       _loc17_ = li32(_loc23_ + 4);
                                       _loc23_ = li32(_loc23_);
                                       _loc11_ = 10;
                                       break;
                                    }
                                    _loc24_ = _loc35_ & 0x10;
                                    if(_loc24_ != 0)
                                    {
                                       _loc21_ = li32(_loc2_ - 320);
                                       if(_loc21_ != 0)
                                       {
                                          var _temp_560:* = _loc33_ << 3;
                                          _loc21_ += _temp_560;
                                       }
                                       else
                                       {
                                          var _temp_561:* = int(_loc22_ + 4);
                                          _loc21_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc21_ = li32(_loc21_);
                                       _loc11_ = 10;
                                       break;
                                    }
                                    _loc24_ = _loc35_ & 0x40;
                                    if(_loc24_ != 0)
                                    {
                                       _loc21_ = li32(_loc2_ - 320);
                                       if(_loc21_ != 0)
                                       {
                                          var _temp_564:* = _loc33_ << 3;
                                          _loc21_ += _temp_564;
                                       }
                                       else
                                       {
                                          var _temp_565:* = int(_loc22_ + 4);
                                          _loc21_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc21_ = li16(_loc21_);
                                       _loc11_ = 10;
                                       break;
                                    }
                                    var _temp_566:* = _loc35_ & 0x2000;
                                    _loc21_ = li32(_loc2_ - 320);
                                    if(_temp_566 != 0)
                                    {
                                       if(_loc21_ != 0)
                                       {
                                          var _temp_567:* = _loc33_ << 3;
                                          _loc21_ += _temp_567;
                                       }
                                       else
                                       {
                                          var _temp_568:* = int(_loc22_ + 4);
                                          _loc21_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc21_ = li8(_loc21_);
                                       _loc11_ = 10;
                                       break;
                                    }
                                    if(_loc21_ != 0)
                                    {
                                       var _temp_569:* = _loc33_ << 3;
                                       _loc21_ += _temp_569;
                                    }
                                    else
                                    {
                                       var _temp_570:* = int(_loc22_ + 4);
                                       _loc21_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc21_ = li32(_loc21_);
                                    _loc11_ = 10;
                                    break;
                                 }
                                 §§goto(addr2f9b);
                              }
                              else
                              {
                                 _loc35_ |= 16;
                                 addr1f29:
                                 _loc31_ = _loc35_;
                                 _loc24_ = _loc31_ & 0x10;
                                 if(_loc24_ != 0)
                                 {
                                    if(_loc34_ != 0)
                                    {
                                       _loc1_ -= 16;
                                       si32(_loc34_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F_idalloc();
                                       _loc1_ += 16;
                                    }
                                    _loc35_ = li32(_loc2_ - 320);
                                    if(_loc35_ != 0)
                                    {
                                       var _temp_575:* = _loc33_ << 3;
                                       _loc35_ += _temp_575;
                                    }
                                    else
                                    {
                                       var _temp_576:* = int(_loc22_ + 4);
                                       _loc35_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc35_ = li32(_loc35_);
                                    _loc33_ += 1;
                                    _loc15_ = wdnative_nternal.L__2E_str5732;
                                    if(_loc35_ != 0)
                                    {
                                       while(true)
                                       {
                                          if(_loc29_ <= -1)
                                          {
                                             si32(_loc35_,_loc2_ - 132);
                                             _loc1_ -= 16;
                                             si32(128,_loc1_ + 8);
                                             si32(0,_loc1_ + 4);
                                             _loc47_ = _loc2_ - 128;
                                             si32(_loc47_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative.Fmemset();
                                             _loc1_ += 16;
                                             _loc24_ = li32(wdnative_nternal.___wcsnrtombs);
                                             _loc1_ -= 32;
                                             si32(_loc47_,_loc1_ + 16);
                                             si32(0,_loc1_ + 12);
                                             si32(-1,_loc1_ + 8);
                                             _loc47_ = _loc2_ - 132;
                                             si32(_loc47_,_loc1_ + 4);
                                             si32(0,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative.ptr2fun[_loc24_]();
                                             _loc1_ += 32;
                                             _loc34_ = wdnative.eax;
                                             if(_loc34_ == -1)
                                             {
                                                break;
                                             }
                                          }
                                          else
                                          {
                                             _loc34_ = _loc29_;
                                             if(_loc29_ >= 128)
                                             {
                                                si32(_loc35_,_loc2_ - 132);
                                                _loc1_ -= 16;
                                                si32(128,_loc1_ + 8);
                                                _loc34_ = 0;
                                                si32(_loc34_,_loc1_ + 4);
                                                _loc15_ = _loc2_ - 128;
                                                si32(_loc15_,_loc1_);
                                                wdnative.ESP = _loc1_;
                                                wdnative.Fmemset();
                                                _loc1_ += 16;
                                                _loc11_ = _loc35_;
                                                while(true)
                                                {
                                                   _loc24_ = li32(_loc11_);
                                                   _loc47_ = _loc11_ + 4;
                                                   si32(_loc47_,_loc2_ - 132);
                                                   _loc47_ = li32(wdnative_nternal.___wcrtomb);
                                                   _loc1_ -= 16;
                                                   si32(_loc15_,_loc1_ + 8);
                                                   si32(_loc24_,_loc1_ + 4);
                                                   si32(_loc42_,_loc1_);
                                                   wdnative.ESP = _loc1_;
                                                   wdnative.ptr2fun[_loc47_]();
                                                   _loc1_ += 16;
                                                   _loc11_ = wdnative.eax;
                                                   _loc24_ = _loc11_ + -1;
                                                   if((uint(_loc24_)) > 4294967293)
                                                   {
                                                      break;
                                                   }
                                                   _loc13_ = _loc11_ + _loc34_;
                                                   if((uint(_loc13_)) > uint(_loc29_))
                                                   {
                                                      break;
                                                   }
                                                   _loc11_ = li32(_loc2_ - 132);
                                                   _loc34_ = _loc13_;
                                                }
                                             }
                                          }
                                          _loc1_ -= 16;
                                          _loc24_ = _loc34_ + 1;
                                          si32(_loc24_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.F_malloc();
                                          _loc1_ += 16;
                                          _loc15_ = wdnative.eax;
                                          if(_loc15_ == 0)
                                          {
                                             break;
                                          }
                                          si32(_loc35_,_loc2_ - 132);
                                          _loc1_ -= 16;
                                          si32(128,_loc1_ + 8);
                                          si32(0,_loc1_ + 4);
                                          _loc47_ = _loc2_ - 128;
                                          si32(_loc47_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.Fmemset();
                                          _loc1_ += 16;
                                          _loc24_ = li32(wdnative_nternal.___wcsnrtombs);
                                          _loc1_ -= 32;
                                          si32(_loc47_,_loc1_ + 16);
                                          si32(_loc34_,_loc1_ + 12);
                                          si32(-1,_loc1_ + 8);
                                          _loc47_ = _loc2_ - 132;
                                          si32(_loc47_,_loc1_ + 4);
                                          si32(_loc15_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.ptr2fun[_loc24_]();
                                          _loc1_ += 32;
                                          _loc34_ = wdnative.eax;
                                          if(_loc34_ == -1)
                                          {
                                             _loc1_ -= 16;
                                             si32(_loc15_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F_idalloc();
                                             _loc1_ += 16;
                                             break;
                                          }
                                          var _temp_602:* = int(_loc15_ + _loc34_);
                                          si8(0,_temp_602);
                                          _loc34_ = _loc15_;
                                       }
                                       _loc24_ = li16(_loc9_ + 12);
                                       _loc24_ = _loc24_ | 0x40;
                                       si16(_loc24_,_loc9_ + 12);
                                       _loc34_ = 0;
                                       _loc18_ = _loc30_;
                                       break loop2;
                                    }
                                 }
                                 else
                                 {
                                    _loc35_ = li32(_loc2_ - 320);
                                    if(_loc35_ != 0)
                                    {
                                       var _temp_606:* = _loc33_ << 3;
                                       _loc35_ += _temp_606;
                                    }
                                    else
                                    {
                                       var _temp_607:* = int(_loc22_ + 4);
                                       _loc35_ = _loc22_;
                                       _loc22_ += 4;
                                    }
                                    _loc15_ = li32(_loc35_);
                                    _loc33_ += 1;
                                    if(_loc15_ == 0)
                                    {
                                       _loc15_ = wdnative_nternal.L__2E_str5732;
                                    }
                                 }
                                 _loc13_ = 0;
                                 if(_loc29_ <= -1)
                                 {
                                    _loc35_ = _loc15_ & -4;
                                    _loc47_ = li32(_loc35_);
                                    var _temp_612:* = int(_loc47_ + -16843009);
                                    _loc24_ = (_loc47_ = (_loc47_ &= -2139062144) ^ -2139062144) & _temp_612;
                                    if(_loc24_ != 0)
                                    {
                                       _loc11_ = _loc35_ + 4;
                                       _loc13_ = 0;
                                       while(true)
                                       {
                                          _loc18_ = _loc15_ + _loc13_;
                                          if((uint(_loc18_)) < uint(_loc11_))
                                          {
                                             _loc24_ = li8(_loc18_);
                                             if(_loc24_ == 0)
                                             {
                                                break;
                                             }
                                             _loc13_ += 1;
                                             continue;
                                          }
                                       }
                                       addr240a:
                                       _loc19_ = 0;
                                       si8(_loc19_,_loc2_ - 139);
                                       §§goto(addr2fc8);
                                    }
                                    _loc11_ = _loc35_ + 4;
                                    while(true)
                                    {
                                       _loc35_ = li32(_loc11_);
                                       _loc24_ = _loc35_ + -16843009;
                                       _loc47_ = _loc35_ & -2139062144;
                                       _loc47_ = _loc47_ ^ -2139062144;
                                       _loc24_ = _loc47_ & _loc24_;
                                       if(_loc24_ != 0)
                                       {
                                          _loc24_ = _loc35_ & 0xFF;
                                          if(_loc24_ == 0)
                                          {
                                             _loc13_ = _loc11_ - _loc15_;
                                             break;
                                          }
                                          _loc24_ = li8(_loc11_ + 1);
                                          if(_loc24_ == 0)
                                          {
                                             _loc24_ = 1 - _loc15_;
                                             _loc13_ = _loc24_ + _loc11_;
                                             break;
                                          }
                                          _loc24_ = li8(_loc11_ + 2);
                                          if(_loc24_ == 0)
                                          {
                                             _loc24_ = 2 - _loc15_;
                                             _loc13_ = _loc24_ + _loc11_;
                                             break;
                                          }
                                          _loc24_ = li8(_loc11_ + 3);
                                          if(_loc24_ == 0)
                                          {
                                             _loc24_ = 3 - _loc15_;
                                             _loc13_ = _loc24_ + _loc11_;
                                             break;
                                          }
                                       }
                                       _loc11_ += 4;
                                    }
                                 }
                                 else
                                 {
                                    while(uint(_loc13_) < uint(_loc29_))
                                    {
                                       _loc24_ = _loc15_ + _loc13_;
                                       _loc24_ = li8(_loc24_);
                                       if(_loc24_ == 0)
                                       {
                                          break;
                                       }
                                       _loc13_ += 1;
                                    }
                                 }
                                 §§goto(addr240a);
                              }
                           }
                        }
                        else if(_loc11_ <= 107)
                        {
                           while(true)
                           {
                              if(_loc11_ <= 101)
                              {
                                 if(_loc11_ <= 98)
                                 {
                                    if(_loc11_ == 88)
                                    {
                                       _loc27_ = wdnative_nternal._xdigs_upper_2E_4544;
                                       addr268a:
                                       _loc31_ = _loc35_ & 0x1C20;
                                       if(_loc31_ != 0)
                                       {
                                          _loc24_ = _loc35_ & 0x1000;
                                          if(_loc24_ != 0)
                                          {
                                             _loc17_ = li32(_loc2_ - 320);
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_663:* = _loc33_ << 3;
                                                _loc23_ = _loc17_ + _temp_663;
                                             }
                                             else
                                             {
                                                var _temp_664:* = int(_loc22_ + 8);
                                                _loc23_ = _loc22_;
                                                _loc22_ += 8;
                                             }
                                             _loc17_ = li32(_loc23_ + 4);
                                             _loc23_ = li32(_loc23_);
                                          }
                                          else
                                          {
                                             _loc24_ = _loc35_ & 0x0400;
                                             if(_loc24_ != 0)
                                             {
                                                _loc17_ = li32(_loc2_ - 320);
                                                if(_loc17_ != 0)
                                                {
                                                   var _temp_667:* = _loc33_ << 3;
                                                   _loc17_ += _temp_667;
                                                }
                                                else
                                                {
                                                   var _temp_668:* = int(_loc22_ + 4);
                                                   _loc17_ = _loc22_;
                                                   _loc22_ += 4;
                                                }
                                                _loc23_ = li32(_loc17_);
                                                _loc17_ = 0;
                                             }
                                             else
                                             {
                                                var _temp_669:* = _loc35_ & 0x0800;
                                                _loc17_ = li32(_loc2_ - 320);
                                                if(_temp_669 != 0)
                                                {
                                                   if(_loc17_ != 0)
                                                   {
                                                      var _temp_670:* = _loc33_ << 3;
                                                      _loc17_ += _temp_670;
                                                   }
                                                   else
                                                   {
                                                      var _temp_671:* = int(_loc22_ + 4);
                                                      _loc17_ = _loc22_;
                                                      _loc22_ += 4;
                                                   }
                                                   _loc23_ = li32(_loc17_);
                                                   _loc17_ = _loc23_ >> 31;
                                                }
                                                else
                                                {
                                                   if(_loc17_ != 0)
                                                   {
                                                      var _temp_673:* = _loc33_ << 3;
                                                      _loc23_ = _loc17_ + _temp_673;
                                                   }
                                                   else
                                                   {
                                                      var _temp_674:* = int(_loc22_ + 8);
                                                      _loc23_ = _loc22_;
                                                      _loc22_ += 8;
                                                   }
                                                   _loc17_ = li32(_loc23_ + 4);
                                                   _loc23_ = li32(_loc23_);
                                                }
                                             }
                                          }
                                       }
                                       else
                                       {
                                          _loc24_ = _loc35_ & 0x10;
                                          if(_loc24_ != 0)
                                          {
                                             _loc21_ = li32(_loc2_ - 320);
                                             if(_loc21_ != 0)
                                             {
                                                var _temp_677:* = _loc33_ << 3;
                                                _loc21_ += _temp_677;
                                             }
                                             else
                                             {
                                                var _temp_678:* = int(_loc22_ + 4);
                                                _loc21_ = _loc22_;
                                                _loc22_ += 4;
                                             }
                                             _loc21_ = li32(_loc21_);
                                          }
                                          else
                                          {
                                             _loc24_ = _loc35_ & 0x40;
                                             if(_loc24_ != 0)
                                             {
                                                _loc21_ = li32(_loc2_ - 320);
                                                if(_loc21_ != 0)
                                                {
                                                   var _temp_681:* = _loc33_ << 3;
                                                   _loc21_ += _temp_681;
                                                }
                                                else
                                                {
                                                   var _temp_682:* = int(_loc22_ + 4);
                                                   _loc21_ = _loc22_;
                                                   _loc22_ += 4;
                                                }
                                                _loc21_ = li16(_loc21_);
                                             }
                                             else
                                             {
                                                var _temp_683:* = _loc35_ & 0x2000;
                                                _loc21_ = li32(_loc2_ - 320);
                                                if(_temp_683 != 0)
                                                {
                                                   if(_loc21_ != 0)
                                                   {
                                                      var _temp_684:* = _loc33_ << 3;
                                                      _loc21_ += _temp_684;
                                                   }
                                                   else
                                                   {
                                                      var _temp_685:* = int(_loc22_ + 4);
                                                      _loc21_ = _loc22_;
                                                      _loc22_ += 4;
                                                   }
                                                   _loc21_ = li8(_loc21_);
                                                }
                                                else
                                                {
                                                   if(_loc21_ != 0)
                                                   {
                                                      var _temp_686:* = _loc33_ << 3;
                                                      _loc21_ += _temp_686;
                                                   }
                                                   else
                                                   {
                                                      var _temp_687:* = int(_loc22_ + 4);
                                                      _loc21_ = _loc22_;
                                                      _loc22_ += 4;
                                                   }
                                                   _loc21_ = li32(_loc21_);
                                                }
                                             }
                                          }
                                       }
                                       _loc24_ = _loc35_ & 1;
                                       if(_loc24_ != 0)
                                       {
                                          _loc15_ = _loc13_ = 1;
                                          if(_loc21_ == 0)
                                          {
                                             _loc15_ = 0;
                                          }
                                          _loc24_ = _loc23_ | _loc17_;
                                          if(_loc24_ == 0)
                                          {
                                             _loc13_ = 0;
                                          }
                                          if(_loc31_ != 0)
                                          {
                                             _loc15_ = _loc13_;
                                          }
                                          _loc24_ = _loc15_ & 1;
                                          if(_loc24_ != 0)
                                          {
                                             si8(_loc11_,_loc2_ - 313);
                                          }
                                       }
                                       _loc35_ &= -513;
                                       _loc11_ = 16;
                                       break loop36;
                                    }
                                    if(_loc11_ != 97)
                                    {
                                       §§goto(addr2f9b);
                                    }
                                    else
                                    {
                                       §§goto(addr0fae);
                                    }
                                 }
                                 else if(_loc11_ != 99)
                                 {
                                    if(_loc11_ != 100)
                                    {
                                       if(_loc11_ != 101)
                                       {
                                          §§goto(addr2f9b);
                                       }
                                       else
                                       {
                                          §§goto(addr11f9);
                                       }
                                    }
                                 }
                                 else
                                 {
                                    §§goto(addr0bbc);
                                 }
                              }
                              else if(_loc11_ <= 103)
                              {
                                 if(_loc11_ != 102)
                                 {
                                    if(_loc11_ == 103)
                                    {
                                       break loop4;
                                    }
                                    §§goto(addr2f9b);
                                 }
                                 §§goto(addr1231);
                              }
                              else
                              {
                                 if(_loc11_ == 104)
                                 {
                                    _loc24_ = _loc35_ & 0x40;
                                    if(_loc24_ != 0)
                                    {
                                       _loc24_ = _loc35_ & -8257;
                                       _loc35_ = _loc24_ | 0x2000;
                                       break loop6;
                                    }
                                    _loc35_ |= 64;
                                    break loop6;
                                 }
                                 if(_loc11_ != 105)
                                 {
                                    if(_loc11_ == 106)
                                    {
                                       _loc35_ |= 4096;
                                       break loop6;
                                    }
                                    §§goto(addr2f9b);
                                 }
                              }
                              §§goto(addr0d00);
                           }
                        }
                        else
                        {
                           while(true)
                           {
                              if(_loc11_ <= 114)
                              {
                                 if(_loc11_ <= 110)
                                 {
                                    if(_loc11_ == 108)
                                    {
                                       _loc24_ = _loc35_ & 0x10;
                                       if(_loc24_ != 0)
                                       {
                                          _loc24_ = _loc35_ & -49;
                                          _loc35_ = _loc24_ | 0x20;
                                          break loop6;
                                       }
                                       _loc35_ |= 16;
                                       break loop6;
                                    }
                                    if(_loc11_ == 110)
                                    {
                                       _loc24_ = _loc35_ & 0x20;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_695:* = _loc33_ << 3;
                                             _loc32_ += _temp_695;
                                          }
                                          else
                                          {
                                             var _temp_696:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc47_ = li32(_loc32_);
                                          _loc24_ = _loc30_ >> 31;
                                          si32(_loc24_,_loc47_ + 4);
                                          si32(_loc30_,_loc47_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       _loc24_ = _loc35_ & 0x0400;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_700:* = _loc33_ << 3;
                                             _loc32_ += _temp_700;
                                          }
                                          else
                                          {
                                             var _temp_701:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc24_ = li32(_loc32_);
                                          si32(_loc30_,_loc24_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       _loc24_ = _loc35_ & 0x0800;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_704:* = _loc33_ << 3;
                                             _loc32_ += _temp_704;
                                          }
                                          else
                                          {
                                             var _temp_705:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc24_ = li32(_loc32_);
                                          si32(_loc30_,_loc24_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       _loc24_ = _loc35_ & 0x1000;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_708:* = _loc33_ << 3;
                                             _loc32_ += _temp_708;
                                          }
                                          else
                                          {
                                             var _temp_709:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc47_ = li32(_loc32_);
                                          _loc24_ = _loc30_ >> 31;
                                          si32(_loc24_,_loc47_ + 4);
                                          si32(_loc30_,_loc47_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       _loc24_ = _loc35_ & 0x10;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_713:* = _loc33_ << 3;
                                             _loc32_ += _temp_713;
                                          }
                                          else
                                          {
                                             var _temp_714:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc24_ = li32(_loc32_);
                                          si32(_loc30_,_loc24_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       _loc24_ = _loc35_ & 0x40;
                                       if(_loc24_ != 0)
                                       {
                                          _loc32_ = li32(_loc2_ - 320);
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_717:* = _loc33_ << 3;
                                             _loc32_ += _temp_717;
                                          }
                                          else
                                          {
                                             var _temp_718:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc24_ = li32(_loc32_);
                                          si16(_loc30_,_loc24_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       var _temp_719:* = _loc35_ & 0x2000;
                                       _loc32_ = li32(_loc2_ - 320);
                                       if(_temp_719 != 0)
                                       {
                                          if(_loc32_ != 0)
                                          {
                                             var _temp_720:* = _loc33_ << 3;
                                             _loc32_ += _temp_720;
                                          }
                                          else
                                          {
                                             var _temp_721:* = int(_loc22_ + 4);
                                             _loc32_ = _loc22_;
                                             _loc22_ += 4;
                                          }
                                          _loc24_ = li32(_loc32_);
                                          si8(_loc30_,_loc24_);
                                          _loc33_ += 1;
                                          _loc35_ = _loc30_;
                                          break loop5;
                                       }
                                       if(_loc32_ != 0)
                                       {
                                          var _temp_722:* = _loc33_ << 3;
                                          _loc32_ += _temp_722;
                                       }
                                       else
                                       {
                                          var _temp_723:* = int(_loc22_ + 4);
                                          _loc32_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc24_ = li32(_loc32_);
                                       si32(_loc30_,_loc24_);
                                       _loc33_ += 1;
                                       _loc35_ = _loc30_;
                                       break loop5;
                                    }
                                 }
                                 else if(_loc11_ != 111)
                                 {
                                    if(_loc11_ == 112)
                                    {
                                       _loc27_ = li32(_loc2_ - 320);
                                       if(_loc27_ != 0)
                                       {
                                          var _temp_727:* = _loc33_ << 3;
                                          _loc27_ += _temp_727;
                                       }
                                       else
                                       {
                                          var _temp_728:* = int(_loc22_ + 4);
                                          _loc27_ = _loc22_;
                                          _loc22_ += 4;
                                       }
                                       _loc23_ = li32(_loc27_);
                                       si8(120,_loc2_ - 313);
                                       _loc35_ |= 4096;
                                       _loc17_ = 0;
                                       _loc27_ = wdnative_nternal._xdigs_lower_2E_4543;
                                       _loc11_ = 16;
                                       break loop36;
                                    }
                                    if(_loc11_ == 113)
                                    {
                                       _loc35_ |= 32;
                                       break loop6;
                                    }
                                 }
                                 else
                                 {
                                    §§goto(addr1c75);
                                 }
                              }
                              else if(_loc11_ <= 116)
                              {
                                 if(_loc11_ != 115)
                                 {
                                    if(_loc11_ == 116)
                                    {
                                       _loc35_ |= 2048;
                                       break loop6;
                                    }
                                 }
                                 else
                                 {
                                    §§goto(addr1f29);
                                 }
                              }
                              else if(_loc11_ != 117)
                              {
                                 if(_loc11_ != 120)
                                 {
                                    if(_loc11_ == 122)
                                    {
                                       _loc35_ |= 1024;
                                       break loop6;
                                    }
                                 }
                                 else
                                 {
                                    _loc27_ = wdnative_nternal._xdigs_lower_2E_4543;
                                    §§goto(addr268a);
                                 }
                              }
                              else
                              {
                                 §§goto(addr2422);
                              }
                              §§goto(addr2f9b);
                           }
                        }
                        §§goto(addr2fc8);
                     }
                     si8(0,_loc2_ - 139);
                     _loc33_ += 1;
                     §§goto(addr2938);
                  }
                  continue loop4;
               }
               continue loop2;
            }
            _loc10_ = _loc11_ + -2;
            if(_loc29_ == 0)
            {
               _loc29_ = 1;
            }
            §§goto(addr1231);
         }
         §§goto(addr447d);
      }
      if(_loc36_ != 0)
      {
         _loc22_ = li32(_loc36_ - 4);
         si32(_loc22_,_loc36_);
         _loc24_ = 1 << _loc22_;
         si32(_loc24_,_loc36_ + 4);
         _loc20_ = _loc36_ + -4;
         if(_loc20_ != 0)
         {
            if(_loc22_ >= 10)
            {
               _loc1_ -= 16;
               si32(_loc20_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F_idalloc();
               _loc1_ += 16;
            }
            else
            {
               var _temp_733:* = _loc22_ << 2;
               _loc24_ = wdnative_nternal._freelist + _temp_733;
               _loc47_ = li32(_loc24_);
               si32(_loc47_,_loc20_);
               si32(_loc20_,_loc24_);
            }
         }
      }
      if(_loc34_ != 0)
      {
         _loc1_ -= 16;
         si32(_loc34_,_loc1_);
         wdnative.ESP = _loc1_;
         wdnative_nternal.F_idalloc();
         _loc1_ += 16;
      }
      _loc24_ = li8(_loc9_ + 12);
      _loc24_ = _loc24_ & 0x40;
      if(_loc24_ != 0)
      {
         _loc18_ = -1;
      }
      _loc9_ = li32(_loc2_ - 320);
      if(_loc9_ != 0)
      {
         _loc24_ = _loc2_ - 384;
         if(_loc24_ != _loc9_)
         {
            _loc1_ -= 16;
            si32(_loc9_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative_nternal.F_idalloc();
            _loc1_ += 16;
         }
      }
      addr45db:
      wdnative.eax = _loc18_;
      _loc1_ = _loc2_;
      wdnative.ESP = _loc1_;
   }
}

