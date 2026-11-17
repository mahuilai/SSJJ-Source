package wdnative_nternal
{
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_stub_exit() : void
   {
      var _temp_1:* = this;
      var _loc1_:int = wdnative.ESP;
      var _loc2_:int = _loc1_;
      _loc1_ -= 16;
      si32(0,_loc1_);
      wdnative.ESP = _loc1_;
      wdnative_nternal.F_exit();
      _loc1_ += 16;
   }
}

