package wdnative_nternal
{
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F__ZSt9terminatev() : void
   {
      var _temp_1:* = this;
      var _loc1_:int = wdnative.ESP;
      var _loc2_:int = _loc1_;
      _loc1_ -= 16;
      si32(wdnative_nternal.__ZN9__gnu_cxx27__verbose_terminate_handlerEv,_loc1_);
      wdnative.ESP = _loc1_;
      wdnative_nternal.F__ZN10__cxxabiv111__terminateEPFvvE();
      _loc1_ += 16;
   }
}

