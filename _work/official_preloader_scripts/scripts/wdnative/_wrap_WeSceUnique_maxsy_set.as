package wdnative
{
   import avm2.intrinsics.memory.sf32;
   
   public function _wrap_WeSceUnique_maxsy_set(param1:*, param2:Number) : void
   {
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc3_:Number = NaN;
      var _loc5_:int;
      _loc6_ = _loc5_ = wdnative.ESP;
      _loc4_ = param1;
      _loc3_ = param2;
      if(_loc4_ != 0)
      {
         sf32(_loc3_,_loc4_ + 16);
      }
      var _loc7_:* = undefined;
      wdnative.ESP = _loc5_ = _loc6_;
      return _loc7_;
   }
}

