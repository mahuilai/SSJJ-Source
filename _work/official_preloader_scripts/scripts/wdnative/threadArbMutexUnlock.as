package wdnative
{
   public function threadArbMutexUnlock() : void
   {
      if(!--threadArbLockDepth)
      {
         wdnative.threadArbMutex.unlock();
      }
   }
}

