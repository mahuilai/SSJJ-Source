package wdnative
{
   import flash.utils.ByteArray;
   
   public function newThread(param1:int, param2:int, param3:int, param4:Vector.<int>) : *
   {
      var _loc9_:int = 0;
      trace("CRun::newThread: " + arguments);
      var _loc7_:* = createflasccWorker();
      _loc7_.setSharedProperty("flascc.threadId",param1);
      _loc7_.setSharedProperty("flascc.threadArbMutex",wdnative.threadArbMutex);
      _loc9_ = 0;
      while(_loc9_ < 32)
      {
         _loc7_.setSharedProperty("flascc.threadArbCond." + _loc9_,wdnative.threadArbConds[_loc9_]);
         _loc9_++;
      }
      wdnative.ram_init.shareable = true;
      _loc7_.setSharedProperty("flascc.ram",wdnative.ram_init);
      _loc7_.setSharedProperty("flascc.esp_init",param2);
      _loc7_.setSharedProperty("flascc.thread_entry",param3);
      var _loc8_:ByteArray = new ByteArray();
      _loc8_.writeObject(param4);
      _loc7_.setSharedProperty("flascc.thread_args",_loc8_);
      for each(var _loc6_:Function in wdnative.workerInits)
      {
         _loc6_(_loc7_);
      }
      return _loc7_;
   }
}

