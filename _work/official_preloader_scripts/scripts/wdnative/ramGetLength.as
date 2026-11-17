package wdnative
{
   public function ramGetLength() : int
   {
      if(wdnative.isLegacy)
      {
         return wdnative.ram.length;
      }
      var _temp_1:* = int(wdnative.ram.position);
      wdnative.ram.position = 4;
      var _loc1_:int = int(wdnative.ram.readInt());
      wdnative.ram.position = _temp_1;
      return _loc1_;
   }
}

