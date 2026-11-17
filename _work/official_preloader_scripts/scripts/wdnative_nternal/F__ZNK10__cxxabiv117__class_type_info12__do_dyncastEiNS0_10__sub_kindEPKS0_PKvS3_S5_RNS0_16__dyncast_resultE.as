package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__ZNK10__cxxabiv117__class_type_info12__do_dyncastEiNS0_10__sub_kindEPKS0_PKvS3_S5_RNS0_16__dyncast_resultE() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc7_ = li32(_loc1_ + 4);
      _loc6_ = li32(_loc3_ + 28);
      _loc5_ = li32(_loc3_ + 16);
      _loc4_ = li32(_loc3_ + 8);
      _loc1_ = li32(_loc3_ + 24);
      while(true)
      {
         if(_loc5_ == _loc1_)
         {
            var _temp_2:* = li32(li32(_loc3_ + 20) + 4);
            if(_loc7_ == _temp_2)
            {
               si32(_loc4_,_loc6_ + 8);
               break;
            }
         }
         _loc1_ = li32(_loc3_ + 12);
         _loc1_ = li32(_loc1_ + 4);
         if(_loc7_ != _loc1_)
         {
            break;
         }
         si32(_loc5_,_loc6_);
         si32(_loc4_,_loc6_ + 4);
         si32(1,_loc6_ + 12);
         break;
      }
      wdnative.eax = 0;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

