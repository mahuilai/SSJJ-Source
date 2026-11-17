package wdnative
{
   public function ramAtomicCompareAndSwapLength(param1:int, param2:int) : int
   {
      if(wdnative.isLegacy)
      {
         return wdnative.ram.atomicCompareAndSwapLength(param1,param2);
      }
      if(param2 + 8 >= wdnative.ram.length)
      {
         wdnative.ram.length = param2 + 1048576;
      }
      var _loc3_:int = int(wdnative.ram.atomicCompareAndSwapIntAt(4,param1,param2));
      trace("v6 ramAtomicCompareAndSwapLength exp " + param1 + ", new " + param2 + ", rc " + _loc3_ + ",diff " + (param2 - param1));
      return _loc3_;
   }
}

