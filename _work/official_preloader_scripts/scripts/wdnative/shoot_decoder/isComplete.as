package wdnative.shoot_decoder
{
   import wdnative.ESP;
   
   public function isComplete() : Boolean
   {
      var _loc4_:* = undefined;
      var _loc3_:int = 0;
      var _loc2_:Boolean = false;
      var _loc1_:int = wdnative.ESP;
      _loc3_ = _loc1_;
      _loc2_ = Boolean(0);
      _loc4_ = _loc2_;
      _loc1_ = _loc3_;
      wdnative.ESP = _loc1_;
      return _loc4_;
   }
}

