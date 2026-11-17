package wdnative
{
   public function ramSetLength(param1:int) : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      if(wdnative.isLegacy)
      {
         wdnative.ram.length = param1;
      }
      else
      {
         _loc2_ = wdnative.ramGetLength();
         if(param1 + 8 > wdnative.ram.length)
         {
            wdnative.ram.length = param1 + 1048576;
         }
         var _loc3_:int = int(wdnative.ram.position);
         wdnative.ram.position = 4;
         wdnative.ram.writeInt(param1);
         wdnative.ram.position = _loc3_;
         trace("v6 ramSetLength old " + _loc2_ + ", new " + wdnative.ram.length + ",diff " + (wdnative.ram.length - _loc2_));
      }
   }
}

