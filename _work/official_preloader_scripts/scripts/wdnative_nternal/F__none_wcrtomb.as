package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__none_wcrtomb() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 1;
      _loc4_ = li32(_loc3_);
      if(_loc4_ != 0)
      {
         _loc1_ = li32(_loc3_ + 4);
         if(uint(_loc1_) >= 256)
         {
            si32(86,wdnative_nternal._errno);
            _loc1_ = -1;
         }
         else
         {
            si8(_loc1_,_loc4_);
            _loc1_ = 1;
         }
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

