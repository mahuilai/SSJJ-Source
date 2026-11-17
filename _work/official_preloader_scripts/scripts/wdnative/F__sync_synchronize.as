package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal._avm2_haveWorkers_2E_4258;
   
   public function F__sync_synchronize() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
      if(_loc1_ == -1)
      {
         _loc1_ = int(Boolean(workerClass));
         si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
      }
      if(_loc1_ != 0)
      {
         mfence();
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

