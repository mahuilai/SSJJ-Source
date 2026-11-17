package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_unqualified_name() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc10_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc11_ = li32(_loc1_ + 12);
      _loc10_ = li8(_loc11_);
      var _loc9_:int = _loc10_ + -48;
      _loc9_ = _loc9_ & 0xFF;
      if((uint(_loc9_)) <= 9)
      {
         _loc2_ -= 16;
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_source_name();
         _loc2_ += 16;
         _loc10_ = wdnative.eax;
      }
      else
      {
         _loc9_ = _loc10_ + -97;
         _loc9_ = _loc9_ & 0xFF;
         if((uint(_loc9_)) <= 25)
         {
            _loc2_ -= 16;
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_operator_name();
            _loc10_ = 0;
            _loc2_ += 16;
            _loc8_ = wdnative.eax;
            if(_loc8_ != 0)
            {
               var _temp_11:* = li32(_loc8_);
               _loc10_ = _loc8_;
               if(_temp_11 == 40)
               {
                  var _loc7_:int;
                  _loc9_ = li32(_loc1_ + 48) + li32((_loc7_ = li32(_loc8_ + 4)) + 8);
                  _loc9_ = _loc9_ + 7;
                  si32(_loc9_,_loc1_ + 48);
                  _loc10_ = _loc8_;
               }
            }
         }
         else
         {
            _loc9_ = _loc10_ + -67;
            _loc9_ = _loc9_ & 0xFF;
            if((uint(_loc9_)) <= 1)
            {
               _loc8_ = li32(_loc1_ + 44);
               if(_loc8_ != 0)
               {
                  _loc10_ = li32(_loc8_);
                  if(_loc10_ != 21)
                  {
                     if(_loc10_ == 0)
                     {
                        var _temp_20:* = li32(_loc1_ + 48);
                        _loc9_ = (_loc9_ = li32(_loc8_ + 8)) + _temp_20;
                        si32(_loc9_,_loc1_ + 48);
                     }
                  }
                  else
                  {
                     var _temp_23:* = li32(_loc1_ + 48);
                     _loc9_ = (_loc9_ = li32(_loc8_ + 8)) + _temp_23;
                     si32(_loc9_,_loc1_ + 48);
                  }
               }
               _loc6_ = si8(li8(_loc11_));
               _loc9_ = _loc11_ + 1;
               si32(_loc9_,_loc1_ + 12);
               if(_loc6_ != 68)
               {
                  _loc10_ = 0;
                  if(_loc6_ == 67)
                  {
                     _loc6_ = si8(li8(_loc11_ + 1));
                     _loc9_ = _loc11_ + 2;
                     si32(_loc9_,_loc1_ + 12);
                     _loc11_ = 1;
                     while(true)
                     {
                        if(_loc6_ != 49)
                        {
                           if(_loc6_ != 51)
                           {
                              _loc10_ = 0;
                              if(_loc6_ != 50)
                              {
                                 break;
                              }
                              _loc11_ = 2;
                           }
                           else
                           {
                              _loc11_ = 3;
                           }
                        }
                        _loc5_ = li32(_loc1_ + 20);
                        _loc9_ = li32(_loc1_ + 24);
                        _loc10_ = 0;
                        if(_loc5_ < _loc9_)
                        {
                           _loc6_ = li32(_loc1_ + 16);
                           _loc9_ = _loc5_ + 1;
                           si32(_loc9_,_loc1_ + 20);
                           _loc5_ *= 12;
                           _loc1_ = _loc6_ + _loc5_;
                           _loc10_ = 0;
                           if(_loc1_ != 0)
                           {
                              if(_loc8_ != 0)
                              {
                                 _loc9_ = _loc6_ + _loc5_;
                                 si32(6,_loc9_);
                                 si32(_loc11_,_loc9_ + 4);
                                 si32(_loc8_,_loc9_ + 8);
                                 _loc10_ = _loc1_;
                              }
                           }
                        }
                        break;
                     }
                  }
               }
               else
               {
                  _loc6_ = si8(li8(_loc11_ + 1));
                  _loc9_ = _loc11_ + 2;
                  si32(_loc9_,_loc1_ + 12);
                  _loc11_ = 1;
                  while(true)
                  {
                     if(_loc6_ != 48)
                     {
                        if(_loc6_ != 50)
                        {
                           _loc10_ = 0;
                           if(_loc6_ != 49)
                           {
                              break;
                           }
                           _loc11_ = 2;
                        }
                        else
                        {
                           _loc11_ = 3;
                        }
                     }
                     _loc5_ = li32(_loc1_ + 20);
                     _loc9_ = li32(_loc1_ + 24);
                     _loc10_ = 0;
                     if(_loc5_ < _loc9_)
                     {
                        _loc6_ = li32(_loc1_ + 16);
                        _loc9_ = _loc5_ + 1;
                        si32(_loc9_,_loc1_ + 20);
                        _loc1_ = _loc5_ * 12;
                        _loc5_ = _loc6_ + _loc1_;
                        _loc10_ = 0;
                        if(_loc5_ != 0)
                        {
                           if(_loc8_ != 0)
                           {
                              _loc9_ = _loc6_ + _loc1_;
                              si32(7,_loc9_);
                              si32(_loc11_,_loc9_ + 4);
                              si32(_loc8_,_loc9_ + 8);
                              _loc10_ = _loc5_;
                           }
                        }
                     }
                     break;
                  }
               }
            }
            else
            {
               var _temp_30:* = _loc10_ & 0xFF;
               _loc10_ = 0;
               if(_temp_30 == 76)
               {
                  _loc9_ = _loc11_ + 1;
                  si32(_loc9_,_loc1_ + 12);
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_source_name();
                  _loc10_ = 0;
                  _loc2_ += 16;
                  _loc11_ = wdnative.eax;
                  if(_loc11_ != 0)
                  {
                     _loc4_ = li32(_loc1_ + 12);
                     var _temp_35:* = li8(_loc4_);
                     _loc10_ = _loc11_;
                     if(_temp_35 == 95)
                     {
                        _loc5_ = _loc4_ + 1;
                        si32(_loc5_,_loc1_ + 12);
                        _loc8_ = li8(_loc4_ + 1);
                        _loc6_ = _loc10_ = 0;
                        if(_loc8_ == 110)
                        {
                           _loc5_ = _loc4_ + 2;
                           si32(_loc5_,_loc1_ + 12);
                           _loc8_ = li8(_loc4_ + 2);
                           _loc6_ = 1;
                        }
                        _loc9_ = _loc8_ + -48;
                        _loc9_ = _loc9_ & 0xFF;
                        _loc4_ = _loc10_;
                        if(uint(_loc9_) <= 9)
                        {
                           _loc5_ += 1;
                           _loc4_ = 0;
                           do
                           {
                              si32(_loc5_,_loc1_ + 12);
                              _loc9_ = _loc4_ * 10;
                              _loc7_ = _loc8_ << 24;
                              _loc7_ = _loc7_ >> 24;
                              _loc9_ += _loc7_;
                              _loc4_ = _loc9_ + -48;
                              _loc9_ = _loc5_ + 1;
                              _loc8_ = li8(_loc5_);
                              _loc7_ = _loc8_ + -48;
                              _loc7_ = _loc7_ & 0xFF;
                              _loc5_ = _loc9_;
                           }
                           while(uint(_loc7_) < 10);
                        }
                        if(_loc6_ != _loc10_)
                        {
                           _loc4_ = 0 - _loc4_;
                        }
                        if(_loc4_ >= _loc10_)
                        {
                           _loc10_ = _loc11_;
                        }
                     }
                  }
               }
            }
         }
      }
      wdnative.eax = _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

