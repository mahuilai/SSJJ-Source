package wdnative
{
   public function sbrk(param1:int, param2:int) : int
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc5_:int = wdnative.ramGetLength();
      var _loc3_:int = _loc5_ + param2 - 1 & -param2;
      var _loc6_:int = _loc3_ + param1;
      if(wdnative.workerClass)
      {
         while(true)
         {
            try
            {
               _loc4_ = wdnative.ramAtomicCompareAndSwapLength(_loc5_,_loc6_);
            }
            catch(e:*)
            {
               var _temp_3:* = this;
               var _temp_4:* = e;
               if(wdnative.throwWhenOutOfMemory)
               {
                  throw e;
               }
               return -1;
            }
            if(_loc4_ == _loc5_)
            {
               break;
            }
            _loc5_ = _loc4_;
            _loc3_ = _loc5_ + param2 - 1 & -param2;
            _loc6_ = _loc3_ + param1;
         }
      }
      else
      {
         try
         {
            wdnative.ramSetLength(_loc6_);
         }
         catch(e:*)
         {
            var _temp_7:* = this;
            var _temp_8:* = e;
            if(wdnative.throwWhenOutOfMemory)
            {
               throw e;
            }
            return -1;
         }
      }
      return _loc3_;
   }
}

