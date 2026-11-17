package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_name() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc13_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 16;
      _loc3_ = li32(_loc4_);
      _loc15_ = li32(_loc3_ + 12);
      _loc14_ = si8(li8(_loc15_));
      if(_loc14_ <= 82)
      {
         if(_loc14_ != 76)
         {
            if(_loc14_ != 78)
            {
               addr0c70:
               _loc2_ -= 16;
               si32(_loc3_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_unqualified_name();
               _loc2_ += 16;
               _loc15_ = wdnative.eax;
               var _loc12_:int = li32(_loc3_ + 12);
               _loc12_ = li8(_loc12_);
               _loc14_ = _loc15_;
               if(_loc12_ == 73)
               {
                  _loc14_ = 0;
                  if(_loc15_ != 0)
                  {
                     _loc10_ = li32(_loc3_ + 32);
                     var _temp_6:* = li32(_loc3_ + 36);
                     _loc14_ = 0;
                     if(_loc10_ < _temp_6)
                     {
                        var _temp_8:* = _loc10_ << 2;
                        var _temp_9:* = int((_loc12_ = li32(_loc3_ + 28)) + _temp_8);
                        si32(_loc15_,_temp_9);
                        _loc12_ = li32(_loc3_ + 32);
                        _loc12_ = _loc12_ + 1;
                        si32(_loc12_,_loc3_ + 32);
                        _loc2_ -= 16;
                        si32(_loc3_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_d_template_args();
                        _loc14_ = 0;
                        _loc2_ += 16;
                        _loc9_ = wdnative.eax;
                        if(_loc15_ != 0)
                        {
                           if(_loc9_ != 0)
                           {
                              _loc13_ = li32(_loc3_ + 20);
                              var _temp_13:* = li32(_loc3_ + 24);
                              _loc14_ = 0;
                              if(_loc13_ < _temp_13)
                              {
                                 _loc10_ = li32(_loc3_ + 16);
                                 _loc12_ = _loc13_ + 1;
                                 si32(_loc12_,_loc3_ + 20);
                                 _loc13_ *= 12;
                                 _loc3_ = _loc10_ + _loc13_;
                                 _loc14_ = 0;
                                 if(_loc3_ != 0)
                                 {
                                    _loc12_ = _loc10_ + _loc13_;
                                    si32(4,_loc12_);
                                    si32(_loc15_,_loc12_ + 4);
                                    si32(_loc9_,_loc12_ + 8);
                                    _loc14_ = _loc3_;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
            else
            {
               _loc13_ = _loc15_ + 1;
               si32(_loc13_,_loc3_ + 12);
               var _temp_16:* = _loc14_ & 0xFF;
               _loc14_ = 0;
               if(_temp_16 == 78)
               {
                  _loc15_ = _loc4_ - 4;
                  _loc14_ = 0;
                  while(true)
                  {
                     _loc11_ = li8(_loc13_);
                     if(_loc11_ != 75)
                     {
                        if(_loc11_ != 86)
                        {
                           if(_loc11_ != 114)
                           {
                              if(_loc15_ != 0)
                              {
                                 _loc10_ = 0;
                                 loop1:
                                 while(true)
                                 {
                                    _loc9_ = _loc11_ & 0xFF;
                                    if(_loc9_ != 0)
                                    {
                                       loop5:
                                       while(true)
                                       {
                                          _loc12_ = _loc11_ + -48;
                                          _loc12_ = _loc12_ & 0xFF;
                                          if((uint(_loc12_)) >= 10)
                                          {
                                             _loc12_ = _loc11_ + -97;
                                             _loc12_ = _loc12_ & 0xFF;
                                             if((uint(_loc12_)) >= 26)
                                             {
                                                _loc12_ = _loc11_ << 24;
                                                _loc12_ = _loc12_ >> 24;
                                                if(_loc12_ <= 75)
                                                {
                                                   _loc12_ = _loc11_ + -67;
                                                   _loc12_ = _loc12_ & 0xFF;
                                                   if((uint(_loc12_)) >= 2)
                                                   {
                                                      if(_loc9_ != 69)
                                                      {
                                                         if(_loc9_ != 73)
                                                         {
                                                            addr0260:
                                                            _loc14_ = 0;
                                                            si32(_loc14_,_loc15_);
                                                            break loop1;
                                                         }
                                                         addr0582:
                                                         if(_loc10_ != 0)
                                                         {
                                                            _loc2_ -= 16;
                                                            si32(_loc3_,_loc2_);
                                                            wdnative.ESP = _loc2_;
                                                            wdnative_nternal.F_d_template_args();
                                                            _loc13_ = 4;
                                                            _loc2_ += 16;
                                                            _loc14_ = wdnative.eax;
                                                            addr048e:
                                                            _loc1_ = _loc14_;
                                                            _loc14_ = 0;
                                                            if(_loc1_ != 0)
                                                            {
                                                               _loc5_ = li32(_loc3_ + 20);
                                                               var _temp_32:* = li32(_loc3_ + 24);
                                                               _loc14_ = 0;
                                                               if(_loc5_ < _temp_32)
                                                               {
                                                                  _loc11_ = li32(_loc3_ + 16);
                                                                  _loc12_ = _loc5_ + 1;
                                                                  si32(_loc12_,_loc3_ + 20);
                                                                  _loc7_ = _loc5_ * 12;
                                                                  _loc5_ = _loc11_ + _loc7_;
                                                                  _loc14_ = 0;
                                                                  if(_loc5_ != 0)
                                                                  {
                                                                     _loc12_ = _loc11_ + _loc7_;
                                                                     si32(_loc13_,_loc12_);
                                                                     si32(_loc10_,_loc12_ + 4);
                                                                     si32(_loc1_,_loc12_ + 8);
                                                                     _loc14_ = _loc5_;
                                                                  }
                                                               }
                                                            }
                                                            addr0508:
                                                            if(_loc9_ == 83)
                                                            {
                                                               continue loop1;
                                                            }
                                                            _loc12_ = li32(_loc3_ + 12);
                                                            _loc12_ = li8(_loc12_);
                                                            if(_loc12_ == 69)
                                                            {
                                                               continue loop1;
                                                            }
                                                            if(_loc14_ != 0)
                                                            {
                                                               _loc10_ = li32(_loc3_ + 32);
                                                               var _temp_36:* = li32(_loc3_ + 36);
                                                               if(_loc10_ < _temp_36)
                                                               {
                                                                  var _temp_38:* = _loc10_ << 2;
                                                                  var _temp_39:* = int((_loc12_ = li32(_loc3_ + 28)) + _temp_38);
                                                                  si32(_loc14_,_temp_39);
                                                                  _loc12_ = li32(_loc3_ + 32);
                                                                  _loc12_ = _loc12_ + 1;
                                                                  si32(_loc12_,_loc3_ + 32);
                                                                  continue loop1;
                                                               }
                                                            }
                                                         }
                                                         _loc14_ = 0;
                                                         si32(_loc14_,_loc15_);
                                                         break loop1;
                                                      }
                                                      si32(_loc10_,_loc15_);
                                                      _loc14_ = 0;
                                                      if(_loc10_ != 0)
                                                      {
                                                         var _loc8_:int = li32(_loc3_ + 12);
                                                         var _temp_44:* = li8(_loc8_);
                                                         si32(_loc8_ += 1,_loc3_ + 12);
                                                         _loc14_ = 0;
                                                         if(_temp_44 == 69)
                                                         {
                                                            _loc14_ = li32(_loc4_ - 4);
                                                         }
                                                      }
                                                      break loop1;
                                                   }
                                                }
                                                else if(_loc9_ != 76)
                                                {
                                                   if(_loc9_ == 83)
                                                   {
                                                      _loc2_ -= 16;
                                                      si32(1,_loc2_ + 4);
                                                      si32(_loc3_,_loc2_);
                                                      wdnative.ESP = _loc2_;
                                                      wdnative_nternal.F_d_substitution();
                                                      _loc2_ += 16;
                                                      _loc14_ = wdnative.eax;
                                                      break;
                                                   }
                                                   if(_loc9_ == 84)
                                                   {
                                                      _loc1_ = _loc13_ + 1;
                                                      si32(_loc1_,_loc3_ + 12);
                                                      _loc11_ = li8(_loc13_ + 1);
                                                      _loc14_ = 0;
                                                      while(true)
                                                      {
                                                         if(_loc11_ != 110)
                                                         {
                                                            _loc5_ = _loc14_;
                                                            if(_loc11_ == 95)
                                                            {
                                                               _loc12_ = _loc13_ + 2;
                                                               si32(_loc12_,_loc3_ + 12);
                                                               _loc13_ = 0;
                                                               break;
                                                            }
                                                         }
                                                         else
                                                         {
                                                            _loc1_ = _loc13_ + 2;
                                                            si32(_loc1_,_loc3_ + 12);
                                                            _loc11_ = li8(_loc13_ + 2);
                                                            _loc5_ = 1;
                                                         }
                                                         _loc12_ = _loc11_ + -48;
                                                         _loc12_ = _loc12_ & 0xFF;
                                                         _loc13_ = _loc14_;
                                                         if(uint(_loc12_) <= 9)
                                                         {
                                                            do
                                                            {
                                                               _loc12_ = _loc1_ + 1;
                                                               si32(_loc12_,_loc3_ + 12);
                                                               _loc8_ = _loc13_ * 10;
                                                               var _loc6_:int = _loc11_ << 24;
                                                               _loc6_ = _loc6_ >> 24;
                                                               _loc8_ += _loc6_;
                                                               _loc13_ = _loc8_ + -48;
                                                               _loc11_ = li8(_loc1_ + 1);
                                                               _loc8_ = _loc11_ + -48;
                                                               _loc8_ = _loc8_ & 0xFF;
                                                               _loc1_ = _loc12_;
                                                            }
                                                            while(uint(_loc8_) < 10);
                                                         }
                                                         if(_loc5_ != _loc14_)
                                                         {
                                                            _loc13_ = 0 - _loc13_;
                                                         }
                                                         if(_loc13_ >= 0)
                                                         {
                                                            _loc12_ = _loc1_ + 1;
                                                            si32(_loc12_,_loc3_ + 12);
                                                            var _temp_53:* = _loc11_ & 0xFF;
                                                            _loc14_ = 0;
                                                            if(_temp_53 == 95)
                                                            {
                                                               _loc13_ += 1;
                                                               break;
                                                            }
                                                         }
                                                         break loop5;
                                                      }
                                                      _loc12_ = li32(_loc3_ + 40);
                                                      _loc12_ = _loc12_ + 1;
                                                      si32(_loc12_,_loc3_ + 40);
                                                      _loc1_ = li32(_loc3_ + 20);
                                                      _loc12_ = li32(_loc3_ + 24);
                                                      _loc14_ = 0;
                                                      if(_loc1_ < _loc12_)
                                                      {
                                                         _loc11_ = li32(_loc3_ + 16);
                                                         _loc12_ = _loc1_ + 1;
                                                         si32(_loc12_,_loc3_ + 20);
                                                         _loc5_ = _loc1_ * 12;
                                                         _loc1_ = _loc11_ + _loc5_;
                                                         _loc14_ = 0;
                                                         if(_loc1_ != 0)
                                                         {
                                                            _loc12_ = _loc11_ + _loc5_;
                                                            si32(5,_loc12_);
                                                            si32(_loc13_,_loc12_ + 4);
                                                            _loc14_ = _loc1_;
                                                         }
                                                      }
                                                      break;
                                                   }
                                                   §§goto(addr0260);
                                                }
                                             }
                                          }
                                          _loc2_ -= 16;
                                          si32(_loc3_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_d_unqualified_name();
                                          _loc2_ += 16;
                                          _loc14_ = wdnative.eax;
                                          break;
                                       }
                                       _loc13_ = 1;
                                       if(_loc10_ != 0)
                                       {
                                          §§goto(addr048e);
                                       }
                                       §§goto(addr0508);
                                    }
                                    §§goto(addr0582);
                                    _loc13_ = li32(_loc3_ + 12);
                                    _loc11_ = li8(_loc13_);
                                    _loc10_ = _loc14_;
                                 }
                              }
                              §§goto(addr0d9c);
                           }
                        }
                     }
                     _loc12_ = _loc13_ + 1;
                     si32(_loc12_,_loc3_ + 12);
                     if(_loc11_ != 86)
                     {
                        if(_loc11_ == 114)
                        {
                           _loc12_ = li32(_loc3_ + 48);
                           _loc12_ = _loc12_ + 9;
                           si32(_loc12_,_loc3_ + 48);
                           _loc10_ = 25;
                        }
                        else
                        {
                           _loc12_ = li32(_loc3_ + 48);
                           _loc12_ = _loc12_ + 6;
                           si32(_loc12_,_loc3_ + 48);
                           _loc10_ = 27;
                        }
                     }
                     else
                     {
                        _loc12_ = li32(_loc3_ + 48);
                        _loc12_ = _loc12_ + 9;
                        si32(_loc12_,_loc3_ + 48);
                        _loc10_ = 26;
                     }
                     _loc9_ = li32(_loc3_ + 20);
                     _loc12_ = li32(_loc3_ + 24);
                     if(_loc9_ >= _loc12_)
                     {
                        break;
                     }
                     var _temp_69:* = li32(_loc3_ + 16);
                     si32(_loc8_ = _loc9_ + 1,_loc3_ + 20);
                     _loc9_ = _temp_69 + int(_loc9_ * 12);
                     if(_loc9_ == 0)
                     {
                        break;
                     }
                     si32(_loc10_,_loc9_);
                     si32(_loc14_,_loc9_ + 4);
                     si32(_loc14_,_loc9_ + 8);
                     si32(_loc9_,_loc15_);
                     _loc15_ = _loc9_ + 4;
                     _loc13_ = li32(_loc3_ + 12);
                  }
                  _loc14_ = 0;
                  si32(_loc14_,_loc15_);
               }
            }
         }
         else
         {
            _loc2_ -= 16;
            si32(_loc3_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_unqualified_name();
            _loc2_ += 16;
            _loc14_ = wdnative.eax;
         }
      }
      else if(_loc14_ != 83)
      {
         if(_loc14_ != 90)
         {
            §§goto(addr0c70);
         }
         else
         {
            _loc12_ = _loc15_ + 1;
            si32(_loc12_,_loc3_ + 12);
            var _temp_73:* = _loc14_ & 0xFF;
            _loc14_ = 0;
            if(_temp_73 == 90)
            {
               _loc2_ -= 16;
               _loc14_ = 0;
               si32(_loc14_,_loc2_ + 4);
               si32(_loc3_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_encoding();
               _loc2_ += 16;
               _loc15_ = wdnative.eax;
               _loc11_ = li32(_loc3_ + 12);
               var _temp_77:* = li8(_loc11_);
               si32(_loc10_ = _loc11_ + 1,_loc3_ + 12);
               if(_temp_77 == 69)
               {
                  _loc12_ = li8(_loc10_);
                  if(_loc12_ == 115)
                  {
                     _loc12_ = _loc11_ + 2;
                     si32(_loc12_,_loc3_ + 12);
                     while(true)
                     {
                        _loc12_ = li8(_loc11_ + 2);
                        if(_loc12_ == 95)
                        {
                           _loc13_ = _loc11_ + 3;
                           si32(_loc13_,_loc3_ + 12);
                           _loc9_ = li8(_loc11_ + 3);
                           _loc10_ = _loc14_ = 0;
                           if(_loc9_ == 110)
                           {
                              _loc13_ = _loc11_ + 4;
                              si32(_loc13_,_loc3_ + 12);
                              _loc9_ = li8(_loc11_ + 4);
                              _loc10_ = 1;
                           }
                           _loc12_ = _loc9_ + -48;
                           _loc12_ = _loc12_ & 0xFF;
                           _loc11_ = _loc14_;
                           if(uint(_loc12_) <= 9)
                           {
                              _loc13_ += 1;
                              _loc11_ = 0;
                              do
                              {
                                 si32(_loc13_,_loc3_ + 12);
                                 _loc12_ = _loc11_ * 10;
                                 _loc8_ = _loc9_ << 24;
                                 _loc8_ = _loc8_ >> 24;
                                 _loc12_ += _loc8_;
                                 _loc11_ = _loc12_ + -48;
                                 _loc12_ = _loc13_ + 1;
                                 _loc9_ = li8(_loc13_);
                                 _loc8_ = _loc9_ + -48;
                                 _loc8_ = _loc8_ & 0xFF;
                                 _loc13_ = _loc12_;
                              }
                              while(uint(_loc8_) < 10);
                           }
                           if(_loc10_ != _loc14_)
                           {
                              _loc11_ = 0 - _loc11_;
                           }
                           if(_loc11_ < 0)
                           {
                              break;
                           }
                        }
                        _loc10_ = li32(_loc3_ + 20);
                        _loc12_ = li32(_loc3_ + 24);
                        _loc14_ = 0;
                        if(_loc10_ < _loc12_)
                        {
                           var _temp_89:* = li32(_loc3_ + 16);
                           si32(_loc8_ = _loc10_ + 1,_loc3_ + 20);
                           _loc9_ = _temp_89 + int(_loc10_ * 12);
                           _loc14_ = 0;
                           if(_loc9_ != 0)
                           {
                              _loc14_ = 0;
                              si32(_loc14_,_loc9_);
                              si32(wdnative_nternal.L__2E_str135522,_loc9_ + 4);
                              si32(14,_loc9_ + 8);
                              if(_loc15_ != 0)
                              {
                                 _loc13_ = li32(_loc3_ + 20);
                                 var _temp_90:* = li32(_loc3_ + 24);
                                 _loc14_ = 0;
                                 if(_loc13_ < _temp_90)
                                 {
                                    _loc10_ = li32(_loc3_ + 16);
                                    _loc12_ = _loc13_ + 1;
                                    si32(_loc12_,_loc3_ + 20);
                                    _loc13_ *= 12;
                                    _loc3_ = _loc10_ + _loc13_;
                                    _loc14_ = 0;
                                    if(_loc3_ != 0)
                                    {
                                       _loc12_ = _loc10_ + _loc13_;
                                       si32(2,_loc12_);
                                       si32(_loc15_,_loc12_ + 4);
                                       si32(_loc9_,_loc12_ + 8);
                                       _loc14_ = _loc3_;
                                    }
                                 }
                              }
                           }
                        }
                        break;
                     }
                  }
                  else
                  {
                     _loc2_ -= 16;
                     si32(_loc3_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_name();
                     _loc2_ += 16;
                     _loc10_ = wdnative.eax;
                     while(true)
                     {
                        _loc11_ = li32(_loc3_ + 12);
                        _loc12_ = li8(_loc11_);
                        if(_loc12_ == 95)
                        {
                           _loc1_ = _loc11_ + 1;
                           si32(_loc1_,_loc3_ + 12);
                           _loc9_ = li8(_loc11_ + 1);
                           _loc13_ = _loc14_ = 0;
                           if(_loc9_ == 110)
                           {
                              _loc1_ = _loc11_ + 2;
                              si32(_loc1_,_loc3_ + 12);
                              _loc9_ = li8(_loc11_ + 2);
                              _loc13_ = 1;
                           }
                           _loc12_ = _loc9_ + -48;
                           _loc12_ = _loc12_ & 0xFF;
                           _loc11_ = _loc14_;
                           if(uint(_loc12_) <= 9)
                           {
                              _loc1_ += 1;
                              _loc11_ = 0;
                              do
                              {
                                 si32(_loc1_,_loc3_ + 12);
                                 _loc12_ = _loc11_ * 10;
                                 _loc8_ = _loc9_ << 24;
                                 _loc8_ = _loc8_ >> 24;
                                 _loc12_ += _loc8_;
                                 _loc11_ = _loc12_ + -48;
                                 _loc12_ = _loc1_ + 1;
                                 _loc9_ = li8(_loc1_);
                                 _loc8_ = _loc9_ + -48;
                                 _loc8_ = _loc8_ & 0xFF;
                                 _loc1_ = _loc12_;
                              }
                              while(uint(_loc8_) < 10);
                           }
                           if(_loc13_ != _loc14_)
                           {
                              _loc11_ = 0 - _loc11_;
                           }
                           if(_loc11_ < 0)
                           {
                              break;
                           }
                        }
                        _loc14_ = 0;
                        if(_loc15_ != 0)
                        {
                           if(_loc10_ != 0)
                           {
                              _loc13_ = li32(_loc3_ + 20);
                              var _temp_100:* = li32(_loc3_ + 24);
                              _loc14_ = 0;
                              if(_loc13_ < _temp_100)
                              {
                                 _loc9_ = li32(_loc3_ + 16);
                                 _loc12_ = _loc13_ + 1;
                                 si32(_loc12_,_loc3_ + 20);
                                 _loc13_ *= 12;
                                 _loc3_ = _loc9_ + _loc13_;
                                 _loc14_ = 0;
                                 if(_loc3_ != 0)
                                 {
                                    _loc12_ = _loc9_ + _loc13_;
                                    si32(2,_loc12_);
                                    si32(_loc15_,_loc12_ + 4);
                                    si32(_loc10_,_loc12_ + 8);
                                    _loc14_ = _loc3_;
                                 }
                              }
                           }
                        }
                        break;
                     }
                  }
               }
            }
         }
      }
      else
      {
         _loc12_ = li8(_loc15_ + 1);
         if(_loc12_ != 116)
         {
            _loc2_ -= 16;
            si32(0,_loc2_ + 4);
            si32(_loc3_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_substitution();
            _loc10_ = 1;
            _loc2_ += 16;
            _loc15_ = wdnative.eax;
         }
         else
         {
            _loc12_ = _loc15_ + 2;
            si32(_loc12_,_loc3_ + 12);
            _loc9_ = li32(_loc3_ + 20);
            var _temp_105:* = li32(_loc3_ + 24);
            _loc14_ = _loc10_ = 0;
            if(_loc9_ < _temp_105)
            {
               _loc15_ = li32(_loc3_ + 16);
               _loc12_ = _loc9_ + 1;
               si32(_loc12_,_loc3_ + 20);
               _loc9_ *= 12;
               _loc13_ = _loc15_ + _loc9_;
               _loc14_ = 0;
               if(_loc13_ != 0)
               {
                  _loc12_ = _loc15_ + _loc9_;
                  si32(0,_loc12_);
                  si32(wdnative_nternal.L__2E_str387,_loc12_ + 4);
                  si32(3,_loc12_ + 8);
                  _loc14_ = _loc13_;
               }
            }
            _loc2_ -= 16;
            si32(_loc3_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_unqualified_name();
            _loc2_ += 16;
            _loc9_ = wdnative.eax;
            _loc15_ = _loc10_;
            if(_loc14_ != 0)
            {
               _loc15_ = _loc10_;
               if(_loc9_ != 0)
               {
                  _loc11_ = li32(_loc3_ + 20);
                  var _temp_108:* = li32(_loc3_ + 24);
                  _loc15_ = 0;
                  if(_loc11_ < _temp_108)
                  {
                     _loc13_ = li32(_loc3_ + 16);
                     _loc12_ = _loc11_ + 1;
                     si32(_loc12_,_loc3_ + 20);
                     _loc11_ *= 12;
                     _loc1_ = _loc13_ + _loc11_;
                     _loc15_ = 0;
                     if(_loc1_ != 0)
                     {
                        _loc12_ = _loc13_ + _loc11_;
                        si32(1,_loc12_);
                        si32(_loc14_,_loc12_ + 4);
                        si32(_loc9_,_loc12_ + 8);
                        _loc15_ = _loc1_;
                     }
                  }
               }
            }
            _loc12_ = li32(_loc3_ + 48);
            _loc12_ = _loc12_ + 3;
            si32(_loc12_,_loc3_ + 48);
         }
         _loc12_ = li32(_loc3_ + 12);
         _loc12_ = li8(_loc12_);
         _loc14_ = _loc15_;
         if(_loc12_ == 73)
         {
            _loc9_ = 1;
            if(_loc15_ != 0)
            {
               _loc9_ = 0;
            }
            while(true)
            {
               if(_loc10_ == 0)
               {
                  _loc14_ = 0;
                  if(_loc15_ == 0)
                  {
                     break;
                  }
                  _loc10_ = li32(_loc3_ + 32);
                  var _temp_113:* = li32(_loc3_ + 36);
                  _loc14_ = 0;
                  if(_loc10_ >= _temp_113)
                  {
                     break;
                  }
                  var _temp_115:* = _loc10_ << 2;
                  var _temp_116:* = int((_loc12_ = li32(_loc3_ + 28)) + _temp_115);
                  si32(_loc15_,_temp_116);
                  _loc12_ = li32(_loc3_ + 32);
                  _loc12_ = _loc12_ + 1;
                  si32(_loc12_,_loc3_ + 32);
                  _loc9_ = 0;
               }
               _loc2_ -= 16;
               si32(_loc3_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_template_args();
               _loc14_ = 0;
               _loc2_ += 16;
               _loc10_ = wdnative.eax;
               if(_loc9_ == 0)
               {
                  if(_loc10_ != 0)
                  {
                     _loc13_ = li32(_loc3_ + 20);
                     var _temp_120:* = li32(_loc3_ + 24);
                     _loc14_ = 0;
                     if(_loc13_ < _temp_120)
                     {
                        _loc9_ = li32(_loc3_ + 16);
                        _loc12_ = _loc13_ + 1;
                        si32(_loc12_,_loc3_ + 20);
                        _loc13_ *= 12;
                        _loc3_ = _loc9_ + _loc13_;
                        _loc14_ = 0;
                        if(_loc3_ != 0)
                        {
                           _loc12_ = _loc9_ + _loc13_;
                           si32(4,_loc12_);
                           si32(_loc15_,_loc12_ + 4);
                           si32(_loc10_,_loc12_ + 8);
                           _loc14_ = _loc3_;
                        }
                     }
                  }
               }
               break;
            }
         }
      }
      addr0d9c:
      wdnative.eax = _loc14_;
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

