package wdnative
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.sf32;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.L__2E_str662;
   import wdnative_nternal.__ZZ12getSceUniquePvP11WeSceUniqueE8__func__;
   
   public function _wrap_getSceUnique(param1:int, param2:int) : Boolean
   {
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int;
      _loc7_ = _loc6_ = wdnative.ESP;
      _loc5_ = param1;
      _loc11_ = param2;
      if(_loc11_ == 0)
      {
         _loc6_ -= 16;
         si32(wdnative_nternal.L__2E_str662,_loc6_ + 12);
         si32(65,_loc6_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc6_ + 4);
         si32(wdnative_nternal.__ZZ12getSceUniquePvP11WeSceUniqueE8__func__,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F___assert();
         _loc6_ += 16;
      }
      var _loc10_:int = li8(_loc5_ + 36);
      _loc10_ = _loc10_ & 0x20;
      _loc8_ = 0;
      if(_loc10_ != 0)
      {
         var _loc4_:Number = lf32(_loc5_ + 564);
         sf32(_loc4_,_loc11_);
         _loc4_ = lf32(_loc5_ + 568);
         sf32(_loc4_,_loc11_ + 4);
         _loc4_ = lf32(_loc5_ + 572);
         sf32(_loc4_,_loc11_ + 8);
         _loc4_ = lf32(_loc5_ + 576);
         sf32(_loc4_,_loc11_ + 12);
         _loc4_ = lf32(_loc5_ + 580);
         sf32(_loc4_,_loc11_ + 16);
         _loc4_ = lf32(_loc5_ + 584);
         sf32(_loc4_,_loc11_ + 20);
         _loc10_ = li32(_loc5_ + 588);
         si32(_loc10_,_loc11_ + 24);
         _loc8_ = 1;
      }
      var _loc3_:Boolean = Boolean(_loc8_);
      var _loc9_:Boolean = _loc3_;
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc9_;
   }
}

