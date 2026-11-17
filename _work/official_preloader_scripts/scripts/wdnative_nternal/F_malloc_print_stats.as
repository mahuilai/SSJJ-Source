package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   
   public function F_malloc_print_stats() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc17_:int = 0;
      var _loc14_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc13_:int = 0;
      var _loc11_:int = 0;
      var _loc15_:int = 0;
      var _loc2_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc3_ -= 32;
      var _loc4_:int = li8(wdnative_nternal._opt_print_stats_2E_b);
      if(_loc4_ == 1)
      {
         _loc17_ = wdnative_nternal.L__2E_str1616 & -4;
         var _loc16_:int = li32(_loc17_);
         var _temp_7:* = int(_loc16_ + -16843009);
         var _temp_8:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_7;
         _loc15_ = _loc17_ + 4;
         _loc14_ = 0;
         if(_temp_8 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str1616 + _loc14_;
               _loc15_ = _loc17_ + 4;
               if(uint(_loc4_) < uint(_loc15_))
               {
                  continue;
               }
            }
            while(_loc15_ = _loc17_ + 4, _loc13_ = wdnative_nternal.L__2E_str1616, if(uint(wdnative_nternal.L__2E_str1616) <= uint(_loc15_))
            {
               _loc13_ = _loc15_;
            }, _loc4_ = _loc13_ ^ -1, _loc15_ = wdnative_nternal.L__2E_str1616 + _loc4_, if((uint(_loc15_)) <= 4294967263)
            {
               _loc15_ = -33;
            }, _loc15_ ^= -1, _loc14_ += 1, _loc14_ != 33);
            §§goto(addr01bc);
         }
         while(true)
         {
            _loc17_ = li32(_loc15_);
            _loc4_ = _loc17_ + -16843009;
            _loc16_ = _loc17_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc17_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ -= wdnative_nternal.L__2E_str1616;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1806:* = int(1 - wdnative_nternal.L__2E_str1616);
                  _loc15_ += _temp_1806;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1808:* = int(2 - wdnative_nternal.L__2E_str1616);
                  _loc15_ += _temp_1808;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1810:* = int(3 - wdnative_nternal.L__2E_str1616);
                  _loc15_ += _temp_1810;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr01bc:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str1616,_loc3_ + 4);
         si32(2,_loc3_);
         _loc17_ = wdnative_nternal.L__2E_str2617 & -4;
         _loc15_ = _loc17_ + 4;
         _loc14_ = 0;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop163:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_17:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_17 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop163;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_24:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_24;
                     break loop163;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_26:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_26;
                     break loop163;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_28:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_28;
                     break loop163;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop164:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_34:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_34 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop164;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_41:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_41;
                     break loop164;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_43:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_43;
                     break loop164;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_45:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_45;
                     break loop164;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop165:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_51:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_51 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop165;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_58:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_58;
                     break loop165;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_60:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_60;
                     break loop165;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_62:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_62;
                     break loop165;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str3618 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc15_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str3618 + _loc14_;
               _loc13_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc13_))
               {
                  continue;
               }
            }
            while(_loc13_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str3618, if(uint(wdnative_nternal.L__2E_str3618) <= uint(_loc13_))
            {
               _loc12_ = _loc13_;
            }, _loc4_ = _loc12_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str3618 + _loc4_, if((uint(_loc13_)) <= 4294967284)
            {
               _loc13_ = -12;
            }, _loc13_ ^= -1, _loc14_ += 1, _loc14_ != 12);
            §§goto(addr0725);
         }
         while(true)
         {
            _loc14_ = li32(_loc13_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ -= wdnative_nternal.L__2E_str3618;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1795:* = int(1 - wdnative_nternal.L__2E_str3618);
                  _loc13_ += _temp_1795;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1797:* = int(2 - wdnative_nternal.L__2E_str3618);
                  _loc13_ += _temp_1797;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1799:* = int(3 - wdnative_nternal.L__2E_str3618);
                  _loc13_ += _temp_1799;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr0725:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str3618,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str4619 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc15_ + 4;
         _loc14_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str4619 + _loc14_;
               _loc13_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc13_))
               {
                  continue;
               }
            }
            while(_loc13_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str4619, if(uint(wdnative_nternal.L__2E_str4619) <= uint(_loc13_))
            {
               _loc12_ = _loc13_;
            }, _loc4_ = _loc12_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str4619 + _loc4_, if((uint(_loc13_)) <= 4294967287)
            {
               _loc13_ = -9;
            }, _loc13_ ^= -1, _loc14_ += 1, _loc14_ != 9);
            §§goto(addr08c1);
         }
         while(true)
         {
            _loc14_ = li32(_loc13_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ -= wdnative_nternal.L__2E_str4619;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1784:* = int(1 - wdnative_nternal.L__2E_str4619);
                  _loc13_ += _temp_1784;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1786:* = int(2 - wdnative_nternal.L__2E_str4619);
                  _loc13_ += _temp_1786;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1788:* = int(3 - wdnative_nternal.L__2E_str4619);
                  _loc13_ += _temp_1788;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr08c1:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str4619,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc15_ + 4;
         _loc14_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc14_;
               _loc13_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc13_))
               {
                  continue;
               }
            }
            while(_loc12_ = _loc15_ + 4, _loc13_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc12_))
            {
               _loc13_ = _loc12_;
            }, _loc4_ = _loc13_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc13_ != -1)
            {
               _loc13_ = -2;
            }, _loc13_ ^= -1, _loc14_ += 1, _loc14_ != 2);
            §§goto(addr0a5c);
         }
         while(true)
         {
            _loc14_ = li32(_loc13_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1773:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc13_ += _temp_1773;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1775:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc13_ += _temp_1775;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1777:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc13_ += _temp_1777;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr0a5c:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 0;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc13_ = _loc15_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop166:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_89:* = _loc13_ & 1;
               _loc13_ = _loc15_;
               if(_temp_89 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc14_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop166;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_96:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc14_ + _temp_96;
                     break loop166;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_98:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc14_ + _temp_98;
                     break loop166;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_100:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc14_ + _temp_100;
                     break loop166;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc14_ = wdnative_nternal.L__2E_str6621;
         _loc4_ = li8(wdnative_nternal._opt_abort_2E_b);
         if(_loc4_ == _loc15_)
         {
            _loc14_ = wdnative_nternal.L__2E_str7622;
         }
         _loc13_ = wdnative_nternal.L__2E_str8623 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str8623 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str8623, if(uint(wdnative_nternal.L__2E_str8623) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str8623 + _loc4_, if((uint(_loc12_)) <= 4294967271)
            {
               _loc12_ = -25;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 25);
            §§goto(addr0d54);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str8623;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1762:* = int(1 - wdnative_nternal.L__2E_str8623);
                  _loc12_ += _temp_1762;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1764:* = int(2 - wdnative_nternal.L__2E_str8623);
                  _loc12_ += _temp_1764;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1766:* = int(3 - wdnative_nternal.L__2E_str8623);
                  _loc12_ += _temp_1766;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr0d54:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str8623,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc11_ = _loc14_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc11_ + 4;
            _loc15_ = 0;
            while(true)
            {
               _loc13_ = _loc14_ + _loc15_;
               if((uint(_loc13_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc13_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ += 1;
                  continue;
               }
            }
            §§goto(addr0eb4);
         }
         _loc13_ = _loc11_ + 4;
         while(true)
         {
            _loc15_ = li32(_loc13_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ = _loc13_ - _loc14_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc14_;
                  _loc15_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc14_;
                  _loc15_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc14_;
                  _loc15_ = _loc4_ + _loc13_;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr0eb4:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(_loc14_,_loc3_ + 4);
         si32(2,_loc3_);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop167:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_123:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_123 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop167;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_130:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_130;
                     break loop167;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_132:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_132;
                     break loop167;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_134:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_134;
                     break loop167;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop168:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_140:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_140 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop168;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_147:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_147;
                     break loop168;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_149:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_149;
                     break loop168;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_151:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_151;
                     break loop168;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc14_ = wdnative_nternal.L__2E_str10625;
         _loc4_ = li8(wdnative_nternal._opt_dss_2E_b);
         if(_loc4_ == 0)
         {
            _loc14_ = wdnative_nternal.L__2E_str9624;
         }
         _loc11_ = _loc14_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc11_ + 4;
            _loc15_ = 0;
            while(true)
            {
               _loc13_ = _loc14_ + _loc15_;
               if((uint(_loc13_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc13_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ += 1;
                  continue;
               }
            }
            §§goto(addr12b1);
         }
         _loc15_ = _loc11_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ -= _loc14_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr12b1:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(_loc14_,_loc3_ + 4);
         si32(2,_loc3_);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop169:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_167:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_167 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop169;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_174:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_174;
                     break loop169;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_176:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_176;
                     break loop169;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_178:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_178;
                     break loop169;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop170:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_184:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_184 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop170;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_191:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_191;
                     break loop170;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_193:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_193;
                     break loop170;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_195:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_195;
                     break loop170;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop171:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_201:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_201 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop171;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_208:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_208;
                     break loop171;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_210:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_210;
                     break loop171;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_212:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_212;
                     break loop171;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc14_ = wdnative_nternal.L__2E_str11626;
         _loc4_ = li8(wdnative_nternal._opt_junk_2E_b);
         if(_loc4_ == 0)
         {
            _loc14_ = wdnative_nternal.L__2E_str12627;
         }
         _loc13_ = _loc14_ & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc13_ + 4;
            _loc15_ = 0;
            while(true)
            {
               _loc11_ = _loc14_ + _loc15_;
               if((uint(_loc11_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc11_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ += 1;
                  continue;
               }
            }
            §§goto(addr17f0);
         }
         _loc15_ = _loc13_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ -= _loc14_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr17f0:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(_loc14_,_loc3_ + 4);
         si32(2,_loc3_);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop172:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_228:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_228 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop172;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_235:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_235;
                     break loop172;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_237:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_237;
                     break loop172;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_239:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_239;
                     break loop172;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop173:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_245:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_245 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop173;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_252:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_252;
                     break loop173;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_254:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_254;
                     break loop173;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_256:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_256;
                     break loop173;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop174:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_262:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_262 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop174;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_269:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_269;
                     break loop174;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_271:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_271;
                     break loop174;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_273:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_273;
                     break loop174;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc14_ = wdnative_nternal.L__2E_str14629;
         _loc4_ = li8(wdnative_nternal._opt_mmap_2E_b);
         if(_loc4_ == 0)
         {
            _loc14_ = wdnative_nternal.L__2E_str13628;
         }
         _loc13_ = _loc14_ & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc13_ + 4;
            _loc15_ = 0;
            while(true)
            {
               _loc11_ = _loc14_ + _loc15_;
               if((uint(_loc11_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc11_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ += 1;
                  continue;
               }
            }
            §§goto(addr1d2f);
         }
         _loc15_ = _loc13_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ -= _loc14_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr1d2f:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(_loc14_,_loc3_ + 4);
         si32(2,_loc3_);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop175:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_289:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_289 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop175;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_296:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_296;
                     break loop175;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_298:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_298;
                     break loop175;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_300:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_300;
                     break loop175;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop176:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_306:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_306 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop176;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_313:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_313;
                     break loop176;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_315:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_315;
                     break loop176;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_317:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_317;
                     break loop176;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc14_ = _loc17_ + 4;
         _loc15_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc14_))
         {
            _loc15_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop177:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_323:* = _loc15_ & 1;
               _loc15_ = 0;
               if(_temp_323 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc15_ = li32(_loc14_);
               _loc4_ = _loc15_ + -16843009;
               _loc16_ = _loc15_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc15_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc15_ = _loc14_ - wdnative_nternal.L__2E_str2617;
                     break loop177;
                  }
                  _loc4_ = li8(_loc14_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_330:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_330;
                     break loop177;
                  }
                  _loc4_ = li8(_loc14_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_332:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_332;
                     break loop177;
                  }
                  _loc4_ = li8(_loc14_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_334:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc15_ = _loc14_ + _temp_334;
                     break loop177;
                  }
               }
               _loc14_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc12_ = wdnative_nternal.L__2E_str15630;
         _loc4_ = li8(wdnative_nternal._opt_utrace_2E_b);
         if(_loc4_ == 0)
         {
            _loc12_ = wdnative_nternal.L__2E_str16631;
         }
         _loc11_ = _loc12_ & -4;
         _loc10_ = li32(_loc11_);
         _loc14_ = wdnative_nternal.L__2E_str21636;
         _loc4_ = li8(wdnative_nternal._opt_zero_2E_b);
         if(_loc4_ == 0)
         {
            _loc14_ = wdnative_nternal.L__2E_str22637;
         }
         _loc15_ = wdnative_nternal.L__2E_str19634;
         _loc4_ = li8(wdnative_nternal._opt_xmalloc_2E_b);
         if(_loc4_ == 0)
         {
            _loc15_ = wdnative_nternal.L__2E_str20635;
         }
         _loc13_ = wdnative_nternal.L__2E_str17632;
         _loc4_ = li8(wdnative_nternal._opt_sysv_2E_b);
         if(_loc4_ == 0)
         {
            _loc13_ = wdnative_nternal.L__2E_str18633;
         }
         _loc4_ = _loc10_ + -16843009;
         _loc16_ = _loc10_ & -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc10_ = _loc11_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc6_ = _loc12_ + _loc1_;
               if((uint(_loc6_)) < uint(_loc10_))
               {
                  _loc4_ = li8(_loc6_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr22b5);
         }
         _loc11_ += 4;
         while(true)
         {
            _loc10_ = li32(_loc11_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc11_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
            }
            _loc11_ += 4;
         }
         addr22b5:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc12_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc11_ = _loc13_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc11_ + 4;
            _loc6_ = 0;
            while(true)
            {
               _loc10_ = _loc13_ + _loc6_;
               if((uint(_loc10_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc10_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc6_ += 1;
                  continue;
               }
            }
            §§goto(addr2413);
         }
         _loc12_ = _loc11_ + 4;
         while(true)
         {
            _loc11_ = li32(_loc12_);
            _loc4_ = _loc11_ + -16843009;
            _loc16_ = _loc11_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc11_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc6_ = _loc12_ - _loc13_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc13_;
                  _loc6_ = _loc4_ + _loc12_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc13_;
                  _loc6_ = _loc4_ + _loc12_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc13_;
                  _loc6_ = _loc4_ + _loc12_;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr2413:
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(_loc13_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc11_ = _loc15_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc11_ + 4;
            _loc10_ = 0;
            while(true)
            {
               _loc13_ = _loc15_ + _loc10_;
               if((uint(_loc13_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc13_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc10_ += 1;
                  continue;
               }
            }
            §§goto(addr2572);
         }
         _loc13_ = _loc11_ + 4;
         while(true)
         {
            _loc12_ = li32(_loc13_);
            _loc4_ = _loc12_ + -16843009;
            _loc16_ = _loc12_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc12_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ = _loc13_ - _loc15_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr2572:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(_loc15_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = _loc14_ & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc12_ = _loc13_ + 4;
            _loc15_ = 0;
            while(true)
            {
               _loc11_ = _loc14_ + _loc15_;
               if((uint(_loc11_)) < uint(_loc12_))
               {
                  _loc4_ = li8(_loc11_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ += 1;
                  continue;
               }
            }
            §§goto(addr26d1);
         }
         _loc15_ = _loc13_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc15_ -= _loc14_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc14_;
                  _loc15_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr26d1:
         _loc3_ -= 16;
         si32(_loc15_,_loc3_ + 8);
         si32(_loc14_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc7_ = li32(wdnative_nternal._ncpus);
         si8(0,_loc5_ - 1);
         _loc14_ = _loc5_ - 21;
         _loc12_ = _loc6_ = -20 - _loc14_;
         _loc11_ = _loc6_;
         _loc13_ = _loc6_;
         _loc8_ = _loc6_;
         _loc9_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc7_,_loc3_);
            si32(_loc9_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc2_ = wdnative.eax;
            _loc1_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc9_,_loc3_ + 4);
            si32(_loc7_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc6_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc10_ = _loc8_ = 1;
            if(uint(_loc7_) <= 9)
            {
               _loc10_ = 0;
            }
            if(_loc9_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc9_ != 0)
            {
               _loc10_ = _loc8_;
            }
            _loc6_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc7_ = _loc2_;
            _loc9_ = _loc1_;
         }
         while(_loc10_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str23638 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_383:* = int(_loc16_ + -16843009);
         var _temp_384:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_383;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_384 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str23638 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str23638, if(uint(wdnative_nternal.L__2E_str23638) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str23638 + _loc4_, if(uint(_loc1_) <= 4294967289)
            {
               _loc1_ = -7;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 7);
            §§goto(addr2987);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str23638;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1663:* = int(1 - wdnative_nternal.L__2E_str23638);
                  _loc1_ += _temp_1663;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1665:* = int(2 - wdnative_nternal.L__2E_str23638);
                  _loc1_ += _temp_1665;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1667:* = int(3 - wdnative_nternal.L__2E_str23638);
                  _loc1_ += _temp_1667;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr2987:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str23638,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc6_ = 0 - _loc13_;
            _loc13_ = _loc10_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc4_ = _loc1_ + _loc6_;
               if((uint(_loc4_)) < uint(_loc13_))
               {
                  _loc4_ = _loc1_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr2aef);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc15_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr2aef:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc15_ + 4;
         _loc13_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc13_;
               _loc12_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc12_ != -1)
            {
               _loc12_ = -2;
            }, _loc12_ ^= -1, _loc13_ += 1, _loc13_ != 2);
            §§goto(addr2c88);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1641:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1641;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1643:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1643;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1645:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1645;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr2c88:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop178:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_409:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_409 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop178;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_416:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_416;
                     break loop178;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_418:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_418;
                     break loop178;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_420:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_420;
                     break loop178;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = li32(wdnative_nternal._narenas);
         si8(0,_loc5_ - 1);
         _loc12_ = _loc9_ = -20 - _loc14_;
         _loc11_ = _loc9_;
         _loc13_ = _loc9_;
         _loc8_ = _loc9_;
         _loc6_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc10_,_loc3_);
            si32(_loc6_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc2_ = wdnative.eax;
            _loc7_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc6_,_loc3_ + 4);
            si32(_loc10_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc9_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc1_ = _loc8_ = 1;
            if(uint(_loc10_) <= 9)
            {
               _loc1_ = 0;
            }
            if(_loc6_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc6_ != 0)
            {
               _loc1_ = _loc8_;
            }
            _loc9_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc10_ = _loc2_;
            _loc6_ = _loc7_;
         }
         while(_loc1_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str24639 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_430:* = int(_loc16_ + -16843009);
         var _temp_431:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_430;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_431 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str24639 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc1_ = _loc10_ + 4, _loc2_ = wdnative_nternal.L__2E_str24639, if(uint(wdnative_nternal.L__2E_str24639) <= uint(_loc1_))
            {
               _loc2_ = _loc1_;
            }, _loc4_ = _loc2_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str24639 + _loc4_, if(uint(_loc1_) <= 4294967283)
            {
               _loc1_ = -13;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 13);
            §§goto(addr3077);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str24639;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1630:* = int(1 - wdnative_nternal.L__2E_str24639);
                  _loc1_ += _temp_1630;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1632:* = int(2 - wdnative_nternal.L__2E_str24639);
                  _loc1_ += _temp_1632;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1634:* = int(3 - wdnative_nternal.L__2E_str24639);
                  _loc1_ += _temp_1634;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr3077:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str24639,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc1_ = 0 - _loc13_;
            _loc13_ = _loc10_ + 4;
            _loc6_ = 0;
            while(true)
            {
               _loc4_ = _loc6_ + _loc1_;
               if((uint(_loc4_)) < uint(_loc13_))
               {
                  _loc4_ = _loc6_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc6_ += 1;
                  continue;
               }
            }
            §§goto(addr31e6);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc6_ = _loc15_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr31e6:
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc15_ + 4;
         _loc13_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc13_;
               _loc12_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc12_ != -1)
            {
               _loc12_ = -2;
            }, _loc12_ ^= -1, _loc13_ += 1, _loc13_ != 2);
            §§goto(addr3380);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1608:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1608;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1610:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1610;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1612:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1612;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr3380:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc13_ = _loc17_ + 4;
         _loc15_ = 0;
         _loc12_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc13_))
         {
            _loc12_ = _loc15_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop179:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_456:* = _loc12_ & 1;
               _loc12_ = _loc15_;
               if(_temp_456 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc12_ = li32(_loc13_);
               _loc4_ = _loc12_ + -16843009;
               _loc16_ = _loc12_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc12_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc12_ = _loc13_ - wdnative_nternal.L__2E_str2617;
                     break loop179;
                  }
                  _loc4_ = li8(_loc13_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_463:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc12_ = _loc13_ + _temp_463;
                     break loop179;
                  }
                  _loc4_ = li8(_loc13_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_465:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc12_ = _loc13_ + _temp_465;
                     break loop179;
                  }
                  _loc4_ = li8(_loc13_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_467:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc12_ = _loc13_ + _temp_467;
                     break loop179;
                  }
               }
               _loc13_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(_loc15_,_loc5_ - 1);
         si8(52,_loc5_ - 2);
         _loc12_ = wdnative_nternal.L__2E_str25640 & -4;
         _loc16_ = li32(_loc12_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc14_ + 19;
         _loc11_ = _loc12_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str25640 + _loc15_;
               _loc11_ = _loc12_ + 4;
               if(uint(_loc4_) < uint(_loc11_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc12_ + 4, _loc10_ = wdnative_nternal.L__2E_str25640, if(uint(wdnative_nternal.L__2E_str25640) <= uint(_loc11_))
            {
               _loc10_ = _loc11_;
            }, _loc4_ = _loc10_ ^ -1, _loc11_ = wdnative_nternal.L__2E_str25640 + _loc4_, if((uint(_loc11_)) <= 4294967281)
            {
               _loc11_ = -15;
            }, _loc11_ ^= -1, _loc15_ += 1, _loc15_ != 15);
            §§goto(addr3676);
         }
         while(true)
         {
            _loc15_ = li32(_loc11_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc11_ -= wdnative_nternal.L__2E_str25640;
                  break;
               }
               _loc4_ = li8(_loc11_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1597:* = int(1 - wdnative_nternal.L__2E_str25640);
                  _loc11_ += _temp_1597;
                  break;
               }
               _loc4_ = li8(_loc11_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1599:* = int(2 - wdnative_nternal.L__2E_str25640);
                  _loc11_ += _temp_1599;
                  break;
               }
               _loc4_ = li8(_loc11_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1601:* = int(3 - wdnative_nternal.L__2E_str25640);
                  _loc11_ += _temp_1601;
                  break;
               }
            }
            _loc11_ += 4;
         }
         addr3676:
         _loc3_ -= 16;
         si32(_loc11_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str25640,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc11_ = _loc13_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc15_ = _loc11_ + 4;
            _loc10_ = 0;
            while(true)
            {
               _loc12_ = _loc13_ + _loc10_;
               if((uint(_loc12_)) < uint(_loc15_))
               {
                  _loc4_ = li8(_loc12_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc10_ += 1;
                  continue;
               }
            }
            §§goto(addr37d6);
         }
         _loc12_ = _loc11_ + 4;
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ = _loc12_ - _loc13_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc13_;
                  _loc10_ = _loc4_ + _loc12_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc13_;
                  _loc10_ = _loc4_ + _loc12_;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc13_;
                  _loc10_ = _loc4_ + _loc12_;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr37d6:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(_loc13_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc12_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc12_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc10_ = _loc12_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc15_;
               _loc10_ = _loc12_ + 4;
               if(uint(_loc4_) < uint(_loc10_))
               {
                  continue;
               }
            }
            while(_loc6_ = _loc12_ + 4, _loc10_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc6_))
            {
               _loc10_ = _loc6_;
            }, _loc4_ = _loc10_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc10_ != -1)
            {
               _loc10_ = -2;
            }, _loc10_ ^= -1, _loc15_ += 1, _loc15_ != 2);
            §§goto(addr3970);
         }
         while(true)
         {
            _loc15_ = li32(_loc10_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc10_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1575:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc10_ += _temp_1575;
                  break;
               }
               _loc4_ = li8(_loc10_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1577:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc10_ += _temp_1577;
                  break;
               }
               _loc4_ = li8(_loc10_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1579:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc10_ += _temp_1579;
                  break;
               }
            }
            _loc10_ += 4;
         }
         addr3970:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc12_ = 0;
         _loc10_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc10_ = _loc12_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop180:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_496:* = _loc10_ & 1;
               _loc10_ = _loc12_;
               if(_temp_496 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc10_ = li32(_loc15_);
               _loc4_ = _loc10_ + -16843009;
               _loc16_ = _loc10_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc10_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc10_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop180;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_503:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc15_ + _temp_503;
                     break loop180;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_505:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc15_ + _temp_505;
                     break loop180;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_507:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc15_ + _temp_507;
                     break loop180;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(_loc12_,_loc5_ - 1);
         si8(54,_loc5_ - 2);
         si8(49,_loc5_ - 3);
         _loc10_ = wdnative_nternal.L__2E_str26641 & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc15_ = _loc14_ + 18;
         _loc6_ = _loc10_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str26641 + _loc12_;
               _loc6_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc6_))
               {
                  continue;
               }
            }
            while(_loc6_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str26641, if(uint(wdnative_nternal.L__2E_str26641) <= uint(_loc6_))
            {
               _loc1_ = _loc6_;
            }, _loc4_ = _loc1_ ^ -1, _loc6_ = wdnative_nternal.L__2E_str26641 + _loc4_, if((uint(_loc6_)) <= 4294967281)
            {
               _loc6_ = -15;
            }, _loc6_ ^= -1, _loc12_ += 1, _loc12_ != 15);
            §§goto(addr3c6b);
         }
         while(true)
         {
            _loc12_ = li32(_loc6_);
            _loc4_ = _loc12_ + -16843009;
            _loc16_ = _loc12_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc12_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc6_ -= wdnative_nternal.L__2E_str26641;
                  break;
               }
               _loc4_ = li8(_loc6_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1564:* = int(1 - wdnative_nternal.L__2E_str26641);
                  _loc6_ += _temp_1564;
                  break;
               }
               _loc4_ = li8(_loc6_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1566:* = int(2 - wdnative_nternal.L__2E_str26641);
                  _loc6_ += _temp_1566;
                  break;
               }
               _loc4_ = li8(_loc6_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1568:* = int(3 - wdnative_nternal.L__2E_str26641);
                  _loc6_ += _temp_1568;
                  break;
               }
            }
            _loc6_ += 4;
         }
         addr3c6b:
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str26641,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc12_ = _loc15_ & -4;
         _loc16_ = li32(_loc12_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc6_ = _loc12_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc10_ = _loc15_ + _loc1_;
               if((uint(_loc10_)) < uint(_loc6_))
               {
                  _loc4_ = li8(_loc10_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr3dc3);
         }
         _loc10_ = _loc12_ + 4;
         while(true)
         {
            _loc6_ = li32(_loc10_);
            _loc4_ = _loc6_ + -16843009;
            _loc16_ = _loc6_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc6_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc10_ - _loc15_;
                  break;
               }
               _loc4_ = li8(_loc10_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc15_;
                  _loc1_ = _loc4_ + _loc10_;
                  break;
               }
               _loc4_ = li8(_loc10_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc15_;
                  _loc1_ = _loc4_ + _loc10_;
                  break;
               }
               _loc4_ = li8(_loc10_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc15_;
                  _loc1_ = _loc4_ + _loc10_;
                  break;
               }
            }
            _loc10_ += 4;
         }
         addr3dc3:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc15_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc6_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc6_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc1_ = _loc6_ + 4;
         _loc10_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc10_;
               _loc1_ = _loc6_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc6_ + 4, _loc1_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc1_ != -1)
            {
               _loc1_ = -2;
            }, _loc1_ ^= -1, _loc10_ += 1, _loc10_ != 2);
            §§goto(addr3f41);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1542:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1542;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1544:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1544;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1546:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1546;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr3f41:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc6_ = _loc17_ + 4;
         _loc10_ = 0;
         _loc1_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc6_))
         {
            _loc1_ = _loc10_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop181:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_535:* = _loc1_ & 1;
               _loc1_ = _loc10_;
               if(_temp_535 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc1_ = li32(_loc6_);
               _loc4_ = _loc1_ + -16843009;
               _loc16_ = _loc1_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc1_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc1_ = _loc6_ - wdnative_nternal.L__2E_str2617;
                     break loop181;
                  }
                  _loc4_ = li8(_loc6_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_541:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_541;
                     break loop181;
                  }
                  _loc4_ = li8(_loc6_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_543:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_543;
                     break loop181;
                  }
                  _loc4_ = li8(_loc6_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_545:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_545;
                     break loop181;
                  }
               }
               _loc6_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(_loc10_,_loc5_ - 1);
         si8(52,_loc5_ - 2);
         si8(54,_loc5_ - 3);
         _loc6_ = wdnative_nternal.L__2E_str27642 & -4;
         _loc16_ = li32(_loc6_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc1_ = _loc6_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str27642 + _loc10_;
               _loc1_ = _loc6_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc6_ + 4, _loc1_ = wdnative_nternal.L__2E_str27642, if(uint(wdnative_nternal.L__2E_str27642) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str27642 + _loc4_, if(uint(_loc1_) <= 4294967269)
            {
               _loc1_ = -27;
            }, _loc1_ ^= -1, _loc10_ += 1, _loc10_ != 27);
            §§goto(addr420f);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str27642;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1531:* = int(1 - wdnative_nternal.L__2E_str27642);
                  _loc1_ += _temp_1531;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1533:* = int(2 - wdnative_nternal.L__2E_str27642);
                  _loc1_ += _temp_1533;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1535:* = int(3 - wdnative_nternal.L__2E_str27642);
                  _loc1_ += _temp_1535;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr420f:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str27642,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc12_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc10_ = _loc12_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc6_ = _loc15_ + _loc1_;
               if((uint(_loc6_)) < uint(_loc10_))
               {
                  _loc4_ = li8(_loc6_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr4360);
         }
         _loc6_ = _loc12_ + 4;
         while(true)
         {
            _loc10_ = li32(_loc6_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc6_ - _loc15_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc15_;
                  _loc1_ = _loc4_ + _loc6_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc15_;
                  _loc1_ = _loc4_ + _loc6_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc15_;
                  _loc1_ = _loc4_ + _loc6_;
                  break;
               }
            }
            _loc6_ += 4;
         }
         addr4360:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc15_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc6_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc6_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc1_ = _loc6_ + 4;
         _loc10_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc10_;
               _loc1_ = _loc6_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc1_ = _loc6_ + 4, _loc2_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc1_))
            {
               _loc2_ = _loc1_;
            }, _loc4_ = _loc2_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc1_ != -1)
            {
               _loc1_ = -2;
            }, _loc1_ ^= -1, _loc10_ += 1, _loc10_ != 2);
            §§goto(addr44de);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1509:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1509;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1511:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1511;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1513:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc1_ += _temp_1513;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr44de:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc6_ = _loc17_ + 4;
         _loc10_ = 0;
         _loc1_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc6_))
         {
            _loc1_ = _loc10_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop182:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_571:* = _loc1_ & 1;
               _loc1_ = _loc10_;
               if(_temp_571 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc1_ = li32(_loc6_);
               _loc4_ = _loc1_ + -16843009;
               _loc16_ = _loc1_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc1_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc1_ = _loc6_ - wdnative_nternal.L__2E_str2617;
                     break loop182;
                  }
                  _loc4_ = li8(_loc6_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_577:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_577;
                     break loop182;
                  }
                  _loc4_ = li8(_loc6_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_579:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_579;
                     break loop182;
                  }
                  _loc4_ = li8(_loc6_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_581:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc1_ = _loc6_ + _temp_581;
                     break loop182;
                  }
               }
               _loc6_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(_loc10_,_loc5_ - 1);
         si8(50,_loc5_ - 2);
         _loc6_ = wdnative_nternal.L__2E_str28643 & -4;
         _loc16_ = li32(_loc6_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc1_ = _loc6_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str28643 + _loc10_;
               _loc1_ = _loc6_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc1_ = _loc6_ + 4, _loc2_ = wdnative_nternal.L__2E_str28643, if(uint(wdnative_nternal.L__2E_str28643) <= uint(_loc1_))
            {
               _loc2_ = _loc1_;
            }, _loc4_ = _loc2_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str28643 + _loc4_, if(uint(_loc1_) <= 4294967271)
            {
               _loc1_ = -25;
            }, _loc1_ ^= -1, _loc10_ += 1, _loc10_ != 25);
            §§goto(addr47a4);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str28643;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1498:* = int(1 - wdnative_nternal.L__2E_str28643);
                  _loc1_ += _temp_1498;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1500:* = int(2 - wdnative_nternal.L__2E_str28643);
                  _loc1_ += _temp_1500;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1502:* = int(3 - wdnative_nternal.L__2E_str28643);
                  _loc1_ += _temp_1502;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr47a4:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str28643,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc1_ = _loc11_ + 4;
            _loc10_ = 0;
            while(true)
            {
               _loc6_ = _loc13_ + _loc10_;
               if((uint(_loc6_)) < uint(_loc1_))
               {
                  _loc4_ = li8(_loc6_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc10_ += 1;
                  continue;
               }
            }
            §§goto(addr48fb);
         }
         _loc6_ = _loc11_ + 4;
         while(true)
         {
            _loc10_ = li32(_loc6_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ = _loc6_ - _loc13_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc13_;
                  _loc10_ = _loc4_ + _loc6_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc13_;
                  _loc10_ = _loc4_ + _loc6_;
                  break;
               }
               _loc4_ = li8(_loc6_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc13_;
                  _loc10_ = _loc4_ + _loc6_;
                  break;
               }
            }
            _loc6_ += 4;
         }
         addr48fb:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(_loc13_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = wdnative_nternal.L__2E_str29644 & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str29644 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc1_ = _loc10_ + 4, _loc2_ = wdnative_nternal.L__2E_str29644, if(uint(wdnative_nternal.L__2E_str29644) <= uint(_loc1_))
            {
               _loc2_ = _loc1_;
            }, _loc4_ = _loc2_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str29644 + _loc4_, if(uint(_loc1_) <= 4294967293)
            {
               _loc1_ = -3;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 3);
            §§goto(addr4a7b);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str29644;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1476:* = int(1 - wdnative_nternal.L__2E_str29644);
                  _loc1_ += _temp_1476;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1478:* = int(2 - wdnative_nternal.L__2E_str29644);
                  _loc1_ += _temp_1478;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1480:* = int(3 - wdnative_nternal.L__2E_str29644);
                  _loc1_ += _temp_1480;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr4a7b:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str29644,_loc3_ + 4);
         si32(2,_loc3_);
         _loc10_ = _loc17_ + 4;
         _loc6_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc10_))
         {
            _loc6_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop183:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_607:* = _loc6_ & 1;
               _loc6_ = 0;
               if(_temp_607 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc6_ = li32(_loc10_);
               _loc4_ = _loc6_ + -16843009;
               _loc16_ = _loc6_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc6_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc6_ = _loc10_ - wdnative_nternal.L__2E_str2617;
                     break loop183;
                  }
                  _loc4_ = li8(_loc10_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_614:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc6_ = _loc10_ + _temp_614;
                     break loop183;
                  }
                  _loc4_ = li8(_loc10_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_616:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc6_ = _loc10_ + _temp_616;
                     break loop183;
                  }
                  _loc4_ = li8(_loc10_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_618:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc6_ = _loc10_ + _temp_618;
                     break loop183;
                  }
               }
               _loc10_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(0,_loc5_ - 1);
         si8(56,_loc5_ - 2);
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc10_ = _loc11_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc6_ = _loc13_ + _loc1_;
               if((uint(_loc6_)) < uint(_loc10_))
               {
                  _loc4_ = li8(_loc6_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr4d1e);
         }
         _loc11_ += 4;
         while(true)
         {
            _loc10_ = li32(_loc11_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc11_ - _loc13_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc13_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc13_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
               _loc4_ = li8(_loc11_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc13_;
                  _loc1_ = _loc4_ + _loc11_;
                  break;
               }
            }
            _loc11_ += 4;
         }
         addr4d1e:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc13_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str30645 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc10_ = _loc13_ + 4;
         _loc11_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str30645 + _loc11_;
               _loc10_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc10_))
               {
                  continue;
               }
            }
            while(_loc10_ = _loc13_ + 4, _loc6_ = wdnative_nternal.L__2E_str30645, if(uint(wdnative_nternal.L__2E_str30645) <= uint(_loc10_))
            {
               _loc6_ = _loc10_;
            }, _loc4_ = _loc6_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str30645 + _loc4_, if((uint(_loc10_)) <= 4294967293)
            {
               _loc10_ = -3;
            }, _loc10_ ^= -1, _loc11_ += 1, _loc11_ != 3);
            §§goto(addr4eb8);
         }
         while(true)
         {
            _loc13_ = li32(_loc10_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ -= wdnative_nternal.L__2E_str30645;
                  break;
               }
               _loc4_ = li8(_loc10_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1454:* = int(1 - wdnative_nternal.L__2E_str30645);
                  _loc10_ += _temp_1454;
                  break;
               }
               _loc4_ = li8(_loc10_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1456:* = int(2 - wdnative_nternal.L__2E_str30645);
                  _loc10_ += _temp_1456;
                  break;
               }
               _loc4_ = li8(_loc10_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1458:* = int(3 - wdnative_nternal.L__2E_str30645);
                  _loc10_ += _temp_1458;
                  break;
               }
            }
            _loc10_ += 4;
         }
         addr4eb8:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str30645,_loc3_ + 4);
         si32(2,_loc3_);
         _loc11_ = _loc17_ + 4;
         _loc13_ = 0;
         _loc10_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc11_))
         {
            _loc10_ = _loc13_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop184:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_639:* = _loc10_ & 1;
               _loc10_ = _loc13_;
               if(_temp_639 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc10_ = li32(_loc11_);
               _loc4_ = _loc10_ + -16843009;
               _loc16_ = _loc10_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc10_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc10_ = _loc11_ - wdnative_nternal.L__2E_str2617;
                     break loop184;
                  }
                  _loc4_ = li8(_loc11_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_646:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_646;
                     break loop184;
                  }
                  _loc4_ = li8(_loc11_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_648:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_648;
                     break loop184;
                  }
                  _loc4_ = li8(_loc11_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_650:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_650;
                     break loop184;
                  }
               }
               _loc11_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc11_ = _loc17_ + 4;
         _loc10_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc11_))
         {
            _loc10_ = _loc13_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop185:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_656:* = _loc10_ & 1;
               _loc10_ = _loc13_;
               if(_temp_656 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc10_ = li32(_loc11_);
               _loc4_ = _loc10_ + -16843009;
               _loc16_ = _loc10_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc10_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc10_ = _loc11_ - wdnative_nternal.L__2E_str2617;
                     break loop185;
                  }
                  _loc4_ = li8(_loc11_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_663:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_663;
                     break loop185;
                  }
                  _loc4_ = li8(_loc11_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_665:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_665;
                     break loop185;
                  }
                  _loc4_ = li8(_loc11_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_667:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc10_ = _loc11_ + _temp_667;
                     break loop185;
                  }
               }
               _loc11_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         si8(_loc13_,_loc5_ - 1);
         si8(54,_loc5_ - 2);
         si8(49,_loc5_ - 3);
         _loc11_ = wdnative_nternal.L__2E_str31646 & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc10_ = _loc11_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str31646 + _loc13_;
               _loc10_ = _loc11_ + 4;
               if(uint(_loc4_) < uint(_loc10_))
               {
                  continue;
               }
            }
            while(_loc6_ = _loc11_ + 4, _loc10_ = wdnative_nternal.L__2E_str31646, if(uint(wdnative_nternal.L__2E_str31646) <= uint(_loc6_))
            {
               _loc10_ = _loc6_;
            }, _loc4_ = _loc10_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str31646 + _loc4_, if((uint(_loc10_)) <= 4294967272)
            {
               _loc10_ = -24;
            }, _loc10_ ^= -1, _loc13_ += 1, _loc13_ != 24);
            §§goto(addr52f0);
         }
         while(true)
         {
            _loc13_ = li32(_loc10_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ -= wdnative_nternal.L__2E_str31646;
                  break;
               }
               _loc4_ = li8(_loc10_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1443:* = int(1 - wdnative_nternal.L__2E_str31646);
                  _loc10_ += _temp_1443;
                  break;
               }
               _loc4_ = li8(_loc10_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1445:* = int(2 - wdnative_nternal.L__2E_str31646);
                  _loc10_ += _temp_1445;
                  break;
               }
               _loc4_ = li8(_loc10_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1447:* = int(3 - wdnative_nternal.L__2E_str31646);
                  _loc10_ += _temp_1447;
                  break;
               }
            }
            _loc10_ += 4;
         }
         addr52f0:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str31646,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc12_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc13_ = _loc12_ + 4;
            _loc10_ = 0;
            while(true)
            {
               _loc11_ = _loc15_ + _loc10_;
               if((uint(_loc11_)) < uint(_loc13_))
               {
                  _loc4_ = li8(_loc11_);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc10_ += 1;
                  continue;
               }
            }
            §§goto(addr544a);
         }
         _loc13_ = _loc12_ + 4;
         while(true)
         {
            _loc12_ = li32(_loc13_);
            _loc4_ = _loc12_ + -16843009;
            _loc16_ = _loc12_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc12_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc10_ = _loc13_ - _loc15_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc15_;
                  _loc10_ = _loc4_ + _loc13_;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr544a:
         _loc3_ -= 16;
         si32(_loc10_,_loc3_ + 8);
         si32(_loc15_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str29644 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str29644 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str29644, if(uint(wdnative_nternal.L__2E_str29644) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str29644 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 3);
            §§goto(addr55e5);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str29644;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1421:* = int(1 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1421;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1423:* = int(2 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1423;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1425:* = int(3 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1425;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr55e5:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str29644,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop186:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_695:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_695 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop186;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_702:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_702;
                     break loop186;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_704:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_704;
                     break loop186;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_706:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_706;
                     break loop186;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc6_ = li32(wdnative_nternal._qspace_max);
         si8(0,_loc5_ - 1);
         _loc2_ = _loc9_ = -20 - _loc14_;
         _loc12_ = _loc9_;
         _loc13_ = _loc9_;
         _loc8_ = _loc9_;
         _loc10_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc6_,_loc3_);
            si32(_loc10_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc11_ = wdnative.eax;
            _loc1_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc10_,_loc3_ + 4);
            si32(_loc6_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc9_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc7_ = _loc8_ = 1;
            if(uint(_loc6_) <= 9)
            {
               _loc7_ = 0;
            }
            if(_loc10_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc10_ != 0)
            {
               _loc7_ = _loc8_;
            }
            _loc9_ += 1;
            _loc2_ += 1;
            _loc12_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc6_ = _loc11_;
            _loc10_ = _loc1_;
         }
         while(_loc7_ != 0);
         _loc11_ = 0 - _loc2_;
         _loc10_ = _loc11_ & -4;
         _loc16_ = li32(_loc10_);
         var _temp_717:* = int(_loc16_ + -16843009);
         var _temp_718:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_717;
         _loc12_ = 0 - _loc12_;
         if(_temp_718 != 0)
         {
            _loc1_ = 0 - _loc13_;
            _loc6_ = _loc10_ + 4;
            _loc13_ = 0;
            while(true)
            {
               _loc4_ = _loc13_ + _loc1_;
               if((uint(_loc4_)) < uint(_loc6_))
               {
                  _loc4_ = _loc13_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc13_ += 1;
                  continue;
               }
            }
            §§goto(addr59c3);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ = _loc15_ - _loc11_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc11_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc11_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc11_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr59c3:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(_loc12_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str30645 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str30645 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str30645, if(uint(wdnative_nternal.L__2E_str30645) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str30645 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 3);
            §§goto(addr5b5e);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str30645;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1399:* = int(1 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1399;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1401:* = int(2 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1401;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1403:* = int(3 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1403;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr5b5e:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str30645,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop187:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_736:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_736 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop187;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_743:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_743;
                     break loop187;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_745:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_745;
                     break loop187;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_747:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_747;
                     break loop187;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop188:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_753:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_753 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop188;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_760:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_760;
                     break loop188;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_762:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_762;
                     break loop188;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_764:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_764;
                     break loop188;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc2_ = li32(wdnative_nternal._cspace_min);
         si8(0,_loc5_ - 1);
         _loc1_ = -20 - _loc14_;
         _loc12_ = _loc1_;
         _loc11_ = _loc1_;
         _loc13_ = _loc1_;
         _loc8_ = _loc1_;
         _loc9_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc2_,_loc3_);
            si32(_loc9_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc10_ = wdnative.eax;
            _loc6_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc9_,_loc3_ + 4);
            si32(_loc2_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc1_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc7_ = _loc8_ = 1;
            if(uint(_loc2_) <= 9)
            {
               _loc7_ = 0;
            }
            if(_loc9_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc9_ != 0)
            {
               _loc7_ = _loc8_;
            }
            _loc1_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc2_ = _loc10_;
            _loc9_ = _loc6_;
         }
         while(_loc7_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str32647 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_773:* = int(_loc16_ + -16843009);
         var _temp_774:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_773;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_774 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str32647 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str32647, if(uint(wdnative_nternal.L__2E_str32647) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str32647 + _loc4_, if(uint(_loc1_) <= 4294967270)
            {
               _loc1_ = -26;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 26);
            §§goto(addr6089);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str32647;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1388:* = int(1 - wdnative_nternal.L__2E_str32647);
                  _loc1_ += _temp_1388;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1390:* = int(2 - wdnative_nternal.L__2E_str32647);
                  _loc1_ += _temp_1390;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1392:* = int(3 - wdnative_nternal.L__2E_str32647);
                  _loc1_ += _temp_1392;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr6089:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str32647,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc6_ = 0 - _loc13_;
            _loc1_ = _loc10_ + 4;
            _loc13_ = 0;
            while(true)
            {
               _loc4_ = _loc13_ + _loc6_;
               if((uint(_loc4_)) < uint(_loc1_))
               {
                  _loc4_ = _loc13_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc13_ += 1;
                  continue;
               }
            }
            §§goto(addr61f8);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ = _loc15_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr61f8:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str29644 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc15_ + 4;
         _loc13_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str29644 + _loc13_;
               _loc12_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str29644, if(uint(wdnative_nternal.L__2E_str29644) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str29644 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc13_ += 1, _loc13_ != 3);
            §§goto(addr6393);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str29644;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1366:* = int(1 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1366;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1368:* = int(2 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1368;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1370:* = int(3 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1370;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr6393:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str29644,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop189:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_799:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_799 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop189;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_806:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_806;
                     break loop189;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_808:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_808;
                     break loop189;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_810:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_810;
                     break loop189;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc2_ = li32(wdnative_nternal._cspace_max);
         si8(0,_loc5_ - 1);
         _loc10_ = _loc11_ = -20 - _loc14_;
         _loc12_ = _loc11_;
         _loc13_ = _loc11_;
         _loc8_ = _loc11_;
         _loc9_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc2_,_loc3_);
            si32(_loc9_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc1_ = wdnative.eax;
            _loc6_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc9_,_loc3_ + 4);
            si32(_loc2_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc11_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc7_ = _loc8_ = 1;
            if(uint(_loc2_) <= 9)
            {
               _loc7_ = 0;
            }
            if(_loc9_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc9_ != 0)
            {
               _loc7_ = _loc8_;
            }
            _loc11_ += 1;
            _loc10_ += 1;
            _loc12_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc2_ = _loc1_;
            _loc9_ = _loc6_;
         }
         while(_loc7_ != 0);
         _loc11_ = 0 - _loc10_;
         _loc10_ = _loc11_ & -4;
         _loc16_ = li32(_loc10_);
         var _temp_821:* = int(_loc16_ + -16843009);
         var _temp_822:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_821;
         _loc12_ = 0 - _loc12_;
         if(_temp_822 != 0)
         {
            _loc6_ = 0 - _loc13_;
            _loc13_ = _loc10_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc4_ = _loc1_ + _loc6_;
               if((uint(_loc4_)) < uint(_loc13_))
               {
                  _loc4_ = _loc1_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr6769);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc15_ - _loc11_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr6769:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc12_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str30645 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str30645 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str30645, if(uint(wdnative_nternal.L__2E_str30645) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str30645 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 3);
            §§goto(addr6903);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str30645;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1344:* = int(1 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1344;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1346:* = int(2 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1346;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1348:* = int(3 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1348;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr6903:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str30645,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop190:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_840:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_840 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop190;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_847:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_847;
                     break loop190;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_849:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_849;
                     break loop190;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_851:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_851;
                     break loop190;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop191:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_857:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_857 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop191;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_864:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_864;
                     break loop191;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_866:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_866;
                     break loop191;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_868:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_868;
                     break loop191;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc9_ = li32(wdnative_nternal._sspace_min);
         si8(0,_loc5_ - 1);
         _loc1_ = -20 - _loc14_;
         _loc12_ = _loc1_;
         _loc11_ = _loc1_;
         _loc13_ = _loc1_;
         _loc8_ = _loc1_;
         _loc7_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc9_,_loc3_);
            si32(_loc7_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc10_ = wdnative.eax;
            _loc6_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc7_,_loc3_ + 4);
            si32(_loc9_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc16_ = li8(_loc4_);
            _loc4_ = _loc1_ ^ -1;
            si8(_loc16_,_loc4_);
            _loc2_ = _loc8_ = 1;
            if(uint(_loc9_) <= 9)
            {
               _loc2_ = 0;
            }
            if(_loc7_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc7_ != 0)
            {
               _loc2_ = _loc8_;
            }
            _loc1_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc9_ = _loc10_;
            _loc7_ = _loc6_;
         }
         while(_loc2_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str33648 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_877:* = int(_loc16_ + -16843009);
         var _temp_878:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_877;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_878 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str33648 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc1_ = _loc10_ + 4, _loc2_ = wdnative_nternal.L__2E_str33648, if(uint(wdnative_nternal.L__2E_str33648) <= uint(_loc1_))
            {
               _loc2_ = _loc1_;
            }, _loc4_ = _loc2_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str33648 + _loc4_, if(uint(_loc1_) <= 4294967272)
            {
               _loc1_ = -24;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 24);
            §§goto(addr6e2f);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str33648;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1333:* = int(1 - wdnative_nternal.L__2E_str33648);
                  _loc1_ += _temp_1333;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1335:* = int(2 - wdnative_nternal.L__2E_str33648);
                  _loc1_ += _temp_1335;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1337:* = int(3 - wdnative_nternal.L__2E_str33648);
                  _loc1_ += _temp_1337;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr6e2f:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str33648,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc6_ = 0 - _loc13_;
            _loc13_ = _loc10_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc4_ = _loc1_ + _loc6_;
               if((uint(_loc4_)) < uint(_loc13_))
               {
                  _loc4_ = _loc1_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr6f97);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc15_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr6f97:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str29644 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str29644 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str29644, if(uint(wdnative_nternal.L__2E_str29644) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str29644 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 3);
            §§goto(addr7131);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str29644;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1311:* = int(1 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1311;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1313:* = int(2 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1313;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1315:* = int(3 - wdnative_nternal.L__2E_str29644);
                  _loc12_ += _temp_1315;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr7131:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str29644,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop192:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_903:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_903 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop192;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_910:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_910;
                     break loop192;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_912:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_912;
                     break loop192;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_914:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_914;
                     break loop192;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc4_ = li8(wdnative_nternal._sspace_max_2E_b);
         si8(0,_loc5_ - 1);
         _loc11_ = 3840;
         if(_loc4_ == 0)
         {
            _loc11_ = 0;
         }
         _loc10_ = _loc6_ = -20 - _loc14_;
         _loc12_ = _loc6_;
         _loc13_ = _loc6_;
         _loc8_ = _loc6_;
         _loc7_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc11_,_loc3_);
            si32(_loc7_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc9_ = wdnative.eax;
            _loc2_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc7_,_loc3_ + 4);
            si32(_loc11_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc16_ = li8(_loc4_);
            _loc4_ = _loc6_ ^ -1;
            si8(_loc16_,_loc4_);
            _loc1_ = _loc8_ = 1;
            if(uint(_loc11_) <= 9)
            {
               _loc1_ = 0;
            }
            if(_loc7_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc7_ != 0)
            {
               _loc1_ = _loc8_;
            }
            _loc6_ += 1;
            _loc10_ += 1;
            _loc12_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc11_ = _loc9_;
            _loc7_ = _loc2_;
         }
         while(_loc1_ != 0);
         _loc11_ = 0 - _loc10_;
         _loc10_ = _loc11_ & -4;
         _loc16_ = li32(_loc10_);
         var _temp_925:* = int(_loc16_ + -16843009);
         var _temp_926:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_925;
         _loc12_ = 0 - _loc12_;
         if(_temp_926 != 0)
         {
            _loc13_ = 0 - _loc13_;
            _loc6_ = _loc10_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc4_ = _loc1_ + _loc13_;
               if((uint(_loc4_)) < uint(_loc6_))
               {
                  _loc4_ = _loc1_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr751a);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc15_ - _loc11_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc11_;
                  _loc1_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr751a:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc12_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str30645 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc15_ + 4;
         _loc13_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str30645 + _loc13_;
               _loc12_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str30645, if(uint(wdnative_nternal.L__2E_str30645) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str30645 + _loc4_, if((uint(_loc12_)) <= 4294967293)
            {
               _loc12_ = -3;
            }, _loc12_ ^= -1, _loc13_ += 1, _loc13_ != 3);
            §§goto(addr76b4);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str30645;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1289:* = int(1 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1289;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1291:* = int(2 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1291;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1293:* = int(3 - wdnative_nternal.L__2E_str30645);
                  _loc12_ += _temp_1293;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr76b4:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str30645,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop193:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_944:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_944 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop193;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_951:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_951;
                     break loop193;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_953:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_953;
                     break loop193;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_955:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_955;
                     break loop193;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop194:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_961:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_961 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop194;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_968:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_968;
                     break loop194;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_970:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_970;
                     break loop194;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_972:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_972;
                     break loop194;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc2_ = li32(wdnative_nternal._opt_dirty_max);
         si8(0,_loc5_ - 1);
         _loc12_ = _loc6_ = -20 - _loc14_;
         _loc11_ = _loc6_;
         _loc13_ = _loc6_;
         _loc8_ = _loc6_;
         _loc1_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc2_,_loc3_);
            si32(_loc1_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc7_ = wdnative.eax;
            _loc9_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc1_,_loc3_ + 4);
            si32(_loc2_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc6_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc10_ = _loc8_ = 1;
            if(uint(_loc2_) <= 9)
            {
               _loc10_ = 0;
            }
            if(_loc1_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc1_ != 0)
            {
               _loc10_ = _loc8_;
            }
            _loc6_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc2_ = _loc7_;
            _loc1_ = _loc9_;
         }
         while(_loc10_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str34649 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_982:* = int(_loc16_ + -16843009);
         var _temp_983:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_982;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_983 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str34649 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str34649, if(uint(wdnative_nternal.L__2E_str34649) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str34649 + _loc4_, if(uint(_loc1_) <= 4294967268)
            {
               _loc1_ = -28;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 28);
            §§goto(addr7be0);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str34649;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1278:* = int(1 - wdnative_nternal.L__2E_str34649);
                  _loc1_ += _temp_1278;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1280:* = int(2 - wdnative_nternal.L__2E_str34649);
                  _loc1_ += _temp_1280;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1282:* = int(3 - wdnative_nternal.L__2E_str34649);
                  _loc1_ += _temp_1282;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr7be0:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str34649,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc13_ = 0 - _loc13_;
            _loc6_ = _loc10_ + 4;
            _loc1_ = 0;
            while(true)
            {
               _loc4_ = _loc1_ + _loc13_;
               if((uint(_loc4_)) < uint(_loc6_))
               {
                  _loc4_ = _loc1_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc1_ += 1;
                  continue;
               }
            }
            §§goto(addr7d48);
         }
         _loc13_ = _loc10_ + 4;
         while(true)
         {
            _loc15_ = li32(_loc13_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ = _loc13_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc1_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc1_ = _loc4_ + _loc13_;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc1_ = _loc4_ + _loc13_;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr7d48:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = wdnative_nternal.L__2E_str5620 & -4;
         _loc16_ = li32(_loc13_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc12_ = _loc13_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str5620 + _loc15_;
               _loc12_ = _loc13_ + 4;
               if(uint(_loc4_) < uint(_loc12_))
               {
                  continue;
               }
            }
            while(_loc11_ = _loc13_ + 4, _loc12_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc11_))
            {
               _loc12_ = _loc11_;
            }, _loc4_ = _loc12_ ^ -1, _loc12_ = wdnative_nternal.L__2E_str5620 + _loc4_, if(_loc12_ != -1)
            {
               _loc12_ = -2;
            }, _loc12_ ^= -1, _loc15_ += 1, _loc15_ != 2);
            §§goto(addr7ee1);
         }
         while(true)
         {
            _loc15_ = li32(_loc12_);
            _loc4_ = _loc15_ + -16843009;
            _loc16_ = _loc15_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc15_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc12_ -= wdnative_nternal.L__2E_str5620;
                  break;
               }
               _loc4_ = li8(_loc12_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1256:* = int(1 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1256;
                  break;
               }
               _loc4_ = li8(_loc12_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1258:* = int(2 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1258;
                  break;
               }
               _loc4_ = li8(_loc12_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1260:* = int(3 - wdnative_nternal.L__2E_str5620);
                  _loc12_ += _temp_1260;
                  break;
               }
            }
            _loc12_ += 4;
         }
         addr7ee1:
         _loc3_ -= 16;
         si32(_loc12_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str5620,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop195:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1008:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_1008 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop195;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1015:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1015;
                     break loop195;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1017:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1017;
                     break loop195;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1019:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1019;
                     break loop195;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc2_ = li32(wdnative_nternal._chunksize);
         si8(0,_loc5_ - 1);
         _loc12_ = _loc10_ = -20 - _loc14_;
         _loc11_ = _loc10_;
         _loc13_ = _loc10_;
         _loc8_ = _loc10_;
         _loc9_ = 0;
         do
         {
            _loc15_ = _loc8_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc2_,_loc3_);
            si32(_loc9_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc1_ = wdnative.eax;
            _loc6_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc9_,_loc3_ + 4);
            si32(_loc2_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc16_ = li8(_loc4_);
            _loc4_ = _loc10_ ^ -1;
            si8(_loc16_,_loc4_);
            _loc7_ = _loc8_ = 1;
            if(uint(_loc2_) <= 9)
            {
               _loc7_ = 0;
            }
            if(_loc9_ == 0)
            {
               _loc8_ = 0;
            }
            if(_loc9_ != 0)
            {
               _loc7_ = _loc8_;
            }
            _loc10_ += 1;
            _loc12_ += 1;
            _loc11_ += 1;
            _loc13_ += 1;
            _loc8_ = _loc15_ + 1;
            _loc2_ = _loc1_;
            _loc9_ = _loc6_;
         }
         while(_loc7_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str35650 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_1029:* = int(_loc16_ + -16843009);
         var _temp_1030:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_1029;
         _loc12_ = 0 - _loc12_;
         _loc11_ = 0 - _loc11_;
         _loc1_ = _loc10_ + 4;
         _loc6_ = 0;
         if(_temp_1030 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str35650 + _loc6_;
               _loc1_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc1_))
               {
                  continue;
               }
            }
            while(_loc2_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str35650, if(uint(wdnative_nternal.L__2E_str35650) <= uint(_loc2_))
            {
               _loc1_ = _loc2_;
            }, _loc4_ = _loc1_ ^ -1, _loc1_ = wdnative_nternal.L__2E_str35650 + _loc4_, if(uint(_loc1_) <= 4294967283)
            {
               _loc1_ = -13;
            }, _loc1_ ^= -1, _loc6_ += 1, _loc6_ != 13);
            §§goto(addr82cf);
         }
         while(true)
         {
            _loc10_ = li32(_loc1_);
            _loc4_ = _loc10_ + -16843009;
            _loc16_ = _loc10_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc10_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc1_ -= wdnative_nternal.L__2E_str35650;
                  break;
               }
               _loc4_ = li8(_loc1_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1245:* = int(1 - wdnative_nternal.L__2E_str35650);
                  _loc1_ += _temp_1245;
                  break;
               }
               _loc4_ = li8(_loc1_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1247:* = int(2 - wdnative_nternal.L__2E_str35650);
                  _loc1_ += _temp_1247;
                  break;
               }
               _loc4_ = li8(_loc1_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1249:* = int(3 - wdnative_nternal.L__2E_str35650);
                  _loc1_ += _temp_1249;
                  break;
               }
            }
            _loc1_ += 4;
         }
         addr82cf:
         _loc3_ -= 16;
         si32(_loc1_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str35650,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc10_ = _loc12_ & -4;
         _loc16_ = li32(_loc10_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc6_ = 0 - _loc13_;
            _loc1_ = _loc10_ + 4;
            _loc13_ = 0;
            while(true)
            {
               _loc4_ = _loc13_ + _loc6_;
               if((uint(_loc4_)) < uint(_loc1_))
               {
                  _loc4_ = _loc13_ - _loc15_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc13_ += 1;
                  continue;
               }
            }
            §§goto(addr843e);
         }
         _loc15_ = _loc10_ + 4;
         while(true)
         {
            _loc13_ = li32(_loc15_);
            _loc4_ = _loc13_ + -16843009;
            _loc16_ = _loc13_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ = _loc15_ - _loc12_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc12_;
                  _loc13_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr843e:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(_loc11_,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop196:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1048:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_1048 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop196;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1055:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1055;
                     break loop196;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1057:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1057;
                     break loop196;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1059:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1059;
                     break loop196;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = 0;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop197:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1065:* = _loc13_ & 1;
               _loc13_ = 0;
               if(_temp_1065 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop197;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1072:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1072;
                     break loop197;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1074:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1074;
                     break loop197;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1076:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1076;
                     break loop197;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc13_ = li32(wdnative_nternal._opt_chunk_2pow);
         si8(0,_loc5_ - 1);
         _loc1_ = -20 - _loc14_;
         _loc11_ = _loc1_;
         _loc12_ = _loc1_;
         _loc15_ = _loc1_;
         _loc7_ = _loc1_;
         _loc6_ = 0;
         do
         {
            _loc14_ = _loc7_;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc13_,_loc3_);
            si32(_loc6_,_loc3_ + 4);
            wdnative.ESP = _loc3_;
            F___udivdi3();
            _loc3_ += 16;
            _loc9_ = wdnative.eax;
            _loc2_ = wdnative.edx;
            _loc3_ -= 16;
            si32(0,_loc3_ + 12);
            si32(10,_loc3_ + 8);
            si32(_loc6_,_loc3_ + 4);
            si32(_loc13_,_loc3_);
            wdnative.ESP = _loc3_;
            F___umoddi3();
            _loc3_ += 16;
            _loc4_ = wdnative.eax;
            _loc4_ = wdnative_nternal.L__2E_str702 + _loc4_;
            _loc4_ = li8(_loc4_);
            _loc16_ = _loc1_ ^ -1;
            si8(_loc4_,_loc16_);
            _loc10_ = _loc7_ = 1;
            if(uint(_loc13_) <= 9)
            {
               _loc10_ = 0;
            }
            if(_loc6_ == 0)
            {
               _loc7_ = 0;
            }
            if(_loc6_ != 0)
            {
               _loc10_ = _loc7_;
            }
            _loc1_ += 1;
            _loc11_ += 1;
            _loc12_ += 1;
            _loc15_ += 1;
            _loc7_ = _loc14_ + 1;
            _loc13_ = _loc9_;
            _loc6_ = _loc2_;
         }
         while(_loc10_ != 0);
         _loc10_ = wdnative_nternal.L__2E_str36651 & -4;
         _loc16_ = li32(_loc10_);
         var _temp_1085:* = int(_loc16_ + -16843009);
         var _temp_1086:* = (_loc16_ = (_loc16_ &= -2139062144) ^ -2139062144) & _temp_1085;
         _loc13_ = 0 - _loc11_;
         _loc12_ = 0 - _loc12_;
         _loc6_ = _loc10_ + 4;
         _loc11_ = 0;
         if(_temp_1086 != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str36651 + _loc11_;
               _loc6_ = _loc10_ + 4;
               if(uint(_loc4_) < uint(_loc6_))
               {
                  continue;
               }
            }
            while(_loc6_ = _loc10_ + 4, _loc1_ = wdnative_nternal.L__2E_str36651, if(uint(wdnative_nternal.L__2E_str36651) <= uint(_loc6_))
            {
               _loc1_ = _loc6_;
            }, _loc4_ = _loc1_ ^ -1, _loc6_ = wdnative_nternal.L__2E_str36651 + _loc4_, if((uint(_loc6_)) <= 4294967291)
            {
               _loc6_ = -5;
            }, _loc6_ ^= -1, _loc11_ += 1, _loc11_ != 5);
            §§goto(addr8983);
         }
         while(true)
         {
            _loc11_ = li32(_loc6_);
            _loc4_ = _loc11_ + -16843009;
            _loc16_ = _loc11_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc11_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc6_ -= wdnative_nternal.L__2E_str36651;
                  break;
               }
               _loc4_ = li8(_loc6_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1223:* = int(1 - wdnative_nternal.L__2E_str36651);
                  _loc6_ += _temp_1223;
                  break;
               }
               _loc4_ = li8(_loc6_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1225:* = int(2 - wdnative_nternal.L__2E_str36651);
                  _loc6_ += _temp_1225;
                  break;
               }
               _loc4_ = li8(_loc6_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1227:* = int(3 - wdnative_nternal.L__2E_str36651);
                  _loc6_ += _temp_1227;
                  break;
               }
            }
            _loc6_ += 4;
         }
         addr8983:
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str36651,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc11_ = _loc13_ & -4;
         _loc16_ = li32(_loc11_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         if(_loc4_ != 0)
         {
            _loc15_ = 0 - _loc15_;
            _loc10_ = _loc11_ + 4;
            _loc6_ = 0;
            while(true)
            {
               _loc4_ = _loc6_ + _loc15_;
               if((uint(_loc4_)) < uint(_loc10_))
               {
                  _loc4_ = _loc6_ - _loc14_;
                  _loc4_ = li8(_loc4_ - 1);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc6_ += 1;
                  continue;
               }
            }
            §§goto(addr8af5);
         }
         _loc15_ = _loc11_ + 4;
         while(true)
         {
            _loc14_ = li32(_loc15_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc6_ = _loc15_ - _loc13_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 1);
               if(_loc4_ == 0)
               {
                  _loc4_ = 1 - _loc13_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 2);
               if(_loc4_ == 0)
               {
                  _loc4_ = 2 - _loc13_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
               _loc4_ = li8(_loc15_ + 3);
               if(_loc4_ == 0)
               {
                  _loc4_ = 3 - _loc13_;
                  _loc6_ = _loc4_ + _loc15_;
                  break;
               }
            }
            _loc15_ += 4;
         }
         addr8af5:
         _loc3_ -= 16;
         si32(_loc6_,_loc3_ + 8);
         si32(_loc12_,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc14_ = wdnative_nternal.L__2E_str37652 & -4;
         _loc16_ = li32(_loc14_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc14_ + 4;
         _loc15_ = 0;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str37652 + _loc15_;
               _loc13_ = _loc14_ + 4;
               if(uint(_loc4_) < uint(_loc13_))
               {
                  continue;
               }
            }
            while(_loc13_ = _loc14_ + 4, _loc12_ = wdnative_nternal.L__2E_str37652, if(uint(wdnative_nternal.L__2E_str37652) <= uint(_loc13_))
            {
               _loc12_ = _loc13_;
            }, _loc4_ = _loc12_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str37652 + _loc4_, if((uint(_loc13_)) <= 4294967293)
            {
               _loc13_ = -3;
            }, _loc13_ ^= -1, _loc15_ += 1, _loc15_ != 3);
            §§goto(addr8c90);
         }
         while(true)
         {
            _loc14_ = li32(_loc13_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ -= wdnative_nternal.L__2E_str37652;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1201:* = int(1 - wdnative_nternal.L__2E_str37652);
                  _loc13_ += _temp_1201;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1203:* = int(2 - wdnative_nternal.L__2E_str37652);
                  _loc13_ += _temp_1203;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1205:* = int(3 - wdnative_nternal.L__2E_str37652);
                  _loc13_ += _temp_1205;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr8c90:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str37652,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc14_ = 0;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop198:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1112:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_1112 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop198;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1119:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1119;
                     break loop198;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1121:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1121;
                     break loop198;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1123:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1123;
                     break loop198;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc15_ = wdnative_nternal.L__2E_str38653 & -4;
         _loc16_ = li32(_loc15_);
         _loc4_ = _loc16_ + -16843009;
         _loc16_ &= -2139062144;
         _loc16_ = _loc16_ ^ -2139062144;
         _loc4_ = _loc16_ & _loc4_;
         _loc13_ = _loc15_ + 4;
         if(_loc4_ != 0)
         {
            do
            {
               _loc4_ = wdnative_nternal.L__2E_str38653 + _loc14_;
               _loc13_ = _loc15_ + 4;
               if(uint(_loc4_) < uint(_loc13_))
               {
                  continue;
               }
            }
            while(_loc13_ = _loc15_ + 4, _loc12_ = wdnative_nternal.L__2E_str38653, if(uint(wdnative_nternal.L__2E_str38653) <= uint(_loc13_))
            {
               _loc12_ = _loc13_;
            }, _loc4_ = _loc12_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str38653 + _loc4_, if((uint(_loc13_)) <= 4294967265)
            {
               _loc13_ = -31;
            }, _loc13_ ^= -1, _loc14_ += 1, _loc14_ != 31);
            §§goto(addr8f6e);
         }
         while(true)
         {
            _loc14_ = li32(_loc13_);
            _loc4_ = _loc14_ + -16843009;
            _loc16_ = _loc14_ & -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc14_ & 0xFF;
               if(_loc4_ == 0)
               {
                  _loc13_ -= wdnative_nternal.L__2E_str38653;
                  break;
               }
               _loc4_ = li8(_loc13_ + 1);
               if(_loc4_ == 0)
               {
                  var _temp_1190:* = int(1 - wdnative_nternal.L__2E_str38653);
                  _loc13_ += _temp_1190;
                  break;
               }
               _loc4_ = li8(_loc13_ + 2);
               if(_loc4_ == 0)
               {
                  var _temp_1192:* = int(2 - wdnative_nternal.L__2E_str38653);
                  _loc13_ += _temp_1192;
                  break;
               }
               _loc4_ = li8(_loc13_ + 3);
               if(_loc4_ == 0)
               {
                  var _temp_1194:* = int(3 - wdnative_nternal.L__2E_str38653);
                  _loc13_ += _temp_1194;
                  break;
               }
            }
            _loc13_ += 4;
         }
         addr8f6e:
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str38653,_loc3_ + 4);
         si32(2,_loc3_);
         _loc15_ = _loc17_ + 4;
         _loc14_ = 0;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop199:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1136:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_1136 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop199;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1143:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1143;
                     break loop199;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1145:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1145;
                     break loop199;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1147:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1147;
                     break loop199;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop200:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               var _temp_1153:* = _loc13_ & 1;
               _loc13_ = _loc14_;
               if(_temp_1153 == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc13_ = li32(_loc15_);
               _loc4_ = _loc13_ + -16843009;
               _loc16_ = _loc13_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc13_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc13_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop200;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1160:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1160;
                     break loop200;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1162:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1162;
                     break loop200;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1164:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc13_ = _loc15_ + _temp_1164;
                     break loop200;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc13_,_loc3_ + 8);
         si32(2,_loc3_);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         _loc15_ = _loc17_ + 4;
         _loc13_ = 1;
         if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc15_))
         {
            _loc13_ = _loc14_;
         }
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         _loc16_ = li32(_loc17_);
         _loc4_ = _loc16_ + -16843009;
         loop201:
         while(true)
         {
            _loc16_ &= -2139062144;
            _loc16_ = _loc16_ ^ -2139062144;
            _loc4_ = _loc16_ & _loc4_;
            if(_loc4_ != 0)
            {
               _loc4_ = _loc13_ & 1;
               if(_loc4_ == 0)
               {
                  break;
               }
            }
            while(true)
            {
               _loc17_ = li32(_loc15_);
               _loc4_ = _loc17_ + -16843009;
               _loc16_ = _loc17_ & -2139062144;
               _loc16_ = _loc16_ ^ -2139062144;
               _loc4_ = _loc16_ & _loc4_;
               if(_loc4_ != 0)
               {
                  _loc4_ = _loc17_ & 0xFF;
                  if(_loc4_ == 0)
                  {
                     _loc14_ = _loc15_ - wdnative_nternal.L__2E_str2617;
                     break loop201;
                  }
                  _loc4_ = li8(_loc15_ + 1);
                  if(_loc4_ == 0)
                  {
                     var _temp_1177:* = int(1 - wdnative_nternal.L__2E_str2617);
                     _loc14_ = _loc15_ + _temp_1177;
                     break loop201;
                  }
                  _loc4_ = li8(_loc15_ + 2);
                  if(_loc4_ == 0)
                  {
                     var _temp_1179:* = int(2 - wdnative_nternal.L__2E_str2617);
                     _loc14_ = _loc15_ + _temp_1179;
                     break loop201;
                  }
                  _loc4_ = li8(_loc15_ + 3);
                  if(_loc4_ == 0)
                  {
                     var _temp_1181:* = int(3 - wdnative_nternal.L__2E_str2617);
                     _loc14_ = _loc15_ + _temp_1181;
                     break loop201;
                  }
               }
               _loc15_ += 4;
            }
            break;
         }
         _loc3_ -= 16;
         si32(_loc14_,_loc3_ + 8);
         si32(wdnative_nternal.L__2E_str2617,_loc3_ + 4);
         si32(2,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___sys_write();
         _loc3_ += 16;
         §§goto(addr9366);
      }
      addr9366:
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

