package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_type() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      loop4:
      while(true)
      {
         _loc12_ = li32(_loc1_ + 12);
         _loc11_ = li8(_loc12_);
         if(_loc11_ != 75)
         {
            if(_loc11_ != 86)
            {
               if(_loc11_ != 114)
               {
                  var _loc8_:int = _loc11_ << 24;
                  _loc10_ = _loc8_ >> 24;
                  _loc9_ = 0;
                  while(true)
                  {
                     if(_loc10_ <= 82)
                     {
                        while(true)
                        {
                           if(_loc10_ <= 70)
                           {
                              if(_loc10_ > 66)
                              {
                                 if(_loc10_ != 67)
                                 {
                                    if(_loc10_ != 70)
                                    {
                                       break loop4;
                                    }
                                    _loc9_ = _loc12_ + 1;
                                    si32(_loc9_,_loc1_ + 12);
                                    _loc10_ = 0;
                                    if(_loc11_ == 70)
                                    {
                                       _loc8_ = li8(_loc9_);
                                       if(_loc8_ == 89)
                                       {
                                          _loc8_ = _loc12_ + 2;
                                          si32(_loc8_,_loc1_ + 12);
                                       }
                                       _loc2_ -= 16;
                                       si32(1,_loc2_ + 4);
                                       si32(_loc1_,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F_d_bare_function_type();
                                       _loc2_ += 16;
                                       _loc10_ = wdnative.eax;
                                       var _loc6_:int = li32(_loc1_ + 12);
                                       _loc8_ = li8(_loc6_);
                                       _loc6_ += 1;
                                       si32(_loc6_,_loc1_ + 12);
                                       if(_loc8_ != 69)
                                       {
                                          _loc10_ = 0;
                                       }
                                    }
                                    si32(_loc10_,_loc3_ - 8);
                                    break;
                                 }
                                 _loc8_ = _loc12_ + 1;
                                 si32(_loc8_,_loc1_ + 12);
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_d_type();
                                 _loc10_ = 0;
                                 _loc2_ += 16;
                                 _loc12_ = wdnative.eax;
                                 if(_loc12_ != 0)
                                 {
                                    _loc7_ = li32(_loc1_ + 20);
                                    var _temp_33:* = li32(_loc1_ + 24);
                                    _loc10_ = 0;
                                    if(_loc7_ < _temp_33)
                                    {
                                       _loc9_ = li32(_loc1_ + 16);
                                       _loc8_ = _loc7_ + 1;
                                       si32(_loc8_,_loc1_ + 20);
                                       _loc11_ = _loc7_ * 12;
                                       _loc7_ = _loc9_ + _loc11_;
                                       _loc10_ = 0;
                                       if(_loc7_ != 0)
                                       {
                                          _loc8_ = _loc9_ + _loc11_;
                                          si32(31,_loc8_);
                                          si32(_loc12_,_loc8_ + 4);
                                          si32(0,_loc8_ + 8);
                                          _loc10_ = _loc7_;
                                       }
                                    }
                                 }
                                 si32(_loc10_,_loc3_ - 8);
                                 break;
                              }
                              _loc8_ = _loc10_ + -48;
                              if((uint(_loc8_)) >= 10)
                              {
                                 if(_loc10_ != 65)
                                 {
                                    break loop4;
                                 }
                                 _loc7_ = _loc12_ + 1;
                                 si32(_loc7_,_loc1_ + 12);
                                 _loc10_ = 0;
                                 if(_loc11_ == 65)
                                 {
                                    _loc10_ = li8(_loc7_);
                                    _loc9_ = 0;
                                    while(true)
                                    {
                                       if(_loc10_ != 95)
                                       {
                                          _loc8_ = _loc10_ + -48;
                                          _loc8_ = _loc8_ & 0xFF;
                                          if((uint(_loc8_)) <= 9)
                                          {
                                             _loc10_ = _loc12_ + 2;
                                             _loc11_ = 0;
                                             do
                                             {
                                                si32(_loc10_,_loc1_ + 12);
                                                _loc11_ += -1;
                                                _loc12_ = _loc10_ + 1;
                                                _loc8_ = li8(_loc10_);
                                                _loc8_ = _loc8_ + -48;
                                                _loc8_ = _loc8_ & 0xFF;
                                                _loc10_ = _loc12_;
                                             }
                                             while(uint(_loc8_) < 10);
                                             _loc9_ = li32(_loc1_ + 20);
                                             var _temp_11:* = li32(_loc1_ + 24);
                                             _loc10_ = 0;
                                             if(_loc9_ >= _temp_11)
                                             {
                                                break;
                                             }
                                             var _temp_13:* = li32(_loc1_ + 16);
                                             si32(_loc6_ = _loc9_ + 1,_loc1_ + 20);
                                             _loc9_ = _temp_13 + int(_loc9_ * 12);
                                             _loc10_ = 0;
                                             if(_loc9_ == 0)
                                             {
                                                break;
                                             }
                                             if(_loc7_ == 0)
                                             {
                                                break;
                                             }
                                             if(_loc11_ == 0)
                                             {
                                                break;
                                             }
                                             _loc8_ = _loc12_ + -1;
                                             var _temp_15:* = int(_loc8_ - _loc7_);
                                             si32(_loc10_ = 0,_loc9_);
                                             si32(_loc7_,_loc9_ + 4);
                                             si32(_temp_15,_loc9_ + 8);
                                             if(_loc9_ == 0)
                                             {
                                                break;
                                             }
                                          }
                                          else
                                          {
                                             _loc2_ -= 16;
                                             si32(_loc1_,_loc2_);
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_d_expression();
                                             _loc10_ = 0;
                                             _loc2_ += 16;
                                             _loc9_ = wdnative.eax;
                                             if(_loc9_ == 0)
                                             {
                                                break;
                                             }
                                          }
                                       }
                                       _loc6_ = li32(_loc1_ + 12);
                                       _loc8_ = li8(_loc6_);
                                       _loc6_ += 1;
                                       si32(_loc6_,_loc1_ + 12);
                                       _loc10_ = 0;
                                       if(_loc8_ == 95)
                                       {
                                          _loc2_ -= 16;
                                          si32(_loc1_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_d_type();
                                          _loc10_ = 0;
                                          _loc2_ += 16;
                                          _loc7_ = wdnative.eax;
                                          if(_loc7_ != 0)
                                          {
                                             _loc11_ = li32(_loc1_ + 20);
                                             var _temp_22:* = li32(_loc1_ + 24);
                                             _loc10_ = 0;
                                             if(_loc11_ < _temp_22)
                                             {
                                                _loc12_ = li32(_loc1_ + 16);
                                                _loc8_ = _loc11_ + 1;
                                                si32(_loc8_,_loc1_ + 20);
                                                _loc5_ = _loc11_ * 12;
                                                _loc11_ = _loc12_ + _loc5_;
                                                _loc10_ = 0;
                                                if(_loc11_ != 0)
                                                {
                                                   _loc8_ = _loc12_ + _loc5_;
                                                   si32(36,_loc8_);
                                                   si32(_loc9_,_loc8_ + 4);
                                                   si32(_loc7_,_loc8_ + 8);
                                                   _loc10_ = _loc11_;
                                                }
                                             }
                                          }
                                       }
                                       break;
                                    }
                                 }
                                 si32(_loc10_,_loc3_ - 8);
                                 break;
                              }
                           }
                           else
                           {
                              if(_loc10_ <= 77)
                              {
                                 if(_loc10_ != 71)
                                 {
                                    if(_loc10_ != 77)
                                    {
                                       break loop4;
                                    }
                                    _loc8_ = _loc12_ + 1;
                                    si32(_loc8_,_loc1_ + 12);
                                    _loc10_ = 0;
                                    if(_loc11_ == 77)
                                    {
                                       _loc2_ -= 16;
                                       si32(_loc1_,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F_d_type();
                                       _loc12_ = _loc3_ - 4;
                                       _loc2_ += 16;
                                       _loc9_ = wdnative.eax;
                                       _loc10_ = 0;
                                       while(true)
                                       {
                                          _loc11_ = li32(_loc1_ + 12);
                                          _loc7_ = li8(_loc11_);
                                          if(_loc7_ != 75)
                                          {
                                             if(_loc7_ != 86)
                                             {
                                                if(_loc7_ != 114)
                                                {
                                                   if(_loc12_ != 0)
                                                   {
                                                      _loc2_ -= 16;
                                                      si32(_loc1_,_loc2_);
                                                      wdnative.ESP = _loc2_;
                                                      wdnative_nternal.F_d_type();
                                                      _loc2_ += 16;
                                                      _loc10_ = wdnative.eax;
                                                      si32(_loc10_,_loc12_);
                                                      _loc8_ = _loc3_ - 4;
                                                      if(_loc8_ != _loc12_)
                                                      {
                                                         _loc8_ = li32(_loc10_);
                                                         if(_loc8_ != 35)
                                                         {
                                                            _loc10_ = 0;
                                                            _loc7_ = li32(_loc3_ - 4);
                                                            if(_loc7_ == 0)
                                                            {
                                                               break;
                                                            }
                                                            _loc12_ = li32(_loc1_ + 32);
                                                            var _temp_44:* = li32(_loc1_ + 36);
                                                            _loc10_ = 0;
                                                            if(_loc12_ >= _temp_44)
                                                            {
                                                               break;
                                                            }
                                                            var _temp_46:* = _loc12_ << 2;
                                                            var _temp_47:* = int((_loc6_ = li32(_loc1_ + 28)) + _temp_46);
                                                            si32(_loc7_,_temp_47);
                                                            _loc8_ = li32(_loc1_ + 32);
                                                            _loc8_ = _loc8_ + 1;
                                                            si32(_loc8_,_loc1_ + 32);
                                                         }
                                                      }
                                                      _loc10_ = 0;
                                                      if(_loc9_ != 0)
                                                      {
                                                         _loc7_ = li32(_loc3_ - 4);
                                                         if(_loc7_ != 0)
                                                         {
                                                            _loc11_ = li32(_loc1_ + 20);
                                                            var _temp_51:* = li32(_loc1_ + 24);
                                                            _loc10_ = 0;
                                                            if(_loc11_ < _temp_51)
                                                            {
                                                               _loc12_ = li32(_loc1_ + 16);
                                                               _loc8_ = _loc11_ + 1;
                                                               si32(_loc8_,_loc1_ + 20);
                                                               _loc5_ = _loc11_ * 12;
                                                               _loc11_ = _loc12_ + _loc5_;
                                                               _loc10_ = 0;
                                                               if(_loc11_ != 0)
                                                               {
                                                                  _loc8_ = _loc12_ + _loc5_;
                                                                  si32(37,_loc8_);
                                                                  si32(_loc9_,_loc8_ + 4);
                                                                  si32(_loc7_,_loc8_ + 8);
                                                                  _loc10_ = _loc11_;
                                                               }
                                                            }
                                                         }
                                                      }
                                                   }
                                                   break;
                                                }
                                             }
                                          }
                                          _loc8_ = _loc11_ + 1;
                                          si32(_loc8_,_loc1_ + 12);
                                          if(_loc7_ != 86)
                                          {
                                             if(_loc7_ == 114)
                                             {
                                                _loc8_ = li32(_loc1_ + 48);
                                                _loc8_ = _loc8_ + 9;
                                                si32(_loc8_,_loc1_ + 48);
                                                _loc7_ = 25;
                                             }
                                             else
                                             {
                                                _loc8_ = li32(_loc1_ + 48);
                                                _loc8_ = _loc8_ + 6;
                                                si32(_loc8_,_loc1_ + 48);
                                                _loc7_ = 27;
                                             }
                                          }
                                          else
                                          {
                                             _loc8_ = li32(_loc1_ + 48);
                                             _loc8_ = _loc8_ + 9;
                                             si32(_loc8_,_loc1_ + 48);
                                             _loc7_ = 26;
                                          }
                                          _loc11_ = li32(_loc1_ + 20);
                                          _loc8_ = li32(_loc1_ + 24);
                                          if(_loc11_ < _loc8_)
                                          {
                                             var _temp_61:* = li32(_loc1_ + 16);
                                             si32(_loc6_ = _loc11_ + 1,_loc1_ + 20);
                                             _loc11_ = _temp_61 + int(_loc11_ * 12);
                                             if(_loc11_ != 0)
                                             {
                                                continue;
                                             }
                                          }
                                          _loc10_ = 0;
                                          si32(_loc10_,_loc12_);
                                          break;
                                          si32(_loc7_,_loc11_);
                                          si32(_loc10_,_loc11_ + 4);
                                          si32(_loc10_,_loc11_ + 8);
                                          si32(_loc11_,_loc12_);
                                          _loc12_ = _loc11_ + 4;
                                       }
                                    }
                                    si32(_loc10_,_loc3_ - 8);
                                    break;
                                 }
                                 _loc8_ = _loc12_ + 1;
                                 si32(_loc8_,_loc1_ + 12);
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_d_type();
                                 _loc10_ = 0;
                                 _loc2_ += 16;
                                 _loc12_ = wdnative.eax;
                                 if(_loc12_ != 0)
                                 {
                                    _loc7_ = li32(_loc1_ + 20);
                                    var _temp_66:* = li32(_loc1_ + 24);
                                    _loc10_ = 0;
                                    if(_loc7_ < _temp_66)
                                    {
                                       _loc9_ = li32(_loc1_ + 16);
                                       _loc8_ = _loc7_ + 1;
                                       si32(_loc8_,_loc1_ + 20);
                                       _loc11_ = _loc7_ * 12;
                                       _loc7_ = _loc9_ + _loc11_;
                                       _loc10_ = 0;
                                       if(_loc7_ != 0)
                                       {
                                          _loc8_ = _loc9_ + _loc11_;
                                          si32(32,_loc8_);
                                          si32(_loc12_,_loc8_ + 4);
                                          si32(0,_loc8_ + 8);
                                          _loc10_ = _loc7_;
                                       }
                                    }
                                 }
                                 si32(_loc10_,_loc3_ - 8);
                                 break;
                              }
                              if(_loc10_ != 78)
                              {
                                 if(_loc10_ != 80)
                                 {
                                    if(_loc10_ != 82)
                                    {
                                       break loop4;
                                    }
                                    _loc8_ = _loc12_ + 1;
                                    si32(_loc8_,_loc1_ + 12);
                                    _loc2_ -= 16;
                                    si32(_loc1_,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F_d_type();
                                    _loc10_ = 0;
                                    _loc2_ += 16;
                                    _loc12_ = wdnative.eax;
                                    if(_loc12_ != 0)
                                    {
                                       _loc7_ = li32(_loc1_ + 20);
                                       var _temp_71:* = li32(_loc1_ + 24);
                                       _loc10_ = 0;
                                       if(_loc7_ < _temp_71)
                                       {
                                          _loc9_ = li32(_loc1_ + 16);
                                          _loc8_ = _loc7_ + 1;
                                          si32(_loc8_,_loc1_ + 20);
                                          _loc7_ *= 12;
                                          _loc11_ = _loc9_ + _loc7_;
                                          _loc10_ = 0;
                                          if(_loc11_ != 0)
                                          {
                                             _loc8_ = _loc9_ + _loc7_;
                                             si32(30,_loc8_);
                                             si32(_loc12_,_loc8_ + 4);
                                             si32(0,_loc8_ + 8);
                                             _loc10_ = _loc11_;
                                          }
                                       }
                                    }
                                    si32(_loc10_,_loc3_ - 8);
                                    break;
                                 }
                                 _loc8_ = _loc12_ + 1;
                                 si32(_loc8_,_loc1_ + 12);
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_d_type();
                                 _loc10_ = 0;
                                 _loc2_ += 16;
                                 _loc12_ = wdnative.eax;
                                 if(_loc12_ != 0)
                                 {
                                    _loc7_ = li32(_loc1_ + 20);
                                    var _temp_76:* = li32(_loc1_ + 24);
                                    _loc10_ = 0;
                                    if(_loc7_ < _temp_76)
                                    {
                                       _loc9_ = li32(_loc1_ + 16);
                                       _loc8_ = _loc7_ + 1;
                                       si32(_loc8_,_loc1_ + 20);
                                       _loc11_ = _loc7_ * 12;
                                       _loc7_ = _loc9_ + _loc11_;
                                       _loc10_ = 0;
                                       if(_loc7_ != 0)
                                       {
                                          _loc8_ = _loc9_ + _loc11_;
                                          si32(29,_loc8_);
                                          si32(_loc12_,_loc8_ + 4);
                                          si32(0,_loc8_ + 8);
                                          _loc10_ = _loc7_;
                                       }
                                    }
                                 }
                                 si32(_loc10_,_loc3_ - 8);
                                 break;
                              }
                           }
                           addr052b:
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_name();
                           _loc2_ += 16;
                           _loc10_ = wdnative.eax;
                           si32(_loc10_,_loc3_ - 8);
                           break;
                        }
                     }
                     else if(_loc10_ <= 96)
                     {
                        if(_loc10_ <= 84)
                        {
                           if(_loc10_ != 83)
                           {
                              if(_loc10_ != 84)
                              {
                                 break loop4;
                              }
                              _loc9_ = _loc12_ + 1;
                              si32(_loc9_,_loc1_ + 12);
                              _loc10_ = 0;
                              if(_loc11_ == 84)
                              {
                                 _loc7_ = li8(_loc9_);
                                 _loc10_ = 0;
                                 loop8:
                                 while(true)
                                 {
                                    while(true)
                                    {
                                       if(_loc7_ != 110)
                                       {
                                          _loc11_ = _loc10_;
                                          if(_loc7_ == 95)
                                          {
                                             _loc9_ = _loc12_ + 2;
                                             si32(_loc9_,_loc1_ + 12);
                                             _loc12_ = 0;
                                             break;
                                          }
                                       }
                                       else
                                       {
                                          _loc9_ = _loc12_ + 2;
                                          si32(_loc9_,_loc1_ + 12);
                                          _loc7_ = li8(_loc12_ + 2);
                                          _loc11_ = 1;
                                       }
                                       _loc8_ = _loc7_ + -48;
                                       _loc8_ = _loc8_ & 0xFF;
                                       _loc12_ = _loc10_;
                                       if(uint(_loc8_) <= 9)
                                       {
                                          do
                                          {
                                             _loc8_ = _loc9_ + 1;
                                             si32(_loc8_,_loc1_ + 12);
                                             _loc6_ = _loc12_ * 10;
                                             var _loc4_:int = _loc7_ << 24;
                                             _loc4_ = _loc4_ >> 24;
                                             _loc6_ += _loc4_;
                                             _loc12_ = _loc6_ + -48;
                                             _loc7_ = li8(_loc9_ + 1);
                                             _loc6_ = _loc7_ + -48;
                                             _loc6_ = _loc6_ & 0xFF;
                                             _loc9_ = _loc8_;
                                          }
                                          while(uint(_loc6_) < 10);
                                       }
                                       if(_loc11_ != _loc10_)
                                       {
                                          _loc12_ = 0 - _loc12_;
                                       }
                                       if(_loc12_ >= 0)
                                       {
                                          _loc9_ += 1;
                                          si32(_loc9_,_loc1_ + 12);
                                          _loc12_ += 1;
                                          var _temp_90:* = _loc7_ & 0xFF;
                                          _loc10_ = 0;
                                          if(_temp_90 == 95)
                                          {
                                             break;
                                          }
                                       }
                                       break loop8;
                                    }
                                    _loc8_ = li32(_loc1_ + 40);
                                    _loc8_ = _loc8_ + 1;
                                    si32(_loc8_,_loc1_ + 40);
                                    _loc11_ = li32(_loc1_ + 20);
                                    _loc8_ = li32(_loc1_ + 24);
                                    _loc10_ = 0;
                                    if(_loc11_ < _loc8_)
                                    {
                                       _loc7_ = li32(_loc1_ + 16);
                                       _loc8_ = _loc11_ + 1;
                                       si32(_loc8_,_loc1_ + 20);
                                       _loc11_ *= 12;
                                       _loc5_ = _loc7_ + _loc11_;
                                       _loc10_ = 0;
                                       if(_loc5_ != 0)
                                       {
                                          _loc8_ = _loc7_ + _loc11_;
                                          si32(5,_loc8_);
                                          si32(_loc12_,_loc8_ + 4);
                                          _loc9_ = li32(_loc1_ + 12);
                                          _loc10_ = _loc5_;
                                       }
                                    }
                                    break;
                                 }
                              }
                              break loop8;
                           }
                           _loc10_ = li8(_loc12_ + 1);
                           _loc8_ = _loc10_ + -48;
                           _loc8_ = _loc8_ & 0xFF;
                           if((uint(_loc8_)) >= 10)
                           {
                              _loc8_ = _loc10_ & 0xFF;
                              if(_loc8_ != 95)
                              {
                                 _loc8_ = _loc10_ + -65;
                                 _loc8_ = _loc8_ & 0xFF;
                                 if((uint(_loc8_)) > 25)
                                 {
                                    _loc2_ -= 16;
                                    si32(_loc1_,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F_d_name();
                                    _loc2_ += 16;
                                    _loc10_ = wdnative.eax;
                                    si32(_loc10_,_loc3_ - 8);
                                    _loc9_ = 0;
                                    if(_loc10_ != 0)
                                    {
                                       var _temp_102:* = li32(_loc10_);
                                       _loc9_ = _loc10_;
                                       if(_temp_102 != 21)
                                       {
                                          break;
                                       }
                                    }
                                    break loop4;
                                 }
                              }
                           }
                           _loc2_ -= 16;
                           _loc10_ = 0;
                           si32(_loc10_,_loc2_ + 4);
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_substitution();
                           _loc2_ += 16;
                           _loc9_ = wdnative.eax;
                           si32(_loc9_,_loc3_ - 8);
                           _loc8_ = li32(_loc1_ + 12);
                           _loc8_ = li8(_loc8_);
                           if(_loc8_ != 73)
                           {
                              break loop4;
                           }
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_template_args();
                           _loc2_ += 16;
                           _loc12_ = wdnative.eax;
                           if(_loc9_ != 0)
                           {
                              if(_loc12_ != 0)
                              {
                                 _loc11_ = li32(_loc1_ + 20);
                                 var _temp_108:* = li32(_loc1_ + 24);
                                 _loc10_ = 0;
                                 if(_loc11_ < _temp_108)
                                 {
                                    _loc7_ = li32(_loc1_ + 16);
                                    _loc8_ = _loc11_ + 1;
                                    si32(_loc8_,_loc1_ + 20);
                                    _loc11_ *= 12;
                                    _loc5_ = _loc7_ + _loc11_;
                                    _loc10_ = 0;
                                    if(_loc5_ != 0)
                                    {
                                       _loc8_ = _loc7_ + _loc11_;
                                       si32(4,_loc8_);
                                       si32(_loc9_,_loc8_ + 4);
                                       si32(_loc12_,_loc8_ + 8);
                                       _loc10_ = _loc5_;
                                    }
                                 }
                              }
                           }
                           si32(_loc10_,_loc3_ - 8);
                        }
                        else if(_loc10_ != 85)
                        {
                           if(_loc10_ != 90)
                           {
                              break loop4;
                           }
                           §§goto(addr052b);
                        }
                        else
                        {
                           _loc8_ = _loc12_ + 1;
                           si32(_loc8_,_loc1_ + 12);
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_source_name();
                           _loc2_ += 16;
                           _loc8_ = wdnative.eax;
                           si32(_loc8_,_loc3_ - 8);
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_type();
                           _loc10_ = 0;
                           _loc2_ += 16;
                           _loc7_ = wdnative.eax;
                           if(_loc7_ != 0)
                           {
                              _loc9_ = li32(_loc3_ - 8);
                              if(_loc9_ != 0)
                              {
                                 _loc11_ = li32(_loc1_ + 20);
                                 var _temp_116:* = li32(_loc1_ + 24);
                                 _loc10_ = 0;
                                 if(_loc11_ < _temp_116)
                                 {
                                    _loc12_ = li32(_loc1_ + 16);
                                    _loc8_ = _loc11_ + 1;
                                    si32(_loc8_,_loc1_ + 20);
                                    _loc11_ *= 12;
                                    _loc5_ = _loc12_ + _loc11_;
                                    _loc10_ = 0;
                                    if(_loc5_ != 0)
                                    {
                                       _loc8_ = _loc12_ + _loc11_;
                                       si32(28,_loc8_);
                                       si32(_loc7_,_loc8_ + 4);
                                       si32(_loc9_,_loc8_ + 8);
                                       _loc10_ = _loc5_;
                                    }
                                 }
                              }
                           }
                           si32(_loc10_,_loc3_ - 8);
                        }
                     }
                     else
                     {
                        _loc7_ = _loc10_ + -97;
                        if((uint(_loc7_)) > 25)
                        {
                           break loop4;
                        }
                        _loc8_ = 1 << _loc7_;
                        _loc8_ = _loc8_ & 0x03EC7BFF;
                        if(_loc8_ != 0)
                        {
                           _loc8_ = _loc10_ * 20;
                           _loc8_ = _loc8_ + wdnative_nternal._cplus_demangle_builtin_types;
                           _loc10_ = _loc8_ + -1940;
                           _loc9_ = 0;
                           if(_loc10_ != 0)
                           {
                              _loc11_ = li32(_loc1_ + 20);
                              var _temp_128:* = li32(_loc1_ + 24);
                              _loc9_ = 0;
                              if(_loc11_ < _temp_128)
                              {
                                 _loc7_ = li32(_loc1_ + 16);
                                 _loc8_ = _loc11_ + 1;
                                 si32(_loc8_,_loc1_ + 20);
                                 _loc5_ = _loc11_ * 12;
                                 _loc11_ = _loc7_ + _loc5_;
                                 _loc9_ = 0;
                                 if(_loc11_ != 0)
                                 {
                                    _loc8_ = _loc7_ + _loc5_;
                                    si32(33,_loc8_);
                                    si32(_loc10_,_loc8_ + 4);
                                    _loc12_ = li32(_loc1_ + 12);
                                    _loc9_ = _loc11_;
                                 }
                              }
                           }
                           si32(_loc9_,_loc3_ - 8);
                           _loc8_ = li32(_loc1_ + 48);
                           _loc6_ = li32(_loc9_ + 4);
                           _loc6_ = li32(_loc6_ + 4);
                           _loc8_ = _loc6_ + _loc8_;
                           si32(_loc8_,_loc1_ + 48);
                           _loc8_ = _loc12_ + 1;
                           si32(_loc8_,_loc1_ + 12);
                           break loop4;
                        }
                        if(_loc7_ != 20)
                        {
                           break loop4;
                        }
                        _loc8_ = _loc12_ + 1;
                        si32(_loc8_,_loc1_ + 12);
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_d_source_name();
                        _loc10_ = 0;
                        _loc2_ += 16;
                        _loc9_ = wdnative.eax;
                        if(_loc9_ != 0)
                        {
                           _loc7_ = li32(_loc1_ + 20);
                           var _temp_124:* = li32(_loc1_ + 24);
                           _loc10_ = 0;
                           if(_loc7_ < _temp_124)
                           {
                              _loc12_ = li32(_loc1_ + 16);
                              _loc8_ = _loc7_ + 1;
                              si32(_loc8_,_loc1_ + 20);
                              _loc7_ *= 12;
                              _loc11_ = _loc12_ + _loc7_;
                              _loc10_ = 0;
                              if(_loc11_ != 0)
                              {
                                 _loc8_ = _loc12_ + _loc7_;
                                 si32(34,_loc8_);
                                 si32(_loc9_,_loc8_ + 4);
                                 si32(0,_loc8_ + 8);
                                 _loc10_ = _loc11_;
                              }
                           }
                        }
                        si32(_loc10_,_loc3_ - 8);
                     }
                     _loc9_ = 0;
                     if(_loc10_ != 0)
                     {
                        break;
                     }
                     break loop4;
                  }
                  _loc12_ = li32(_loc1_ + 32);
                  _loc8_ = li32(_loc1_ + 36);
                  _loc9_ = 0;
                  if(_loc12_ < _loc8_)
                  {
                     var _temp_135:* = _loc12_ << 2;
                     var _temp_136:* = int((_loc8_ = li32(_loc1_ + 28)) + _temp_135);
                     si32(_loc10_,_temp_136);
                     _loc8_ = li32(_loc1_ + 32);
                     _loc8_ = _loc8_ + 1;
                     si32(_loc8_,_loc1_ + 32);
                     _loc9_ = li32(_loc3_ - 8);
                  }
                  break;
               }
            }
         }
         _loc10_ = _loc3_ - 8;
         _loc9_ = 0;
         while(true)
         {
            _loc7_ = _loc11_ & 0xFF;
            if(_loc7_ != 75)
            {
               if(_loc7_ != 86)
               {
                  if(_loc7_ != 114)
                  {
                     if(_loc10_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_d_type();
                        _loc2_ += 16;
                        _loc8_ = wdnative.eax;
                        si32(_loc8_,_loc10_);
                        _loc9_ = 0;
                        _loc12_ = li32(_loc3_ - 8);
                        if(_loc12_ != 0)
                        {
                           _loc10_ = li32(_loc1_ + 32);
                           var _temp_144:* = li32(_loc1_ + 36);
                           _loc9_ = 0;
                           if(_loc10_ < _temp_144)
                           {
                              var _temp_146:* = _loc10_ << 2;
                              var _temp_147:* = int((_loc8_ = li32(_loc1_ + 28)) + _temp_146);
                              si32(_loc12_,_temp_147);
                              _loc8_ = li32(_loc1_ + 32);
                              _loc8_ = _loc8_ + 1;
                              si32(_loc8_,_loc1_ + 32);
                              _loc9_ = li32(_loc3_ - 8);
                           }
                        }
                     }
                     break loop4;
                  }
               }
            }
            _loc8_ = _loc12_ + 1;
            si32(_loc8_,_loc1_ + 12);
            if(_loc7_ != 86)
            {
               if(_loc7_ == 114)
               {
                  _loc8_ = li32(_loc1_ + 48);
                  _loc8_ = _loc8_ + 9;
                  si32(_loc8_,_loc1_ + 48);
                  _loc12_ = 22;
               }
               else
               {
                  _loc8_ = li32(_loc1_ + 48);
                  _loc8_ = _loc8_ + 6;
                  si32(_loc8_,_loc1_ + 48);
                  _loc12_ = 24;
               }
            }
            else
            {
               _loc8_ = li32(_loc1_ + 48);
               _loc8_ = _loc8_ + 9;
               si32(_loc8_,_loc1_ + 48);
               _loc12_ = 23;
            }
            _loc7_ = li32(_loc1_ + 20);
            _loc8_ = li32(_loc1_ + 24);
            if(_loc7_ < _loc8_)
            {
               var _temp_158:* = li32(_loc1_ + 16);
               si32(_loc6_ = _loc7_ + 1,_loc1_ + 20);
               _loc7_ = _temp_158 + int(_loc7_ * 12);
               if(_loc7_ != 0)
               {
                  continue;
               }
            }
            _loc9_ = 0;
            si32(_loc9_,_loc10_);
            break loop4;
            si32(_loc12_,_loc7_);
            si32(_loc9_,_loc7_ + 4);
            si32(_loc9_,_loc7_ + 8);
            si32(_loc7_,_loc10_);
            _loc10_ = _loc7_ + 4;
            _loc12_ = li32(_loc1_ + 12);
            _loc11_ = li8(_loc12_);
         }
         break;
      }
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

