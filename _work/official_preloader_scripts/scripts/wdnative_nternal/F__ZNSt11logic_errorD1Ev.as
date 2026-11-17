package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F__ZNSt11logic_errorD1Ev() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative_nternal.__ZTVSt11logic_error + 8;
      _loc7_ = li32(_loc3_);
      si32(_loc1_,_loc7_);
      _loc6_ = li32(_loc7_ + 4);
      _loc5_ = _loc6_ + -12;
      if(_loc5_ != wdnative_nternal.__ZNSs4_Rep20_S_empty_rep_storageE)
      {
         var _temp_6:* = li32(_loc6_ - 4);
         var _loc4_:int;
         si32(_loc4_ = (_loc4_ = li32(_loc6_ - 4)) + -1,_loc6_ - 4);
         if(_temp_6 <= 0)
         {
            if(_loc5_ != 0)
            {
               _loc2_ -= 16;
               si32(_loc5_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_idalloc();
               _loc2_ += 16;
            }
         }
      }
      _loc1_ = wdnative_nternal.__ZTVSt9exception + 8;
      si32(_loc1_,_loc7_);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

