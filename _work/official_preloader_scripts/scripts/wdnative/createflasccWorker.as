package wdnative
{
   public function createflasccWorker() : *
   {
      if(!wdnative.workerSWFBytes)
      {
         wdnative.workerSWFBytes = retargetSWF();
      }
      return workerDomainClass["current"].createWorker(wdnative.workerSWFBytes);
   }
}

