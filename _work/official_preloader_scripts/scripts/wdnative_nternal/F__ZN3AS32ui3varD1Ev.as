package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F__ZN3AS32ui3varD1Ev() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc1_ = li32(_loc1_);
      _loc2_ -= 16;
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F__ZN3AS32ui3var8internal7releaseEj();
      _loc2_ += 16;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

