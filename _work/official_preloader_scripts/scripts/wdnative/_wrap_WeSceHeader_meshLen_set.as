package wdnative
{
   import avm2.intrinsics.memory.si32;
   
   public function _wrap_WeSceHeader_meshLen_set(param1:*, param2:int) : void
   {
      var _loc5_:int = 0;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:int;
      _loc5_ = _loc4_ = wdnative.ESP;
      _loc3_ = param1;
      _loc7_ = param2;
      if(_loc3_ != 0)
      {
         si32(_loc7_,_loc3_ + 84);
      }
      var _loc6_:* = undefined;
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc6_;
   }
}

