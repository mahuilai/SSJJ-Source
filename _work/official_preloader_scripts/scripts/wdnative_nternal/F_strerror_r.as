package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   
   public function F_strerror_r() : void
   {
      var _temp_1:* = this;
      var _loc10_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc22_:int = 0;
      var _loc11_:int = 0;
      var _loc19_:int = 0;
      var _loc17_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc18_:int = 0;
      var _loc12_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      _loc10_ = wdnative.ESP;
      var _loc5_:int = _loc10_ - 1168;
      _loc6_ = wdnative_nternal.L__2E_str1703;
      _loc22_ = li32(wdnative_nternal._errno);
      _loc21_ = li32(_loc10_ + 4);
      _loc20_ = li32(_loc10_);
      while(true)
      {
         _loc19_ = li8(_loc6_);
         if(_loc19_ == 0)
         {
            break;
         }
         if(_loc19_ == 47)
         {
            if(_loc6_ != 0)
            {
               _loc5_ -= 16;
               si32(wdnative_nternal.L__2E_str1703,_loc5_);
               wdnative.ESP = _loc5_;
               wdnative_nternal.F_load_msgcat();
               _loc5_ += 16;
               _loc18_ = wdnative.eax;
               §§goto(addr0d94);
            }
            break;
         }
         _loc6_ += 1;
      }
      loop30:
      while(true)
      {
         _loc6_ = li8(wdnative_nternal._current_categories + 192);
         if(_loc6_ != 0)
         {
            _loc19_ = wdnative_nternal._current_categories + 192;
            _loc17_ = _loc19_ & -4;
            var _loc16_:int = li32(_loc17_);
            var _temp_38:* = int(_loc16_ + -16843009);
            var _temp_39:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_38;
            _loc18_ = _loc17_ + 4;
            _loc1_ = 0;
            if(_temp_39 != 0)
            {
               while(true)
               {
                  _loc11_ = _loc19_ + _loc1_;
                  _loc18_ = _loc17_ + 4;
                  if(uint(_loc11_) < uint(_loc18_))
                  {
                     var _loc15_:int = li8(_loc11_);
                     if(_loc15_ == 0)
                     {
                        break;
                     }
                     _loc1_ += 1;
                     continue;
                  }
               }
               addr0226:
               if(uint(_loc1_) <= 31)
               {
                  _loc18_ = wdnative_nternal._current_categories + 193;
                  _loc1_ = _loc6_;
                  loop31:
                  while(true)
                  {
                     if(_loc6_ == 46)
                     {
                        _loc11_ = li8(wdnative_nternal._current_categories + 193);
                        if(_loc11_ == 0)
                        {
                           break;
                        }
                        _loc18_ = wdnative_nternal._current_categories + 193;
                        _loc1_ = 46;
                        if(_loc11_ == 46)
                        {
                           _loc18_ = wdnative_nternal._current_categories + 193;
                           var _temp_43:* = li8(wdnative_nternal._current_categories + 194);
                           _loc1_ = _loc6_;
                           if(_temp_43 == 0)
                           {
                              break;
                           }
                        }
                     }
                     while(true)
                     {
                        _loc6_ = _loc1_ & 0xFF;
                        if(_loc6_ == 0)
                        {
                           break loop30;
                        }
                        if(_loc6_ == 47)
                        {
                           _loc19_ = wdnative_nternal._current_categories + 192;
                           if(_loc18_ != 1)
                           {
                              break loop31;
                           }
                           break loop30;
                        }
                        var _temp_44:* = int(_loc18_ + 1);
                        _loc1_ = li8(_loc18_);
                        _loc18_ += 1;
                     }
                     break loop30;
                  }
               }
               addr02c5:
               _loc19_ = wdnative_nternal.L__2E_str11003;
               break;
            }
            while(true)
            {
               _loc1_ = li32(_loc18_);
               _loc15_ = _loc1_ + -16843009;
               _loc16_ = _loc1_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc15_ = _loc16_ & _loc15_;
               if(_loc15_ != 0)
               {
                  _loc15_ = _loc1_ & 0xFF;
                  if(_loc15_ == 0)
                  {
                     var _temp_50:* = int(wdnative_nternal._current_categories + 192);
                     _loc1_ = _loc18_ - _temp_50;
                     break;
                  }
                  _loc15_ = li8(_loc18_ + 1);
                  if(_loc15_ == 0)
                  {
                     var _temp_52:* = int(wdnative_nternal._current_categories + 192);
                     var _temp_53:* = int(1 - _temp_52);
                     _loc1_ = _loc18_ + _temp_53;
                     break;
                  }
                  _loc15_ = li8(_loc18_ + 2);
                  if(_loc15_ == 0)
                  {
                     var _temp_55:* = int(wdnative_nternal._current_categories + 192);
                     var _temp_56:* = int(2 - _temp_55);
                     _loc1_ = _loc18_ + _temp_56;
                     break;
                  }
                  _loc15_ = li8(_loc18_ + 3);
                  if(_loc15_ == 0)
                  {
                     var _temp_58:* = int(wdnative_nternal._current_categories + 192);
                     var _temp_59:* = int(3 - _temp_58);
                     _loc1_ = _loc18_ + _temp_59;
                     break;
                  }
               }
               _loc18_ += 4;
            }
            §§goto(addr0226);
         }
         §§goto(addr02c5);
      }
      _loc11_ = _loc19_ & -4;
      _loc16_ = li32(_loc11_);
      _loc15_ = _loc16_ + -16843009;
      _loc16_ &= -2139062144;
      _loc16_ = _loc16_ ^ -2139062144;
      _loc15_ = _loc16_ & _loc15_;
      if(_loc15_ != 0)
      {
         _loc6_ = _loc11_ + 4;
         _loc1_ = 0;
         while(true)
         {
            _loc18_ = _loc19_ + _loc1_;
            if((uint(_loc18_)) < uint(_loc6_))
            {
               _loc15_ = li8(_loc18_);
               if(_loc15_ == 0)
               {
                  break;
               }
               _loc1_ += 1;
               continue;
            }
         }
         §§goto(addr03f6);
      }
      _loc18_ = _loc11_ + 4;
      while(true)
      {
         _loc6_ = li32(_loc18_);
         _loc15_ = _loc6_ + -16843009;
         _loc16_ = _loc6_ & -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc15_ = _loc16_ & _loc15_;
         if(_loc15_ != 0)
         {
            _loc15_ = _loc6_ & 0xFF;
            if(_loc15_ == 0)
            {
               _loc1_ = _loc18_ - _loc19_;
               break;
            }
            _loc15_ = li8(_loc18_ + 1);
            if(_loc15_ == 0)
            {
               _loc15_ = 1 - _loc19_;
               _loc1_ = _loc15_ + _loc18_;
               break;
            }
            _loc15_ = li8(_loc18_ + 2);
            if(_loc15_ == 0)
            {
               _loc15_ = 2 - _loc19_;
               _loc1_ = _loc15_ + _loc18_;
               break;
            }
            _loc15_ = li8(_loc18_ + 3);
            if(_loc15_ == 0)
            {
               _loc15_ = 3 - _loc19_;
               _loc1_ = _loc15_ + _loc18_;
               break;
            }
         }
         _loc18_ += 4;
      }
      addr03f6:
      _loc5_ -= 16;
      _loc1_ += 1;
      si32(_loc1_,_loc5_);
      wdnative.ESP = _loc5_;
      wdnative.F_malloc();
      _loc18_ = -1;
      _loc5_ += 16;
      _loc6_ = wdnative.eax;
      if(_loc6_ != 0)
      {
         _loc5_ -= 16;
         si32(_loc1_,_loc5_ + 8);
         si32(_loc19_,_loc5_ + 4);
         si32(_loc6_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative.Fmemcpy();
         _loc5_ += 16;
         _loc18_ = _loc6_;
         while(true)
         {
            _loc11_ = li8(_loc18_);
            _loc1_ = _loc6_;
            if(_loc11_ == 0)
            {
               break;
            }
            if(_loc11_ == 64)
            {
               _loc1_ = _loc6_;
               if(_loc18_ != 0)
               {
                  si8(0,_loc18_);
                  _loc1_ = _loc6_;
               }
               break;
            }
            _loc18_ += 1;
         }
         while(true)
         {
            _loc17_ = li8(_loc1_);
            _loc18_ = wdnative_nternal.L__2E_str21004;
            _loc11_ = _loc6_;
            if(_loc17_ == 0)
            {
               break;
            }
            if(_loc17_ == 95)
            {
               _loc18_ = wdnative_nternal.L__2E_str21004;
               _loc11_ = _loc6_;
               if(_loc1_ != 0)
               {
                  si8(0,_loc1_);
                  _loc18_ = _loc11_ = _loc1_ + 1;
               }
               break;
            }
            _loc1_ += 1;
         }
         while(true)
         {
            _loc17_ = li8(_loc11_);
            _loc1_ = wdnative_nternal.L__2E_str21004;
            if(_loc17_ == 0)
            {
               break;
            }
            if(_loc17_ == 46)
            {
               _loc1_ = wdnative_nternal.L__2E_str21004;
               if(_loc11_ != 0)
               {
                  si8(0,_loc11_);
                  _loc1_ = _loc11_ + 1;
               }
               break;
            }
            _loc11_ += 1;
         }
         _loc17_ = 1;
         for(; (_loc11_ = li8((_loc15_ = wdnative_nternal.L__2E_str31005 + _loc17_) - 1)) != 61; _loc17_ += 1)
         {
            if(_loc11_ != 0)
            {
               continue;
            }
            if(_loc17_ == 1)
            {
               break;
            }
            addr068b:
            _loc11_ = 0;
            _loc12_ = li32(wdnative_nternal._environ);
            if(_loc12_ != 0)
            {
               _loc13_ = li32(_loc12_);
               _loc11_ = 0;
               if(_loc13_ != 0)
               {
                  loop32:
                  while(true)
                  {
                     if(_loc17_ == 1)
                     {
                        _loc12_ += 4;
                        while(true)
                        {
                           _loc11_ = 0;
                           if(_loc13_ == 0)
                           {
                              break loop32;
                           }
                           _loc15_ = _loc13_ + _loc17_;
                           _loc15_ = li8(_loc15_ - 1);
                           if(_loc15_ != 61)
                           {
                              continue;
                           }
                           var _temp_75:* = int(_loc12_ + 4);
                           _loc13_ = li32(_loc12_);
                           _loc12_ += 4;
                        }
                        break;
                     }
                     _loc12_ += 4;
                     loop10:
                     while(true)
                     {
                        _loc11_ = 0;
                        if(_loc13_ == 0)
                        {
                           break loop32;
                        }
                        while(true)
                        {
                           _loc15_ = _loc13_ - _loc11_;
                           _loc14_ = li8(_loc15_);
                           _loc15_ = wdnative_nternal.L__2E_str31005 - _loc11_;
                           _loc15_ = li8(_loc15_);
                           if(_loc14_ == _loc15_)
                           {
                              if(_loc14_ == 0)
                              {
                                 break;
                              }
                              var _temp_81:* = int(_loc17_ + _loc11_);
                              _loc11_ += -1;
                              if(_temp_81 == 2)
                              {
                                 break;
                              }
                              continue;
                           }
                           continue loop10;
                        }
                        _loc15_ = _loc13_ + _loc17_;
                        _loc15_ = li8(_loc15_ - 1);
                        if(_loc15_ != 61)
                        {
                           continue;
                        }
                        _loc15_ = _loc12_ + 4;
                        _loc13_ = li32(_loc12_);
                        _loc12_ = _loc15_;
                     }
                     break;
                     _loc11_ = _loc13_ + _loc17_;
                     break;
                  }
               }
            }
            _loc17_ = wdnative_nternal.L__2E_str41006;
            _loc13_ = 0;
            if(_loc11_ != _loc13_)
            {
               _loc17_ = _loc11_;
            }
            _loc11_ = _loc17_ & -4;
            _loc16_ = li32(_loc11_);
            _loc15_ = _loc16_ + -16843009;
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc15_ = _loc16_ & _loc15_;
            if(_loc15_ != 0)
            {
               _loc12_ = _loc11_ + 4;
               while(true)
               {
                  _loc14_ = _loc17_ + _loc13_;
                  if((uint(_loc14_)) < uint(_loc12_))
                  {
                     _loc15_ = li8(_loc14_);
                     if(_loc15_ == 0)
                     {
                        break;
                     }
                     _loc13_ += 1;
                     continue;
                  }
               }
               §§goto(addr07d0);
            }
            _loc13_ = _loc11_ + 4;
            while(true)
            {
               _loc11_ = li32(_loc13_);
               _loc15_ = _loc11_ + -16843009;
               _loc16_ = _loc11_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc15_ = _loc16_ & _loc15_;
               if(_loc15_ != 0)
               {
                  _loc15_ = _loc11_ & 0xFF;
                  if(_loc15_ == 0)
                  {
                     _loc13_ -= _loc17_;
                     break;
                  }
                  _loc15_ = li8(_loc13_ + 1);
                  if(_loc15_ == 0)
                  {
                     _loc15_ = 1 - _loc17_;
                     _loc13_ = _loc15_ + _loc13_;
                     break;
                  }
                  _loc15_ = li8(_loc13_ + 2);
                  if(_loc15_ == 0)
                  {
                     _loc15_ = 2 - _loc17_;
                     _loc13_ = _loc15_ + _loc13_;
                     break;
                  }
                  _loc15_ = li8(_loc13_ + 3);
                  if(_loc15_ == 0)
                  {
                     _loc15_ = 3 - _loc17_;
                     _loc13_ = _loc15_ + _loc13_;
                     break;
                  }
               }
               _loc13_ += 4;
            }
            addr07d0:
            _loc5_ -= 16;
            _loc13_ += 1;
            si32(_loc13_,_loc5_);
            wdnative.ESP = _loc5_;
            wdnative.F_malloc();
            _loc5_ += 16;
            _loc11_ = wdnative.eax;
            if(_loc11_ != 0)
            {
               _loc5_ -= 16;
               si32(_loc13_,_loc5_ + 8);
               si32(_loc17_,_loc5_ + 4);
               si32(_loc11_,_loc5_);
               wdnative.ESP = _loc5_;
               wdnative.Fmemcpy();
               _loc5_ += 16;
               _loc17_ = _loc10_ - 1024;
               _loc13_ = _loc17_ + 1022;
               _loc4_ = _loc11_;
               loop15:
               while(true)
               {
                  if(_loc4_ == 0)
                  {
                     _loc5_ -= 16;
                     si32(_loc6_,_loc5_);
                     wdnative.ESP = _loc5_;
                     wdnative_nternal.F_idalloc();
                     _loc5_ += 16;
                     _loc5_ = _loc5_ - 16;
                     si32(_loc11_,_loc5_);
                     wdnative.ESP = _loc5_;
                     wdnative_nternal.F_idalloc();
                     _loc5_ += 16;
                     si32(2,wdnative_nternal._errno);
                     _loc18_ = -1;
                     break;
                  }
                  _loc14_ = _loc4_ + 1;
                  loop16:
                  while(true)
                  {
                     _loc12_ = li8(_loc14_ - 1);
                     _loc7_ = 2;
                     do
                     {
                        _loc15_ = wdnative_nternal.L__2E_str51007 - _loc7_;
                        _loc15_ = li8(_loc15_ + 2);
                        _loc9_ = _loc12_ & 0xFF;
                        if(_loc15_ == _loc9_)
                        {
                           break loop16;
                        }
                     }
                     while(_loc7_ += -1, _loc7_ != 0);
                     _loc14_ += 1;
                  }
                  _loc12_ = 0;
                  if(_loc9_ != 0)
                  {
                     si8(0,_loc14_ - 1);
                     _loc12_ = _loc14_;
                  }
                  _loc7_ = li8(_loc4_);
                  _loc14_ = _loc17_;
                  if(_loc7_ != 0)
                  {
                     loop18:
                     while(true)
                     {
                        _loc9_ = _loc7_ & 0xFF;
                        if(_loc9_ != 37)
                        {
                           if(_loc9_ == 0)
                           {
                              si8(0,_loc14_);
                              _loc5_ -= 16;
                              _loc15_ = _loc10_ - 1120;
                              si32(_loc15_,_loc5_ + 4);
                              _loc14_ = _loc10_ - 1024;
                              si32(_loc14_,_loc5_);
                              wdnative.ESP = _loc5_;
                              wdnative_nternal.F___sys_stat();
                              _loc5_ += 16;
                              var _temp_112:* = wdnative.eax;
                              _loc4_ = _loc12_;
                              if(_temp_112 == 0)
                              {
                                 break;
                              }
                              continue loop15;
                           }
                           var _temp_113:* = int(_loc10_ - 1024);
                           _loc15_ = _loc14_ - _temp_113;
                           if((uint(_loc15_)) <= 1022)
                           {
                              si8(_loc7_,_loc14_);
                              _loc14_ += 1;
                              _loc9_ = _loc4_;
                              continue;
                           }
                        }
                        else
                        {
                           _loc8_ = si8(li8(_loc4_ + 1));
                           _loc9_ = _loc4_ + 1;
                           while(true)
                           {
                              if(_loc8_ <= 98)
                              {
                                 if(_loc8_ != 37)
                                 {
                                    if(_loc8_ != 76)
                                    {
                                       if(_loc8_ != 78)
                                       {
                                          addr0927:
                                          _loc15_ = _loc10_ - 1024;
                                          _loc15_ = _loc14_ - _loc15_;
                                          if((uint(_loc15_)) > 1022)
                                          {
                                             break;
                                          }
                                          _loc15_ = li8(_loc4_);
                                          si8(_loc15_,_loc14_);
                                          _loc14_ += 1;
                                          _loc9_ = _loc4_;
                                          continue loop18;
                                       }
                                       _loc7_ = wdnative_nternal.L__2E_str1703;
                                    }
                                    else
                                    {
                                       _loc7_ = _loc19_;
                                    }
                                    addr095c:
                                    _loc15_ = _loc10_ - 1024;
                                    _loc15_ = _loc15_ - _loc14_;
                                    _loc4_ = _loc15_ + 1023;
                                    _loc3_ = _loc7_;
                                    if(_loc4_ != 0)
                                    {
                                       _loc3_ = _loc13_ - _loc14_;
                                       _loc8_ = _loc14_;
                                       _loc2_ = _loc7_;
                                       do
                                       {
                                          if(_loc3_ != 0)
                                          {
                                             continue;
                                          }
                                          _loc3_ = _loc2_;
                                          if(_loc4_ != 0)
                                          {
                                             si8(0,_loc8_);
                                             _loc3_ = _loc2_;
                                          }
                                       }
                                       while(_loc15_ = li8(_loc2_), si8(_loc15_,_loc8_), _loc8_ += 1, _loc2_ += 1, _loc3_ += -1, _loc15_ != 0);
                                       addr09e8:
                                       _loc15_ = _loc7_ ^ -1;
                                       _loc15_ = _loc2_ + _loc15_;
                                       if((uint(_loc15_)) >= uint(_loc4_))
                                       {
                                          break;
                                       }
                                       _loc2_ = _loc7_ & -4;
                                       _loc16_ = li32(_loc2_);
                                       var _temp_124:* = int(_loc16_ + -16843009);
                                       _loc15_ = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_124;
                                       if(_loc15_ != 0)
                                       {
                                          _loc8_ = _loc2_ + 4;
                                          _loc3_ = 0;
                                          while(true)
                                          {
                                             _loc4_ = _loc7_ + _loc3_;
                                             if((uint(_loc4_)) < uint(_loc8_))
                                             {
                                                _loc15_ = li8(_loc4_);
                                                if(_loc15_ == 0)
                                                {
                                                   break;
                                                }
                                                _loc3_ += 1;
                                                continue;
                                             }
                                          }
                                          addr0b7c:
                                          _loc14_ += _loc3_;
                                          continue loop18;
                                       }
                                       _loc8_ = _loc2_ + 4;
                                       while(true)
                                       {
                                          _loc4_ = li32(_loc8_);
                                          _loc15_ = _loc4_ + -16843009;
                                          _loc16_ = _loc4_ & -2139062144;
                                          _loc16_ = _loc16_ ^ -2139062144;
                                          _loc15_ = _loc16_ & _loc15_;
                                          if(_loc15_ != 0)
                                          {
                                             _loc15_ = _loc4_ & 0xFF;
                                             if(_loc15_ == 0)
                                             {
                                                _loc3_ = _loc8_ - _loc7_;
                                                break;
                                             }
                                             _loc15_ = li8(_loc8_ + 1);
                                             if(_loc15_ == 0)
                                             {
                                                _loc15_ = 1 - _loc7_;
                                                _loc3_ = _loc15_ + _loc8_;
                                                break;
                                             }
                                             _loc15_ = li8(_loc8_ + 2);
                                             if(_loc15_ == 0)
                                             {
                                                _loc15_ = 2 - _loc7_;
                                                _loc3_ = _loc15_ + _loc8_;
                                                break;
                                             }
                                             _loc15_ = li8(_loc8_ + 3);
                                             if(_loc15_ == 0)
                                             {
                                                _loc15_ = 3 - _loc7_;
                                                _loc3_ = _loc15_ + _loc8_;
                                                break;
                                             }
                                          }
                                          _loc8_ += 4;
                                       }
                                       §§goto(addr0b7c);
                                    }
                                    do
                                    {
                                       _loc2_ = _loc3_ + 1;
                                       _loc15_ = li8(_loc3_);
                                       _loc3_ = _loc2_;
                                    }
                                    while(_loc15_ != 0);
                                    §§goto(addr09e8);
                                 }
                                 else
                                 {
                                    _loc4_ = _loc9_;
                                 }
                                 §§goto(addr0927);
                              }
                              else if(_loc8_ != 99)
                              {
                                 _loc7_ = _loc6_;
                                 if(_loc8_ != 108)
                                 {
                                    if(_loc8_ == 116)
                                    {
                                       _loc7_ = _loc18_;
                                    }
                                    else
                                    {
                                       §§goto(addr0927);
                                    }
                                 }
                              }
                              else
                              {
                                 _loc7_ = _loc1_;
                              }
                              §§goto(addr095c);
                           }
                        }
                        _loc5_ -= 16;
                        si32(_loc6_,_loc5_);
                        wdnative.ESP = _loc5_;
                        wdnative_nternal.F_idalloc();
                        _loc5_ += 16;
                        _loc5_ = _loc5_ - 16;
                        si32(_loc11_,_loc5_);
                        wdnative.ESP = _loc5_;
                        wdnative_nternal.F_idalloc();
                        _loc5_ += 16;
                        si32(63,wdnative_nternal._errno);
                        _loc18_ = -1;
                        break loop15;
                        _loc7_ = li8(_loc9_ + 1);
                        _loc4_ = _loc9_ + 1;
                     }
                     _loc5_ -= 16;
                     si32(_loc6_,_loc5_);
                     wdnative.ESP = _loc5_;
                     wdnative_nternal.F_idalloc();
                     _loc5_ += 16;
                     _loc5_ = _loc5_ - 16;
                     si32(_loc11_,_loc5_);
                     wdnative.ESP = _loc5_;
                     wdnative_nternal.F_idalloc();
                     _loc5_ += 16;
                     _loc5_ = _loc5_ - 16;
                     si32(_loc14_,_loc5_);
                     wdnative.ESP = _loc5_;
                     wdnative_nternal.F_load_msgcat();
                     _loc5_ += 16;
                     _loc18_ = wdnative.eax;
                     break;
                  }
                  _loc9_ = _loc4_ + -1;
                  _loc7_ = wdnative_nternal.L__2E_str1703;
                  _loc14_ = _loc10_ - 1024;
                  §§goto(addr095c);
               }
            }
            else
            {
               var _temp_152:* = li32(wdnative_nternal._errno);
               _loc5_ -= 16;
               si32(_loc6_,_loc5_);
               wdnative.ESP = _loc5_;
               wdnative_nternal.F_idalloc();
               _loc5_ += 16;
               si32(_temp_152,wdnative_nternal._errno);
               _loc18_ = -1;
            }
            §§goto(addr0d94);
         }
         si32(22,wdnative_nternal._errno);
         _loc11_ = 0;
         §§goto(addr068b);
      }
      addr0d94:
      _loc15_ = _loc20_ + -1;
      if((uint(_loc15_)) >= 93)
      {
         _loc5_ -= 16;
         si32(wdnative_nternal.L__2E_str2704,_loc5_ + 8);
         si32(65535,_loc5_ + 4);
         si32(_loc18_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F_catgets();
         _loc5_ += 16;
         _loc1_ = wdnative.eax;
         _loc11_ = 0;
         si8(_loc11_,_loc10_ - 1121);
         _loc16_ = _loc20_ >> 31;
         _loc15_ = _loc20_ + _loc16_;
         _loc17_ = _loc15_ ^ _loc16_;
         _loc15_ = _loc10_ - 1156;
         _loc19_ = _loc15_ + 35;
         _loc6_ = _loc15_ + 34;
         do
         {
            _loc15_ = _loc17_;
            _loc16_ = (uint(_loc15_)) % 10;
            _loc16_ = wdnative_nternal.L__2E_str702 + _loc16_;
            _loc16_ = li8(_loc16_);
            si8(_loc16_,_loc6_);
            _loc19_ += -1;
            _loc6_ += -1;
            _loc17_ = uint(_loc15_) / 10;
         }
         while(uint(_loc15_) > 9);
         if(_loc20_ <= -1)
         {
            si8(45,_loc6_);
            _loc19_ = _loc6_;
         }
         si8(32,_loc19_ - 1);
         _loc20_ = 58;
         si8(_loc20_,_loc19_ - 2);
         do
         {
            if(_loc11_ == -63)
            {
               var _temp_15:* = int(_loc21_ - _loc11_);
               si8(0,_temp_15);
               _loc1_ -= _loc11_;
               do
               {
                  _loc15_ = _loc1_ + 1;
                  _loc16_ = li8(_loc1_);
                  _loc6_ = 64;
                  _loc1_ = _loc15_;
               }
               while(_loc16_ != 0);
               break;
            }
            var _temp_14:* = int(_loc21_ - _loc11_);
            si8(_loc16_ = li8(_loc16_ = _loc1_ - _loc11_),_temp_14);
            _loc11_ += -1;
            _loc6_ = 64;
         }
         while(_loc16_ != 0);
         while(_loc6_ != 0)
         {
            _loc1_ = _loc21_ - _loc6_;
            _loc15_ = li8(_loc1_ + 64);
            if(_loc15_ == 0)
            {
               _loc21_ = _loc1_ + 64;
               _loc19_ += -1;
               do
               {
                  _loc1_ = 1;
                  if(_loc6_ != 1)
                  {
                     si8(_loc20_,_loc21_);
                     _loc1_ = _loc6_ + -1;
                     _loc21_ += 1;
                  }
                  _loc15_ = _loc19_ + 1;
                  _loc20_ = li8(_loc19_);
                  _loc19_ = _loc15_;
                  _loc6_ = _loc1_;
               }
               while(_loc20_ != 0);
               si8(0,_loc21_);
               break;
            }
            _loc6_ += -1;
         }
      }
      else
      {
         _loc5_ -= 16;
         si32(_loc18_,_loc5_);
         si32(_loc20_,_loc5_ + 4);
         var _temp_17:* = _loc20_ << 2;
         _loc15_ = wdnative_nternal._sys_errlist + _temp_17;
         _loc15_ = li32(_loc15_);
         si32(_loc15_,_loc5_ + 8);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F_catgets();
         _loc20_ = 0;
         _loc5_ += 16;
         _loc19_ = wdnative.eax;
         do
         {
            if(_loc20_ == -63)
            {
               var _temp_24:* = int(_loc21_ - _loc20_);
               si8(0,_temp_24);
               _loc21_ = _loc19_ - _loc20_;
               do
               {
                  _loc16_ = _loc21_ + 1;
                  _loc15_ = li8(_loc21_);
                  _loc21_ = _loc16_;
               }
               while(_loc15_ != 0);
               break;
            }
            var _temp_23:* = int(_loc21_ - _loc20_);
            si8(_loc16_ = li8(_loc16_ = _loc19_ - _loc20_),_temp_23);
            _loc20_ += -1;
         }
         while(_loc16_ != 0);
      }
      _loc15_ = _loc18_ + -1;
      if((uint(_loc15_)) >= 4294967294)
      {
         si32(9,wdnative_nternal._errno);
      }
      else
      {
         var _temp_27:* = li32(_loc18_);
         si32(li32(_loc18_ + 4),(_loc5_ -= 16) + 4);
         si32(_temp_27,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F_munmap();
         _loc5_ += 16;
         if(_loc18_ != 0)
         {
            _loc5_ -= 16;
            si32(_loc18_,_loc5_);
            wdnative.ESP = _loc5_;
            wdnative_nternal.F_idalloc();
            _loc5_ += 16;
         }
      }
      si32(_loc22_,wdnative_nternal._errno);
      wdnative.ESP = _loc5_ = _loc10_;
   }
}

