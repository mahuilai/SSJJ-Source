package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_encoding() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      while(true)
      {
         _loc12_ = li32(_loc1_ + 12);
         _loc11_ = li8(_loc12_);
         if(_loc11_ != 71)
         {
            if(_loc11_ != 84)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_name();
               _loc2_ += 16;
               _loc12_ = wdnative.eax;
               if(_loc12_ != 0)
               {
                  var _loc9_:int = li32(_loc3_ + 4);
                  if(_loc9_ != 0)
                  {
                     _loc9_ = li8(_loc1_ + 8);
                     _loc9_ = _loc9_ & 1;
                     if(_loc9_ == 0)
                     {
                        _loc1_ = li32(_loc12_);
                        var _temp_9:* = int(_loc1_ + -25);
                        _loc11_ = _loc12_;
                        if(uint(_temp_9) <= 2)
                        {
                           do
                           {
                              _loc11_ = li32(_loc11_ + 4);
                              _loc1_ = li32(_loc11_);
                           }
                           while(_loc9_ = _loc1_ + -25, (uint(_loc9_)) < 3);
                        }
                        if(_loc1_ == 2)
                        {
                           _loc1_ = li32(_loc11_ + 8);
                           _loc9_ = li32(_loc1_);
                           _loc9_ = _loc9_ + -25;
                           if((uint(_loc9_)) <= 2)
                           {
                              do
                              {
                                 _loc1_ = li32(_loc1_ + 4);
                              }
                              while(_loc9_ = li32(_loc1_), _loc9_ = _loc9_ + -25, (uint(_loc9_)) < 3);
                           }
                           si32(_loc1_,_loc11_ + 8);
                        }
                        break;
                     }
                  }
               }
               _loc9_ = li32(_loc1_ + 12);
               _loc8_ = li8(_loc9_);
               _loc11_ = _loc12_;
               if(_loc8_ != 0)
               {
                  _loc10_ = _loc12_;
                  _loc11_ = _loc12_;
                  if(_loc8_ != 69)
                  {
                     while(true)
                     {
                        _loc8_ = _loc11_ = 0;
                        if(_loc10_ == 0)
                        {
                           break;
                        }
                        _loc7_ = li32(_loc10_);
                        _loc9_ = _loc7_ + -25;
                        if((uint(_loc9_)) >= 3)
                        {
                           _loc8_ = 0;
                           if(_loc7_ == 4)
                           {
                              _loc8_ = _loc10_ + 4;
                              while(true)
                              {
                                 _loc7_ = li32(_loc8_);
                                 if(_loc7_ != 0)
                                 {
                                    _loc10_ = li32(_loc7_);
                                    _loc8_ = 0;
                                    if(_loc10_ == 42)
                                    {
                                       break;
                                    }
                                    _loc9_ = _loc10_ + -6;
                                    if((uint(_loc9_)) < 2)
                                    {
                                       break;
                                    }
                                    _loc9_ = _loc10_ + -1;
                                    if((uint(_loc9_)) <= 1)
                                    {
                                       continue;
                                    }
                                 }
                                 _loc8_ = 1;
                                 break;
                                 _loc8_ = _loc7_ + 8;
                              }
                           }
                           break;
                        }
                        _loc10_ = li32(_loc10_ + 4);
                     }
                     _loc2_ -= 16;
                     si32(_loc8_,_loc2_ + 4);
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_bare_function_type();
                     _loc2_ += 16;
                     _loc8_ = wdnative.eax;
                     if(_loc12_ != 0)
                     {
                        if(_loc8_ != 0)
                        {
                           _loc7_ = li32(_loc1_ + 20);
                           var _temp_23:* = li32(_loc1_ + 24);
                           _loc11_ = 0;
                           if(_loc7_ < _temp_23)
                           {
                              _loc10_ = li32(_loc1_ + 16);
                              _loc9_ = _loc7_ + 1;
                              si32(_loc9_,_loc1_ + 20);
                              _loc7_ *= 12;
                              _loc1_ = _loc10_ + _loc7_;
                              _loc11_ = 0;
                              if(_loc1_ != 0)
                              {
                                 _loc9_ = _loc10_ + _loc7_;
                                 si32(3,_loc9_);
                                 si32(_loc12_,_loc9_ + 4);
                                 si32(_loc8_,_loc9_ + 8);
                                 _loc11_ = _loc1_;
                              }
                           }
                        }
                     }
                  }
               }
               break;
            }
         }
         _loc10_ = li32(_loc1_ + 48);
         _loc9_ = _loc10_ + 20;
         si32(_loc9_,_loc1_ + 48);
         _loc8_ = li8(_loc12_);
         _loc9_ = _loc12_ + 1;
         si32(_loc9_,_loc1_ + 12);
         if(_loc8_ != 71)
         {
            _loc11_ = 0;
            if(_loc8_ == 84)
            {
               _loc7_ = si8(li8(_loc12_ + 1));
               _loc8_ = _loc12_ + 2;
               si32(_loc8_,_loc1_ + 12);
               _loc11_ = 0;
               if(_loc7_ <= 83)
               {
                  if(_loc7_ <= 72)
                  {
                     if(_loc7_ != 67)
                     {
                        if(_loc7_ != 70)
                        {
                           break;
                        }
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_d_type();
                        _loc11_ = 0;
                        _loc2_ += 16;
                        _loc8_ = wdnative.eax;
                        if(_loc8_ != 0)
                        {
                           _loc10_ = li32(_loc1_ + 20);
                           var _temp_31:* = li32(_loc1_ + 24);
                           _loc11_ = 0;
                           if(_loc10_ < _temp_31)
                           {
                              _loc12_ = li32(_loc1_ + 16);
                              _loc9_ = _loc10_ + 1;
                              si32(_loc9_,_loc1_ + 20);
                              _loc10_ *= 12;
                              _loc1_ = _loc12_ + _loc10_;
                              _loc11_ = 0;
                              if(_loc1_ != 0)
                              {
                                 _loc9_ = _loc12_ + _loc10_;
                                 si32(13,_loc9_);
                                 si32(_loc8_,_loc9_ + 4);
                                 si32(0,_loc9_ + 8);
                                 _loc11_ = _loc1_;
                              }
                           }
                        }
                        break;
                     }
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_type();
                     _loc2_ += 16;
                     _loc12_ = wdnative.eax;
                     _loc7_ = li32(_loc1_ + 12);
                     _loc10_ = li8(_loc7_);
                     _loc8_ = _loc11_ = 0;
                     if(_loc10_ == 110)
                     {
                        _loc9_ = _loc7_ + 1;
                        si32(_loc9_,_loc1_ + 12);
                        _loc10_ = li8(_loc7_ + 1);
                        _loc8_ = 1;
                        _loc7_ = _loc9_;
                     }
                     _loc9_ = _loc10_ + -48;
                     _loc9_ = _loc9_ & 0xFF;
                     _loc5_ = _loc11_;
                     if(uint(_loc9_) <= 9)
                     {
                        do
                        {
                           _loc9_ = _loc7_ + 1;
                           si32(_loc9_,_loc1_ + 12);
                           var _loc6_:int = _loc5_ * 10;
                           var _loc4_:int = _loc10_ << 24;
                           _loc4_ = _loc4_ >> 24;
                           _loc6_ += _loc4_;
                           _loc5_ = _loc6_ + -48;
                           _loc10_ = li8(_loc7_ + 1);
                           _loc6_ = _loc10_ + -48;
                           _loc6_ = _loc6_ & 0xFF;
                           _loc7_ = _loc9_;
                        }
                        while(uint(_loc6_) < 10);
                     }
                     if(_loc8_ != _loc11_)
                     {
                        _loc5_ = 0 - _loc5_;
                     }
                     if(_loc5_ >= 0)
                     {
                        _loc9_ = _loc7_ + 1;
                        si32(_loc9_,_loc1_ + 12);
                        var _temp_43:* = _loc10_ & 0xFF;
                        _loc11_ = 0;
                        if(_temp_43 == 95)
                        {
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_type();
                           _loc2_ += 16;
                           _loc8_ = wdnative.eax;
                           _loc9_ = li32(_loc1_ + 48);
                           _loc9_ = _loc9_ + 5;
                           si32(_loc9_,_loc1_ + 48);
                           _loc11_ = 0;
                           if(_loc8_ != 0)
                           {
                              if(_loc12_ != 0)
                              {
                                 _loc7_ = li32(_loc1_ + 20);
                                 var _temp_47:* = li32(_loc1_ + 24);
                                 _loc11_ = 0;
                                 if(_loc7_ < _temp_47)
                                 {
                                    _loc10_ = li32(_loc1_ + 16);
                                    _loc9_ = _loc7_ + 1;
                                    si32(_loc9_,_loc1_ + 20);
                                    _loc1_ = _loc7_ * 12;
                                    _loc7_ = _loc10_ + _loc1_;
                                    _loc11_ = 0;
                                    if(_loc7_ != 0)
                                    {
                                       _loc9_ = _loc10_ + _loc1_;
                                       si32(10,_loc9_);
                                       si32(_loc8_,_loc9_ + 4);
                                       si32(_loc12_,_loc9_ + 8);
                                       _loc11_ = _loc7_;
                                    }
                                 }
                              }
                           }
                        }
                     }
                     break;
                  }
                  if(_loc7_ != 73)
                  {
                     if(_loc7_ != 74)
                     {
                        if(_loc7_ != 83)
                        {
                           break;
                        }
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_d_type();
                        _loc11_ = 0;
                        _loc2_ += 16;
                        _loc12_ = wdnative.eax;
                        if(_loc12_ != 0)
                        {
                           _loc10_ = li32(_loc1_ + 20);
                           var _temp_51:* = li32(_loc1_ + 24);
                           _loc11_ = 0;
                           if(_loc10_ < _temp_51)
                           {
                              _loc8_ = li32(_loc1_ + 16);
                              _loc9_ = _loc10_ + 1;
                              si32(_loc9_,_loc1_ + 20);
                              _loc10_ *= 12;
                              _loc1_ = _loc8_ + _loc10_;
                              _loc11_ = 0;
                              if(_loc1_ != 0)
                              {
                                 _loc9_ = _loc8_ + _loc10_;
                                 si32(12,_loc9_);
                                 si32(_loc12_,_loc9_ + 4);
                                 si32(0,_loc9_ + 8);
                                 _loc11_ = _loc1_;
                              }
                           }
                        }
                        break;
                     }
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_type();
                     _loc11_ = 0;
                     _loc2_ += 16;
                     _loc8_ = wdnative.eax;
                     if(_loc8_ != 0)
                     {
                        _loc10_ = li32(_loc1_ + 20);
                        var _temp_55:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc10_ < _temp_55)
                        {
                           _loc12_ = li32(_loc1_ + 16);
                           _loc9_ = _loc10_ + 1;
                           si32(_loc9_,_loc1_ + 20);
                           _loc10_ *= 12;
                           _loc1_ = _loc12_ + _loc10_;
                           _loc11_ = 0;
                           if(_loc1_ != 0)
                           {
                              _loc9_ = _loc12_ + _loc10_;
                              si32(17,_loc9_);
                              si32(_loc8_,_loc9_ + 4);
                              si32(0,_loc9_ + 8);
                              _loc11_ = _loc1_;
                           }
                        }
                     }
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_type();
                  _loc11_ = 0;
                  _loc2_ += 16;
                  _loc12_ = wdnative.eax;
                  if(_loc12_ != 0)
                  {
                     _loc10_ = li32(_loc1_ + 20);
                     var _temp_59:* = li32(_loc1_ + 24);
                     _loc11_ = 0;
                     if(_loc10_ < _temp_59)
                     {
                        _loc8_ = li32(_loc1_ + 16);
                        _loc9_ = _loc10_ + 1;
                        si32(_loc9_,_loc1_ + 20);
                        _loc1_ = _loc10_ * 12;
                        _loc10_ = _loc8_ + _loc1_;
                        _loc11_ = 0;
                        if(_loc10_ != 0)
                        {
                           _loc9_ = _loc8_ + _loc1_;
                           si32(11,_loc9_);
                           si32(_loc12_,_loc9_ + 4);
                           si32(0,_loc9_ + 8);
                           _loc11_ = _loc10_;
                        }
                     }
                  }
                  break;
               }
               if(_loc7_ <= 98)
               {
                  if(_loc7_ != 84)
                  {
                     if(_loc7_ != 86)
                     {
                        break;
                     }
                     _loc9_ = _loc10_ + 15;
                     si32(_loc9_,_loc1_ + 48);
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_type();
                     _loc11_ = 0;
                     _loc2_ += 16;
                     _loc12_ = wdnative.eax;
                     if(_loc12_ != 0)
                     {
                        _loc10_ = li32(_loc1_ + 20);
                        var _temp_64:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc10_ < _temp_64)
                        {
                           _loc8_ = li32(_loc1_ + 16);
                           _loc9_ = _loc10_ + 1;
                           si32(_loc9_,_loc1_ + 20);
                           _loc1_ = _loc10_ * 12;
                           _loc10_ = _loc8_ + _loc1_;
                           _loc11_ = 0;
                           if(_loc10_ != 0)
                           {
                              _loc9_ = _loc8_ + _loc1_;
                              si32(8,_loc9_);
                              si32(_loc12_,_loc9_ + 4);
                              si32(0,_loc9_ + 8);
                              _loc11_ = _loc10_;
                           }
                        }
                     }
                     break;
                  }
                  _loc9_ = _loc10_ + 10;
                  si32(_loc9_,_loc1_ + 48);
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_type();
                  _loc11_ = 0;
                  _loc2_ += 16;
                  _loc12_ = wdnative.eax;
                  if(_loc12_ != 0)
                  {
                     _loc10_ = li32(_loc1_ + 20);
                     var _temp_69:* = li32(_loc1_ + 24);
                     _loc11_ = 0;
                     if(_loc10_ < _temp_69)
                     {
                        _loc8_ = li32(_loc1_ + 16);
                        _loc9_ = _loc10_ + 1;
                        si32(_loc9_,_loc1_ + 20);
                        _loc10_ *= 12;
                        _loc1_ = _loc8_ + _loc10_;
                        _loc11_ = 0;
                        if(_loc1_ != 0)
                        {
                           _loc9_ = _loc8_ + _loc10_;
                           si32(9,_loc9_);
                           si32(_loc12_,_loc9_ + 4);
                           si32(0,_loc9_ + 8);
                           _loc11_ = _loc1_;
                        }
                     }
                  }
                  break;
               }
               if(_loc7_ != 99)
               {
                  if(_loc7_ != 104)
                  {
                     if(_loc7_ != 118)
                     {
                        break;
                     }
                     _loc11_ = li8(_loc8_);
                     if(_loc11_ == 110)
                     {
                        _loc8_ = _loc12_ + 3;
                        si32(_loc8_,_loc1_ + 12);
                        _loc11_ = li8(_loc12_ + 3);
                     }
                     _loc9_ = _loc11_ + -48;
                     _loc9_ = _loc9_ & 0xFF;
                     if((uint(_loc9_)) <= 9)
                     {
                        do
                        {
                           _loc9_ = _loc8_ + 1;
                           si32(_loc9_,_loc1_ + 12);
                           _loc11_ = li8(_loc8_ + 1);
                           _loc6_ = _loc11_ + -48;
                           _loc6_ = _loc6_ & 0xFF;
                           _loc8_ = _loc9_;
                        }
                        while(uint(_loc6_) < 10);
                     }
                     _loc12_ = _loc8_ + 1;
                     si32(_loc12_,_loc1_ + 12);
                     _loc9_ = _loc11_ & 0xFF;
                     _loc11_ = 0;
                     if(_loc9_ == 95)
                     {
                        _loc11_ = li8(_loc12_);
                        if(_loc11_ == 110)
                        {
                           _loc12_ = _loc8_ + 2;
                           si32(_loc12_,_loc1_ + 12);
                           _loc11_ = li8(_loc8_ + 2);
                        }
                        _loc9_ = _loc11_ + -48;
                        _loc9_ = _loc9_ & 0xFF;
                        if((uint(_loc9_)) <= 9)
                        {
                           do
                           {
                              _loc9_ = _loc12_ + 1;
                              si32(_loc9_,_loc1_ + 12);
                              _loc11_ = li8(_loc12_ + 1);
                              _loc6_ = _loc11_ + -48;
                              _loc6_ = _loc6_ & 0xFF;
                              _loc12_ = _loc9_;
                           }
                           while(uint(_loc6_) < 10);
                        }
                        _loc9_ = _loc12_ + 1;
                        si32(_loc9_,_loc1_ + 12);
                        _loc9_ = _loc11_ & 0xFF;
                        _loc11_ = 0;
                        if(_loc9_ == 95)
                        {
                           _loc2_ -= 16;
                           _loc11_ = 0;
                           si32(_loc11_,_loc2_ + 4);
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_d_encoding();
                           _loc2_ += 16;
                           _loc8_ = wdnative.eax;
                           if(_loc8_ != 0)
                           {
                              _loc10_ = li32(_loc1_ + 20);
                              var _temp_89:* = li32(_loc1_ + 24);
                              _loc11_ = 0;
                              if(_loc10_ < _temp_89)
                              {
                                 _loc12_ = li32(_loc1_ + 16);
                                 _loc9_ = _loc10_ + 1;
                                 si32(_loc9_,_loc1_ + 20);
                                 _loc1_ = _loc10_ * 12;
                                 _loc10_ = _loc12_ + _loc1_;
                                 _loc11_ = 0;
                                 if(_loc10_ != 0)
                                 {
                                    _loc9_ = _loc12_ + _loc1_;
                                    si32(15,_loc9_);
                                    si32(_loc8_,_loc9_ + 4);
                                    si32(0,_loc9_ + 8);
                                    _loc11_ = _loc10_;
                                 }
                              }
                           }
                        }
                     }
                     break;
                  }
                  _loc11_ = li8(_loc8_);
                  if(_loc11_ == 110)
                  {
                     _loc8_ = _loc12_ + 3;
                     si32(_loc8_,_loc1_ + 12);
                     _loc11_ = li8(_loc12_ + 3);
                  }
                  _loc9_ = _loc11_ + -48;
                  _loc9_ = _loc9_ & 0xFF;
                  if((uint(_loc9_)) <= 9)
                  {
                     do
                     {
                        _loc9_ = _loc8_ + 1;
                        si32(_loc9_,_loc1_ + 12);
                        _loc11_ = li8(_loc8_ + 1);
                        _loc6_ = _loc11_ + -48;
                        _loc6_ = _loc6_ & 0xFF;
                        _loc8_ = _loc9_;
                     }
                     while(uint(_loc6_) < 10);
                  }
                  _loc9_ = _loc8_ + 1;
                  si32(_loc9_,_loc1_ + 12);
                  _loc9_ = _loc11_ & 0xFF;
                  _loc11_ = 0;
                  if(_loc9_ == 95)
                  {
                     _loc2_ -= 16;
                     _loc11_ = 0;
                     si32(_loc11_,_loc2_ + 4);
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_encoding();
                     _loc2_ += 16;
                     _loc12_ = wdnative.eax;
                     if(_loc12_ != 0)
                     {
                        _loc10_ = li32(_loc1_ + 20);
                        var _temp_101:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc10_ < _temp_101)
                        {
                           _loc8_ = li32(_loc1_ + 16);
                           _loc9_ = _loc10_ + 1;
                           si32(_loc9_,_loc1_ + 20);
                           _loc10_ *= 12;
                           _loc1_ = _loc8_ + _loc10_;
                           _loc11_ = 0;
                           if(_loc1_ != 0)
                           {
                              _loc9_ = _loc8_ + _loc10_;
                              si32(14,_loc9_);
                              si32(_loc12_,_loc9_ + 4);
                              si32(0,_loc9_ + 8);
                              _loc11_ = _loc1_;
                           }
                        }
                     }
                  }
                  break;
               }
               _loc10_ = si8(li8(_loc12_ + 2));
               _loc8_ = _loc12_ + 3;
               si32(_loc8_,_loc1_ + 12);
               if(_loc10_ != 118)
               {
                  _loc11_ = 0;
                  if(_loc10_ != 104)
                  {
                     break;
                  }
                  _loc11_ = li8(_loc8_);
                  if(_loc11_ == 110)
                  {
                     _loc8_ = _loc12_ + 4;
                     si32(_loc8_,_loc1_ + 12);
                     _loc11_ = li8(_loc12_ + 4);
                  }
                  _loc9_ = _loc11_ + -48;
                  _loc9_ = _loc9_ & 0xFF;
                  _loc12_ = _loc8_;
                  if(uint(_loc9_) <= 9)
                  {
                     do
                     {
                        _loc12_ = _loc8_ + 1;
                        si32(_loc12_,_loc1_ + 12);
                        _loc11_ = li8(_loc8_ + 1);
                        _loc9_ = _loc11_ + -48;
                        _loc9_ = _loc9_ & 0xFF;
                        _loc8_ = _loc12_;
                     }
                     while(uint(_loc9_) <= 9);
                  }
               }
               else
               {
                  _loc11_ = li8(_loc8_);
                  if(_loc11_ == 110)
                  {
                     _loc8_ = _loc12_ + 4;
                     si32(_loc8_,_loc1_ + 12);
                     _loc11_ = li8(_loc12_ + 4);
                  }
                  _loc9_ = _loc11_ + -48;
                  _loc9_ = _loc9_ & 0xFF;
                  if((uint(_loc9_)) <= 9)
                  {
                     do
                     {
                        _loc9_ = _loc8_ + 1;
                        si32(_loc9_,_loc1_ + 12);
                        _loc11_ = li8(_loc8_ + 1);
                        _loc6_ = _loc11_ + -48;
                        _loc6_ = _loc6_ & 0xFF;
                        _loc8_ = _loc9_;
                     }
                     while(uint(_loc6_) < 10);
                  }
                  _loc10_ = _loc8_ + 1;
                  si32(_loc10_,_loc1_ + 12);
                  _loc9_ = _loc11_ & 0xFF;
                  _loc11_ = 0;
                  if(_loc9_ != 95)
                  {
                     break;
                  }
                  _loc11_ = li8(_loc10_);
                  if(_loc11_ == 110)
                  {
                     _loc10_ = _loc8_ + 2;
                     si32(_loc10_,_loc1_ + 12);
                     _loc11_ = li8(_loc8_ + 2);
                  }
                  _loc9_ = _loc11_ + -48;
                  _loc9_ = _loc9_ & 0xFF;
                  _loc12_ = _loc10_;
                  if(uint(_loc9_) <= 9)
                  {
                     do
                     {
                        _loc12_ = _loc10_ + 1;
                        si32(_loc12_,_loc1_ + 12);
                        _loc11_ = li8(_loc10_ + 1);
                        _loc9_ = _loc11_ + -48;
                        _loc9_ = _loc9_ & 0xFF;
                        _loc10_ = _loc12_;
                     }
                     while(uint(_loc9_) < 10);
                  }
               }
               _loc9_ = _loc12_ + 1;
               si32(_loc9_,_loc1_ + 12);
               _loc9_ = _loc11_ & 0xFF;
               _loc11_ = 0;
               if(_loc9_ == 95)
               {
                  _loc10_ = si8(li8(_loc12_ + 1));
                  _loc8_ = _loc12_ + 2;
                  si32(_loc8_,_loc1_ + 12);
                  if(_loc10_ != 118)
                  {
                     _loc11_ = 0;
                     if(_loc10_ != 104)
                     {
                        break;
                     }
                     _loc11_ = li8(_loc8_);
                     if(_loc11_ == 110)
                     {
                        _loc8_ = _loc12_ + 3;
                        si32(_loc8_,_loc1_ + 12);
                        _loc11_ = li8(_loc12_ + 3);
                     }
                     _loc9_ = _loc11_ + -48;
                     _loc9_ = _loc9_ & 0xFF;
                     _loc10_ = _loc8_;
                     if(uint(_loc9_) <= 9)
                     {
                        do
                        {
                           _loc10_ = _loc8_ + 1;
                           si32(_loc10_,_loc1_ + 12);
                           _loc11_ = li8(_loc8_ + 1);
                           _loc9_ = _loc11_ + -48;
                           _loc9_ = _loc9_ & 0xFF;
                           _loc8_ = _loc10_;
                        }
                        while(uint(_loc9_) <= 9);
                     }
                  }
                  else
                  {
                     _loc11_ = li8(_loc8_);
                     if(_loc11_ == 110)
                     {
                        _loc8_ = _loc12_ + 3;
                        si32(_loc8_,_loc1_ + 12);
                        _loc11_ = li8(_loc12_ + 3);
                     }
                     _loc9_ = _loc11_ + -48;
                     _loc9_ = _loc9_ & 0xFF;
                     if((uint(_loc9_)) <= 9)
                     {
                        do
                        {
                           _loc9_ = _loc8_ + 1;
                           si32(_loc9_,_loc1_ + 12);
                           _loc11_ = li8(_loc8_ + 1);
                           _loc6_ = _loc11_ + -48;
                           _loc6_ = _loc6_ & 0xFF;
                           _loc8_ = _loc9_;
                        }
                        while(uint(_loc6_) < 10);
                     }
                     _loc12_ = _loc8_ + 1;
                     si32(_loc12_,_loc1_ + 12);
                     _loc9_ = _loc11_ & 0xFF;
                     _loc11_ = 0;
                     if(_loc9_ != 95)
                     {
                        break;
                     }
                     _loc11_ = li8(_loc12_);
                     if(_loc11_ == 110)
                     {
                        _loc12_ = _loc8_ + 2;
                        si32(_loc12_,_loc1_ + 12);
                        _loc11_ = li8(_loc8_ + 2);
                     }
                     _loc9_ = _loc11_ + -48;
                     _loc9_ = _loc9_ & 0xFF;
                     _loc10_ = _loc12_;
                     if(uint(_loc9_) <= 9)
                     {
                        do
                        {
                           _loc10_ = _loc12_ + 1;
                           si32(_loc10_,_loc1_ + 12);
                           _loc11_ = li8(_loc12_ + 1);
                           _loc9_ = _loc11_ + -48;
                           _loc9_ = _loc9_ & 0xFF;
                           _loc12_ = _loc10_;
                        }
                        while(uint(_loc9_) < 10);
                     }
                  }
                  _loc9_ = _loc10_ + 1;
                  si32(_loc9_,_loc1_ + 12);
                  _loc9_ = _loc11_ & 0xFF;
                  _loc11_ = 0;
                  if(_loc9_ == 95)
                  {
                     _loc2_ -= 16;
                     _loc11_ = 0;
                     si32(_loc11_,_loc2_ + 4);
                     si32(_loc1_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_encoding();
                     _loc2_ += 16;
                     _loc8_ = wdnative.eax;
                     if(_loc8_ != 0)
                     {
                        _loc10_ = li32(_loc1_ + 20);
                        var _temp_149:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc10_ < _temp_149)
                        {
                           _loc12_ = li32(_loc1_ + 16);
                           _loc9_ = _loc10_ + 1;
                           si32(_loc9_,_loc1_ + 20);
                           _loc10_ *= 12;
                           _loc1_ = _loc12_ + _loc10_;
                           _loc11_ = 0;
                           if(_loc1_ != 0)
                           {
                              _loc9_ = _loc12_ + _loc10_;
                              si32(16,_loc9_);
                              si32(_loc8_,_loc9_ + 4);
                              si32(0,_loc9_ + 8);
                              _loc11_ = _loc1_;
                           }
                        }
                     }
                  }
               }
            }
            break;
         }
         _loc8_ = si8(li8(_loc12_ + 1));
         _loc9_ = _loc12_ + 2;
         si32(_loc9_,_loc1_ + 12);
         if(_loc8_ != 65)
         {
            if(_loc8_ != 82)
            {
               _loc11_ = 0;
               if(_loc8_ == 86)
               {
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_name();
                  _loc11_ = 0;
                  _loc2_ += 16;
                  _loc8_ = wdnative.eax;
                  if(_loc8_ != 0)
                  {
                     _loc10_ = li32(_loc1_ + 20);
                     var _temp_154:* = li32(_loc1_ + 24);
                     _loc11_ = 0;
                     if(_loc10_ < _temp_154)
                     {
                        _loc12_ = li32(_loc1_ + 16);
                        _loc9_ = _loc10_ + 1;
                        si32(_loc9_,_loc1_ + 20);
                        _loc10_ *= 12;
                        _loc1_ = _loc12_ + _loc10_;
                        _loc11_ = 0;
                        if(_loc1_ != 0)
                        {
                           _loc9_ = _loc12_ + _loc10_;
                           si32(18,_loc9_);
                           si32(_loc8_,_loc9_ + 4);
                           si32(0,_loc9_ + 8);
                           _loc11_ = _loc1_;
                        }
                     }
                  }
               }
               break;
            }
            _loc2_ -= 16;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_name();
            _loc11_ = 0;
            _loc2_ += 16;
            _loc8_ = wdnative.eax;
            if(_loc8_ != 0)
            {
               _loc10_ = li32(_loc1_ + 20);
               var _temp_158:* = li32(_loc1_ + 24);
               _loc11_ = 0;
               if(_loc10_ < _temp_158)
               {
                  _loc12_ = li32(_loc1_ + 16);
                  _loc9_ = _loc10_ + 1;
                  si32(_loc9_,_loc1_ + 20);
                  _loc10_ *= 12;
                  _loc1_ = _loc12_ + _loc10_;
                  _loc11_ = 0;
                  if(_loc1_ != 0)
                  {
                     _loc9_ = _loc12_ + _loc10_;
                     si32(19,_loc9_);
                     si32(_loc8_,_loc9_ + 4);
                     si32(0,_loc9_ + 8);
                     _loc11_ = _loc1_;
                  }
               }
            }
            break;
         }
         _loc2_ -= 16;
         _loc11_ = 0;
         si32(_loc11_,_loc2_ + 4);
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_encoding();
         _loc2_ += 16;
         _loc12_ = wdnative.eax;
         if(_loc12_ != 0)
         {
            _loc10_ = li32(_loc1_ + 20);
            var _temp_162:* = li32(_loc1_ + 24);
            _loc11_ = 0;
            if(_loc10_ < _temp_162)
            {
               _loc8_ = li32(_loc1_ + 16);
               _loc9_ = _loc10_ + 1;
               si32(_loc9_,_loc1_ + 20);
               _loc1_ = _loc10_ * 12;
               _loc10_ = _loc8_ + _loc1_;
               _loc11_ = 0;
               if(_loc10_ != 0)
               {
                  _loc9_ = _loc8_ + _loc1_;
                  si32(20,_loc9_);
                  si32(_loc12_,_loc9_ + 4);
                  si32(0,_loc9_ + 8);
                  _loc11_ = _loc10_;
               }
            }
         }
         break;
      }
      wdnative.eax = _loc11_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

