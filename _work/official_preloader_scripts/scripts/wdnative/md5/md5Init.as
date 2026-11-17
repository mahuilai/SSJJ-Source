package wdnative.md5
{
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function md5Init(param1:int) : void
   {
      var _loc5_:* = undefined;
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc4_ = _loc3_;
      _loc2_ = param1;
      si32(0,_loc2_ + 12);
      si32(0,_loc2_ + 16);
      si32(1732584193,_loc2_ + 20);
      si32(-271733879,_loc2_ + 24);
      si32(-1732584194,_loc2_ + 28);
      si32(271733878,_loc2_ + 32);
      _loc3_ = _loc4_;
      wdnative.ESP = _loc3_;
      return _loc5_;
   }
}

