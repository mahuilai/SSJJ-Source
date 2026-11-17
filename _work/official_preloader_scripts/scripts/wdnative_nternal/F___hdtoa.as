package wdnative_nternal
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.lf64;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.sf64;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F___hdtoa() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc13_:Number = NaN;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc12_:int = 0;
      var _loc14_:int = 0;
      var _loc17_:int = 0;
      var _loc8_:int = 0;
      var _loc3_:int = 0;
      var _loc18_:int = 0;
      var _loc5_:int = 0;
      var _loc15_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc19_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 32;
      _loc13_ = lf64(_loc4_);
      sf64(_loc13_,_loc4_ - 8);
      _loc3_ = _loc4_ - 8;
      _loc3_ |= 4;
      _loc19_ = li32(_loc3_);
      _loc3_ = _loc19_ >>> 31;
      _loc18_ = li32(_loc4_ + 20);
      si32(_loc3_,_loc18_);
      _loc17_ = _loc19_ >>> 20;
      _loc15_ = _loc17_ & 0x07FF;
      _loc14_ = li32(_loc4_ + 24);
      _loc12_ = li32(_loc4_ + 16);
      _loc10_ = li32(_loc4_ + 12);
      _loc9_ = li32(_loc4_ + 8);
      _loc1_ = li32(_loc4_ - 8);
      while(true)
      {
         if(_loc15_ != 2047)
         {
            if(_loc15_ != 0)
            {
               break;
            }
            var _temp_5:* = _loc19_ & 0x0FFFFF | _loc1_;
            _loc15_ = 16;
            if(_temp_5 != 0)
            {
               _loc15_ = 8;
            }
         }
         else
         {
            var _temp_6:* = _loc19_ & 0x0FFFFF | _loc1_;
            _loc15_ = 1;
            if(_temp_6 != 0)
            {
               _loc15_ = 2;
            }
         }
         if(_loc15_ <= 7)
         {
            if(_loc15_ != 1)
            {
               if(_loc15_ == 4)
               {
                  break;
               }
               addr031f:
               si32(2147483647,_loc12_);
               _loc1_ = li32(wdnative_nternal._freelist);
               if(_loc1_ != 0)
               {
                  si32(li32(_loc1_),wdnative_nternal._freelist);
               }
               else
               {
                  _loc1_ = li32(wdnative_nternal._pmem_next);
                  if(uint(int((int(_loc1_ - wdnative_nternal._private_mem) >> 3) + 3)) <= 288)
                  {
                     si32(int(_loc1_ + 24),wdnative_nternal._pmem_next);
                  }
                  else
                  {
                     _loc2_ -= 16;
                     si32(24,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.F_malloc();
                     _loc2_ += 16;
                     _loc1_ = wdnative.eax;
                  }
                  si32(0,_loc1_ + 4);
                  si32(1,_loc1_ + 8);
               }
               si32(0,_loc1_ + 16);
               si32(0,_loc1_ + 12);
               si32(0,_loc1_);
               si8(78,_loc1_ + 4);
               si8(97,_loc1_ + 5);
               si8(78,_loc1_ + 6);
               si8(0,_loc1_ + 7);
               _loc12_ = _loc1_ + 4;
               if(_loc14_ != 0)
               {
                  si32(int(_loc1_ + 7),_loc14_);
               }
            }
            else
            {
               si32(2147483647,_loc12_);
               _loc1_ = li32(wdnative_nternal._freelist);
               if(_loc1_ != 0)
               {
                  si32(li32(_loc1_),wdnative_nternal._freelist);
               }
               else
               {
                  _loc1_ = li32(wdnative_nternal._pmem_next);
                  if(uint(int((int(_loc1_ - wdnative_nternal._private_mem) >> 3) + 3)) <= 288)
                  {
                     si32(int(_loc1_ + 24),wdnative_nternal._pmem_next);
                  }
                  else
                  {
                     _loc2_ -= 16;
                     si32(24,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.F_malloc();
                     _loc2_ += 16;
                     _loc1_ = wdnative.eax;
                  }
                  si32(0,_loc1_ + 4);
                  si32(1,_loc1_ + 8);
               }
               si32(0,_loc1_ + 16);
               si32(0,_loc1_ + 12);
               si32(0,_loc1_);
               si8(73,_loc1_ + 4);
               si8(110,_loc1_ + 5);
               si8(102,_loc1_ + 6);
               si8(105,_loc1_ + 7);
               si8(110,_loc1_ + 8);
               si8(105,_loc1_ + 9);
               si8(116,_loc1_ + 10);
               si8(121,_loc1_ + 11);
               si8(0,_loc1_ + 12);
               _loc12_ = _loc1_ + 4;
               if(_loc14_ != 0)
               {
                  si32(int(_loc1_ + 12),_loc14_);
               }
            }
         }
         else if(_loc15_ != 8)
         {
            if(_loc15_ != 16)
            {
               §§goto(addr031f);
            }
            else
            {
               si32(1,_loc12_);
               _loc1_ = li32(wdnative_nternal._freelist);
               if(_loc1_ != 0)
               {
                  si32(li32(_loc1_),wdnative_nternal._freelist);
               }
               else
               {
                  _loc1_ = li32(wdnative_nternal._pmem_next);
                  if(uint(int((int(_loc1_ - wdnative_nternal._private_mem) >> 3) + 3)) <= 288)
                  {
                     si32(int(_loc1_ + 24),wdnative_nternal._pmem_next);
                  }
                  else
                  {
                     _loc2_ -= 16;
                     si32(24,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.F_malloc();
                     _loc2_ += 16;
                     _loc1_ = wdnative.eax;
                  }
                  si32(0,_loc1_ + 4);
                  si32(1,_loc1_ + 8);
               }
               si32(0,_loc1_ + 16);
               si32(0,_loc1_ + 12);
               si32(0,_loc1_);
               si8(48,_loc1_ + 4);
               si8(0,_loc1_ + 5);
               _loc12_ = _loc1_ + 4;
               if(_loc14_ != 0)
               {
                  si32(int(_loc12_ + 1),_loc14_);
               }
            }
         }
         else
         {
            var _loc11_:Number = _loc13_ * 5.363123171977039e+154;
            sf64(_loc11_,_loc4_ - 16);
            _loc19_ = li32(int(_loc4_ - 16) | 4);
            _loc17_ = (_loc19_ >>> 20 & 0x07FF) + -1536;
            _loc1_ = li32(_loc4_ - 16);
            addr03e4:
            si32(_loc17_,_loc12_);
            _loc17_ = 1;
            _loc5_ = 0;
            if(_loc10_ != _loc5_)
            {
               _loc17_ = _loc10_;
            }
            _loc15_ = _loc17_;
            if(_loc17_ <= _loc5_)
            {
               _loc15_ = 15;
            }
            _loc10_ = 4;
            while(true)
            {
               if(uint(_loc15_) >= 20)
               {
                  do
                  {
                     _loc5_ += 1;
                     _loc10_ <<= 1;
                     _loc3_ = _loc10_ + 16;
                  }
                  while(uint(_loc3_) <= uint(_loc15_));
                  if(_loc5_ >= 10)
                  {
                     _loc6_ = 1 << _loc5_;
                     _loc7_ = (_loc6_ << 2) + 27;
                     break;
                  }
               }
               _loc3_ = _loc5_ << 2;
               _loc8_ = wdnative_nternal._freelist + _loc3_;
               _loc10_ = li32(_loc8_);
               if(_loc10_ != 0)
               {
                  si32(li32(_loc10_),_loc8_);
               }
               else
               {
                  _loc10_ = li32(wdnative_nternal._pmem_next);
                  if(uint(int((int(_loc10_ - wdnative_nternal._private_mem) >> 3) + (_loc8_ = (_loc7_ = (_loc18_ = (_loc6_ = 1 << _loc5_) << 2) + 27) >>> 3))) > 288)
                  {
                     break;
                  }
                  var _temp_21:* = _loc8_ << 3;
                  si32(int(_loc10_ + _temp_21),wdnative_nternal._pmem_next);
                  si32(_loc5_,_loc10_ + 4);
                  si32(_loc6_,_loc10_ + 8);
               }
               si32(0,_loc10_ + 16);
               si32(0,_loc10_ + 12);
               si32(_loc5_,_loc10_);
               _loc3_ = _loc17_ + -1;
               if(uint(_loc3_) <= 13)
               {
                  si32(_loc19_ & -2146435073 | (_loc18_ = (_loc18_ = _loc17_ << 22) + 1013972992) & 0x7FF00000,(_loc18_ = _loc4_ - 24) | 4);
                  si32(_loc1_,_loc4_ - 24);
                  var _temp_25:* = (_loc19_ & -2147483648) >>> 29;
                  _loc11_ = lf32(int(wdnative_nternal._one + _temp_25));
                  var _loc16_:Number = lf64(_loc4_ - 24);
                  _loc16_ = _loc16_ + _loc11_;
                  _loc11_ = _loc16_ - _loc11_;
                  sf64(_loc11_,_loc4_ - 32);
                  var _temp_31:* = li32(_loc12_);
                  var _temp_29:* = _loc17_ << 2;
                  _loc18_ = -967 - _temp_29;
                  si32(int(int(_loc18_ + _temp_31) + ((_loc18_ = (_loc19_ = li32(_loc18_ = (_loc18_ = _loc4_ - 32) | 4)) >>> 20) & 0x07FF)),_loc12_);
                  _loc1_ = li32(_loc4_ - 32);
               }
               _loc12_ = _loc10_ + 4;
               si8(49,_loc12_);
               if(_loc15_ >= 2)
               {
                  _loc15_ = _loc12_ + _loc15_;
                  _loc5_ = _loc12_ + 2;
                  if(uint(_loc15_) <= uint(_loc5_))
                  {
                     _loc15_ = _loc5_;
                  }
                  _loc3_ = _loc12_ ^ -1;
                  _loc5_ = _loc15_ + _loc3_;
                  _loc15_ = _loc10_ + 5;
                  _loc19_ &= 1048575;
                  do
                  {
                     _loc3_ = _loc19_ >>> 16;
                     _loc3_ &= 15;
                     _loc3_ = _loc9_ + _loc3_;
                     _loc3_ = li8(_loc3_);
                     si8(_loc3_,_loc15_);
                     _loc3_ = _loc1_ >>> 28;
                     _loc18_ = _loc19_ << 4;
                     _loc19_ = _loc18_ | _loc3_;
                     _loc15_ += 1;
                     _loc5_ += -1;
                     _loc1_ <<= 4;
                  }
                  while(_loc5_ != 0);
               }
               _loc1_ = 16;
               if(_loc17_ <= -1)
               {
                  do
                  {
                     _loc3_ = _loc10_ + _loc1_;
                     _loc3_ = li8(_loc3_ + 2);
                     _loc1_ += -1;
                     _loc17_ = _loc1_;
                  }
                  while(_loc3_ == 48);
               }
               _loc1_ = _loc12_ + _loc17_;
               si8(0,_loc1_);
               if(_loc14_ != 0)
               {
                  si32(_loc1_,_loc14_);
               }
            }
            _loc2_ -= 16;
            _loc3_ = _loc7_ & -8;
            si32(_loc3_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.F_malloc();
            _loc2_ += 16;
            _loc10_ = wdnative.eax;
            §§goto(addr04f4);
         }
         wdnative.eax = _loc12_;
         _loc2_ = _loc4_;
         wdnative.ESP = _loc2_;
         return;
      }
      _loc3_ = _loc17_ & 0x07FF;
      _loc17_ = _loc3_ + -1022;
      §§goto(addr03e4);
   }
}

