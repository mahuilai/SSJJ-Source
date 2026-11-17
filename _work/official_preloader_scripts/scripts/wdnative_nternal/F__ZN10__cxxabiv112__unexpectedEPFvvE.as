package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.ptr2fun;
   
   public function F__ZN10__cxxabiv112__unexpectedEPFvvE() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      wdnative.ESP = _loc2_;
      wdnative.ptr2fun[_loc1_]();
      wdnative.ESP = _loc2_;
      wdnative_nternal.F__ZSt9terminatev();
   }
}

