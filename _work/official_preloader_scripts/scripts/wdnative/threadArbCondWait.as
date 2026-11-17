package wdnative
{
   public function threadArbCondWait(param1:Number) : Boolean
   {
      var _loc2_:Boolean = false;
      return Boolean(wdnative.threadArbConds[wdnative.threadId & 0x1F].wait(param1));
   }
}

