package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_expression() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      loop2:
      while(true)
      {
         _loc12_ = li32(_loc1_ + 12);
         _loc11_ = li8(_loc12_);
         if(_loc11_ != 115)
         {
            if(_loc11_ == 84)
            {
               _loc10_ = _loc12_ + 1;
               si32(_loc10_,_loc1_ + 12);
               _loc9_ = li8(_loc12_ + 1);
               _loc11_ = 0;
               while(true)
               {
                  if(_loc9_ != 110)
                  {
                     _loc8_ = _loc11_;
                     if(_loc9_ == 95)
                     {
                        var _loc7_:int = _loc12_ + 2;
                        si32(_loc7_,_loc1_ + 12);
                        _loc8_ = 0;
                        break;
                     }
                  }
                  else
                  {
                     _loc10_ = _loc12_ + 2;
                     si32(_loc10_,_loc1_ + 12);
                     _loc9_ = li8(_loc12_ + 2);
                     _loc8_ = 1;
                  }
                  _loc7_ = _loc9_ + -48;
                  _loc7_ = _loc7_ & 0xFF;
                  _loc12_ = _loc11_;
                  if(uint(_loc7_) <= 9)
                  {
                     do
                     {
                        _loc7_ = _loc10_ + 1;
                        si32(_loc7_,_loc1_ + 12);
                        var _loc6_:int = _loc12_ * 10;
                        var _loc5_:int = _loc9_ << 24;
                        _loc5_ = _loc5_ >> 24;
                        _loc6_ += _loc5_;
                        _loc12_ = _loc6_ + -48;
                        _loc9_ = li8(_loc10_ + 1);
                        _loc6_ = _loc9_ + -48;
                        _loc6_ = _loc6_ & 0xFF;
                        _loc10_ = _loc7_;
                     }
                     while(uint(_loc6_) < 10);
                  }
                  if(_loc8_ != _loc11_)
                  {
                     _loc12_ = 0 - _loc12_;
                  }
                  if(_loc12_ >= 0)
                  {
                     _loc7_ = _loc10_ + 1;
                     si32(_loc7_,_loc1_ + 12);
                     _loc8_ = _loc12_ + 1;
                     var _temp_15:* = _loc9_ & 0xFF;
                     _loc11_ = 0;
                     if(_temp_15 == 95)
                     {
                        break;
                     }
                  }
                  break loop2;
               }
               _loc7_ = li32(_loc1_ + 40);
               _loc7_ = _loc7_ + 1;
               si32(_loc7_,_loc1_ + 40);
               _loc10_ = li32(_loc1_ + 20);
               _loc7_ = li32(_loc1_ + 24);
               _loc11_ = 0;
               if(_loc10_ < _loc7_)
               {
                  _loc9_ = li32(_loc1_ + 16);
                  _loc7_ = _loc10_ + 1;
                  si32(_loc7_,_loc1_ + 20);
                  _loc10_ *= 12;
                  _loc1_ = _loc9_ + _loc10_;
                  _loc11_ = 0;
                  if(_loc1_ != 0)
                  {
                     _loc7_ = _loc9_ + _loc10_;
                     si32(5,_loc7_);
                     si32(_loc8_,_loc7_ + 4);
                     _loc11_ = _loc1_;
                  }
               }
               break;
            }
            if(_loc11_ == 76)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_expr_primary();
               _loc2_ += 16;
               _loc11_ = wdnative.eax;
               break;
            }
         }
         else
         {
            _loc7_ = li8(_loc12_ + 1);
            if(_loc7_ == 114)
            {
               _loc7_ = _loc12_ + 2;
               si32(_loc7_,_loc1_ + 12);
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_type();
               _loc2_ += 16;
               _loc8_ = wdnative.eax;
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_unqualified_name();
               _loc2_ += 16;
               _loc9_ = wdnative.eax;
               _loc7_ = li32(_loc1_ + 12);
               _loc7_ = li8(_loc7_);
               if(_loc7_ != 73)
               {
                  _loc11_ = 0;
                  if(_loc8_ != 0)
                  {
                     if(_loc9_ != 0)
                     {
                        _loc12_ = li32(_loc1_ + 20);
                        var _temp_25:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc12_ < _temp_25)
                        {
                           _loc10_ = li32(_loc1_ + 16);
                           _loc7_ = _loc12_ + 1;
                           si32(_loc7_,_loc1_ + 20);
                           _loc1_ = _loc12_ * 12;
                           _loc12_ = _loc10_ + _loc1_;
                           _loc11_ = 0;
                           if(_loc12_ != 0)
                           {
                              _loc7_ = _loc10_ + _loc1_;
                              si32(1,_loc7_);
                              si32(_loc8_,_loc7_ + 4);
                              si32(_loc9_,_loc7_ + 8);
                              _loc11_ = _loc12_;
                           }
                        }
                     }
                  }
                  break;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_template_args();
               _loc11_ = 0;
               _loc2_ += 16;
               _loc12_ = wdnative.eax;
               if(_loc9_ != 0)
               {
                  if(_loc12_ != 0)
                  {
                     _loc10_ = li32(_loc1_ + 20);
                     var _temp_28:* = li32(_loc1_ + 24);
                     _loc11_ = 0;
                     if(_loc10_ < _temp_28)
                     {
                        var _temp_30:* = li32(_loc1_ + 16);
                        si32(_loc6_ = _loc10_ + 1,_loc1_ + 20);
                        _loc10_ = _temp_30 + int(_loc10_ * 12);
                        _loc11_ = 0;
                        if(_loc10_ != 0)
                        {
                           si32(4,_loc10_);
                           si32(_loc9_,_loc10_ + 4);
                           si32(_loc12_,_loc10_ + 8);
                           _loc11_ = 0;
                           if(_loc8_ != 0)
                           {
                              _loc12_ = li32(_loc1_ + 20);
                              var _temp_31:* = li32(_loc1_ + 24);
                              _loc11_ = 0;
                              if(_loc12_ < _temp_31)
                              {
                                 _loc9_ = li32(_loc1_ + 16);
                                 _loc7_ = _loc12_ + 1;
                                 si32(_loc7_,_loc1_ + 20);
                                 _loc1_ = _loc12_ * 12;
                                 _loc12_ = _loc9_ + _loc1_;
                                 _loc11_ = 0;
                                 if(_loc12_ != 0)
                                 {
                                    _loc7_ = _loc9_ + _loc1_;
                                    si32(1,_loc7_);
                                    si32(_loc8_,_loc7_ + 4);
                                    si32(_loc10_,_loc7_ + 8);
                                    _loc11_ = _loc12_;
                                 }
                              }
                           }
                        }
                     }
                  }
               }
               break;
            }
         }
         _loc2_ -= 16;
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_operator_name();
         _loc11_ = 0;
         _loc2_ += 16;
         _loc8_ = wdnative.eax;
         if(_loc8_ != 0)
         {
            loop4:
            while(true)
            {
               loop5:
               while(true)
               {
                  loop6:
                  while(true)
                  {
                     _loc9_ = li32(_loc8_);
                     if(_loc9_ == 40)
                     {
                        _loc7_ = li32(_loc1_ + 48) + li32((_loc6_ = li32(_loc8_ + 4)) + 8);
                        _loc7_ = _loc7_ + -2;
                        si32(_loc7_,_loc1_ + 48);
                        _loc9_ = li32(_loc8_);
                        if(_loc9_ == 40)
                        {
                           _loc9_ = li32(_loc8_ + 4);
                           _loc10_ = li32(_loc9_);
                           _loc12_ = wdnative_nternal.L__2E_str18405;
                           while(true)
                           {
                              _loc11_ = li8(_loc10_);
                              _loc7_ = li8(_loc12_);
                              if(_loc11_ != _loc7_)
                              {
                                 break loop6;
                              }
                              _loc12_ += 1;
                              _loc10_ += 1;
                              if(_loc11_ == 0)
                              {
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_d_type();
                                 _loc11_ = 0;
                                 _loc2_ += 16;
                                 _loc10_ = wdnative.eax;
                                 if(_loc8_ != 0)
                                 {
                                    if(_loc10_ != 0)
                                    {
                                       _loc12_ = li32(_loc1_ + 20);
                                       var _temp_67:* = li32(_loc1_ + 24);
                                       _loc11_ = 0;
                                       if(_loc12_ < _temp_67)
                                       {
                                          _loc9_ = li32(_loc1_ + 16);
                                          _loc7_ = _loc12_ + 1;
                                          si32(_loc7_,_loc1_ + 20);
                                          _loc12_ *= 12;
                                          _loc1_ = _loc9_ + _loc12_;
                                          _loc11_ = 0;
                                          if(_loc1_ != 0)
                                          {
                                             _loc7_ = _loc9_ + _loc12_;
                                             si32(43,_loc7_);
                                             si32(_loc8_,_loc7_ + 4);
                                             si32(_loc10_,_loc7_ + 8);
                                             _loc11_ = _loc1_;
                                          }
                                       }
                                    }
                                 }
                                 break loop2;
                              }
                           }
                           break loop2;
                        }
                     }
                     if(_loc9_ != 42)
                     {
                        if(_loc9_ != 41)
                        {
                           _loc11_ = 0;
                           if(_loc9_ == 40)
                           {
                              _loc9_ = li32(_loc8_ + 4);
                              break;
                           }
                           break loop2;
                        }
                        _loc11_ = _loc8_ + 4;
                        break loop5;
                     }
                     break loop4;
                  }
                  _loc11_ = _loc9_ + 12;
                  break;
               }
               _loc9_ = li32(_loc11_);
               if(_loc9_ != 3)
               {
                  if(_loc9_ != 2)
                  {
                     _loc11_ = 0;
                     if(_loc9_ == 1)
                     {
                        break;
                     }
                     break loop2;
                  }
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_expression();
                  _loc2_ += 16;
                  _loc10_ = wdnative.eax;
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_expression();
                  _loc11_ = 0;
                  _loc2_ += 16;
                  _loc12_ = wdnative.eax;
                  if(_loc10_ != 0)
                  {
                     if(_loc12_ != 0)
                     {
                        _loc9_ = li32(_loc1_ + 20);
                        var _temp_42:* = li32(_loc1_ + 24);
                        _loc11_ = 0;
                        if(_loc9_ < _temp_42)
                        {
                           var _temp_44:* = li32(_loc1_ + 16);
                           si32(_loc6_ = _loc9_ + 1,_loc1_ + 20);
                           _loc9_ = _temp_44 + int(_loc9_ * 12);
                           _loc11_ = 0;
                           if(_loc9_ != 0)
                           {
                              si32(45,_loc9_);
                              si32(_loc10_,_loc9_ + 4);
                              si32(_loc12_,_loc9_ + 8);
                              _loc11_ = 0;
                              if(_loc8_ != 0)
                              {
                                 _loc12_ = li32(_loc1_ + 20);
                                 var _temp_45:* = li32(_loc1_ + 24);
                                 _loc11_ = 0;
                                 if(_loc12_ < _temp_45)
                                 {
                                    _loc10_ = li32(_loc1_ + 16);
                                    _loc7_ = _loc12_ + 1;
                                    si32(_loc7_,_loc1_ + 20);
                                    _loc12_ *= 12;
                                    _loc1_ = _loc10_ + _loc12_;
                                    _loc11_ = 0;
                                    if(_loc1_ != 0)
                                    {
                                       _loc7_ = _loc10_ + _loc12_;
                                       si32(44,_loc7_);
                                       si32(_loc8_,_loc7_ + 4);
                                       si32(_loc9_,_loc7_ + 8);
                                       _loc11_ = _loc1_;
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
                  break loop2;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_expression();
               _loc2_ += 16;
               _loc9_ = wdnative.eax;
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_expression();
               _loc2_ += 16;
               _loc4_ = wdnative.eax;
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_expression();
               _loc11_ = 0;
               _loc2_ += 16;
               _loc10_ = wdnative.eax;
               if(_loc4_ != 0)
               {
                  if(_loc10_ != 0)
                  {
                     _loc12_ = li32(_loc1_ + 20);
                     var _temp_50:* = li32(_loc1_ + 24);
                     _loc11_ = 0;
                     if(_loc12_ < _temp_50)
                     {
                        var _temp_52:* = li32(_loc1_ + 16);
                        si32(_loc6_ = _loc12_ + 1,_loc1_ + 20);
                        _loc12_ = _temp_52 + int(_loc12_ * 12);
                        _loc11_ = 0;
                        if(_loc12_ != 0)
                        {
                           si32(48,_loc12_);
                           si32(_loc4_,_loc12_ + 4);
                           si32(_loc10_,_loc12_ + 8);
                           _loc11_ = 0;
                           if(_loc9_ != 0)
                           {
                              _loc10_ = li32(_loc1_ + 20);
                              var _temp_53:* = li32(_loc1_ + 24);
                              _loc11_ = 0;
                              if(_loc10_ < _temp_53)
                              {
                                 var _temp_55:* = li32(_loc1_ + 16);
                                 si32(_loc6_ = _loc10_ + 1,_loc1_ + 20);
                                 _loc10_ = _temp_55 + int(_loc10_ * 12);
                                 _loc11_ = 0;
                                 if(_loc10_ != 0)
                                 {
                                    si32(47,_loc10_);
                                    si32(_loc9_,_loc10_ + 4);
                                    si32(_loc12_,_loc10_ + 8);
                                    _loc11_ = 0;
                                    if(_loc8_ != 0)
                                    {
                                       _loc12_ = li32(_loc1_ + 20);
                                       var _temp_56:* = li32(_loc1_ + 24);
                                       _loc11_ = 0;
                                       if(_loc12_ < _temp_56)
                                       {
                                          _loc9_ = li32(_loc1_ + 16);
                                          _loc7_ = _loc12_ + 1;
                                          si32(_loc7_,_loc1_ + 20);
                                          _loc1_ = _loc12_ * 12;
                                          _loc12_ = _loc9_ + _loc1_;
                                          _loc11_ = 0;
                                          if(_loc12_ != 0)
                                          {
                                             _loc7_ = _loc9_ + _loc1_;
                                             si32(46,_loc7_);
                                             si32(_loc8_,_loc7_ + 4);
                                             si32(_loc10_,_loc7_ + 8);
                                             _loc11_ = _loc12_;
                                          }
                                       }
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
               break loop2;
            }
            _loc2_ -= 16;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_expression();
            _loc11_ = 0;
            _loc2_ += 16;
            _loc9_ = wdnative.eax;
            if(_loc8_ != 0)
            {
               if(_loc9_ != 0)
               {
                  _loc12_ = li32(_loc1_ + 20);
                  var _temp_37:* = li32(_loc1_ + 24);
                  _loc11_ = 0;
                  if(_loc12_ < _temp_37)
                  {
                     _loc10_ = li32(_loc1_ + 16);
                     _loc7_ = _loc12_ + 1;
                     si32(_loc7_,_loc1_ + 20);
                     _loc12_ *= 12;
                     _loc1_ = _loc10_ + _loc12_;
                     _loc11_ = 0;
                     if(_loc1_ != 0)
                     {
                        _loc7_ = _loc10_ + _loc12_;
                        si32(43,_loc7_);
                        si32(_loc8_,_loc7_ + 4);
                        si32(_loc9_,_loc7_ + 8);
                        _loc11_ = _loc1_;
                     }
                  }
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

