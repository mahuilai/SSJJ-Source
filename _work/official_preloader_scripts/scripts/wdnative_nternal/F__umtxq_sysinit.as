package wdnative_nternal
{
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   
   public function F__umtxq_sysinit() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 0;
      do
      {
         _loc2_ -= 16;
         si32(16,_loc2_ + 12);
         si32(0,_loc2_ + 8);
         si32(wdnative_nternal.L__2E_str8606,_loc2_ + 4);
         var _loc6_:int = wdnative_nternal._umtxq_chains + _loc1_;
         si32(_loc6_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_kmtx_init();
         _loc2_ += 16;
         si32(0,_loc6_ + 20);
         var _loc5_:int = _loc6_ + 20;
         si32(_loc5_,_loc6_ + 24);
         si32(0,_loc6_ + 28);
         _loc5_ = _loc6_ + 28;
         si32(_loc5_,_loc6_ + 32);
         si8(0,_loc6_ + 36);
         si32(0,_loc6_ + 40);
         _loc1_ += 44;
         _loc4_ = 0;
      }
      while(_loc1_ != 5632);
      do
      {
         _loc2_ -= 16;
         si32(16,_loc2_ + 12);
         si32(0,_loc2_ + 8);
         si32(wdnative_nternal.L__2E_str8606,_loc2_ + 4);
         _loc6_ = wdnative_nternal._umtxq_chains + _loc4_;
         _loc5_ = _loc6_ + 5632;
         si32(_loc5_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_kmtx_init();
         _loc2_ += 16;
         si32(0,_loc6_ + 5652);
         _loc5_ = _loc6_ + 5652;
         si32(_loc5_,_loc6_ + 5656);
         si32(0,_loc6_ + 5660);
         _loc5_ = _loc6_ + 5660;
         si32(_loc5_,_loc6_ + 5664);
         si8(0,_loc6_ + 5668);
         si32(0,_loc6_ + 5672);
      }
      while(_loc4_ += 44, _loc4_ != 5632);
      _loc2_ -= 16;
      si32(1,_loc2_ + 12);
      si32(0,_loc2_ + 8);
      si32(wdnative_nternal.L__2E_str9607,_loc2_ + 4);
      si32(wdnative_nternal._umtx_lock,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_kmtx_init();
      _loc2_ += 16;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

