package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F___sfvwrite() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc24_:int = 0;
      var _loc10_:int = 0;
      var _loc22_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc26_:int = 0;
      var _loc11_:int = 0;
      var _loc23_:int = 0;
      var _loc9_:int = 0;
      var _loc3_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:int = 0;
      var _loc16_:int = 0;
      var _loc4_:int = 0;
      var _loc25_:int = 0;
      var _loc12_:int = 0;
      var _loc17_:int = 0;
      var _loc19_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc18_:int = 0;
      var _loc13_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      _loc10_ = li32(_loc2_ + 4);
      _loc26_ = li32(_loc10_ + 8);
      _loc25_ = 0;
      if(_loc26_ != 0)
      {
         while(true)
         {
            _loc24_ = li32(_loc2_);
            _loc23_ = li16(_loc24_ + 12);
            _loc26_ = _loc23_ & 8;
            if(_loc26_ != 0)
            {
               _loc26_ = li32(_loc24_ + 16);
               if(_loc26_ != 0)
               {
                  break;
               }
               _loc26_ = _loc23_ & 0x0200;
               if(_loc26_ != 0)
               {
                  break;
               }
            }
            _loc1_ -= 16;
            si32(_loc24_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative_nternal.F___swsetup();
            _loc25_ = -1;
            _loc1_ += 16;
            _loc26_ = wdnative.eax;
            if(_loc26_ == 0)
            {
               _loc23_ = li16(_loc24_ + 12);
               break;
            }
         }
         _loc26_ = _loc23_ & 2;
         _loc22_ = li32(_loc10_);
         _loc21_ = li32(_loc22_ + 4);
         _loc20_ = li32(_loc22_);
         if(_loc26_ != 0)
         {
            _loc22_ += 12;
            loop0:
            while(true)
            {
               while(_loc21_ != 0)
               {
                  _loc23_ = 1024;
                  if(uint(_loc21_) <= uint(_loc23_))
                  {
                     _loc23_ = _loc21_;
                  }
                  _loc26_ = li8(_loc24_ + 13);
                  _loc26_ = _loc26_ & 1;
                  if(_loc26_ != 0)
                  {
                     _loc19_ = li32(wdnative_nternal._errno);
                     _loc1_ -= 16;
                     si32(2,_loc1_ + 4);
                     si32(_loc24_,_loc1_);
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F__sseek();
                     _loc1_ += 16;
                     _loc26_ = wdnative.eax & wdnative.edx;
                     if(_loc26_ == -1)
                     {
                        _loc26_ = li8(_loc24_ + 13);
                        _loc26_ = _loc26_ & 4;
                        if(_loc26_ != 0)
                        {
                           addr1aab:
                           _loc26_ = li16(_loc24_ + 12);
                           _loc26_ = _loc26_ | 0x40;
                           si16(_loc26_,_loc24_ + 12);
                           _loc25_ = -1;
                           break loop0;
                           var _temp_11:* = int(_loc22_ + 8);
                           _loc21_ = li32(_loc22_);
                           _loc20_ = li32(_loc22_ - 4);
                           _loc22_ += 8;
                           break;
                        }
                     }
                     si32(_loc19_,wdnative_nternal._errno);
                  }
                  _loc26_ = li32(_loc24_ + 44);
                  var _loc7_:int = li32(_loc24_ + 28);
                  _loc1_ -= 16;
                  si32(_loc23_,_loc1_ + 8);
                  si32(_loc20_,_loc1_ + 4);
                  si32(_loc7_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative.ptr2fun[_loc26_]();
                  _loc1_ += 16;
                  _loc23_ = wdnative.eax;
                  _loc15_ = li16(_loc24_ + 12);
                  if(_loc23_ < 0)
                  {
                     _loc26_ = _loc15_ & 0xEFFF;
                     si16(_loc26_,_loc24_ + 12);
                     addr1aab:
                     _loc26_ = li16(_loc24_ + 12);
                     _loc26_ = _loc26_ | 0x40;
                     si16(_loc26_,_loc24_ + 12);
                     _loc25_ = -1;
                     break loop0;
                     var _temp_11:* = int(_loc22_ + 8);
                     _loc21_ = li32(_loc22_);
                     _loc20_ = li32(_loc22_ - 4);
                     _loc22_ += 8;
                     break;
                  }
                  while(true)
                  {
                     _loc26_ = _loc15_ & 0x1100;
                     if(_loc26_ == 4352)
                     {
                        var _temp_21:* = _loc23_ ^ -1;
                        _loc25_ = li32(_loc24_ + 80);
                        _loc17_ = _loc16_ = 1;
                        if(uint(_loc25_) <= uint(_temp_21))
                        {
                           _loc17_ = 0;
                        }
                        _loc18_ = li32(_loc24_ + 84);
                        _loc19_ = _loc23_ >> 31;
                        _loc11_ = 2147483647 - _loc19_;
                        if(_loc18_ <= _loc11_)
                        {
                           _loc16_ = 0;
                        }
                        if(_loc18_ != _loc11_)
                        {
                           _loc17_ = _loc16_;
                        }
                        if(_loc17_ == 0)
                        {
                           _loc15_ = _loc25_ + _loc23_;
                           si32(_loc15_,_loc24_ + 80);
                           _loc16_ = _loc11_ = 1;
                           if(uint(_loc15_) >= uint(_loc25_))
                           {
                              _loc16_ = 0;
                           }
                           if(uint(_loc15_) >= uint(_loc23_))
                           {
                              _loc11_ = _loc16_;
                           }
                           _loc26_ = _loc18_ + _loc19_;
                           _loc26_ = _loc26_ + _loc11_;
                           si32(_loc26_,_loc24_ + 84);
                           break;
                        }
                     }
                     _loc26_ = _loc15_ & 0xEFFF;
                     si16(_loc26_,_loc24_ + 12);
                     break;
                  }
                  if(_loc23_ < 1)
                  {
                     addr1aab:
                     _loc26_ = li16(_loc24_ + 12);
                     _loc26_ = _loc26_ | 0x40;
                     si16(_loc26_,_loc24_ + 12);
                     _loc25_ = -1;
                     break loop0;
                     var _temp_11:* = int(_loc22_ + 8);
                     _loc21_ = li32(_loc22_);
                     _loc20_ = li32(_loc22_ - 4);
                     _loc22_ += 8;
                     break;
                  }
                  _loc26_ = li32(_loc10_ + 8);
                  _loc7_ = _loc26_ - _loc23_;
                  si32(_loc7_,_loc10_ + 8);
                  _loc21_ -= _loc23_;
                  _loc20_ += _loc23_;
                  _loc25_ = 0;
                  if(_loc26_ == _loc23_)
                  {
                     break loop0;
                  }
               }
            }
         }
         else
         {
            _loc26_ = _loc23_ & 0xFFFF;
            _loc26_ = _loc26_ & 1;
            if(_loc26_ == 0)
            {
               _loc22_ += 12;
               loop2:
               while(true)
               {
                  loop5:
                  while(_loc21_ != 0)
                  {
                     loop21:
                     while(true)
                     {
                        _loc19_ = li16(_loc24_ + 12);
                        _loc26_ = _loc19_ & 0x4200;
                        if(_loc26_ == 16896)
                        {
                           _loc26_ = li32(_loc24_ + 8);
                           if((uint(_loc26_)) < uint(_loc21_))
                           {
                              _loc23_ = li32(_loc24_ + 16);
                              var _temp_38:* = li32(_loc24_);
                              si32(_loc7_ = _loc21_ + 128,_loc24_ + 8);
                              _loc19_ = _temp_38 - _loc23_;
                              _loc26_ = _loc19_ + _loc21_;
                              _loc7_ = _loc26_ + 128;
                              si32(_loc7_,_loc24_ + 20);
                              _loc25_ = _loc26_ + 129;
                              _loc1_ -= 16;
                              si32(_loc25_,_loc1_ + 4);
                              si32(_loc23_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative_nternal.F_realloc();
                              _loc1_ += 16;
                              _loc18_ = wdnative.eax;
                              if(_loc18_ == 0)
                              {
                                 if(_loc23_ != 0)
                                 {
                                    if(_loc25_ != 0)
                                    {
                                       _loc1_ -= 16;
                                       si32(_loc23_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative_nternal.F_idalloc();
                                       _loc1_ += 16;
                                    }
                                 }
                              }
                              si32(_loc18_,_loc24_ + 16);
                              if(_loc18_ == 0)
                              {
                                 break;
                              }
                              _loc26_ = _loc18_ + _loc19_;
                              si32(_loc26_,_loc24_);
                              _loc19_ = li16(_loc24_ + 12);
                           }
                        }
                        _loc23_ = li32(_loc24_ + 8);
                        _loc26_ = _loc19_ & 0x0200;
                        if(_loc26_ != 0)
                        {
                           _loc19_ = _loc21_;
                           if(uint(_loc23_) <= uint(_loc21_))
                           {
                              _loc19_ = _loc23_;
                           }
                           _loc23_ = _loc21_;
                           if(_loc19_ >= 1)
                           {
                              var _temp_47:* = li32(_loc24_);
                              _loc1_ -= 16;
                              si32(_loc20_,_loc1_ + 4);
                              si32(_temp_47,_loc1_);
                              si32(_loc19_,_loc1_ + 8);
                              wdnative.ESP = _loc1_;
                              wdnative.Fmemcpy();
                              _loc1_ += 16;
                              _loc26_ = li32(_loc24_ + 8);
                              _loc26_ = _loc26_ - _loc19_;
                              si32(_loc26_,_loc24_ + 8);
                              _loc26_ = li32(_loc24_);
                              _loc26_ = _loc26_ + _loc19_;
                              si32(_loc26_,_loc24_);
                              _loc23_ = _loc21_;
                           }
                        }
                        else
                        {
                           _loc18_ = li32(_loc24_);
                           var _temp_53:* = li32(_loc24_ + 16);
                           while(true)
                           {
                              if(uint(_loc18_) > uint(_temp_53))
                              {
                                 if(uint(_loc23_) < uint(_loc21_))
                                 {
                                    _loc1_ -= 16;
                                    si32(_loc20_,_loc1_ + 4);
                                    si32(_loc18_,_loc1_);
                                    si32(_loc23_,_loc1_ + 8);
                                    wdnative.ESP = _loc1_;
                                    wdnative.Fmemcpy();
                                    _loc1_ += 16;
                                    _loc26_ = li32(_loc24_);
                                    _loc25_ = _loc26_ + _loc23_;
                                    si32(_loc25_,_loc24_);
                                    _loc18_ = 0;
                                    _loc19_ = wdnative_nternal.___sglue;
                                    if(_loc24_ == 0)
                                    {
                                       do
                                       {
                                          _loc15_ = li32(_loc19_ + 4);
                                          if(_loc15_ >= 1)
                                          {
                                             _loc25_ = li32(_loc19_ + 8);
                                             do
                                             {
                                                _loc11_ = si16(li16(_loc25_ + 12));
                                                if(_loc11_ >= 1)
                                                {
                                                   var _temp_61:* = _loc11_ & 8;
                                                   _loc12_ = 0;
                                                   if(_temp_61 != 0)
                                                   {
                                                      _loc16_ = li32(_loc25_ + 16);
                                                      _loc12_ = 0;
                                                      if(_loc16_ != 0)
                                                      {
                                                         _loc17_ = li32(_loc25_);
                                                         si32(_loc16_,_loc25_);
                                                         var _temp_62:* = _loc11_ & 3;
                                                         _loc12_ = 0;
                                                         if(_temp_62 == 0)
                                                         {
                                                            _loc12_ = li32(_loc25_ + 20);
                                                         }
                                                         _loc17_ -= _loc16_;
                                                         si32(_loc12_,_loc25_ + 8);
                                                         loop14:
                                                         while(true)
                                                         {
                                                            _loc12_ = 0;
                                                            if(_loc17_ <= 0)
                                                            {
                                                               break;
                                                            }
                                                            while(true)
                                                            {
                                                               _loc26_ = _loc11_ & 0x0100;
                                                               if(_loc26_ != 0)
                                                               {
                                                                  _loc12_ = li32(wdnative_nternal._errno);
                                                                  _loc1_ -= 16;
                                                                  si32(2,_loc1_ + 4);
                                                                  si32(_loc25_,_loc1_);
                                                                  wdnative.ESP = _loc1_;
                                                                  wdnative_nternal.F__sseek();
                                                                  _loc1_ += 16;
                                                                  _loc26_ = wdnative.eax & wdnative.edx;
                                                                  if(_loc26_ == -1)
                                                                  {
                                                                     _loc11_ = li16(_loc25_ + 12);
                                                                     _loc26_ = _loc11_ & 0x0400;
                                                                     if(_loc26_ != 0)
                                                                     {
                                                                        break;
                                                                     }
                                                                  }
                                                                  si32(_loc12_,wdnative_nternal._errno);
                                                               }
                                                               _loc26_ = li32(_loc25_ + 44);
                                                               _loc7_ = li32(_loc25_ + 28);
                                                               _loc1_ -= 16;
                                                               si32(_loc17_,_loc1_ + 8);
                                                               si32(_loc16_,_loc1_ + 4);
                                                               si32(_loc7_,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative.ptr2fun[_loc26_]();
                                                               _loc1_ += 16;
                                                               _loc13_ = wdnative.eax;
                                                               _loc11_ = li16(_loc25_ + 12);
                                                               if(_loc13_ < 0)
                                                               {
                                                                  _loc11_ &= 61439;
                                                                  si16(_loc11_,_loc25_ + 12);
                                                                  break;
                                                               }
                                                               while(true)
                                                               {
                                                                  _loc26_ = _loc11_ & 0x1100;
                                                                  if(_loc26_ == 4352)
                                                                  {
                                                                     var _temp_71:* = _loc13_ ^ -1;
                                                                     _loc14_ = li32(_loc25_ + 80);
                                                                     _loc8_ = _loc9_ = 1;
                                                                     if(uint(_loc14_) <= uint(_temp_71))
                                                                     {
                                                                        _loc8_ = 0;
                                                                     }
                                                                     _loc6_ = li32(_loc25_ + 84);
                                                                     _loc12_ = _loc13_ >> 31;
                                                                     _loc4_ = 2147483647 - _loc12_;
                                                                     if(_loc6_ <= _loc4_)
                                                                     {
                                                                        _loc9_ = 0;
                                                                     }
                                                                     if(_loc6_ != _loc4_)
                                                                     {
                                                                        _loc8_ = _loc9_;
                                                                     }
                                                                     if(_loc8_ == 0)
                                                                     {
                                                                        _loc9_ = _loc14_ + _loc13_;
                                                                        si32(_loc9_,_loc25_ + 80);
                                                                        _loc4_ = _loc8_ = 1;
                                                                        if(uint(_loc9_) >= uint(_loc14_))
                                                                        {
                                                                           _loc4_ = 0;
                                                                        }
                                                                        if(uint(_loc9_) >= uint(_loc13_))
                                                                        {
                                                                           _loc8_ = _loc4_;
                                                                        }
                                                                        _loc26_ = _loc6_ + _loc12_;
                                                                        _loc26_ = _loc26_ + _loc8_;
                                                                        si32(_loc26_,_loc25_ + 84);
                                                                        break;
                                                                     }
                                                                  }
                                                                  _loc11_ &= 61439;
                                                                  si16(_loc11_,_loc25_ + 12);
                                                                  break;
                                                               }
                                                               if(_loc13_ <= 0)
                                                               {
                                                                  break;
                                                               }
                                                               continue loop14;
                                                            }
                                                            _loc26_ = _loc11_ | 0x40;
                                                            si16(_loc26_,_loc25_ + 12);
                                                            _loc12_ = -1;
                                                            break;
                                                            _loc16_ += _loc13_;
                                                            _loc17_ -= _loc13_;
                                                         }
                                                      }
                                                   }
                                                   _loc18_ = _loc12_ | _loc18_;
                                                }
                                                _loc25_ += 232;
                                             }
                                             while(_loc15_ += -1, _loc15_ != 0);
                                          }
                                       }
                                       while(_loc19_ = li32(_loc19_), _loc19_ != 0);
                                       if(_loc18_ != 0)
                                       {
                                          break loop21;
                                       }
                                       break;
                                    }
                                    _loc18_ = si16(li16(_loc24_ + 12));
                                    _loc26_ = _loc18_ & 0x18;
                                    if(_loc26_ == 0)
                                    {
                                       si32(9,wdnative_nternal._errno);
                                       break loop21;
                                    }
                                    _loc26_ = _loc18_ & 8;
                                    if(_loc26_ != 0)
                                    {
                                       _loc19_ = li32(_loc24_ + 16);
                                       if(_loc19_ != 0)
                                       {
                                          si32(_loc19_,_loc24_);
                                          var _temp_82:* = _loc18_ & 3;
                                          _loc15_ = 0;
                                          if(_temp_82 == 0)
                                          {
                                             _loc15_ = li32(_loc24_ + 20);
                                          }
                                          _loc25_ -= _loc19_;
                                          si32(_loc15_,_loc24_ + 8);
                                          while(_loc25_ > 0)
                                          {
                                             _loc26_ = _loc18_ & 0x0100;
                                             if(_loc26_ != 0)
                                             {
                                                _loc15_ = li32(wdnative_nternal._errno);
                                                _loc1_ -= 16;
                                                si32(2,_loc1_ + 4);
                                                si32(_loc24_,_loc1_);
                                                wdnative.ESP = _loc1_;
                                                wdnative_nternal.F__sseek();
                                                _loc1_ += 16;
                                                _loc26_ = wdnative.eax & wdnative.edx;
                                                if(_loc26_ == -1)
                                                {
                                                   _loc18_ = li16(_loc24_ + 12);
                                                   _loc26_ = _loc18_ & 0x0400;
                                                   if(_loc26_ != 0)
                                                   {
                                                      _loc26_ = _loc18_ | 0x40;
                                                      si16(_loc26_,_loc24_ + 12);
                                                      §§goto(addr1aab);
                                                      var _temp_33:* = int(_loc22_ + 8);
                                                      _loc21_ = li32(_loc22_);
                                                      _loc20_ = li32(_loc22_ - 4);
                                                      _loc22_ += 8;
                                                      break loop5;
                                                   }
                                                }
                                                si32(_loc15_,wdnative_nternal._errno);
                                             }
                                             _loc26_ = li32(_loc24_ + 44);
                                             _loc7_ = li32(_loc24_ + 28);
                                             _loc1_ -= 16;
                                             si32(_loc25_,_loc1_ + 8);
                                             si32(_loc19_,_loc1_ + 4);
                                             si32(_loc7_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative.ptr2fun[_loc26_]();
                                             _loc1_ += 16;
                                             _loc15_ = wdnative.eax;
                                             _loc18_ = li16(_loc24_ + 12);
                                             if(_loc15_ < 0)
                                             {
                                                _loc18_ &= 61439;
                                                si16(_loc18_,_loc24_ + 12);
                                                _loc26_ = _loc18_ | 0x40;
                                                si16(_loc26_,_loc24_ + 12);
                                                §§goto(addr1aab);
                                                var _temp_33:* = int(_loc22_ + 8);
                                                _loc21_ = li32(_loc22_);
                                                _loc20_ = li32(_loc22_ - 4);
                                                _loc22_ += 8;
                                                break loop5;
                                             }
                                             while(true)
                                             {
                                                _loc26_ = _loc18_ & 0x1100;
                                                if(_loc26_ == 4352)
                                                {
                                                   var _temp_91:* = _loc15_ ^ -1;
                                                   _loc11_ = li32(_loc24_ + 80);
                                                   _loc14_ = _loc6_ = 1;
                                                   if(uint(_loc11_) <= uint(_temp_91))
                                                   {
                                                      _loc14_ = 0;
                                                   }
                                                   _loc17_ = li32(_loc24_ + 84);
                                                   _loc16_ = _loc15_ >> 31;
                                                   _loc12_ = 2147483647 - _loc16_;
                                                   if(_loc17_ <= _loc12_)
                                                   {
                                                      _loc6_ = 0;
                                                   }
                                                   if(_loc17_ != _loc12_)
                                                   {
                                                      _loc14_ = _loc6_;
                                                   }
                                                   if(_loc14_ == 0)
                                                   {
                                                      _loc12_ = _loc11_ + _loc15_;
                                                      si32(_loc12_,_loc24_ + 80);
                                                      _loc14_ = _loc6_ = 1;
                                                      if(uint(_loc12_) >= uint(_loc11_))
                                                      {
                                                         _loc14_ = 0;
                                                      }
                                                      if(uint(_loc12_) >= uint(_loc15_))
                                                      {
                                                         _loc6_ = _loc14_;
                                                      }
                                                      _loc26_ = _loc17_ + _loc16_;
                                                      _loc26_ = _loc26_ + _loc6_;
                                                      si32(_loc26_,_loc24_ + 84);
                                                      break;
                                                   }
                                                }
                                                _loc18_ &= 61439;
                                                si16(_loc18_,_loc24_ + 12);
                                                break;
                                             }
                                             if(_loc15_ <= 0)
                                             {
                                                _loc26_ = _loc18_ | 0x40;
                                                si16(_loc26_,_loc24_ + 12);
                                                §§goto(addr1aab);
                                                var _temp_33:* = int(_loc22_ + 8);
                                                _loc21_ = li32(_loc22_);
                                                _loc20_ = li32(_loc22_ - 4);
                                                _loc22_ += 8;
                                                break loop5;
                                             }
                                             _loc19_ += _loc15_;
                                             _loc25_ -= _loc15_;
                                          }
                                       }
                                    }
                                    break;
                                 }
                              }
                              _loc23_ = li32(_loc24_ + 20);
                              if((uint(_loc23_)) <= uint(_loc21_))
                              {
                                 _loc26_ = _loc19_ & 0xFFFF;
                                 _loc26_ = _loc26_ & 0x0100;
                                 if(_loc26_ != 0)
                                 {
                                    _loc19_ = li32(wdnative_nternal._errno);
                                    _loc1_ -= 16;
                                    si32(2,_loc1_ + 4);
                                    si32(_loc24_,_loc1_);
                                    wdnative.ESP = _loc1_;
                                    wdnative_nternal.F__sseek();
                                    _loc1_ += 16;
                                    _loc26_ = wdnative.eax & wdnative.edx;
                                    if(_loc26_ == -1)
                                    {
                                       _loc26_ = li8(_loc24_ + 13);
                                       _loc26_ = _loc26_ & 4;
                                       if(_loc26_ != 0)
                                       {
                                          break loop21;
                                       }
                                    }
                                    si32(_loc19_,wdnative_nternal._errno);
                                 }
                                 _loc26_ = li32(_loc24_ + 44);
                                 _loc7_ = li32(_loc24_ + 28);
                                 _loc1_ -= 16;
                                 si32(_loc23_,_loc1_ + 8);
                                 si32(_loc20_,_loc1_ + 4);
                                 si32(_loc7_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative.ptr2fun[_loc26_]();
                                 _loc1_ += 16;
                                 _loc23_ = wdnative.eax;
                                 _loc15_ = li16(_loc24_ + 12);
                                 if(_loc23_ >= 0)
                                 {
                                    while(true)
                                    {
                                       _loc26_ = _loc15_ & 0x1100;
                                       if(_loc26_ == 4352)
                                       {
                                          var _temp_107:* = _loc23_ ^ -1;
                                          _loc19_ = li32(_loc24_ + 80);
                                          _loc17_ = _loc11_ = 1;
                                          if(uint(_loc19_) <= uint(_temp_107))
                                          {
                                             _loc17_ = 0;
                                          }
                                          _loc25_ = li32(_loc24_ + 84);
                                          _loc18_ = _loc23_ >> 31;
                                          _loc16_ = 2147483647 - _loc18_;
                                          if(_loc25_ <= _loc16_)
                                          {
                                             _loc11_ = 0;
                                          }
                                          if(_loc25_ != _loc16_)
                                          {
                                             _loc17_ = _loc11_;
                                          }
                                          if(_loc17_ == 0)
                                          {
                                             _loc11_ = _loc19_ + _loc23_;
                                             si32(_loc11_,_loc24_ + 80);
                                             _loc15_ = _loc16_ = 1;
                                             if(uint(_loc11_) >= uint(_loc19_))
                                             {
                                                _loc15_ = 0;
                                             }
                                             if(uint(_loc11_) >= uint(_loc23_))
                                             {
                                                _loc16_ = _loc15_;
                                             }
                                             _loc26_ = _loc25_ + _loc18_;
                                             _loc26_ = _loc26_ + _loc16_;
                                             si32(_loc26_,_loc24_ + 84);
                                             break;
                                          }
                                       }
                                       _loc26_ = _loc15_ & 0xEFFF;
                                       si16(_loc26_,_loc24_ + 12);
                                       break;
                                    }
                                    if(_loc23_ >= 1)
                                    {
                                       break;
                                    }
                                    break loop21;
                                 }
                                 _loc26_ = _loc15_ & 0xEFFF;
                                 si16(_loc26_,_loc24_ + 12);
                                 break loop21;
                              }
                              _loc1_ -= 16;
                              si32(_loc20_,_loc1_ + 4);
                              si32(_loc18_,_loc1_);
                              si32(_loc21_,_loc1_ + 8);
                              wdnative.ESP = _loc1_;
                              wdnative.Fmemcpy();
                              _loc1_ += 16;
                              _loc26_ = li32(_loc24_ + 8);
                              _loc26_ = _loc26_ - _loc21_;
                              si32(_loc26_,_loc24_ + 8);
                              _loc26_ = li32(_loc24_);
                              _loc26_ = _loc26_ + _loc21_;
                              si32(_loc26_,_loc24_);
                              _loc23_ = _loc21_;
                              break;
                           }
                        }
                        _loc26_ = li32(_loc10_ + 8);
                        _loc7_ = _loc26_ - _loc23_;
                        si32(_loc7_,_loc10_ + 8);
                        _loc21_ -= _loc23_;
                        _loc20_ += _loc23_;
                        _loc25_ = 0;
                        if(_loc26_ == _loc23_)
                        {
                           break loop2;
                        }
                        continue loop5;
                     }
                     §§goto(addr1aab);
                  }
               }
            }
            else
            {
               _loc22_ += 12;
               _loc23_ = 0;
               loop1:
               while(true)
               {
                  _loc18_ = 0;
                  loop4:
                  while(_loc21_ != 0)
                  {
                     _loc19_ = 0;
                     if(_loc18_ == 0)
                     {
                        while(true)
                        {
                           _loc23_ = _loc20_ + _loc19_;
                           _loc26_ = li8(_loc23_);
                           if(_loc26_ != 10)
                           {
                              _loc19_ += 1;
                              if(_loc21_ != _loc19_)
                              {
                                 continue;
                              }
                           }
                           else if(_loc23_ != 0)
                           {
                              _loc23_ = _loc19_ + 1;
                              _loc18_ = 1;
                              break;
                           }
                           _loc23_ = _loc21_ + 1;
                           _loc18_ = 1;
                           break;
                        }
                     }
                     _loc15_ = _loc23_;
                     if(uint(_loc23_) > uint(_loc21_))
                     {
                        _loc15_ = _loc21_;
                     }
                     _loc25_ = li32(_loc24_ + 20);
                     _loc11_ = li32(_loc24_);
                     _loc26_ = li32(_loc24_ + 16);
                     loop27:
                     while(true)
                     {
                        while(true)
                        {
                           if(uint(_loc11_) > uint(_loc26_))
                           {
                              var _temp_166:* = li32(_loc24_ + 8);
                              _loc19_ = _loc25_ + _temp_166;
                              if(_loc15_ > _loc19_)
                              {
                                 _loc1_ -= 16;
                                 si32(_loc20_,_loc1_ + 4);
                                 si32(_loc11_,_loc1_);
                                 si32(_loc19_,_loc1_ + 8);
                                 wdnative.ESP = _loc1_;
                                 wdnative.Fmemcpy();
                                 _loc1_ += 16;
                                 _loc26_ = li32(_loc24_);
                                 _loc11_ = _loc26_ + _loc19_;
                                 si32(_loc11_,_loc24_);
                                 _loc15_ = 0;
                                 _loc25_ = wdnative_nternal.___sglue;
                                 if(_loc24_ == 0)
                                 {
                                    do
                                    {
                                       _loc16_ = li32(_loc25_ + 4);
                                       if(_loc16_ >= 1)
                                       {
                                          _loc11_ = li32(_loc25_ + 8);
                                          do
                                          {
                                             _loc12_ = si16(li16(_loc11_ + 12));
                                             if(_loc12_ >= 1)
                                             {
                                                var _temp_174:* = _loc12_ & 8;
                                                _loc14_ = 0;
                                                if(_temp_174 != 0)
                                                {
                                                   _loc17_ = li32(_loc11_ + 16);
                                                   _loc14_ = 0;
                                                   if(_loc17_ != 0)
                                                   {
                                                      _loc6_ = li32(_loc11_);
                                                      si32(_loc17_,_loc11_);
                                                      var _temp_175:* = _loc12_ & 3;
                                                      _loc14_ = 0;
                                                      if(_temp_175 == 0)
                                                      {
                                                         _loc14_ = li32(_loc11_ + 20);
                                                      }
                                                      _loc6_ -= _loc17_;
                                                      si32(_loc14_,_loc11_ + 8);
                                                      loop12:
                                                      while(true)
                                                      {
                                                         _loc14_ = 0;
                                                         if(_loc6_ <= 0)
                                                         {
                                                            break;
                                                         }
                                                         while(true)
                                                         {
                                                            _loc26_ = _loc12_ & 0x0100;
                                                            if(_loc26_ != 0)
                                                            {
                                                               _loc14_ = li32(wdnative_nternal._errno);
                                                               _loc1_ -= 16;
                                                               si32(2,_loc1_ + 4);
                                                               si32(_loc11_,_loc1_);
                                                               wdnative.ESP = _loc1_;
                                                               wdnative_nternal.F__sseek();
                                                               _loc1_ += 16;
                                                               _loc26_ = wdnative.eax & wdnative.edx;
                                                               if(_loc26_ == -1)
                                                               {
                                                                  _loc12_ = li16(_loc11_ + 12);
                                                                  _loc26_ = _loc12_ & 0x0400;
                                                                  if(_loc26_ != 0)
                                                                  {
                                                                     break;
                                                                  }
                                                               }
                                                               si32(_loc14_,wdnative_nternal._errno);
                                                            }
                                                            _loc7_ = li32(_loc11_ + 44);
                                                            _loc26_ = li32(_loc11_ + 28);
                                                            _loc1_ -= 16;
                                                            si32(_loc6_,_loc1_ + 8);
                                                            si32(_loc17_,_loc1_ + 4);
                                                            si32(_loc26_,_loc1_);
                                                            wdnative.ESP = _loc1_;
                                                            wdnative.ptr2fun[_loc7_]();
                                                            _loc1_ += 16;
                                                            _loc9_ = wdnative.eax;
                                                            _loc12_ = li16(_loc11_ + 12);
                                                            if(_loc9_ < 0)
                                                            {
                                                               _loc12_ &= 61439;
                                                               si16(_loc12_,_loc11_ + 12);
                                                               break;
                                                            }
                                                            while(true)
                                                            {
                                                               _loc26_ = _loc12_ & 0x1100;
                                                               if(_loc26_ == 4352)
                                                               {
                                                                  var _temp_184:* = _loc9_ ^ -1;
                                                                  _loc4_ = li32(_loc11_ + 80);
                                                                  _loc3_ = _loc5_ = 1;
                                                                  if(uint(_loc4_) <= uint(_temp_184))
                                                                  {
                                                                     _loc3_ = 0;
                                                                  }
                                                                  _loc13_ = li32(_loc11_ + 84);
                                                                  _loc14_ = _loc9_ >> 31;
                                                                  _loc8_ = 2147483647 - _loc14_;
                                                                  if(_loc13_ <= _loc8_)
                                                                  {
                                                                     _loc5_ = 0;
                                                                  }
                                                                  if(_loc13_ != _loc8_)
                                                                  {
                                                                     _loc3_ = _loc5_;
                                                                  }
                                                                  if(_loc3_ == 0)
                                                                  {
                                                                     _loc5_ = _loc4_ + _loc9_;
                                                                     si32(_loc5_,_loc11_ + 80);
                                                                     _loc3_ = _loc8_ = 1;
                                                                     if(uint(_loc5_) >= uint(_loc4_))
                                                                     {
                                                                        _loc3_ = 0;
                                                                     }
                                                                     if(uint(_loc5_) >= uint(_loc9_))
                                                                     {
                                                                        _loc8_ = _loc3_;
                                                                     }
                                                                     _loc26_ = _loc13_ + _loc14_;
                                                                     _loc26_ = _loc26_ + _loc8_;
                                                                     si32(_loc26_,_loc11_ + 84);
                                                                     break;
                                                                  }
                                                               }
                                                               _loc12_ &= 61439;
                                                               si16(_loc12_,_loc11_ + 12);
                                                               break;
                                                            }
                                                            if(_loc9_ <= 0)
                                                            {
                                                               break;
                                                            }
                                                            continue loop12;
                                                         }
                                                         _loc26_ = _loc12_ | 0x40;
                                                         si16(_loc26_,_loc11_ + 12);
                                                         _loc14_ = -1;
                                                         break;
                                                         _loc17_ += _loc9_;
                                                         _loc6_ -= _loc9_;
                                                      }
                                                   }
                                                }
                                                _loc15_ = _loc14_ | _loc15_;
                                             }
                                             _loc11_ += 232;
                                          }
                                          while(_loc16_ += -1, _loc16_ != 0);
                                       }
                                    }
                                    while(_loc25_ = li32(_loc25_), _loc25_ != 0);
                                    if(_loc15_ != 0)
                                    {
                                       break;
                                    }
                                    break loop27;
                                 }
                                 _loc25_ = si16(li16(_loc24_ + 12));
                                 _loc26_ = _loc25_ & 0x18;
                                 if(_loc26_ == 0)
                                 {
                                    si32(9,wdnative_nternal._errno);
                                    break;
                                 }
                                 _loc26_ = _loc25_ & 8;
                                 if(_loc26_ != 0)
                                 {
                                    _loc15_ = li32(_loc24_ + 16);
                                    if(_loc15_ != 0)
                                    {
                                       si32(_loc15_,_loc24_);
                                       var _temp_195:* = _loc25_ & 3;
                                       _loc16_ = 0;
                                       if(_temp_195 == 0)
                                       {
                                          _loc16_ = li32(_loc24_ + 20);
                                       }
                                       _loc11_ -= _loc15_;
                                       si32(_loc16_,_loc24_ + 8);
                                       while(_loc11_ > 0)
                                       {
                                          _loc26_ = _loc25_ & 0x0100;
                                          if(_loc26_ != 0)
                                          {
                                             _loc16_ = li32(wdnative_nternal._errno);
                                             _loc1_ -= 16;
                                             si32(2,_loc1_ + 4);
                                             si32(_loc24_,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F__sseek();
                                             _loc1_ += 16;
                                             _loc26_ = wdnative.eax & wdnative.edx;
                                             if(_loc26_ == -1)
                                             {
                                                _loc25_ = li16(_loc24_ + 12);
                                                _loc26_ = _loc25_ & 0x0400;
                                                if(_loc26_ != 0)
                                                {
                                                   _loc26_ = _loc25_ | 0x40;
                                                   si16(_loc26_,_loc24_ + 12);
                                                   §§goto(addr1aab);
                                                   var _temp_121:* = int(_loc22_ + 8);
                                                   _loc21_ = li32(_loc22_);
                                                   _loc20_ = li32(_loc22_ - 4);
                                                   _loc22_ += 8;
                                                   break loop4;
                                                }
                                             }
                                             si32(_loc16_,wdnative_nternal._errno);
                                          }
                                          _loc7_ = li32(_loc24_ + 44);
                                          _loc26_ = li32(_loc24_ + 28);
                                          _loc1_ -= 16;
                                          si32(_loc11_,_loc1_ + 8);
                                          si32(_loc15_,_loc1_ + 4);
                                          si32(_loc26_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative.ptr2fun[_loc7_]();
                                          _loc1_ += 16;
                                          _loc16_ = wdnative.eax;
                                          _loc25_ = li16(_loc24_ + 12);
                                          if(_loc16_ < 0)
                                          {
                                             _loc25_ &= 61439;
                                             si16(_loc25_,_loc24_ + 12);
                                             _loc26_ = _loc25_ | 0x40;
                                             si16(_loc26_,_loc24_ + 12);
                                             §§goto(addr1aab);
                                             var _temp_121:* = int(_loc22_ + 8);
                                             _loc21_ = li32(_loc22_);
                                             _loc20_ = li32(_loc22_ - 4);
                                             _loc22_ += 8;
                                             break loop4;
                                          }
                                          while(true)
                                          {
                                             _loc26_ = _loc25_ & 0x1100;
                                             if(_loc26_ == 4352)
                                             {
                                                var _temp_204:* = _loc16_ ^ -1;
                                                _loc17_ = li32(_loc24_ + 80);
                                                _loc14_ = _loc4_ = 1;
                                                if(uint(_loc17_) <= uint(_temp_204))
                                                {
                                                   _loc14_ = 0;
                                                }
                                                _loc12_ = li32(_loc24_ + 84);
                                                _loc6_ = _loc16_ >> 31;
                                                _loc13_ = 2147483647 - _loc6_;
                                                if(_loc12_ <= _loc13_)
                                                {
                                                   _loc4_ = 0;
                                                }
                                                if(_loc12_ != _loc13_)
                                                {
                                                   _loc14_ = _loc4_;
                                                }
                                                if(_loc14_ == 0)
                                                {
                                                   _loc13_ = _loc17_ + _loc16_;
                                                   si32(_loc13_,_loc24_ + 80);
                                                   _loc14_ = _loc4_ = 1;
                                                   if(uint(_loc13_) >= uint(_loc17_))
                                                   {
                                                      _loc14_ = 0;
                                                   }
                                                   if(uint(_loc13_) >= uint(_loc16_))
                                                   {
                                                      _loc4_ = _loc14_;
                                                   }
                                                   _loc26_ = _loc12_ + _loc6_;
                                                   _loc26_ = _loc26_ + _loc4_;
                                                   si32(_loc26_,_loc24_ + 84);
                                                   break;
                                                }
                                             }
                                             _loc25_ &= 61439;
                                             si16(_loc25_,_loc24_ + 12);
                                             break;
                                          }
                                          if(_loc16_ <= 0)
                                          {
                                             _loc26_ = _loc25_ | 0x40;
                                             si16(_loc26_,_loc24_ + 12);
                                             §§goto(addr1aab);
                                             var _temp_121:* = int(_loc22_ + 8);
                                             _loc21_ = li32(_loc22_);
                                             _loc20_ = li32(_loc22_ - 4);
                                             _loc22_ += 8;
                                             break loop4;
                                          }
                                          _loc15_ += _loc16_;
                                          _loc11_ -= _loc16_;
                                       }
                                    }
                                 }
                                 break loop27;
                              }
                           }
                           if(_loc25_ <= _loc15_)
                           {
                              _loc26_ = li8(_loc24_ + 13);
                              _loc26_ = _loc26_ & 1;
                              if(_loc26_ != 0)
                              {
                                 _loc19_ = li32(wdnative_nternal._errno);
                                 _loc1_ -= 16;
                                 si32(2,_loc1_ + 4);
                                 si32(_loc24_,_loc1_);
                                 wdnative.ESP = _loc1_;
                                 wdnative_nternal.F__sseek();
                                 _loc1_ += 16;
                                 _loc26_ = wdnative.eax & wdnative.edx;
                                 if(_loc26_ == -1)
                                 {
                                    _loc26_ = li8(_loc24_ + 13);
                                    _loc26_ = _loc26_ & 4;
                                    if(_loc26_ != 0)
                                    {
                                       break;
                                    }
                                 }
                                 si32(_loc19_,wdnative_nternal._errno);
                              }
                              _loc26_ = li32(_loc24_ + 44);
                              _loc7_ = li32(_loc24_ + 28);
                              _loc1_ -= 16;
                              si32(_loc25_,_loc1_ + 8);
                              si32(_loc20_,_loc1_ + 4);
                              si32(_loc7_,_loc1_);
                              wdnative.ESP = _loc1_;
                              wdnative.ptr2fun[_loc26_]();
                              _loc1_ += 16;
                              _loc19_ = wdnative.eax;
                              _loc17_ = li16(_loc24_ + 12);
                              if(_loc19_ >= 0)
                              {
                                 while(true)
                                 {
                                    _loc26_ = _loc17_ & 0x1100;
                                    if(_loc26_ == 4352)
                                    {
                                       var _temp_219:* = _loc19_ ^ -1;
                                       _loc25_ = li32(_loc24_ + 80);
                                       _loc12_ = _loc16_ = 1;
                                       if(uint(_loc25_) <= uint(_temp_219))
                                       {
                                          _loc12_ = 0;
                                       }
                                       _loc15_ = li32(_loc24_ + 84);
                                       _loc11_ = _loc19_ >> 31;
                                       _loc6_ = 2147483647 - _loc11_;
                                       if(_loc15_ <= _loc6_)
                                       {
                                          _loc16_ = 0;
                                       }
                                       if(_loc15_ != _loc6_)
                                       {
                                          _loc12_ = _loc16_;
                                       }
                                       if(_loc12_ == 0)
                                       {
                                          _loc12_ = _loc25_ + _loc19_;
                                          si32(_loc12_,_loc24_ + 80);
                                          _loc16_ = _loc17_ = 1;
                                          if(uint(_loc12_) >= uint(_loc25_))
                                          {
                                             _loc16_ = 0;
                                          }
                                          if(uint(_loc12_) >= uint(_loc19_))
                                          {
                                             _loc17_ = _loc16_;
                                          }
                                          _loc26_ = _loc15_ + _loc11_;
                                          _loc26_ = _loc26_ + _loc17_;
                                          si32(_loc26_,_loc24_ + 84);
                                          break;
                                       }
                                    }
                                    _loc26_ = _loc17_ & 0xEFFF;
                                    si16(_loc26_,_loc24_ + 12);
                                    break;
                                 }
                                 if(_loc19_ >= 1)
                                 {
                                    break loop27;
                                 }
                                 break;
                              }
                              _loc26_ = _loc17_ & 0xEFFF;
                              si16(_loc26_,_loc24_ + 12);
                              break;
                           }
                           _loc1_ -= 16;
                           si32(_loc20_,_loc1_ + 4);
                           si32(_loc11_,_loc1_);
                           si32(_loc15_,_loc1_ + 8);
                           wdnative.ESP = _loc1_;
                           wdnative.Fmemcpy();
                           _loc1_ += 16;
                           _loc26_ = li32(_loc24_ + 8);
                           _loc26_ = _loc26_ - _loc15_;
                           si32(_loc26_,_loc24_ + 8);
                           _loc26_ = li32(_loc24_);
                           _loc26_ = _loc26_ + _loc15_;
                           si32(_loc26_,_loc24_);
                           _loc19_ = _loc15_;
                           break loop27;
                        }
                        §§goto(addr1aab);
                     }
                     if(_loc23_ == _loc19_)
                     {
                        _loc25_ = 0;
                        _loc11_ = wdnative_nternal.___sglue;
                        if(_loc24_ == 0)
                        {
                           do
                           {
                              _loc17_ = li32(_loc11_ + 4);
                              if(_loc17_ >= 1)
                              {
                                 _loc16_ = li32(_loc11_ + 8);
                                 do
                                 {
                                    _loc18_ = si16(li16(_loc16_ + 12));
                                    if(_loc18_ >= 1)
                                    {
                                       var _temp_128:* = _loc18_ & 8;
                                       _loc6_ = 0;
                                       if(_temp_128 != 0)
                                       {
                                          _loc15_ = li32(_loc16_ + 16);
                                          _loc6_ = 0;
                                          if(_loc15_ != 0)
                                          {
                                             _loc12_ = li32(_loc16_);
                                             si32(_loc15_,_loc16_);
                                             var _temp_129:* = _loc18_ & 3;
                                             _loc6_ = 0;
                                             if(_temp_129 == 0)
                                             {
                                                _loc6_ = li32(_loc16_ + 20);
                                             }
                                             _loc12_ -= _loc15_;
                                             si32(_loc6_,_loc16_ + 8);
                                             loop18:
                                             while(true)
                                             {
                                                _loc6_ = 0;
                                                if(_loc12_ <= 0)
                                                {
                                                   break;
                                                }
                                                while(true)
                                                {
                                                   _loc26_ = _loc18_ & 0x0100;
                                                   if(_loc26_ != 0)
                                                   {
                                                      _loc6_ = li32(wdnative_nternal._errno);
                                                      _loc1_ -= 16;
                                                      si32(2,_loc1_ + 4);
                                                      si32(_loc16_,_loc1_);
                                                      wdnative.ESP = _loc1_;
                                                      wdnative_nternal.F__sseek();
                                                      _loc1_ += 16;
                                                      _loc26_ = wdnative.eax & wdnative.edx;
                                                      if(_loc26_ == -1)
                                                      {
                                                         _loc18_ = li16(_loc16_ + 12);
                                                         _loc26_ = _loc18_ & 0x0400;
                                                         if(_loc26_ != 0)
                                                         {
                                                            break;
                                                         }
                                                      }
                                                      si32(_loc6_,wdnative_nternal._errno);
                                                   }
                                                   _loc7_ = li32(_loc16_ + 44);
                                                   _loc26_ = li32(_loc16_ + 28);
                                                   _loc1_ -= 16;
                                                   si32(_loc12_,_loc1_ + 8);
                                                   si32(_loc15_,_loc1_ + 4);
                                                   si32(_loc26_,_loc1_);
                                                   wdnative.ESP = _loc1_;
                                                   wdnative.ptr2fun[_loc7_]();
                                                   _loc1_ += 16;
                                                   _loc4_ = wdnative.eax;
                                                   _loc18_ = li16(_loc16_ + 12);
                                                   if(_loc4_ < 0)
                                                   {
                                                      _loc18_ &= 61439;
                                                      si16(_loc18_,_loc16_ + 12);
                                                      break;
                                                   }
                                                   while(true)
                                                   {
                                                      _loc26_ = _loc18_ & 0x1100;
                                                      if(_loc26_ == 4352)
                                                      {
                                                         var _temp_138:* = _loc4_ ^ -1;
                                                         _loc13_ = li32(_loc16_ + 80);
                                                         _loc5_ = _loc8_ = 1;
                                                         if(uint(_loc13_) <= uint(_temp_138))
                                                         {
                                                            _loc5_ = 0;
                                                         }
                                                         _loc14_ = li32(_loc16_ + 84);
                                                         _loc6_ = _loc4_ >> 31;
                                                         _loc9_ = 2147483647 - _loc6_;
                                                         if(_loc14_ <= _loc9_)
                                                         {
                                                            _loc8_ = 0;
                                                         }
                                                         if(_loc14_ != _loc9_)
                                                         {
                                                            _loc5_ = _loc8_;
                                                         }
                                                         if(_loc5_ == 0)
                                                         {
                                                            _loc9_ = _loc13_ + _loc4_;
                                                            si32(_loc9_,_loc16_ + 80);
                                                            _loc8_ = _loc5_ = 1;
                                                            if(uint(_loc9_) >= uint(_loc13_))
                                                            {
                                                               _loc8_ = 0;
                                                            }
                                                            if(uint(_loc9_) >= uint(_loc4_))
                                                            {
                                                               _loc5_ = _loc8_;
                                                            }
                                                            _loc26_ = _loc14_ + _loc6_;
                                                            _loc26_ = _loc26_ + _loc5_;
                                                            si32(_loc26_,_loc16_ + 84);
                                                            break;
                                                         }
                                                      }
                                                      _loc18_ &= 61439;
                                                      si16(_loc18_,_loc16_ + 12);
                                                      break;
                                                   }
                                                   if(_loc4_ <= 0)
                                                   {
                                                      break;
                                                   }
                                                   continue loop18;
                                                }
                                                _loc26_ = _loc18_ | 0x40;
                                                si16(_loc26_,_loc16_ + 12);
                                                _loc6_ = -1;
                                                break;
                                                _loc15_ += _loc4_;
                                                _loc12_ -= _loc4_;
                                             }
                                          }
                                       }
                                       _loc25_ = _loc6_ | _loc25_;
                                    }
                                    _loc16_ += 232;
                                 }
                                 while(_loc17_ += -1, _loc17_ != 0);
                              }
                           }
                           while(_loc11_ = li32(_loc11_), _loc11_ != 0);
                           _loc18_ = 0;
                           if(_loc25_ != 0)
                           {
                              break loop28;
                           }
                        }
                        else
                        {
                           _loc25_ = si16(li16(_loc24_ + 12));
                           _loc26_ = _loc25_ & 0x18;
                           if(_loc26_ == 0)
                           {
                              si32(9,wdnative_nternal._errno);
                              break loop28;
                           }
                           var _temp_147:* = _loc25_ & 8;
                           _loc18_ = 0;
                           if(_temp_147 != 0)
                           {
                              _loc15_ = li32(_loc24_ + 16);
                              _loc18_ = 0;
                              if(_loc15_ != 0)
                              {
                                 _loc11_ = li32(_loc24_);
                                 si32(_loc15_,_loc24_);
                                 var _temp_148:* = _loc25_ & 3;
                                 _loc18_ = 0;
                                 if(_temp_148 == 0)
                                 {
                                    _loc18_ = li32(_loc24_ + 20);
                                 }
                                 _loc11_ -= _loc15_;
                                 si32(_loc18_,_loc24_ + 8);
                                 loop17:
                                 while(true)
                                 {
                                    _loc18_ = 0;
                                    if(_loc11_ <= 0)
                                    {
                                       break;
                                    }
                                    while(true)
                                    {
                                       _loc26_ = _loc25_ & 0x0100;
                                       if(_loc26_ != 0)
                                       {
                                          _loc18_ = li32(wdnative_nternal._errno);
                                          _loc1_ -= 16;
                                          si32(2,_loc1_ + 4);
                                          si32(_loc24_,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F__sseek();
                                          _loc1_ += 16;
                                          _loc26_ = wdnative.eax & wdnative.edx;
                                          if(_loc26_ == -1)
                                          {
                                             _loc25_ = li16(_loc24_ + 12);
                                             _loc26_ = _loc25_ & 0x0400;
                                             if(_loc26_ != 0)
                                             {
                                                break;
                                             }
                                          }
                                          si32(_loc18_,wdnative_nternal._errno);
                                       }
                                       _loc7_ = li32(_loc24_ + 44);
                                       _loc26_ = li32(_loc24_ + 28);
                                       _loc1_ -= 16;
                                       si32(_loc11_,_loc1_ + 8);
                                       si32(_loc15_,_loc1_ + 4);
                                       si32(_loc26_,_loc1_);
                                       wdnative.ESP = _loc1_;
                                       wdnative.ptr2fun[_loc7_]();
                                       _loc1_ += 16;
                                       _loc12_ = wdnative.eax;
                                       _loc25_ = li16(_loc24_ + 12);
                                       if(_loc12_ < 0)
                                       {
                                          _loc25_ &= 61439;
                                          si16(_loc25_,_loc24_ + 12);
                                          break;
                                       }
                                       while(true)
                                       {
                                          _loc26_ = _loc25_ & 0x1100;
                                          if(_loc26_ == 4352)
                                          {
                                             var _temp_157:* = _loc12_ ^ -1;
                                             _loc16_ = li32(_loc24_ + 80);
                                             _loc13_ = _loc6_ = 1;
                                             if(uint(_loc16_) <= uint(_temp_157))
                                             {
                                                _loc13_ = 0;
                                             }
                                             _loc18_ = li32(_loc24_ + 84);
                                             _loc17_ = _loc12_ >> 31;
                                             _loc14_ = 2147483647 - _loc17_;
                                             if(_loc18_ <= _loc14_)
                                             {
                                                _loc6_ = 0;
                                             }
                                             if(_loc18_ != _loc14_)
                                             {
                                                _loc13_ = _loc6_;
                                             }
                                             if(_loc13_ == 0)
                                             {
                                                _loc6_ = _loc16_ + _loc12_;
                                                si32(_loc6_,_loc24_ + 80);
                                                _loc14_ = _loc13_ = 1;
                                                if(uint(_loc6_) >= uint(_loc16_))
                                                {
                                                   _loc14_ = 0;
                                                }
                                                if(uint(_loc6_) >= uint(_loc12_))
                                                {
                                                   _loc13_ = _loc14_;
                                                }
                                                _loc26_ = _loc18_ + _loc17_;
                                                _loc26_ = _loc26_ + _loc13_;
                                                si32(_loc26_,_loc24_ + 84);
                                                break;
                                             }
                                          }
                                          _loc25_ &= 61439;
                                          si16(_loc25_,_loc24_ + 12);
                                          break;
                                       }
                                       if(_loc12_ <= 0)
                                       {
                                          break;
                                       }
                                       continue loop17;
                                    }
                                    _loc26_ = _loc25_ | 0x40;
                                    si16(_loc26_,_loc24_ + 12);
                                    break loop28;
                                    _loc15_ += _loc12_;
                                    _loc11_ -= _loc12_;
                                 }
                              }
                           }
                        }
                     }
                     _loc23_ -= _loc19_;
                     _loc26_ = li32(_loc10_ + 8);
                     _loc7_ = _loc26_ - _loc19_;
                     si32(_loc7_,_loc10_ + 8);
                     _loc21_ -= _loc19_;
                     _loc20_ += _loc19_;
                     _loc25_ = 0;
                     if(_loc26_ == _loc19_)
                     {
                        break loop1;
                     }
                  }
               }
            }
         }
      }
      wdnative.eax = _loc25_;
      _loc1_ = _loc2_;
      wdnative.ESP = _loc1_;
   }
}

