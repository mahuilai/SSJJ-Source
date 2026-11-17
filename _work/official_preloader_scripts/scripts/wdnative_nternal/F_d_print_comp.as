package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   
   public function F_d_print_comp() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc15_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc12_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc3_ -= 192;
      _loc4_ = li32(_loc5_);
      _loc17_ = li32(_loc4_ + 4);
      _loc16_ = li32(_loc5_ + 4);
      if(_loc16_ == 0)
      {
         if(_loc17_ != 0)
         {
            _loc3_ -= 16;
            si32(_loc17_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_idalloc();
            _loc3_ += 16;
         }
         si32(0,_loc4_ + 4);
      }
      else if(_loc17_ != 0)
      {
         _loc15_ = li32(_loc16_);
         if(_loc15_ <= 19)
         {
            if(_loc15_ <= 9)
            {
               if(_loc15_ <= 4)
               {
                  if(_loc15_ <= 2)
                  {
                     if(_loc15_ != 0)
                     {
                        var _loc14_:int = _loc15_ + -1;
                        if((uint(_loc14_)) >= 2)
                        {
                           addr6847:
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_idalloc();
                           _loc3_ += 16;
                           si32(0,_loc4_ + 4);
                        }
                        else
                        {
                           var _temp_8:* = li32(_loc16_ + 4);
                           _loc3_ -= 16;
                           si32(_temp_8,_loc3_ + 4);
                           si32(_loc4_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_d_print_comp();
                           _loc3_ += 16;
                           _loc17_ = li32(_loc4_ + 4);
                           _loc14_ = li8(_loc4_);
                           _loc14_ = _loc14_ & 4;
                           if(_loc14_ == 0)
                           {
                              if(_loc17_ != 0)
                              {
                                 _loc12_ = li32(_loc4_ + 12);
                                 _loc15_ = li32(_loc4_ + 8);
                                 _loc13_ = _loc15_ + 2;
                                 if((uint(_loc13_)) <= uint(_loc12_))
                                 {
                                    var _temp_14:* = int(_loc17_ + _loc15_);
                                    si16(14906,_temp_14);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 2;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 else
                                 {
                                    while(true)
                                    {
                                       if(uint(_loc12_) >= uint(_loc13_))
                                       {
                                          if(_loc17_ != 0)
                                          {
                                             var _temp_17:* = li32(_loc4_ + 8);
                                             var _temp_18:* = int(_loc17_ + _temp_17);
                                             si16(14906,_temp_18);
                                             _loc14_ = li32(_loc4_ + 8);
                                             _loc14_ = _loc14_ + 2;
                                             si32(_loc14_,_loc4_ + 8);
                                          }
                                          break;
                                       }
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       _loc12_ <<= 1;
                                       si32(_loc12_,_loc3_ + 4);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_realloc();
                                       _loc3_ += 16;
                                       _loc17_ = wdnative.eax;
                                       if(_loc17_ == 0)
                                       {
                                          _loc17_ = li32(_loc4_ + 4);
                                          if(_loc17_ != 0)
                                          {
                                             _loc3_ -= 16;
                                             si32(_loc17_,_loc3_);
                                             wdnative.ESP = _loc3_;
                                             wdnative_nternal.F_idalloc();
                                             _loc3_ += 16;
                                          }
                                          si32(0,_loc4_ + 4);
                                          si32(1,_loc4_ + 24);
                                          break;
                                       }
                                       si32(_loc17_,_loc4_ + 4);
                                       si32(_loc12_,_loc4_ + 12);
                                    }
                                 }
                              }
                           }
                           else if(_loc17_ != 0)
                           {
                              _loc13_ = li32(_loc4_ + 12);
                              _loc12_ = li32(_loc4_ + 8);
                              if((uint(_loc12_)) < uint(_loc13_))
                              {
                                 var _temp_27:* = int(_loc17_ + _loc12_);
                                 si8(46,_temp_27);
                                 _loc14_ = _loc12_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              else
                              {
                                 _loc12_ += 1;
                                 while(true)
                                 {
                                    if(uint(_loc13_) >= uint(_loc12_))
                                    {
                                       if(_loc17_ != 0)
                                       {
                                          var _temp_29:* = li32(_loc4_ + 8);
                                          var _temp_30:* = int(_loc17_ + _temp_29);
                                          si8(46,_temp_30);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                       }
                                       break;
                                    }
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    _loc13_ <<= 1;
                                    si32(_loc13_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc17_ = wdnative.eax;
                                    if(_loc17_ == 0)
                                    {
                                       _loc17_ = li32(_loc4_ + 4);
                                       if(_loc17_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break;
                                    }
                                    si32(_loc17_,_loc4_ + 4);
                                    si32(_loc13_,_loc4_ + 12);
                                 }
                              }
                           }
                           _loc14_ = li32(_loc16_ + 8);
                           _loc3_ -= 16;
                           si32(_loc14_,_loc3_ + 4);
                           si32(_loc4_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_d_print_comp();
                           _loc3_ += 16;
                        }
                     }
                     else
                     {
                        _loc14_ = li8(_loc4_);
                        _loc14_ = _loc14_ & 4;
                        if(_loc14_ == 0)
                        {
                           loop74:
                           while(true)
                           {
                              if(_loc17_ == 0)
                              {
                                 _loc13_ = li32(_loc4_ + 12);
                                 _loc12_ = li32(_loc4_ + 8);
                                 _loc15_ = li32(_loc16_ + 8);
                              }
                              else
                              {
                                 _loc12_ = li32(_loc4_ + 8);
                                 _loc15_ = li32(_loc16_ + 8);
                                 var _temp_42:* = int(_loc15_ + _loc12_);
                                 _loc13_ = li32(_loc4_ + 12);
                                 if(uint(_temp_42) <= uint(_loc13_))
                                 {
                                    var _temp_43:* = li32(_loc16_ + 4);
                                    _loc3_ -= 16;
                                    si32(_loc15_,_loc3_ + 8);
                                    si32(_temp_43,_loc3_ + 4);
                                    _loc14_ = _loc17_ + _loc12_;
                                    si32(_loc14_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative.Fmemcpy();
                                    _loc3_ += 16;
                                    var _temp_47:* = li32(_loc4_ + 8);
                                    _loc14_ = (_loc14_ = li32(_loc16_ + 8)) + _temp_47;
                                    si32(_loc14_,_loc4_ + 8);
                                    break;
                                 }
                              }
                              _loc10_ = _loc12_ + _loc15_;
                              _loc16_ = li32(_loc16_ + 4);
                              if(uint(_loc10_) > uint(_loc13_))
                              {
                                 while(true)
                                 {
                                    if(uint(_loc13_) < uint(_loc10_))
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       _loc13_ <<= 1;
                                       si32(_loc13_,_loc3_ + 4);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_realloc();
                                       _loc3_ += 16;
                                       _loc17_ = wdnative.eax;
                                       if(_loc17_ == 0)
                                       {
                                          _loc16_ = li32(_loc4_ + 4);
                                          if(_loc16_ != 0)
                                          {
                                             _loc3_ -= 16;
                                             si32(_loc16_,_loc3_);
                                             wdnative.ESP = _loc3_;
                                             wdnative_nternal.F_idalloc();
                                             _loc3_ += 16;
                                          }
                                          si32(0,_loc4_ + 4);
                                          si32(1,_loc4_ + 24);
                                          break loop74;
                                       }
                                       continue;
                                    }
                                    if(_loc17_ == 0)
                                    {
                                       break loop74;
                                    }
                                    _loc12_ = li32(_loc4_ + 8);
                                    si32(_loc17_,_loc4_ + 4);
                                    si32(_loc13_,_loc4_ + 12);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc16_,_loc3_ + 4);
                              _loc14_ = _loc17_ + _loc12_;
                              si32(_loc14_,_loc3_);
                              si32(_loc15_,_loc3_ + 8);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemcpy();
                              _loc3_ += 16;
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + _loc15_;
                              si32(_loc14_,_loc4_ + 8);
                              break;
                           }
                        }
                        else
                        {
                           _loc13_ = li32(_loc16_ + 8);
                           if(_loc13_ >= 1)
                           {
                              _loc17_ = li32(_loc16_ + 4);
                              _loc16_ = _loc17_ + _loc13_;
                              loop25:
                              do
                              {
                                 _loc14_ = _loc16_ - _loc17_;
                                 if(_loc14_ >= 4)
                                 {
                                    _loc14_ = li8(_loc17_);
                                    if(_loc14_ == 95)
                                    {
                                       _loc14_ = li8(_loc17_ + 1);
                                       if(_loc14_ == 95)
                                       {
                                          _loc14_ = li8(_loc17_ + 2);
                                          if(_loc14_ == 85)
                                          {
                                             _loc13_ = _loc17_ + 3;
                                             _loc12_ = 0;
                                             while(true)
                                             {
                                                if(uint(_loc13_) < uint(_loc16_))
                                                {
                                                   _loc15_ = si8(li8(_loc13_));
                                                   _loc14_ = _loc15_ + -48;
                                                   _loc14_ = _loc14_ & 0xFF;
                                                   if((uint(_loc14_)) <= 9)
                                                   {
                                                      _loc15_ += -48;
                                                      continue;
                                                   }
                                                   _loc14_ = _loc15_ + -65;
                                                   _loc14_ = _loc14_ & 0xFF;
                                                   if((uint(_loc14_)) <= 5)
                                                   {
                                                      _loc15_ += -55;
                                                      continue;
                                                   }
                                                   _loc14_ = _loc15_ + -97;
                                                   _loc14_ = _loc14_ & 0xFF;
                                                   if((uint(_loc14_)) <= 5)
                                                   {
                                                      _loc15_ += -87;
                                                      continue;
                                                   }
                                                   if(uint(_loc13_) < uint(_loc16_))
                                                   {
                                                      _loc14_ = _loc15_ & 0xFF;
                                                      if(_loc14_ == 95)
                                                      {
                                                         if(uint(_loc12_) <= 255)
                                                         {
                                                            _loc15_ = li32(_loc4_ + 4);
                                                            _loc17_ = _loc13_;
                                                            if(_loc15_ != 0)
                                                            {
                                                               _loc17_ = li32(_loc4_ + 12);
                                                               _loc10_ = li32(_loc4_ + 8);
                                                               if((uint(_loc10_)) < uint(_loc17_))
                                                               {
                                                                  var _temp_74:* = int(_loc15_ + _loc10_);
                                                                  si8(_loc12_,_temp_74);
                                                                  _loc14_ = _loc10_ + 1;
                                                                  si32(_loc14_,_loc4_ + 8);
                                                                  _loc17_ = _loc13_;
                                                               }
                                                               else
                                                               {
                                                                  _loc10_ += 1;
                                                                  while(uint(_loc17_) < uint(_loc10_))
                                                                  {
                                                                     _loc3_ -= 16;
                                                                     si32(_loc15_,_loc3_);
                                                                     _loc17_ <<= 1;
                                                                     si32(_loc17_,_loc3_ + 4);
                                                                     wdnative.ESP = _loc3_;
                                                                     wdnative_nternal.F_realloc();
                                                                     _loc3_ += 16;
                                                                     _loc15_ = wdnative.eax;
                                                                     if(_loc15_ == 0)
                                                                     {
                                                                        _loc17_ = li32(_loc4_ + 4);
                                                                        if(_loc17_ != 0)
                                                                        {
                                                                           _loc3_ -= 16;
                                                                           si32(_loc17_,_loc3_);
                                                                           wdnative.ESP = _loc3_;
                                                                           wdnative_nternal.F_idalloc();
                                                                           _loc3_ += 16;
                                                                        }
                                                                        si32(0,_loc4_ + 4);
                                                                        si32(1,_loc4_ + 24);
                                                                        _loc17_ = _loc13_;
                                                                        continue loop25;
                                                                     }
                                                                     si32(_loc15_,_loc4_ + 4);
                                                                     si32(_loc17_,_loc4_ + 12);
                                                                  }
                                                                  _loc17_ = _loc13_;
                                                                  if(_loc15_ != 0)
                                                                  {
                                                                     var _temp_81:* = li32(_loc4_ + 8);
                                                                     var _temp_82:* = int(_loc15_ + _temp_81);
                                                                     si8(_loc12_,_temp_82);
                                                                     _loc14_ = li32(_loc4_ + 8);
                                                                     _loc14_ = _loc14_ + 1;
                                                                     si32(_loc14_,_loc4_ + 8);
                                                                     _loc17_ = _loc13_;
                                                                  }
                                                               }
                                                            }
                                                            continue loop25;
                                                         }
                                                      }
                                                   }
                                                }
                                                _loc14_ = _loc12_ << 4;
                                                _loc12_ = _loc15_ + _loc14_;
                                                _loc13_ += 1;
                                             }
                                             continue;
                                          }
                                       }
                                    }
                                 }
                                 _loc13_ = li32(_loc4_ + 4);
                                 if(_loc13_ != 0)
                                 {
                                    _loc15_ = li8(_loc17_);
                                    _loc12_ = li32(_loc4_ + 12);
                                    _loc10_ = li32(_loc4_ + 8);
                                    if((uint(_loc10_)) < uint(_loc12_))
                                    {
                                       var _temp_87:* = int(_loc13_ + _loc10_);
                                       si8(_loc15_,_temp_87);
                                       _loc14_ = _loc10_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    else
                                    {
                                       _loc10_ += 1;
                                       while(uint(_loc12_) < uint(_loc10_))
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc13_,_loc3_);
                                          _loc12_ <<= 1;
                                          si32(_loc12_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc13_ = wdnative.eax;
                                          if(_loc13_ == 0)
                                          {
                                             _loc13_ = li32(_loc4_ + 4);
                                             if(_loc13_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc13_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             continue loop25;
                                          }
                                          si32(_loc13_,_loc4_ + 4);
                                          si32(_loc12_,_loc4_ + 12);
                                       }
                                       if(_loc13_ != 0)
                                       {
                                          var _temp_94:* = li32(_loc4_ + 8);
                                          var _temp_95:* = int(_loc13_ + _temp_94);
                                          si8(_loc15_,_temp_95);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                       }
                                    }
                                 }
                              }
                              while(_loc17_ += 1, (uint(_loc17_)) < uint(_loc16_));
                           }
                        }
                     }
                  }
                  else if(_loc15_ != 3)
                  {
                     if(_loc15_ != 4)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        _loc17_ = li32(_loc4_ + 20);
                        _loc13_ = 0;
                        si32(_loc13_,_loc4_ + 20);
                        var _temp_98:* = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_temp_98,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                        _loc12_ = li32(_loc4_ + 4);
                        if(_loc12_ != 0)
                        {
                           loop75:
                           while(true)
                           {
                              _loc15_ = li32(_loc4_ + 8);
                              if(_loc15_ != 0)
                              {
                                 _loc14_ = _loc15_ + _loc12_;
                                 var _temp_103:* = li8(_loc14_ - 1);
                                 _loc13_ = _loc15_;
                                 if(_temp_103 == 60)
                                 {
                                    _loc13_ = li32(_loc4_ + 12);
                                    while(true)
                                    {
                                       if(_loc12_ != 0)
                                       {
                                          if(uint(_loc15_) < uint(_loc13_))
                                          {
                                             var _temp_104:* = int(_loc12_ + _loc15_);
                                             si8(32,_temp_104);
                                             _loc13_ = _loc15_ + 1;
                                             si32(_loc13_,_loc4_ + 8);
                                             break;
                                          }
                                       }
                                       if(uint(_loc15_) >= uint(_loc13_))
                                       {
                                          _loc15_ += 1;
                                          while(true)
                                          {
                                             if(uint(_loc13_) < uint(_loc15_))
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc12_,_loc3_);
                                                _loc13_ <<= 1;
                                                si32(_loc13_,_loc3_ + 4);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_realloc();
                                                _loc3_ += 16;
                                                _loc12_ = wdnative.eax;
                                                if(_loc12_ == 0)
                                                {
                                                   _loc13_ = li32(_loc4_ + 4);
                                                   if(_loc13_ != 0)
                                                   {
                                                      _loc3_ -= 16;
                                                      si32(_loc13_,_loc3_);
                                                      wdnative.ESP = _loc3_;
                                                      wdnative_nternal.F_idalloc();
                                                      _loc3_ += 16;
                                                   }
                                                   si32(0,_loc4_ + 4);
                                                   si32(1,_loc4_ + 24);
                                                   break loop75;
                                                }
                                                continue;
                                             }
                                             if(_loc12_ == 0)
                                             {
                                                break loop75;
                                             }
                                             _loc15_ = li32(_loc4_ + 8);
                                             si32(_loc12_,_loc4_ + 4);
                                             si32(_loc13_,_loc4_ + 12);
                                          }
                                          break loop75;
                                       }
                                       _loc14_ = _loc12_ + _loc15_;
                                       si8(32,_loc14_);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc13_ = _loc14_ + 1;
                                       si32(_loc13_,_loc4_ + 8);
                                       break;
                                    }
                                 }
                              }
                              _loc12_ = li32(_loc4_ + 4);
                              if(_loc12_ != 0)
                              {
                                 _loc15_ = li32(_loc4_ + 12);
                                 if(uint(_loc13_) < uint(_loc15_))
                                 {
                                    var _temp_114:* = int(_loc12_ + _loc13_);
                                    si8(60,_temp_114);
                                    _loc14_ = _loc13_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                    break;
                                 }
                                 _loc13_ += 1;
                                 while(true)
                                 {
                                    if(uint(_loc15_) >= uint(_loc13_))
                                    {
                                       if(_loc12_ != 0)
                                       {
                                          var _temp_116:* = li32(_loc4_ + 8);
                                          var _temp_117:* = int(_loc12_ + _temp_116);
                                          si8(60,_temp_117);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                       }
                                       break loop75;
                                    }
                                    _loc3_ -= 16;
                                    si32(_loc12_,_loc3_);
                                    _loc15_ <<= 1;
                                    si32(_loc15_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc12_ = wdnative.eax;
                                    if(_loc12_ == 0)
                                    {
                                       _loc13_ = li32(_loc4_ + 4);
                                       if(_loc13_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc13_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break loop75;
                                    }
                                    si32(_loc12_,_loc4_ + 4);
                                    si32(_loc15_,_loc4_ + 12);
                                 }
                              }
                              break;
                           }
                        }
                        _loc14_ = li32(_loc16_ + 8);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                        _loc16_ = li32(_loc4_ + 4);
                        if(_loc16_ != 0)
                        {
                           _loc12_ = li32(_loc4_ + 8);
                           _loc13_ = 0;
                           loop77:
                           while(true)
                           {
                              if(_loc12_ != 0)
                              {
                                 _loc14_ = _loc12_ + _loc16_;
                                 var _temp_128:* = li8(_loc14_ - 1);
                                 _loc13_ = _loc12_;
                                 if(_temp_128 == 62)
                                 {
                                    _loc13_ = li32(_loc4_ + 12);
                                    while(true)
                                    {
                                       if(_loc16_ != 0)
                                       {
                                          if(uint(_loc12_) < uint(_loc13_))
                                          {
                                             var _temp_129:* = int(_loc16_ + _loc12_);
                                             si8(32,_temp_129);
                                             _loc13_ = _loc12_ + 1;
                                             si32(_loc13_,_loc4_ + 8);
                                             break;
                                          }
                                       }
                                       if(uint(_loc12_) >= uint(_loc13_))
                                       {
                                          _loc12_ += 1;
                                          while(true)
                                          {
                                             if(uint(_loc13_) < uint(_loc12_))
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc16_,_loc3_);
                                                _loc13_ <<= 1;
                                                si32(_loc13_,_loc3_ + 4);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_realloc();
                                                _loc3_ += 16;
                                                _loc16_ = wdnative.eax;
                                                if(_loc16_ == 0)
                                                {
                                                   _loc16_ = li32(_loc4_ + 4);
                                                   if(_loc16_ != 0)
                                                   {
                                                      _loc3_ -= 16;
                                                      si32(_loc16_,_loc3_);
                                                      wdnative.ESP = _loc3_;
                                                      wdnative_nternal.F_idalloc();
                                                      _loc3_ += 16;
                                                   }
                                                   si32(0,_loc4_ + 4);
                                                   si32(1,_loc4_ + 24);
                                                   break loop77;
                                                }
                                                continue;
                                             }
                                             if(_loc16_ == 0)
                                             {
                                                break loop77;
                                             }
                                             _loc12_ = li32(_loc4_ + 8);
                                             si32(_loc16_,_loc4_ + 4);
                                             si32(_loc13_,_loc4_ + 12);
                                          }
                                          break loop77;
                                       }
                                       _loc14_ = _loc16_ + _loc12_;
                                       si8(32,_loc14_);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc13_ = _loc14_ + 1;
                                       si32(_loc13_,_loc4_ + 8);
                                       break;
                                    }
                                 }
                              }
                              _loc16_ = li32(_loc4_ + 4);
                              if(_loc16_ != 0)
                              {
                                 _loc12_ = li32(_loc4_ + 12);
                                 if(uint(_loc13_) < uint(_loc12_))
                                 {
                                    var _temp_139:* = int(_loc16_ + _loc13_);
                                    si8(62,_temp_139);
                                    _loc14_ = _loc13_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                    break;
                                 }
                                 _loc13_ += 1;
                                 while(true)
                                 {
                                    if(uint(_loc12_) >= uint(_loc13_))
                                    {
                                       if(_loc16_ != 0)
                                       {
                                          var _temp_141:* = li32(_loc4_ + 8);
                                          var _temp_142:* = int(_loc16_ + _temp_141);
                                          si8(62,_temp_142);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                       }
                                       break loop77;
                                    }
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    _loc12_ <<= 1;
                                    si32(_loc12_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc16_ = wdnative.eax;
                                    if(_loc16_ == 0)
                                    {
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc16_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break loop77;
                                    }
                                    si32(_loc16_,_loc4_ + 4);
                                    si32(_loc12_,_loc4_ + 12);
                                 }
                              }
                              break;
                           }
                        }
                        si32(_loc17_,_loc4_ + 20);
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 20);
                     _loc1_ = 0;
                     _loc6_ = _loc13_;
                     _loc15_ = 0;
                     _loc7_ = _loc16_;
                     var _temp_153:*;
                     var _temp_150:*;
                     var _temp_151:*;
                     var _temp_152:*;
                     var _temp_154:*;
                     var _temp_155:*;
                     var _temp_156:*;
                     var _temp_157:*;
                     var _temp_158:*;
                     var _temp_160:*;
                     var _temp_161:*;
                     var _loc11_:int;
                     var _loc8_:int;
                     do
                     {
                        _loc12_ = _loc5_ - 64;
                        _loc7_ = li32(_loc7_ + 4);
                        if(_loc7_ == 0)
                        {
                           _loc2_ = li32(_loc7_);
                           _loc10_ = _loc7_;
                           break;
                        }
                        if(uint(_loc15_) < 4)
                        {
                           continue;
                        }
                        if(_loc17_ != 0)
                        {
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_idalloc();
                           _loc3_ += 16;
                        }
                        si32(0,_loc4_ + 4);
                     }
                     while(var _temp_153:* = int(_loc12_ + _loc1_), var _temp_150:* = _loc15_ << 4, _loc14_ = _loc12_ + _temp_150, _loc11_ = _loc15_ << 2, _loc15_ += 1, var _temp_151:* = _loc11_ << 2, var _temp_152:* = int(_loc12_ + _temp_151), si32(_loc6_,_temp_152), si32(_temp_153,_loc4_ + 20), var _temp_154:* = _loc11_ << 2, var _temp_155:* = int(_loc12_ + _temp_154), si32(_loc7_,_temp_155 + 4), var _temp_156:* = _loc11_ << 2, var _temp_157:* = int(_loc12_ + _temp_156), si32(0,_temp_157 + 8), var _temp_158:* = _loc11_ << 2, var _temp_160:* = int(_loc12_ + _temp_158), si32(_loc8_ = li32(_loc4_ + 16),_temp_160 + 12), _loc1_ += 16, _loc2_ = li32(_loc7_), var _temp_161:* = int(_loc2_ + -25), _loc6_ = _loc14_, _loc10_ = _loc7_, uint(_temp_161) <= 2);
                     if(_loc2_ == 4)
                     {
                        _loc14_ = li32(_loc4_ + 16);
                        si32(_loc14_,_loc5_ - 72);
                        _loc14_ = _loc5_ - 72;
                        si32(_loc14_,_loc4_ + 16);
                        var _temp_166:* = _loc14_ | 4;
                        si32(_loc7_,_temp_166);
                        _loc2_ = li32(_loc7_);
                     }
                     if(_loc2_ == 2)
                     {
                        var _temp_167:* = _loc15_ << 4;
                        _loc2_ = _loc12_ + _temp_167;
                        _loc7_ += 8;
                        while(true)
                        {
                           _loc7_ = li32(_loc7_);
                           _loc14_ = li32(_loc7_);
                           _loc14_ = _loc14_ + -25;
                           if((uint(_loc14_)) < 3)
                           {
                              if(uint(_loc15_) >= 4)
                              {
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 break;
                              }
                              continue;
                           }
                           var _temp_171:* = int(_loc2_ + -16);
                           si32(_loc11_ = li32(_loc2_ - 12),_loc2_ + 4);
                           _loc11_ = li32(_loc2_ - 8);
                           si32(_loc11_,_loc2_ + 8);
                           _loc11_ = li32(_loc2_ - 4);
                           si32(_loc11_,_loc2_ + 12);
                           si32(_temp_171,_loc2_);
                           si32(_loc2_,_loc4_ + 20);
                           si32(_loc7_,_loc2_ - 12);
                           si32(0,_loc2_ - 8);
                           _loc14_ = li32(_loc4_ + 16);
                           si32(_loc14_,_loc2_ - 4);
                           _loc2_ += 16;
                           _loc15_ += 1;
                           _loc7_ += 4;
                        }
                        §§goto(addr686f);
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc14_ = li32(_loc10_);
                     if(_loc14_ == 4)
                     {
                        _loc14_ = li32(_loc5_ - 72);
                        si32(_loc14_,_loc4_ + 16);
                     }
                     if(_loc15_ != 0)
                     {
                        do
                        {
                           _loc14_ = _loc15_ << 4;
                           _loc14_ = _loc12_ + _loc14_;
                           _loc14_ = li32(_loc14_ - 8);
                           if(_loc14_ == 0)
                           {
                              _loc16_ = li32(_loc4_ + 4);
                              if(_loc16_ != 0)
                              {
                                 _loc17_ = li32(_loc4_ + 12);
                                 _loc10_ = li32(_loc4_ + 8);
                                 if((uint(_loc10_)) < uint(_loc17_))
                                 {
                                    var _temp_186:* = int(_loc16_ + _loc10_);
                                    si8(32,_temp_186);
                                    _loc14_ = _loc10_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 else
                                 {
                                    _loc10_ += 1;
                                    for(; uint(_loc17_) < uint(_loc10_); si32(_loc16_,_loc4_ + 4),si32(_loc17_,_loc4_ + 12))
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc16_,_loc3_);
                                       _loc17_ <<= 1;
                                       si32(_loc17_,_loc3_ + 4);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_realloc();
                                       _loc3_ += 16;
                                       _loc16_ = wdnative.eax;
                                       if(_loc16_ != 0)
                                       {
                                          continue;
                                       }
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc16_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                    }
                                    if(_loc16_ != 0)
                                    {
                                       var _temp_193:* = li32(_loc4_ + 8);
                                       var _temp_194:* = int(_loc16_ + _temp_193);
                                       si8(32,_temp_194);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                 }
                              }
                              _loc14_ = _loc15_ << 2;
                              _loc14_ = _loc14_ << 2;
                              _loc14_ = _loc12_ + _loc14_;
                              _loc14_ = li32(_loc14_ - 12);
                              _loc3_ -= 16;
                              si32(_loc14_,_loc3_ + 4);
                              si32(_loc4_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_d_print_mod();
                              _loc3_ += 16;
                           }
                        }
                        while(_loc15_ += -1, _loc15_ != 0);
                     }
                     si32(_loc13_,_loc4_ + 20);
                  }
               }
               else if(_loc15_ <= 6)
               {
                  if(_loc15_ != 5)
                  {
                     if(_loc15_ != 6)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        var _temp_200:* = li32(_loc16_ + 8);
                        _loc3_ -= 16;
                        si32(_temp_200,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                     }
                  }
                  else
                  {
                     _loc12_ = li32(_loc4_ + 16);
                     if(_loc12_ == 0)
                     {
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_idalloc();
                        _loc3_ += 16;
                        si32(0,_loc4_ + 4);
                     }
                     else
                     {
                        _loc13_ = li32(_loc12_ + 4);
                        _loc16_ = li32(_loc16_ + 4);
                        while(true)
                        {
                           _loc13_ = li32(_loc13_ + 8);
                           if(_loc13_ != 0)
                           {
                              _loc14_ = li32(_loc13_);
                              if(_loc14_ != 39)
                              {
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 break;
                              }
                              if(_loc16_ >= 1)
                              {
                                 continue;
                              }
                              if(_loc16_ == 0)
                              {
                                 if(_loc13_ != 0)
                                 {
                                    _loc14_ = li32(_loc12_);
                                    si32(_loc14_,_loc4_ + 16);
                                    var _temp_208:* = li32(_loc13_ + 4);
                                    _loc3_ -= 16;
                                    si32(_temp_208,_loc3_ + 4);
                                    si32(_loc4_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_d_print_comp();
                                    _loc3_ += 16;
                                    si32(_loc12_,_loc4_ + 16);
                                    break;
                                 }
                              }
                           }
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           break;
                           _loc16_ += -1;
                        }
                     }
                  }
               }
               else if(_loc15_ != 7)
               {
                  if(_loc15_ != 8)
                  {
                     if(_loc15_ != 9)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 8;
                        if((uint(_loc12_)) <= uint(_loc13_))
                        {
                           _loc14_ = _loc17_ + _loc15_;
                           si32(544370534,_loc14_ + 4);
                           si32(542397526,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 8;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc13_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_215:* = li32(_loc4_ + 8);
                                    _loc14_ = _loc17_ + _temp_215;
                                    si32(544370534,_loc14_ + 4);
                                    si32(542397526,_loc14_);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 8;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc13_ <<= 1;
                              si32(_loc13_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                        }
                        _loc14_ = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     _loc12_ = _loc15_ + 11;
                     if((uint(_loc12_)) <= uint(_loc13_))
                     {
                        _loc14_ = _loc17_ + _loc15_;
                        si8(32,_loc14_ + 10);
                        si16(29295,_loc14_ + 8);
                        si32(1713399148,_loc14_ + 4);
                        si32(1650553974,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 11;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_228:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_228;
                                 si8(32,_loc14_ + 10);
                                 si16(29295,_loc14_ + 8);
                                 si32(1713399148,_loc14_ + 4);
                                 si32(1650553974,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 11;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  _loc13_ = li32(_loc4_ + 12);
                  _loc12_ = li32(_loc4_ + 8);
                  if((uint(_loc12_)) < uint(_loc13_))
                  {
                     var _temp_238:* = int(_loc17_ + _loc12_);
                     si8(126,_temp_238);
                     _loc14_ = _loc12_ + 1;
                     si32(_loc14_,_loc4_ + 8);
                  }
                  else
                  {
                     _loc12_ += 1;
                     while(true)
                     {
                        if(uint(_loc13_) >= uint(_loc12_))
                        {
                           if(_loc17_ != 0)
                           {
                              var _temp_240:* = li32(_loc4_ + 8);
                              var _temp_241:* = int(_loc17_ + _temp_240);
                              si8(126,_temp_241);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           break;
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        _loc13_ <<= 1;
                        si32(_loc13_,_loc3_ + 4);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_realloc();
                        _loc3_ += 16;
                        _loc17_ = wdnative.eax;
                        if(_loc17_ == 0)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           si32(1,_loc4_ + 24);
                           break;
                        }
                        si32(_loc17_,_loc4_ + 4);
                        si32(_loc13_,_loc4_ + 12);
                     }
                  }
                  _loc14_ = li32(_loc16_ + 8);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
               }
            }
            else if(_loc15_ <= 14)
            {
               if(_loc15_ <= 11)
               {
                  if(_loc15_ != 10)
                  {
                     if(_loc15_ != 11)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 13;
                        if((uint(_loc12_)) <= uint(_loc13_))
                        {
                           _loc14_ = _loc17_ + _loc15_;
                           si8(32,_loc14_ + 12);
                           si32(1919903264,_loc14_ + 8);
                           si32(1868983913,_loc14_ + 4);
                           si32(1701869940,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 13;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc13_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_254:* = li32(_loc4_ + 8);
                                    _loc14_ = _loc17_ + _temp_254;
                                    si8(32,_loc14_ + 12);
                                    si32(1919903264,_loc14_ + 8);
                                    si32(1868983913,_loc14_ + 4);
                                    si32(1701869940,_loc14_);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 13;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc13_ <<= 1;
                              si32(_loc13_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                        }
                        _loc14_ = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc12_ = li32(_loc4_ + 8);
                     _loc15_ = _loc12_ + 24;
                     if((uint(_loc15_)) <= uint(_loc13_))
                     {
                        _loc14_ = _loc17_ + _loc12_;
                        si32(544370534,_loc14_ + 20);
                        si32(543517794,_loc14_ + 16);
                        si32(1635022368,_loc14_ + 12);
                        si32(1852795252,_loc14_ + 8);
                        si32(1668641396,_loc14_ + 4);
                        si32(1936617315,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 24;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc15_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_267:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_267;
                                 si32(544370534,_loc14_ + 20);
                                 si32(543517794,_loc14_ + 16);
                                 si32(1635022368,_loc14_ + 12);
                                 si32(1852795252,_loc14_ + 8);
                                 si32(1668641396,_loc14_ + 4);
                                 si32(1936617315,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 24;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc13_ = li32(_loc4_ + 4);
                     if(_loc13_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 4;
                        if((uint(_loc12_)) <= uint(_loc17_))
                        {
                           var _temp_279:* = int(_loc13_ + _loc15_);
                           si32(762210605,_temp_279);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 4;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc12_))
                              {
                                 if(_loc13_ != 0)
                                 {
                                    var _temp_282:* = li32(_loc4_ + 8);
                                    var _temp_283:* = int(_loc13_ + _temp_282);
                                    si32(762210605,_temp_283);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 4;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc13_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc13_ = wdnative.eax;
                              if(_loc13_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc13_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else if(_loc15_ != 12)
               {
                  if(_loc15_ != 13)
                  {
                     if(_loc15_ != 14)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 21;
                        if((uint(_loc12_)) <= uint(_loc13_))
                        {
                           _loc14_ = _loc17_ + _loc15_;
                           si8(32,_loc14_ + 20);
                           si32(1869881451,_loc14_ + 16);
                           si32(1853188212,_loc14_ + 12);
                           si32(543973749,_loc14_ + 8);
                           si32(1953655158,_loc14_ + 4);
                           si32(762212206,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 21;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc13_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_296:* = li32(_loc4_ + 8);
                                    _loc14_ = _loc17_ + _temp_296;
                                    si8(32,_loc14_ + 20);
                                    si32(1869881451,_loc14_ + 16);
                                    si32(1853188212,_loc14_ + 12);
                                    si32(543973749,_loc14_ + 8);
                                    si32(1953655158,_loc14_ + 4);
                                    si32(762212206,_loc14_);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 21;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc13_ <<= 1;
                              si32(_loc13_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                        }
                        _loc14_ = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     _loc12_ = _loc15_ + 16;
                     if((uint(_loc12_)) <= uint(_loc13_))
                     {
                        _loc14_ = _loc17_ + _loc15_;
                        si32(544370534,_loc14_ + 12);
                        si32(544106016,_loc14_ + 8);
                        si32(1868983913,_loc14_ + 4);
                        si32(1701869940,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 16;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_309:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_309;
                                 si32(544370534,_loc14_ + 12);
                                 si32(544106016,_loc14_ + 8);
                                 si32(1868983913,_loc14_ + 4);
                                 si32(1701869940,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 16;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  _loc13_ = li32(_loc4_ + 12);
                  _loc12_ = li32(_loc4_ + 8);
                  _loc15_ = _loc12_ + 18;
                  if((uint(_loc15_)) <= uint(_loc13_))
                  {
                     _loc14_ = _loc17_ + _loc12_;
                     si16(8306,_loc14_ + 16);
                     si32(1868963941,_loc14_ + 12);
                     si32(1835101728,_loc14_ + 8);
                     si32(1868983913,_loc14_ + 4);
                     si32(1701869940,_loc14_);
                     _loc14_ = li32(_loc4_ + 8);
                     _loc14_ = _loc14_ + 18;
                     si32(_loc14_,_loc4_ + 8);
                  }
                  else
                  {
                     while(true)
                     {
                        if(uint(_loc13_) >= uint(_loc15_))
                        {
                           if(_loc17_ != 0)
                           {
                              var _temp_322:* = li32(_loc4_ + 8);
                              _loc14_ = _loc17_ + _temp_322;
                              si16(8306,_loc14_ + 16);
                              si32(1868963941,_loc14_ + 12);
                              si32(1835101728,_loc14_ + 8);
                              si32(1868983913,_loc14_ + 4);
                              si32(1701869940,_loc14_);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 18;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           break;
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        _loc13_ <<= 1;
                        si32(_loc13_,_loc3_ + 4);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_realloc();
                        _loc3_ += 16;
                        _loc17_ = wdnative.eax;
                        if(_loc17_ == 0)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           si32(1,_loc4_ + 24);
                           break;
                        }
                        si32(_loc17_,_loc4_ + 4);
                        si32(_loc13_,_loc4_ + 12);
                     }
                  }
                  _loc14_ = li32(_loc16_ + 4);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
               }
            }
            else if(_loc15_ <= 16)
            {
               if(_loc15_ != 15)
               {
                  if(_loc15_ != 16)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     _loc12_ = _loc15_ + 26;
                     if((uint(_loc12_)) <= uint(_loc13_))
                     {
                        _loc14_ = _loc17_ + _loc15_;
                        si16(8303,_loc14_ + 24);
                        si32(1948281710,_loc14_ + 20);
                        si32(1969779744,_loc14_ + 16);
                        si32(1852994932,_loc14_ + 12);
                        si32(1701978228,_loc14_ + 8);
                        si32(1851877746,_loc14_ + 4);
                        si32(1635151715,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 26;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_335:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_335;
                                 si16(8303,_loc14_ + 24);
                                 si32(1948281710,_loc14_ + 20);
                                 si32(1969779744,_loc14_ + 16);
                                 si32(1852994932,_loc14_ + 12);
                                 si32(1701978228,_loc14_ + 8);
                                 si32(1851877746,_loc14_ + 4);
                                 si32(1635151715,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 26;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  _loc13_ = li32(_loc4_ + 12);
                  _loc15_ = li32(_loc4_ + 8);
                  _loc12_ = _loc15_ + 17;
                  if((uint(_loc12_)) <= uint(_loc13_))
                  {
                     _loc14_ = _loc17_ + _loc15_;
                     si8(32,_loc14_ + 16);
                     si32(1869881451,_loc14_ + 12);
                     si32(1853188212,_loc14_ + 8);
                     si32(543973749,_loc14_ + 4);
                     si32(1953655158,_loc14_);
                     _loc14_ = li32(_loc4_ + 8);
                     _loc14_ = _loc14_ + 17;
                     si32(_loc14_,_loc4_ + 8);
                  }
                  else
                  {
                     while(true)
                     {
                        if(uint(_loc13_) >= uint(_loc12_))
                        {
                           if(_loc17_ != 0)
                           {
                              var _temp_348:* = li32(_loc4_ + 8);
                              _loc14_ = _loc17_ + _temp_348;
                              si8(32,_loc14_ + 16);
                              si32(1869881451,_loc14_ + 12);
                              si32(1853188212,_loc14_ + 8);
                              si32(543973749,_loc14_ + 4);
                              si32(1953655158,_loc14_);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 17;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           break;
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        _loc13_ <<= 1;
                        si32(_loc13_,_loc3_ + 4);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_realloc();
                        _loc3_ += 16;
                        _loc17_ = wdnative.eax;
                        if(_loc17_ == 0)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           si32(1,_loc4_ + 24);
                           break;
                        }
                        si32(_loc17_,_loc4_ + 4);
                        si32(_loc13_,_loc4_ + 12);
                     }
                  }
                  _loc14_ = li32(_loc16_ + 4);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
               }
            }
            else if(_loc15_ != 17)
            {
               if(_loc15_ != 18)
               {
                  if(_loc15_ != 19)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     _loc15_ = li32(_loc4_ + 12);
                     _loc12_ = li32(_loc4_ + 8);
                     _loc13_ = _loc12_ + 24;
                     if((uint(_loc13_)) <= uint(_loc15_))
                     {
                        _loc14_ = _loc17_ + _loc12_;
                        si32(544370534,_loc14_ + 20);
                        si32(544830049,_loc14_ + 16);
                        si32(1919905901,_loc14_ + 12);
                        si32(1702109285,_loc14_ + 8);
                        si32(1668179314,_loc14_ + 4);
                        si32(1701209458,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 24;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc15_) >= uint(_loc13_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_361:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_361;
                                 si32(544370534,_loc14_ + 20);
                                 si32(544830049,_loc14_ + 16);
                                 si32(1919905901,_loc14_ + 12);
                                 si32(1702109285,_loc14_ + 8);
                                 si32(1668179314,_loc14_ + 4);
                                 si32(1701209458,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 24;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc15_ <<= 1;
                           si32(_loc15_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc15_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  _loc15_ = li32(_loc4_ + 12);
                  _loc12_ = li32(_loc4_ + 8);
                  _loc13_ = _loc12_ + 19;
                  if((uint(_loc13_)) <= uint(_loc15_))
                  {
                     _loc14_ = _loc17_ + _loc12_;
                     si8(32,_loc14_ + 18);
                     si16(29295,_loc14_ + 16);
                     si32(1713399148,_loc14_ + 12);
                     si32(1650551154,_loc14_ + 8);
                     si32(1635131492,_loc14_ + 4);
                     si32(1918989671,_loc14_);
                     _loc14_ = li32(_loc4_ + 8);
                     _loc14_ = _loc14_ + 19;
                     si32(_loc14_,_loc4_ + 8);
                  }
                  else
                  {
                     while(true)
                     {
                        if(uint(_loc15_) >= uint(_loc13_))
                        {
                           if(_loc17_ != 0)
                           {
                              var _temp_374:* = li32(_loc4_ + 8);
                              _loc14_ = _loc17_ + _temp_374;
                              si8(32,_loc14_ + 18);
                              si16(29295,_loc14_ + 16);
                              si32(1713399148,_loc14_ + 12);
                              si32(1650551154,_loc14_ + 8);
                              si32(1635131492,_loc14_ + 4);
                              si32(1918989671,_loc14_);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 19;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           break;
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        _loc15_ <<= 1;
                        si32(_loc15_,_loc3_ + 4);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_realloc();
                        _loc3_ += 16;
                        _loc17_ = wdnative.eax;
                        if(_loc17_ == 0)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           si32(1,_loc4_ + 24);
                           break;
                        }
                        si32(_loc17_,_loc4_ + 4);
                        si32(_loc15_,_loc4_ + 12);
                     }
                  }
                  _loc14_ = li32(_loc16_ + 4);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
               }
            }
            else
            {
               _loc12_ = li32(_loc4_ + 12);
               _loc15_ = li32(_loc4_ + 8);
               _loc13_ = _loc15_ + 15;
               if((uint(_loc13_)) <= uint(_loc12_))
               {
                  _loc14_ = _loc17_ + _loc15_;
                  si8(32,_loc14_ + 14);
                  si16(29295,_loc14_ + 12);
                  si32(1713402739,_loc14_ + 8);
                  si32(1634485024,_loc14_ + 4);
                  si32(1635148138,_loc14_);
                  _loc14_ = li32(_loc4_ + 8);
                  _loc14_ = _loc14_ + 15;
                  si32(_loc14_,_loc4_ + 8);
               }
               else
               {
                  while(true)
                  {
                     if(uint(_loc12_) >= uint(_loc13_))
                     {
                        if(_loc17_ != 0)
                        {
                           var _temp_387:* = li32(_loc4_ + 8);
                           _loc14_ = _loc17_ + _temp_387;
                           si8(32,_loc14_ + 14);
                           si16(29295,_loc14_ + 12);
                           si32(1713402739,_loc14_ + 8);
                           si32(1634485024,_loc14_ + 4);
                           si32(1635148138,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 15;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc17_,_loc3_);
                     _loc12_ <<= 1;
                     si32(_loc12_,_loc3_ + 4);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_realloc();
                     _loc3_ += 16;
                     _loc17_ = wdnative.eax;
                     if(_loc17_ == 0)
                     {
                        _loc17_ = li32(_loc4_ + 4);
                        if(_loc17_ != 0)
                        {
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_idalloc();
                           _loc3_ += 16;
                        }
                        si32(0,_loc4_ + 4);
                        si32(1,_loc4_ + 24);
                        break;
                     }
                     si32(_loc17_,_loc4_ + 4);
                     si32(_loc12_,_loc4_ + 12);
                  }
               }
               _loc14_ = li32(_loc16_ + 4);
               _loc3_ -= 16;
               si32(_loc14_,_loc3_ + 4);
               si32(_loc4_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_d_print_comp();
               _loc3_ += 16;
            }
         }
         else if(_loc15_ <= 37)
         {
            if(_loc15_ <= 32)
            {
               if(_loc15_ <= 21)
               {
                  if(_loc15_ != 20)
                  {
                     if(_loc15_ != 21)
                     {
                        §§goto(addr6847);
                     }
                     else
                     {
                        _loc10_ = li32(_loc4_ + 8);
                        _loc13_ = li32(_loc16_ + 8);
                        _loc12_ = _loc13_ + _loc10_;
                        _loc15_ = li32(_loc4_ + 12);
                        if(uint(_loc12_) <= uint(_loc15_))
                        {
                           var _temp_397:* = li32(_loc16_ + 4);
                           _loc3_ -= 16;
                           si32(_loc13_,_loc3_ + 8);
                           si32(_temp_397,_loc3_ + 4);
                           _loc14_ = _loc17_ + _loc10_;
                           si32(_loc14_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.Fmemcpy();
                           _loc3_ += 16;
                           var _temp_401:* = li32(_loc4_ + 8);
                           _loc14_ = (_loc14_ = li32(_loc16_ + 8)) + _temp_401;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc16_ = li32(_loc16_ + 4);
                           while(true)
                           {
                              if(uint(_loc15_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_403:* = li32(_loc4_ + 8);
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_ + 4);
                                    _loc14_ = _loc17_ + _temp_403;
                                    si32(_loc14_,_loc3_);
                                    si32(_loc13_,_loc3_ + 8);
                                    wdnative.ESP = _loc3_;
                                    wdnative.Fmemcpy();
                                    _loc3_ += 16;
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + _loc13_;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc15_ <<= 1;
                              si32(_loc15_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc15_,_loc4_ + 12);
                           }
                        }
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     _loc12_ = _loc15_ + 17;
                     if((uint(_loc12_)) <= uint(_loc13_))
                     {
                        _loc14_ = _loc17_ + _loc15_;
                        si8(32,_loc14_ + 16);
                        si32(1919903264,_loc14_ + 12);
                        si32(1935763820,_loc14_ + 8);
                        si32(1629515365,_loc14_ + 4);
                        si32(1684302184,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 17;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_417:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_417;
                                 si8(32,_loc14_ + 16);
                                 si32(1919903264,_loc14_ + 12);
                                 si32(1935763820,_loc14_ + 8);
                                 si32(1629515365,_loc14_ + 4);
                                 si32(1684302184,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 17;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  loop79:
                  while(true)
                  {
                     _loc14_ = _loc15_ + -22;
                     if((uint(_loc14_)) < 3)
                     {
                        _loc13_ = _loc4_ + 20;
                        while(true)
                        {
                           _loc13_ = li32(_loc13_);
                           if(_loc13_ != 0)
                           {
                              _loc14_ = li32(_loc13_ + 8);
                              if(_loc14_ != 0)
                              {
                                 continue;
                              }
                              _loc14_ = li32(_loc13_ + 4);
                              _loc17_ = li32(_loc14_);
                              _loc14_ = _loc17_ + -22;
                              if((uint(_loc14_)) <= 2)
                              {
                                 if(_loc17_ == _loc15_)
                                 {
                                    var _temp_433:* = li32(_loc16_ + 4);
                                    _loc3_ -= 16;
                                    si32(_temp_433,_loc3_ + 4);
                                    si32(_loc4_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_d_print_comp();
                                    _loc3_ += 16;
                                    break loop79;
                                 }
                                 continue;
                              }
                           }
                        }
                        break;
                     }
                     _loc14_ = _loc15_ + -25;
                     if((uint(_loc14_)) >= 8)
                     {
                        §§goto(addr6847);
                     }
                     _loc14_ = li32(_loc4_ + 20);
                     si32(_loc14_,_loc5_ - 88);
                     _loc14_ = _loc5_ - 88;
                     si32(_loc14_,_loc4_ + 20);
                     _loc14_ |= 4;
                     si32(_loc16_,_loc14_);
                     si32(0,_loc5_ - 80);
                     _loc14_ = li32(_loc4_ + 16);
                     si32(_loc14_,_loc5_ - 76);
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc14_ = li32(_loc5_ - 80);
                     if(_loc14_ == 0)
                     {
                        _loc3_ -= 16;
                        si32(_loc16_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_mod();
                        _loc3_ += 16;
                     }
                     _loc14_ = li32(_loc5_ - 88);
                     si32(_loc14_,_loc4_ + 20);
                     break;
                  }
               }
            }
            else if(_loc15_ <= 34)
            {
               if(_loc15_ != 33)
               {
                  if(_loc15_ != 34)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     var _temp_442:* = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_temp_442,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
               else
               {
                  _loc12_ = li32(_loc16_ + 4);
                  _loc13_ = li32(_loc4_ + 8);
                  _loc14_ = li8(_loc4_);
                  _loc14_ = _loc14_ & 4;
                  if(_loc14_ == 0)
                  {
                     _loc10_ = li32(_loc12_ + 4);
                     _loc7_ = _loc10_ + _loc13_;
                     _loc15_ = li32(_loc4_ + 12);
                     if(uint(_loc7_) <= uint(_loc15_))
                     {
                        var _temp_447:* = li32(_loc12_);
                        _loc3_ -= 16;
                        si32(_loc10_,_loc3_ + 8);
                        si32(_temp_447,_loc3_ + 4);
                        _loc14_ = _loc17_ + _loc13_;
                        si32(_loc14_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative.Fmemcpy();
                        _loc3_ += 16;
                        var _temp_452:* = li32(_loc4_ + 8);
                        _loc14_ = (_loc11_ = li32((_loc11_ = li32(_loc16_ + 4)) + 4)) + _temp_452;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        _loc16_ = li32(_loc12_);
                        while(true)
                        {
                           if(uint(_loc15_) >= uint(_loc7_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_454:* = li32(_loc4_ + 8);
                                 _loc3_ -= 16;
                                 si32(_loc16_,_loc3_ + 4);
                                 _loc14_ = _loc17_ + _temp_454;
                                 si32(_loc14_,_loc3_);
                                 si32(_loc10_,_loc3_ + 8);
                                 wdnative.ESP = _loc3_;
                                 wdnative.Fmemcpy();
                                 _loc3_ += 16;
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + _loc10_;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc15_ <<= 1;
                           si32(_loc15_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc16_ = li32(_loc4_ + 4);
                              if(_loc16_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc16_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc15_,_loc4_ + 12);
                        }
                     }
                  }
                  else
                  {
                     _loc7_ = li32(_loc12_ + 12);
                     _loc10_ = _loc7_ + _loc13_;
                     _loc15_ = li32(_loc4_ + 12);
                     if(uint(_loc10_) <= uint(_loc15_))
                     {
                        var _temp_465:* = li32(_loc12_ + 8);
                        _loc3_ -= 16;
                        si32(_loc7_,_loc3_ + 8);
                        si32(_temp_465,_loc3_ + 4);
                        _loc14_ = _loc17_ + _loc13_;
                        si32(_loc14_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative.Fmemcpy();
                        _loc3_ += 16;
                        var _temp_470:* = li32(_loc4_ + 8);
                        _loc14_ = (_loc11_ = li32((_loc11_ = li32(_loc16_ + 4)) + 12)) + _temp_470;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        _loc16_ = li32(_loc12_ + 8);
                        while(true)
                        {
                           if(uint(_loc15_) >= uint(_loc10_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_472:* = li32(_loc4_ + 8);
                                 _loc3_ -= 16;
                                 si32(_loc16_,_loc3_ + 4);
                                 _loc14_ = _loc17_ + _temp_472;
                                 si32(_loc14_,_loc3_);
                                 si32(_loc7_,_loc3_ + 8);
                                 wdnative.ESP = _loc3_;
                                 wdnative.Fmemcpy();
                                 _loc3_ += 16;
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + _loc7_;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc15_ <<= 1;
                           si32(_loc15_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc16_ = li32(_loc4_ + 4);
                              if(_loc16_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc16_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc15_,_loc4_ + 12);
                        }
                     }
                  }
               }
            }
            else if(_loc15_ != 35)
            {
               if(_loc15_ != 36)
               {
                  if(_loc15_ != 37)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     _loc14_ = li32(_loc4_ + 20);
                     si32(_loc14_,_loc5_ - 184);
                     _loc14_ = _loc5_ - 184;
                     si32(_loc14_,_loc4_ + 20);
                     var _temp_484:* = _loc14_ | 4;
                     si32(_loc16_,_temp_484);
                     si32(0,_loc5_ - 176);
                     _loc14_ = li32(_loc4_ + 16);
                     si32(_loc14_,_loc5_ - 172);
                     var _temp_486:* = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_temp_486,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc14_ = li32(_loc5_ - 176);
                     if(_loc14_ == 0)
                     {
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc17_ = li32(_loc4_ + 12);
                           _loc12_ = li32(_loc4_ + 8);
                           if((uint(_loc12_)) < uint(_loc17_))
                           {
                              var _temp_491:* = int(_loc13_ + _loc12_);
                              si8(32,_temp_491);
                              _loc14_ = _loc12_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           else
                           {
                              _loc12_ += 1;
                              while(true)
                              {
                                 if(uint(_loc17_) >= uint(_loc12_))
                                 {
                                    if(_loc13_ != 0)
                                    {
                                       var _temp_493:* = li32(_loc4_ + 8);
                                       var _temp_494:* = int(_loc13_ + _temp_493);
                                       si8(32,_temp_494);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    break;
                                 }
                                 _loc3_ -= 16;
                                 si32(_loc13_,_loc3_);
                                 _loc17_ <<= 1;
                                 si32(_loc17_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc13_ = wdnative.eax;
                                 if(_loc13_ == 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break;
                                 }
                                 si32(_loc13_,_loc4_ + 4);
                                 si32(_loc17_,_loc4_ + 12);
                              }
                           }
                        }
                        _loc14_ = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc12_ = li32(_loc4_ + 12);
                           _loc16_ = li32(_loc4_ + 8);
                           _loc17_ = _loc16_ + 3;
                           if((uint(_loc17_)) <= uint(_loc12_))
                           {
                              _loc14_ = _loc13_ + _loc16_;
                              si8(42,_loc14_ + 2);
                              si16(14906,_loc14_);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 3;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           else
                           {
                              while(true)
                              {
                                 if(uint(_loc12_) >= uint(_loc17_))
                                 {
                                    if(_loc13_ != 0)
                                    {
                                       var _temp_508:* = li32(_loc4_ + 8);
                                       _loc14_ = _loc13_ + _temp_508;
                                       si8(42,_loc14_ + 2);
                                       si16(14906,_loc14_);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 3;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    break;
                                 }
                                 _loc3_ -= 16;
                                 si32(_loc13_,_loc3_);
                                 _loc12_ <<= 1;
                                 si32(_loc12_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc13_ = wdnative.eax;
                                 if(_loc13_ == 0)
                                 {
                                    _loc16_ = li32(_loc4_ + 4);
                                    if(_loc16_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc16_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break;
                                 }
                                 si32(_loc13_,_loc4_ + 4);
                                 si32(_loc12_,_loc4_ + 12);
                              }
                           }
                        }
                     }
                     _loc14_ = li32(_loc5_ - 184);
                     si32(_loc14_,_loc4_ + 20);
                  }
               }
               else
               {
                  _loc12_ = li32(_loc4_ + 20);
                  si32(_loc12_,_loc5_ - 168);
                  _loc17_ = _loc5_ - 168;
                  si32(_loc17_,_loc4_ + 20);
                  var _temp_519:* = _loc17_ | 4;
                  si32(_loc16_,_temp_519);
                  si32(0,_loc5_ - 160);
                  _loc14_ = li32(_loc4_ + 16);
                  si32(_loc14_,_loc5_ - 156);
                  _loc13_ = 1;
                  _loc15_ = _loc12_;
                  while(true)
                  {
                     if(_loc15_ != 0)
                     {
                        _loc14_ = li32(_loc15_ + 4);
                        _loc14_ = li32(_loc14_);
                        _loc14_ = _loc14_ + -22;
                        if((uint(_loc14_)) < 3)
                        {
                           _loc14_ = li32(_loc15_ + 8);
                           if(_loc14_ == 0)
                           {
                              if(uint(_loc13_) >= 4)
                              {
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 break;
                              }
                              var _temp_527:* = _loc13_ << 4;
                              _loc14_ = _loc17_ + _temp_527;
                              _loc11_ = li32(_loc15_);
                              si32(_loc11_,_loc14_);
                              var _temp_530:* = _loc14_ | 4;
                              si32(_loc8_ = li32(_loc15_ + 4),_temp_530);
                              _loc11_ = li32(_loc15_ + 8);
                              si32(_loc11_,_loc14_ + 8);
                              _loc11_ = li32(_loc15_ + 12);
                              si32(_loc11_,_loc14_ + 12);
                              _loc11_ = li32(_loc4_ + 20);
                              si32(_loc11_,_loc14_);
                              si32(_loc14_,_loc4_ + 20);
                              si32(1,_loc15_ + 8);
                              _loc13_ += 1;
                           }
                           continue;
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     si32(_loc12_,_loc4_ + 20);
                     _loc14_ = li32(_loc5_ - 160);
                     if(_loc14_ == 0)
                     {
                        if(uint(_loc13_) >= 2)
                        {
                           do
                           {
                              _loc14_ = _loc13_ << 4;
                              _loc14_ = _loc17_ + _loc14_;
                              _loc14_ = li32(_loc14_ - 12);
                              _loc3_ -= 16;
                              si32(_loc14_,_loc3_ + 4);
                              si32(_loc4_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_d_print_mod();
                              _loc3_ += 16;
                           }
                           while(_loc13_ += -1, _loc13_ != 1);
                           _loc12_ = li32(_loc4_ + 20);
                        }
                        _loc3_ -= 16;
                        si32(_loc12_,_loc3_ + 8);
                        si32(_loc16_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_array_type();
                        _loc3_ += 16;
                     }
                     break;
                     _loc15_ = li32(_loc15_);
                  }
               }
            }
            else
            {
               _loc14_ = li8(_loc4_);
               _loc14_ = _loc14_ & 0x20;
               if(_loc14_ != 0)
               {
                  var _temp_542:* = li32(_loc4_ + 20);
                  _loc3_ -= 16;
                  si32(_temp_542,_loc3_ + 8);
                  si32(_loc16_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_function_type();
                  _loc3_ += 16;
               }
               while(true)
               {
                  _loc14_ = li32(_loc16_ + 4);
                  if(_loc14_ != 0)
                  {
                     _loc14_ = li32(_loc4_ + 20);
                     si32(_loc14_,_loc5_ - 104);
                     _loc14_ = _loc5_ - 104;
                     si32(_loc14_,_loc4_ + 20);
                     var _temp_547:* = _loc14_ | 4;
                     si32(_loc16_,_temp_547);
                     si32(0,_loc5_ - 96);
                     _loc14_ = li32(_loc4_ + 16);
                     si32(_loc14_,_loc5_ - 92);
                     var _temp_549:* = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_temp_549,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc14_ = li32(_loc5_ - 104);
                     si32(_loc14_,_loc4_ + 20);
                     _loc14_ = li32(_loc5_ - 96);
                     if(_loc14_ != 0)
                     {
                        break;
                     }
                     _loc14_ = li8(_loc4_);
                     _loc14_ = _loc14_ & 0x20;
                     if(_loc14_ == 0)
                     {
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc17_ = li32(_loc4_ + 12);
                           _loc12_ = li32(_loc4_ + 8);
                           if((uint(_loc12_)) < uint(_loc17_))
                           {
                              var _temp_557:* = int(_loc13_ + _loc12_);
                              si8(32,_temp_557);
                              _loc14_ = _loc12_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           else
                           {
                              _loc12_ += 1;
                              while(true)
                              {
                                 if(uint(_loc17_) >= uint(_loc12_))
                                 {
                                    if(_loc13_ != 0)
                                    {
                                       var _temp_559:* = li32(_loc4_ + 8);
                                       var _temp_560:* = int(_loc13_ + _temp_559);
                                       si8(32,_temp_560);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    break;
                                 }
                                 _loc3_ -= 16;
                                 si32(_loc13_,_loc3_);
                                 _loc17_ <<= 1;
                                 si32(_loc17_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc13_ = wdnative.eax;
                                 if(_loc13_ == 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break;
                                 }
                                 si32(_loc13_,_loc4_ + 4);
                                 si32(_loc17_,_loc4_ + 12);
                              }
                           }
                        }
                     }
                  }
                  _loc14_ = li8(_loc4_);
                  _loc14_ = _loc14_ & 0x20;
                  if(_loc14_ == 0)
                  {
                     var _temp_570:* = li32(_loc4_ + 20);
                     _loc3_ -= 16;
                     si32(_temp_570,_loc3_ + 8);
                     si32(_loc16_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_function_type();
                     _loc3_ += 16;
                  }
                  break;
               }
            }
         }
         else if(_loc15_ <= 43)
         {
            if(_loc15_ <= 40)
            {
               _loc14_ = _loc15_ + -38;
               if((uint(_loc14_)) >= 2)
               {
                  if(_loc15_ != 40)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     _loc12_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     _loc13_ = _loc15_ + 8;
                     if((uint(_loc13_)) <= uint(_loc12_))
                     {
                        _loc14_ = _loc17_ + _loc15_;
                        si32(1919906913,_loc14_ + 4);
                        si32(1919250543,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 8;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc12_) >= uint(_loc13_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_577:* = li32(_loc4_ + 8);
                                 _loc14_ = _loc17_ + _temp_577;
                                 si32(1919906913,_loc14_ + 4);
                                 si32(1919250543,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 8;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc12_ <<= 1;
                           si32(_loc12_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc12_,_loc4_ + 12);
                        }
                     }
                     loop81:
                     while(true)
                     {
                        _loc14_ = li32(_loc16_ + 4);
                        _loc14_ = li32(_loc14_ + 4);
                        _loc14_ = li8(_loc14_);
                        _loc14_ = _loc14_ + -97;
                        _loc14_ = _loc14_ & 0xFF;
                        if((uint(_loc14_)) <= 25)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ == 0)
                           {
                              break;
                           }
                           _loc13_ = li32(_loc4_ + 12);
                           _loc12_ = li32(_loc4_ + 8);
                           if((uint(_loc12_)) >= uint(_loc13_))
                           {
                              _loc12_ += 1;
                              while(true)
                              {
                                 if(uint(_loc13_) < uint(_loc12_))
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    _loc13_ <<= 1;
                                    si32(_loc13_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc17_ = wdnative.eax;
                                    if(_loc17_ == 0)
                                    {
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc16_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break loop81;
                                    }
                                    continue;
                                 }
                                 if(_loc17_ == 0)
                                 {
                                    break loop81;
                                 }
                                 var _temp_594:* = li32(_loc4_ + 8);
                                 var _temp_595:* = int(_loc17_ + _temp_594);
                                 si8(32,_temp_595);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                                 si32(_loc17_,_loc4_ + 4);
                                 si32(_loc13_,_loc4_ + 12);
                              }
                              break;
                           }
                           var _temp_592:* = int(_loc17_ + _loc12_);
                           si8(32,_temp_592);
                           _loc14_ = _loc12_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc10_ = li32(_loc4_ + 8);
                           _loc7_ = li32(_loc16_ + 4);
                           _loc15_ = li32(_loc7_ + 8);
                           _loc12_ = _loc15_ + _loc10_;
                           _loc17_ = li32(_loc4_ + 12);
                           if(uint(_loc12_) <= uint(_loc17_))
                           {
                              var _temp_606:* = li32(_loc7_ + 4);
                              _loc3_ -= 16;
                              si32(_loc15_,_loc3_ + 8);
                              si32(_temp_606,_loc3_ + 4);
                              _loc14_ = _loc13_ + _loc10_;
                              si32(_loc14_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative.Fmemcpy();
                              _loc3_ += 16;
                              var _temp_611:* = li32(_loc4_ + 8);
                              _loc14_ = (_loc11_ = li32((_loc11_ = li32(_loc16_ + 4)) + 8)) + _temp_611;
                              si32(_loc14_,_loc4_ + 8);
                              break;
                           }
                           _loc16_ = li32(_loc7_ + 4);
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc12_))
                              {
                                 if(_loc13_ != 0)
                                 {
                                    var _temp_613:* = li32(_loc4_ + 8);
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_ + 4);
                                    _loc14_ = _loc13_ + _temp_613;
                                    si32(_loc14_,_loc3_);
                                    si32(_loc15_,_loc3_ + 8);
                                    wdnative.ESP = _loc3_;
                                    wdnative.Fmemcpy();
                                    _loc3_ += 16;
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + _loc15_;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break loop81;
                              }
                              _loc3_ -= 16;
                              si32(_loc13_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc13_ = wdnative.eax;
                              if(_loc13_ == 0)
                              {
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break loop81;
                              }
                              si32(_loc13_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                        break;
                     }
                  }
               }
               else
               {
                  var _temp_623:* = li32(_loc16_ + 4);
                  _loc3_ -= 16;
                  si32(_temp_623,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
                  _loc14_ = li32(_loc16_ + 8);
                  if(_loc14_ != 0)
                  {
                     _loc13_ = li32(_loc4_ + 4);
                     if(_loc13_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 2;
                        if((uint(_loc12_)) <= uint(_loc17_))
                        {
                           var _temp_629:* = int(_loc13_ + _loc15_);
                           si16(8236,_temp_629);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 2;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc12_))
                              {
                                 if(_loc13_ != 0)
                                 {
                                    var _temp_632:* = li32(_loc4_ + 8);
                                    var _temp_633:* = int(_loc13_ + _temp_632);
                                    si16(8236,_temp_633);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 2;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc13_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc13_ = wdnative.eax;
                              if(_loc13_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc13_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                  }
               }
            }
            else if(_loc15_ != 41)
            {
               if(_loc15_ != 42)
               {
                  if(_loc15_ != 43)
                  {
                     §§goto(addr6847);
                  }
                  else
                  {
                     _loc13_ = li32(_loc16_ + 4);
                     _loc14_ = li32(_loc13_);
                     if(_loc14_ != 42)
                     {
                        _loc3_ -= 16;
                        si32(_loc13_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_expr_op();
                        _loc3_ += 16;
                        addr45ac:
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc17_ = li32(_loc4_ + 12);
                           _loc12_ = li32(_loc4_ + 8);
                           if((uint(_loc12_)) < uint(_loc17_))
                           {
                              var _temp_647:* = int(_loc13_ + _loc12_);
                              si8(40,_temp_647);
                              _loc14_ = _loc12_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           else
                           {
                              _loc12_ += 1;
                              while(true)
                              {
                                 if(uint(_loc17_) >= uint(_loc12_))
                                 {
                                    if(_loc13_ != 0)
                                    {
                                       var _temp_649:* = li32(_loc4_ + 8);
                                       var _temp_650:* = int(_loc13_ + _temp_649);
                                       si8(40,_temp_650);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    break;
                                 }
                                 _loc3_ -= 16;
                                 si32(_loc13_,_loc3_);
                                 _loc17_ <<= 1;
                                 si32(_loc17_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc13_ = wdnative.eax;
                                 if(_loc13_ == 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break;
                                 }
                                 si32(_loc13_,_loc4_ + 4);
                                 si32(_loc17_,_loc4_ + 12);
                              }
                           }
                        }
                     }
                     else
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc12_ = li32(_loc4_ + 8);
                        if((uint(_loc12_)) < uint(_loc13_))
                        {
                           var _temp_659:* = int(_loc17_ + _loc12_);
                           si8(40,_temp_659);
                           _loc14_ = _loc12_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc12_ += 1;
                           while(true)
                           {
                              if(uint(_loc13_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_661:* = li32(_loc4_ + 8);
                                    var _temp_662:* = int(_loc17_ + _temp_661);
                                    si8(40,_temp_662);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc13_ <<= 1;
                              si32(_loc13_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                        }
                        _loc14_ = li32(_loc16_ + 4);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_cast();
                        _loc3_ += 16;
                        _loc13_ = li32(_loc4_ + 4);
                        if(_loc13_ != 0)
                        {
                           _loc17_ = li32(_loc4_ + 12);
                           _loc12_ = li32(_loc4_ + 8);
                           if((uint(_loc12_)) < uint(_loc17_))
                           {
                              var _temp_673:* = int(_loc13_ + _loc12_);
                              si8(41,_temp_673);
                              _loc14_ = _loc12_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                              §§goto(addr45ac);
                           }
                           else
                           {
                              _loc12_ += 1;
                              while(true)
                              {
                                 if(uint(_loc17_) < uint(_loc12_))
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc13_,_loc3_);
                                    _loc17_ <<= 1;
                                    si32(_loc17_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc13_ = wdnative.eax;
                                    if(_loc13_ == 0)
                                    {
                                       _loc17_ = li32(_loc4_ + 4);
                                       if(_loc17_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break;
                                    }
                                    continue;
                                 }
                                 if(_loc13_ == 0)
                                 {
                                    break;
                                 }
                                 var _temp_675:* = li32(_loc4_ + 8);
                                 var _temp_676:* = int(_loc13_ + _temp_675);
                                 si8(41,_temp_676);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                                 §§goto(addr45ac);
                                 si32(_loc13_,_loc4_ + 4);
                                 si32(_loc17_,_loc4_ + 12);
                              }
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc16_ = li32(_loc4_ + 4);
                     if(_loc16_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc13_ = li32(_loc4_ + 8);
                        if((uint(_loc13_)) < uint(_loc17_))
                        {
                           var _temp_687:* = int(_loc16_ + _loc13_);
                           si8(41,_temp_687);
                           _loc14_ = _loc13_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc13_ += 1;
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc13_))
                              {
                                 if(_loc16_ != 0)
                                 {
                                    var _temp_689:* = li32(_loc4_ + 8);
                                    var _temp_690:* = int(_loc16_ + _temp_689);
                                    si8(41,_temp_690);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc16_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc16_ = wdnative.eax;
                              if(_loc16_ == 0)
                              {
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc16_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                  }
               }
               else
               {
                  _loc15_ = li32(_loc4_ + 12);
                  _loc12_ = li32(_loc4_ + 8);
                  _loc13_ = _loc12_ + 9;
                  if((uint(_loc13_)) <= uint(_loc15_))
                  {
                     _loc14_ = _loc17_ + _loc12_;
                     si8(32,_loc14_ + 8);
                     si32(1919906913,_loc14_ + 4);
                     si32(1919250543,_loc14_);
                     _loc14_ = li32(_loc4_ + 8);
                     _loc14_ = _loc14_ + 9;
                     si32(_loc14_,_loc4_ + 8);
                  }
                  else
                  {
                     while(true)
                     {
                        if(uint(_loc15_) >= uint(_loc13_))
                        {
                           if(_loc17_ != 0)
                           {
                              var _temp_702:* = li32(_loc4_ + 8);
                              _loc14_ = _loc17_ + _temp_702;
                              si8(32,_loc14_ + 8);
                              si32(1919906913,_loc14_ + 4);
                              si32(1919250543,_loc14_);
                              _loc14_ = li32(_loc4_ + 8);
                              _loc14_ = _loc14_ + 9;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           break;
                        }
                        _loc3_ -= 16;
                        si32(_loc17_,_loc3_);
                        _loc15_ <<= 1;
                        si32(_loc15_,_loc3_ + 4);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_realloc();
                        _loc3_ += 16;
                        _loc17_ = wdnative.eax;
                        if(_loc17_ == 0)
                        {
                           _loc17_ = li32(_loc4_ + 4);
                           if(_loc17_ != 0)
                           {
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_idalloc();
                              _loc3_ += 16;
                           }
                           si32(0,_loc4_ + 4);
                           si32(1,_loc4_ + 24);
                           break;
                        }
                        si32(_loc17_,_loc4_ + 4);
                        si32(_loc15_,_loc4_ + 12);
                     }
                  }
                  _loc3_ -= 16;
                  si32(_loc16_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_cast();
                  _loc3_ += 16;
               }
            }
            else
            {
               _loc15_ = li32(_loc4_ + 12);
               _loc12_ = li32(_loc4_ + 8);
               _loc13_ = _loc12_ + 9;
               if((uint(_loc13_)) <= uint(_loc15_))
               {
                  _loc14_ = _loc17_ + _loc12_;
                  si8(32,_loc14_ + 8);
                  si32(1919906913,_loc14_ + 4);
                  si32(1919250543,_loc14_);
                  _loc14_ = li32(_loc4_ + 8);
                  _loc14_ = _loc14_ + 9;
                  si32(_loc14_,_loc4_ + 8);
               }
               else
               {
                  while(true)
                  {
                     if(uint(_loc15_) >= uint(_loc13_))
                     {
                        if(_loc17_ != 0)
                        {
                           var _temp_715:* = li32(_loc4_ + 8);
                           _loc14_ = _loc17_ + _temp_715;
                           si8(32,_loc14_ + 8);
                           si32(1919906913,_loc14_ + 4);
                           si32(1919250543,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 9;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        break;
                     }
                     _loc3_ -= 16;
                     si32(_loc17_,_loc3_);
                     _loc15_ <<= 1;
                     si32(_loc15_,_loc3_ + 4);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_realloc();
                     _loc3_ += 16;
                     _loc17_ = wdnative.eax;
                     if(_loc17_ == 0)
                     {
                        _loc17_ = li32(_loc4_ + 4);
                        if(_loc17_ != 0)
                        {
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_idalloc();
                           _loc3_ += 16;
                        }
                        si32(0,_loc4_ + 4);
                        si32(1,_loc4_ + 24);
                        break;
                     }
                     si32(_loc17_,_loc4_ + 4);
                     si32(_loc15_,_loc4_ + 12);
                  }
               }
               _loc14_ = li32(_loc16_ + 8);
               _loc3_ -= 16;
               si32(_loc14_,_loc3_ + 4);
               si32(_loc4_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_d_print_comp();
               _loc3_ += 16;
            }
         }
         else if(_loc15_ <= 45)
         {
            if(_loc15_ != 44)
            {
               if(_loc15_ != 45)
               {
                  §§goto(addr6847);
               }
               else
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_idalloc();
                  _loc3_ += 16;
                  si32(0,_loc4_ + 4);
               }
            }
            else
            {
               _loc14_ = li32(_loc16_ + 8);
               _loc14_ = li32(_loc14_);
               if(_loc14_ != 45)
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_idalloc();
                  _loc3_ += 16;
                  si32(0,_loc4_ + 4);
               }
               else
               {
                  loop82:
                  while(true)
                  {
                     _loc13_ = li32(_loc16_ + 4);
                     _loc14_ = li32(_loc13_);
                     if(_loc14_ == 40)
                     {
                        _loc13_ = li32(_loc13_ + 4);
                        _loc14_ = li32(_loc13_ + 8);
                        if(_loc14_ == 1)
                        {
                           _loc14_ = li32(_loc13_ + 4);
                           _loc14_ = li8(_loc14_);
                           if(_loc14_ == 62)
                           {
                              _loc13_ = li32(_loc4_ + 12);
                              _loc12_ = li32(_loc4_ + 8);
                              while(true)
                              {
                                 if(_loc17_ != 0)
                                 {
                                    if(uint(_loc12_) < uint(_loc13_))
                                    {
                                       var _temp_734:* = int(_loc17_ + _loc12_);
                                       si8(40,_temp_734);
                                       _loc14_ = _loc12_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                       break;
                                    }
                                 }
                                 if(uint(_loc12_) >= uint(_loc13_))
                                 {
                                    _loc12_ += 1;
                                    while(true)
                                    {
                                       if(uint(_loc13_) < uint(_loc12_))
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          _loc13_ <<= 1;
                                          si32(_loc13_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc17_ = wdnative.eax;
                                          if(_loc17_ == 0)
                                          {
                                             _loc17_ = li32(_loc4_ + 4);
                                             if(_loc17_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc17_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break loop82;
                                          }
                                          continue;
                                       }
                                       if(_loc17_ == 0)
                                       {
                                          break loop82;
                                       }
                                       _loc12_ = li32(_loc4_ + 8);
                                       si32(_loc17_,_loc4_ + 4);
                                       si32(_loc13_,_loc4_ + 12);
                                    }
                                    break loop82;
                                 }
                                 _loc14_ = _loc17_ + _loc12_;
                                 si8(40,_loc14_);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                                 break;
                              }
                           }
                        }
                     }
                     _loc17_ = li32(_loc4_ + 4);
                     if(_loc17_ != 0)
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc12_ = li32(_loc4_ + 8);
                        if((uint(_loc12_)) < uint(_loc13_))
                        {
                           var _temp_745:* = int(_loc17_ + _loc12_);
                           si8(40,_temp_745);
                           _loc14_ = _loc12_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                           break;
                        }
                        _loc12_ += 1;
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_747:* = li32(_loc4_ + 8);
                                 var _temp_748:* = int(_loc17_ + _temp_747);
                                 si8(40,_temp_748);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break loop82;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break loop82;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                     break;
                  }
                  _loc14_ = li32(_loc16_ + 8);
                  _loc14_ = li32(_loc14_ + 4);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
                  _loc12_ = li32(_loc4_ + 4);
                  if(_loc12_ != 0)
                  {
                     _loc15_ = li32(_loc4_ + 12);
                     _loc17_ = li32(_loc4_ + 8);
                     _loc13_ = _loc17_ + 2;
                     if((uint(_loc13_)) <= uint(_loc15_))
                     {
                        var _temp_761:* = int(_loc12_ + _loc17_);
                        si16(8233,_temp_761);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 2;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc15_) >= uint(_loc13_))
                           {
                              if(_loc12_ != 0)
                              {
                                 var _temp_764:* = li32(_loc4_ + 8);
                                 var _temp_765:* = int(_loc12_ + _temp_764);
                                 si16(8233,_temp_765);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 2;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc12_,_loc3_);
                           _loc15_ <<= 1;
                           si32(_loc15_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc12_ = wdnative.eax;
                           if(_loc12_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc12_,_loc4_ + 4);
                           si32(_loc15_,_loc4_ + 12);
                        }
                     }
                  }
                  _loc14_ = li32(_loc16_ + 4);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_expr_op();
                  _loc3_ += 16;
                  _loc12_ = li32(_loc4_ + 4);
                  if(_loc12_ != 0)
                  {
                     _loc15_ = li32(_loc4_ + 12);
                     _loc13_ = li32(_loc4_ + 8);
                     _loc17_ = _loc13_ + 2;
                     if((uint(_loc17_)) <= uint(_loc15_))
                     {
                        var _temp_777:* = int(_loc12_ + _loc13_);
                        si16(10272,_temp_777);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 2;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        while(true)
                        {
                           if(uint(_loc15_) >= uint(_loc17_))
                           {
                              if(_loc12_ != 0)
                              {
                                 var _temp_780:* = li32(_loc4_ + 8);
                                 var _temp_781:* = int(_loc12_ + _temp_780);
                                 si16(10272,_temp_781);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 2;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc12_,_loc3_);
                           _loc15_ <<= 1;
                           si32(_loc15_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc12_ = wdnative.eax;
                           if(_loc12_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc12_,_loc4_ + 4);
                           si32(_loc15_,_loc4_ + 12);
                        }
                     }
                  }
                  _loc14_ = li32(_loc16_ + 8);
                  _loc14_ = li32(_loc14_ + 8);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F_d_print_comp();
                  _loc3_ += 16;
                  _loc17_ = li32(_loc4_ + 4);
                  if(_loc17_ != 0)
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc12_ = li32(_loc4_ + 8);
                     if((uint(_loc12_)) < uint(_loc13_))
                     {
                        var _temp_793:* = int(_loc17_ + _loc12_);
                        si8(41,_temp_793);
                        _loc14_ = _loc12_ + 1;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        _loc12_ += 1;
                        while(true)
                        {
                           if(uint(_loc13_) >= uint(_loc12_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_795:* = li32(_loc4_ + 8);
                                 var _temp_796:* = int(_loc17_ + _temp_795);
                                 si8(41,_temp_796);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc13_ <<= 1;
                           si32(_loc13_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc13_,_loc4_ + 12);
                        }
                     }
                  }
                  _loc16_ = li32(_loc16_ + 4);
                  _loc14_ = li32(_loc16_);
                  if(_loc14_ == 40)
                  {
                     _loc16_ = li32(_loc16_ + 4);
                     _loc14_ = li32(_loc16_ + 8);
                     if(_loc14_ == 1)
                     {
                        _loc14_ = li32(_loc16_ + 4);
                        _loc14_ = li8(_loc14_);
                        if(_loc14_ == 62)
                        {
                           _loc16_ = li32(_loc4_ + 4);
                           if(_loc16_ != 0)
                           {
                              _loc17_ = li32(_loc4_ + 12);
                              _loc13_ = li32(_loc4_ + 8);
                              if((uint(_loc13_)) < uint(_loc17_))
                              {
                                 var _temp_812:* = int(_loc16_ + _loc13_);
                                 si8(41,_temp_812);
                                 _loc14_ = _loc13_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              else
                              {
                                 _loc13_ += 1;
                                 while(true)
                                 {
                                    if(uint(_loc17_) >= uint(_loc13_))
                                    {
                                       if(_loc16_ != 0)
                                       {
                                          var _temp_814:* = li32(_loc4_ + 8);
                                          var _temp_815:* = int(_loc16_ + _temp_814);
                                          si8(41,_temp_815);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                       }
                                       break;
                                    }
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    _loc17_ <<= 1;
                                    si32(_loc17_,_loc3_ + 4);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_realloc();
                                    _loc3_ += 16;
                                    _loc16_ = wdnative.eax;
                                    if(_loc16_ == 0)
                                    {
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc16_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                       si32(0,_loc4_ + 4);
                                       si32(1,_loc4_ + 24);
                                       break;
                                    }
                                    si32(_loc16_,_loc4_ + 4);
                                    si32(_loc17_,_loc4_ + 12);
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         else if(_loc15_ != 46)
         {
            _loc14_ = _loc15_ + -47;
            if((uint(_loc14_)) >= 2)
            {
               _loc14_ = _loc15_ + -49;
               if((uint(_loc14_)) >= 2)
               {
                  §§goto(addr6847);
               }
               else
               {
                  _loc12_ = li32(_loc16_ + 4);
                  var _temp_826:* = li32(_loc12_);
                  _loc13_ = 0;
                  loop84:
                  while(true)
                  {
                     if(_temp_826 == 33)
                     {
                        _loc14_ = li32(_loc12_ + 4);
                        _loc12_ = li32(_loc14_ + 16);
                        if(_loc12_ != 7)
                        {
                           var _temp_829:* = int(_loc12_ + -1);
                           _loc13_ = _loc12_;
                           if(uint(_temp_829) <= 5)
                           {
                              _loc14_ = li32(_loc16_ + 8);
                              var _temp_831:* = li32(_loc14_);
                              _loc13_ = _loc12_;
                              if(_temp_831 == 0)
                              {
                                 if(_loc15_ == 50)
                                 {
                                    _loc13_ = li32(_loc4_ + 12);
                                    _loc15_ = li32(_loc4_ + 8);
                                    if((uint(_loc15_)) < uint(_loc13_))
                                    {
                                       var _temp_833:* = int(_loc17_ + _loc15_);
                                       si8(45,_temp_833);
                                       _loc14_ = _loc15_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    else
                                    {
                                       _loc15_ += 1;
                                       while(true)
                                       {
                                          if(uint(_loc13_) >= uint(_loc15_))
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_835:* = li32(_loc4_ + 8);
                                                var _temp_836:* = int(_loc17_ + _temp_835);
                                                si8(45,_temp_836);
                                                _loc14_ = li32(_loc4_ + 8);
                                                _loc14_ = _loc14_ + 1;
                                                si32(_loc14_,_loc4_ + 8);
                                             }
                                             break;
                                          }
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          _loc13_ <<= 1;
                                          si32(_loc13_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc17_ = wdnative.eax;
                                          if(_loc17_ == 0)
                                          {
                                             _loc17_ = li32(_loc4_ + 4);
                                             if(_loc17_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc17_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break;
                                          }
                                          si32(_loc17_,_loc4_ + 4);
                                          si32(_loc13_,_loc4_ + 12);
                                       }
                                    }
                                 }
                                 _loc14_ = li32(_loc16_ + 8);
                                 _loc3_ -= 16;
                                 si32(_loc14_,_loc3_ + 4);
                                 si32(_loc4_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_d_print_comp();
                                 _loc3_ += 16;
                                 if(_loc12_ <= 3)
                                 {
                                    if(_loc12_ != 2)
                                    {
                                       if(_loc12_ != 3)
                                       {
                                          break;
                                       }
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc17_ = li32(_loc4_ + 12);
                                          _loc13_ = li32(_loc4_ + 8);
                                          if((uint(_loc13_)) < uint(_loc17_))
                                          {
                                             var _temp_847:* = int(_loc16_ + _loc13_);
                                             si8(108,_temp_847);
                                             _loc14_ = _loc13_ + 1;
                                             si32(_loc14_,_loc4_ + 8);
                                             break;
                                          }
                                          _loc13_ += 1;
                                          while(true)
                                          {
                                             if(uint(_loc17_) >= uint(_loc13_))
                                             {
                                                if(_loc16_ != 0)
                                                {
                                                   var _temp_849:* = li32(_loc4_ + 8);
                                                   var _temp_850:* = int(_loc16_ + _temp_849);
                                                   si8(108,_temp_850);
                                                   _loc14_ = li32(_loc4_ + 8);
                                                   _loc14_ = _loc14_ + 1;
                                                   si32(_loc14_,_loc4_ + 8);
                                                }
                                                break loop84;
                                             }
                                             _loc3_ -= 16;
                                             si32(_loc16_,_loc3_);
                                             _loc17_ <<= 1;
                                             si32(_loc17_,_loc3_ + 4);
                                             wdnative.ESP = _loc3_;
                                             wdnative_nternal.F_realloc();
                                             _loc3_ += 16;
                                             _loc16_ = wdnative.eax;
                                             if(_loc16_ == 0)
                                             {
                                                _loc16_ = li32(_loc4_ + 4);
                                                if(_loc16_ != 0)
                                                {
                                                   _loc3_ -= 16;
                                                   si32(_loc16_,_loc3_);
                                                   wdnative.ESP = _loc3_;
                                                   wdnative_nternal.F_idalloc();
                                                   _loc3_ += 16;
                                                }
                                                si32(0,_loc4_ + 4);
                                                si32(1,_loc4_ + 24);
                                                break loop84;
                                             }
                                             si32(_loc16_,_loc4_ + 4);
                                             si32(_loc17_,_loc4_ + 12);
                                          }
                                       }
                                       break;
                                    }
                                    _loc16_ = li32(_loc4_ + 4);
                                    if(_loc16_ != 0)
                                    {
                                       _loc17_ = li32(_loc4_ + 12);
                                       _loc13_ = li32(_loc4_ + 8);
                                       if((uint(_loc13_)) < uint(_loc17_))
                                       {
                                          var _temp_860:* = int(_loc16_ + _loc13_);
                                          si8(117,_temp_860);
                                          _loc14_ = _loc13_ + 1;
                                          si32(_loc14_,_loc4_ + 8);
                                          break;
                                       }
                                       _loc13_ += 1;
                                       while(true)
                                       {
                                          if(uint(_loc17_) >= uint(_loc13_))
                                          {
                                             if(_loc16_ != 0)
                                             {
                                                var _temp_862:* = li32(_loc4_ + 8);
                                                var _temp_863:* = int(_loc16_ + _temp_862);
                                                si8(117,_temp_863);
                                                _loc14_ = li32(_loc4_ + 8);
                                                _loc14_ = _loc14_ + 1;
                                                si32(_loc14_,_loc4_ + 8);
                                             }
                                             break loop84;
                                          }
                                          _loc3_ -= 16;
                                          si32(_loc16_,_loc3_);
                                          _loc17_ <<= 1;
                                          si32(_loc17_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc16_ = wdnative.eax;
                                          if(_loc16_ == 0)
                                          {
                                             _loc16_ = li32(_loc4_ + 4);
                                             if(_loc16_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc16_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break loop84;
                                          }
                                          si32(_loc16_,_loc4_ + 4);
                                          si32(_loc17_,_loc4_ + 12);
                                       }
                                    }
                                    break;
                                 }
                                 if(_loc12_ != 4)
                                 {
                                    if(_loc12_ != 5)
                                    {
                                       if(_loc12_ != 6)
                                       {
                                          break;
                                       }
                                       _loc16_ = li32(_loc4_ + 4);
                                       if(_loc16_ != 0)
                                       {
                                          _loc17_ = li32(_loc4_ + 12);
                                          _loc12_ = li32(_loc4_ + 8);
                                          _loc13_ = _loc12_ + 3;
                                          if((uint(_loc13_)) <= uint(_loc17_))
                                          {
                                             _loc14_ = _loc16_ + _loc12_;
                                             si8(108,_loc14_ + 2);
                                             si16(27765,_loc14_);
                                             _loc14_ = li32(_loc4_ + 8);
                                             _loc14_ = _loc14_ + 3;
                                             si32(_loc14_,_loc4_ + 8);
                                             break;
                                          }
                                          while(true)
                                          {
                                             if(uint(_loc17_) >= uint(_loc13_))
                                             {
                                                if(_loc16_ != 0)
                                                {
                                                   var _temp_876:* = li32(_loc4_ + 8);
                                                   _loc14_ = _loc16_ + _temp_876;
                                                   si8(108,_loc14_ + 2);
                                                   si16(27765,_loc14_);
                                                   _loc14_ = li32(_loc4_ + 8);
                                                   _loc14_ = _loc14_ + 3;
                                                   si32(_loc14_,_loc4_ + 8);
                                                }
                                                break loop84;
                                             }
                                             _loc3_ -= 16;
                                             si32(_loc16_,_loc3_);
                                             _loc17_ <<= 1;
                                             si32(_loc17_,_loc3_ + 4);
                                             wdnative.ESP = _loc3_;
                                             wdnative_nternal.F_realloc();
                                             _loc3_ += 16;
                                             _loc16_ = wdnative.eax;
                                             if(_loc16_ == 0)
                                             {
                                                _loc16_ = li32(_loc4_ + 4);
                                                if(_loc16_ != 0)
                                                {
                                                   _loc3_ -= 16;
                                                   si32(_loc16_,_loc3_);
                                                   wdnative.ESP = _loc3_;
                                                   wdnative_nternal.F_idalloc();
                                                   _loc3_ += 16;
                                                }
                                                si32(0,_loc4_ + 4);
                                                si32(1,_loc4_ + 24);
                                                break loop84;
                                             }
                                             si32(_loc16_,_loc4_ + 4);
                                             si32(_loc17_,_loc4_ + 12);
                                          }
                                       }
                                       break;
                                    }
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc16_ = li32(_loc4_ + 12);
                                       _loc12_ = li32(_loc4_ + 8);
                                       _loc13_ = _loc12_ + 2;
                                       if((uint(_loc13_)) <= uint(_loc16_))
                                       {
                                          var _temp_887:* = int(_loc17_ + _loc12_);
                                          si16(27756,_temp_887);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 2;
                                          si32(_loc14_,_loc4_ + 8);
                                          break;
                                       }
                                       while(true)
                                       {
                                          if(uint(_loc16_) >= uint(_loc13_))
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_890:* = li32(_loc4_ + 8);
                                                var _temp_891:* = int(_loc17_ + _temp_890);
                                                si16(27756,_temp_891);
                                                _loc14_ = li32(_loc4_ + 8);
                                                _loc14_ = _loc14_ + 2;
                                                si32(_loc14_,_loc4_ + 8);
                                             }
                                             break loop84;
                                          }
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          _loc16_ <<= 1;
                                          si32(_loc16_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc17_ = wdnative.eax;
                                          if(_loc17_ == 0)
                                          {
                                             _loc16_ = li32(_loc4_ + 4);
                                             if(_loc16_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc16_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break loop84;
                                          }
                                          si32(_loc17_,_loc4_ + 4);
                                          si32(_loc16_,_loc4_ + 12);
                                       }
                                    }
                                    break;
                                 }
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 12);
                                    _loc12_ = li32(_loc4_ + 8);
                                    _loc13_ = _loc12_ + 2;
                                    if((uint(_loc13_)) <= uint(_loc17_))
                                    {
                                       var _temp_902:* = int(_loc16_ + _loc12_);
                                       si16(27765,_temp_902);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 2;
                                       si32(_loc14_,_loc4_ + 8);
                                       break;
                                    }
                                    while(true)
                                    {
                                       if(uint(_loc17_) >= uint(_loc13_))
                                       {
                                          if(_loc16_ != 0)
                                          {
                                             var _temp_905:* = li32(_loc4_ + 8);
                                             var _temp_906:* = int(_loc16_ + _temp_905);
                                             si16(27765,_temp_906);
                                             _loc14_ = li32(_loc4_ + 8);
                                             _loc14_ = _loc14_ + 2;
                                             si32(_loc14_,_loc4_ + 8);
                                          }
                                          break loop84;
                                       }
                                       _loc3_ -= 16;
                                       si32(_loc16_,_loc3_);
                                       _loc17_ <<= 1;
                                       si32(_loc17_,_loc3_ + 4);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_realloc();
                                       _loc3_ += 16;
                                       _loc16_ = wdnative.eax;
                                       if(_loc16_ == 0)
                                       {
                                          _loc16_ = li32(_loc4_ + 4);
                                          if(_loc16_ != 0)
                                          {
                                             _loc3_ -= 16;
                                             si32(_loc16_,_loc3_);
                                             wdnative.ESP = _loc3_;
                                             wdnative_nternal.F_idalloc();
                                             _loc3_ += 16;
                                          }
                                          si32(0,_loc4_ + 4);
                                          si32(1,_loc4_ + 24);
                                          break loop84;
                                       }
                                       si32(_loc16_,_loc4_ + 4);
                                       si32(_loc17_,_loc4_ + 12);
                                    }
                                 }
                                 break;
                              }
                           }
                        }
                        else
                        {
                           _loc10_ = li32(_loc16_ + 8);
                           var _temp_915:* = li32(_loc10_);
                           _loc13_ = 7;
                           if(_temp_915 == 0)
                           {
                              var _temp_916:* = li32(_loc10_ + 8);
                              _loc13_ = _loc12_;
                              if(_temp_916 == 1)
                              {
                                 _loc13_ = _loc12_;
                                 if(_loc15_ == 49)
                                 {
                                    _loc14_ = li32(_loc10_ + 4);
                                    _loc15_ = si8(li8(_loc14_));
                                    if(_loc15_ == 49)
                                    {
                                       _loc16_ = li32(_loc4_ + 12);
                                       _loc12_ = li32(_loc4_ + 8);
                                       _loc13_ = _loc12_ + 4;
                                       if((uint(_loc13_)) <= uint(_loc16_))
                                       {
                                          var _temp_933:* = int(_loc17_ + _loc12_);
                                          si32(1702195828,_temp_933);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 4;
                                          si32(_loc14_,_loc4_ + 8);
                                          break;
                                       }
                                       while(true)
                                       {
                                          if(uint(_loc16_) >= uint(_loc13_))
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_936:* = li32(_loc4_ + 8);
                                                var _temp_937:* = int(_loc17_ + _temp_936);
                                                si32(1702195828,_temp_937);
                                                _loc14_ = li32(_loc4_ + 8);
                                                _loc14_ = _loc14_ + 4;
                                                si32(_loc14_,_loc4_ + 8);
                                             }
                                             break loop84;
                                          }
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          _loc16_ <<= 1;
                                          si32(_loc16_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc17_ = wdnative.eax;
                                          if(_loc17_ == 0)
                                          {
                                             _loc16_ = li32(_loc4_ + 4);
                                             if(_loc16_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc16_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break loop84;
                                          }
                                          si32(_loc17_,_loc4_ + 4);
                                          si32(_loc16_,_loc4_ + 12);
                                       }
                                       break;
                                    }
                                    _loc13_ = _loc12_;
                                    if(_loc15_ == 48)
                                    {
                                       _loc16_ = li32(_loc4_ + 12);
                                       _loc13_ = li32(_loc4_ + 8);
                                       _loc12_ = _loc13_ + 5;
                                       if((uint(_loc12_)) <= uint(_loc16_))
                                       {
                                          _loc14_ = _loc17_ + _loc13_;
                                          si8(101,_loc14_ + 4);
                                          si32(1936482662,_loc14_);
                                          _loc14_ = li32(_loc4_ + 8);
                                          _loc14_ = _loc14_ + 5;
                                          si32(_loc14_,_loc4_ + 8);
                                          break;
                                       }
                                       while(true)
                                       {
                                          if(uint(_loc16_) >= uint(_loc12_))
                                          {
                                             if(_loc17_ != 0)
                                             {
                                                var _temp_923:* = li32(_loc4_ + 8);
                                                _loc14_ = _loc17_ + _temp_923;
                                                si8(101,_loc14_ + 4);
                                                si32(1936482662,_loc14_);
                                                _loc14_ = li32(_loc4_ + 8);
                                                _loc14_ = _loc14_ + 5;
                                                si32(_loc14_,_loc4_ + 8);
                                             }
                                             break loop84;
                                          }
                                          _loc3_ -= 16;
                                          si32(_loc17_,_loc3_);
                                          _loc16_ <<= 1;
                                          si32(_loc16_,_loc3_ + 4);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_realloc();
                                          _loc3_ += 16;
                                          _loc17_ = wdnative.eax;
                                          if(_loc17_ == 0)
                                          {
                                             _loc16_ = li32(_loc4_ + 4);
                                             if(_loc16_ != 0)
                                             {
                                                _loc3_ -= 16;
                                                si32(_loc16_,_loc3_);
                                                wdnative.ESP = _loc3_;
                                                wdnative_nternal.F_idalloc();
                                                _loc3_ += 16;
                                             }
                                             si32(0,_loc4_ + 4);
                                             si32(1,_loc4_ + 24);
                                             break loop84;
                                          }
                                          si32(_loc17_,_loc4_ + 4);
                                          si32(_loc16_,_loc4_ + 12);
                                       }
                                       break;
                                    }
                                 }
                              }
                           }
                        }
                     }
                     _loc12_ = li32(_loc4_ + 12);
                     _loc15_ = li32(_loc4_ + 8);
                     if((uint(_loc15_)) < uint(_loc12_))
                     {
                        var _temp_946:* = int(_loc17_ + _loc15_);
                        si8(40,_temp_946);
                        _loc14_ = _loc15_ + 1;
                        si32(_loc14_,_loc4_ + 8);
                     }
                     else
                     {
                        _loc15_ += 1;
                        while(true)
                        {
                           if(uint(_loc12_) >= uint(_loc15_))
                           {
                              if(_loc17_ != 0)
                              {
                                 var _temp_948:* = li32(_loc4_ + 8);
                                 var _temp_949:* = int(_loc17_ + _temp_948);
                                 si8(40,_temp_949);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break;
                           }
                           _loc3_ -= 16;
                           si32(_loc17_,_loc3_);
                           _loc12_ <<= 1;
                           si32(_loc12_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc17_ = wdnative.eax;
                           if(_loc17_ == 0)
                           {
                              _loc17_ = li32(_loc4_ + 4);
                              if(_loc17_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break;
                           }
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc12_,_loc4_ + 12);
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc12_ = li32(_loc4_ + 4);
                     if(_loc12_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        if((uint(_loc15_)) < uint(_loc17_))
                        {
                           var _temp_960:* = int(_loc12_ + _loc15_);
                           si8(41,_temp_960);
                           _loc14_ = _loc15_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc15_ += 1;
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc15_))
                              {
                                 if(_loc12_ != 0)
                                 {
                                    var _temp_962:* = li32(_loc4_ + 8);
                                    var _temp_963:* = int(_loc12_ + _temp_962);
                                    si8(41,_temp_963);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc12_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc12_ = wdnative.eax;
                              if(_loc12_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc12_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_);
                     if(_loc14_ == 50)
                     {
                        _loc12_ = li32(_loc4_ + 4);
                        if(_loc12_ != 0)
                        {
                           _loc17_ = li32(_loc4_ + 12);
                           _loc15_ = li32(_loc4_ + 8);
                           if((uint(_loc15_)) < uint(_loc17_))
                           {
                              var _temp_974:* = int(_loc12_ + _loc15_);
                              si8(45,_temp_974);
                              _loc14_ = _loc15_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                           }
                           else
                           {
                              _loc15_ += 1;
                              while(true)
                              {
                                 if(uint(_loc17_) >= uint(_loc15_))
                                 {
                                    if(_loc12_ != 0)
                                    {
                                       var _temp_976:* = li32(_loc4_ + 8);
                                       var _temp_977:* = int(_loc12_ + _temp_976);
                                       si8(45,_temp_977);
                                       _loc14_ = li32(_loc4_ + 8);
                                       _loc14_ = _loc14_ + 1;
                                       si32(_loc14_,_loc4_ + 8);
                                    }
                                    break;
                                 }
                                 _loc3_ -= 16;
                                 si32(_loc12_,_loc3_);
                                 _loc17_ <<= 1;
                                 si32(_loc17_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc12_ = wdnative.eax;
                                 if(_loc12_ == 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break;
                                 }
                                 si32(_loc12_,_loc4_ + 4);
                                 si32(_loc17_,_loc4_ + 12);
                              }
                           }
                        }
                     }
                     if(_loc13_ != 8)
                     {
                        var _temp_985:* = li32(_loc16_ + 8);
                        _loc3_ -= 16;
                        si32(_temp_985,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                        break;
                     }
                     _loc12_ = li32(_loc4_ + 4);
                     if(_loc12_ == 0)
                     {
                        var _temp_988:* = li32(_loc16_ + 8);
                        _loc3_ -= 16;
                        si32(_temp_988,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                     }
                     else
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        if((uint(_loc15_)) < uint(_loc17_))
                        {
                           var _temp_991:* = int(_loc12_ + _loc15_);
                           si8(91,_temp_991);
                           _loc14_ = _loc15_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc15_ += 1;
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc15_))
                              {
                                 if(_loc12_ != 0)
                                 {
                                    var _temp_993:* = li32(_loc4_ + 8);
                                    var _temp_994:* = int(_loc12_ + _temp_993);
                                    si8(91,_temp_994);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc12_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc12_ = wdnative.eax;
                              if(_loc12_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc12_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                        _loc14_ = li32(_loc16_ + 8);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_loc4_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_d_print_comp();
                        _loc3_ += 16;
                        if(_loc13_ != 8)
                        {
                           break;
                        }
                     }
                     _loc16_ = li32(_loc4_ + 4);
                     if(_loc16_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc13_ = li32(_loc4_ + 8);
                        if((uint(_loc13_)) < uint(_loc17_))
                        {
                           var _temp_1005:* = int(_loc16_ + _loc13_);
                           si8(93,_temp_1005);
                           _loc14_ = _loc13_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                           break;
                        }
                        _loc13_ += 1;
                        while(true)
                        {
                           if(uint(_loc17_) >= uint(_loc13_))
                           {
                              if(_loc16_ != 0)
                              {
                                 var _temp_1007:* = li32(_loc4_ + 8);
                                 var _temp_1008:* = int(_loc16_ + _temp_1007);
                                 si8(93,_temp_1008);
                                 _loc14_ = li32(_loc4_ + 8);
                                 _loc14_ = _loc14_ + 1;
                                 si32(_loc14_,_loc4_ + 8);
                              }
                              break loop84;
                           }
                           _loc3_ -= 16;
                           si32(_loc16_,_loc3_);
                           _loc17_ <<= 1;
                           si32(_loc17_,_loc3_ + 4);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_realloc();
                           _loc3_ += 16;
                           _loc16_ = wdnative.eax;
                           if(_loc16_ == 0)
                           {
                              _loc16_ = li32(_loc4_ + 4);
                              if(_loc16_ != 0)
                              {
                                 _loc3_ -= 16;
                                 si32(_loc16_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_idalloc();
                                 _loc3_ += 16;
                              }
                              si32(0,_loc4_ + 4);
                              si32(1,_loc4_ + 24);
                              break loop84;
                           }
                           si32(_loc16_,_loc4_ + 4);
                           si32(_loc17_,_loc4_ + 12);
                        }
                     }
                     break;
                  }
               }
            }
            else
            {
               _loc3_ -= 16;
               si32(_loc17_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_idalloc();
               _loc3_ += 16;
               si32(0,_loc4_ + 4);
            }
         }
         else
         {
            while(true)
            {
               _loc13_ = li32(_loc16_ + 8);
               _loc14_ = li32(_loc13_);
               if(_loc14_ == 47)
               {
                  _loc14_ = li32(_loc13_ + 8);
                  _loc14_ = li32(_loc14_);
                  if(_loc14_ != 48)
                  {
                     if(_loc17_ == 0)
                     {
                        break;
                     }
                  }
                  else
                  {
                     _loc13_ = li32(_loc4_ + 12);
                     _loc12_ = li32(_loc4_ + 8);
                     loop86:
                     while(true)
                     {
                        if(_loc17_ != 0)
                        {
                           if(uint(_loc12_) < uint(_loc13_))
                           {
                              var _temp_1021:* = int(_loc17_ + _loc12_);
                              si8(40,_temp_1021);
                              _loc14_ = _loc12_ + 1;
                              si32(_loc14_,_loc4_ + 8);
                              break;
                           }
                        }
                        if(uint(_loc12_) >= uint(_loc13_))
                        {
                           _loc12_ += 1;
                           while(true)
                           {
                              if(uint(_loc13_) < uint(_loc12_))
                              {
                                 _loc3_ -= 16;
                                 si32(_loc17_,_loc3_);
                                 _loc13_ <<= 1;
                                 si32(_loc13_,_loc3_ + 4);
                                 wdnative.ESP = _loc3_;
                                 wdnative_nternal.F_realloc();
                                 _loc3_ += 16;
                                 _loc17_ = wdnative.eax;
                                 if(_loc17_ == 0)
                                 {
                                    _loc17_ = li32(_loc4_ + 4);
                                    if(_loc17_ != 0)
                                    {
                                       _loc3_ -= 16;
                                       si32(_loc17_,_loc3_);
                                       wdnative.ESP = _loc3_;
                                       wdnative_nternal.F_idalloc();
                                       _loc3_ += 16;
                                    }
                                    si32(0,_loc4_ + 4);
                                    si32(1,_loc4_ + 24);
                                    break loop86;
                                 }
                                 continue;
                              }
                              if(_loc17_ == 0)
                              {
                                 break loop86;
                              }
                              _loc12_ = li32(_loc4_ + 8);
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                           break;
                        }
                        _loc14_ = _loc17_ + _loc12_;
                        si8(40,_loc14_);
                        _loc14_ = li32(_loc4_ + 8);
                        _loc14_ = _loc14_ + 1;
                        si32(_loc14_,_loc4_ + 8);
                        break;
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc14_ = li32(_loc14_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc13_ = li32(_loc4_ + 4);
                     if(_loc13_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 2;
                        if((uint(_loc12_)) <= uint(_loc17_))
                        {
                           var _temp_1035:* = int(_loc13_ + _loc15_);
                           si16(8233,_temp_1035);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 2;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc12_))
                              {
                                 if(_loc13_ != 0)
                                 {
                                    var _temp_1038:* = li32(_loc4_ + 8);
                                    var _temp_1039:* = int(_loc13_ + _temp_1038);
                                    si16(8233,_temp_1039);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 2;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc13_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc13_ = wdnative.eax;
                              if(_loc13_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc13_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_expr_op();
                     _loc3_ += 16;
                     _loc17_ = li32(_loc4_ + 4);
                     if(_loc17_ != 0)
                     {
                        _loc13_ = li32(_loc4_ + 12);
                        _loc15_ = li32(_loc4_ + 8);
                        _loc12_ = _loc15_ + 2;
                        if((uint(_loc12_)) <= uint(_loc13_))
                        {
                           var _temp_1051:* = int(_loc17_ + _loc15_);
                           si16(10272,_temp_1051);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 2;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc13_) >= uint(_loc12_))
                              {
                                 if(_loc17_ != 0)
                                 {
                                    var _temp_1054:* = li32(_loc4_ + 8);
                                    var _temp_1055:* = int(_loc17_ + _temp_1054);
                                    si16(10272,_temp_1055);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 2;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc17_,_loc3_);
                              _loc13_ <<= 1;
                              si32(_loc13_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc17_ = wdnative.eax;
                              if(_loc17_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc17_,_loc4_ + 4);
                              si32(_loc13_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc14_ = li32(_loc14_ + 8);
                     _loc14_ = li32(_loc14_ + 4);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc15_ = li32(_loc4_ + 4);
                     if(_loc15_ != 0)
                     {
                        _loc12_ = li32(_loc4_ + 12);
                        _loc13_ = li32(_loc4_ + 8);
                        _loc17_ = _loc13_ + 5;
                        if((uint(_loc17_)) <= uint(_loc12_))
                        {
                           _loc14_ = _loc15_ + _loc13_;
                           si8(40,_loc14_ + 4);
                           si32(540680233,_loc14_);
                           _loc14_ = li32(_loc4_ + 8);
                           _loc14_ = _loc14_ + 5;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           while(true)
                           {
                              if(uint(_loc12_) >= uint(_loc17_))
                              {
                                 if(_loc15_ != 0)
                                 {
                                    var _temp_1071:* = li32(_loc4_ + 8);
                                    _loc14_ = _loc15_ + _temp_1071;
                                    si8(40,_loc14_ + 4);
                                    si32(540680233,_loc14_);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 5;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc15_,_loc3_);
                              _loc12_ <<= 1;
                              si32(_loc12_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc15_ = wdnative.eax;
                              if(_loc15_ == 0)
                              {
                                 _loc17_ = li32(_loc4_ + 4);
                                 if(_loc17_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc17_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc15_,_loc4_ + 4);
                              si32(_loc12_,_loc4_ + 12);
                           }
                        }
                     }
                     _loc14_ = li32(_loc16_ + 8);
                     _loc14_ = li32(_loc14_ + 8);
                     _loc14_ = li32(_loc14_ + 8);
                     _loc3_ -= 16;
                     si32(_loc14_,_loc3_ + 4);
                     si32(_loc4_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_d_print_comp();
                     _loc3_ += 16;
                     _loc16_ = li32(_loc4_ + 4);
                     if(_loc16_ != 0)
                     {
                        _loc17_ = li32(_loc4_ + 12);
                        _loc13_ = li32(_loc4_ + 8);
                        if((uint(_loc13_)) < uint(_loc17_))
                        {
                           var _temp_1084:* = int(_loc16_ + _loc13_);
                           si8(41,_temp_1084);
                           _loc14_ = _loc13_ + 1;
                           si32(_loc14_,_loc4_ + 8);
                        }
                        else
                        {
                           _loc13_ += 1;
                           while(true)
                           {
                              if(uint(_loc17_) >= uint(_loc13_))
                              {
                                 if(_loc16_ != 0)
                                 {
                                    var _temp_1086:* = li32(_loc4_ + 8);
                                    var _temp_1087:* = int(_loc16_ + _temp_1086);
                                    si8(41,_temp_1087);
                                    _loc14_ = li32(_loc4_ + 8);
                                    _loc14_ = _loc14_ + 1;
                                    si32(_loc14_,_loc4_ + 8);
                                 }
                                 break;
                              }
                              _loc3_ -= 16;
                              si32(_loc16_,_loc3_);
                              _loc17_ <<= 1;
                              si32(_loc17_,_loc3_ + 4);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F_realloc();
                              _loc3_ += 16;
                              _loc16_ = wdnative.eax;
                              if(_loc16_ == 0)
                              {
                                 _loc16_ = li32(_loc4_ + 4);
                                 if(_loc16_ != 0)
                                 {
                                    _loc3_ -= 16;
                                    si32(_loc16_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative_nternal.F_idalloc();
                                    _loc3_ += 16;
                                 }
                                 si32(0,_loc4_ + 4);
                                 si32(1,_loc4_ + 24);
                                 break;
                              }
                              si32(_loc16_,_loc4_ + 4);
                              si32(_loc17_,_loc4_ + 12);
                           }
                        }
                     }
                     §§goto(addr686f);
                  }
               }
               _loc3_ -= 16;
               si32(_loc17_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_idalloc();
               _loc3_ += 16;
               break;
            }
            si32(0,_loc4_ + 4);
         }
      }
      addr686f:
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

