package wdnative
{
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.L__2E_str965;
   import wdnative_nternal.__ZZ12getSceHeaderPvP11WeSceHeaderE8__func__;
   
   public function _wrap_getSceHeader(param1:int, param2:int) : Boolean
   {
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int;
      _loc6_ = _loc5_ = wdnative.ESP;
      _loc4_ = param1;
      _loc9_ = param2;
      if(_loc9_ == 0)
      {
         _loc5_ -= 16;
         si32(wdnative_nternal.L__2E_str965,_loc5_ + 12);
         si32(42,_loc5_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc5_ + 4);
         si32(wdnative_nternal.__ZZ12getSceHeaderPvP11WeSceHeaderE8__func__,_loc5_);
         wdnative.ESP = _loc5_;
         wdnative_nternal.F___assert();
         _loc5_ += 16;
      }
      _loc5_ -= 16;
      si32(124,_loc5_ + 8);
      si32(_loc9_,_loc5_);
      var _loc8_:int = _loc4_ + 92;
      si32(_loc8_,_loc5_ + 4);
      wdnative.ESP = _loc5_;
      wdnative.Fmemcpy();
      _loc5_ += 16;
      var _loc3_:Boolean = Boolean(1);
      var _loc7_:Boolean = _loc3_;
      wdnative.ESP = _loc5_ = _loc6_;
      return _loc7_;
   }
}

