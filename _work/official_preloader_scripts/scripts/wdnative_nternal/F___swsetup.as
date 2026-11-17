package wdnative_nternal
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F___swsetup() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li8(wdnative_nternal.___sdidinit_2E_b);
      if(_loc1_ == 0)
      {
         si32(wdnative_nternal.__cleanup,wdnative_nternal.___cleanup);
         si8(1,wdnative_nternal.___sdidinit_2E_b);
      }
      _loc6_ = li32(_loc3_);
      _loc5_ = li16(_loc6_ + 12);
      _loc1_ = _loc5_ & 8;
      while(true)
      {
         if(_loc1_ == 0)
         {
            if((_loc5_ & 0x10) == 0)
            {
               si32(9,wdnative_nternal._errno);
               si16(li16(_loc6_ + 12) | 0x40,_loc6_ + 12);
               _loc4_ = -1;
               break;
            }
            if((_loc5_ & 4) != 0)
            {
               _loc4_ = li32(_loc6_ + 48);
               if(_loc4_ != 0)
               {
                  var _temp_5:* = int(_loc6_ + 64);
                  if(_loc4_ != _temp_5)
                  {
                     _loc2_ -= 16;
                     si32(_loc4_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                     _loc5_ = li16(_loc6_ + 12);
                  }
                  si32(0,_loc6_ + 48);
               }
               _loc5_ &= 65499;
               si16(_loc5_,_loc6_ + 12);
               si32(0,_loc6_ + 4);
               _loc1_ = li32(_loc6_ + 16);
               si32(_loc1_,_loc6_);
            }
            _loc5_ |= 8;
            si16(_loc5_,_loc6_ + 12);
         }
         _loc1_ = li32(_loc6_ + 16);
         if(_loc1_ == 0)
         {
            _loc2_ -= 16;
            si32(_loc6_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F___smakebuf();
            _loc2_ += 16;
            _loc5_ = li16(_loc6_ + 12);
         }
         _loc1_ = _loc5_ & 1;
         if(_loc1_ != 0)
         {
            _loc4_ = 0;
            si32(_loc4_,_loc6_ + 8);
            var _temp_10:* = li32(_loc6_ + 20);
            si32(int(0 - _temp_10),_loc6_ + 24);
            break;
         }
         var _temp_11:* = _loc5_ & 2;
         _loc5_ = _loc4_ = 0;
         if(_temp_11 == 0)
         {
            _loc5_ = li32(_loc6_ + 20);
         }
         si32(_loc5_,_loc6_ + 8);
         break;
      }
      wdnative.eax = _loc4_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

