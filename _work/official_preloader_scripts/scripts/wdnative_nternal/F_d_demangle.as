package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F_d_demangle() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 96;
      _loc1_ = 0;
      _loc12_ = li32(_loc3_ + 4);
      si32(_loc1_,_loc12_);
      _loc11_ = li32(_loc3_);
      _loc10_ = _loc11_ & -4;
      _loc9_ = li32(_loc10_);
      _loc8_ = _loc9_ + -16843009;
      _loc9_ &= -2139062144;
      _loc9_ = _loc9_ ^ -2139062144;
      _loc8_ = _loc9_ & _loc8_;
      if(_loc8_ != 0)
      {
         _loc7_ = _loc10_ + 4;
         while(true)
         {
            _loc6_ = _loc11_ + _loc1_;
            if((uint(_loc6_)) < uint(_loc7_))
            {
               _loc8_ = li8(_loc6_);
               if(_loc8_ == 0)
               {
                  break;
               }
               _loc1_ += 1;
               continue;
            }
         }
         §§goto(addr016b);
      }
      _loc10_ += 4;
      while(true)
      {
         _loc1_ = li32(_loc10_);
         _loc8_ = _loc1_ + -16843009;
         _loc9_ = _loc1_ & -2139062144;
         _loc9_ = _loc9_ ^ -2139062144;
         _loc8_ = _loc9_ & _loc8_;
         if(_loc8_ != 0)
         {
            _loc8_ = _loc1_ & 0xFF;
            if(_loc8_ == 0)
            {
               _loc1_ = _loc10_ - _loc11_;
               break;
            }
            _loc8_ = li8(_loc10_ + 1);
            if(_loc8_ == 0)
            {
               _loc8_ = 1 - _loc11_;
               _loc1_ = _loc8_ + _loc10_;
               break;
            }
            _loc8_ = li8(_loc10_ + 2);
            if(_loc8_ == 0)
            {
               _loc8_ = 2 - _loc11_;
               _loc1_ = _loc8_ + _loc10_;
               break;
            }
            _loc8_ = li8(_loc10_ + 3);
            if(_loc8_ == 0)
            {
               _loc8_ = 3 - _loc11_;
               _loc1_ = _loc8_ + _loc10_;
               break;
            }
         }
         _loc10_ += 4;
      }
      addr016b:
      loop6:
      while(true)
      {
         _loc7_ = li8(_loc11_);
         if(_loc7_ == 95)
         {
            var _temp_12:* = li8(_loc11_ + 1);
            _loc7_ = 95;
            _loc6_ = 1;
            if(_temp_12 == 90)
            {
               break;
            }
         }
         _loc10_ = _loc6_ = 0;
         while(true)
         {
            _loc8_ = wdnative_nternal.L__2E_str16403 - _loc10_;
            _loc8_ = li8(_loc8_);
            _loc7_ &= 255;
            if(_loc7_ != _loc8_)
            {
               break loop6;
            }
            if(_loc7_ == 0)
            {
               break;
            }
            if(_loc10_ == -7)
            {
               break;
            }
            _loc8_ = _loc11_ - _loc10_;
            _loc7_ = li8(_loc8_ + 1);
            _loc10_ += -1;
         }
         _loc10_ = li8(_loc11_ + 8);
         if(_loc10_ != 36)
         {
            if(_loc10_ != 46)
            {
               _loc6_ = 0;
               if(_loc10_ != 95)
               {
                  break;
               }
            }
         }
         _loc7_ = li8(_loc11_ + 9);
         if(_loc7_ != 68)
         {
            _loc6_ = 0;
            if(_loc7_ != 73)
            {
               break;
            }
         }
         _loc8_ = li8(_loc11_ + 10);
         _loc6_ = 0;
         if(_loc8_ == 95)
         {
            _loc2_ -= 16;
            _loc8_ = _loc1_ + 29;
            si32(_loc8_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.F_malloc();
            _loc2_ += 16;
            _loc10_ = wdnative.eax;
            if(_loc10_ == 0)
            {
               si32(1,_loc12_);
               _loc10_ = 0;
            }
            else
            {
               if(_loc7_ == 73)
               {
                  si16(32,_loc10_ + 28);
                  si32(1869881444,_loc10_ + 24);
                  si32(1702454635,_loc10_ + 20);
                  si32(544436847,_loc10_ + 16);
                  si32(1952675186,_loc10_ + 12);
                  si32(1953721967,_loc10_ + 8);
                  si32(1663069281,_loc10_ + 4);
                  si32(1651469415,_loc10_);
                  _loc1_ = _loc10_;
               }
               else
               {
                  si8(0,_loc10_ + 28);
                  si32(544175136,_loc10_ + 24);
                  si32(1684371813,_loc10_ + 20);
                  si32(1797288818,_loc10_ + 16);
                  si32(1869898613,_loc10_ + 12);
                  si32(1920234341,_loc10_ + 8);
                  si32(1679846497,_loc10_ + 4);
                  si32(1651469415,_loc10_);
                  _loc1_ = _loc10_;
               }
               do
               {
                  _loc12_ = _loc1_ + 1;
                  _loc8_ = li8(_loc1_ + 1);
                  _loc1_ = _loc12_;
               }
               while(_loc8_ != 0);
               _loc11_ += 11;
               do
               {
                  _loc8_ = li8(_loc11_);
                  si8(_loc8_,_loc12_);
                  _loc11_ += 1;
                  _loc12_ += 1;
               }
               while(_loc8_ != 0);
            }
            §§goto(addr06e9);
         }
         break;
      }
      si32(_loc11_,_loc3_ - 88);
      _loc8_ = _loc11_ + _loc1_;
      _loc7_ = _loc3_ - 88;
      _loc9_ = _loc7_ | 4;
      si32(_loc8_,_loc9_);
      si32(17,_loc3_ - 80);
      si32(_loc11_,_loc3_ - 76);
      _loc8_ = _loc1_ << 1;
      si32(_loc8_,_loc3_ - 64);
      _loc10_ = 0;
      si32(_loc10_,_loc3_ - 68);
      si32(_loc1_,_loc3_ - 52);
      si32(_loc10_,_loc3_ - 56);
      si32(_loc10_,_loc3_ - 48);
      si32(_loc10_,_loc3_ - 44);
      si32(_loc10_,_loc3_ - 40);
      _loc11_ = _loc2_;
      _loc8_ = li32(_loc3_ - 64);
      _loc8_ = _loc8_ * 12;
      _loc8_ = _loc8_ + 15;
      _loc9_ = _loc8_ & -16;
      _loc8_ = _loc2_;
      _loc8_ = _loc8_ - _loc9_;
      _loc2_ = _loc8_ = _loc8_ & -16;
      _loc9_ = li32(_loc3_ - 52);
      _loc9_ = _loc9_ << 2;
      _loc9_ = _loc9_ + 15;
      var _loc5_:int = _loc9_ & -16;
      _loc9_ = _loc2_;
      _loc9_ = _loc9_ - _loc5_;
      _loc2_ = _loc9_ = _loc9_ & -16;
      si32(_loc8_,_loc3_ - 72);
      si32(_loc9_,_loc3_ - 60);
      if(_loc6_ == 1)
      {
         _loc4_ = li32(_loc3_ - 76);
         var _temp_41:* = li8(_loc4_);
         si32(_loc8_ = _loc4_ + 1,_loc3_ - 76);
         _loc6_ = 0;
         if(_temp_41 == 95)
         {
            var _temp_43:* = li8(_loc4_ + 1);
            si32(_loc9_ = _loc4_ + 2,_loc3_ - 76);
            _loc6_ = 0;
            if(_temp_43 == 90)
            {
               _loc2_ -= 16;
               si32(1,_loc2_ + 4);
               si32(_loc7_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_encoding();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
            }
         }
      }
      else
      {
         _loc2_ -= 16;
         si32(_loc7_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_type();
         _loc2_ += 16;
         _loc6_ = wdnative.eax;
      }
      _loc8_ = li32(_loc3_ - 76);
      _loc8_ = li8(_loc8_);
      if(_loc8_ != _loc10_)
      {
         _loc6_ = _loc10_;
      }
      if(_loc6_ != 0)
      {
         _loc8_ = li32(_loc3_ - 40);
         var _temp_50:* = int(int(_loc8_ + _loc1_) + int((_loc9_ = li32(_loc3_ - 48)) * 10));
         si32(17,_loc3_ - 32);
         _loc9_ = (_loc9_ = _temp_50 >> 31) >>> 29;
         _loc8_ = _temp_50 + ((_loc9_ = _temp_50 + _loc9_) >> 3);
         _loc8_ = _loc8_ + 1;
         si32(_loc8_,_loc3_ - 20);
         _loc2_ -= 16;
         si32(_loc8_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F_malloc();
         _loc4_ = _loc3_ - 32;
         _loc1_ = _loc4_ | 4;
         _loc2_ += 16;
         _loc8_ = wdnative.eax;
         si32(_loc8_,_loc1_);
         _loc10_ = 0;
         _loc7_ = 1;
         if(_loc8_ != 0)
         {
            _loc10_ = 0;
            si32(_loc10_,_loc3_ - 24);
            si32(_loc10_,_loc3_ - 16);
            si32(_loc10_,_loc3_ - 12);
            si32(_loc10_,_loc3_ - 8);
            _loc2_ -= 16;
            si32(_loc6_,_loc2_ + 4);
            si32(_loc4_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_print_comp();
            _loc2_ += 16;
            while(true)
            {
               _loc7_ = li32(_loc1_);
               if(_loc7_ != 0)
               {
                  _loc6_ = li32(_loc3_ - 20);
                  _loc4_ = li32(_loc3_ - 24);
                  if((uint(_loc4_)) >= uint(_loc6_))
                  {
                     _loc4_ += 1;
                     while(true)
                     {
                        if(uint(_loc6_) >= uint(_loc4_))
                        {
                           if(_loc7_ != 0)
                           {
                              var _temp_63:* = li32(_loc3_ - 24);
                              var _temp_64:* = int(_loc7_ + _temp_63);
                              si8(_loc10_,_temp_64);
                              _loc4_ = li32(_loc3_ - 24);
                              §§goto(addr06af);
                           }
                        }
                        else
                        {
                           _loc2_ -= 16;
                           si32(_loc7_,_loc2_);
                           _loc6_ <<= 1;
                           si32(_loc6_,_loc2_ + 4);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_realloc();
                           _loc2_ += 16;
                           _loc7_ = wdnative.eax;
                           if(_loc7_ != 0)
                           {
                              continue;
                           }
                           _loc6_ = li32(_loc1_);
                           if(_loc6_ != 0)
                           {
                              _loc2_ -= 16;
                              si32(_loc6_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_idalloc();
                              _loc2_ += 16;
                           }
                           si32(_loc10_,_loc1_);
                           si32(1,_loc3_ - 8);
                        }
                        si32(_loc7_,_loc1_);
                        si32(_loc6_,_loc3_ - 20);
                     }
                     break;
                  }
                  var _temp_61:* = int(_loc7_ + _loc4_);
                  si8(_loc10_,_temp_61);
                  addr06af:
                  _loc8_ = _loc4_ + 1;
                  si32(_loc8_,_loc3_ - 24);
                  _loc1_ = li32(_loc1_);
                  if(_loc1_ != 0)
                  {
                     _loc7_ = li32(_loc3_ - 20);
                     _loc10_ = _loc1_;
                     break;
                  }
               }
               _loc7_ = li32(_loc3_ - 8);
               break;
            }
         }
         si32(_loc7_,_loc12_);
      }
      _loc2_ = _loc11_;
      addr06e9:
      wdnative.eax = _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

