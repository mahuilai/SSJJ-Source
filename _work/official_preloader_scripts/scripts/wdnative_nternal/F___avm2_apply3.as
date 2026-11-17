package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.sf64;
   import avm2.intrinsics.memory.si32;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.edx;
   import wdnative.st0;
   
   public function F___avm2_apply3() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:Number = NaN;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc7_ = li32(_loc3_ + 8);
      _loc6_ = li32(_loc3_ + 12);
      wdnative.ESP = _loc2_;
      _loc1_ = CModule.callI(_loc1_,CModule.readIntVector(_loc7_,_loc6_));
      _loc7_ = wdnative.edx;
      _loc4_ = wdnative.st0;
      _loc5_ = li32(_loc3_);
      si32(_loc1_,_loc5_);
      si32(_loc7_,_loc5_ + 4);
      sf64(_loc4_,_loc5_ + 8);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

