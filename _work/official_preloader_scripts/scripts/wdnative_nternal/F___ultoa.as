package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F___ultoa() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 12);
      _loc8_ = li32(_loc3_ + 8);
      _loc7_ = li32(_loc3_ + 4);
      _loc6_ = li32(_loc3_);
      if(_loc8_ != 8)
      {
         _loc1_ = li32(_loc3_ + 16);
         if(_loc8_ != 16)
         {
            if(_loc8_ == 10)
            {
               if(uint(_loc6_) <= 9)
               {
                  var _loc5_:int = _loc6_ + 48;
                  si8(_loc5_,_loc7_ - 1);
                  _loc7_ += -1;
               }
               else
               {
                  if(_loc6_ <= -1)
                  {
                     _loc5_ = uint(_loc6_) % 10;
                     _loc5_ = _loc5_ | 0x30;
                     si8(_loc5_,_loc7_ - 1);
                     _loc6_ /= 10;
                     _loc7_ += -1;
                  }
                  do
                  {
                     _loc5_ = _loc6_ % 10;
                     _loc5_ = _loc5_ + 48;
                     si8(_loc5_,_loc7_ - 1);
                     _loc7_ += -1;
                     _loc5_ = _loc6_ / 10;
                     var _loc4_:int = _loc6_ + 9;
                     _loc6_ = _loc5_;
                  }
                  while(uint(_loc4_) > 18);
               }
            }
            else
            {
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_abort();
            }
         }
         else
         {
            do
            {
               _loc5_ = _loc6_ & 0x0F;
               _loc5_ = _loc1_ + _loc5_;
               _loc5_ = li8(_loc5_);
               si8(_loc5_,_loc7_ - 1);
               _loc7_ += -1;
            }
            while(_loc6_ >>>= 4, _loc6_ != 0);
         }
      }
      else
      {
         do
         {
            _loc5_ = _loc6_ & 7;
            _loc8_ = _loc5_ | 0x30;
            si8(_loc8_,_loc7_ - 1);
            _loc7_ += -1;
         }
         while(_loc6_ >>>= 3, _loc6_ != 0);
         if(_loc1_ != 0)
         {
            _loc5_ = _loc8_ & 0xFF;
            if(_loc5_ != 48)
            {
               si8(48,_loc7_ - 1);
               _loc7_ += -1;
            }
         }
      }
      wdnative.eax = _loc7_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

