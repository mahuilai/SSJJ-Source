package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_expr_primary() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc12_:int = 0;
      var _loc5_:int = 0;
      var _loc13_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc14_ = li32(_loc1_ + 12);
      _loc13_ = li8(_loc14_);
      _loc12_ = _loc14_ + 1;
      si32(_loc12_,_loc1_ + 12);
      _loc11_ = 0;
      if(_loc13_ == 76)
      {
         _loc13_ = li8(_loc12_);
         if(_loc13_ == 95)
         {
            _loc13_ = _loc14_ + 2;
            si32(_loc13_,_loc1_ + 12);
            var _temp_7:* = li8(_loc14_ + 2);
            var _loc10_:int;
            si32(_loc10_ = _loc14_ + 3,_loc1_ + 12);
            _loc11_ = 0;
            if(_temp_7 == 90)
            {
               _loc2_ -= 16;
               si32(0,_loc2_ + 4);
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_encoding();
               _loc2_ += 16;
               _loc11_ = wdnative.eax;
            }
            addr037f:
            _loc10_ = li32(_loc1_ + 12);
            _loc13_ = li8(_loc10_);
            _loc10_ += 1;
            si32(_loc10_,_loc1_ + 12);
            if(_loc13_ != 69)
            {
               _loc11_ = 0;
            }
         }
         else
         {
            _loc2_ -= 16;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_type();
            _loc11_ = 0;
            _loc2_ += 16;
            _loc12_ = wdnative.eax;
            if(_loc12_ != 0)
            {
               _loc13_ = li32(_loc12_);
               if(_loc13_ == 33)
               {
                  _loc11_ = li32(_loc12_ + 4);
                  _loc13_ = li32(_loc11_ + 16);
                  if(_loc13_ != 0)
                  {
                     var _temp_17:* = li32(_loc11_ + 4);
                     _loc13_ = (_loc13_ = li32(_loc1_ + 48)) - _temp_17;
                     si32(_loc13_,_loc1_ + 48);
                  }
               }
               _loc9_ = li32(_loc1_ + 12);
               _loc13_ = li8(_loc9_);
               _loc14_ = 49;
               if(_loc13_ == 110)
               {
                  _loc9_ += 1;
                  si32(_loc9_,_loc1_ + 12);
                  _loc14_ = 50;
               }
               _loc8_ = 1;
               while(true)
               {
                  _loc7_ = _loc9_ + _loc8_;
                  _loc6_ = li8(_loc7_ - 1);
                  _loc11_ = 0;
                  if(_loc6_ == 0)
                  {
                     break;
                  }
                  if(_loc6_ != 69)
                  {
                     continue;
                  }
                  _loc4_ = li32(_loc1_ + 20);
                  var _temp_22:* = li32(_loc1_ + 24);
                  _loc7_ = _loc11_ = 0;
                  if(_loc4_ < _temp_22)
                  {
                     _loc6_ = li32(_loc1_ + 16);
                     _loc13_ = _loc4_ + 1;
                     si32(_loc13_,_loc1_ + 20);
                     _loc4_ *= 12;
                     _loc5_ = _loc6_ + _loc4_;
                     _loc7_ = 0;
                     if(_loc5_ != 0)
                     {
                        if(_loc9_ != 0)
                        {
                           if(_loc8_ != 1)
                           {
                              var _temp_24:* = int(_loc8_ + -1);
                              _loc10_ = _loc6_ + _loc4_;
                              si32(0,_loc10_);
                              si32(_loc9_,_loc10_ + 4);
                              si32(_temp_24,_loc10_ + 8);
                              _loc7_ = _loc5_;
                           }
                        }
                     }
                  }
                  if(_loc14_ <= 33)
                  {
                     _loc8_ = _loc14_ + -1;
                     if((uint(_loc8_)) <= 31)
                     {
                        _loc8_ = 1 << _loc8_;
                        _loc13_ = _loc8_ & -267387520;
                        if(_loc13_ == 0)
                        {
                           _loc13_ = _loc8_ & 0x0800020F;
                           if(_loc13_ == 0)
                           {
                              _loc13_ = _loc8_ & 0x07E00000;
                              if(_loc13_ != 0)
                              {
                                 addr0310:
                                 _loc9_ = li32(_loc1_ + 20);
                                 _loc13_ = li32(_loc1_ + 24);
                                 _loc11_ = 0;
                                 if(_loc9_ < _loc13_)
                                 {
                                    _loc8_ = li32(_loc1_ + 16);
                                    _loc13_ = _loc9_ + 1;
                                    si32(_loc13_,_loc1_ + 20);
                                    _loc6_ = _loc9_ * 12;
                                    _loc9_ = _loc8_ + _loc6_;
                                    _loc11_ = 0;
                                    if(_loc9_ != 0)
                                    {
                                       _loc13_ = _loc8_ + _loc6_;
                                       si32(_loc14_,_loc13_);
                                       si32(_loc12_,_loc13_ + 4);
                                       si32(_loc7_,_loc13_ + 8);
                                       _loc11_ = _loc9_;
                                    }
                                 }
                              }
                           }
                           else
                           {
                              addr02d8:
                              _loc11_ = 0;
                              if(_loc12_ != 0)
                              {
                                 if(_loc7_ != 0)
                                 {
                                    §§goto(addr0310);
                                 }
                              }
                           }
                        }
                        else
                        {
                           addr02f2:
                           _loc11_ = 0;
                           if(_loc12_ != 0)
                           {
                              §§goto(addr0310);
                           }
                        }
                     }
                  }
                  else if(_loc14_ <= 36)
                  {
                     if(_loc14_ != 34)
                     {
                        while(true)
                        {
                           if(_loc14_ != 35)
                           {
                              if(_loc14_ != 36)
                              {
                                 break;
                              }
                              _loc11_ = 0;
                              if(_loc7_ == 0)
                              {
                                 break;
                              }
                           }
                           §§goto(addr0310);
                        }
                     }
                     else
                     {
                        §§goto(addr02f2);
                     }
                  }
                  else
                  {
                     _loc8_ = _loc14_ + -37;
                     if((uint(_loc8_)) <= 13)
                     {
                        _loc8_ = 1 << _loc8_;
                        _loc13_ = _loc8_ & 0x3FC1;
                        if(_loc13_ == 0)
                        {
                           _loc13_ = _loc8_ & 0x26;
                           if(_loc13_ != 0)
                           {
                              §§goto(addr02f2);
                           }
                        }
                        else
                        {
                           §§goto(addr02d8);
                        }
                     }
                  }
                  §§goto(addr037f);
                  si32(_loc7_,_loc1_ + 12);
                  _loc8_ += 1;
               }
            }
         }
      }
      wdnative.eax = _loc11_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

