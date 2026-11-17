package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F___assert() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 12);
      _loc6_ = li32(_loc3_ + 8);
      _loc5_ = li32(_loc3_ + 4);
      _loc4_ = li32(_loc3_);
      if(_loc4_ == 0)
      {
         _loc2_ -= 16;
         si32(_loc6_,_loc2_ + 12);
         si32(_loc5_,_loc2_ + 8);
         si32(_loc1_,_loc2_ + 4);
         si32(wdnative_nternal.L__2E_str566,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_fprintf();
         _loc2_ += 16;
      }
      else
      {
         _loc2_ -= 32;
         si32(_loc6_,_loc2_ + 16);
         si32(_loc5_,_loc2_ + 12);
         si32(_loc4_,_loc2_ + 8);
         si32(_loc1_,_loc2_ + 4);
         si32(wdnative_nternal.L__2E_str1567,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_fprintf();
         _loc2_ += 32;
      }
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_abort();
   }
}

