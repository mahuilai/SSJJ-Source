package wdnative
{
   function ramInit() : Boolean
   {
      trace("v6 initRam begin ");
      wdnative.ram.endian = "littleEndian";
      if(wdnative.ram.length < 1200)
      {
         wdnative.ram.length = 1200;
      }
      wdnative.domainClass.currentDomain.domainMemory = wdnative.ram_init;
      var _loc4_:int = int(wdnative.ram.position);
      wdnative.ram.position = 0;
      var _loc1_:int = int(wdnative.ram.readInt());
      var _loc3_:Boolean = _loc1_ != 287454020;
      if(!_loc3_)
      {
         wdnative.ram.position = 4;
         if(int(wdnative.ram.readInt()) < 8)
         {
            wdnative.ram.position = 4;
            wdnative.ram.writeInt(8);
         }
      }
      wdnative.ram.position = _loc4_;
      trace("v6 initRam end, legacy: " + _loc3_);
      return _loc3_;
   }
}

