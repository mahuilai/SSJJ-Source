package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_substitution() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc12_ = li32(_loc1_ + 12);
      _loc11_ = li8(_loc12_);
      var _loc10_:int = _loc12_ + 1;
      si32(_loc10_,_loc1_ + 12);
      _loc9_ = 0;
      if(_loc11_ == 83)
      {
         _loc8_ = li8(_loc12_ + 1);
         _loc9_ = _loc12_ + 2;
         si32(_loc9_,_loc1_ + 12);
         loop2:
         while(true)
         {
            if(_loc8_ != 95)
            {
               _loc10_ = _loc8_ + -48;
               _loc10_ = _loc10_ & 0xFF;
               if((uint(_loc10_)) >= 10)
               {
                  _loc10_ = _loc8_ + -65;
                  _loc10_ = _loc10_ & 0xFF;
                  if((uint(_loc10_)) > 25)
                  {
                     _loc10_ = li32(_loc1_ + 8);
                     _loc10_ = _loc10_ >>> 3;
                     _loc12_ = _loc10_ & 1;
                     if(_loc12_ == 0)
                     {
                        _loc10_ = li32(_loc3_ + 4);
                        if(_loc10_ != 0)
                        {
                           _loc10_ = li8(_loc9_);
                           _loc10_ = _loc10_ + -67;
                           _loc10_ = _loc10_ & 0xFF;
                           if((uint(_loc10_)) <= 1)
                           {
                              _loc12_ = 1;
                           }
                        }
                     }
                     _loc9_ = 0;
                     _loc6_ = 24;
                     _loc5_ = _loc9_;
                     while(true)
                     {
                        if(_loc5_ >= 196)
                        {
                           break loop2;
                        }
                        _loc7_ = wdnative_nternal._standard_subs + _loc6_;
                        _loc10_ = li8(_loc7_ - 24);
                        if(_loc10_ == _loc8_)
                        {
                           if(_loc6_ != 24)
                           {
                              _loc5_ = li32(_loc1_ + 20);
                              var _temp_18:* = li32(_loc1_ + 24);
                              _loc8_ = 0;
                              if(_loc5_ < _temp_18)
                              {
                                 _loc9_ = li32(_loc1_ + 16);
                                 _loc10_ = _loc5_ + 1;
                                 si32(_loc10_,_loc1_ + 20);
                                 _loc6_ = _loc5_ * 12;
                                 _loc5_ = _loc9_ + _loc6_;
                                 _loc8_ = 0;
                                 if(_loc5_ != 0)
                                 {
                                    var _temp_20:* = li32(_loc7_ - 4);
                                    var _loc4_:int = li32(_loc7_);
                                    _loc10_ = _loc9_ + _loc6_;
                                    si32(21,_loc10_);
                                    si32(_temp_20,_loc10_ + 4);
                                    si32(_loc4_,_loc10_ + 8);
                                    _loc8_ = _loc5_;
                                 }
                              }
                              si32(_loc8_,_loc1_ + 44);
                           }
                           _loc8_ = _loc7_ + -20;
                           _loc9_ = 0;
                           if(_loc12_ != _loc9_)
                           {
                              _loc8_ = _loc7_ + -12;
                           }
                           _loc8_ = li32(_loc8_);
                           _loc5_ = _loc7_ + -16;
                           if(_loc12_ != _loc9_)
                           {
                              _loc5_ = _loc7_ + -8;
                           }
                           _loc7_ = li32(_loc5_);
                           _loc10_ = li32(_loc1_ + 48);
                           _loc10_ = _loc10_ + _loc7_;
                           si32(_loc10_,_loc1_ + 48);
                           _loc5_ = li32(_loc1_ + 20);
                           _loc10_ = li32(_loc1_ + 24);
                           if(_loc5_ < _loc10_)
                           {
                              _loc12_ = li32(_loc1_ + 16);
                              _loc10_ = _loc5_ + 1;
                              si32(_loc10_,_loc1_ + 20);
                              _loc5_ *= 12;
                              _loc1_ = _loc12_ + _loc5_;
                              _loc9_ = 0;
                              if(_loc1_ != 0)
                              {
                                 _loc10_ = _loc12_ + _loc5_;
                                 si32(21,_loc10_);
                                 si32(_loc8_,_loc10_ + 4);
                                 si32(_loc7_,_loc10_ + 8);
                                 _loc9_ = _loc1_;
                              }
                           }
                           break loop2;
                        }
                        _loc6_ += 28;
                        _loc5_ += 28;
                     }
                     break;
                  }
               }
            }
            _loc7_ = 0;
            if(_loc8_ != 95)
            {
               _loc7_ = _loc12_ + 3;
               _loc12_ = 0;
               while(true)
               {
                  _loc10_ = _loc8_ + -48;
                  _loc10_ = _loc10_ & 0xFF;
                  if((uint(_loc10_)) <= 9)
                  {
                     _loc10_ = int(_loc12_ * 36) + ((_loc11_ = _loc8_ << 24) >> 24);
                     _loc12_ = _loc10_ + -48;
                  }
                  else
                  {
                     _loc10_ = _loc8_ + -65;
                     var _temp_29:* = _loc10_ & 0xFF;
                     _loc9_ = 0;
                     if(uint(_temp_29) > 25)
                     {
                        break loop2;
                     }
                     _loc10_ = int(_loc12_ * 36) + ((_loc11_ = _loc8_ << 24) >> 24);
                     _loc12_ = _loc10_ + -55;
                  }
                  _loc9_ = 0;
                  if(_loc12_ < 0)
                  {
                     break loop2;
                  }
                  _loc8_ = li8(_loc7_ - 1);
                  si32(_loc7_,_loc1_ + 12);
                  _loc7_ += 1;
                  if(_loc8_ != 95)
                  {
                     continue;
                  }
                  _loc7_ = _loc12_ + 1;
               }
               break;
            }
            _loc10_ = li32(_loc1_ + 32);
            _loc9_ = 0;
            if(_loc10_ > _loc7_)
            {
               _loc10_ = li32(_loc1_ + 40);
               _loc10_ = _loc10_ + 1;
               si32(_loc10_,_loc1_ + 40);
               var _temp_35:* = _loc7_ << 2;
               _loc10_ = (_loc10_ = li32(_loc1_ + 28)) + _temp_35;
               _loc9_ = li32(_loc10_);
            }
            break;
         }
      }
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

