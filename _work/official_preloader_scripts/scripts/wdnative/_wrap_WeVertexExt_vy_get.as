package wdnative
{
   import avm2.intrinsics.memory.lf32;
   
   public function _wrap_WeVertexExt_vy_get(param1:*) : Number
   {
      var _loc7_:* = undefined;
      var _loc6_:int = 0;
      var _loc2_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc5_:int;
      _loc6_ = _loc5_ = wdnative.ESP;
      var _loc4_:int = param1;
      _loc3_ = lf32(_loc4_ + 8);
      _loc2_ = _loc3_;
      _loc7_ = _loc2_;
      wdnative.ESP = _loc5_ = _loc6_;
      return _loc7_;
   }
}

