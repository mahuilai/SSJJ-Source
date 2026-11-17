package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   
   public function F__ZN20WeLittleEndianReader12readIntByLenEi() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc3_);
      if(_loc1_ != 1)
      {
         if(_loc1_ != 2)
         {
            if(_loc1_ == 4)
            {
               _loc2_ -= 16;
               si32(_loc8_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc2_ += 16;
               _loc1_ = wdnative.eax;
            }
            else
            {
               var _loc5_:int = li32(_loc8_ + 48);
               _loc5_ = _loc5_ + _loc1_;
               si32(_loc5_,_loc8_ + 48);
               var _temp_5:* = li32(_loc8_ + 44);
               _loc1_ = 0;
               if(_loc5_ >= _temp_5)
               {
                  si32(1,_loc8_ + 4);
                  si32(1,_loc8_ + 8);
                  _loc1_ = 0;
               }
            }
         }
         else
         {
            _loc7_ = li32(_loc8_ + 44);
            _loc6_ = li32(_loc8_ + 48);
            if(_loc6_ >= _loc7_)
            {
               si32(1,_loc8_ + 4);
               si32(1,_loc8_ + 8);
               _loc1_ = 0;
            }
            else
            {
               _loc5_ = li32(_loc8_ + 36);
               _loc5_ = _loc5_ + _loc6_;
               _loc1_ = li8(_loc5_);
               _loc6_ += 1;
               si32(_loc6_,_loc8_ + 48);
            }
            if(_loc6_ >= _loc7_)
            {
               si32(1,_loc8_ + 4);
               si32(1,_loc8_ + 8);
               _loc8_ = 0;
            }
            else
            {
               _loc5_ = li32(_loc8_ + 36);
               _loc5_ = _loc5_ + _loc6_;
               var _temp_13:* = li8(_loc5_);
               si32(_loc5_ = _loc6_ + 1,_loc8_ + 48);
               _loc8_ = _temp_13 << 8;
            }
            _loc5_ = _loc8_ | _loc1_;
            _loc5_ = _loc5_ << 16;
            _loc1_ = _loc5_ >> 16;
         }
      }
      else
      {
         _loc6_ = li32(_loc8_ + 48);
         var _temp_16:* = li32(_loc8_ + 44);
         if(_loc6_ >= _temp_16)
         {
            si32(1,_loc8_ + 4);
            si32(1,_loc8_ + 8);
            _loc1_ = 0;
         }
         else
         {
            _loc5_ = li32(_loc8_ + 36);
            _loc5_ = _loc5_ + _loc6_;
            _loc1_ = li8(_loc5_);
            _loc5_ = _loc6_ + 1;
            si32(_loc5_,_loc8_ + 48);
         }
      }
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

