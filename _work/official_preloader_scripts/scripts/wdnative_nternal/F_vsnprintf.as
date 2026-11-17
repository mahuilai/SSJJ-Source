package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F_vsnprintf() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 240;
      _loc2_ -= 16;
      si32(232,_loc2_ + 8);
      _loc1_ = _loc3_ - 240;
      si32(_loc1_,_loc2_);
      si32(0,_loc2_ + 4);
      wdnative.ESP = _loc2_;
      wdnative.Fmemset();
      _loc2_ += 16;
      si16(-1,_loc3_ - 226);
      _loc10_ = li32(_loc3_ + 4);
      _loc9_ = 1;
      if(_loc10_ == 0)
      {
         _loc9_ = 0;
      }
      var _loc8_:int = _loc9_ & 1;
      _loc7_ = _loc10_ - _loc8_;
      _loc9_ = 2147483647;
      if(_loc7_ >= 0)
      {
         _loc9_ = _loc7_;
      }
      _loc6_ = _loc7_ = li32(_loc3_);
      if(_loc9_ == 0)
      {
         _loc6_ = _loc3_ - 2;
      }
      _loc5_ = _loc9_;
      if(_loc9_ == 0)
      {
         _loc5_ = 1;
      }
      if(_loc9_ == 0)
      {
         if(_loc10_ != 0)
         {
            si8(0,_loc7_);
            _loc5_ = 1;
            _loc6_ = _loc3_ - 2;
         }
      }
      var _loc4_:int = li32(_loc3_ + 12);
      _loc8_ = li32(_loc3_ + 8);
      si16(520,_loc3_ - 228);
      si32(_loc6_,_loc3_ - 240);
      si32(_loc6_,_loc3_ - 224);
      si32(_loc5_,_loc3_ - 232);
      si32(_loc5_,_loc3_ - 220);
      _loc2_ -= 16;
      si32(_loc4_,_loc2_ + 8);
      si32(_loc8_,_loc2_ + 4);
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___vfprintf();
      _loc2_ += 16;
      _loc1_ = wdnative.eax;
      if(_loc10_ != 0)
      {
         var _temp_5:* = li32(_loc3_ - 240);
         si8(0,_temp_5);
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

