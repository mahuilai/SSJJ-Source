package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F___swbuf() : void
   {
      var _temp_1:* = this;
      var _loc9_:int = 0;
      var _loc19_:int = 0;
      var _loc5_:int = 0;
      var _loc20_:int = 0;
      var _loc14_:int = 0;
      var _loc1_:int = 0;
      var _loc13_:int = 0;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc18_:int = 0;
      var _loc17_:int = 0;
      var _loc15_:int = 0;
      var _loc21_:int = 0;
      var _loc11_:int = 0;
      var _loc2_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc16_:int = 0;
      var _loc4_:int;
      _loc9_ = _loc4_ = wdnative.ESP;
      _loc5_ = li32(_loc9_ + 4);
      _loc21_ = li32(_loc5_ + 24);
      si32(_loc21_,_loc5_ + 8);
      _loc20_ = li16(_loc5_ + 12);
      _loc21_ = _loc20_ & 8;
      _loc19_ = li32(_loc9_);
      while(true)
      {
         if(_loc21_ != 0)
         {
            _loc21_ = li32(_loc5_ + 16);
            if(_loc21_ != 0)
            {
               break;
            }
            _loc21_ = _loc20_ & 0x0200;
            if(_loc21_ != 0)
            {
               break;
            }
         }
         _loc4_ -= 16;
         si32(_loc5_,_loc4_);
         wdnative.ESP = _loc4_;
         wdnative_nternal.F___swsetup();
         _loc18_ = -1;
         _loc4_ += 16;
         _loc21_ = wdnative.eax;
         if(_loc21_ == 0)
         {
            break;
         }
         §§goto(addr0bc8);
      }
      _loc21_ = li32(_loc5_ + 100);
      if(_loc21_ == 0)
      {
         si32(-1,_loc5_ + 100);
      }
      _loc20_ = _loc19_ & 0xFF;
      _loc17_ = li32(_loc5_ + 16);
      _loc16_ = li32(_loc5_);
      _loc15_ = _loc16_ - _loc17_;
      loop9:
      while(true)
      {
         _loc14_ = li32(_loc5_ + 20);
         if(_loc14_ > _loc15_)
         {
            _loc15_ += 1;
         }
         else
         {
            _loc16_ = 0;
            _loc18_ = wdnative_nternal.___sglue;
            if(_loc5_ == 0)
            {
               do
               {
                  _loc15_ = li32(_loc18_ + 4);
                  if(_loc15_ >= 1)
                  {
                     _loc14_ = li32(_loc18_ + 8);
                     do
                     {
                        _loc17_ = si16(li16(_loc14_ + 12));
                        if(_loc17_ >= 1)
                        {
                           var _temp_21:* = _loc17_ & 8;
                           _loc1_ = 0;
                           if(_temp_21 != 0)
                           {
                              _loc10_ = li32(_loc14_ + 16);
                              _loc1_ = 0;
                              if(_loc10_ != 0)
                              {
                                 _loc11_ = li32(_loc14_);
                                 si32(_loc10_,_loc14_);
                                 var _temp_22:* = _loc17_ & 3;
                                 _loc1_ = 0;
                                 if(_temp_22 == 0)
                                 {
                                    _loc1_ = li32(_loc14_ + 20);
                                 }
                                 _loc11_ -= _loc10_;
                                 si32(_loc1_,_loc14_ + 8);
                                 loop3:
                                 while(true)
                                 {
                                    _loc1_ = 0;
                                    if(_loc11_ <= 0)
                                    {
                                       break;
                                    }
                                    while(true)
                                    {
                                       _loc21_ = _loc17_ & 0x0100;
                                       if(_loc21_ != 0)
                                       {
                                          _loc1_ = li32(wdnative_nternal._errno);
                                          _loc4_ -= 16;
                                          si32(2,_loc4_ + 4);
                                          si32(_loc14_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative_nternal.F__sseek();
                                          _loc4_ += 16;
                                          _loc21_ = wdnative.eax & wdnative.edx;
                                          if(_loc21_ == -1)
                                          {
                                             _loc17_ = li16(_loc14_ + 12);
                                             _loc21_ = _loc17_ & 0x0400;
                                             if(_loc21_ != 0)
                                             {
                                                break;
                                             }
                                          }
                                          si32(_loc1_,wdnative_nternal._errno);
                                       }
                                       var _loc12_:int = li32(_loc14_ + 44);
                                       _loc21_ = li32(_loc14_ + 28);
                                       _loc4_ -= 16;
                                       si32(_loc11_,_loc4_ + 8);
                                       si32(_loc10_,_loc4_ + 4);
                                       si32(_loc21_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative.ptr2fun[_loc12_]();
                                       _loc4_ += 16;
                                       _loc13_ = wdnative.eax;
                                       _loc17_ = li16(_loc14_ + 12);
                                       if(_loc13_ < 0)
                                       {
                                          _loc17_ &= 61439;
                                          si16(_loc17_,_loc14_ + 12);
                                          break;
                                       }
                                       while(true)
                                       {
                                          _loc21_ = _loc17_ & 0x1100;
                                          if(_loc21_ == 4352)
                                          {
                                             var _temp_31:* = _loc13_ ^ -1;
                                             _loc3_ = li32(_loc14_ + 80);
                                             _loc7_ = _loc6_ = 1;
                                             if(uint(_loc3_) <= uint(_temp_31))
                                             {
                                                _loc7_ = 0;
                                             }
                                             _loc8_ = li32(_loc14_ + 84);
                                             _loc1_ = _loc13_ >> 31;
                                             _loc2_ = 2147483647 - _loc1_;
                                             if(_loc8_ <= _loc2_)
                                             {
                                                _loc6_ = 0;
                                             }
                                             if(_loc8_ != _loc2_)
                                             {
                                                _loc7_ = _loc6_;
                                             }
                                             if(_loc7_ == 0)
                                             {
                                                _loc2_ = _loc3_ + _loc13_;
                                                si32(_loc2_,_loc14_ + 80);
                                                _loc6_ = _loc7_ = 1;
                                                if(uint(_loc2_) >= uint(_loc3_))
                                                {
                                                   _loc6_ = 0;
                                                }
                                                if(uint(_loc2_) >= uint(_loc13_))
                                                {
                                                   _loc7_ = _loc6_;
                                                }
                                                _loc21_ = _loc8_ + _loc1_;
                                                _loc21_ = _loc21_ + _loc7_;
                                                si32(_loc21_,_loc14_ + 84);
                                                break;
                                             }
                                          }
                                          _loc17_ &= 61439;
                                          si16(_loc17_,_loc14_ + 12);
                                          break;
                                       }
                                       if(_loc13_ <= 0)
                                       {
                                          break;
                                       }
                                       continue loop3;
                                    }
                                    _loc21_ = _loc17_ | 0x40;
                                    si16(_loc21_,_loc14_ + 12);
                                    _loc1_ = -1;
                                    break;
                                    _loc10_ += _loc13_;
                                    _loc11_ -= _loc13_;
                                 }
                              }
                           }
                           _loc16_ = _loc1_ | _loc16_;
                        }
                        _loc14_ += 232;
                     }
                     while(_loc15_ += -1, _loc15_ != 0);
                  }
               }
               while(_loc18_ = li32(_loc18_), _loc18_ != 0);
               _loc18_ = -1;
               if(_loc16_ != 0)
               {
                  break;
               }
            }
            else
            {
               _loc16_ = si16(li16(_loc5_ + 12));
               _loc21_ = _loc16_ & 0x18;
               if(_loc21_ == 0)
               {
                  si32(9,wdnative_nternal._errno);
                  _loc18_ = -1;
                  break;
               }
               _loc21_ = _loc16_ & 8;
               if(_loc21_ != 0)
               {
                  if(_loc17_ != 0)
                  {
                     si32(_loc17_,_loc5_);
                     _loc21_ = _loc16_ & 3;
                     if(_loc21_ != 0)
                     {
                        _loc14_ = 0;
                     }
                     si32(_loc14_,_loc5_ + 8);
                     while(true)
                     {
                        if(_loc15_ > 0)
                        {
                           _loc21_ = _loc16_ & 0x0100;
                           if(_loc21_ != 0)
                           {
                              _loc18_ = li32(wdnative_nternal._errno);
                              _loc4_ -= 16;
                              si32(2,_loc4_ + 4);
                              si32(_loc5_,_loc4_);
                              wdnative.ESP = _loc4_;
                              wdnative_nternal.F__sseek();
                              _loc4_ += 16;
                              _loc21_ = wdnative.eax & wdnative.edx;
                              if(_loc21_ == -1)
                              {
                                 _loc16_ = li16(_loc5_ + 12);
                                 _loc21_ = _loc16_ & 0x0400;
                                 if(_loc21_ != 0)
                                 {
                                    break;
                                 }
                              }
                              si32(_loc18_,wdnative_nternal._errno);
                           }
                           _loc21_ = li32(_loc5_ + 44);
                           _loc12_ = li32(_loc5_ + 28);
                           _loc4_ -= 16;
                           si32(_loc15_,_loc4_ + 8);
                           si32(_loc17_,_loc4_ + 4);
                           si32(_loc12_,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative.ptr2fun[_loc21_]();
                           _loc4_ += 16;
                           _loc11_ = wdnative.eax;
                           _loc16_ = li16(_loc5_ + 12);
                           if(_loc11_ < 0)
                           {
                              _loc16_ &= 61439;
                              si16(_loc16_,_loc5_ + 12);
                              break;
                           }
                           while(true)
                           {
                              _loc21_ = _loc16_ & 0x1100;
                              if(_loc21_ == 4352)
                              {
                                 var _temp_49:* = _loc11_ ^ -1;
                                 _loc18_ = li32(_loc5_ + 80);
                                 _loc1_ = 1;
                                 _loc8_ = _loc1_;
                                 if(uint(_loc18_) <= uint(_temp_49))
                                 {
                                    _loc8_ = 0;
                                 }
                                 _loc10_ = li32(_loc5_ + 84);
                                 _loc14_ = _loc11_ >> 31;
                                 _loc3_ = 2147483647 - _loc14_;
                                 if(_loc10_ <= _loc3_)
                                 {
                                    _loc1_ = 0;
                                 }
                                 if(_loc10_ != _loc3_)
                                 {
                                    _loc8_ = _loc1_;
                                 }
                                 if(_loc8_ == 0)
                                 {
                                    _loc3_ = _loc18_ + _loc11_;
                                    si32(_loc3_,_loc5_ + 80);
                                    _loc1_ = _loc8_ = 1;
                                    if(uint(_loc3_) >= uint(_loc18_))
                                    {
                                       _loc1_ = 0;
                                    }
                                    if(uint(_loc3_) >= uint(_loc11_))
                                    {
                                       _loc8_ = _loc1_;
                                    }
                                    _loc21_ = _loc10_ + _loc14_;
                                    _loc21_ = _loc21_ + _loc8_;
                                    si32(_loc21_,_loc5_ + 84);
                                    break;
                                 }
                              }
                              _loc16_ &= 61439;
                              si16(_loc16_,_loc5_ + 12);
                              break;
                           }
                           if(_loc11_ <= 0)
                           {
                              break;
                           }
                           _loc17_ += _loc11_;
                           _loc15_ -= _loc11_;
                           continue;
                        }
                     }
                     _loc21_ = _loc16_ | 0x40;
                     si16(_loc21_,_loc5_ + 12);
                     _loc18_ = -1;
                     break;
                  }
               }
            }
            _loc16_ = li32(_loc5_);
            _loc15_ = 1;
         }
         _loc21_ = li32(_loc5_ + 8);
         _loc21_ = _loc21_ + -1;
         si32(_loc21_,_loc5_ + 8);
         si8(_loc19_,_loc16_);
         _loc17_ = _loc16_ + 1;
         si32(_loc17_,_loc5_);
         _loc18_ = li32(_loc5_ + 20);
         loop13:
         while(true)
         {
            if(_loc15_ != _loc18_)
            {
               _loc21_ = li16(_loc5_ + 12);
               _loc21_ = _loc21_ & 1;
               if(_loc21_ == 0)
               {
                  break;
               }
               if(_loc20_ != 10)
               {
                  break;
               }
            }
            _loc19_ = 0;
            _loc16_ = wdnative_nternal.___sglue;
            if(_loc5_ == 0)
            {
               do
               {
                  _loc17_ = li32(_loc16_ + 4);
                  if(_loc17_ >= 1)
                  {
                     _loc18_ = li32(_loc16_ + 8);
                     do
                     {
                        _loc15_ = si16(li16(_loc18_ + 12));
                        if(_loc15_ >= 1)
                        {
                           var _temp_64:* = _loc15_ & 8;
                           _loc10_ = 0;
                           if(_temp_64 != 0)
                           {
                              _loc5_ = li32(_loc18_ + 16);
                              _loc10_ = 0;
                              if(_loc5_ != 0)
                              {
                                 _loc14_ = li32(_loc18_);
                                 si32(_loc5_,_loc18_);
                                 var _temp_65:* = _loc15_ & 3;
                                 _loc10_ = 0;
                                 if(_temp_65 == 0)
                                 {
                                    _loc10_ = li32(_loc18_ + 20);
                                 }
                                 _loc14_ -= _loc5_;
                                 si32(_loc10_,_loc18_ + 8);
                                 loop7:
                                 while(true)
                                 {
                                    _loc10_ = 0;
                                    if(_loc14_ <= 0)
                                    {
                                       break;
                                    }
                                    while(true)
                                    {
                                       _loc21_ = _loc15_ & 0x0100;
                                       if(_loc21_ != 0)
                                       {
                                          _loc10_ = li32(wdnative_nternal._errno);
                                          _loc4_ -= 16;
                                          si32(2,_loc4_ + 4);
                                          si32(_loc18_,_loc4_);
                                          wdnative.ESP = _loc4_;
                                          wdnative_nternal.F__sseek();
                                          _loc4_ += 16;
                                          _loc21_ = wdnative.eax & wdnative.edx;
                                          if(_loc21_ == -1)
                                          {
                                             _loc15_ = li16(_loc18_ + 12);
                                             _loc21_ = _loc15_ & 0x0400;
                                             if(_loc21_ != 0)
                                             {
                                                break;
                                             }
                                          }
                                          si32(_loc10_,wdnative_nternal._errno);
                                       }
                                       _loc12_ = li32(_loc18_ + 44);
                                       _loc21_ = li32(_loc18_ + 28);
                                       _loc4_ -= 16;
                                       si32(_loc14_,_loc4_ + 8);
                                       si32(_loc5_,_loc4_ + 4);
                                       si32(_loc21_,_loc4_);
                                       wdnative.ESP = _loc4_;
                                       wdnative.ptr2fun[_loc12_]();
                                       _loc4_ += 16;
                                       _loc10_ = wdnative.eax;
                                       _loc15_ = li16(_loc18_ + 12);
                                       if(_loc10_ < 0)
                                       {
                                          _loc15_ &= 61439;
                                          si16(_loc15_,_loc18_ + 12);
                                          break;
                                       }
                                       while(true)
                                       {
                                          _loc21_ = _loc15_ & 0x1100;
                                          if(_loc21_ == 4352)
                                          {
                                             var _temp_74:* = _loc10_ ^ -1;
                                             _loc11_ = li32(_loc18_ + 80);
                                             _loc3_ = _loc13_ = 1;
                                             if(uint(_loc11_) <= uint(_temp_74))
                                             {
                                                _loc3_ = 0;
                                             }
                                             _loc1_ = li32(_loc18_ + 84);
                                             _loc8_ = _loc10_ >> 31;
                                             _loc6_ = 2147483647 - _loc8_;
                                             if(_loc1_ <= _loc6_)
                                             {
                                                _loc13_ = 0;
                                             }
                                             if(_loc1_ != _loc6_)
                                             {
                                                _loc3_ = _loc13_;
                                             }
                                             if(_loc3_ == 0)
                                             {
                                                _loc6_ = _loc11_ + _loc10_;
                                                si32(_loc6_,_loc18_ + 80);
                                                _loc3_ = _loc13_ = 1;
                                                if(uint(_loc6_) >= uint(_loc11_))
                                                {
                                                   _loc3_ = 0;
                                                }
                                                if(uint(_loc6_) >= uint(_loc10_))
                                                {
                                                   _loc13_ = _loc3_;
                                                }
                                                _loc21_ = _loc1_ + _loc8_;
                                                _loc21_ = _loc21_ + _loc13_;
                                                si32(_loc21_,_loc18_ + 84);
                                                break;
                                             }
                                          }
                                          _loc15_ &= 61439;
                                          si16(_loc15_,_loc18_ + 12);
                                          break;
                                       }
                                       if(_loc10_ <= 0)
                                       {
                                          break;
                                       }
                                       continue loop7;
                                    }
                                    _loc21_ = _loc15_ | 0x40;
                                    si16(_loc21_,_loc18_ + 12);
                                    _loc10_ = -1;
                                    break;
                                    _loc5_ += _loc10_;
                                    _loc14_ -= _loc10_;
                                 }
                              }
                           }
                           _loc19_ = _loc10_ | _loc19_;
                        }
                        _loc18_ += 232;
                     }
                     while(_loc17_ += -1, _loc17_ != 0);
                  }
               }
               while(_loc16_ = li32(_loc16_), _loc16_ != 0);
               _loc18_ = -1;
               if(_loc19_ == 0)
               {
                  break;
               }
               break loop9;
            }
            _loc16_ = si16(li16(_loc5_ + 12));
            _loc21_ = _loc16_ & 0x18;
            if(_loc21_ == 0)
            {
               si32(9,wdnative_nternal._errno);
               _loc18_ = -1;
               break loop9;
            }
            _loc21_ = _loc16_ & 8;
            if(_loc21_ != 0)
            {
               _loc19_ = li32(_loc5_ + 16);
               if(_loc19_ != 0)
               {
                  si32(_loc19_,_loc5_);
                  _loc21_ = _loc16_ & 3;
                  if(_loc21_ != 0)
                  {
                     _loc18_ = 0;
                  }
                  si32(_loc18_,_loc5_ + 8);
                  _loc18_ = _loc17_ - _loc19_;
                  loop6:
                  while(true)
                  {
                     if(_loc18_ <= 0)
                     {
                        break loop13;
                     }
                     while(true)
                     {
                        _loc21_ = _loc16_ & 0x0100;
                        if(_loc21_ != 0)
                        {
                           _loc17_ = li32(wdnative_nternal._errno);
                           _loc4_ -= 16;
                           si32(2,_loc4_ + 4);
                           si32(_loc5_,_loc4_);
                           wdnative.ESP = _loc4_;
                           wdnative_nternal.F__sseek();
                           _loc4_ += 16;
                           _loc21_ = wdnative.eax & wdnative.edx;
                           if(_loc21_ == -1)
                           {
                              _loc16_ = li16(_loc5_ + 12);
                              _loc21_ = _loc16_ & 0x0400;
                              if(_loc21_ != 0)
                              {
                                 break;
                              }
                           }
                           si32(_loc17_,wdnative_nternal._errno);
                        }
                        _loc12_ = li32(_loc5_ + 44);
                        _loc21_ = li32(_loc5_ + 28);
                        _loc4_ -= 16;
                        si32(_loc18_,_loc4_ + 8);
                        si32(_loc19_,_loc4_ + 4);
                        si32(_loc21_,_loc4_);
                        wdnative.ESP = _loc4_;
                        wdnative.ptr2fun[_loc12_]();
                        _loc4_ += 16;
                        _loc10_ = wdnative.eax;
                        _loc16_ = li16(_loc5_ + 12);
                        if(_loc10_ < 0)
                        {
                           _loc16_ &= 61439;
                           si16(_loc16_,_loc5_ + 12);
                           break;
                        }
                        while(true)
                        {
                           _loc21_ = _loc16_ & 0x1100;
                           if(_loc21_ == 4352)
                           {
                              var _temp_94:* = _loc10_ ^ -1;
                              _loc15_ = li32(_loc5_ + 80);
                              _loc1_ = 1;
                              _loc11_ = _loc1_;
                              if(uint(_loc15_) <= uint(_temp_94))
                              {
                                 _loc11_ = 0;
                              }
                              _loc17_ = li32(_loc5_ + 84);
                              _loc14_ = _loc10_ >> 31;
                              _loc8_ = 2147483647 - _loc14_;
                              if(_loc17_ <= _loc8_)
                              {
                                 _loc1_ = 0;
                              }
                              if(_loc17_ != _loc8_)
                              {
                                 _loc11_ = _loc1_;
                              }
                              if(_loc11_ == 0)
                              {
                                 _loc1_ = _loc15_ + _loc10_;
                                 si32(_loc1_,_loc5_ + 80);
                                 _loc8_ = _loc11_ = 1;
                                 if(uint(_loc1_) >= uint(_loc15_))
                                 {
                                    _loc8_ = 0;
                                 }
                                 if(uint(_loc1_) >= uint(_loc10_))
                                 {
                                    _loc11_ = _loc8_;
                                 }
                                 _loc21_ = _loc17_ + _loc14_;
                                 _loc21_ = _loc21_ + _loc11_;
                                 si32(_loc21_,_loc5_ + 84);
                                 break;
                              }
                           }
                           _loc16_ &= 61439;
                           si16(_loc16_,_loc5_ + 12);
                           break;
                        }
                        if(_loc10_ <= 0)
                        {
                           break;
                        }
                        continue loop6;
                     }
                     _loc21_ = _loc16_ | 0x40;
                     si16(_loc21_,_loc5_ + 12);
                     _loc18_ = -1;
                     break loop9;
                     _loc19_ += _loc10_;
                     _loc18_ -= _loc10_;
                  }
                  break loop9;
               }
            }
            break;
         }
         _loc18_ = _loc20_;
         break;
      }
      addr0bc8:
      wdnative.eax = _loc18_;
      wdnative.ESP = _loc4_ = _loc9_;
   }
}

