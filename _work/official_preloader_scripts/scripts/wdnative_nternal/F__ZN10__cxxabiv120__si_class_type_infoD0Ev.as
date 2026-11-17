package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F__ZN10__cxxabiv120__si_class_type_infoD0Ev() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative_nternal.__ZTVN10__cxxabiv117__class_type_infoE + 8;
      _loc4_ = li32(_loc3_);
      si32(_loc1_,_loc4_);
      if(_loc4_ != 0)
      {
         _loc2_ -= 16;
         si32(_loc4_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_idalloc();
         _loc2_ += 16;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

