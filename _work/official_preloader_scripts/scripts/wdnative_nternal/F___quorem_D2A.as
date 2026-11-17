package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   
   public function F___quorem_D2A() : void
   {
      var _temp_1:* = this;
      var _loc10_:int = 0;
      var _loc6_:int = 0;
      var _loc22_:int = 0;
      var _loc3_:int = 0;
      var _loc23_:int = 0;
      var _loc12_:int = 0;
      var _loc24_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:int = 0;
      var _loc4_:int = 0;
      var _loc17_:int = 0;
      var _loc13_:int = 0;
      var _loc2_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc20_:int = 0;
      var _loc21_:int = 0;
      var _loc5_:int;
      _loc10_ = _loc5_ = wdnative.ESP;
      _loc6_ = li32(_loc10_);
      _loc24_ = li32(_loc6_ + 16);
      _loc23_ = li32(_loc10_ + 4);
      _loc22_ = li32(_loc23_ + 16);
      _loc21_ = 0;
      if(_loc24_ >= _loc22_)
      {
         _loc20_ = _loc22_ + -1;
         var _loc19_:int = _loc20_ << 2;
         var _loc18_:int = _loc6_ + _loc19_;
         var _temp_10:* = li32(_loc18_ + 20);
         var _loc16_:int = (_loc16_ = li32((_loc19_ = _loc23_ + _loc19_) + 20)) + 1;
         _loc21_ = uint(_temp_10) / uint(_loc16_);
         _loc1_ = _loc19_ + 20;
         if(_loc21_ != 0)
         {
            _loc11_ = _loc6_ + 20;
            _loc12_ = _loc23_ + 20;
            _loc24_ = 0;
            _loc14_ = 0;
            _loc15_ = 0;
            _loc4_ = 0;
            do
            {
               _loc5_ -= 16;
               si32(_loc21_,_loc5_ + 8);
               si32(0,_loc5_ + 4);
               si32(0,_loc5_ + 12);
               _loc18_ = li32(_loc12_);
               si32(_loc18_,_loc5_);
               wdnative.ESP = _loc5_;
               F___muldi3();
               _loc5_ += 16;
               _loc18_ = wdnative.eax;
               _loc7_ = wdnative.edx;
               _loc8_ = _loc18_ + _loc15_;
               _loc9_ = li32(_loc11_);
               _loc3_ = _loc9_ - _loc8_;
               _loc19_ = _loc3_ - _loc24_;
               si32(_loc19_,_loc11_);
               _loc2_ = 1;
               _loc17_ = _loc2_;
               if(uint(_loc8_) >= uint(_loc18_))
               {
                  _loc17_ = 0;
               }
               _loc13_ = _loc2_;
               if(uint(_loc8_) >= uint(_loc15_))
               {
                  _loc13_ = _loc17_;
               }
               _loc17_ = _loc2_;
               if(uint(_loc3_) >= uint(_loc24_))
               {
                  _loc17_ = 0;
               }
               if(uint(_loc9_) >= uint(_loc8_))
               {
                  _loc2_ = 0;
               }
               _loc18_ = _loc7_ + _loc4_;
               _loc15_ = _loc18_ + _loc13_;
               _loc18_ = 0 - _loc2_;
               _loc18_ = _loc18_ - _loc14_;
               _loc18_ = _loc18_ - _loc17_;
               _loc24_ = _loc18_ & 1;
               _loc11_ += 4;
               _loc12_ += 4;
               _loc14_ = 0;
               _loc4_ = 0;
            }
            while(uint(_loc12_) <= uint(_loc1_));
            _loc24_ = _loc22_ << 2;
            _loc18_ = _loc6_ + _loc24_;
            _loc18_ = li32(_loc18_ + 16);
            if(_loc18_ != 0)
            {
               _loc24_ = li32(_loc6_ + 16);
            }
            else
            {
               _loc20_ = _loc6_ + 20;
               _loc18_ = _loc24_ + _loc6_;
               _loc3_ = _loc18_ + 12;
               _loc24_ = _loc22_ + -1;
               while(uint(_loc3_) > uint(_loc20_))
               {
                  _loc18_ = li32(_loc3_);
                  if(_loc18_ != 0)
                  {
                     break;
                  }
                  _loc24_ += -1;
                  _loc3_ += -4;
               }
               si32(_loc24_,_loc6_ + 16);
               _loc20_ = _loc24_;
            }
         }
         _loc22_ = li32(_loc23_ + 16);
         if(_loc24_ != _loc22_)
         {
            _loc3_ = _loc24_ - _loc22_;
         }
         else
         {
            _loc19_ = _loc22_ << 2;
            _loc18_ = _loc19_ + _loc6_;
            _loc8_ = _loc18_ + 20;
            _loc18_ = _loc19_ + _loc23_;
            _loc9_ = _loc18_ + 16;
            _loc3_ = _loc6_ + 20;
            do
            {
               _loc24_ = li32(_loc9_);
               _loc22_ = li32(_loc8_ - 4);
               if(_loc22_ == _loc24_)
               {
                  continue;
               }
               _loc3_ = -1;
               if(uint(_loc22_) >= uint(_loc24_))
               {
                  _loc3_ = 1;
               }
            }
            while(_loc8_ += -4, _loc9_ += -4, uint(_loc8_) > uint(_loc3_));
            §§goto(addr0301);
         }
         if(_loc3_ >= 0)
         {
            addr0301:
            _loc22_ = _loc6_ + 20;
            _loc9_ = _loc23_ + 20;
            _loc8_ = 0;
            _loc7_ = 0;
            _loc13_ = 0;
            _loc2_ = 0;
            do
            {
               _loc18_ = li32(_loc9_);
               _loc23_ = _loc18_ + _loc13_;
               _loc24_ = li32(_loc22_);
               _loc3_ = _loc24_ - _loc23_;
               _loc19_ = _loc3_ - _loc8_;
               si32(_loc19_,_loc22_);
               _loc11_ = _loc14_ = 1;
               if(uint(_loc23_) >= uint(_loc18_))
               {
                  _loc11_ = 0;
               }
               _loc12_ = _loc14_;
               if(uint(_loc23_) >= uint(_loc13_))
               {
                  _loc12_ = _loc11_;
               }
               _loc11_ = _loc14_;
               if(uint(_loc3_) >= uint(_loc8_))
               {
                  _loc11_ = 0;
               }
               if(uint(_loc24_) >= uint(_loc23_))
               {
                  _loc14_ = 0;
               }
               _loc13_ = _loc2_ + _loc12_;
               _loc18_ = 0 - _loc14_;
               _loc18_ = _loc18_ - _loc7_;
               _loc18_ = _loc18_ - _loc11_;
               _loc8_ = _loc18_ & 1;
               _loc22_ += 4;
               _loc9_ += 4;
               _loc7_ = 0;
               _loc2_ = 0;
            }
            while(uint(_loc9_) <= uint(_loc1_));
            _loc1_ = _loc20_ << 2;
            _loc22_ = _loc6_ + 20;
            _loc18_ = _loc22_ + _loc1_;
            var _temp_36:* = li32(_loc18_);
            _loc21_ += 1;
            if(_temp_36 == 0)
            {
               _loc23_ = _loc6_ + 16;
               while(true)
               {
                  _loc18_ = _loc23_ + _loc1_;
                  if((uint(_loc18_)) <= uint(_loc22_))
                  {
                     break;
                  }
                  var _temp_41:* = _loc20_ << 2;
                  _loc18_ = _loc23_ + _temp_41;
                  _loc18_ = li32(_loc18_);
                  if(_loc18_ != 0)
                  {
                     break;
                  }
                  _loc1_ += -4;
                  _loc20_ += -1;
               }
               si32(_loc20_,_loc6_ + 16);
            }
            §§goto(addr0444);
         }
      }
      addr0444:
      wdnative.eax = _loc21_;
      wdnative.ESP = _loc5_ = _loc10_;
   }
}

