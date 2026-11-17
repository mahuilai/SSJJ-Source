package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   
   public function F__ZN20WeLittleEndianReader7readIntEv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc10_ = li32(_loc1_ + 44);
      _loc9_ = li32(_loc1_ + 48);
      if(_loc9_ >= _loc10_)
      {
         si32(1,_loc1_ + 4);
         si32(1,_loc1_ + 8);
         _loc8_ = 0;
      }
      else
      {
         var _loc7_:int = li32(_loc1_ + 36);
         _loc7_ = _loc7_ + _loc9_;
         _loc8_ = li8(_loc7_);
         _loc9_ += 1;
         si32(_loc9_,_loc1_ + 48);
      }
      if(_loc9_ >= _loc10_)
      {
         si32(1,_loc1_ + 4);
         si32(1,_loc1_ + 8);
         _loc6_ = 0;
      }
      else
      {
         _loc7_ = li32(_loc1_ + 36);
         _loc7_ = _loc7_ + _loc9_;
         var _temp_9:* = li8(_loc7_);
         si32(_loc9_ += 1,_loc1_ + 48);
         _loc6_ = _temp_9 << 8;
      }
      if(_loc9_ >= _loc10_)
      {
         si32(1,_loc1_ + 4);
         si32(1,_loc1_ + 8);
         _loc5_ = 0;
      }
      else
      {
         _loc7_ = li32(_loc1_ + 36);
         _loc7_ = _loc7_ + _loc9_;
         var _temp_13:* = li8(_loc7_);
         si32(_loc9_ += 1,_loc1_ + 48);
         _loc5_ = _temp_13 << 16;
      }
      if(_loc9_ >= _loc10_)
      {
         si32(1,_loc1_ + 4);
         si32(1,_loc1_ + 8);
         _loc10_ = 0;
      }
      else
      {
         _loc7_ = li32(_loc1_ + 36);
         _loc7_ = _loc7_ + _loc9_;
         var _temp_17:* = li8(_loc7_);
         var _loc4_:int;
         si32(_loc4_ = _loc9_ + 1,_loc1_ + 48);
         _loc10_ = _temp_17 << 24;
      }
      _loc7_ = _loc6_ | _loc8_;
      _loc7_ = _loc7_ | _loc5_;
      wdnative.eax = _loc7_ = _loc7_ | _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

