package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__ZNK10__cxxabiv117__class_type_info10__do_catchEPKSt9type_infoPPvj() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc1_ + 4);
      _loc7_ = li32(_loc3_);
      _loc6_ = li32(_loc7_ + 4);
      _loc5_ = 1;
      if(_loc6_ != _loc8_)
      {
         var _temp_3:* = li32(_loc3_ + 12);
         _loc5_ = 0;
         if(uint(_temp_3) <= 3)
         {
            var _temp_5:* = li32(_loc3_ + 8);
            var _loc4_:int = li32((_loc8_ = li32(_loc1_)) + 20);
            _loc2_ -= 16;
            si32(_temp_5,_loc2_ + 8);
            si32(_loc7_,_loc2_ + 4);
            si32(_loc1_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.ptr2fun[_loc4_]();
            _loc2_ += 16;
            _loc5_ = wdnative.eax;
         }
      }
      wdnative.eax = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

