package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__ZL17parse_lsda_headerP15_Unwind_ContextPKhP16lsda_header_info() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 0;
      _loc10_ = li32(_loc3_ + 8);
      si32(_loc1_,_loc10_);
      _loc9_ = _loc10_ + 4;
      _loc8_ = li32(_loc3_ + 4);
      _loc7_ = _loc8_ + 1;
      _loc6_ = li8(_loc8_);
      if(_loc6_ != 255)
      {
         _loc5_ = _loc6_ & 0x70;
         if(_loc5_ <= 47)
         {
            if(_loc5_ != 0)
            {
               if(_loc5_ != 16)
               {
                  if(_loc5_ != 32)
                  {
                     addr00a3:
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_abort();
                  }
               }
            }
         }
         else if(_loc5_ != 48)
         {
            if(_loc5_ != 64)
            {
               if(_loc5_ != 80)
               {
                  §§goto(addr00a3);
               }
            }
         }
         _loc2_ -= 16;
         si32(_loc9_,_loc2_ + 12);
         si32(_loc7_,_loc2_ + 8);
         si32(_loc1_,_loc2_ + 4);
         si32(_loc6_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__ZL28read_encoded_value_with_basehjPKhPj();
         _loc2_ += 16;
         _loc7_ = wdnative.eax;
      }
      else
      {
         si32(0,_loc9_);
      }
      _loc8_ = li8(_loc7_);
      si8(_loc8_,_loc10_ + 20);
      if(_loc8_ != 255)
      {
         _loc9_ = _loc7_ + 1;
         _loc7_ = _loc1_;
         do
         {
            _loc8_ = si8(li8(_loc9_));
            var _loc4_:int = _loc8_ & 0x7F;
            _loc4_ = _loc4_ << _loc1_;
            _loc7_ = _loc4_ | _loc7_;
            _loc1_ += 7;
            _loc9_ += 1;
         }
         while(_loc8_ < 0);
         _loc8_ = _loc9_ + _loc7_;
         si32(_loc8_,_loc10_ + 12);
      }
      else
      {
         si32(0,_loc10_ + 12);
         _loc9_ = _loc7_ + 1;
      }
      _loc8_ = li8(_loc9_);
      si8(_loc8_,_loc10_ + 21);
      _loc7_ = _loc9_ + 1;
      _loc1_ = 0;
      _loc9_ = _loc1_;
      do
      {
         _loc8_ = si8(li8(_loc7_));
         _loc4_ = _loc8_ & 0x7F;
         _loc4_ = _loc4_ << _loc1_;
         _loc9_ = _loc4_ | _loc9_;
         _loc1_ += 7;
         _loc7_ += 1;
      }
      while(_loc8_ < 0);
      _loc8_ = _loc7_ + _loc9_;
      si32(_loc8_,_loc10_ + 16);
      wdnative.eax = _loc7_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

