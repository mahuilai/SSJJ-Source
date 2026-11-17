package wdnative.md5
{
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.CModule;
   import wdnative.ESP;
   import wdnative.F__Z12MD5TransformPjPh;
   import wdnative.F__Z8MD5FinalP7MD5_CTXPh;
   import wdnative.Fmemcpy;
   import wdnative_nternal.F_sprintf;
   
   public function md5(param1:int, param2:int) : String
   {
      var _loc6_:int = 0;
      var _loc14_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc7_:int = 0;
      _loc6_ = wdnative.ESP;
      var _loc4_:int = _loc6_ - 160;
      _loc3_ = param1;
      _loc14_ = param2;
      si32(1732584193,_loc6_ - 84);
      si32(-271733879,_loc6_ - 80);
      si32(-1732584194,_loc6_ - 76);
      si32(271733878,_loc6_ - 72);
      var _loc13_:int = _loc14_ << 3;
      si32(_loc13_,_loc6_ - 92);
      _loc13_ = _loc14_ >>> 29;
      si32(_loc13_,_loc6_ - 88);
      _loc11_ = _loc6_ - 104;
      _loc10_ = _loc11_ + 36;
      _loc9_ = 0;
      if(uint(_loc14_) >= 64)
      {
         _loc8_ = _loc11_ + 20;
         _loc4_ -= 16;
         _loc9_ = 64;
         si32(_loc9_,_loc4_ + 8);
         si32(_loc3_,_loc4_ + 4);
         si32(_loc10_,_loc4_);
         wdnative.ESP = _loc4_;
         wdnative.Fmemcpy();
         _loc4_ += 16;
         _loc4_ = _loc4_ - 16;
         si32(_loc10_,_loc4_ + 4);
         si32(_loc8_,_loc4_);
         wdnative.ESP = _loc4_;
         wdnative.F__Z12MD5TransformPjPh();
         _loc4_ += 16;
         _loc7_ = 128;
         if(uint(_loc14_) >= 128)
         {
            do
            {
               _loc4_ -= 16;
               si32(_loc8_,_loc4_);
               _loc13_ = _loc3_ + _loc9_;
               si32(_loc13_,_loc4_ + 4);
               wdnative.ESP = _loc4_;
               wdnative.F__Z12MD5TransformPjPh();
               _loc4_ += 16;
               _loc7_ += 64;
               _loc9_ += 64;
            }
            while(uint(_loc7_) <= uint(_loc14_));
         }
      }
      _loc4_ -= 16;
      si32(_loc10_,_loc4_);
      _loc13_ = _loc14_ - _loc9_;
      si32(_loc13_,_loc4_ + 8);
      _loc13_ = _loc3_ + _loc9_;
      si32(_loc13_,_loc4_ + 4);
      wdnative.ESP = _loc4_;
      wdnative.Fmemcpy();
      _loc4_ += 16;
      _loc4_ = _loc4_ - 16;
      _loc9_ = _loc6_ - 120;
      si32(_loc9_,_loc4_ + 4);
      si32(_loc11_,_loc4_);
      wdnative.ESP = _loc4_;
      wdnative.F__Z8MD5FinalP7MD5_CTXPh();
      _loc4_ += 16;
      _loc7_ = 16;
      _loc11_ = _loc6_ - 152;
      do
      {
         _loc13_ = _loc9_ - _loc7_;
         _loc13_ = li8(_loc13_ + 16);
         _loc4_ -= 16;
         si32(_loc13_,_loc4_ + 4);
         si32(_loc11_,_loc4_);
         wdnative.ESP = _loc4_;
         wdnative_nternal.F_sprintf();
         _loc4_ += 16;
         _loc7_ += -1;
         _loc11_ += 2;
      }
      while(_loc7_ != 0);
      var _temp_18:* = int(_loc6_ - 152);
      var _loc5_:String = CModule.readString(_temp_18,32);
      var _temp_22:* = _loc5_;
      wdnative.ESP = _loc4_ = _loc6_;
      return _temp_22;
   }
}

