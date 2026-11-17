package wdnative
{
   public function yield(param1:int = 1) : void
   {
      if(!yieldCond)
      {
         var _loc2_:Class = new wdnative.mutexClass();
         _loc2_.lock();
         yieldCond = new wdnative.conditionClass(_loc2_);
      }
      yieldCond.wait(param1);
   }
}

