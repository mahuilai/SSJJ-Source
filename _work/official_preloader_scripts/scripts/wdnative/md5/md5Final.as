package wdnative.md5
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.F__Z8MD5FinalP7MD5_CTXPh;
   import wdnative_nternal.F_sprintf;
   
   public function md5Final(param1:int) : String
   {
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc3_ -= 48;
      _loc2_ = param1;
      _loc3_ -= 16;
      _loc9_ = _loc5_ - 16;
      si32(_loc9_,_loc3_ + 4);
      si32(_loc2_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative.F__Z8MD5FinalP7MD5_CTXPh();
      _loc3_ += 16;
      _loc8_ = 16;
      _loc6_ = _loc5_ - 48;
      do
      {
         _loc2_ = _loc9_ - _loc8_;
         _loc2_ = li8(_loc2_ + 16);
         _loc3_ -= 16;
         si32(_loc2_,_loc3_ + 4);
         si32(_loc6_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F_sprintf();
         _loc3_ += 16;
         _loc8_ += -1;
         _loc6_ += 2;
      }
      while(_loc8_ != 0);
      var _temp_4:* = int(_loc5_ - 48);
      var _loc4_:String = CModule.readString(_temp_4,32);
      var _temp_7:* = _loc4_;
      wdnative.ESP = _loc5_;
      return _temp_7;
   }
}

