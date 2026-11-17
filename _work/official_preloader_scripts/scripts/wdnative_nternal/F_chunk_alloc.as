package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F_chunk_alloc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc11_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 64;
      _loc1_ = li32(_loc3_);
      loop43:
      while(true)
      {
         var _loc14_:int = li8(wdnative_nternal._opt_mmap_2E_b);
         if(_loc14_ == 0)
         {
            _loc2_ -= 16;
            si32(_loc1_,_loc2_ + 4);
            _loc13_ = 0;
            si32(_loc13_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_pages_map();
            _loc2_ += 16;
            _loc12_ = wdnative.eax;
            if(_loc12_ != 0)
            {
               _loc14_ = li32(wdnative_nternal._chunksize_mask);
               _loc11_ = _loc14_ & _loc12_;
               if(_loc11_ != 0)
               {
                  _loc14_ = li32(wdnative_nternal._chunksize);
                  var _temp_8:* = int(_loc14_ - _loc11_);
                  _loc2_ -= 16;
                  si32(_temp_8,_loc2_ + 4);
                  _loc14_ = _loc12_ + _loc1_;
                  si32(_loc14_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_pages_map();
                  _loc2_ += 16;
                  loop44:
                  while(true)
                  {
                     while(true)
                     {
                        _loc14_ = wdnative.eax;
                        if(_loc14_ == 0)
                        {
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_ + 4);
                           si32(_loc12_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_munmap();
                           _loc2_ += 16;
                           _loc14_ = wdnative.eax;
                           if(_loc14_ == -1)
                           {
                              var _temp_15:* = li32(wdnative_nternal._errno);
                              _loc2_ -= 16;
                              _loc12_ = _loc3_ - 64;
                              si32(_loc12_,_loc2_ + 4);
                              si32(_temp_15,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_strerror_r();
                              _loc2_ += 16;
                              _loc11_ = li32(wdnative_nternal.___progname);
                              _loc10_ = _loc11_ & -4;
                              var _loc9_:int = li32(_loc10_);
                              var _temp_22:* = int(_loc9_ + -16843009);
                              _loc14_ = (_loc9_ = (_loc9_ &= -2139062144) ^ -2139062144) & _temp_22;
                              if(_loc14_ != 0)
                              {
                                 _loc13_ = _loc10_ + 4;
                                 _loc8_ = 0;
                                 while(true)
                                 {
                                    _loc7_ = _loc11_ + _loc8_;
                                    if((uint(_loc7_)) < uint(_loc13_))
                                    {
                                       _loc14_ = li8(_loc7_);
                                       if(_loc14_ == 0)
                                       {
                                          break;
                                       }
                                       _loc8_ += 1;
                                       continue;
                                    }
                                 }
                                 addr026d:
                                 _loc2_ -= 16;
                                 si32(_loc8_,_loc2_ + 8);
                                 si32(_loc11_,_loc2_ + 4);
                                 si32(2,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F___sys_write();
                                 _loc2_ += 16;
                                 _loc8_ = wdnative_nternal.L__2E_str39654 & -4;
                                 _loc9_ = li32(_loc8_);
                                 _loc14_ = _loc9_ + -16843009;
                                 _loc9_ &= -2139062144;
                                 _loc9_ = _loc9_ ^ -2139062144;
                                 _loc14_ = _loc9_ & _loc14_;
                                 _loc10_ = _loc8_ + 4;
                                 _loc11_ = 0;
                                 if(_loc14_ != 0)
                                 {
                                    do
                                    {
                                       _loc14_ = wdnative_nternal.L__2E_str39654 + _loc11_;
                                       _loc10_ = _loc8_ + 4;
                                       if(uint(_loc14_) < uint(_loc10_))
                                       {
                                          continue;
                                       }
                                    }
                                    while(_loc10_ = _loc8_ + 4, _loc13_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc10_))
                                    {
                                       _loc13_ = _loc10_;
                                    }, _loc14_ = _loc13_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str39654 + _loc14_, if((uint(_loc10_)) <= 4294967265)
                                    {
                                       _loc10_ = -31;
                                    }, _loc10_ ^= -1, _loc11_ += 1, _loc11_ != 31);
                                    addr0408:
                                    _loc2_ -= 16;
                                    si32(_loc10_,_loc2_ + 8);
                                    si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                                    si32(2,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F___sys_write();
                                    _loc2_ += 16;
                                    _loc8_ = _loc12_ & -4;
                                    _loc9_ = li32(_loc8_);
                                    _loc14_ = _loc9_ + -16843009;
                                    _loc9_ &= -2139062144;
                                    _loc9_ = _loc9_ ^ -2139062144;
                                    _loc14_ = _loc9_ & _loc14_;
                                    if(_loc14_ != 0)
                                    {
                                       _loc10_ = _loc8_ + 4;
                                       _loc11_ = 0;
                                       while(true)
                                       {
                                          _loc13_ = _loc12_ + _loc11_;
                                          if((uint(_loc13_)) < uint(_loc10_))
                                          {
                                             _loc14_ = li8(_loc13_);
                                             if(_loc14_ == 0)
                                             {
                                                break;
                                             }
                                             _loc11_ += 1;
                                             continue;
                                          }
                                       }
                                       addr0568:
                                       _loc2_ -= 16;
                                       si32(_loc11_,_loc2_ + 8);
                                       si32(_loc12_,_loc2_ + 4);
                                       si32(2,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F___sys_write();
                                       _loc2_ += 16;
                                       _loc12_ = wdnative_nternal.L__2E_str5620 & -4;
                                       _loc9_ = li32(_loc12_);
                                       _loc14_ = _loc9_ + -16843009;
                                       _loc9_ &= -2139062144;
                                       _loc9_ = _loc9_ ^ -2139062144;
                                       _loc14_ = _loc9_ & _loc14_;
                                       _loc8_ = _loc12_ + 4;
                                       _loc11_ = 0;
                                       if(_loc14_ != 0)
                                       {
                                          do
                                          {
                                             _loc14_ = wdnative_nternal.L__2E_str5620 + _loc11_;
                                             _loc8_ = _loc12_ + 4;
                                             if(uint(_loc14_) < uint(_loc8_))
                                             {
                                                continue;
                                             }
                                          }
                                          while(_loc10_ = _loc12_ + 4, _loc8_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc10_))
                                          {
                                             _loc8_ = _loc10_;
                                          }, _loc14_ = _loc8_ ^ -1, _loc8_ = wdnative_nternal.L__2E_str5620 + _loc14_, if(_loc8_ != -1)
                                          {
                                             _loc8_ = -2;
                                          }, _loc8_ ^= -1, _loc11_ += 1, _loc11_ != 2);
                                          addr0702:
                                          _loc2_ -= 16;
                                          si32(_loc8_,_loc2_ + 8);
                                          si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                                          si32(2,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F___sys_write();
                                          _loc2_ += 16;
                                          _loc14_ = li8(wdnative_nternal._opt_abort_2E_b);
                                          if(_loc14_ == 1)
                                          {
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_abort();
                                          }
                                          addr074e:
                                          _loc14_ = li32(wdnative_nternal._chunksize);
                                          _loc12_ = _loc14_ + _loc1_;
                                          if((uint(_loc12_)) <= uint(_loc1_))
                                          {
                                             break;
                                          }
                                          _loc2_ -= 16;
                                          si32(_loc12_,_loc2_ + 4);
                                          _loc11_ = 0;
                                          si32(_loc11_,_loc2_);
                                          wdnative.ESP = _loc2_;
                                          wdnative_nternal.F_pages_map();
                                          _loc2_ += 16;
                                          _loc12_ = wdnative.eax;
                                          if(_loc12_ == 0)
                                          {
                                             break;
                                          }
                                          _loc14_ = li32(wdnative_nternal._chunksize_mask);
                                          _loc8_ = _loc14_ & _loc12_;
                                          if(_loc8_ != 0)
                                          {
                                             _loc14_ = li32(wdnative_nternal._chunksize);
                                             var _temp_60:* = int(_loc14_ - _loc8_);
                                             _loc2_ -= 16;
                                             si32(_temp_60,_loc2_ + 4);
                                             si32(_loc12_,_loc2_);
                                             wdnative.ESP = _loc2_;
                                             wdnative_nternal.F_munmap();
                                             _loc2_ += 16;
                                             _loc14_ = wdnative.eax;
                                             if(_loc14_ == -1)
                                             {
                                                var _temp_64:* = li32(wdnative_nternal._errno);
                                                _loc2_ -= 16;
                                                _loc10_ = _loc3_ - 64;
                                                si32(_loc10_,_loc2_ + 4);
                                                si32(_temp_64,_loc2_);
                                                wdnative.ESP = _loc2_;
                                                wdnative_nternal.F_strerror_r();
                                                _loc2_ += 16;
                                                _loc13_ = li32(wdnative_nternal.___progname);
                                                _loc7_ = _loc13_ & -4;
                                                _loc9_ = li32(_loc7_);
                                                var _temp_71:* = int(_loc9_ + -16843009);
                                                _loc14_ = (_loc9_ = (_loc9_ &= -2139062144) ^ -2139062144) & _temp_71;
                                                if(_loc14_ != 0)
                                                {
                                                   _loc6_ = _loc7_ + 4;
                                                   _loc4_ = 0;
                                                   while(true)
                                                   {
                                                      _loc5_ = _loc13_ + _loc4_;
                                                      if((uint(_loc5_)) < uint(_loc6_))
                                                      {
                                                         _loc14_ = li8(_loc5_);
                                                         if(_loc14_ == 0)
                                                         {
                                                            break;
                                                         }
                                                         _loc4_ += 1;
                                                         continue;
                                                      }
                                                   }
                                                   addr094d:
                                                   _loc2_ -= 16;
                                                   si32(_loc4_,_loc2_ + 8);
                                                   si32(_loc13_,_loc2_ + 4);
                                                   si32(2,_loc2_);
                                                   wdnative.ESP = _loc2_;
                                                   wdnative_nternal.F___sys_write();
                                                   _loc2_ += 16;
                                                   _loc13_ = wdnative_nternal.L__2E_str39654 & -4;
                                                   _loc9_ = li32(_loc13_);
                                                   _loc14_ = _loc9_ + -16843009;
                                                   _loc9_ &= -2139062144;
                                                   _loc9_ = _loc9_ ^ -2139062144;
                                                   _loc14_ = _loc9_ & _loc14_;
                                                   _loc4_ = _loc13_ + 4;
                                                   _loc7_ = 0;
                                                   if(_loc14_ != 0)
                                                   {
                                                      do
                                                      {
                                                         _loc14_ = wdnative_nternal.L__2E_str39654 + _loc7_;
                                                         _loc4_ = _loc13_ + 4;
                                                         if(uint(_loc14_) < uint(_loc4_))
                                                         {
                                                            continue;
                                                         }
                                                      }
                                                      while(_loc5_ = _loc13_ + 4, _loc4_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc5_))
                                                      {
                                                         _loc4_ = _loc5_;
                                                      }, _loc14_ = _loc4_ ^ -1, _loc4_ = wdnative_nternal.L__2E_str39654 + _loc14_, if((uint(_loc4_)) <= 4294967265)
                                                      {
                                                         _loc4_ = -31;
                                                      }, _loc4_ ^= -1, _loc7_ += 1, _loc7_ != 31);
                                                      addr0ae8:
                                                      _loc2_ -= 16;
                                                      si32(_loc4_,_loc2_ + 8);
                                                      si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                                                      si32(2,_loc2_);
                                                      wdnative.ESP = _loc2_;
                                                      wdnative_nternal.F___sys_write();
                                                      _loc2_ += 16;
                                                      _loc4_ = _loc10_ & -4;
                                                      _loc9_ = li32(_loc4_);
                                                      _loc14_ = _loc9_ + -16843009;
                                                      _loc9_ &= -2139062144;
                                                      _loc9_ = _loc9_ ^ -2139062144;
                                                      _loc14_ = _loc9_ & _loc14_;
                                                      if(_loc14_ != 0)
                                                      {
                                                         _loc13_ = _loc4_ + 4;
                                                         _loc5_ = 0;
                                                         while(true)
                                                         {
                                                            _loc7_ = _loc10_ + _loc5_;
                                                            if((uint(_loc7_)) < uint(_loc13_))
                                                            {
                                                               _loc14_ = li8(_loc7_);
                                                               if(_loc14_ == 0)
                                                               {
                                                                  break;
                                                               }
                                                               _loc5_ += 1;
                                                               continue;
                                                            }
                                                         }
                                                         addr0c48:
                                                         _loc2_ -= 16;
                                                         si32(_loc5_,_loc2_ + 8);
                                                         si32(_loc10_,_loc2_ + 4);
                                                         si32(2,_loc2_);
                                                         wdnative.ESP = _loc2_;
                                                         wdnative_nternal.F___sys_write();
                                                         _loc2_ += 16;
                                                         _loc10_ = wdnative_nternal.L__2E_str5620 & -4;
                                                         _loc9_ = li32(_loc10_);
                                                         _loc14_ = _loc9_ + -16843009;
                                                         _loc9_ &= -2139062144;
                                                         _loc9_ = _loc9_ ^ -2139062144;
                                                         _loc14_ = _loc9_ & _loc14_;
                                                         _loc7_ = _loc10_ + 4;
                                                         _loc13_ = 0;
                                                         if(_loc14_ != 0)
                                                         {
                                                            do
                                                            {
                                                               _loc14_ = wdnative_nternal.L__2E_str5620 + _loc13_;
                                                               _loc7_ = _loc10_ + 4;
                                                               if(uint(_loc14_) < uint(_loc7_))
                                                               {
                                                                  continue;
                                                               }
                                                            }
                                                            while(_loc7_ = _loc10_ + 4, _loc4_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc7_))
                                                            {
                                                               _loc4_ = _loc7_;
                                                            }, _loc14_ = _loc4_ ^ -1, _loc7_ = wdnative_nternal.L__2E_str5620 + _loc14_, if(_loc7_ != -1)
                                                            {
                                                               _loc7_ = -2;
                                                            }, _loc7_ ^= -1, _loc13_ += 1, _loc13_ != 2);
                                                            addr0de2:
                                                            _loc2_ -= 16;
                                                            si32(_loc7_,_loc2_ + 8);
                                                            si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                                                            si32(2,_loc2_);
                                                            wdnative.ESP = _loc2_;
                                                            wdnative_nternal.F___sys_write();
                                                            _loc2_ += 16;
                                                            _loc14_ = li8(wdnative_nternal._opt_abort_2E_b);
                                                            if(_loc14_ == 1)
                                                            {
                                                               wdnative.ESP = _loc2_;
                                                               wdnative_nternal.F_abort();
                                                            }
                                                            addr0e2e:
                                                            _loc14_ = li32(wdnative_nternal._chunksize);
                                                            _loc2_ -= 16;
                                                            si32(_loc8_,_loc2_ + 4);
                                                            _loc14_ -= _loc8_;
                                                            _loc12_ = _loc14_ + _loc12_;
                                                            _loc14_ = _loc12_ + _loc1_;
                                                            si32(_loc14_,_loc2_);
                                                            wdnative.ESP = _loc2_;
                                                            wdnative_nternal.F_munmap();
                                                            _loc2_ += 16;
                                                            _loc14_ = wdnative.eax;
                                                            if(_loc14_ != -1)
                                                            {
                                                               break loop44;
                                                            }
                                                            var _temp_108:* = li32(wdnative_nternal._errno);
                                                            _loc2_ -= 16;
                                                            _loc8_ = _loc3_ - 64;
                                                            si32(_loc8_,_loc2_ + 4);
                                                            si32(_temp_108,_loc2_);
                                                            wdnative.ESP = _loc2_;
                                                            wdnative_nternal.F_strerror_r();
                                                            _loc2_ += 16;
                                                            _loc10_ = li32(wdnative_nternal.___progname);
                                                            _loc4_ = _loc10_ & -4;
                                                            _loc9_ = li32(_loc4_);
                                                            var _temp_115:* = int(_loc9_ + -16843009);
                                                            _loc14_ = (_loc9_ = (_loc9_ &= -2139062144) ^ -2139062144) & _temp_115;
                                                            if(_loc14_ != 0)
                                                            {
                                                               _loc13_ = _loc4_ + 4;
                                                               while(true)
                                                               {
                                                                  _loc7_ = _loc10_ + _loc11_;
                                                                  if((uint(_loc7_)) < uint(_loc13_))
                                                                  {
                                                                     _loc14_ = li8(_loc7_);
                                                                     if(_loc14_ == 0)
                                                                     {
                                                                        break;
                                                                     }
                                                                     _loc11_ += 1;
                                                                     continue;
                                                                  }
                                                               }
                                                               addr0fda:
                                                               _loc2_ -= 16;
                                                               si32(_loc11_,_loc2_ + 8);
                                                               si32(_loc10_,_loc2_ + 4);
                                                               si32(2,_loc2_);
                                                               wdnative.ESP = _loc2_;
                                                               wdnative_nternal.F___sys_write();
                                                               _loc2_ += 16;
                                                               _loc11_ = wdnative_nternal.L__2E_str39654 & -4;
                                                               _loc9_ = li32(_loc11_);
                                                               _loc14_ = _loc9_ + -16843009;
                                                               _loc9_ &= -2139062144;
                                                               _loc9_ = _loc9_ ^ -2139062144;
                                                               _loc14_ = _loc9_ & _loc14_;
                                                               _loc13_ = _loc11_ + 4;
                                                               _loc10_ = 0;
                                                               if(_loc14_ != 0)
                                                               {
                                                                  do
                                                                  {
                                                                     _loc14_ = wdnative_nternal.L__2E_str39654 + _loc10_;
                                                                     _loc13_ = _loc11_ + 4;
                                                                     if(uint(_loc14_) < uint(_loc13_))
                                                                     {
                                                                        continue;
                                                                     }
                                                                  }
                                                                  while(_loc7_ = _loc11_ + 4, _loc13_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc7_))
                                                                  {
                                                                     _loc13_ = _loc7_;
                                                                  }, _loc14_ = _loc13_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str39654 + _loc14_, if((uint(_loc13_)) <= 4294967265)
                                                                  {
                                                                     _loc13_ = -31;
                                                                  }, _loc13_ ^= -1, _loc10_ += 1, _loc10_ != 31);
                                                                  addr1175:
                                                                  _loc2_ -= 16;
                                                                  si32(_loc13_,_loc2_ + 8);
                                                                  si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                                                                  si32(2,_loc2_);
                                                                  wdnative.ESP = _loc2_;
                                                                  wdnative_nternal.F___sys_write();
                                                                  _loc2_ += 16;
                                                                  _loc10_ = _loc8_ & -4;
                                                                  _loc9_ = li32(_loc10_);
                                                                  _loc14_ = _loc9_ + -16843009;
                                                                  _loc9_ &= -2139062144;
                                                                  _loc9_ = _loc9_ ^ -2139062144;
                                                                  _loc14_ = _loc9_ & _loc14_;
                                                                  if(_loc14_ != 0)
                                                                  {
                                                                     _loc13_ = _loc10_ + 4;
                                                                     _loc11_ = 0;
                                                                     while(true)
                                                                     {
                                                                        _loc7_ = _loc8_ + _loc11_;
                                                                        if((uint(_loc7_)) < uint(_loc13_))
                                                                        {
                                                                           _loc14_ = li8(_loc7_);
                                                                           if(_loc14_ == 0)
                                                                           {
                                                                              break;
                                                                           }
                                                                           _loc11_ += 1;
                                                                           continue;
                                                                        }
                                                                     }
                                                                     addr12d5:
                                                                     _loc2_ -= 16;
                                                                     si32(_loc11_,_loc2_ + 8);
                                                                     si32(_loc8_,_loc2_ + 4);
                                                                     si32(2,_loc2_);
                                                                     wdnative.ESP = _loc2_;
                                                                     wdnative_nternal.F___sys_write();
                                                                     _loc2_ += 16;
                                                                     _loc8_ = wdnative_nternal.L__2E_str5620 & -4;
                                                                     _loc9_ = li32(_loc8_);
                                                                     _loc14_ = _loc9_ + -16843009;
                                                                     _loc9_ &= -2139062144;
                                                                     _loc9_ = _loc9_ ^ -2139062144;
                                                                     _loc14_ = _loc9_ & _loc14_;
                                                                     _loc10_ = _loc8_ + 4;
                                                                     _loc11_ = 0;
                                                                     if(_loc14_ != 0)
                                                                     {
                                                                        do
                                                                        {
                                                                           _loc14_ = wdnative_nternal.L__2E_str5620 + _loc11_;
                                                                           _loc10_ = _loc8_ + 4;
                                                                           if(uint(_loc14_) < uint(_loc10_))
                                                                           {
                                                                              continue;
                                                                           }
                                                                        }
                                                                        while(_loc10_ = _loc8_ + 4, _loc13_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc10_))
                                                                        {
                                                                           _loc13_ = _loc10_;
                                                                        }, _loc14_ = _loc13_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str5620 + _loc14_, if(_loc10_ != -1)
                                                                        {
                                                                           _loc10_ = -2;
                                                                        }, _loc10_ ^= -1, _loc11_ += 1, _loc11_ != 2);
                                                                        addr146f:
                                                                        _loc2_ -= 16;
                                                                        si32(_loc10_,_loc2_ + 8);
                                                                        si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                                                                        si32(2,_loc2_);
                                                                        wdnative.ESP = _loc2_;
                                                                        wdnative_nternal.F___sys_write();
                                                                        _loc2_ += 16;
                                                                        _loc14_ = li8(wdnative_nternal._opt_abort_2E_b);
                                                                        if(_loc14_ != 1)
                                                                        {
                                                                           break loop44;
                                                                        }
                                                                        wdnative.ESP = _loc2_;
                                                                        wdnative_nternal.F_abort();
                                                                        addr14bb:
                                                                        _loc14_ = li32(wdnative_nternal._chunksize);
                                                                        _loc2_ -= 16;
                                                                        si32(_loc14_,_loc2_ + 4);
                                                                        _loc14_ = _loc12_ + _loc1_;
                                                                        si32(_loc14_,_loc2_);
                                                                        wdnative.ESP = _loc2_;
                                                                        wdnative_nternal.F_munmap();
                                                                        _loc2_ += 16;
                                                                        _loc14_ = wdnative.eax;
                                                                        if(_loc14_ != -1)
                                                                        {
                                                                           break loop44;
                                                                        }
                                                                        var _temp_150:* = li32(wdnative_nternal._errno);
                                                                        _loc2_ -= 16;
                                                                        _loc11_ = _loc3_ - 64;
                                                                        si32(_loc11_,_loc2_ + 4);
                                                                        si32(_temp_150,_loc2_);
                                                                        wdnative.ESP = _loc2_;
                                                                        wdnative_nternal.F_strerror_r();
                                                                        _loc2_ += 16;
                                                                        _loc8_ = li32(wdnative_nternal.___progname);
                                                                        _loc10_ = _loc8_ & -4;
                                                                        _loc9_ = li32(_loc10_);
                                                                        var _temp_157:* = int(_loc9_ + -16843009);
                                                                        _loc14_ = (_loc9_ = (_loc9_ &= -2139062144) ^ -2139062144) & _temp_157;
                                                                        if(_loc14_ != 0)
                                                                        {
                                                                           _loc7_ = _loc10_ + 4;
                                                                           _loc13_ = 0;
                                                                           while(true)
                                                                           {
                                                                              _loc4_ = _loc8_ + _loc13_;
                                                                              if((uint(_loc4_)) < uint(_loc7_))
                                                                              {
                                                                                 _loc14_ = li8(_loc4_);
                                                                                 if(_loc14_ == 0)
                                                                                 {
                                                                                    break;
                                                                                 }
                                                                                 _loc13_ += 1;
                                                                                 continue;
                                                                              }
                                                                           }
                                                                           addr165d:
                                                                           _loc2_ -= 16;
                                                                           si32(_loc13_,_loc2_ + 8);
                                                                           si32(_loc8_,_loc2_ + 4);
                                                                           si32(2,_loc2_);
                                                                           wdnative.ESP = _loc2_;
                                                                           wdnative_nternal.F___sys_write();
                                                                           _loc2_ += 16;
                                                                           _loc8_ = wdnative_nternal.L__2E_str39654 & -4;
                                                                           _loc9_ = li32(_loc8_);
                                                                           _loc14_ = _loc9_ + -16843009;
                                                                           _loc9_ &= -2139062144;
                                                                           _loc9_ = _loc9_ ^ -2139062144;
                                                                           _loc14_ = _loc9_ & _loc14_;
                                                                           _loc13_ = _loc8_ + 4;
                                                                           _loc10_ = 0;
                                                                           if(_loc14_ != 0)
                                                                           {
                                                                              do
                                                                              {
                                                                                 _loc14_ = wdnative_nternal.L__2E_str39654 + _loc10_;
                                                                                 _loc13_ = _loc8_ + 4;
                                                                                 if(uint(_loc14_) < uint(_loc13_))
                                                                                 {
                                                                                    continue;
                                                                                 }
                                                                              }
                                                                              while(_loc7_ = _loc8_ + 4, _loc13_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc7_))
                                                                              {
                                                                                 _loc13_ = _loc7_;
                                                                              }, _loc14_ = _loc13_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str39654 + _loc14_, if((uint(_loc13_)) <= 4294967265)
                                                                              {
                                                                                 _loc13_ = -31;
                                                                              }, _loc13_ ^= -1, _loc10_ += 1, _loc10_ != 31);
                                                                              addr17f8:
                                                                              _loc2_ -= 16;
                                                                              si32(_loc13_,_loc2_ + 8);
                                                                              si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                                                                              si32(2,_loc2_);
                                                                              wdnative.ESP = _loc2_;
                                                                              wdnative_nternal.F___sys_write();
                                                                              _loc2_ += 16;
                                                                              _loc8_ = _loc11_ & -4;
                                                                              _loc9_ = li32(_loc8_);
                                                                              _loc14_ = _loc9_ + -16843009;
                                                                              _loc9_ &= -2139062144;
                                                                              _loc9_ = _loc9_ ^ -2139062144;
                                                                              _loc14_ = _loc9_ & _loc14_;
                                                                              if(_loc14_ != 0)
                                                                              {
                                                                                 _loc13_ = _loc8_ + 4;
                                                                                 _loc10_ = 0;
                                                                                 while(true)
                                                                                 {
                                                                                    _loc7_ = _loc11_ + _loc10_;
                                                                                    if((uint(_loc7_)) < uint(_loc13_))
                                                                                    {
                                                                                       _loc14_ = li8(_loc7_);
                                                                                       if(_loc14_ == 0)
                                                                                       {
                                                                                          break;
                                                                                       }
                                                                                       _loc10_ += 1;
                                                                                       continue;
                                                                                    }
                                                                                 }
                                                                                 addr1958:
                                                                                 _loc2_ -= 16;
                                                                                 si32(_loc10_,_loc2_ + 8);
                                                                                 si32(_loc11_,_loc2_ + 4);
                                                                                 si32(2,_loc2_);
                                                                                 wdnative.ESP = _loc2_;
                                                                                 wdnative_nternal.F___sys_write();
                                                                                 _loc2_ += 16;
                                                                                 _loc11_ = wdnative_nternal.L__2E_str5620 & -4;
                                                                                 _loc9_ = li32(_loc11_);
                                                                                 _loc14_ = _loc9_ + -16843009;
                                                                                 _loc9_ &= -2139062144;
                                                                                 _loc9_ = _loc9_ ^ -2139062144;
                                                                                 _loc14_ = _loc9_ & _loc14_;
                                                                                 _loc10_ = _loc11_ + 4;
                                                                                 _loc8_ = 0;
                                                                                 if(_loc14_ != 0)
                                                                                 {
                                                                                    do
                                                                                    {
                                                                                       _loc14_ = wdnative_nternal.L__2E_str5620 + _loc8_;
                                                                                       _loc10_ = _loc11_ + 4;
                                                                                       if(uint(_loc14_) < uint(_loc10_))
                                                                                       {
                                                                                          continue;
                                                                                       }
                                                                                    }
                                                                                    while(_loc13_ = _loc11_ + 4, _loc10_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc13_))
                                                                                    {
                                                                                       _loc10_ = _loc13_;
                                                                                    }, _loc14_ = _loc10_ ^ -1, _loc10_ = wdnative_nternal.L__2E_str5620 + _loc14_, if(_loc10_ != -1)
                                                                                    {
                                                                                       _loc10_ = -2;
                                                                                    }, _loc10_ ^= -1, _loc8_ += 1, _loc8_ != 2);
                                                                                    addr1af2:
                                                                                    _loc2_ -= 16;
                                                                                    si32(_loc10_,_loc2_ + 8);
                                                                                    si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                                                                                    si32(2,_loc2_);
                                                                                    wdnative.ESP = _loc2_;
                                                                                    wdnative_nternal.F___sys_write();
                                                                                    _loc2_ += 16;
                                                                                    _loc14_ = li8(wdnative_nternal._opt_abort_2E_b);
                                                                                    if(_loc14_ != 1)
                                                                                    {
                                                                                       break loop44;
                                                                                    }
                                                                                    wdnative.ESP = _loc2_;
                                                                                    wdnative_nternal.F_abort();
                                                                                    addr1b3e:
                                                                                    _loc14_ = li32(wdnative_nternal._chunksize);
                                                                                    _loc14_ = _loc14_ - _loc11_;
                                                                                    _loc2_ -= 16;
                                                                                    si32(_loc14_,_loc2_ + 4);
                                                                                    si32(_loc12_,_loc2_);
                                                                                    wdnative.ESP = _loc2_;
                                                                                    wdnative_nternal.F_munmap();
                                                                                    _loc2_ += 16;
                                                                                    _loc14_ = wdnative.eax;
                                                                                    if(_loc14_ == -1)
                                                                                    {
                                                                                       var _temp_192:* = li32(wdnative_nternal._errno);
                                                                                       _loc2_ -= 16;
                                                                                       _loc8_ = _loc3_ - 64;
                                                                                       si32(_loc8_,_loc2_ + 4);
                                                                                       si32(_temp_192,_loc2_);
                                                                                       wdnative.ESP = _loc2_;
                                                                                       wdnative_nternal.F_strerror_r();
                                                                                       _loc2_ += 16;
                                                                                       _loc10_ = li32(wdnative_nternal.___progname);
                                                                                       _loc5_ = _loc10_ & -4;
                                                                                       _loc9_ = li32(_loc5_);
                                                                                       var _temp_199:* = int(_loc9_ + -16843009);
                                                                                       _loc14_ = (_loc9_ = (_loc9_ &= -2139062144) ^ -2139062144) & _temp_199;
                                                                                       if(_loc14_ != 0)
                                                                                       {
                                                                                          _loc7_ = _loc5_ + 4;
                                                                                          while(true)
                                                                                          {
                                                                                             _loc4_ = _loc10_ + _loc13_;
                                                                                             if((uint(_loc4_)) < uint(_loc7_))
                                                                                             {
                                                                                                _loc14_ = li8(_loc4_);
                                                                                                if(_loc14_ == 0)
                                                                                                {
                                                                                                   break;
                                                                                                }
                                                                                                _loc13_ += 1;
                                                                                                continue;
                                                                                             }
                                                                                          }
                                                                                          addr1cdd:
                                                                                          _loc2_ -= 16;
                                                                                          si32(_loc13_,_loc2_ + 8);
                                                                                          si32(_loc10_,_loc2_ + 4);
                                                                                          si32(2,_loc2_);
                                                                                          wdnative.ESP = _loc2_;
                                                                                          wdnative_nternal.F___sys_write();
                                                                                          _loc2_ += 16;
                                                                                          _loc10_ = wdnative_nternal.L__2E_str39654 & -4;
                                                                                          _loc9_ = li32(_loc10_);
                                                                                          _loc14_ = _loc9_ + -16843009;
                                                                                          _loc9_ &= -2139062144;
                                                                                          _loc9_ = _loc9_ ^ -2139062144;
                                                                                          _loc14_ = _loc9_ & _loc14_;
                                                                                          _loc7_ = _loc10_ + 4;
                                                                                          _loc13_ = 0;
                                                                                          if(_loc14_ != 0)
                                                                                          {
                                                                                             do
                                                                                             {
                                                                                                _loc14_ = wdnative_nternal.L__2E_str39654 + _loc13_;
                                                                                                _loc7_ = _loc10_ + 4;
                                                                                                if(uint(_loc14_) < uint(_loc7_))
                                                                                                {
                                                                                                   continue;
                                                                                                }
                                                                                             }
                                                                                             while(_loc7_ = _loc10_ + 4, _loc4_ = wdnative_nternal.L__2E_str39654, if(uint(wdnative_nternal.L__2E_str39654) <= uint(_loc7_))
                                                                                             {
                                                                                                _loc4_ = _loc7_;
                                                                                             }, _loc14_ = _loc4_ ^ -1, _loc7_ = wdnative_nternal.L__2E_str39654 + _loc14_, if((uint(_loc7_)) <= 4294967265)
                                                                                             {
                                                                                                _loc7_ = -31;
                                                                                             }, _loc7_ ^= -1, _loc13_ += 1, _loc13_ != 31);
                                                                                             addr1e78:
                                                                                             _loc2_ -= 16;
                                                                                             si32(_loc7_,_loc2_ + 8);
                                                                                             si32(wdnative_nternal.L__2E_str39654,_loc2_ + 4);
                                                                                             si32(2,_loc2_);
                                                                                             wdnative.ESP = _loc2_;
                                                                                             wdnative_nternal.F___sys_write();
                                                                                             _loc2_ += 16;
                                                                                             _loc13_ = _loc8_ & -4;
                                                                                             _loc9_ = li32(_loc13_);
                                                                                             _loc14_ = _loc9_ + -16843009;
                                                                                             _loc9_ &= -2139062144;
                                                                                             _loc9_ = _loc9_ ^ -2139062144;
                                                                                             _loc14_ = _loc9_ & _loc14_;
                                                                                             if(_loc14_ != 0)
                                                                                             {
                                                                                                _loc10_ = _loc13_ + 4;
                                                                                                _loc4_ = 0;
                                                                                                while(true)
                                                                                                {
                                                                                                   _loc7_ = _loc8_ + _loc4_;
                                                                                                   if((uint(_loc7_)) < uint(_loc10_))
                                                                                                   {
                                                                                                      _loc14_ = li8(_loc7_);
                                                                                                      if(_loc14_ == 0)
                                                                                                      {
                                                                                                         break;
                                                                                                      }
                                                                                                      _loc4_ += 1;
                                                                                                      continue;
                                                                                                   }
                                                                                                }
                                                                                                addr1fd8:
                                                                                                _loc2_ -= 16;
                                                                                                si32(_loc4_,_loc2_ + 8);
                                                                                                si32(_loc8_,_loc2_ + 4);
                                                                                                si32(2,_loc2_);
                                                                                                wdnative.ESP = _loc2_;
                                                                                                wdnative_nternal.F___sys_write();
                                                                                                _loc2_ += 16;
                                                                                                _loc8_ = wdnative_nternal.L__2E_str5620 & -4;
                                                                                                _loc9_ = li32(_loc8_);
                                                                                                _loc14_ = _loc9_ + -16843009;
                                                                                                _loc9_ &= -2139062144;
                                                                                                _loc9_ = _loc9_ ^ -2139062144;
                                                                                                _loc14_ = _loc9_ & _loc14_;
                                                                                                _loc13_ = _loc8_ + 4;
                                                                                                _loc10_ = 0;
                                                                                                if(_loc14_ != 0)
                                                                                                {
                                                                                                   do
                                                                                                   {
                                                                                                      _loc14_ = wdnative_nternal.L__2E_str5620 + _loc10_;
                                                                                                      _loc13_ = _loc8_ + 4;
                                                                                                      if(uint(_loc14_) < uint(_loc13_))
                                                                                                      {
                                                                                                         continue;
                                                                                                      }
                                                                                                   }
                                                                                                   while(_loc13_ = _loc8_ + 4, _loc7_ = wdnative_nternal.L__2E_str5620, if(uint(wdnative_nternal.L__2E_str5620) <= uint(_loc13_))
                                                                                                   {
                                                                                                      _loc7_ = _loc13_;
                                                                                                   }, _loc14_ = _loc7_ ^ -1, _loc13_ = wdnative_nternal.L__2E_str5620 + _loc14_, if(_loc13_ != -1)
                                                                                                   {
                                                                                                      _loc13_ = -2;
                                                                                                   }, _loc13_ ^= -1, _loc10_ += 1, _loc10_ != 2);
                                                                                                   addr2172:
                                                                                                   _loc2_ -= 16;
                                                                                                   si32(_loc13_,_loc2_ + 8);
                                                                                                   si32(wdnative_nternal.L__2E_str5620,_loc2_ + 4);
                                                                                                   si32(2,_loc2_);
                                                                                                   wdnative.ESP = _loc2_;
                                                                                                   wdnative_nternal.F___sys_write();
                                                                                                   _loc2_ += 16;
                                                                                                   _loc14_ = li8(wdnative_nternal._opt_abort_2E_b);
                                                                                                   if(_loc14_ == 1)
                                                                                                   {
                                                                                                      wdnative.ESP = _loc2_;
                                                                                                      wdnative_nternal.F_abort();
                                                                                                   }
                                                                                                   addr21be:
                                                                                                   _loc14_ = _loc12_ - _loc11_;
                                                                                                   _loc9_ = li32(wdnative_nternal._chunksize);
                                                                                                   _loc12_ = _loc14_ + _loc9_;
                                                                                                   break loop44;
                                                                                                }
                                                                                                while(true)
                                                                                                {
                                                                                                   _loc8_ = li32(_loc13_);
                                                                                                   _loc14_ = _loc8_ + -16843009;
                                                                                                   _loc9_ = _loc8_ & -2139062144;
                                                                                                   _loc9_ = _loc9_ ^ -2139062144;
                                                                                                   _loc14_ = _loc9_ & _loc14_;
                                                                                                   if(_loc14_ != 0)
                                                                                                   {
                                                                                                      _loc14_ = _loc8_ & 0xFF;
                                                                                                      if(_loc14_ == 0)
                                                                                                      {
                                                                                                         _loc13_ -= wdnative_nternal.L__2E_str5620;
                                                                                                         break;
                                                                                                      }
                                                                                                      _loc14_ = li8(_loc13_ + 1);
                                                                                                      if(_loc14_ == 0)
                                                                                                      {
                                                                                                         var _temp_236:* = int(1 - wdnative_nternal.L__2E_str5620);
                                                                                                         _loc13_ += _temp_236;
                                                                                                         break;
                                                                                                      }
                                                                                                      _loc14_ = li8(_loc13_ + 2);
                                                                                                      if(_loc14_ == 0)
                                                                                                      {
                                                                                                         var _temp_238:* = int(2 - wdnative_nternal.L__2E_str5620);
                                                                                                         _loc13_ += _temp_238;
                                                                                                         break;
                                                                                                      }
                                                                                                      _loc14_ = li8(_loc13_ + 3);
                                                                                                      if(_loc14_ == 0)
                                                                                                      {
                                                                                                         var _temp_240:* = int(3 - wdnative_nternal.L__2E_str5620);
                                                                                                         _loc13_ += _temp_240;
                                                                                                         break;
                                                                                                      }
                                                                                                   }
                                                                                                   _loc13_ += 4;
                                                                                                }
                                                                                                §§goto(addr2172);
                                                                                             }
                                                                                             _loc10_ = _loc13_ + 4;
                                                                                             while(true)
                                                                                             {
                                                                                                _loc13_ = li32(_loc10_);
                                                                                                _loc14_ = _loc13_ + -16843009;
                                                                                                _loc9_ = _loc13_ & -2139062144;
                                                                                                _loc9_ = _loc9_ ^ -2139062144;
                                                                                                _loc14_ = _loc9_ & _loc14_;
                                                                                                if(_loc14_ != 0)
                                                                                                {
                                                                                                   _loc14_ = _loc13_ & 0xFF;
                                                                                                   if(_loc14_ == 0)
                                                                                                   {
                                                                                                      _loc4_ = _loc10_ - _loc8_;
                                                                                                      break;
                                                                                                   }
                                                                                                   _loc14_ = li8(_loc10_ + 1);
                                                                                                   if(_loc14_ == 0)
                                                                                                   {
                                                                                                      _loc14_ = 1 - _loc8_;
                                                                                                      _loc4_ = _loc14_ + _loc10_;
                                                                                                      break;
                                                                                                   }
                                                                                                   _loc14_ = li8(_loc10_ + 2);
                                                                                                   if(_loc14_ == 0)
                                                                                                   {
                                                                                                      _loc14_ = 2 - _loc8_;
                                                                                                      _loc4_ = _loc14_ + _loc10_;
                                                                                                      break;
                                                                                                   }
                                                                                                   _loc14_ = li8(_loc10_ + 3);
                                                                                                   if(_loc14_ == 0)
                                                                                                   {
                                                                                                      _loc14_ = 3 - _loc8_;
                                                                                                      _loc4_ = _loc14_ + _loc10_;
                                                                                                      break;
                                                                                                   }
                                                                                                }
                                                                                                _loc10_ += 4;
                                                                                             }
                                                                                             §§goto(addr1fd8);
                                                                                          }
                                                                                          while(true)
                                                                                          {
                                                                                             _loc10_ = li32(_loc7_);
                                                                                             _loc14_ = _loc10_ + -16843009;
                                                                                             _loc9_ = _loc10_ & -2139062144;
                                                                                             _loc9_ = _loc9_ ^ -2139062144;
                                                                                             _loc14_ = _loc9_ & _loc14_;
                                                                                             if(_loc14_ != 0)
                                                                                             {
                                                                                                _loc14_ = _loc10_ & 0xFF;
                                                                                                if(_loc14_ == 0)
                                                                                                {
                                                                                                   _loc7_ -= wdnative_nternal.L__2E_str39654;
                                                                                                   break;
                                                                                                }
                                                                                                _loc14_ = li8(_loc7_ + 1);
                                                                                                if(_loc14_ == 0)
                                                                                                {
                                                                                                   var _temp_258:* = int(1 - wdnative_nternal.L__2E_str39654);
                                                                                                   _loc7_ += _temp_258;
                                                                                                   break;
                                                                                                }
                                                                                                _loc14_ = li8(_loc7_ + 2);
                                                                                                if(_loc14_ == 0)
                                                                                                {
                                                                                                   var _temp_260:* = int(2 - wdnative_nternal.L__2E_str39654);
                                                                                                   _loc7_ += _temp_260;
                                                                                                   break;
                                                                                                }
                                                                                                _loc14_ = li8(_loc7_ + 3);
                                                                                                if(_loc14_ == 0)
                                                                                                {
                                                                                                   var _temp_262:* = int(3 - wdnative_nternal.L__2E_str39654);
                                                                                                   _loc7_ += _temp_262;
                                                                                                   break;
                                                                                                }
                                                                                             }
                                                                                             _loc7_ += 4;
                                                                                          }
                                                                                          §§goto(addr1e78);
                                                                                       }
                                                                                       _loc13_ = _loc5_ + 4;
                                                                                       while(true)
                                                                                       {
                                                                                          _loc7_ = li32(_loc13_);
                                                                                          _loc14_ = _loc7_ + -16843009;
                                                                                          _loc9_ = _loc7_ & -2139062144;
                                                                                          _loc9_ = _loc9_ ^ -2139062144;
                                                                                          _loc14_ = _loc9_ & _loc14_;
                                                                                          if(_loc14_ != 0)
                                                                                          {
                                                                                             _loc14_ = _loc7_ & 0xFF;
                                                                                             if(_loc14_ == 0)
                                                                                             {
                                                                                                _loc13_ -= _loc10_;
                                                                                                break;
                                                                                             }
                                                                                             _loc14_ = li8(_loc13_ + 1);
                                                                                             if(_loc14_ == 0)
                                                                                             {
                                                                                                _loc14_ = 1 - _loc10_;
                                                                                                _loc13_ = _loc14_ + _loc13_;
                                                                                                break;
                                                                                             }
                                                                                             _loc14_ = li8(_loc13_ + 2);
                                                                                             if(_loc14_ == 0)
                                                                                             {
                                                                                                _loc14_ = 2 - _loc10_;
                                                                                                _loc13_ = _loc14_ + _loc13_;
                                                                                                break;
                                                                                             }
                                                                                             _loc14_ = li8(_loc13_ + 3);
                                                                                             if(_loc14_ == 0)
                                                                                             {
                                                                                                _loc14_ = 3 - _loc10_;
                                                                                                _loc13_ = _loc14_ + _loc13_;
                                                                                                break;
                                                                                             }
                                                                                          }
                                                                                          _loc13_ += 4;
                                                                                       }
                                                                                       §§goto(addr1cdd);
                                                                                    }
                                                                                    §§goto(addr21be);
                                                                                 }
                                                                                 while(true)
                                                                                 {
                                                                                    _loc11_ = li32(_loc10_);
                                                                                    _loc14_ = _loc11_ + -16843009;
                                                                                    _loc9_ = _loc11_ & -2139062144;
                                                                                    _loc9_ = _loc9_ ^ -2139062144;
                                                                                    _loc14_ = _loc9_ & _loc14_;
                                                                                    if(_loc14_ != 0)
                                                                                    {
                                                                                       _loc14_ = _loc11_ & 0xFF;
                                                                                       if(_loc14_ == 0)
                                                                                       {
                                                                                          _loc10_ -= wdnative_nternal.L__2E_str5620;
                                                                                          break;
                                                                                       }
                                                                                       _loc14_ = li8(_loc10_ + 1);
                                                                                       if(_loc14_ == 0)
                                                                                       {
                                                                                          var _temp_280:* = int(1 - wdnative_nternal.L__2E_str5620);
                                                                                          _loc10_ += _temp_280;
                                                                                          break;
                                                                                       }
                                                                                       _loc14_ = li8(_loc10_ + 2);
                                                                                       if(_loc14_ == 0)
                                                                                       {
                                                                                          var _temp_282:* = int(2 - wdnative_nternal.L__2E_str5620);
                                                                                          _loc10_ += _temp_282;
                                                                                          break;
                                                                                       }
                                                                                       _loc14_ = li8(_loc10_ + 3);
                                                                                       if(_loc14_ == 0)
                                                                                       {
                                                                                          var _temp_284:* = int(3 - wdnative_nternal.L__2E_str5620);
                                                                                          _loc10_ += _temp_284;
                                                                                          break;
                                                                                       }
                                                                                    }
                                                                                    _loc10_ += 4;
                                                                                 }
                                                                                 §§goto(addr1af2);
                                                                              }
                                                                              _loc8_ += 4;
                                                                              while(true)
                                                                              {
                                                                                 _loc10_ = li32(_loc8_);
                                                                                 _loc14_ = _loc10_ + -16843009;
                                                                                 _loc9_ = _loc10_ & -2139062144;
                                                                                 _loc9_ = _loc9_ ^ -2139062144;
                                                                                 _loc14_ = _loc9_ & _loc14_;
                                                                                 if(_loc14_ != 0)
                                                                                 {
                                                                                    _loc14_ = _loc10_ & 0xFF;
                                                                                    if(_loc14_ == 0)
                                                                                    {
                                                                                       _loc10_ = _loc8_ - _loc11_;
                                                                                       break;
                                                                                    }
                                                                                    _loc14_ = li8(_loc8_ + 1);
                                                                                    if(_loc14_ == 0)
                                                                                    {
                                                                                       _loc14_ = 1 - _loc11_;
                                                                                       _loc10_ = _loc14_ + _loc8_;
                                                                                       break;
                                                                                    }
                                                                                    _loc14_ = li8(_loc8_ + 2);
                                                                                    if(_loc14_ == 0)
                                                                                    {
                                                                                       _loc14_ = 2 - _loc11_;
                                                                                       _loc10_ = _loc14_ + _loc8_;
                                                                                       break;
                                                                                    }
                                                                                    _loc14_ = li8(_loc8_ + 3);
                                                                                    if(_loc14_ == 0)
                                                                                    {
                                                                                       _loc14_ = 3 - _loc11_;
                                                                                       _loc10_ = _loc14_ + _loc8_;
                                                                                       break;
                                                                                    }
                                                                                 }
                                                                                 _loc8_ += 4;
                                                                              }
                                                                              §§goto(addr1958);
                                                                           }
                                                                           while(true)
                                                                           {
                                                                              _loc8_ = li32(_loc13_);
                                                                              _loc14_ = _loc8_ + -16843009;
                                                                              _loc9_ = _loc8_ & -2139062144;
                                                                              _loc9_ = _loc9_ ^ -2139062144;
                                                                              _loc14_ = _loc9_ & _loc14_;
                                                                              if(_loc14_ != 0)
                                                                              {
                                                                                 _loc14_ = _loc8_ & 0xFF;
                                                                                 if(_loc14_ == 0)
                                                                                 {
                                                                                    _loc13_ -= wdnative_nternal.L__2E_str39654;
                                                                                    break;
                                                                                 }
                                                                                 _loc14_ = li8(_loc13_ + 1);
                                                                                 if(_loc14_ == 0)
                                                                                 {
                                                                                    var _temp_302:* = int(1 - wdnative_nternal.L__2E_str39654);
                                                                                    _loc13_ += _temp_302;
                                                                                    break;
                                                                                 }
                                                                                 _loc14_ = li8(_loc13_ + 2);
                                                                                 if(_loc14_ == 0)
                                                                                 {
                                                                                    var _temp_304:* = int(2 - wdnative_nternal.L__2E_str39654);
                                                                                    _loc13_ += _temp_304;
                                                                                    break;
                                                                                 }
                                                                                 _loc14_ = li8(_loc13_ + 3);
                                                                                 if(_loc14_ == 0)
                                                                                 {
                                                                                    var _temp_306:* = int(3 - wdnative_nternal.L__2E_str39654);
                                                                                    _loc13_ += _temp_306;
                                                                                    break;
                                                                                 }
                                                                              }
                                                                              _loc13_ += 4;
                                                                           }
                                                                           §§goto(addr17f8);
                                                                        }
                                                                        _loc10_ += 4;
                                                                        while(true)
                                                                        {
                                                                           _loc13_ = li32(_loc10_);
                                                                           _loc14_ = _loc13_ + -16843009;
                                                                           _loc9_ = _loc13_ & -2139062144;
                                                                           _loc9_ = _loc9_ ^ -2139062144;
                                                                           _loc14_ = _loc9_ & _loc14_;
                                                                           if(_loc14_ != 0)
                                                                           {
                                                                              _loc14_ = _loc13_ & 0xFF;
                                                                              if(_loc14_ == 0)
                                                                              {
                                                                                 _loc13_ = _loc10_ - _loc8_;
                                                                                 break;
                                                                              }
                                                                              _loc14_ = li8(_loc10_ + 1);
                                                                              if(_loc14_ == 0)
                                                                              {
                                                                                 _loc14_ = 1 - _loc8_;
                                                                                 _loc13_ = _loc14_ + _loc10_;
                                                                                 break;
                                                                              }
                                                                              _loc14_ = li8(_loc10_ + 2);
                                                                              if(_loc14_ == 0)
                                                                              {
                                                                                 _loc14_ = 2 - _loc8_;
                                                                                 _loc13_ = _loc14_ + _loc10_;
                                                                                 break;
                                                                              }
                                                                              _loc14_ = li8(_loc10_ + 3);
                                                                              if(_loc14_ == 0)
                                                                              {
                                                                                 _loc14_ = 3 - _loc8_;
                                                                                 _loc13_ = _loc14_ + _loc10_;
                                                                                 break;
                                                                              }
                                                                           }
                                                                           _loc10_ += 4;
                                                                        }
                                                                        §§goto(addr165d);
                                                                     }
                                                                     while(true)
                                                                     {
                                                                        _loc11_ = li32(_loc10_);
                                                                        _loc14_ = _loc11_ + -16843009;
                                                                        _loc9_ = _loc11_ & -2139062144;
                                                                        _loc9_ = _loc9_ ^ -2139062144;
                                                                        _loc14_ = _loc9_ & _loc14_;
                                                                        if(_loc14_ != 0)
                                                                        {
                                                                           _loc14_ = _loc11_ & 0xFF;
                                                                           if(_loc14_ == 0)
                                                                           {
                                                                              _loc10_ -= wdnative_nternal.L__2E_str5620;
                                                                              break;
                                                                           }
                                                                           _loc14_ = li8(_loc10_ + 1);
                                                                           if(_loc14_ == 0)
                                                                           {
                                                                              var _temp_324:* = int(1 - wdnative_nternal.L__2E_str5620);
                                                                              _loc10_ += _temp_324;
                                                                              break;
                                                                           }
                                                                           _loc14_ = li8(_loc10_ + 2);
                                                                           if(_loc14_ == 0)
                                                                           {
                                                                              var _temp_326:* = int(2 - wdnative_nternal.L__2E_str5620);
                                                                              _loc10_ += _temp_326;
                                                                              break;
                                                                           }
                                                                           _loc14_ = li8(_loc10_ + 3);
                                                                           if(_loc14_ == 0)
                                                                           {
                                                                              var _temp_328:* = int(3 - wdnative_nternal.L__2E_str5620);
                                                                              _loc10_ += _temp_328;
                                                                              break;
                                                                           }
                                                                        }
                                                                        _loc10_ += 4;
                                                                     }
                                                                     §§goto(addr146f);
                                                                  }
                                                                  _loc11_ = _loc10_ + 4;
                                                                  while(true)
                                                                  {
                                                                     _loc10_ = li32(_loc11_);
                                                                     _loc14_ = _loc10_ + -16843009;
                                                                     _loc9_ = _loc10_ & -2139062144;
                                                                     _loc9_ = _loc9_ ^ -2139062144;
                                                                     _loc14_ = _loc9_ & _loc14_;
                                                                     if(_loc14_ != 0)
                                                                     {
                                                                        _loc14_ = _loc10_ & 0xFF;
                                                                        if(_loc14_ == 0)
                                                                        {
                                                                           _loc11_ -= _loc8_;
                                                                           break;
                                                                        }
                                                                        _loc14_ = li8(_loc11_ + 1);
                                                                        if(_loc14_ == 0)
                                                                        {
                                                                           _loc14_ = 1 - _loc8_;
                                                                           _loc11_ = _loc14_ + _loc11_;
                                                                           break;
                                                                        }
                                                                        _loc14_ = li8(_loc11_ + 2);
                                                                        if(_loc14_ == 0)
                                                                        {
                                                                           _loc14_ = 2 - _loc8_;
                                                                           _loc11_ = _loc14_ + _loc11_;
                                                                           break;
                                                                        }
                                                                        _loc14_ = li8(_loc11_ + 3);
                                                                        if(_loc14_ == 0)
                                                                        {
                                                                           _loc14_ = 3 - _loc8_;
                                                                           _loc11_ = _loc14_ + _loc11_;
                                                                           break;
                                                                        }
                                                                     }
                                                                     _loc11_ += 4;
                                                                  }
                                                                  §§goto(addr12d5);
                                                               }
                                                               while(true)
                                                               {
                                                                  _loc11_ = li32(_loc13_);
                                                                  _loc14_ = _loc11_ + -16843009;
                                                                  _loc9_ = _loc11_ & -2139062144;
                                                                  _loc9_ = _loc9_ ^ -2139062144;
                                                                  _loc14_ = _loc9_ & _loc14_;
                                                                  if(_loc14_ != 0)
                                                                  {
                                                                     _loc14_ = _loc11_ & 0xFF;
                                                                     if(_loc14_ == 0)
                                                                     {
                                                                        _loc13_ -= wdnative_nternal.L__2E_str39654;
                                                                        break;
                                                                     }
                                                                     _loc14_ = li8(_loc13_ + 1);
                                                                     if(_loc14_ == 0)
                                                                     {
                                                                        var _temp_346:* = int(1 - wdnative_nternal.L__2E_str39654);
                                                                        _loc13_ += _temp_346;
                                                                        break;
                                                                     }
                                                                     _loc14_ = li8(_loc13_ + 2);
                                                                     if(_loc14_ == 0)
                                                                     {
                                                                        var _temp_348:* = int(2 - wdnative_nternal.L__2E_str39654);
                                                                        _loc13_ += _temp_348;
                                                                        break;
                                                                     }
                                                                     _loc14_ = li8(_loc13_ + 3);
                                                                     if(_loc14_ == 0)
                                                                     {
                                                                        var _temp_350:* = int(3 - wdnative_nternal.L__2E_str39654);
                                                                        _loc13_ += _temp_350;
                                                                        break;
                                                                     }
                                                                  }
                                                                  _loc13_ += 4;
                                                               }
                                                               §§goto(addr1175);
                                                            }
                                                            _loc11_ = _loc4_ + 4;
                                                            while(true)
                                                            {
                                                               _loc13_ = li32(_loc11_);
                                                               _loc14_ = _loc13_ + -16843009;
                                                               _loc9_ = _loc13_ & -2139062144;
                                                               _loc9_ = _loc9_ ^ -2139062144;
                                                               _loc14_ = _loc9_ & _loc14_;
                                                               if(_loc14_ != 0)
                                                               {
                                                                  _loc14_ = _loc13_ & 0xFF;
                                                                  if(_loc14_ == 0)
                                                                  {
                                                                     _loc11_ -= _loc10_;
                                                                     break;
                                                                  }
                                                                  _loc14_ = li8(_loc11_ + 1);
                                                                  if(_loc14_ == 0)
                                                                  {
                                                                     _loc14_ = 1 - _loc10_;
                                                                     _loc11_ = _loc14_ + _loc11_;
                                                                     break;
                                                                  }
                                                                  _loc14_ = li8(_loc11_ + 2);
                                                                  if(_loc14_ == 0)
                                                                  {
                                                                     _loc14_ = 2 - _loc10_;
                                                                     _loc11_ = _loc14_ + _loc11_;
                                                                     break;
                                                                  }
                                                                  _loc14_ = li8(_loc11_ + 3);
                                                                  if(_loc14_ == 0)
                                                                  {
                                                                     _loc14_ = 3 - _loc10_;
                                                                     _loc11_ = _loc14_ + _loc11_;
                                                                     break;
                                                                  }
                                                               }
                                                               _loc11_ += 4;
                                                            }
                                                            §§goto(addr0fda);
                                                         }
                                                         while(true)
                                                         {
                                                            _loc10_ = li32(_loc7_);
                                                            _loc14_ = _loc10_ + -16843009;
                                                            _loc9_ = _loc10_ & -2139062144;
                                                            _loc9_ = _loc9_ ^ -2139062144;
                                                            _loc14_ = _loc9_ & _loc14_;
                                                            if(_loc14_ != 0)
                                                            {
                                                               _loc14_ = _loc10_ & 0xFF;
                                                               if(_loc14_ == 0)
                                                               {
                                                                  _loc7_ -= wdnative_nternal.L__2E_str5620;
                                                                  break;
                                                               }
                                                               _loc14_ = li8(_loc7_ + 1);
                                                               if(_loc14_ == 0)
                                                               {
                                                                  var _temp_368:* = int(1 - wdnative_nternal.L__2E_str5620);
                                                                  _loc7_ += _temp_368;
                                                                  break;
                                                               }
                                                               _loc14_ = li8(_loc7_ + 2);
                                                               if(_loc14_ == 0)
                                                               {
                                                                  var _temp_370:* = int(2 - wdnative_nternal.L__2E_str5620);
                                                                  _loc7_ += _temp_370;
                                                                  break;
                                                               }
                                                               _loc14_ = li8(_loc7_ + 3);
                                                               if(_loc14_ == 0)
                                                               {
                                                                  var _temp_372:* = int(3 - wdnative_nternal.L__2E_str5620);
                                                                  _loc7_ += _temp_372;
                                                                  break;
                                                               }
                                                            }
                                                            _loc7_ += 4;
                                                         }
                                                         §§goto(addr0de2);
                                                      }
                                                      _loc7_ = _loc4_ + 4;
                                                      while(true)
                                                      {
                                                         _loc13_ = li32(_loc7_);
                                                         _loc14_ = _loc13_ + -16843009;
                                                         _loc9_ = _loc13_ & -2139062144;
                                                         _loc9_ = _loc9_ ^ -2139062144;
                                                         _loc14_ = _loc9_ & _loc14_;
                                                         if(_loc14_ != 0)
                                                         {
                                                            _loc14_ = _loc13_ & 0xFF;
                                                            if(_loc14_ == 0)
                                                            {
                                                               _loc5_ = _loc7_ - _loc10_;
                                                               break;
                                                            }
                                                            _loc14_ = li8(_loc7_ + 1);
                                                            if(_loc14_ == 0)
                                                            {
                                                               _loc14_ = 1 - _loc10_;
                                                               _loc5_ = _loc14_ + _loc7_;
                                                               break;
                                                            }
                                                            _loc14_ = li8(_loc7_ + 2);
                                                            if(_loc14_ == 0)
                                                            {
                                                               _loc14_ = 2 - _loc10_;
                                                               _loc5_ = _loc14_ + _loc7_;
                                                               break;
                                                            }
                                                            _loc14_ = li8(_loc7_ + 3);
                                                            if(_loc14_ == 0)
                                                            {
                                                               _loc14_ = 3 - _loc10_;
                                                               _loc5_ = _loc14_ + _loc7_;
                                                               break;
                                                            }
                                                         }
                                                         _loc7_ += 4;
                                                      }
                                                      §§goto(addr0c48);
                                                   }
                                                   while(true)
                                                   {
                                                      _loc13_ = li32(_loc4_);
                                                      _loc14_ = _loc13_ + -16843009;
                                                      _loc9_ = _loc13_ & -2139062144;
                                                      _loc9_ = _loc9_ ^ -2139062144;
                                                      _loc14_ = _loc9_ & _loc14_;
                                                      if(_loc14_ != 0)
                                                      {
                                                         _loc14_ = _loc13_ & 0xFF;
                                                         if(_loc14_ == 0)
                                                         {
                                                            _loc4_ -= wdnative_nternal.L__2E_str39654;
                                                            break;
                                                         }
                                                         _loc14_ = li8(_loc4_ + 1);
                                                         if(_loc14_ == 0)
                                                         {
                                                            var _temp_390:* = int(1 - wdnative_nternal.L__2E_str39654);
                                                            _loc4_ += _temp_390;
                                                            break;
                                                         }
                                                         _loc14_ = li8(_loc4_ + 2);
                                                         if(_loc14_ == 0)
                                                         {
                                                            var _temp_392:* = int(2 - wdnative_nternal.L__2E_str39654);
                                                            _loc4_ += _temp_392;
                                                            break;
                                                         }
                                                         _loc14_ = li8(_loc4_ + 3);
                                                         if(_loc14_ == 0)
                                                         {
                                                            var _temp_394:* = int(3 - wdnative_nternal.L__2E_str39654);
                                                            _loc4_ += _temp_394;
                                                            break;
                                                         }
                                                      }
                                                      _loc4_ += 4;
                                                   }
                                                   §§goto(addr0ae8);
                                                }
                                                _loc7_ += 4;
                                                while(true)
                                                {
                                                   _loc4_ = li32(_loc7_);
                                                   _loc14_ = _loc4_ + -16843009;
                                                   _loc9_ = _loc4_ & -2139062144;
                                                   _loc9_ = _loc9_ ^ -2139062144;
                                                   _loc14_ = _loc9_ & _loc14_;
                                                   if(_loc14_ != 0)
                                                   {
                                                      _loc14_ = _loc4_ & 0xFF;
                                                      if(_loc14_ == 0)
                                                      {
                                                         _loc4_ = _loc7_ - _loc13_;
                                                         break;
                                                      }
                                                      _loc14_ = li8(_loc7_ + 1);
                                                      if(_loc14_ == 0)
                                                      {
                                                         _loc14_ = 1 - _loc13_;
                                                         _loc4_ = _loc14_ + _loc7_;
                                                         break;
                                                      }
                                                      _loc14_ = li8(_loc7_ + 2);
                                                      if(_loc14_ == 0)
                                                      {
                                                         _loc14_ = 2 - _loc13_;
                                                         _loc4_ = _loc14_ + _loc7_;
                                                         break;
                                                      }
                                                      _loc14_ = li8(_loc7_ + 3);
                                                      if(_loc14_ == 0)
                                                      {
                                                         _loc14_ = 3 - _loc13_;
                                                         _loc4_ = _loc14_ + _loc7_;
                                                         break;
                                                      }
                                                   }
                                                   _loc7_ += 4;
                                                }
                                                §§goto(addr094d);
                                             }
                                             §§goto(addr0e2e);
                                          }
                                          §§goto(addr14bb);
                                       }
                                       while(true)
                                       {
                                          _loc12_ = li32(_loc8_);
                                          _loc14_ = _loc12_ + -16843009;
                                          _loc9_ = _loc12_ & -2139062144;
                                          _loc9_ = _loc9_ ^ -2139062144;
                                          _loc14_ = _loc9_ & _loc14_;
                                          if(_loc14_ != 0)
                                          {
                                             _loc14_ = _loc12_ & 0xFF;
                                             if(_loc14_ == 0)
                                             {
                                                _loc8_ -= wdnative_nternal.L__2E_str5620;
                                                break;
                                             }
                                             _loc14_ = li8(_loc8_ + 1);
                                             if(_loc14_ == 0)
                                             {
                                                var _temp_412:* = int(1 - wdnative_nternal.L__2E_str5620);
                                                _loc8_ += _temp_412;
                                                break;
                                             }
                                             _loc14_ = li8(_loc8_ + 2);
                                             if(_loc14_ == 0)
                                             {
                                                var _temp_414:* = int(2 - wdnative_nternal.L__2E_str5620);
                                                _loc8_ += _temp_414;
                                                break;
                                             }
                                             _loc14_ = li8(_loc8_ + 3);
                                             if(_loc14_ == 0)
                                             {
                                                var _temp_416:* = int(3 - wdnative_nternal.L__2E_str5620);
                                                _loc8_ += _temp_416;
                                                break;
                                             }
                                          }
                                          _loc8_ += 4;
                                       }
                                       §§goto(addr0702);
                                    }
                                    _loc11_ = _loc8_ + 4;
                                    while(true)
                                    {
                                       _loc8_ = li32(_loc11_);
                                       _loc14_ = _loc8_ + -16843009;
                                       _loc9_ = _loc8_ & -2139062144;
                                       _loc9_ = _loc9_ ^ -2139062144;
                                       _loc14_ = _loc9_ & _loc14_;
                                       if(_loc14_ != 0)
                                       {
                                          _loc14_ = _loc8_ & 0xFF;
                                          if(_loc14_ == 0)
                                          {
                                             _loc11_ -= _loc12_;
                                             break;
                                          }
                                          _loc14_ = li8(_loc11_ + 1);
                                          if(_loc14_ == 0)
                                          {
                                             _loc14_ = 1 - _loc12_;
                                             _loc11_ = _loc14_ + _loc11_;
                                             break;
                                          }
                                          _loc14_ = li8(_loc11_ + 2);
                                          if(_loc14_ == 0)
                                          {
                                             _loc14_ = 2 - _loc12_;
                                             _loc11_ = _loc14_ + _loc11_;
                                             break;
                                          }
                                          _loc14_ = li8(_loc11_ + 3);
                                          if(_loc14_ == 0)
                                          {
                                             _loc14_ = 3 - _loc12_;
                                             _loc11_ = _loc14_ + _loc11_;
                                             break;
                                          }
                                       }
                                       _loc11_ += 4;
                                    }
                                    §§goto(addr0568);
                                 }
                                 while(true)
                                 {
                                    _loc11_ = li32(_loc10_);
                                    _loc14_ = _loc11_ + -16843009;
                                    _loc9_ = _loc11_ & -2139062144;
                                    _loc9_ = _loc9_ ^ -2139062144;
                                    _loc14_ = _loc9_ & _loc14_;
                                    if(_loc14_ != 0)
                                    {
                                       _loc14_ = _loc11_ & 0xFF;
                                       if(_loc14_ == 0)
                                       {
                                          _loc10_ -= wdnative_nternal.L__2E_str39654;
                                          break;
                                       }
                                       _loc14_ = li8(_loc10_ + 1);
                                       if(_loc14_ == 0)
                                       {
                                          var _temp_434:* = int(1 - wdnative_nternal.L__2E_str39654);
                                          _loc10_ += _temp_434;
                                          break;
                                       }
                                       _loc14_ = li8(_loc10_ + 2);
                                       if(_loc14_ == 0)
                                       {
                                          var _temp_436:* = int(2 - wdnative_nternal.L__2E_str39654);
                                          _loc10_ += _temp_436;
                                          break;
                                       }
                                       _loc14_ = li8(_loc10_ + 3);
                                       if(_loc14_ == 0)
                                       {
                                          var _temp_438:* = int(3 - wdnative_nternal.L__2E_str39654);
                                          _loc10_ += _temp_438;
                                          break;
                                       }
                                    }
                                    _loc10_ += 4;
                                 }
                                 §§goto(addr0408);
                              }
                              _loc8_ = _loc10_ + 4;
                              while(true)
                              {
                                 _loc10_ = li32(_loc8_);
                                 _loc14_ = _loc10_ + -16843009;
                                 _loc9_ = _loc10_ & -2139062144;
                                 _loc9_ = _loc9_ ^ -2139062144;
                                 _loc14_ = _loc9_ & _loc14_;
                                 if(_loc14_ != 0)
                                 {
                                    _loc14_ = _loc10_ & 0xFF;
                                    if(_loc14_ == 0)
                                    {
                                       _loc8_ -= _loc11_;
                                       break;
                                    }
                                    _loc14_ = li8(_loc8_ + 1);
                                    if(_loc14_ == 0)
                                    {
                                       _loc14_ = 1 - _loc11_;
                                       _loc8_ = _loc14_ + _loc8_;
                                       break;
                                    }
                                    _loc14_ = li8(_loc8_ + 2);
                                    if(_loc14_ == 0)
                                    {
                                       _loc14_ = 2 - _loc11_;
                                       _loc8_ = _loc14_ + _loc8_;
                                       break;
                                    }
                                    _loc14_ = li8(_loc8_ + 3);
                                    if(_loc14_ == 0)
                                    {
                                       _loc14_ = 3 - _loc11_;
                                       _loc8_ = _loc14_ + _loc8_;
                                       break;
                                    }
                                 }
                                 _loc8_ += 4;
                              }
                              §§goto(addr026d);
                           }
                           §§goto(addr074e);
                        }
                        §§goto(addr1b3e);
                     }
                  }
                  if(_loc12_ == 0)
                  {
                     break loop45;
                  }
               }
               break;
            }
         }
         _loc11_ = li32(_loc3_ + 4);
         _loc8_ = wdnative_nternal._dss_chunks_szad;
         _loc12_ = 0;
         _loc14_ = li8(wdnative_nternal._opt_dss_2E_b);
         if(_loc14_ == 0)
         {
            loop40:
            while(true)
            {
               _loc8_ = li32(_loc8_);
               while(true)
               {
                  _loc14_ = wdnative_nternal._dss_chunks_szad + 4;
                  _loc10_ = _loc12_;
                  if(_loc8_ == _loc14_)
                  {
                     break loop40;
                  }
                  _loc10_ = li32(_loc8_ + 20);
                  _loc13_ = _loc7_ = 1;
                  if(uint(_loc10_) <= uint(_loc1_))
                  {
                     _loc13_ = 0;
                  }
                  if(uint(_loc10_) >= uint(_loc1_))
                  {
                     _loc7_ = 0;
                  }
                  _loc9_ = _loc13_ & 1;
                  _loc14_ = _loc7_ & 1;
                  _loc13_ = _loc14_ - _loc9_;
                  if(_loc10_ == _loc1_)
                  {
                     var _temp_453:* = li32(_loc8_ + 16);
                     _loc13_ = -1;
                     if(_temp_453 == 0)
                     {
                        _loc13_ = 0;
                     }
                  }
                  if(_loc13_ <= -1)
                  {
                     break;
                  }
                  _loc10_ = _loc8_;
                  if(_loc13_ < 1)
                  {
                     break loop40;
                  }
                  _loc14_ = li32(_loc8_ + 4);
                  _loc8_ = _loc14_ & -2;
               }
               _loc12_ = _loc8_;
            }
            if(_loc10_ != 0)
            {
               _loc12_ = li32(_loc10_ + 16);
               _loc2_ -= 16;
               si32(_loc10_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_extent_tree_szad_remove();
               _loc2_ += 16;
               _loc8_ = li32(_loc10_ + 20);
               if(_loc8_ == _loc1_)
               {
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_ + 4);
                  si32(wdnative_nternal._dss_chunks_ad,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_extent_tree_ad_remove();
                  _loc2_ += 16;
                  _loc14_ = li32(wdnative_nternal._base_nodes);
                  si32(_loc14_,_loc10_);
                  si32(_loc10_,wdnative_nternal._base_nodes);
               }
               else
               {
                  _loc14_ = li32(_loc10_ + 16);
                  _loc14_ = _loc14_ + _loc1_;
                  si32(_loc14_,_loc10_ + 16);
                  _loc14_ = _loc8_ - _loc1_;
                  si32(_loc14_,_loc10_ + 20);
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_extent_tree_szad_insert();
                  _loc2_ += 16;
               }
               if(_loc11_ != 0)
               {
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_ + 8);
                  si32(0,_loc2_ + 4);
                  si32(_loc12_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.Fmemset();
                  _loc2_ += 16;
               }
               if(_loc12_ != 0)
               {
                  break;
               }
            }
            if(_loc1_ >= 0)
            {
               _loc14_ = li32(wdnative_nternal._dss_prev);
               if(_loc14_ != -1)
               {
                  while(true)
                  {
                     _loc12_ = int(ramGetLength());
                     if(_loc12_ == -1)
                     {
                        _loc2_ -= 16;
                        si32(_loc12_,_loc2_ + 8);
                        si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                        si32(wdnative_nternal.L__2E_str239,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_tprintf();
                        _loc2_ += 16;
                        si32(12,wdnative_nternal._errno);
                     }
                     si32(_loc12_,wdnative_nternal._dss_max);
                     _loc14_ = li32(wdnative_nternal._chunksize_mask);
                     _loc14_ = _loc14_ & _loc12_;
                     _loc8_ = _loc1_ - _loc14_;
                     if(_loc14_ != 0)
                     {
                        var _temp_467:* = int(_loc8_ + _loc1_);
                        _loc12_ = _loc8_ + _loc12_;
                        _loc8_ += _loc1_;
                     }
                     if(_loc8_ == 0)
                     {
                        _loc11_ = int(ramGetLength());
                     }
                     else
                     {
                        _loc14_ = _loc8_ + 4095;
                        var _temp_469:* = _loc14_ & -4096;
                        _loc11_ = int(sbrk(_temp_469,4096));
                     }
                     if(_loc11_ == -1)
                     {
                        _loc2_ -= 16;
                        si32(_loc11_,_loc2_ + 8);
                        si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                        si32(wdnative_nternal.L__2E_str239,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_tprintf();
                        _loc2_ += 16;
                        si32(12,wdnative_nternal._errno);
                     }
                     si32(_loc11_,wdnative_nternal._dss_prev);
                     _loc14_ = li32(wdnative_nternal._dss_max);
                     if(_loc11_ == _loc14_)
                     {
                        _loc14_ = _loc11_ + _loc8_;
                        si32(_loc14_,wdnative_nternal._dss_max);
                        if(_loc12_ != 0)
                        {
                           break loop43;
                        }
                     }
                     else if(_loc11_ != -1)
                     {
                        continue;
                     }
                  }
                  break;
               }
            }
         }
         _loc12_ = 0;
         break;
      }
      wdnative.eax = _loc12_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

