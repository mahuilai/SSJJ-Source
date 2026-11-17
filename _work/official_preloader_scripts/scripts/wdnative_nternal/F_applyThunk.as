package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F_applyThunk() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc6_ = li32(_loc1_ + 8);
      _loc5_ = li32(_loc1_);
      _loc4_ = li32(_loc1_ + 4);
      _loc4_ = li32(_loc4_);
      _loc2_ -= 16;
      si32(_loc4_,_loc2_ + 8);
      si32(_loc5_,_loc2_ + 4);
      _loc6_ += 3;
      _loc5_ = _loc6_ >> 31;
      _loc5_ = _loc5_ >>> 30;
      _loc6_ += _loc5_;
      _loc6_ = _loc6_ >> 2;
      si32(_loc6_,_loc2_ + 12);
      _loc6_ = _loc3_ - 16;
      si32(_loc6_,_loc2_);
      _loc5_ = wdnative_nternal.___avm2_apply3;
      wdnative.ESP = _loc2_;
      wdnative.ptr2fun[_loc5_]();
      _loc2_ += 16;
      _loc5_ = li32(_loc3_ - 4);
      si32(_loc5_,_loc1_ + 28);
      _loc5_ = li32(_loc3_ - 8);
      si32(_loc5_,_loc1_ + 24);
      _loc6_ |= 4;
      _loc6_ = li32(_loc6_);
      si32(_loc6_,_loc1_ + 20);
      _loc6_ = li32(_loc3_ - 16);
      si32(_loc6_,_loc1_ + 16);
      wdnative.eax = 0;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

