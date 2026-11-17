package wdnative_nternal
{
   import avm2.intrinsics.memory.lf64;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.sf64;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import flash.utils.ByteArray;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemset;
   import wdnative.eax;
   import wdnative.ram;
   
   public function F___find_arguments() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc13_:int = 0;
      var _loc18_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = 0;
      var _loc17_:int = 0;
      var _loc10_:int = 0;
      var _loc12_:int = 0;
      var _loc15_:int = 0;
      var _loc11_:int = 0;
      var _loc19_:int = 0;
      _loc7_ = wdnative.ESP;
      var _loc4_:int = _loc7_ - 48;
      var _loc5_:int = _loc7_ - 48;
      _loc21_ = _loc5_ | 4;
      si32(_loc21_,_loc7_ - 48);
      si32(8,_loc7_ - 12);
      si32(0,_loc7_ - 8);
      si32(1,_loc7_ - 4);
      si32(0,_loc21_ + 24);
      si32(0,_loc21_ + 20);
      si32(0,_loc21_ + 16);
      si32(0,_loc21_ + 12);
      si32(0,_loc21_ + 8);
      si32(0,_loc21_ + 4);
      si32(0,_loc21_);
      si32(0,_loc7_ - 16);
      _loc20_ = li32(_loc7_ + 8);
      _loc19_ = li32(_loc7_ + 4);
      _loc18_ = li32(_loc7_);
      _loc17_ = 1;
      loop0:
      while(true)
      {
         _loc15_ = li8(_loc18_);
         if(_loc15_ != 0)
         {
            if(_loc15_ == 37)
            {
               _loc18_ += 1;
               _loc13_ = 0;
               loop1:
               while(true)
               {
                  _loc12_ = _loc18_ + 1;
                  _loc15_ = si8(li8(_loc18_));
                  while(true)
                  {
                     _loc18_ = _loc12_;
                     if(_loc15_ <= 87)
                     {
                        if(_loc15_ <= 64)
                        {
                           if(_loc15_ <= 42)
                           {
                              if(_loc15_ <= 38)
                              {
                                 if(_loc15_ == 32)
                                 {
                                    break;
                                 }
                                 if(_loc15_ == 35)
                                 {
                                    break;
                                 }
                              }
                              else
                              {
                                 if(_loc15_ == 39)
                                 {
                                    break;
                                 }
                                 if(_loc15_ == 42)
                                 {
                                    _loc8_ = si8(li8(_loc18_));
                                    _loc2_ = _loc8_ + -48;
                                    _loc15_ = 0;
                                    _loc12_ = _loc18_;
                                    if(uint(_loc2_) <= 9)
                                    {
                                       do
                                       {
                                          _loc5_ = _loc15_ * 10;
                                          _loc15_ = _loc5_ + _loc2_;
                                          _loc5_ = _loc12_ + 1;
                                          _loc8_ = si8(li8(_loc12_ + 1));
                                          _loc2_ = _loc8_ + -48;
                                          _loc12_ = _loc5_;
                                       }
                                       while(uint(_loc2_) < 10);
                                    }
                                    _loc5_ = _loc8_ & 0xFF;
                                    if(_loc5_ == 36)
                                    {
                                       si32(_loc15_,_loc7_ - 4);
                                       _loc18_ = li32(_loc7_ - 12);
                                       if(_loc15_ >= _loc18_)
                                       {
                                          _loc2_ = _loc18_ << 1;
                                          _loc10_ = _loc9_ = _loc15_ + 1;
                                          if(_loc9_ <= _loc2_)
                                          {
                                             _loc10_ = _loc2_;
                                          }
                                          _loc15_ = _loc10_ << 2;
                                          _loc8_ = li32(_loc7_ - 48);
                                          if(_loc18_ == 8)
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative.F_malloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc11_ = wdnative.eax;
                                             if(_loc11_ == 0)
                                             {
                                                break loop0;
                                             }
                                             _loc5_ = _loc18_ << 2;
                                             var _loc1_:ByteArray = ram;
                                             _loc1_.position = _loc11_;
                                             _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                          }
                                          else
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_ + 4);
                                             si32(_loc8_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative_nternal.F_realloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc11_ = wdnative.eax;
                                             if(_loc11_ == 0)
                                             {
                                                break loop0;
                                             }
                                          }
                                          if(_loc18_ < _loc10_)
                                          {
                                             _loc4_ -= 16;
                                             si32(0,_loc4_ + 4);
                                             var _temp_15:* = _loc18_ << 2;
                                             _loc5_ = _loc11_ + _temp_15;
                                             si32(_loc5_,_loc4_);
                                             if(_loc2_ <= _loc9_)
                                             {
                                                _loc2_ = _loc9_;
                                             }
                                             _loc5_ = _loc2_ - _loc18_;
                                             _loc5_ = _loc5_ << 2;
                                             si32(_loc5_,_loc4_ + 8);
                                             wdnative.ESP = _loc4_;
                                             wdnative.Fmemset();
                                             _loc4_ += 16;
                                          }
                                          si32(_loc11_,_loc7_ - 48);
                                          si32(_loc10_,_loc7_ - 12);
                                          _loc15_ = li32(_loc7_ - 4);
                                       }
                                       _loc5_ = li32(_loc7_ - 8);
                                       if(_loc15_ > _loc5_)
                                       {
                                          si32(_loc15_,_loc7_ - 8);
                                       }
                                       var _loc3_:int = _loc15_ << 2;
                                       _loc5_ = li32(_loc7_ - 48);
                                       _loc5_ = _loc5_ + _loc3_;
                                       si32(2,_loc5_);
                                       si32(_loc17_,_loc7_ - 4);
                                       _loc18_ = _loc12_ + 1;
                                       break;
                                    }
                                    _loc2_ = li32(_loc7_ - 12);
                                    if(_loc17_ >= _loc2_)
                                    {
                                       _loc12_ = _loc2_ << 1;
                                       _loc10_ = _loc17_ += 1;
                                       if(_loc17_ <= _loc12_)
                                       {
                                          _loc10_ = _loc12_;
                                       }
                                       _loc15_ = _loc10_ << 2;
                                       _loc8_ = li32(_loc7_ - 48);
                                       if(_loc2_ == 8)
                                       {
                                          _loc4_ -= 16;
                                          si32(_loc15_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative.F_malloc();
                                          _loc15_ = -1;
                                          _loc4_ += 16;
                                          _loc9_ = wdnative.eax;
                                          if(_loc9_ == 0)
                                          {
                                             break loop0;
                                          }
                                          _loc5_ = _loc2_ << 2;
                                          _loc1_ = ram;
                                          _loc1_.position = _loc9_;
                                          _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                       }
                                       else
                                       {
                                          _loc4_ -= 16;
                                          si32(_loc15_,_loc4_ + 4);
                                          si32(_loc8_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative_nternal.F_realloc();
                                          _loc15_ = -1;
                                          _loc4_ += 16;
                                          _loc9_ = wdnative.eax;
                                          if(_loc9_ == 0)
                                          {
                                             break loop0;
                                          }
                                       }
                                       if(_loc2_ < _loc10_)
                                       {
                                          _loc4_ -= 16;
                                          si32(0,_loc4_ + 4);
                                          var _temp_26:* = _loc2_ << 2;
                                          _loc5_ = _loc9_ + _temp_26;
                                          si32(_loc5_,_loc4_);
                                          if(_loc12_ <= _loc17_)
                                          {
                                             _loc12_ = _loc17_;
                                          }
                                          _loc5_ = _loc12_ - _loc2_;
                                          _loc5_ = _loc5_ << 2;
                                          si32(_loc5_,_loc4_ + 8);
                                          wdnative.ESP = _loc4_;
                                          wdnative.Fmemset();
                                          _loc4_ += 16;
                                       }
                                       si32(_loc9_,_loc7_ - 48);
                                       si32(_loc10_,_loc7_ - 12);
                                       _loc17_ = li32(_loc7_ - 4);
                                    }
                                    _loc5_ = li32(_loc7_ - 8);
                                    if(_loc17_ > _loc5_)
                                    {
                                       si32(_loc17_,_loc7_ - 8);
                                    }
                                    _loc3_ = _loc17_ << 2;
                                    _loc5_ = li32(_loc7_ - 48);
                                    _loc5_ = _loc5_ + _loc3_;
                                    si32(2,_loc5_);
                                    _loc17_ += 1;
                                    si32(_loc17_,_loc7_ - 4);
                                    break;
                                 }
                              }
                           }
                           else
                           {
                              _loc12_ = _loc15_ + -43;
                              if((uint(_loc12_)) <= 14)
                              {
                                 _loc2_ = 0;
                                 _loc8_ = 1 << _loc12_;
                                 _loc5_ = _loc8_ & 0x7FC0;
                                 if(_loc5_ != 0)
                                 {
                                    do
                                    {
                                       _loc5_ = _loc2_ * 10;
                                       _loc5_ = _loc15_ + _loc5_;
                                       _loc2_ = _loc5_ + -48;
                                       _loc12_ = _loc18_ + 1;
                                       _loc15_ = si8(li8(_loc18_));
                                       _loc5_ = _loc15_ + -48;
                                       _loc18_ = _loc12_;
                                    }
                                    while(uint(_loc5_) < 10);
                                    _loc5_ = _loc15_ & 0xFF;
                                    if(_loc5_ == 36)
                                    {
                                       si32(_loc2_,_loc7_ - 4);
                                       _loc17_ = _loc2_;
                                       _loc18_ = _loc12_;
                                       break;
                                    }
                                    continue;
                                 }
                                 _loc5_ = _loc8_ & 0x25;
                                 if(_loc5_ != 0)
                                 {
                                    break;
                                 }
                                 if(_loc12_ == 3)
                                 {
                                    _loc12_ = _loc18_ + 1;
                                    _loc15_ = li8(_loc18_);
                                    if(_loc15_ == 42)
                                    {
                                       _loc8_ = si8(li8(_loc12_));
                                       _loc10_ = _loc8_ + -48;
                                       _loc15_ = 0;
                                       _loc2_ = _loc12_;
                                       if(uint(_loc10_) <= 9)
                                       {
                                          do
                                          {
                                             _loc5_ = _loc15_ * 10;
                                             _loc15_ = _loc5_ + _loc10_;
                                             _loc2_ = _loc18_ + 1;
                                             _loc8_ = si8(li8(_loc18_ + 2));
                                             _loc10_ = _loc8_ + -48;
                                             _loc18_ = _loc2_;
                                          }
                                          while(uint(_loc10_) < 10);
                                          _loc2_ += 1;
                                       }
                                       _loc5_ = _loc8_ & 0xFF;
                                       if(_loc5_ == 36)
                                       {
                                          si32(_loc15_,_loc7_ - 4);
                                          _loc18_ = li32(_loc7_ - 12);
                                          if(_loc15_ >= _loc18_)
                                          {
                                             _loc12_ = _loc18_ << 1;
                                             _loc10_ = _loc9_ = _loc15_ + 1;
                                             if(_loc9_ <= _loc12_)
                                             {
                                                _loc10_ = _loc12_;
                                             }
                                             _loc15_ = _loc10_ << 2;
                                             _loc8_ = li32(_loc7_ - 48);
                                             if(_loc18_ == 8)
                                             {
                                                _loc4_ -= 16;
                                                si32(_loc15_,_loc4_);
                                                wdnative.ESP = _loc4_;
                                                wdnative.F_malloc();
                                                _loc15_ = -1;
                                                _loc4_ += 16;
                                                _loc11_ = wdnative.eax;
                                                if(_loc11_ == 0)
                                                {
                                                   break loop0;
                                                }
                                                _loc5_ = _loc18_ << 2;
                                                _loc1_ = ram;
                                                _loc1_.position = _loc11_;
                                                _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                             }
                                             else
                                             {
                                                _loc4_ -= 16;
                                                si32(_loc15_,_loc4_ + 4);
                                                si32(_loc8_,_loc4_);
                                                wdnative.ESP = _loc4_;
                                                wdnative_nternal.F_realloc();
                                                _loc15_ = -1;
                                                _loc4_ += 16;
                                                _loc11_ = wdnative.eax;
                                                if(_loc11_ == 0)
                                                {
                                                   break loop0;
                                                }
                                             }
                                             if(_loc18_ < _loc10_)
                                             {
                                                _loc4_ -= 16;
                                                si32(0,_loc4_ + 4);
                                                var _temp_51:* = _loc18_ << 2;
                                                _loc5_ = _loc11_ + _temp_51;
                                                si32(_loc5_,_loc4_);
                                                if(_loc12_ <= _loc9_)
                                                {
                                                   _loc12_ = _loc9_;
                                                }
                                                _loc5_ = _loc12_ - _loc18_;
                                                _loc5_ = _loc5_ << 2;
                                                si32(_loc5_,_loc4_ + 8);
                                                wdnative.ESP = _loc4_;
                                                wdnative.Fmemset();
                                                _loc4_ += 16;
                                             }
                                             si32(_loc11_,_loc7_ - 48);
                                             si32(_loc10_,_loc7_ - 12);
                                             _loc15_ = li32(_loc7_ - 4);
                                          }
                                          _loc5_ = li32(_loc7_ - 8);
                                          if(_loc15_ > _loc5_)
                                          {
                                             si32(_loc15_,_loc7_ - 8);
                                          }
                                          _loc3_ = _loc15_ << 2;
                                          _loc5_ = li32(_loc7_ - 48);
                                          _loc5_ = _loc5_ + _loc3_;
                                          si32(2,_loc5_);
                                          si32(_loc17_,_loc7_ - 4);
                                          _loc18_ = _loc2_ + 1;
                                          break;
                                       }
                                       _loc18_ = li32(_loc7_ - 12);
                                       if(_loc17_ >= _loc18_)
                                       {
                                          _loc2_ = _loc18_ << 1;
                                          _loc17_ = _loc8_ = _loc17_ + 1;
                                          if(_loc8_ <= _loc2_)
                                          {
                                             _loc17_ = _loc2_;
                                          }
                                          _loc15_ = _loc17_ << 2;
                                          _loc10_ = li32(_loc7_ - 48);
                                          if(_loc18_ == 8)
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative.F_malloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc9_ = wdnative.eax;
                                             if(_loc9_ == 0)
                                             {
                                                break loop0;
                                             }
                                             _loc5_ = _loc18_ << 2;
                                             _loc1_ = ram;
                                             _loc1_.position = _loc9_;
                                             _loc1_.writeBytes(_loc1_,_loc10_,_loc5_);
                                          }
                                          else
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_ + 4);
                                             si32(_loc10_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative_nternal.F_realloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc9_ = wdnative.eax;
                                             if(_loc9_ == 0)
                                             {
                                                break loop0;
                                             }
                                          }
                                          if(_loc18_ < _loc17_)
                                          {
                                             _loc4_ -= 16;
                                             si32(0,_loc4_ + 4);
                                             var _temp_62:* = _loc18_ << 2;
                                             _loc5_ = _loc9_ + _temp_62;
                                             si32(_loc5_,_loc4_);
                                             if(_loc2_ <= _loc8_)
                                             {
                                                _loc2_ = _loc8_;
                                             }
                                             _loc5_ = _loc2_ - _loc18_;
                                             _loc5_ = _loc5_ << 2;
                                             si32(_loc5_,_loc4_ + 8);
                                             wdnative.ESP = _loc4_;
                                             wdnative.Fmemset();
                                             _loc4_ += 16;
                                          }
                                          si32(_loc9_,_loc7_ - 48);
                                          si32(_loc17_,_loc7_ - 12);
                                          _loc17_ = li32(_loc7_ - 4);
                                       }
                                       _loc5_ = li32(_loc7_ - 8);
                                       if(_loc17_ > _loc5_)
                                       {
                                          si32(_loc17_,_loc7_ - 8);
                                       }
                                       _loc5_ = _loc17_ << 2;
                                       _loc3_ = li32(_loc7_ - 48);
                                       _loc5_ = _loc3_ + _loc5_;
                                       si32(2,_loc5_);
                                       _loc17_ += 1;
                                       si32(_loc17_,_loc7_ - 4);
                                       _loc18_ = _loc12_;
                                       break;
                                    }
                                    _loc5_ = _loc15_ << 24;
                                    _loc15_ = _loc5_ >> 24;
                                    _loc5_ = _loc15_ + -48;
                                    if((uint(_loc5_)) <= 9)
                                    {
                                       _loc18_ += 1;
                                       do
                                       {
                                          _loc12_ = _loc18_ + 1;
                                          _loc15_ = si8(li8(_loc18_));
                                          _loc5_ = _loc15_ + -48;
                                          _loc18_ = _loc12_;
                                       }
                                       while(uint(_loc5_) < 10);
                                    }
                                    continue;
                                 }
                              }
                           }
                        }
                        else if(_loc15_ <= 70)
                        {
                           if(_loc15_ <= 67)
                           {
                              if(_loc15_ == 65)
                              {
                                 break loop1;
                              }
                              if(_loc15_ == 67)
                              {
                                 _loc13_ |= 16;
                                 addr0bef:
                                 _loc5_ = _loc13_ & 0x10;
                                 _loc2_ = 2;
                                 if(_loc5_ != 0)
                                 {
                                    _loc2_ = 24;
                                 }
                                 _loc12_ = li32(_loc7_ - 12);
                                 if(_loc17_ >= _loc12_)
                                 {
                                    _loc13_ = _loc12_ << 1;
                                    _loc17_ = _loc10_ = _loc17_ + 1;
                                    if(_loc10_ <= _loc13_)
                                    {
                                       _loc17_ = _loc13_;
                                    }
                                    _loc15_ = _loc17_ << 2;
                                    _loc8_ = li32(_loc7_ - 48);
                                    if(_loc12_ == 8)
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative.F_malloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc9_ = wdnative.eax;
                                       if(_loc9_ == 0)
                                       {
                                          break loop0;
                                       }
                                       _loc5_ = _loc12_ << 2;
                                       _loc1_ = ram;
                                       _loc1_.position = _loc9_;
                                       _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                    }
                                    else
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_ + 4);
                                       si32(_loc8_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative_nternal.F_realloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc9_ = wdnative.eax;
                                       if(_loc9_ == 0)
                                       {
                                          break loop0;
                                       }
                                    }
                                    if(_loc12_ < _loc17_)
                                    {
                                       _loc4_ -= 16;
                                       si32(0,_loc4_ + 4);
                                       var _temp_76:* = _loc12_ << 2;
                                       _loc5_ = _loc9_ + _temp_76;
                                       si32(_loc5_,_loc4_);
                                       if(_loc13_ <= _loc10_)
                                       {
                                          _loc13_ = _loc10_;
                                       }
                                       _loc5_ = _loc13_ - _loc12_;
                                       _loc5_ = _loc5_ << 2;
                                       si32(_loc5_,_loc4_ + 8);
                                       wdnative.ESP = _loc4_;
                                       wdnative.Fmemset();
                                       _loc4_ += 16;
                                    }
                                    si32(_loc9_,_loc7_ - 48);
                                    si32(_loc17_,_loc7_ - 12);
                                    _loc17_ = li32(_loc7_ - 4);
                                 }
                                 _loc5_ = li32(_loc7_ - 8);
                                 if(_loc17_ > _loc5_)
                                 {
                                    si32(_loc17_,_loc7_ - 8);
                                 }
                                 _loc3_ = _loc17_ << 2;
                                 _loc5_ = li32(_loc7_ - 48);
                                 _loc5_ = _loc5_ + _loc3_;
                                 si32(_loc2_,_loc5_);
                                 _loc17_ += 1;
                                 si32(_loc17_,_loc7_ - 4);
                                 continue loop0;
                              }
                           }
                           else
                           {
                              if(_loc15_ == 68)
                              {
                                 _loc13_ |= 16;
                                 addr0db1:
                                 _loc12_ = li32(_loc7_ - 12);
                                 if(_loc17_ >= _loc12_)
                                 {
                                    _loc2_ = _loc12_ << 1;
                                    _loc17_ = _loc8_ = _loc17_ + 1;
                                    if(_loc8_ <= _loc2_)
                                    {
                                       _loc17_ = _loc2_;
                                    }
                                    _loc15_ = _loc17_ << 2;
                                    _loc10_ = li32(_loc7_ - 48);
                                    if(_loc12_ == 8)
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative.F_malloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc9_ = wdnative.eax;
                                       if(_loc9_ == 0)
                                       {
                                          break loop0;
                                       }
                                       _loc5_ = _loc12_ << 2;
                                       _loc1_ = ram;
                                       _loc1_.position = _loc9_;
                                       _loc1_.writeBytes(_loc1_,_loc10_,_loc5_);
                                    }
                                    else
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_ + 4);
                                       si32(_loc10_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative_nternal.F_realloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc9_ = wdnative.eax;
                                       if(_loc9_ == 0)
                                       {
                                          break loop0;
                                       }
                                    }
                                    if(_loc12_ < _loc17_)
                                    {
                                       _loc4_ -= 16;
                                       si32(0,_loc4_ + 4);
                                       var _temp_88:* = _loc12_ << 2;
                                       _loc5_ = _loc9_ + _temp_88;
                                       si32(_loc5_,_loc4_);
                                       if(_loc2_ <= _loc8_)
                                       {
                                          _loc2_ = _loc8_;
                                       }
                                       _loc5_ = _loc2_ - _loc12_;
                                       _loc5_ = _loc5_ << 2;
                                       si32(_loc5_,_loc4_ + 8);
                                       wdnative.ESP = _loc4_;
                                       wdnative.Fmemset();
                                       _loc4_ += 16;
                                    }
                                    si32(_loc9_,_loc7_ - 48);
                                    si32(_loc17_,_loc7_ - 12);
                                    _loc17_ = li32(_loc7_ - 4);
                                 }
                                 _loc5_ = li32(_loc7_ - 8);
                                 if(_loc17_ > _loc5_)
                                 {
                                    si32(_loc17_,_loc7_ - 8);
                                 }
                                 _loc5_ = _loc13_ & 0x1000;
                                 if(_loc5_ != 0)
                                 {
                                    var _temp_94:* = _loc17_ << 2;
                                    var _temp_95:* = int(li32(_loc7_ - 48) + _temp_94);
                                    si32(16,_temp_95);
                                    _loc17_ += 1;
                                    si32(_loc17_,_loc7_ - 4);
                                 }
                                 else
                                 {
                                    _loc5_ = _loc13_ & 0x0400;
                                    if(_loc5_ != 0)
                                    {
                                       var _temp_98:* = _loc17_ << 2;
                                       var _temp_99:* = int(li32(_loc7_ - 48) + _temp_98);
                                       si32(13,_temp_99);
                                       _loc17_ += 1;
                                       si32(_loc17_,_loc7_ - 4);
                                    }
                                    else
                                    {
                                       _loc5_ = _loc13_ & 0x0800;
                                       if(_loc5_ != 0)
                                       {
                                          var _temp_102:* = _loc17_ << 2;
                                          var _temp_103:* = int(li32(_loc7_ - 48) + _temp_102);
                                          si32(11,_temp_103);
                                          _loc17_ += 1;
                                          si32(_loc17_,_loc7_ - 4);
                                       }
                                       else
                                       {
                                          _loc5_ = _loc13_ & 0x20;
                                          if(_loc5_ != 0)
                                          {
                                             var _temp_106:* = _loc17_ << 2;
                                             var _temp_107:* = int(li32(_loc7_ - 48) + _temp_106);
                                             si32(8,_temp_107);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                          else
                                          {
                                             var _temp_109:* = _loc13_ & 0x10;
                                             _loc15_ = li32(_loc7_ - 48);
                                             if(_temp_109 != 0)
                                             {
                                                var _temp_110:* = _loc17_ << 2;
                                                var _temp_111:* = int(_loc15_ + _temp_110);
                                                si32(5,_temp_111);
                                                _loc17_ += 1;
                                                si32(_loc17_,_loc7_ - 4);
                                             }
                                             else
                                             {
                                                var _temp_113:* = _loc17_ << 2;
                                                var _temp_114:* = int(_loc15_ + _temp_113);
                                                si32(2,_temp_114);
                                                _loc17_ += 1;
                                                si32(_loc17_,_loc7_ - 4);
                                             }
                                          }
                                       }
                                    }
                                 }
                                 continue loop0;
                              }
                              if(_loc15_ == 69)
                              {
                                 break loop1;
                              }
                           }
                        }
                        else if(_loc15_ <= 78)
                        {
                           if(_loc15_ == 71)
                           {
                              break loop1;
                           }
                           if(_loc15_ == 76)
                           {
                              _loc13_ |= 8;
                              break;
                           }
                        }
                        else
                        {
                           if(_loc15_ == 79)
                           {
                              _loc13_ |= 16;
                              addr1f7b:
                              _loc2_ = li32(_loc7_ - 12);
                              if(_loc17_ >= _loc2_)
                              {
                                 _loc12_ = _loc2_ << 1;
                                 _loc17_ = _loc8_ = _loc17_ + 1;
                                 if(_loc8_ <= _loc12_)
                                 {
                                    _loc17_ = _loc12_;
                                 }
                                 _loc15_ = _loc17_ << 2;
                                 _loc10_ = li32(_loc7_ - 48);
                                 if(_loc2_ == 8)
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative.F_malloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                    _loc5_ = _loc2_ << 2;
                                    _loc1_ = ram;
                                    _loc1_.position = _loc9_;
                                    _loc1_.writeBytes(_loc1_,_loc10_,_loc5_);
                                 }
                                 else
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_ + 4);
                                    si32(_loc10_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative_nternal.F_realloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                 }
                                 if(_loc2_ < _loc17_)
                                 {
                                    _loc4_ -= 16;
                                    si32(0,_loc4_ + 4);
                                    var _temp_166:* = _loc2_ << 2;
                                    _loc5_ = _loc9_ + _temp_166;
                                    si32(_loc5_,_loc4_);
                                    if(_loc12_ <= _loc8_)
                                    {
                                       _loc12_ = _loc8_;
                                    }
                                    _loc5_ = _loc12_ - _loc2_;
                                    _loc5_ = _loc5_ << 2;
                                    si32(_loc5_,_loc4_ + 8);
                                    wdnative.ESP = _loc4_;
                                    wdnative.Fmemset();
                                    _loc4_ += 16;
                                 }
                                 si32(_loc9_,_loc7_ - 48);
                                 si32(_loc17_,_loc7_ - 12);
                                 _loc17_ = li32(_loc7_ - 4);
                              }
                              _loc5_ = li32(_loc7_ - 8);
                              if(_loc17_ > _loc5_)
                              {
                                 si32(_loc17_,_loc7_ - 8);
                              }
                              _loc5_ = _loc13_ & 0x1000;
                              if(_loc5_ != 0)
                              {
                                 var _temp_172:* = _loc17_ << 2;
                                 var _temp_173:* = int(li32(_loc7_ - 48) + _temp_172);
                                 si32(17,_temp_173);
                                 _loc17_ += 1;
                                 si32(_loc17_,_loc7_ - 4);
                              }
                              else
                              {
                                 _loc5_ = _loc13_ & 0x0400;
                                 if(_loc5_ != 0)
                                 {
                                    var _temp_176:* = _loc17_ << 2;
                                    var _temp_177:* = int(li32(_loc7_ - 48) + _temp_176);
                                    si32(14,_temp_177);
                                    _loc17_ += 1;
                                    si32(_loc17_,_loc7_ - 4);
                                 }
                                 else
                                 {
                                    _loc5_ = _loc13_ & 0x0800;
                                    if(_loc5_ != 0)
                                    {
                                       var _temp_180:* = _loc17_ << 2;
                                       var _temp_181:* = int(li32(_loc7_ - 48) + _temp_180);
                                       si32(14,_temp_181);
                                       _loc17_ += 1;
                                       si32(_loc17_,_loc7_ - 4);
                                    }
                                    else
                                    {
                                       _loc5_ = _loc13_ & 0x20;
                                       if(_loc5_ != 0)
                                       {
                                          var _temp_185:* = _loc17_ << 2;
                                          var _temp_186:* = int((_loc5_ = li32(_loc7_ - 48)) + _temp_185);
                                          si32(9,_temp_186);
                                          _loc17_ += 1;
                                          si32(_loc17_,_loc7_ - 4);
                                       }
                                       else
                                       {
                                          var _temp_188:* = _loc13_ & 0x10;
                                          _loc15_ = li32(_loc7_ - 48);
                                          if(_temp_188 != 0)
                                          {
                                             var _temp_189:* = _loc17_ << 2;
                                             var _temp_190:* = int(_loc15_ + _temp_189);
                                             si32(6,_temp_190);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                          else
                                          {
                                             var _temp_192:* = _loc17_ << 2;
                                             var _temp_193:* = int(_loc15_ + _temp_192);
                                             si32(3,_temp_193);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                       }
                                    }
                                 }
                              }
                              continue loop0;
                           }
                           if(_loc15_ == 83)
                           {
                              _loc13_ |= 16;
                              addr23c6:
                              _loc5_ = _loc13_ & 0x10;
                              _loc12_ = 20;
                              if(_loc5_ != 0)
                              {
                                 _loc12_ = 25;
                              }
                              _loc2_ = li32(_loc7_ - 12);
                              if(_loc17_ >= _loc2_)
                              {
                                 _loc13_ = _loc2_ << 1;
                                 _loc17_ = _loc10_ = _loc17_ + 1;
                                 if(_loc10_ <= _loc13_)
                                 {
                                    _loc17_ = _loc13_;
                                 }
                                 _loc15_ = _loc17_ << 2;
                                 _loc8_ = li32(_loc7_ - 48);
                                 if(_loc2_ == 8)
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative.F_malloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                    _loc5_ = _loc2_ << 2;
                                    _loc1_ = ram;
                                    _loc1_.position = _loc9_;
                                    _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                 }
                                 else
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_ + 4);
                                    si32(_loc8_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative_nternal.F_realloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                 }
                                 if(_loc2_ < _loc17_)
                                 {
                                    _loc4_ -= 16;
                                    si32(0,_loc4_ + 4);
                                    var _temp_154:* = _loc2_ << 2;
                                    _loc5_ = _loc9_ + _temp_154;
                                    si32(_loc5_,_loc4_);
                                    if(_loc13_ <= _loc10_)
                                    {
                                       _loc13_ = _loc10_;
                                    }
                                    _loc5_ = _loc13_ - _loc2_;
                                    _loc5_ = _loc5_ << 2;
                                    si32(_loc5_,_loc4_ + 8);
                                    wdnative.ESP = _loc4_;
                                    wdnative.Fmemset();
                                    _loc4_ += 16;
                                 }
                                 si32(_loc9_,_loc7_ - 48);
                                 si32(_loc17_,_loc7_ - 12);
                                 _loc17_ = li32(_loc7_ - 4);
                              }
                              _loc5_ = li32(_loc7_ - 8);
                              if(_loc17_ > _loc5_)
                              {
                                 si32(_loc17_,_loc7_ - 8);
                              }
                              _loc3_ = _loc17_ << 2;
                              _loc5_ = li32(_loc7_ - 48);
                              _loc5_ = _loc5_ + _loc3_;
                              si32(_loc12_,_loc5_);
                              _loc17_ += 1;
                              si32(_loc17_,_loc7_ - 4);
                              continue loop0;
                           }
                           if(_loc15_ == 85)
                           {
                              _loc13_ |= 16;
                              addr2583:
                              _loc2_ = li32(_loc7_ - 12);
                              if(_loc17_ >= _loc2_)
                              {
                                 _loc12_ = _loc2_ << 1;
                                 _loc10_ = _loc8_ = _loc17_ + 1;
                                 if(_loc8_ <= _loc12_)
                                 {
                                    _loc10_ = _loc12_;
                                 }
                                 _loc15_ = _loc10_ << 2;
                                 _loc17_ = li32(_loc7_ - 48);
                                 if(_loc2_ == 8)
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative.F_malloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                    _loc5_ = _loc2_ << 2;
                                    _loc1_ = ram;
                                    _loc1_.position = _loc9_;
                                    _loc1_.writeBytes(_loc1_,_loc17_,_loc5_);
                                 }
                                 else
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_ + 4);
                                    si32(_loc17_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative_nternal.F_realloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc9_ = wdnative.eax;
                                    if(_loc9_ == 0)
                                    {
                                       break loop0;
                                    }
                                 }
                                 if(_loc2_ < _loc10_)
                                 {
                                    _loc4_ -= 16;
                                    si32(0,_loc4_ + 4);
                                    var _temp_121:* = _loc2_ << 2;
                                    _loc5_ = _loc9_ + _temp_121;
                                    si32(_loc5_,_loc4_);
                                    if(_loc12_ <= _loc8_)
                                    {
                                       _loc12_ = _loc8_;
                                    }
                                    _loc5_ = _loc12_ - _loc2_;
                                    _loc5_ = _loc5_ << 2;
                                    si32(_loc5_,_loc4_ + 8);
                                    wdnative.ESP = _loc4_;
                                    wdnative.Fmemset();
                                    _loc4_ += 16;
                                 }
                                 si32(_loc9_,_loc7_ - 48);
                                 si32(_loc10_,_loc7_ - 12);
                                 _loc17_ = li32(_loc7_ - 4);
                              }
                              _loc5_ = li32(_loc7_ - 8);
                              if(_loc17_ > _loc5_)
                              {
                                 si32(_loc17_,_loc7_ - 8);
                              }
                              _loc5_ = _loc13_ & 0x1000;
                              if(_loc5_ != 0)
                              {
                                 var _temp_127:* = _loc17_ << 2;
                                 var _temp_128:* = int(li32(_loc7_ - 48) + _temp_127);
                                 si32(17,_temp_128);
                                 _loc17_ += 1;
                                 si32(_loc17_,_loc7_ - 4);
                              }
                              else
                              {
                                 _loc5_ = _loc13_ & 0x0400;
                                 if(_loc5_ != 0)
                                 {
                                    var _temp_131:* = _loc17_ << 2;
                                    var _temp_132:* = int(li32(_loc7_ - 48) + _temp_131);
                                    si32(14,_temp_132);
                                    _loc17_ += 1;
                                    si32(_loc17_,_loc7_ - 4);
                                 }
                                 else
                                 {
                                    _loc5_ = _loc13_ & 0x0800;
                                    if(_loc5_ != 0)
                                    {
                                       var _temp_135:* = _loc17_ << 2;
                                       var _temp_136:* = int(li32(_loc7_ - 48) + _temp_135);
                                       si32(14,_temp_136);
                                       _loc17_ += 1;
                                       si32(_loc17_,_loc7_ - 4);
                                    }
                                    else
                                    {
                                       _loc5_ = _loc13_ & 0x20;
                                       if(_loc5_ != 0)
                                       {
                                          var _temp_139:* = _loc17_ << 2;
                                          var _temp_140:* = int(li32(_loc7_ - 48) + _temp_139);
                                          si32(9,_temp_140);
                                          _loc17_ += 1;
                                          si32(_loc17_,_loc7_ - 4);
                                       }
                                       else
                                       {
                                          var _temp_142:* = _loc13_ & 0x10;
                                          _loc15_ = li32(_loc7_ - 48);
                                          if(_temp_142 != 0)
                                          {
                                             var _temp_143:* = _loc17_ << 2;
                                             var _temp_144:* = int(_loc15_ + _temp_143);
                                             si32(6,_temp_144);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                          else
                                          {
                                             var _temp_146:* = _loc17_ << 2;
                                             var _temp_147:* = int(_loc15_ + _temp_146);
                                             si32(3,_temp_147);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                       }
                                    }
                                 }
                              }
                              continue loop0;
                           }
                        }
                        addr2822:
                        if(_loc15_ == 0)
                        {
                           addr282b:
                           _loc18_ = li32(_loc7_ - 8);
                           if(_loc18_ <= 7)
                           {
                              _loc18_ = li32(_loc20_);
                           }
                           else
                           {
                              _loc4_ -= 16;
                              _loc5_ = _loc18_ << 3;
                              _loc5_ = _loc5_ + 8;
                              si32(_loc5_,_loc4_);
                              wdnative.ESP = _loc4_;
                              wdnative.F_malloc();
                              _loc4_ += 16;
                              _loc18_ = wdnative.eax;
                              si32(_loc18_,_loc20_);
                              _loc15_ = 0;
                              if(_loc18_ == 0)
                              {
                                 break loop0;
                              }
                           }
                           _loc15_ = 0;
                           si32(_loc15_,_loc18_);
                           _loc18_ = 1;
                           _loc5_ = li32(_loc7_ - 8);
                           if(_loc5_ >= 1)
                           {
                              do
                              {
                                 _loc3_ = _loc18_ << 2;
                                 _loc5_ = li32(_loc7_ - 48);
                                 _loc5_ = _loc5_ + _loc3_;
                                 _loc15_ = li32(_loc5_);
                                 if(_loc15_ <= 12)
                                 {
                                    if(_loc15_ <= 5)
                                    {
                                       if(_loc15_ <= 2)
                                       {
                                          if(_loc15_ != 0)
                                          {
                                             if(_loc15_ != 1)
                                             {
                                                if(_loc15_ == 2)
                                                {
                                                   var _temp_204:* = _loc18_ << 3;
                                                   var _temp_206:* = int(li32(_loc20_) + _temp_204);
                                                   si32(_loc5_ = li32(_loc19_),_temp_206);
                                                   _loc19_ += 4;
                                                }
                                             }
                                             else
                                             {
                                                var _temp_208:* = _loc18_ << 3;
                                                var _temp_210:* = int((_loc5_ = li32(_loc20_)) + _temp_208);
                                                si32(_loc5_ = li32(_loc19_),_temp_210);
                                                _loc19_ += 4;
                                             }
                                          }
                                          else
                                          {
                                             var _temp_211:* = _loc18_ << 3;
                                             var _temp_213:* = int(li32(_loc20_) + _temp_211);
                                             si32(_loc5_ = li32(_loc19_),_temp_213);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else if(_loc15_ != 3)
                                       {
                                          if(_loc15_ != 4)
                                          {
                                             if(_loc15_ == 5)
                                             {
                                                var _temp_215:* = _loc18_ << 3;
                                                var _temp_216:* = int((_loc5_ = li32(_loc20_)) + _temp_215);
                                                si32(li32(_loc19_),_temp_216);
                                                _loc19_ += 4;
                                             }
                                          }
                                          else
                                          {
                                             var _temp_218:* = _loc18_ << 3;
                                             var _temp_220:* = int((_loc5_ = li32(_loc20_)) + _temp_218);
                                             si32(_loc5_ = li32(_loc19_),_temp_220);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_222:* = _loc18_ << 3;
                                          var _temp_224:* = int((_loc5_ = li32(_loc20_)) + _temp_222);
                                          si32(_loc5_ = li32(_loc19_),_temp_224);
                                          _loc19_ += 4;
                                       }
                                    }
                                    else if(_loc15_ <= 8)
                                    {
                                       if(_loc15_ != 6)
                                       {
                                          if(_loc15_ != 7)
                                          {
                                             if(_loc15_ == 8)
                                             {
                                                var _temp_226:* = _loc18_ << 3;
                                                var _loc6_:int = (_loc5_ = li32(_loc20_)) + _temp_226;
                                                var _temp_228:* = li32(_loc19_);
                                                si32(_loc5_ = li32(_loc19_ + 4),_loc6_ + 4);
                                                si32(_temp_228,_loc6_);
                                                _loc19_ += 8;
                                             }
                                          }
                                          else
                                          {
                                             var _temp_230:* = _loc18_ << 3;
                                             var _temp_231:* = int((_loc5_ = li32(_loc20_)) + _temp_230);
                                             si32(li32(_loc19_),_temp_231);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_233:* = _loc18_ << 3;
                                          var _temp_235:* = int((_loc5_ = li32(_loc20_)) + _temp_233);
                                          si32(_loc5_ = li32(_loc19_),_temp_235);
                                          _loc19_ += 4;
                                       }
                                    }
                                    else if(_loc15_ <= 10)
                                    {
                                       if(_loc15_ != 9)
                                       {
                                          if(_loc15_ == 10)
                                          {
                                             var _temp_237:* = _loc18_ << 3;
                                             var _temp_239:* = int((_loc5_ = li32(_loc20_)) + _temp_237);
                                             si32(_loc5_ = li32(_loc19_),_temp_239);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_241:* = _loc18_ << 3;
                                          _loc6_ = (_loc5_ = li32(_loc20_)) + _temp_241;
                                          var _temp_243:* = li32(_loc19_);
                                          si32(_loc5_ = li32(_loc19_ + 4),_loc6_ + 4);
                                          si32(_temp_243,_loc6_);
                                          _loc19_ += 8;
                                       }
                                    }
                                    else if(_loc15_ != 11)
                                    {
                                       if(_loc15_ == 12)
                                       {
                                          var _temp_244:* = _loc18_ << 3;
                                          var _temp_245:* = int(li32(_loc20_) + _temp_244);
                                          si32(li32(_loc19_),_temp_245);
                                          _loc19_ += 4;
                                       }
                                    }
                                    else
                                    {
                                       var _temp_247:* = _loc18_ << 3;
                                       var _temp_249:* = int((_loc5_ = li32(_loc20_)) + _temp_247);
                                       si32(_loc5_ = li32(_loc19_),_temp_249);
                                       _loc19_ += 4;
                                    }
                                 }
                                 else if(_loc15_ <= 18)
                                 {
                                    if(_loc15_ <= 15)
                                    {
                                       if(_loc15_ != 13)
                                       {
                                          if(_loc15_ != 14)
                                          {
                                             if(_loc15_ == 15)
                                             {
                                                var _temp_251:* = _loc18_ << 3;
                                                var _temp_253:* = int((_loc5_ = li32(_loc20_)) + _temp_251);
                                                si32(_loc5_ = li32(_loc19_),_temp_253);
                                                _loc19_ += 4;
                                             }
                                          }
                                          else
                                          {
                                             var _temp_254:* = _loc18_ << 3;
                                             var _temp_256:* = int(li32(_loc20_) + _temp_254);
                                             si32(_loc5_ = li32(_loc19_),_temp_256);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_258:* = _loc18_ << 3;
                                          var _temp_260:* = int((_loc5_ = li32(_loc20_)) + _temp_258);
                                          si32(_loc5_ = li32(_loc19_),_temp_260);
                                          _loc19_ += 4;
                                       }
                                    }
                                    else if(_loc15_ != 16)
                                    {
                                       if(_loc15_ != 17)
                                       {
                                          if(_loc15_ == 18)
                                          {
                                             var _temp_262:* = _loc18_ << 3;
                                             var _temp_263:* = int((_loc5_ = li32(_loc20_)) + _temp_262);
                                             si32(li32(_loc19_),_temp_263);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_264:* = _loc18_ << 3;
                                          _loc5_ = li32(_loc20_) + _temp_264;
                                          var _temp_266:* = li32(_loc19_);
                                          si32(_loc6_ = li32(_loc19_ + 4),_loc5_ + 4);
                                          si32(_temp_266,_loc5_);
                                          _loc19_ += 8;
                                       }
                                    }
                                    else
                                    {
                                       var _temp_268:* = _loc18_ << 3;
                                       _loc3_ = (_loc5_ = li32(_loc20_)) + _temp_268;
                                       var _temp_270:* = li32(_loc19_);
                                       si32(_loc5_ = li32(_loc19_ + 4),_loc3_ + 4);
                                       si32(_temp_270,_loc3_);
                                       _loc19_ += 8;
                                    }
                                 }
                                 else if(_loc15_ <= 21)
                                 {
                                    if(_loc15_ != 19)
                                    {
                                       if(_loc15_ != 20)
                                       {
                                          if(_loc15_ == 21)
                                          {
                                             var _temp_272:* = _loc18_ << 3;
                                             var _temp_273:* = int((_loc5_ = li32(_loc20_)) + _temp_272);
                                             si32(li32(_loc19_),_temp_273);
                                             _loc19_ += 4;
                                          }
                                       }
                                       else
                                       {
                                          var _temp_275:* = _loc18_ << 3;
                                          var _temp_277:* = int((_loc5_ = li32(_loc20_)) + _temp_275);
                                          si32(_loc5_ = li32(_loc19_),_temp_277);
                                          _loc19_ += 4;
                                       }
                                    }
                                    else
                                    {
                                       var _temp_279:* = _loc18_ << 3;
                                       var _temp_281:* = int((_loc5_ = li32(_loc20_)) + _temp_279);
                                       si32(_loc5_ = li32(_loc19_),_temp_281);
                                       _loc19_ += 4;
                                    }
                                 }
                                 else if(_loc15_ <= 23)
                                 {
                                    if(_loc15_ != 22)
                                    {
                                       if(_loc15_ == 23)
                                       {
                                          var _temp_283:* = _loc18_ << 3;
                                          var _temp_285:* = int((_loc5_ = li32(_loc20_)) + _temp_283);
                                          var _loc14_:Number;
                                          sf64(_loc14_ = lf64(_loc19_),_temp_285);
                                          _loc19_ += 8;
                                       }
                                    }
                                    else
                                    {
                                       var _temp_287:* = _loc18_ << 3;
                                       var _temp_289:* = int((_loc5_ = li32(_loc20_)) + _temp_287);
                                       var _loc16_:Number;
                                       sf64(_loc16_ = lf64(_loc19_),_temp_289);
                                       _loc19_ += 8;
                                    }
                                 }
                                 else if(_loc15_ != 24)
                                 {
                                    if(_loc15_ == 25)
                                    {
                                       var _temp_291:* = _loc18_ << 3;
                                       var _temp_293:* = int((_loc5_ = li32(_loc20_)) + _temp_291);
                                       si32(_loc5_ = li32(_loc19_),_temp_293);
                                       _loc19_ += 4;
                                    }
                                 }
                                 else
                                 {
                                    var _temp_295:* = _loc18_ << 3;
                                    var _temp_297:* = int((_loc5_ = li32(_loc20_)) + _temp_295);
                                    si32(_loc5_ = li32(_loc19_),_temp_297);
                                    _loc19_ += 4;
                                 }
                                 _loc18_ += 1;
                                 _loc15_ = 0;
                              }
                              while(_loc5_ = li32(_loc7_ - 8), _loc5_ >= _loc18_);
                           }
                           break loop0;
                        }
                        continue loop0;
                     }
                     if(_loc15_ <= 109)
                     {
                        if(_loc15_ <= 100)
                        {
                           if(_loc15_ <= 98)
                           {
                              if(_loc15_ != 88)
                              {
                                 if(_loc15_ == 97)
                                 {
                                    break loop1;
                                 }
                              }
                              else
                              {
                                 §§goto(addr2583);
                              }
                           }
                           else if(_loc15_ != 99)
                           {
                              if(_loc15_ == 100)
                              {
                                 §§goto(addr0db1);
                              }
                           }
                           else
                           {
                              §§goto(addr0bef);
                           }
                        }
                        else if(_loc15_ <= 104)
                        {
                           _loc5_ = _loc15_ + -101;
                           if((uint(_loc5_)) < 3)
                           {
                              break loop1;
                           }
                           if(_loc15_ == 104)
                           {
                              _loc5_ = _loc13_ & 0x40;
                              if(_loc5_ != 0)
                              {
                                 _loc5_ = _loc13_ & -8257;
                                 _loc13_ = _loc5_ | 0x2000;
                                 break;
                              }
                              _loc13_ |= 64;
                              break;
                           }
                        }
                        else if(_loc15_ != 105)
                        {
                           if(_loc15_ == 106)
                           {
                              _loc13_ |= 4096;
                              break;
                           }
                           if(_loc15_ == 108)
                           {
                              _loc5_ = _loc13_ & 0x10;
                              if(_loc5_ != 0)
                              {
                                 _loc5_ = _loc13_ & -49;
                                 _loc13_ = _loc5_ | 0x20;
                                 break;
                              }
                              _loc13_ |= 16;
                              break;
                           }
                        }
                        else
                        {
                           §§goto(addr0db1);
                        }
                     }
                     else if(_loc15_ <= 114)
                     {
                        if(_loc15_ <= 111)
                        {
                           if(_loc15_ == 110)
                           {
                              _loc5_ = _loc13_ & 0x1000;
                              if(_loc5_ != 0)
                              {
                                 _loc13_ = li32(_loc7_ - 12);
                                 if(_loc17_ >= _loc13_)
                                 {
                                    _loc12_ = _loc13_ << 1;
                                    _loc2_ = _loc17_ + 1;
                                    _loc8_ = _loc2_;
                                    if(_loc2_ <= _loc12_)
                                    {
                                       _loc8_ = _loc12_;
                                    }
                                    _loc15_ = _loc8_ << 2;
                                    _loc17_ = li32(_loc7_ - 48);
                                    if(_loc13_ == 8)
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative.F_malloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc10_ = wdnative.eax;
                                       if(_loc10_ == 0)
                                       {
                                          break loop0;
                                       }
                                       _loc5_ = _loc13_ << 2;
                                       _loc1_ = ram;
                                       _loc1_.position = _loc10_;
                                       _loc1_.writeBytes(_loc1_,_loc17_,_loc5_);
                                    }
                                    else
                                    {
                                       _loc4_ -= 16;
                                       si32(_loc15_,_loc4_ + 4);
                                       si32(_loc17_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative_nternal.F_realloc();
                                       _loc15_ = -1;
                                       _loc4_ += 16;
                                       _loc10_ = wdnative.eax;
                                       if(_loc10_ == 0)
                                       {
                                          break loop0;
                                       }
                                    }
                                    if(_loc13_ < _loc8_)
                                    {
                                       _loc4_ -= 16;
                                       si32(0,_loc4_ + 4);
                                       var _temp_309:* = _loc13_ << 2;
                                       _loc5_ = _loc10_ + _temp_309;
                                       si32(_loc5_,_loc4_);
                                       if(_loc12_ <= _loc2_)
                                       {
                                          _loc12_ = _loc2_;
                                       }
                                       _loc5_ = _loc12_ - _loc13_;
                                       _loc5_ = _loc5_ << 2;
                                       si32(_loc5_,_loc4_ + 8);
                                       wdnative.ESP = _loc4_;
                                       wdnative.Fmemset();
                                       _loc4_ += 16;
                                    }
                                    si32(_loc10_,_loc7_ - 48);
                                    si32(_loc8_,_loc7_ - 12);
                                    _loc17_ = li32(_loc7_ - 4);
                                 }
                                 _loc5_ = li32(_loc7_ - 8);
                                 if(_loc17_ > _loc5_)
                                 {
                                    si32(_loc17_,_loc7_ - 8);
                                 }
                                 _loc3_ = _loc17_ << 2;
                                 _loc5_ = li32(_loc7_ - 48);
                                 _loc5_ = _loc5_ + _loc3_;
                                 si32(18,_loc5_);
                                 _loc17_ += 1;
                                 si32(_loc17_,_loc7_ - 4);
                              }
                              else
                              {
                                 _loc5_ = _loc13_ & 0x0800;
                                 if(_loc5_ != 0)
                                 {
                                    _loc13_ = li32(_loc7_ - 12);
                                    if(_loc17_ >= _loc13_)
                                    {
                                       _loc12_ = _loc13_ << 1;
                                       _loc2_ = _loc17_ += 1;
                                       if(_loc17_ <= _loc12_)
                                       {
                                          _loc2_ = _loc12_;
                                       }
                                       _loc15_ = _loc2_ << 2;
                                       _loc8_ = li32(_loc7_ - 48);
                                       if(_loc13_ == 8)
                                       {
                                          _loc4_ -= 16;
                                          si32(_loc15_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative.F_malloc();
                                          _loc15_ = -1;
                                          _loc4_ += 16;
                                          _loc10_ = wdnative.eax;
                                          if(_loc10_ == 0)
                                          {
                                             break loop0;
                                          }
                                          _loc5_ = _loc13_ << 2;
                                          _loc1_ = ram;
                                          _loc1_.position = _loc10_;
                                          _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                       }
                                       else
                                       {
                                          _loc4_ -= 16;
                                          si32(_loc15_,_loc4_ + 4);
                                          si32(_loc8_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative_nternal.F_realloc();
                                          _loc15_ = -1;
                                          _loc4_ += 16;
                                          _loc10_ = wdnative.eax;
                                          if(_loc10_ == 0)
                                          {
                                             break loop0;
                                          }
                                       }
                                       if(_loc13_ < _loc2_)
                                       {
                                          _loc4_ -= 16;
                                          si32(0,_loc4_ + 4);
                                          var _temp_322:* = _loc13_ << 2;
                                          _loc5_ = _loc10_ + _temp_322;
                                          si32(_loc5_,_loc4_);
                                          if(_loc12_ <= _loc17_)
                                          {
                                             _loc12_ = _loc17_;
                                          }
                                          _loc5_ = _loc12_ - _loc13_;
                                          _loc5_ = _loc5_ << 2;
                                          si32(_loc5_,_loc4_ + 8);
                                          wdnative.ESP = _loc4_;
                                          wdnative.Fmemset();
                                          _loc4_ += 16;
                                       }
                                       si32(_loc10_,_loc7_ - 48);
                                       si32(_loc2_,_loc7_ - 12);
                                       _loc17_ = li32(_loc7_ - 4);
                                    }
                                    _loc5_ = li32(_loc7_ - 8);
                                    if(_loc17_ > _loc5_)
                                    {
                                       si32(_loc17_,_loc7_ - 8);
                                    }
                                    _loc3_ = _loc17_ << 2;
                                    _loc5_ = li32(_loc7_ - 48);
                                    _loc5_ = _loc5_ + _loc3_;
                                    si32(12,_loc5_);
                                    _loc17_ += 1;
                                    si32(_loc17_,_loc7_ - 4);
                                 }
                                 else
                                 {
                                    _loc5_ = _loc13_ & 0x0400;
                                    if(_loc5_ != 0)
                                    {
                                       _loc13_ = li32(_loc7_ - 12);
                                       if(_loc17_ >= _loc13_)
                                       {
                                          _loc12_ = _loc13_ << 1;
                                          _loc17_ = _loc8_ = _loc17_ + 1;
                                          if(_loc8_ <= _loc12_)
                                          {
                                             _loc17_ = _loc12_;
                                          }
                                          _loc15_ = _loc17_ << 2;
                                          _loc2_ = li32(_loc7_ - 48);
                                          if(_loc13_ == 8)
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative.F_malloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc10_ = wdnative.eax;
                                             if(_loc10_ == 0)
                                             {
                                                break loop0;
                                             }
                                             _loc5_ = _loc13_ << 2;
                                             _loc1_ = ram;
                                             _loc1_.position = _loc10_;
                                             _loc1_.writeBytes(_loc1_,_loc2_,_loc5_);
                                          }
                                          else
                                          {
                                             _loc4_ -= 16;
                                             si32(_loc15_,_loc4_ + 4);
                                             si32(_loc2_,_loc4_);
                                             wdnative.ESP = _loc4_;
                                             wdnative_nternal.F_realloc();
                                             _loc15_ = -1;
                                             _loc4_ += 16;
                                             _loc10_ = wdnative.eax;
                                             if(_loc10_ == 0)
                                             {
                                                break loop0;
                                             }
                                          }
                                          if(_loc13_ < _loc17_)
                                          {
                                             _loc4_ -= 16;
                                             si32(0,_loc4_ + 4);
                                             var _temp_335:* = _loc13_ << 2;
                                             _loc5_ = _loc10_ + _temp_335;
                                             si32(_loc5_,_loc4_);
                                             if(_loc12_ <= _loc8_)
                                             {
                                                _loc12_ = _loc8_;
                                             }
                                             _loc5_ = _loc12_ - _loc13_;
                                             _loc5_ = _loc5_ << 2;
                                             si32(_loc5_,_loc4_ + 8);
                                             wdnative.ESP = _loc4_;
                                             wdnative.Fmemset();
                                             _loc4_ += 16;
                                          }
                                          si32(_loc10_,_loc7_ - 48);
                                          si32(_loc17_,_loc7_ - 12);
                                          _loc17_ = li32(_loc7_ - 4);
                                       }
                                       _loc5_ = li32(_loc7_ - 8);
                                       if(_loc17_ > _loc5_)
                                       {
                                          si32(_loc17_,_loc7_ - 8);
                                       }
                                       _loc5_ = _loc17_ << 2;
                                       _loc3_ = li32(_loc7_ - 48);
                                       _loc5_ = _loc3_ + _loc5_;
                                       si32(15,_loc5_);
                                       _loc17_ += 1;
                                       si32(_loc17_,_loc7_ - 4);
                                    }
                                    else
                                    {
                                       _loc5_ = _loc13_ & 0x20;
                                       if(_loc5_ != 0)
                                       {
                                          _loc13_ = li32(_loc7_ - 12);
                                          if(_loc17_ >= _loc13_)
                                          {
                                             _loc12_ = _loc13_ << 1;
                                             _loc2_ = _loc17_ + 1;
                                             _loc17_ = _loc2_;
                                             if(_loc2_ <= _loc12_)
                                             {
                                                _loc17_ = _loc12_;
                                             }
                                             _loc15_ = _loc17_ << 2;
                                             _loc8_ = li32(_loc7_ - 48);
                                             if(_loc13_ == 8)
                                             {
                                                _loc4_ -= 16;
                                                si32(_loc15_,_loc4_);
                                                wdnative.ESP = _loc4_;
                                                wdnative.F_malloc();
                                                _loc15_ = -1;
                                                _loc4_ += 16;
                                                _loc10_ = wdnative.eax;
                                                if(_loc10_ == 0)
                                                {
                                                   break loop0;
                                                }
                                                _loc5_ = _loc13_ << 2;
                                                _loc1_ = ram;
                                                _loc1_.position = _loc10_;
                                                _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                             }
                                             else
                                             {
                                                _loc4_ -= 16;
                                                si32(_loc15_,_loc4_ + 4);
                                                si32(_loc8_,_loc4_);
                                                wdnative.ESP = _loc4_;
                                                wdnative_nternal.F_realloc();
                                                _loc15_ = -1;
                                                _loc4_ += 16;
                                                _loc10_ = wdnative.eax;
                                                if(_loc10_ == 0)
                                                {
                                                   break loop0;
                                                }
                                             }
                                             if(_loc13_ < _loc17_)
                                             {
                                                _loc4_ -= 16;
                                                si32(0,_loc4_ + 4);
                                                var _temp_346:* = _loc13_ << 2;
                                                _loc5_ = _loc10_ + _temp_346;
                                                si32(_loc5_,_loc4_);
                                                if(_loc12_ <= _loc2_)
                                                {
                                                   _loc12_ = _loc2_;
                                                }
                                                _loc5_ = _loc12_ - _loc13_;
                                                _loc5_ = _loc5_ << 2;
                                                si32(_loc5_,_loc4_ + 8);
                                                wdnative.ESP = _loc4_;
                                                wdnative.Fmemset();
                                                _loc4_ += 16;
                                             }
                                             si32(_loc10_,_loc7_ - 48);
                                             si32(_loc17_,_loc7_ - 12);
                                             _loc17_ = li32(_loc7_ - 4);
                                          }
                                          _loc5_ = li32(_loc7_ - 8);
                                          if(_loc17_ > _loc5_)
                                          {
                                             si32(_loc17_,_loc7_ - 8);
                                          }
                                          _loc5_ = _loc17_ << 2;
                                          _loc3_ = li32(_loc7_ - 48);
                                          _loc5_ = _loc3_ + _loc5_;
                                          si32(10,_loc5_);
                                          _loc17_ += 1;
                                          si32(_loc17_,_loc7_ - 4);
                                       }
                                       else
                                       {
                                          _loc5_ = _loc13_ & 0x10;
                                          if(_loc5_ != 0)
                                          {
                                             _loc13_ = li32(_loc7_ - 12);
                                             if(_loc17_ >= _loc13_)
                                             {
                                                _loc12_ = _loc13_ << 1;
                                                _loc8_ = _loc17_ += 1;
                                                if(_loc17_ <= _loc12_)
                                                {
                                                   _loc8_ = _loc12_;
                                                }
                                                _loc15_ = _loc8_ << 2;
                                                _loc2_ = li32(_loc7_ - 48);
                                                if(_loc13_ == 8)
                                                {
                                                   _loc4_ -= 16;
                                                   si32(_loc15_,_loc4_);
                                                   wdnative.ESP = _loc4_;
                                                   wdnative.F_malloc();
                                                   _loc15_ = -1;
                                                   _loc4_ += 16;
                                                   _loc10_ = wdnative.eax;
                                                   if(_loc10_ == 0)
                                                   {
                                                      break loop0;
                                                   }
                                                   _loc5_ = _loc13_ << 2;
                                                   _loc1_ = ram;
                                                   _loc1_.position = _loc10_;
                                                   _loc1_.writeBytes(_loc1_,_loc2_,_loc5_);
                                                }
                                                else
                                                {
                                                   _loc4_ -= 16;
                                                   si32(_loc15_,_loc4_ + 4);
                                                   si32(_loc2_,_loc4_);
                                                   wdnative.ESP = _loc4_;
                                                   wdnative_nternal.F_realloc();
                                                   _loc15_ = -1;
                                                   _loc4_ += 16;
                                                   _loc10_ = wdnative.eax;
                                                   if(_loc10_ == 0)
                                                   {
                                                      break loop0;
                                                   }
                                                }
                                                if(_loc13_ < _loc8_)
                                                {
                                                   _loc4_ -= 16;
                                                   si32(0,_loc4_ + 4);
                                                   var _temp_358:* = _loc13_ << 2;
                                                   _loc5_ = _loc10_ + _temp_358;
                                                   si32(_loc5_,_loc4_);
                                                   if(_loc12_ <= _loc17_)
                                                   {
                                                      _loc12_ = _loc17_;
                                                   }
                                                   _loc5_ = _loc12_ - _loc13_;
                                                   _loc5_ = _loc5_ << 2;
                                                   si32(_loc5_,_loc4_ + 8);
                                                   wdnative.ESP = _loc4_;
                                                   wdnative.Fmemset();
                                                   _loc4_ += 16;
                                                }
                                                si32(_loc10_,_loc7_ - 48);
                                                si32(_loc8_,_loc7_ - 12);
                                                _loc17_ = li32(_loc7_ - 4);
                                             }
                                             _loc5_ = li32(_loc7_ - 8);
                                             if(_loc17_ > _loc5_)
                                             {
                                                si32(_loc17_,_loc7_ - 8);
                                             }
                                             _loc5_ = _loc17_ << 2;
                                             _loc3_ = li32(_loc7_ - 48);
                                             _loc5_ = _loc3_ + _loc5_;
                                             si32(7,_loc5_);
                                             _loc17_ += 1;
                                             si32(_loc17_,_loc7_ - 4);
                                          }
                                          else
                                          {
                                             _loc5_ = _loc13_ & 0x40;
                                             if(_loc5_ != 0)
                                             {
                                                _loc12_ = li32(_loc7_ - 12);
                                                if(_loc17_ >= _loc12_)
                                                {
                                                   _loc13_ = _loc12_ << 1;
                                                   _loc2_ = _loc17_ + 1;
                                                   _loc8_ = _loc2_;
                                                   if(_loc2_ <= _loc13_)
                                                   {
                                                      _loc8_ = _loc13_;
                                                   }
                                                   _loc15_ = _loc8_ << 2;
                                                   _loc17_ = li32(_loc7_ - 48);
                                                   if(_loc12_ == 8)
                                                   {
                                                      _loc4_ -= 16;
                                                      si32(_loc15_,_loc4_);
                                                      wdnative.ESP = _loc4_;
                                                      wdnative.F_malloc();
                                                      _loc15_ = -1;
                                                      _loc4_ += 16;
                                                      _loc10_ = wdnative.eax;
                                                      if(_loc10_ == 0)
                                                      {
                                                         break loop0;
                                                      }
                                                      _loc5_ = _loc12_ << 2;
                                                      _loc1_ = ram;
                                                      _loc1_.position = _loc10_;
                                                      _loc1_.writeBytes(_loc1_,_loc17_,_loc5_);
                                                   }
                                                   else
                                                   {
                                                      _loc4_ -= 16;
                                                      si32(_loc15_,_loc4_ + 4);
                                                      si32(_loc17_,_loc4_);
                                                      wdnative.ESP = _loc4_;
                                                      wdnative_nternal.F_realloc();
                                                      _loc15_ = -1;
                                                      _loc4_ += 16;
                                                      _loc10_ = wdnative.eax;
                                                      if(_loc10_ == 0)
                                                      {
                                                         break loop0;
                                                      }
                                                   }
                                                   if(_loc12_ < _loc8_)
                                                   {
                                                      _loc4_ -= 16;
                                                      si32(0,_loc4_ + 4);
                                                      var _temp_369:* = _loc12_ << 2;
                                                      _loc5_ = _loc10_ + _temp_369;
                                                      si32(_loc5_,_loc4_);
                                                      if(_loc13_ <= _loc2_)
                                                      {
                                                         _loc13_ = _loc2_;
                                                      }
                                                      _loc5_ = _loc13_ - _loc12_;
                                                      _loc5_ = _loc5_ << 2;
                                                      si32(_loc5_,_loc4_ + 8);
                                                      wdnative.ESP = _loc4_;
                                                      wdnative.Fmemset();
                                                      _loc4_ += 16;
                                                   }
                                                   si32(_loc10_,_loc7_ - 48);
                                                   si32(_loc8_,_loc7_ - 12);
                                                   _loc17_ = li32(_loc7_ - 4);
                                                }
                                                _loc5_ = li32(_loc7_ - 8);
                                                if(_loc17_ > _loc5_)
                                                {
                                                   si32(_loc17_,_loc7_ - 8);
                                                }
                                                _loc5_ = _loc17_ << 2;
                                                _loc3_ = li32(_loc7_ - 48);
                                                _loc5_ = _loc3_ + _loc5_;
                                                si32(1,_loc5_);
                                                _loc17_ += 1;
                                                si32(_loc17_,_loc7_ - 4);
                                             }
                                             else
                                             {
                                                var _temp_375:* = _loc13_ & 0x2000;
                                                _loc13_ = li32(_loc7_ - 12);
                                                if(_temp_375 != 0)
                                                {
                                                   if(_loc17_ >= _loc13_)
                                                   {
                                                      _loc12_ = _loc13_ << 1;
                                                      _loc2_ = _loc17_ + 1;
                                                      _loc8_ = _loc2_;
                                                      if(_loc2_ <= _loc12_)
                                                      {
                                                         _loc8_ = _loc12_;
                                                      }
                                                      _loc15_ = _loc8_ << 2;
                                                      _loc17_ = li32(_loc7_ - 48);
                                                      if(_loc13_ == 8)
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(_loc15_,_loc4_);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative.F_malloc();
                                                         _loc15_ = -1;
                                                         _loc4_ += 16;
                                                         _loc10_ = wdnative.eax;
                                                         if(_loc10_ == 0)
                                                         {
                                                            break loop0;
                                                         }
                                                         _loc5_ = _loc13_ << 2;
                                                         _loc1_ = ram;
                                                         _loc1_.position = _loc10_;
                                                         _loc1_.writeBytes(_loc1_,_loc17_,_loc5_);
                                                      }
                                                      else
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(_loc15_,_loc4_ + 4);
                                                         si32(_loc17_,_loc4_);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative_nternal.F_realloc();
                                                         _loc15_ = -1;
                                                         _loc4_ += 16;
                                                         _loc10_ = wdnative.eax;
                                                         if(_loc10_ == 0)
                                                         {
                                                            break loop0;
                                                         }
                                                      }
                                                      if(_loc13_ < _loc8_)
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(0,_loc4_ + 4);
                                                         var _temp_380:* = _loc13_ << 2;
                                                         _loc5_ = _loc10_ + _temp_380;
                                                         si32(_loc5_,_loc4_);
                                                         if(_loc12_ <= _loc2_)
                                                         {
                                                            _loc12_ = _loc2_;
                                                         }
                                                         _loc5_ = _loc12_ - _loc13_;
                                                         _loc5_ = _loc5_ << 2;
                                                         si32(_loc5_,_loc4_ + 8);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative.Fmemset();
                                                         _loc4_ += 16;
                                                      }
                                                      si32(_loc10_,_loc7_ - 48);
                                                      si32(_loc8_,_loc7_ - 12);
                                                      _loc17_ = li32(_loc7_ - 4);
                                                   }
                                                   _loc5_ = li32(_loc7_ - 8);
                                                   if(_loc17_ > _loc5_)
                                                   {
                                                      si32(_loc17_,_loc7_ - 8);
                                                   }
                                                   _loc3_ = _loc17_ << 2;
                                                   _loc5_ = li32(_loc7_ - 48);
                                                   _loc5_ = _loc5_ + _loc3_;
                                                   si32(21,_loc5_);
                                                   _loc17_ += 1;
                                                   si32(_loc17_,_loc7_ - 4);
                                                }
                                                else
                                                {
                                                   if(_loc17_ >= _loc13_)
                                                   {
                                                      _loc12_ = _loc13_ << 1;
                                                      _loc17_ = _loc8_ = _loc17_ + 1;
                                                      if(_loc8_ <= _loc12_)
                                                      {
                                                         _loc17_ = _loc12_;
                                                      }
                                                      _loc15_ = _loc17_ << 2;
                                                      _loc2_ = li32(_loc7_ - 48);
                                                      if(_loc13_ == 8)
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(_loc15_,_loc4_);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative.F_malloc();
                                                         _loc15_ = -1;
                                                         _loc4_ += 16;
                                                         _loc10_ = wdnative.eax;
                                                         if(_loc10_ == 0)
                                                         {
                                                            break loop0;
                                                         }
                                                         _loc5_ = _loc13_ << 2;
                                                         _loc1_ = ram;
                                                         _loc1_.position = _loc10_;
                                                         _loc1_.writeBytes(_loc1_,_loc2_,_loc5_);
                                                      }
                                                      else
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(_loc15_,_loc4_ + 4);
                                                         si32(_loc2_,_loc4_);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative_nternal.F_realloc();
                                                         _loc15_ = -1;
                                                         _loc4_ += 16;
                                                         _loc10_ = wdnative.eax;
                                                         if(_loc10_ == 0)
                                                         {
                                                            break loop0;
                                                         }
                                                      }
                                                      if(_loc13_ < _loc17_)
                                                      {
                                                         _loc4_ -= 16;
                                                         si32(0,_loc4_ + 4);
                                                         var _temp_392:* = _loc13_ << 2;
                                                         _loc5_ = _loc10_ + _temp_392;
                                                         si32(_loc5_,_loc4_);
                                                         if(_loc12_ <= _loc8_)
                                                         {
                                                            _loc12_ = _loc8_;
                                                         }
                                                         _loc5_ = _loc12_ - _loc13_;
                                                         _loc5_ = _loc5_ << 2;
                                                         si32(_loc5_,_loc4_ + 8);
                                                         wdnative.ESP = _loc4_;
                                                         wdnative.Fmemset();
                                                         _loc4_ += 16;
                                                      }
                                                      si32(_loc10_,_loc7_ - 48);
                                                      si32(_loc17_,_loc7_ - 12);
                                                      _loc17_ = li32(_loc7_ - 4);
                                                   }
                                                   _loc5_ = li32(_loc7_ - 8);
                                                   if(_loc17_ > _loc5_)
                                                   {
                                                      si32(_loc17_,_loc7_ - 8);
                                                   }
                                                   _loc3_ = _loc17_ << 2;
                                                   _loc5_ = li32(_loc7_ - 48);
                                                   _loc5_ = _loc5_ + _loc3_;
                                                   si32(4,_loc5_);
                                                   _loc17_ += 1;
                                                   si32(_loc17_,_loc7_ - 4);
                                                }
                                             }
                                          }
                                       }
                                    }
                                 }
                              }
                              continue loop0;
                           }
                           if(_loc15_ == 111)
                           {
                              §§goto(addr1f7b);
                           }
                        }
                        else
                        {
                           if(_loc15_ == 112)
                           {
                              _loc12_ = li32(_loc7_ - 12);
                              if(_loc17_ >= _loc12_)
                              {
                                 _loc13_ = _loc12_ << 1;
                                 _loc2_ = _loc17_ += 1;
                                 if(_loc17_ <= _loc13_)
                                 {
                                    _loc2_ = _loc13_;
                                 }
                                 _loc15_ = _loc2_ << 2;
                                 _loc8_ = li32(_loc7_ - 48);
                                 if(_loc12_ == 8)
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative.F_malloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc10_ = wdnative.eax;
                                    if(_loc10_ == 0)
                                    {
                                       break loop0;
                                    }
                                    _loc5_ = _loc12_ << 2;
                                    _loc1_ = ram;
                                    _loc1_.position = _loc10_;
                                    _loc1_.writeBytes(_loc1_,_loc8_,_loc5_);
                                 }
                                 else
                                 {
                                    _loc4_ -= 16;
                                    si32(_loc15_,_loc4_ + 4);
                                    si32(_loc8_,_loc4_);
                                    wdnative.ESP = _loc4_;
                                    wdnative_nternal.F_realloc();
                                    _loc15_ = -1;
                                    _loc4_ += 16;
                                    _loc10_ = wdnative.eax;
                                    if(_loc10_ == 0)
                                    {
                                       break loop0;
                                    }
                                 }
                                 if(_loc12_ < _loc2_)
                                 {
                                    _loc4_ -= 16;
                                    si32(0,_loc4_ + 4);
                                    var _temp_404:* = _loc12_ << 2;
                                    _loc5_ = _loc10_ + _temp_404;
                                    si32(_loc5_,_loc4_);
                                    if(_loc13_ <= _loc17_)
                                    {
                                       _loc13_ = _loc17_;
                                    }
                                    _loc5_ = _loc13_ - _loc12_;
                                    _loc5_ = _loc5_ << 2;
                                    si32(_loc5_,_loc4_ + 8);
                                    wdnative.ESP = _loc4_;
                                    wdnative.Fmemset();
                                    _loc4_ += 16;
                                 }
                                 si32(_loc10_,_loc7_ - 48);
                                 si32(_loc2_,_loc7_ - 12);
                                 _loc17_ = li32(_loc7_ - 4);
                              }
                              _loc5_ = li32(_loc7_ - 8);
                              if(_loc17_ > _loc5_)
                              {
                                 si32(_loc17_,_loc7_ - 8);
                              }
                              _loc5_ = _loc17_ << 2;
                              _loc3_ = li32(_loc7_ - 48);
                              _loc5_ = _loc3_ + _loc5_;
                              si32(19,_loc5_);
                              _loc17_ += 1;
                              si32(_loc17_,_loc7_ - 4);
                              continue loop0;
                           }
                           if(_loc15_ == 113)
                           {
                              _loc13_ |= 32;
                              break;
                           }
                        }
                     }
                     else if(_loc15_ <= 116)
                     {
                        if(_loc15_ != 115)
                        {
                           if(_loc15_ == 116)
                           {
                              _loc13_ |= 2048;
                              break;
                           }
                        }
                        else
                        {
                           §§goto(addr23c6);
                        }
                     }
                     else
                     {
                        if(_loc15_ != 117)
                        {
                           if(_loc15_ != 120)
                           {
                              if(_loc15_ == 122)
                              {
                                 _loc13_ |= 1024;
                                 break;
                              }
                              §§goto(addr2822);
                           }
                        }
                        §§goto(addr2583);
                     }
                     §§goto(addr2822);
                  }
               }
               _loc12_ = li32(_loc7_ - 12);
               if(_loc17_ >= _loc12_)
               {
                  _loc2_ = _loc12_ << 1;
                  _loc17_ = _loc8_ = _loc17_ + 1;
                  if(_loc8_ <= _loc2_)
                  {
                     _loc17_ = _loc2_;
                  }
                  _loc15_ = _loc17_ << 2;
                  _loc10_ = li32(_loc7_ - 48);
                  if(_loc12_ == 8)
                  {
                     _loc4_ -= 16;
                     si32(_loc15_,_loc4_);
                     wdnative.ESP = _loc4_;
                     wdnative.F_malloc();
                     _loc15_ = -1;
                     _loc4_ += 16;
                     _loc9_ = wdnative.eax;
                     if(_loc9_ == 0)
                     {
                        break;
                     }
                     _loc5_ = _loc12_ << 2;
                     _loc1_ = ram;
                     _loc1_.position = _loc9_;
                     _loc1_.writeBytes(_loc1_,_loc10_,_loc5_);
                  }
                  else
                  {
                     _loc4_ -= 16;
                     si32(_loc15_,_loc4_ + 4);
                     si32(_loc10_,_loc4_);
                     wdnative.ESP = _loc4_;
                     wdnative_nternal.F_realloc();
                     _loc15_ = -1;
                     _loc4_ += 16;
                     _loc9_ = wdnative.eax;
                     if(_loc9_ == 0)
                     {
                        break;
                     }
                  }
                  if(_loc12_ < _loc17_)
                  {
                     _loc4_ -= 16;
                     si32(0,_loc4_ + 4);
                     var _temp_415:* = _loc12_ << 2;
                     _loc5_ = _loc9_ + _temp_415;
                     si32(_loc5_,_loc4_);
                     if(_loc2_ <= _loc8_)
                     {
                        _loc2_ = _loc8_;
                     }
                     _loc5_ = _loc2_ - _loc12_;
                     _loc5_ = _loc5_ << 2;
                     si32(_loc5_,_loc4_ + 8);
                     wdnative.ESP = _loc4_;
                     wdnative.Fmemset();
                     _loc4_ += 16;
                  }
                  si32(_loc9_,_loc7_ - 48);
                  si32(_loc17_,_loc7_ - 12);
                  _loc17_ = li32(_loc7_ - 4);
               }
               _loc5_ = li32(_loc7_ - 8);
               if(_loc17_ > _loc5_)
               {
                  si32(_loc17_,_loc7_ - 8);
               }
               _loc5_ = _loc13_ >>> 3;
               _loc5_ = _loc5_ & 1;
               _loc5_ = _loc5_ | 0x16;
               _loc3_ = _loc17_ << 2;
               _loc6_ = li32(_loc7_ - 48);
               _loc3_ = _loc6_ + _loc3_;
               si32(_loc5_,_loc3_);
               _loc17_ += 1;
               si32(_loc17_,_loc7_ - 4);
            }
            else
            {
               _loc18_ += 1;
            }
            continue;
         }
         §§goto(addr282b);
      }
      _loc19_ = li32(_loc7_ - 48);
      if(_loc19_ != _loc21_)
      {
         if(_loc19_ != 0)
         {
            _loc4_ -= 16;
            si32(_loc19_,_loc4_);
            wdnative.ESP = _loc4_;
            wdnative_nternal.F_idalloc();
            _loc4_ += 16;
         }
      }
      _loc21_ = 1;
      if(_loc15_ == 0)
      {
         var _temp_426:* = li32(_loc20_);
         _loc21_ = 1;
         if(_temp_426 != 0)
         {
            _loc21_ = 0;
         }
      }
      wdnative.eax = _loc21_;
      wdnative.ESP = _loc4_ = _loc7_;
   }
}

