package wdnative_nternal
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi16;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__ZL28read_encoded_value_with_basehjPKhPj() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 12);
      _loc12_ = li32(_loc3_ + 8);
      _loc11_ = li32(_loc3_);
      if(_loc11_ == 80)
      {
         var _loc10_:int = _loc12_ + 3;
         _loc10_ = _loc10_ & -4;
         _loc9_ = _loc10_ + 4;
         _loc8_ = li32(_loc10_);
      }
      else
      {
         _loc7_ = li32(_loc3_ + 4);
         _loc6_ = _loc11_ & 0x0F;
         _loc8_ = 0;
         loop2:
         while(true)
         {
            while(true)
            {
               if(_loc6_ <= 3)
               {
                  if(_loc6_ <= 1)
                  {
                     if(_loc6_ != 0)
                     {
                        _loc9_ = _loc12_;
                        _loc5_ = _loc8_;
                        if(_loc6_ != 1)
                        {
                           addr0218:
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_abort();
                        }
                        else
                        {
                           do
                           {
                              _loc10_ = si8(li8(_loc9_));
                              var _loc4_:int = _loc10_ & 0x7F;
                              _loc4_ = _loc4_ << _loc8_;
                              _loc5_ = _loc4_ | _loc5_;
                              _loc8_ += 7;
                              _loc9_ += 1;
                           }
                           while(_loc10_ < 0);
                        }
                     }
                     else
                     {
                        _loc9_ = _loc12_ + 4;
                        _loc5_ = li32(_loc12_);
                     }
                  }
                  else if(_loc6_ != 2)
                  {
                     if(_loc6_ != 3)
                     {
                        §§goto(addr0218);
                     }
                     else
                     {
                        _loc9_ = _loc12_ + 4;
                        _loc5_ = li32(_loc12_);
                     }
                  }
                  else
                  {
                     _loc9_ = _loc12_ + 2;
                     _loc5_ = li16(_loc12_);
                  }
               }
               else if(_loc6_ <= 9)
               {
                  if(_loc6_ != 4)
                  {
                     _loc9_ = _loc12_;
                     _loc5_ = _loc8_;
                     if(_loc6_ != 9)
                     {
                        §§goto(addr0218);
                     }
                     else
                     {
                        do
                        {
                           _loc10_ = si8(li8(_loc9_));
                           _loc4_ = _loc10_ & 0x7F;
                           _loc4_ = _loc4_ << _loc8_;
                           _loc5_ = _loc4_ | _loc5_;
                           _loc8_ += 7;
                           _loc9_ += 1;
                           _loc6_ = _loc10_ & 0xFF;
                        }
                        while(_loc10_ < 0);
                        if(uint(_loc8_) <= 31)
                        {
                           _loc10_ = _loc6_ & 0x40;
                           if(_loc10_ != 0)
                           {
                              var _temp_13:* = -1 << _loc8_;
                              _loc5_ |= _temp_13;
                              break;
                           }
                        }
                     }
                  }
                  else
                  {
                     _loc9_ = _loc12_ + 8;
                     _loc5_ = li32(_loc12_);
                  }
               }
               else if(_loc6_ != 10)
               {
                  if(_loc6_ != 11)
                  {
                     if(_loc6_ != 12)
                     {
                        §§goto(addr0218);
                     }
                     else
                     {
                        _loc9_ = _loc12_ + 8;
                        _loc5_ = li32(_loc12_);
                     }
                  }
                  else
                  {
                     _loc9_ = _loc12_ + 4;
                     _loc5_ = li32(_loc12_);
                  }
               }
               else
               {
                  _loc9_ = _loc12_ + 2;
                  _loc5_ = si16(li16(_loc12_));
               }
               _loc8_ = 0;
               if(_loc5_ != 0)
               {
                  break;
               }
               break loop2;
            }
            _loc10_ = _loc11_ & 0x70;
            if(_loc10_ == 16)
            {
               _loc7_ = _loc12_;
            }
            _loc8_ = _loc7_ + _loc5_;
            _loc10_ = _loc11_ << 24;
            _loc10_ = _loc10_ >> 24;
            if(_loc10_ <= -1)
            {
               _loc8_ = li32(_loc8_);
            }
            break;
         }
      }
      break loop2;
   }
}

