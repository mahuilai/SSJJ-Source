package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   import wdnative.edx;
   
   public function F___mult_D2A() : void
   {
      var _temp_1:* = this;
      var _loc10_:int = 0;
      var _loc20_:int = 0;
      var _loc16_:int = 0;
      var _loc14_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc24_:int = 0;
      var _loc22_:int = 0;
      var _loc1_:int = 0;
      var _loc21_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc3_:int = 0;
      var _loc23_:int = 0;
      var _loc15_:int = 0;
      var _loc4_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc17_:int = 0;
      var _loc13_:int = 0;
      var _loc2_:int = 0;
      var _loc5_:int;
      _loc10_ = _loc5_ = wdnative.ESP;
      _loc6_ = li32(_loc10_ + 4);
      _loc24_ = li32(_loc6_ + 16);
      _loc23_ = li32(_loc10_);
      _loc22_ = li32(_loc23_ + 16);
      _loc21_ = _loc6_;
      if(_loc22_ >= _loc24_)
      {
         _loc21_ = _loc23_;
      }
      _loc20_ = li32(_loc21_ + 16);
      if(_loc22_ >= _loc24_)
      {
         _loc23_ = _loc6_;
      }
      _loc6_ = li32(_loc23_ + 16);
      _loc22_ = _loc6_ + _loc20_;
      var _loc19_:int = li32(_loc21_ + 8);
      _loc24_ = 1;
      if(_loc19_ >= _loc22_)
      {
         _loc24_ = 0;
      }
      _loc19_ = _loc24_ & 1;
      var _loc18_:int = li32(_loc21_ + 4);
      while(true)
      {
         _loc16_ = _loc19_ + _loc18_;
         if(_loc16_ >= 10)
         {
            _loc1_ = 1 << _loc16_;
            _loc19_ = _loc1_ << 2;
            _loc11_ = _loc19_ + 27;
         }
         else
         {
            var _temp_9:* = _loc16_ << 2;
            _loc1_ = wdnative_nternal._freelist + _temp_9;
            _loc24_ = li32(_loc1_);
            if(_loc24_ != 0)
            {
               _loc19_ = li32(_loc24_);
               si32(_loc19_,_loc1_);
               §§goto(addr01b4);
            }
            _loc24_ = li32(wdnative_nternal._pmem_next);
            _loc19_ = _loc24_ - wdnative_nternal._private_mem;
            var _temp_38:* = _loc19_ >> 3;
            _loc1_ = 1 << _loc16_;
            _loc19_ = _loc1_ << 2;
            _loc11_ = _loc19_ + 27;
            _loc12_ = _loc11_ >>> 3;
            _loc19_ = _temp_38 + _loc12_;
            if((uint(_loc19_)) <= 288)
            {
               var _temp_40:* = _loc12_ << 3;
               _loc19_ = _loc24_ + _temp_40;
               si32(_loc19_,wdnative_nternal._pmem_next);
               break;
            }
         }
         _loc5_ -= 16;
         _loc19_ = _loc11_ & -8;
         si32(_loc19_,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative.F_malloc();
         _loc5_ += 16;
         _loc24_ = wdnative.eax;
         break;
      }
      si32(_loc16_,_loc24_ + 4);
      si32(_loc1_,_loc24_ + 8);
      addr01b4:
      si32(0,_loc24_ + 16);
      si32(0,_loc24_ + 12);
      if(_loc22_ >= 1)
      {
         var _temp_12:* = _loc22_ << 2;
         _loc19_ = _loc24_ + _temp_12;
         _loc1_ = _loc19_ + 20;
         _loc16_ = _loc24_ + 20;
         do
         {
            si32(0,_loc16_);
         }
         while(_loc16_ += 4, (uint(_loc16_)) < uint(_loc1_));
      }
      if(_loc6_ >= 1)
      {
         var _temp_15:* = _loc6_ << 2;
         _loc19_ = _loc23_ + _temp_15;
         _loc6_ = _loc19_ + 20;
         var _temp_17:* = _loc20_ << 2;
         _loc19_ = _loc21_ + _temp_17;
         _loc20_ = _loc19_ + 20;
         _loc23_ += 20;
         _loc16_ = _loc24_ + 20;
         _loc14_ = _loc21_ + 20;
         do
         {
            _loc12_ = li32(_loc23_);
            if(_loc12_ != 0)
            {
               _loc15_ = _loc16_;
               _loc4_ = _loc14_;
               _loc7_ = 0;
               _loc8_ = 0;
               do
               {
                  _loc5_ -= 16;
                  si32(_loc12_,_loc5_ + 8);
                  si32(0,_loc5_ + 4);
                  si32(0,_loc5_ + 12);
                  _loc19_ = li32(_loc4_);
                  si32(_loc19_,_loc5_);
                  wdnative.ESP = _loc5_;
                  F___muldi3();
                  _loc5_ += 16;
                  _loc1_ = wdnative.eax;
                  _loc21_ = wdnative.edx;
                  _loc11_ = _loc1_ + _loc7_;
                  _loc9_ = li32(_loc15_);
                  _loc3_ = _loc11_ + _loc9_;
                  si32(_loc3_,_loc15_);
                  _loc2_ = 1;
                  _loc17_ = _loc2_;
                  if(uint(_loc3_) >= uint(_loc11_))
                  {
                     _loc17_ = 0;
                  }
                  _loc13_ = _loc2_;
                  if(uint(_loc3_) >= uint(_loc9_))
                  {
                     _loc13_ = _loc17_;
                  }
                  _loc17_ = _loc2_;
                  if(uint(_loc11_) >= uint(_loc1_))
                  {
                     _loc17_ = 0;
                  }
                  if(uint(_loc11_) >= uint(_loc7_))
                  {
                     _loc2_ = _loc17_;
                  }
                  _loc19_ = _loc21_ + _loc8_;
                  _loc19_ = _loc19_ + _loc2_;
                  _loc7_ = _loc19_ + _loc13_;
                  _loc15_ += 4;
                  _loc4_ += 4;
                  _loc8_ = 0;
               }
               while(uint(_loc4_) < uint(_loc20_));
               si32(_loc7_,_loc15_);
            }
            _loc23_ += 4;
            _loc16_ += 4;
         }
         while(uint(_loc23_) < uint(_loc6_));
      }
      while(_loc22_ >= 1)
      {
         var _temp_27:* = _loc22_ << 2;
         _loc19_ = _loc24_ + _temp_27;
         _loc19_ = li32(_loc19_ + 16);
         if(_loc19_ != 0)
         {
            break;
         }
         _loc22_ += -1;
      }
      si32(_loc22_,_loc24_ + 16);
      wdnative.eax = _loc24_;
      wdnative.ESP = _loc5_ = _loc10_;
   }
}

