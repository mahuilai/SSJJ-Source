package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.throwWhenOutOfMemory;
   
   public function F_avm2_casRamLength() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
      if(_loc1_ == -1)
      {
         _loc1_ = int(Boolean(workerClass));
         si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
      }
      _loc5_ = li32(_loc3_ + 4);
      _loc4_ = li32(_loc3_);
      if(_loc1_ != 0)
      {
         try
         {
            _loc4_ = int(ramAtomicCompareAndSwapLength(_loc4_,_loc5_));
         }
         catch(e:*)
         {
            var _temp_2:* = this;
            var _temp_3:* = e;
            if(throwWhenOutOfMemory)
            {
               throw e;
            }
            _loc4_ = -1;
         }
      }
      else
      {
         _loc4_ = int(ramGetLength());
         if(_loc4_ == _loc4_)
         {
            try
            {
               ramSetLength(_loc5_);
            }
            catch(e:*)
            {
               var _temp_6:* = this;
               var _temp_7:* = e;
               if(throwWhenOutOfMemory)
               {
                  throw e;
               }
               _loc4_ = -1;
            }
         }
      }
      wdnative.eax = _loc4_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

