package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F_malloc_init() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc23_:int = 0;
      var _loc6_:int = 0;
      var _loc18_:int = 0;
      var _loc19_:int = 0;
      var _loc16_:int = 0;
      var _loc10_:int = 0;
      var _loc12_:int = 0;
      var _loc5_:int = 0;
      var _loc14_:int = 0;
      var _loc20_:int = 0;
      var _loc24_:int = 0;
      var _loc9_:int = 0;
      var _loc22_:int = 0;
      var _loc15_:int = 0;
      var _loc11_:int = 0;
      var _loc17_:int = 0;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      _loc1_ -= 1184;
      _loc9_ = 0;
      var _loc25_:int = li8(wdnative_nternal._malloc_initialized_2E_b);
      if(_loc25_ == 0)
      {
         si32(6,_loc2_ - 1156);
         _loc24_ = 3;
         si32(_loc24_,_loc2_ - 1152);
         si32(4,_loc2_ - 1160);
         _loc1_ -= 32;
         si32(0,_loc1_ + 16);
         _loc25_ = _loc2_ - 1160;
         si32(_loc25_,_loc1_ + 12);
         si32(wdnative_nternal._ncpus,_loc1_ + 8);
         si32(2,_loc1_ + 4);
         _loc25_ = _loc2_ - 1156;
         si32(_loc25_,_loc1_);
         wdnative.ESP = _loc1_;
         wdnative_nternal.F_sysctl();
         _loc1_ += 32;
         _loc25_ = wdnative.eax;
         if(_loc25_ == -1)
         {
            si32(1,wdnative_nternal._ncpus);
         }
         while(true)
         {
            _loc23_ = li32(wdnative_nternal._nops_2E_1547);
            if(_loc23_ == 0)
            {
               si32(8,_loc2_ - 120);
               si32(0,_loc2_ - 8);
               si32(3,_loc2_ - 4);
               si32(104,_loc2_ - 116);
               _loc1_ -= 32;
               si32(wdnative_nternal.L__2E_str990,_loc1_ + 16);
               _loc25_ = _loc2_ - 116;
               si32(_loc25_,_loc1_ + 12);
               _loc22_ = _loc2_ - 112;
               si32(_loc22_,_loc1_ + 8);
               si32(2,_loc1_ + 4);
               _loc25_ = _loc2_ - 8;
               si32(_loc25_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F_sysctl();
               _loc1_ += 32;
               _loc23_ = wdnative.eax;
               if(_loc23_ >= 0)
               {
                  _loc25_ = li32(_loc2_ - 116);
                  var _loc21_:int = _loc25_ >>> 2;
                  si32(_loc21_,_loc2_ - 116);
                  _loc1_ -= 32;
                  si32(0,_loc1_ + 16);
                  _loc25_ = _loc2_ - 120;
                  si32(_loc25_,_loc1_ + 12);
                  si32(wdnative_nternal._ps_2E_1546,_loc1_ + 8);
                  si32(_loc21_,_loc1_ + 4);
                  si32(_loc22_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_sysctl();
                  _loc1_ += 32;
                  _loc23_ = wdnative.eax;
               }
               if(_loc23_ == -1)
               {
                  break;
               }
               _loc25_ = li32(_loc2_ - 120);
               _loc22_ = _loc25_ >>> 2;
               while(true)
               {
                  _loc23_ = _loc22_;
                  if(_loc23_ < 1)
                  {
                     break;
                  }
                  var _temp_19:* = _loc23_ << 2;
                  _loc25_ = wdnative_nternal._ps_2E_1546 + _temp_19;
                  var _temp_21:* = li32(_loc25_ - 4);
                  _loc22_ = _loc23_ + -1;
                  if(_temp_21 != 0)
                  {
                     break;
                  }
               }
               si32(_loc23_,wdnative_nternal._nops_2E_1547);
            }
            _loc22_ = _loc23_;
            if(_loc23_ >= 2)
            {
               _loc22_ = 2;
            }
            if(_loc22_ >= 1)
            {
               _loc1_ -= 16;
               si32(wdnative_nternal._ps_2E_1546,_loc1_ + 4);
               _loc22_ = _loc2_ - 1168;
               si32(_loc22_,_loc1_);
               _loc25_ = _loc23_ << 2;
               var _temp_24:* = _loc25_ ^ -4;
               _loc9_ = -4 - _temp_24;
               if(_loc23_ >= 2)
               {
                  _loc9_ = 8;
               }
               si32(_loc9_,_loc1_ + 8);
               _loc23_ ^= -1;
               if(_loc23_ <= -3)
               {
                  _loc23_ = -3;
               }
               _loc23_ ^= -1;
               wdnative.ESP = _loc1_;
               wdnative.Fmemcpy();
               _loc1_ += 16;
               _loc9_ = li32(wdnative_nternal._opt_chunk_2pow);
               do
               {
                  _loc20_ = li32(_loc22_);
                  if((uint(_loc20_)) <= 4194304)
                  {
                     _loc25_ = 1 << _loc9_;
                     if((uint(_loc25_)) < uint(_loc20_))
                     {
                        do
                        {
                           _loc9_ += 1;
                        }
                        while(_loc25_ = 1 << _loc9_, (uint(_loc25_)) < uint(_loc20_));
                     }
                  }
                  _loc22_ += 4;
               }
               while(_loc23_ += -1, _loc23_ != 0);
               si32(_loc9_,wdnative_nternal._opt_chunk_2pow);
            }
            break;
         }
         _loc9_ = _loc2_ - 1170;
         _loc19_ = 3 - _loc9_;
         _loc18_ = 2 - _loc9_;
         _loc6_ = 1 - _loc9_;
         _loc22_ = _loc9_ & -4;
         _loc23_ = _loc22_ + 4;
         _loc20_ = wdnative_nternal.L__2E_str43658 & -4;
         _loc14_ = wdnative_nternal.L__2E_str44659 & -4;
         _loc15_ = 0;
         do
         {
            if(_loc15_ != 2)
            {
               _loc16_ = 1;
               if(_loc15_ != 1)
               {
                  if(_loc15_ == 0)
                  {
                     si8(0,_loc2_ - 1145);
                     _loc17_ = _loc2_ - 1145;
                  }
               }
               else
               {
                  for(; (_loc17_ = li8((_loc25_ = wdnative_nternal.L__2E_str42657 + _loc16_) - 1)) != 61; _loc16_ += 1)
                  {
                     if(_loc17_ != 0)
                     {
                        continue;
                     }
                     if(_loc16_ == 1)
                     {
                        break;
                     }
                     loop34:
                     while(true)
                     {
                        _loc10_ = li32(wdnative_nternal._environ);
                        if(_loc10_ != 0)
                        {
                           _loc17_ = li32(_loc10_);
                           if(_loc17_ != 0)
                           {
                              if(_loc16_ == 1)
                              {
                                 _loc10_ += 4;
                                 while(true)
                                 {
                                    if(_loc17_ != 0)
                                    {
                                       _loc25_ = _loc17_ + _loc16_;
                                       _loc25_ = li8(_loc25_ - 1);
                                       if(_loc25_ != 61)
                                       {
                                          continue;
                                       }
                                       addr04a8:
                                       _loc17_ += _loc16_;
                                       if(_loc17_ != 0)
                                       {
                                          break loop34;
                                       }
                                    }
                                    var _temp_37:* = int(_loc10_ + 4);
                                    _loc17_ = li32(_loc10_);
                                    _loc10_ += 4;
                                 }
                                 break;
                              }
                              _loc10_ += 4;
                              loop5:
                              while(true)
                              {
                                 _loc11_ = 0;
                                 if(_loc17_ != 0)
                                 {
                                    while(true)
                                    {
                                       _loc25_ = _loc17_ - _loc11_;
                                       _loc12_ = li8(_loc25_);
                                       _loc25_ = wdnative_nternal.L__2E_str42657 - _loc11_;
                                       _loc25_ = li8(_loc25_);
                                       if(_loc12_ == _loc25_)
                                       {
                                          if(_loc12_ == 0)
                                          {
                                             break;
                                          }
                                          var _temp_44:* = int(_loc16_ + _loc11_);
                                          _loc11_ += -1;
                                          if(_temp_44 == 2)
                                          {
                                             break;
                                          }
                                          continue;
                                       }
                                       continue loop5;
                                    }
                                    _loc25_ = _loc17_ + _loc16_;
                                    _loc25_ = li8(_loc25_ - 1);
                                    if(_loc25_ != 61)
                                    {
                                       continue;
                                    }
                                    §§goto(addr04a8);
                                 }
                                 _loc25_ = _loc10_ + 4;
                                 _loc17_ = li32(_loc10_);
                                 _loc10_ = _loc25_;
                              }
                              break;
                           }
                        }
                        addr04b8:
                        si8(0,_loc2_ - 1145);
                        _loc17_ = _loc2_ - 1145;
                        break;
                     }
                  }
                  si32(22,wdnative_nternal._errno);
                  §§goto(addr04b8);
               }
            }
            else
            {
               si8(0,_loc2_ - 1145);
               _loc17_ = _loc2_ - 1145;
            }
            _loc12_ = li8(_loc17_);
            _loc11_ = 0;
            if(_loc12_ != 0)
            {
               do
               {
                  _loc10_ = _loc17_ + _loc11_;
                  _loc25_ = _loc12_ << 24;
                  _loc8_ = _loc25_ >> 24;
                  _loc25_ = _loc8_ + -48;
                  _loc16_ = 1;
                  _loc13_ = 0;
                  if(uint(_loc25_) < 10)
                  {
                     do
                     {
                        _loc25_ = _loc13_ * 10;
                        _loc25_ = _loc8_ + _loc25_;
                        _loc13_ = _loc25_ + -48;
                        _loc25_ = _loc17_ + _loc11_;
                        _loc8_ = si8(li8(_loc25_ + 1));
                        _loc25_ = _loc8_ + -48;
                        _loc11_ += 1;
                     }
                     while(uint(_loc25_) < 10);
                     _loc10_ = _loc17_ + _loc11_;
                     _loc16_ = _loc13_;
                     _loc12_ = _loc8_;
                     if(_loc13_ == 0)
                     {
                        continue;
                     }
                  }
                  loop10:
                  while(true)
                  {
                     _loc25_ = _loc12_ << 24;
                     _loc8_ = _loc25_ >> 24;
                     if(_loc8_ <= 96)
                     {
                        if(_loc8_ <= 76)
                        {
                           if(_loc8_ <= 67)
                           {
                              if(_loc8_ != 65)
                              {
                                 if(_loc8_ != 66)
                                 {
                                    if(_loc8_ != 67)
                                    {
                                       addr0933:
                                       si8(_loc12_,_loc2_ - 1170);
                                       si8(0,_loc2_ - 1169);
                                       _loc12_ = li32(wdnative_nternal.___progname);
                                       _loc13_ = _loc12_ & -4;
                                       _loc21_ = li32(_loc13_);
                                       _loc25_ = _loc21_ + -16843009;
                                       _loc21_ &= -2139062144;
                                       _loc21_ = _loc21_ ^ -2139062144;
                                       _loc25_ = _loc21_ & _loc25_;
                                       if(_loc25_ != 0)
                                       {
                                          _loc8_ = _loc13_ + 4;
                                          _loc7_ = 0;
                                          while(true)
                                          {
                                             _loc5_ = _loc12_ + _loc7_;
                                             if((uint(_loc5_)) < uint(_loc8_))
                                             {
                                                _loc25_ = li8(_loc5_);
                                                if(_loc25_ == 0)
                                                {
                                                   break;
                                                }
                                                _loc7_ += 1;
                                                continue;
                                             }
                                          }
                                          addr0a7a:
                                          _loc1_ -= 16;
                                          si32(_loc7_,_loc1_ + 8);
                                          si32(_loc12_,_loc1_ + 4);
                                          si32(2,_loc1_);
                                          wdnative.ESP = _loc1_;
                                          wdnative_nternal.F___sys_write();
                                          _loc1_ += 16;
                                          _loc21_ = li32(_loc20_);
                                          _loc25_ = _loc21_ + -16843009;
                                          _loc21_ &= -2139062144;
                                          _loc21_ = _loc21_ ^ -2139062144;
                                          _loc25_ = _loc21_ & _loc25_;
                                          _loc8_ = _loc20_ + 4;
                                          _loc12_ = 0;
                                          if(_loc25_ != 0)
                                          {
                                             do
                                             {
                                                _loc25_ = wdnative_nternal.L__2E_str43658 + _loc12_;
                                                _loc8_ = _loc20_ + 4;
                                                if(uint(_loc25_) < uint(_loc8_))
                                                {
                                                   continue;
                                                }
                                             }
                                             while(_loc8_ = _loc20_ + 4, _loc13_ = wdnative_nternal.L__2E_str43658, if(uint(wdnative_nternal.L__2E_str43658) <= uint(_loc8_))
                                             {
                                                _loc13_ = _loc8_;
                                             }, _loc25_ = _loc13_ ^ -1, _loc8_ = wdnative_nternal.L__2E_str43658 + _loc25_, if((uint(_loc8_)) <= 4294967242)
                                             {
                                                _loc8_ = -54;
                                             }, _loc8_ ^= -1, _loc12_ += 1, _loc12_ != 54);
                                             addr0c0e:
                                             _loc1_ -= 16;
                                             si32(_loc8_,_loc1_ + 8);
                                             si32(wdnative_nternal.L__2E_str43658,_loc1_ + 4);
                                             si32(2,_loc1_);
                                             wdnative.ESP = _loc1_;
                                             wdnative_nternal.F___sys_write();
                                             _loc1_ += 16;
                                             _loc21_ = li32(_loc22_);
                                             _loc25_ = _loc21_ + -16843009;
                                             _loc21_ &= -2139062144;
                                             _loc21_ = _loc21_ ^ -2139062144;
                                             _loc25_ = _loc21_ & _loc25_;
                                             _loc13_ = 0;
                                             _loc12_ = _loc23_;
                                             if(_loc25_ != 0)
                                             {
                                                while(true)
                                                {
                                                   _loc8_ = _loc9_ + _loc13_;
                                                   _loc12_ = _loc23_;
                                                   if(uint(_loc8_) < uint(_loc23_))
                                                   {
                                                      _loc25_ = li8(_loc8_);
                                                      if(_loc25_ == 0)
                                                      {
                                                         break;
                                                      }
                                                      _loc13_ += 1;
                                                      continue;
                                                   }
                                                }
                                                addr0d4b:
                                                _loc1_ -= 16;
                                                si32(_loc13_,_loc1_ + 8);
                                                si32(_loc9_,_loc1_ + 4);
                                                si32(2,_loc1_);
                                                wdnative.ESP = _loc1_;
                                                wdnative_nternal.F___sys_write();
                                                _loc1_ += 16;
                                                _loc21_ = li32(_loc14_);
                                                _loc25_ = _loc21_ + -16843009;
                                                _loc21_ &= -2139062144;
                                                _loc21_ = _loc21_ ^ -2139062144;
                                                _loc25_ = _loc21_ & _loc25_;
                                                _loc8_ = _loc14_ + 4;
                                                _loc12_ = 0;
                                                if(_loc25_ != 0)
                                                {
                                                   while(true)
                                                   {
                                                      _loc25_ = wdnative_nternal.L__2E_str44659 + _loc12_;
                                                      _loc8_ = _loc14_ + 4;
                                                      if(uint(_loc25_) >= uint(_loc8_))
                                                      {
                                                         break;
                                                      }
                                                      _loc8_ = _loc14_ + 4;
                                                      _loc13_ = wdnative_nternal.L__2E_str44659;
                                                      if(uint(wdnative_nternal.L__2E_str44659) <= uint(_loc8_))
                                                      {
                                                         _loc13_ = _loc8_;
                                                      }
                                                      _loc25_ = _loc13_ ^ -1;
                                                      _loc8_ = wdnative_nternal.L__2E_str44659 + _loc25_;
                                                      if((uint(_loc8_)) <= 4294967293)
                                                      {
                                                         _loc8_ = -3;
                                                      }
                                                      _loc8_ ^= -1;
                                                      _loc12_ += 1;
                                                      if(_loc12_ != 3)
                                                      {
                                                         continue;
                                                      }
                                                      addr0edf:
                                                      addr0f0e:
                                                      _loc1_ -= 16;
                                                      si32(_loc8_,_loc1_ + 8);
                                                      si32(wdnative_nternal.L__2E_str44659,_loc1_ + 4);
                                                      si32(2,_loc1_);
                                                      wdnative.ESP = _loc1_;
                                                      wdnative_nternal.F___sys_write();
                                                      _loc1_ += 16;
                                                      _loc16_ += -1;
                                                      if(_loc16_ == 0)
                                                      {
                                                         break loop10;
                                                      }
                                                      _loc12_ = li8(_loc10_);
                                                      continue loop10;
                                                   }
                                                }
                                                while(true)
                                                {
                                                   _loc12_ = li32(_loc8_);
                                                   _loc25_ = _loc12_ + -16843009;
                                                   _loc21_ = _loc12_ & -2139062144;
                                                   _loc21_ = _loc21_ ^ -2139062144;
                                                   _loc25_ = _loc21_ & _loc25_;
                                                   if(_loc25_ != 0)
                                                   {
                                                      _loc25_ = _loc12_ & 0xFF;
                                                      if(_loc25_ == 0)
                                                      {
                                                         _loc8_ -= wdnative_nternal.L__2E_str44659;
                                                         break;
                                                      }
                                                      _loc25_ = li8(_loc8_ + 1);
                                                      if(_loc25_ == 0)
                                                      {
                                                         var _temp_96:* = int(1 - wdnative_nternal.L__2E_str44659);
                                                         _loc8_ += _temp_96;
                                                         break;
                                                      }
                                                      _loc25_ = li8(_loc8_ + 2);
                                                      if(_loc25_ == 0)
                                                      {
                                                         var _temp_98:* = int(2 - wdnative_nternal.L__2E_str44659);
                                                         _loc8_ += _temp_98;
                                                         break;
                                                      }
                                                      _loc25_ = li8(_loc8_ + 3);
                                                      if(_loc25_ == 0)
                                                      {
                                                         var _temp_100:* = int(3 - wdnative_nternal.L__2E_str44659);
                                                         _loc8_ += _temp_100;
                                                         break;
                                                      }
                                                   }
                                                   _loc8_ += 4;
                                                }
                                                §§goto(addr0edf);
                                             }
                                             while(true)
                                             {
                                                _loc8_ = li32(_loc12_);
                                                _loc25_ = _loc8_ + -16843009;
                                                _loc21_ = _loc8_ & -2139062144;
                                                _loc21_ = _loc21_ ^ -2139062144;
                                                _loc25_ = _loc21_ & _loc25_;
                                                if(_loc25_ != 0)
                                                {
                                                   _loc25_ = _loc8_ & 0xFF;
                                                   if(_loc25_ == 0)
                                                   {
                                                      _loc13_ = _loc12_ - _loc9_;
                                                      break;
                                                   }
                                                   _loc25_ = li8(_loc12_ + 1);
                                                   if(_loc25_ == 0)
                                                   {
                                                      _loc13_ = _loc6_ + _loc12_;
                                                      break;
                                                   }
                                                   _loc25_ = li8(_loc12_ + 2);
                                                   if(_loc25_ == 0)
                                                   {
                                                      _loc13_ = _loc18_ + _loc12_;
                                                      break;
                                                   }
                                                   _loc25_ = li8(_loc12_ + 3);
                                                   if(_loc25_ == 0)
                                                   {
                                                      _loc13_ = _loc19_ + _loc12_;
                                                      break;
                                                   }
                                                }
                                                _loc12_ += 4;
                                             }
                                             §§goto(addr0d4b);
                                          }
                                          while(true)
                                          {
                                             _loc12_ = li32(_loc8_);
                                             _loc25_ = _loc12_ + -16843009;
                                             _loc21_ = _loc12_ & -2139062144;
                                             _loc21_ = _loc21_ ^ -2139062144;
                                             _loc25_ = _loc21_ & _loc25_;
                                             if(_loc25_ != 0)
                                             {
                                                _loc25_ = _loc12_ & 0xFF;
                                                if(_loc25_ == 0)
                                                {
                                                   _loc8_ -= wdnative_nternal.L__2E_str43658;
                                                   break;
                                                }
                                                _loc25_ = li8(_loc8_ + 1);
                                                if(_loc25_ == 0)
                                                {
                                                   var _temp_115:* = int(1 - wdnative_nternal.L__2E_str43658);
                                                   _loc8_ += _temp_115;
                                                   break;
                                                }
                                                _loc25_ = li8(_loc8_ + 2);
                                                if(_loc25_ == 0)
                                                {
                                                   var _temp_117:* = int(2 - wdnative_nternal.L__2E_str43658);
                                                   _loc8_ += _temp_117;
                                                   break;
                                                }
                                                _loc25_ = li8(_loc8_ + 3);
                                                if(_loc25_ == 0)
                                                {
                                                   var _temp_119:* = int(3 - wdnative_nternal.L__2E_str43658);
                                                   _loc8_ += _temp_119;
                                                   break;
                                                }
                                             }
                                             _loc8_ += 4;
                                          }
                                          §§goto(addr0c0e);
                                       }
                                       _loc13_ += 4;
                                       while(true)
                                       {
                                          _loc8_ = li32(_loc13_);
                                          _loc25_ = _loc8_ + -16843009;
                                          _loc21_ = _loc8_ & -2139062144;
                                          _loc21_ = _loc21_ ^ -2139062144;
                                          _loc25_ = _loc21_ & _loc25_;
                                          if(_loc25_ != 0)
                                          {
                                             _loc25_ = _loc8_ & 0xFF;
                                             if(_loc25_ == 0)
                                             {
                                                _loc7_ = _loc13_ - _loc12_;
                                                break;
                                             }
                                             _loc25_ = li8(_loc13_ + 1);
                                             if(_loc25_ == 0)
                                             {
                                                _loc25_ = 1 - _loc12_;
                                                _loc7_ = _loc25_ + _loc13_;
                                                break;
                                             }
                                             _loc25_ = li8(_loc13_ + 2);
                                             if(_loc25_ == 0)
                                             {
                                                _loc25_ = 2 - _loc12_;
                                                _loc7_ = _loc25_ + _loc13_;
                                                break;
                                             }
                                             _loc25_ = li8(_loc13_ + 3);
                                             if(_loc25_ == 0)
                                             {
                                                _loc25_ = 3 - _loc12_;
                                                _loc7_ = _loc25_ + _loc13_;
                                                break;
                                             }
                                          }
                                          _loc13_ += 4;
                                       }
                                       §§goto(addr0a7a);
                                    }
                                    else
                                    {
                                       _loc12_ = li32(wdnative_nternal._opt_cspace_max_2pow);
                                       if((uint(_loc12_)) <= 10)
                                       {
                                          _loc25_ = _loc12_ + 1;
                                          si32(_loc25_,wdnative_nternal._opt_cspace_max_2pow);
                                       }
                                    }
                                 }
                              }
                              else
                              {
                                 si8(1,wdnative_nternal._opt_abort_2E_b);
                              }
                           }
                           else if(_loc8_ <= 73)
                           {
                              if(_loc8_ != 68)
                              {
                                 if(_loc8_ != 70)
                                 {
                                    §§goto(addr0933);
                                 }
                                 else
                                 {
                                    _loc12_ = li32(wdnative_nternal._opt_dirty_max);
                                    if(_loc12_ == 0)
                                    {
                                       si32(1,wdnative_nternal._opt_dirty_max);
                                    }
                                    else
                                    {
                                       _loc25_ = _loc12_ & 0x7FFFFFFF;
                                       if(_loc25_ != 0)
                                       {
                                          _loc25_ = _loc12_ << 1;
                                          si32(_loc25_,wdnative_nternal._opt_dirty_max);
                                       }
                                    }
                                 }
                              }
                              else
                              {
                                 si8(0,wdnative_nternal._opt_dss_2E_b);
                              }
                           }
                           else if(_loc8_ != 74)
                           {
                              if(_loc8_ != 75)
                              {
                                 §§goto(addr0933);
                              }
                              else
                              {
                                 _loc25_ = li32(wdnative_nternal._opt_chunk_2pow);
                                 _loc12_ = _loc25_ + 1;
                                 if((uint(_loc12_)) <= 31)
                                 {
                                    si32(_loc12_,wdnative_nternal._opt_chunk_2pow);
                                 }
                              }
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_junk_2E_b);
                           }
                        }
                        else if(_loc8_ <= 84)
                        {
                           if(_loc8_ <= 79)
                           {
                              if(_loc8_ != 77)
                              {
                                 if(_loc8_ != 78)
                                 {
                                    §§goto(addr0933);
                                 }
                                 else
                                 {
                                    _loc25_ = li32(wdnative_nternal._opt_narenas_lshift);
                                    _loc25_ = _loc25_ + 1;
                                    si32(_loc25_,wdnative_nternal._opt_narenas_lshift);
                                 }
                              }
                              else
                              {
                                 si8(0,wdnative_nternal._opt_mmap_2E_b);
                              }
                           }
                           else if(_loc8_ != 80)
                           {
                              if(_loc8_ != 81)
                              {
                                 §§goto(addr0933);
                              }
                              else
                              {
                                 _loc25_ = li32(wdnative_nternal._opt_qspace_max_2pow);
                                 _loc12_ = _loc25_ + 1;
                                 var _temp_141:* = li32(wdnative_nternal._opt_cspace_max_2pow);
                                 if(uint(_loc12_) < uint(_temp_141))
                                 {
                                    si32(_loc12_,wdnative_nternal._opt_qspace_max_2pow);
                                 }
                              }
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_print_stats_2E_b);
                           }
                        }
                        else if(_loc8_ <= 87)
                        {
                           if(_loc8_ != 85)
                           {
                              if(_loc8_ != 86)
                              {
                                 §§goto(addr0933);
                              }
                              else
                              {
                                 si8(1,wdnative_nternal._opt_sysv_2E_b);
                              }
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_utrace_2E_b);
                           }
                        }
                        else if(_loc8_ != 88)
                        {
                           if(_loc8_ != 90)
                           {
                              §§goto(addr0933);
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_zero_2E_b);
                           }
                        }
                        else
                        {
                           si8(1,wdnative_nternal._opt_xmalloc_2E_b);
                        }
                     }
                     else if(_loc8_ <= 108)
                     {
                        if(_loc8_ <= 99)
                        {
                           if(_loc8_ != 97)
                           {
                              if(_loc8_ != 98)
                              {
                                 if(_loc8_ != 99)
                                 {
                                    §§goto(addr0933);
                                 }
                                 else
                                 {
                                    _loc8_ = li32(wdnative_nternal._opt_cspace_max_2pow);
                                    _loc12_ = _loc8_ + -1;
                                    var _temp_143:* = li32(wdnative_nternal._opt_qspace_max_2pow);
                                    if(uint(_loc12_) > uint(_temp_143))
                                    {
                                       if(uint(_loc8_) >= 7)
                                       {
                                          si32(_loc12_,wdnative_nternal._opt_cspace_max_2pow);
                                       }
                                    }
                                 }
                              }
                           }
                           else
                           {
                              si8(0,wdnative_nternal._opt_abort_2E_b);
                           }
                        }
                        else if(_loc8_ <= 105)
                        {
                           if(_loc8_ != 100)
                           {
                              if(_loc8_ != 102)
                              {
                                 §§goto(addr0933);
                              }
                              else
                              {
                                 _loc25_ = li32(wdnative_nternal._opt_dirty_max);
                                 _loc25_ = _loc25_ >>> 1;
                                 si32(_loc25_,wdnative_nternal._opt_dirty_max);
                              }
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_dss_2E_b);
                           }
                        }
                        else if(_loc8_ != 106)
                        {
                           if(_loc8_ != 107)
                           {
                              §§goto(addr0933);
                           }
                           else
                           {
                              _loc12_ = li32(wdnative_nternal._opt_chunk_2pow);
                              if((uint(_loc12_)) >= 14)
                              {
                                 _loc25_ = _loc12_ + -1;
                                 si32(_loc25_,wdnative_nternal._opt_chunk_2pow);
                              }
                           }
                        }
                        else
                        {
                           si8(0,wdnative_nternal._opt_junk_2E_b);
                        }
                     }
                     else if(_loc8_ <= 116)
                     {
                        if(_loc8_ <= 111)
                        {
                           if(_loc8_ != 109)
                           {
                              if(_loc8_ != 110)
                              {
                                 §§goto(addr0933);
                              }
                              else
                              {
                                 _loc25_ = li32(wdnative_nternal._opt_narenas_lshift);
                                 _loc25_ = _loc25_ + -1;
                                 si32(_loc25_,wdnative_nternal._opt_narenas_lshift);
                              }
                           }
                           else
                           {
                              si8(1,wdnative_nternal._opt_mmap_2E_b);
                           }
                        }
                        else if(_loc8_ != 112)
                        {
                           if(_loc8_ != 113)
                           {
                              §§goto(addr0933);
                           }
                           else
                           {
                              _loc12_ = li32(wdnative_nternal._opt_qspace_max_2pow);
                              if((uint(_loc12_)) >= 5)
                              {
                                 _loc25_ = _loc12_ + -1;
                                 si32(_loc25_,wdnative_nternal._opt_qspace_max_2pow);
                              }
                           }
                        }
                        else
                        {
                           si8(0,wdnative_nternal._opt_print_stats_2E_b);
                        }
                     }
                     else if(_loc8_ <= 119)
                     {
                        if(_loc8_ != 117)
                        {
                           if(_loc8_ != 118)
                           {
                              §§goto(addr0933);
                           }
                           else
                           {
                              si8(0,wdnative_nternal._opt_sysv_2E_b);
                           }
                        }
                        else
                        {
                           si8(0,wdnative_nternal._opt_utrace_2E_b);
                        }
                     }
                     else if(_loc8_ != 120)
                     {
                        if(_loc8_ != 122)
                        {
                           §§goto(addr0933);
                        }
                        else
                        {
                           si8(0,wdnative_nternal._opt_zero_2E_b);
                        }
                     }
                     else
                     {
                        si8(0,wdnative_nternal._opt_xmalloc_2E_b);
                     }
                     §§goto(addr0f0e);
                  }
               }
               while(_loc11_ += 1, _loc25_ = _loc17_ + _loc11_, _loc12_ = li8(_loc25_), _loc12_ != 0);
            }
         }
         while(_loc15_ += 1, _loc15_ != 3);
         _loc25_ = li8(wdnative_nternal._opt_dss_2E_b);
         if(_loc25_ == 1)
         {
            _loc25_ = li8(wdnative_nternal._opt_mmap_2E_b);
            if(_loc25_ == 1)
            {
               si8(0,wdnative_nternal._opt_mmap_2E_b);
            }
         }
         _loc25_ = li8(wdnative_nternal._opt_print_stats_2E_b);
         if(_loc25_ == 1)
         {
            _loc1_ -= 16;
            si32(wdnative_nternal._malloc_print_stats,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative_nternal.F_atexit();
            _loc1_ += 16;
         }
         _loc9_ = li32(wdnative_nternal._opt_qspace_max_2pow);
         _loc22_ = 1;
         _loc23_ = _loc22_ << _loc9_;
         si32(_loc23_,wdnative_nternal._qspace_max);
         _loc25_ = _loc23_ + 63;
         _loc6_ = _loc25_ & -64;
         _loc20_ = _loc6_ + 64;
         if(_loc6_ != _loc23_)
         {
            _loc20_ = _loc6_;
         }
         si32(_loc20_,wdnative_nternal._cspace_min);
         _loc6_ = li32(wdnative_nternal._opt_cspace_max_2pow);
         _loc14_ = _loc22_ << _loc6_;
         si32(_loc14_,wdnative_nternal._cspace_max);
         _loc25_ = _loc14_ + 255;
         _loc19_ = _loc25_ & -256;
         _loc18_ = _loc19_ + 256;
         if(_loc19_ != _loc14_)
         {
            _loc18_ = _loc19_;
         }
         si32(_loc18_,wdnative_nternal._sspace_min);
         si8(_loc22_,wdnative_nternal._sspace_max_2E_b);
         _loc25_ = _loc14_ - _loc20_;
         var _loc3_:int = _loc25_ >>> 6;
         _loc25_ = _loc3_ + 1;
         _loc21_ = _loc23_ >>> 4;
         si32(_loc21_,wdnative_nternal._nqbins);
         si32(_loc25_,wdnative_nternal._ncbins);
         _loc25_ = _loc21_ + _loc3_;
         _loc21_ = 3840 - _loc18_;
         _loc21_ = _loc21_ >>> 8;
         _loc25_ += _loc21_;
         _loc25_ = _loc25_ + 5;
         si32(_loc25_,wdnative_nternal._nbins);
         loop35:
         while(true)
         {
            if(_loc9_ == 7)
            {
               _loc23_ = wdnative_nternal._const_size2bin;
               if(_loc6_ == 9)
               {
                  break;
               }
            }
            _loc23_ = li32(wdnative_nternal._base_next_addr);
            _loc25_ = _loc23_ + 3904;
            _loc21_ = li32(wdnative_nternal._base_past_addr);
            while(true)
            {
               if(uint(_loc25_) > uint(_loc21_))
               {
                  _loc1_ -= 16;
                  si32(3904,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_base_pages_alloc();
                  _loc9_ = 1;
                  _loc1_ += 16;
                  _loc25_ = wdnative.eax;
                  if(_loc25_ != 0)
                  {
                     break;
                  }
                  _loc23_ = li32(wdnative_nternal._base_next_addr);
               }
               _loc25_ = _loc23_ + 3904;
               si32(_loc25_,wdnative_nternal._base_next_addr);
               _loc9_ = 1;
               if(_loc23_ != 0)
               {
                  si8(-1,_loc23_);
                  si8(0,_loc23_ + 1);
                  _loc9_ = _loc23_ + 1;
                  _loc20_ = 0;
                  do
                  {
                     _loc19_ = _loc20_ + 1;
                     _loc25_ = _loc19_ >>> 1;
                     _loc25_ = _loc25_ | _loc19_;
                     _loc21_ = _loc25_ >>> 2;
                     _loc25_ = _loc21_ | _loc25_;
                     _loc21_ = _loc25_ >>> 4;
                     _loc25_ = _loc21_ | _loc25_;
                     _loc21_ = _loc25_ >>> 8;
                     _loc25_ = _loc21_ | _loc25_;
                     _loc21_ = _loc25_ >>> 16;
                     _loc25_ = _loc21_ | _loc25_;
                     _loc25_ = _loc25_ + 1;
                     _loc18_ = _loc25_ >>> 2;
                     _loc6_ = 0;
                     if(_loc18_ != 0)
                     {
                        var _temp_184:* = int(_loc18_ + -1);
                        _loc25_ = (_loc21_ = _loc18_ ^ -1) & _temp_184;
                        _loc21_ = _loc25_ >>> 1;
                        var _temp_187:* = _loc21_ & 0x55555555;
                        _loc21_ = _loc25_ - _temp_187;
                        _loc25_ = (_loc21_ & 0x33333333) + ((_loc21_ >>>= 2) & 0x33333333);
                        var _temp_191:* = _loc25_ >>> 4;
                        _loc25_ += _temp_191;
                        _loc25_ = _loc25_ & 0x0F0F0F0F;
                        _loc25_ = _loc25_ * 16843009;
                        _loc25_ = _loc25_ >>> 24;
                        _loc6_ = _loc25_ + 1;
                     }
                     _loc25_ = _loc9_ + _loc20_;
                     si8(_loc6_,_loc25_ + 1);
                     _loc20_ = _loc19_;
                  }
                  while(_loc19_ != 14);
                  _loc20_ = 31;
                  _loc9_ = 16;
                  _loc25_ = li32(wdnative_nternal._qspace_max);
                  if((uint(_loc25_)) >= 16)
                  {
                     do
                     {
                        _loc25_ = _loc23_ + _loc9_;
                        _loc21_ = _loc20_ >>> 4;
                        _loc21_ = _loc21_ + 2;
                        si8(_loc21_,_loc25_);
                        _loc20_ += 1;
                        _loc9_ += 1;
                        _loc25_ = li32(wdnative_nternal._qspace_max);
                     }
                     while(uint(_loc9_) <= uint(_loc25_));
                  }
                  _loc25_ = li32(wdnative_nternal._cspace_max);
                  if(uint(_loc9_) <= uint(_loc25_))
                  {
                     do
                     {
                        _loc25_ = _loc23_ + _loc9_;
                        _loc21_ = _loc9_ + 63;
                        _loc3_ = _loc21_ & 0x3FC0;
                        _loc21_ = li32(wdnative_nternal._cspace_min);
                        _loc21_ = _loc3_ - _loc21_;
                        _loc3_ = _loc21_ >>> 6;
                        _loc21_ = li32(wdnative_nternal._nqbins);
                        _loc21_ = _loc21_ + _loc3_;
                        _loc21_ = _loc21_ + 3;
                        si8(_loc21_,_loc25_);
                        _loc9_ += 1;
                        _loc25_ = li32(wdnative_nternal._cspace_max);
                     }
                     while(uint(_loc9_) <= uint(_loc25_));
                  }
                  _loc20_ = 3840;
                  _loc25_ = li8(wdnative_nternal._sspace_max_2E_b);
                  if(_loc25_ == 0)
                  {
                     _loc20_ = 0;
                  }
                  if(uint(_loc9_) <= uint(_loc20_))
                  {
                     while(true)
                     {
                        _loc21_ = li32(wdnative_nternal._ncbins);
                        _loc25_ = li32(wdnative_nternal._nqbins);
                        _loc25_ = _loc25_ + _loc21_;
                        _loc21_ = _loc9_ + 255;
                        _loc3_ = _loc21_ & 0xFF00;
                        _loc21_ = li32(wdnative_nternal._sspace_min);
                        _loc21_ = _loc3_ - _loc21_;
                        _loc21_ = _loc21_ >>> 8;
                        _loc25_ += _loc21_;
                        _loc21_ = _loc25_ + 3;
                        _loc25_ = _loc23_ + _loc9_;
                        si8(_loc21_,_loc25_);
                        _loc20_ = 3840;
                        _loc25_ = li8(wdnative_nternal._sspace_max_2E_b);
                        if(_loc25_ == 0)
                        {
                           _loc20_ = 0;
                        }
                        _loc9_ += 1;
                        if((uint(_loc9_)) > uint(_loc20_))
                        {
                           break loop35;
                        }
                     }
                  }
                  break loop35;
               }
               break;
            }
         }
         si32(_loc23_,wdnative_nternal._size2bin);
         _loc25_ = li32(wdnative_nternal._opt_chunk_2pow);
         _loc23_ = _loc22_ << _loc25_;
         si32(_loc23_,wdnative_nternal._chunksize);
         _loc25_ = _loc23_ + -1;
         si32(_loc25_,wdnative_nternal._chunksize_mask);
         _loc25_ = _loc23_ >>> 12;
         si32(_loc25_,wdnative_nternal._chunk_npages);
         _loc25_ *= 12;
         _loc9_ = _loc25_ + 16;
         _loc25_ = _loc9_ & 0x0FFC;
         if(_loc25_ == 0)
         {
            _loc22_ = 0;
         }
         _loc21_ = _loc9_ >>> 12;
         _loc25_ = _loc22_ & 1;
         _loc25_ = _loc25_ + _loc21_;
         si32(_loc25_,wdnative_nternal._arena_chunk_header_npages);
         _loc25_ <<= 12;
         _loc25_ = _loc23_ - _loc25_;
         si32(_loc25_,wdnative_nternal._arena_maxclass);
         si32(0,wdnative_nternal._huge_mtx);
         si32(0,wdnative_nternal._huge_mtx + 4);
         si32(0,wdnative_nternal._huge_mtx + 8);
         si32(0,wdnative_nternal._huge_mtx + 12);
         _loc25_ = wdnative_nternal._huge + 4;
         si32(_loc25_,wdnative_nternal._huge);
         si32(_loc25_,wdnative_nternal._huge + 12);
         _loc25_ &= -2;
         si32(_loc25_,wdnative_nternal._huge + 16);
         si32(0,wdnative_nternal._dss_mtx);
         si32(0,wdnative_nternal._dss_mtx + 4);
         si32(0,wdnative_nternal._dss_mtx + 8);
         si32(0,wdnative_nternal._dss_mtx + 12);
         _loc22_ = int(ramGetLength());
         if(_loc22_ == -1)
         {
            _loc1_ -= 16;
            si32(_loc22_,_loc1_ + 8);
            si32(wdnative_nternal.L__2E_str1240,_loc1_ + 4);
            si32(wdnative_nternal.L__2E_str239,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative_nternal.F_tprintf();
            _loc1_ += 16;
            si32(12,wdnative_nternal._errno);
         }
         si32(_loc22_,wdnative_nternal._dss_base);
         si32(_loc22_,wdnative_nternal._dss_prev);
         si32(_loc22_,wdnative_nternal._dss_max);
         _loc25_ = wdnative_nternal._dss_chunks_szad + 4;
         si32(_loc25_,wdnative_nternal._dss_chunks_szad);
         si32(_loc25_,wdnative_nternal._dss_chunks_szad + 4);
         _loc25_ &= -2;
         si32(_loc25_,wdnative_nternal._dss_chunks_szad + 8);
         _loc25_ = wdnative_nternal._dss_chunks_ad + 4;
         si32(_loc25_,wdnative_nternal._dss_chunks_ad);
         si32(_loc25_,wdnative_nternal._dss_chunks_ad + 12);
         _loc25_ &= -2;
         si32(_loc25_,wdnative_nternal._dss_chunks_ad + 16);
         _loc25_ = li8(wdnative_nternal._opt_dss_2E_b);
         if(_loc25_ == 0)
         {
            _loc1_ -= 16;
            si32(0,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative_nternal.F_base_pages_alloc();
            _loc1_ += 16;
         }
         si32(0,wdnative_nternal._base_nodes);
         si32(0,wdnative_nternal._base_mtx);
         si32(0,wdnative_nternal._base_mtx + 4);
         si32(0,wdnative_nternal._base_mtx + 8);
         si32(0,wdnative_nternal._base_mtx + 12);
         _loc23_ = li32(wdnative_nternal._opt_narenas_lshift);
         _loc22_ = li32(wdnative_nternal._ncpus);
         if((uint(_loc22_)) >= 2)
         {
            _loc23_ += 1;
            si32(_loc23_,wdnative_nternal._opt_narenas_lshift);
         }
         si32(_loc22_,wdnative_nternal._narenas);
         while(true)
         {
            if(_loc23_ >= 1)
            {
               _loc23_ = _loc22_ << _loc23_;
               if((uint(_loc23_)) > uint(_loc22_))
               {
                  si32(_loc23_,wdnative_nternal._narenas);
                  _loc22_ = _loc23_;
               }
               _loc25_ = _loc22_ << 2;
               _loc23_ = li32(wdnative_nternal._chunksize);
               if(uint(_loc25_) > uint(_loc23_))
               {
                  _loc22_ = _loc23_ >>> 2;
                  si32(_loc22_,wdnative_nternal._narenas);
               }
            }
            else if(_loc23_ <= -1)
            {
               var _temp_234:* = int(0 - _loc23_);
               _loc23_ = _loc22_ >>> _temp_234;
               if((uint(_loc23_)) < uint(_loc22_))
               {
                  si32(_loc23_,wdnative_nternal._narenas);
                  _loc22_ = _loc23_;
               }
               if(_loc22_ == 0)
               {
                  _loc22_ = 1;
                  si32(_loc22_,wdnative_nternal._narenas);
                  break;
               }
            }
            _loc9_ = 1;
            if(uint(_loc22_) <= 1)
            {
               break;
            }
            while(true)
            {
               _loc23_ = 263;
               if(uint(_loc9_) >= 56)
               {
                  break;
               }
               var _temp_239:* = _loc9_ << 2;
               _loc25_ = wdnative_nternal._primes_2E_11863 + _temp_239;
               _loc23_ = li32(_loc25_);
               if((uint(_loc23_)) > uint(_loc22_))
               {
                  break;
               }
               _loc9_ += 1;
            }
            si32(_loc23_,wdnative_nternal._narenas);
            _loc22_ = _loc23_;
            break;
         }
         _loc25_ = _loc22_ << 2;
         _loc25_ = _loc25_ + 63;
         _loc23_ = _loc25_ & -64;
         _loc22_ = li32(wdnative_nternal._base_next_addr);
         _loc21_ = _loc23_ + _loc22_;
         _loc25_ = li32(wdnative_nternal._base_past_addr);
         loop38:
         while(true)
         {
            if(uint(_loc21_) > uint(_loc25_))
            {
               _loc1_ -= 16;
               si32(_loc23_,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F_base_pages_alloc();
               _loc1_ += 16;
               _loc25_ = wdnative.eax;
               if(_loc25_ != 0)
               {
                  si32(0,wdnative_nternal._arenas);
                  _loc9_ = 1;
                  break;
               }
               _loc22_ = li32(wdnative_nternal._base_next_addr);
            }
            _loc25_ = _loc22_ + _loc23_;
            si32(_loc25_,wdnative_nternal._base_next_addr);
            si32(_loc22_,wdnative_nternal._arenas);
            _loc9_ = 1;
            if(_loc22_ == 0)
            {
               break;
            }
            var _temp_247:* = li32(wdnative_nternal._narenas);
            _loc1_ -= 16;
            _loc25_ = _temp_247 << 2;
            si32(_loc25_,_loc1_ + 8);
            si32(0,_loc1_ + 4);
            si32(_loc22_,_loc1_);
            wdnative.ESP = _loc1_;
            wdnative.Fmemset();
            _loc1_ += 16;
            _loc25_ = li32(wdnative_nternal._nbins);
            _loc25_ = _loc25_ * 40;
            _loc25_ = _loc25_ + 123;
            _loc23_ = _loc25_ & -64;
            _loc22_ = li32(wdnative_nternal._base_next_addr);
            var _temp_253:* = int(_loc23_ + _loc22_);
            _loc25_ = li32(wdnative_nternal._base_past_addr);
            while(true)
            {
               if(uint(_temp_253) > uint(_loc25_))
               {
                  _loc1_ -= 16;
                  si32(_loc23_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_base_pages_alloc();
                  _loc1_ += 16;
                  _loc25_ = wdnative.eax;
                  if(_loc25_ != 0)
                  {
                     break;
                  }
                  _loc22_ = li32(wdnative_nternal._base_next_addr);
               }
               _loc25_ = _loc22_ + _loc23_;
               si32(_loc25_,wdnative_nternal._base_next_addr);
               if(_loc22_ != 0)
               {
                  _loc25_ = _loc22_ + 8;
                  si32(_loc25_,_loc22_ + 4);
                  si32(_loc25_,_loc22_ + 12);
                  _loc25_ &= -2;
                  si32(_loc25_,_loc22_ + 16);
                  si32(0,_loc22_ + 36);
                  si32(0,_loc22_ + 40);
                  _loc25_ = _loc22_ + 48;
                  si32(_loc25_,_loc22_ + 44);
                  si32(_loc25_,_loc22_ + 48);
                  _loc25_ &= -2;
                  si32(_loc25_,_loc22_ + 52);
                  si32(0,_loc22_ + 60);
                  _loc25_ = _loc22_ + 68;
                  si32(_loc25_,_loc22_ + 64);
                  si32(_loc25_,_loc22_ + 68);
                  _loc25_ &= -2;
                  si32(_loc25_,_loc22_ + 72);
                  si32(2,_loc22_ + 80);
                  _loc1_ -= 16;
                  si32(4096,_loc1_ + 4);
                  _loc25_ = _loc22_ + 60;
                  si32(_loc25_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_arena_bin_run_size_calc();
                  _loc1_ += 16;
                  var _temp_267:* = wdnative.eax;
                  si32(0,_loc22_ + 100);
                  _loc21_ = _loc22_ + 108;
                  si32(_loc21_,_loc22_ + 104);
                  si32(_loc21_,_loc22_ + 108);
                  _loc21_ &= -2;
                  si32(_loc21_,_loc22_ + 112);
                  si32(4,_loc22_ + 120);
                  _loc1_ -= 16;
                  si32(_temp_267,_loc1_ + 4);
                  _loc25_ = _loc22_ + 100;
                  si32(_loc25_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_arena_bin_run_size_calc();
                  _loc1_ += 16;
                  var _temp_272:* = wdnative.eax;
                  si32(0,_loc22_ + 140);
                  _loc21_ = _loc22_ + 148;
                  si32(_loc21_,_loc22_ + 144);
                  si32(_loc21_,_loc22_ + 148);
                  _loc21_ &= -2;
                  si32(_loc21_,_loc22_ + 152);
                  si32(8,_loc22_ + 160);
                  _loc1_ -= 16;
                  si32(_temp_272,_loc1_ + 4);
                  _loc25_ = _loc22_ + 140;
                  si32(_loc25_,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F_arena_bin_run_size_calc();
                  _loc1_ += 16;
                  _loc23_ = wdnative.eax;
                  _loc19_ = li32(wdnative_nternal._nqbins);
                  _loc25_ = _loc19_ + 3;
                  if((uint(_loc25_)) >= 4)
                  {
                     _loc20_ = _loc22_ + 180;
                     _loc9_ = _loc22_ + 188;
                     _loc24_ = 3;
                     _loc6_ = 16;
                     _loc18_ = 0;
                     do
                     {
                        _loc25_ = _loc22_ + _loc18_;
                        si32(0,_loc25_ + 180);
                        _loc21_ = _loc9_ + _loc18_;
                        si32(_loc21_,_loc25_ + 184);
                        _loc21_ = _loc9_ + _loc18_;
                        si32(_loc21_,_loc25_ + 188);
                        _loc21_ = _loc9_ + _loc18_;
                        _loc21_ = _loc21_ & -2;
                        si32(_loc21_,_loc25_ + 192);
                        si32(_loc6_,_loc25_ + 200);
                        _loc1_ -= 16;
                        si32(_loc23_,_loc1_ + 4);
                        _loc25_ = _loc20_ + _loc18_;
                        si32(_loc25_,_loc1_);
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F_arena_bin_run_size_calc();
                        _loc6_ += 16;
                        _loc18_ += 40;
                        _loc24_ += 1;
                        _loc1_ += 16;
                        _loc23_ = wdnative.eax;
                     }
                     while(_loc19_ = li32(wdnative_nternal._nqbins), _loc25_ = _loc19_ + 3, (uint(_loc25_)) > uint(_loc24_));
                  }
                  _loc25_ = li32(wdnative_nternal._ncbins);
                  _loc25_ = _loc19_ + _loc25_;
                  _loc25_ = _loc25_ + 3;
                  if((uint(_loc25_)) > uint(_loc24_))
                  {
                     var _temp_287:* = int(_loc24_ * 40);
                     _loc9_ = _loc22_ + _temp_287;
                     _loc18_ = 68;
                     _loc6_ = 60;
                     _loc19_ = 0;
                     do
                     {
                        _loc25_ = _loc19_ * 10;
                        _loc25_ = _loc25_ << 2;
                        _loc25_ = _loc9_ + _loc25_;
                        si32(0,_loc25_ + 60);
                        _loc21_ = _loc9_ + _loc18_;
                        si32(_loc21_,_loc25_ + 64);
                        si32(_loc21_,_loc25_ + 68);
                        _loc21_ &= -2;
                        si32(_loc21_,_loc25_ + 72);
                        _loc3_ = _loc24_ + _loc19_;
                        _loc21_ = li32(wdnative_nternal._nqbins);
                        _loc21_ = _loc3_ - _loc21_;
                        _loc3_ = _loc21_ << 6;
                        _loc21_ = li32(wdnative_nternal._cspace_min);
                        _loc21_ = _loc21_ + _loc3_;
                        _loc21_ = _loc21_ + -192;
                        si32(_loc21_,_loc25_ + 80);
                        _loc1_ -= 16;
                        si32(_loc23_,_loc1_ + 4);
                        _loc25_ = _loc9_ + _loc6_;
                        si32(_loc25_,_loc1_);
                        _loc19_ += 1;
                        _loc20_ = _loc24_ + _loc19_;
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F_arena_bin_run_size_calc();
                        _loc1_ += 16;
                        _loc23_ = wdnative.eax;
                        _loc21_ = li32(wdnative_nternal._ncbins);
                        _loc25_ = li32(wdnative_nternal._nqbins);
                        _loc25_ = _loc25_ + _loc21_;
                        _loc25_ = _loc25_ + 3;
                        _loc6_ += 40;
                        _loc18_ += 40;
                     }
                     while(uint(_loc25_) > uint(_loc20_));
                     _loc24_ = _loc20_;
                  }
                  _loc25_ = li32(wdnative_nternal._nbins);
                  if(uint(_loc24_) < uint(_loc25_))
                  {
                     var _temp_299:* = int(_loc24_ * 40);
                     _loc9_ = _loc22_ + _temp_299;
                     _loc6_ = 68;
                     _loc20_ = 60;
                     _loc18_ = 0;
                     do
                     {
                        _loc25_ = _loc18_ * 10;
                        _loc25_ = _loc25_ << 2;
                        _loc25_ = _loc9_ + _loc25_;
                        si32(0,_loc25_ + 60);
                        _loc21_ = _loc9_ + _loc6_;
                        si32(_loc21_,_loc25_ + 64);
                        si32(_loc21_,_loc25_ + 68);
                        _loc21_ &= -2;
                        si32(_loc21_,_loc25_ + 72);
                        _loc21_ = _loc24_ + _loc18_;
                        _loc3_ = li32(wdnative_nternal._nqbins);
                        var _loc4_:int = 0 - _loc3_;
                        _loc3_ = li32(wdnative_nternal._ncbins);
                        _loc3_ = _loc4_ - _loc3_;
                        _loc21_ += _loc3_;
                        _loc3_ = _loc21_ << 8;
                        _loc21_ = li32(wdnative_nternal._sspace_min);
                        _loc21_ = _loc21_ + _loc3_;
                        _loc21_ = _loc21_ + -768;
                        si32(_loc21_,_loc25_ + 80);
                        _loc1_ -= 16;
                        si32(_loc23_,_loc1_ + 4);
                        _loc25_ = _loc9_ + _loc20_;
                        si32(_loc25_,_loc1_);
                        _loc18_ += 1;
                        _loc21_ = _loc24_ + _loc18_;
                        wdnative.ESP = _loc1_;
                        wdnative_nternal.F_arena_bin_run_size_calc();
                        _loc20_ += 40;
                        _loc6_ += 40;
                        _loc1_ += 16;
                        _loc23_ = wdnative.eax;
                        _loc25_ = li32(wdnative_nternal._nbins);
                     }
                     while(uint(_loc21_) < uint(_loc25_));
                  }
                  _loc25_ = li32(wdnative_nternal._arenas);
                  si32(_loc22_,_loc25_);
                  addr224c:
                  _loc25_ = li32(wdnative_nternal._arenas);
                  _loc25_ = li32(_loc25_);
                  _loc9_ = 1;
                  if(_loc25_ != 0)
                  {
                     si8(1,wdnative_nternal._malloc_initialized_2E_b);
                     _loc9_ = 0;
                  }
                  break loop38;
               }
               break;
            }
            _loc24_ = li32(wdnative_nternal.___progname);
            _loc22_ = _loc24_ & -4;
            _loc21_ = li32(_loc22_);
            _loc25_ = _loc21_ + -16843009;
            _loc21_ &= -2139062144;
            _loc21_ = _loc21_ ^ -2139062144;
            _loc25_ = _loc21_ & _loc25_;
            if(_loc25_ != 0)
            {
               _loc23_ = _loc22_ + 4;
               _loc20_ = 0;
               while(true)
               {
                  _loc9_ = _loc24_ + _loc20_;
                  if((uint(_loc9_)) < uint(_loc23_))
                  {
                     _loc25_ = li8(_loc9_);
                     if(_loc25_ == 0)
                     {
                        break;
                     }
                     _loc20_ += 1;
                     continue;
                  }
               }
               addr1dd7:
               _loc1_ -= 16;
               si32(_loc20_,_loc1_ + 8);
               si32(_loc24_,_loc1_ + 4);
               si32(2,_loc1_);
               wdnative.ESP = _loc1_;
               wdnative_nternal.F___sys_write();
               _loc1_ += 16;
               _loc24_ = wdnative_nternal.L__2E_str40655 & -4;
               _loc21_ = li32(_loc24_);
               _loc25_ = _loc21_ + -16843009;
               _loc21_ &= -2139062144;
               _loc21_ = _loc21_ ^ -2139062144;
               _loc25_ = _loc21_ & _loc25_;
               _loc23_ = _loc24_ + 4;
               _loc22_ = 0;
               if(_loc25_ != 0)
               {
                  do
                  {
                     _loc25_ = wdnative_nternal.L__2E_str40655 + _loc22_;
                     _loc23_ = _loc24_ + 4;
                     if(uint(_loc25_) < uint(_loc23_))
                     {
                        continue;
                     }
                  }
                  while(_loc9_ = _loc24_ + 4, _loc23_ = wdnative_nternal.L__2E_str40655, if(uint(wdnative_nternal.L__2E_str40655) <= uint(_loc9_))
                  {
                     _loc23_ = _loc9_;
                  }, _loc25_ = _loc23_ ^ -1, _loc23_ = wdnative_nternal.L__2E_str40655 + _loc25_, if((uint(_loc23_)) <= 4294967259)
                  {
                     _loc23_ = -37;
                  }, _loc23_ ^= -1, _loc22_ += 1, _loc22_ != 37);
                  addr1f72:
                  _loc1_ -= 16;
                  si32(_loc23_,_loc1_ + 8);
                  si32(wdnative_nternal.L__2E_str40655,_loc1_ + 4);
                  si32(2,_loc1_);
                  _loc22_ = wdnative_nternal.L__2E_str2617 & -4;
                  _loc23_ = _loc22_ + 4;
                  _loc24_ = 0;
                  _loc9_ = 1;
                  if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc23_))
                  {
                     _loc9_ = _loc24_;
                  }
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sys_write();
                  _loc1_ += 16;
                  _loc21_ = li32(_loc22_);
                  _loc25_ = _loc21_ + -16843009;
                  loop40:
                  while(true)
                  {
                     _loc21_ &= -2139062144;
                     _loc21_ = _loc21_ ^ -2139062144;
                     _loc25_ = _loc21_ & _loc25_;
                     if(_loc25_ != 0)
                     {
                        var _temp_332:* = _loc9_ & 1;
                        _loc9_ = _loc24_;
                        if(_temp_332 == 0)
                        {
                           break;
                        }
                     }
                     while(true)
                     {
                        _loc9_ = li32(_loc23_);
                        _loc25_ = _loc9_ + -16843009;
                        _loc21_ = _loc9_ & -2139062144;
                        _loc21_ = _loc21_ ^ -2139062144;
                        _loc25_ = _loc21_ & _loc25_;
                        if(_loc25_ != 0)
                        {
                           _loc25_ = _loc9_ & 0xFF;
                           if(_loc25_ == 0)
                           {
                              _loc9_ = _loc23_ - wdnative_nternal.L__2E_str2617;
                              break loop40;
                           }
                           _loc25_ = li8(_loc23_ + 1);
                           if(_loc25_ == 0)
                           {
                              var _temp_339:* = int(1 - wdnative_nternal.L__2E_str2617);
                              _loc9_ = _loc23_ + _temp_339;
                              break loop40;
                           }
                           _loc25_ = li8(_loc23_ + 2);
                           if(_loc25_ == 0)
                           {
                              var _temp_341:* = int(2 - wdnative_nternal.L__2E_str2617);
                              _loc9_ = _loc23_ + _temp_341;
                              break loop40;
                           }
                           _loc25_ = li8(_loc23_ + 3);
                           if(_loc25_ == 0)
                           {
                              var _temp_343:* = int(3 - wdnative_nternal.L__2E_str2617);
                              _loc9_ = _loc23_ + _temp_343;
                              break loop40;
                           }
                        }
                        _loc23_ += 4;
                     }
                     break;
                  }
                  _loc1_ -= 16;
                  si32(_loc9_,_loc1_ + 8);
                  si32(2,_loc1_);
                  si32(wdnative_nternal.L__2E_str2617,_loc1_ + 4);
                  _loc23_ = _loc22_ + 4;
                  _loc9_ = 1;
                  if(uint(wdnative_nternal.L__2E_str2617) < uint(_loc23_))
                  {
                     _loc9_ = _loc24_;
                  }
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sys_write();
                  _loc1_ += 16;
                  _loc21_ = li32(_loc22_);
                  _loc25_ = _loc21_ + -16843009;
                  loop41:
                  while(true)
                  {
                     _loc21_ &= -2139062144;
                     _loc21_ = _loc21_ ^ -2139062144;
                     _loc25_ = _loc21_ & _loc25_;
                     if(_loc25_ != 0)
                     {
                        _loc25_ = _loc9_ & 1;
                        if(_loc25_ == 0)
                        {
                           break;
                        }
                     }
                     while(true)
                     {
                        _loc24_ = li32(_loc23_);
                        _loc25_ = _loc24_ + -16843009;
                        _loc21_ = _loc24_ & -2139062144;
                        _loc21_ = _loc21_ ^ -2139062144;
                        _loc25_ = _loc21_ & _loc25_;
                        if(_loc25_ != 0)
                        {
                           _loc25_ = _loc24_ & 0xFF;
                           if(_loc25_ == 0)
                           {
                              _loc24_ = _loc23_ - wdnative_nternal.L__2E_str2617;
                              break loop41;
                           }
                           _loc25_ = li8(_loc23_ + 1);
                           if(_loc25_ == 0)
                           {
                              var _temp_356:* = int(1 - wdnative_nternal.L__2E_str2617);
                              _loc24_ = _loc23_ + _temp_356;
                              break loop41;
                           }
                           _loc25_ = li8(_loc23_ + 2);
                           if(_loc25_ == 0)
                           {
                              var _temp_358:* = int(2 - wdnative_nternal.L__2E_str2617);
                              _loc24_ = _loc23_ + _temp_358;
                              break loop41;
                           }
                           _loc25_ = li8(_loc23_ + 3);
                           if(_loc25_ == 0)
                           {
                              var _temp_360:* = int(3 - wdnative_nternal.L__2E_str2617);
                              _loc24_ = _loc23_ + _temp_360;
                              break loop41;
                           }
                        }
                        _loc23_ += 4;
                     }
                     break;
                  }
                  _loc1_ -= 16;
                  si32(_loc24_,_loc1_ + 8);
                  si32(wdnative_nternal.L__2E_str2617,_loc1_ + 4);
                  si32(2,_loc1_);
                  wdnative.ESP = _loc1_;
                  wdnative_nternal.F___sys_write();
                  _loc1_ += 16;
                  _loc25_ = li8(wdnative_nternal._opt_abort_2E_b);
                  if(_loc25_ == 1)
                  {
                     wdnative.ESP = _loc1_;
                     wdnative_nternal.F_abort();
                  }
                  §§goto(addr224c);
               }
               while(true)
               {
                  _loc24_ = li32(_loc23_);
                  _loc25_ = _loc24_ + -16843009;
                  _loc21_ = _loc24_ & -2139062144;
                  _loc21_ = _loc21_ ^ -2139062144;
                  _loc25_ = _loc21_ & _loc25_;
                  if(_loc25_ != 0)
                  {
                     _loc25_ = _loc24_ & 0xFF;
                     if(_loc25_ == 0)
                     {
                        _loc23_ -= wdnative_nternal.L__2E_str40655;
                        break;
                     }
                     _loc25_ = li8(_loc23_ + 1);
                     if(_loc25_ == 0)
                     {
                        var _temp_370:* = int(1 - wdnative_nternal.L__2E_str40655);
                        _loc23_ += _temp_370;
                        break;
                     }
                     _loc25_ = li8(_loc23_ + 2);
                     if(_loc25_ == 0)
                     {
                        var _temp_372:* = int(2 - wdnative_nternal.L__2E_str40655);
                        _loc23_ += _temp_372;
                        break;
                     }
                     _loc25_ = li8(_loc23_ + 3);
                     if(_loc25_ == 0)
                     {
                        var _temp_374:* = int(3 - wdnative_nternal.L__2E_str40655);
                        _loc23_ += _temp_374;
                        break;
                     }
                  }
                  _loc23_ += 4;
               }
               §§goto(addr1f72);
            }
            _loc22_ += 4;
            while(true)
            {
               _loc23_ = li32(_loc22_);
               _loc25_ = _loc23_ + -16843009;
               _loc21_ = _loc23_ & -2139062144;
               _loc21_ = _loc21_ ^ -2139062144;
               _loc25_ = _loc21_ & _loc25_;
               if(_loc25_ != 0)
               {
                  _loc25_ = _loc23_ & 0xFF;
                  if(_loc25_ == 0)
                  {
                     _loc20_ = _loc22_ - _loc24_;
                     break;
                  }
                  _loc25_ = li8(_loc22_ + 1);
                  if(_loc25_ == 0)
                  {
                     _loc25_ = 1 - _loc24_;
                     _loc20_ = _loc25_ + _loc22_;
                     break;
                  }
                  _loc25_ = li8(_loc22_ + 2);
                  if(_loc25_ == 0)
                  {
                     _loc25_ = 2 - _loc24_;
                     _loc20_ = _loc25_ + _loc22_;
                     break;
                  }
                  _loc25_ = li8(_loc22_ + 3);
                  if(_loc25_ == 0)
                  {
                     _loc25_ = 3 - _loc24_;
                     _loc20_ = _loc25_ + _loc22_;
                     break;
                  }
               }
               _loc22_ += 4;
            }
            §§goto(addr1dd7);
         }
      }
      wdnative.eax = _loc9_;
      _loc1_ = _loc2_;
      wdnative.ESP = _loc1_;
   }
}

