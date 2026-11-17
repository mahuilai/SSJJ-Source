package wdnative
{
   import avm2.intrinsics.memory.li32;
   
   public function _wrap_WeVertexExt_index_get(param1:*) : int
   {
      var _loc6_:* = undefined;
      var _loc5_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      var _loc4_:int;
      _loc5_ = _loc4_ = wdnative.ESP;
      _loc3_ = param1;
      _loc3_ = li32(_loc3_);
      _loc2_ = _loc3_;
      _loc6_ = _loc2_;
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc6_;
   }
}

