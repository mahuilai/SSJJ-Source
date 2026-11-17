package wdnative
{
   public function threadArbMutexLock() : void
   {
      if(!threadArbLockDepth++)
      {
         wdnative.threadArbMutex.lock();
      }
   }
}

