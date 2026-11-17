package wdnative
{
   public function _wrap_MAX_MESHNAME_LEN_get() : int
   {
      var _loc4_:* = undefined;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 128;
      _loc4_ = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
      return _loc4_;
   }
}

