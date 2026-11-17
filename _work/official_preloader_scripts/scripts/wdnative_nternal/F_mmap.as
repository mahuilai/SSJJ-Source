package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_mmap() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(wdnative_nternal._osreldate_2E_1497);
      if(_loc1_ == 0)
      {
         si32(1,_loc3_ - 12);
         si32(24,_loc3_ - 8);
         si32(0,_loc3_ - 16);
         si32(4,_loc3_ - 4);
         _loc2_ -= 32;
         si32(0,_loc2_ + 16);
         var _loc9_:int = _loc3_ - 4;
         si32(_loc9_,_loc2_ + 12);
         _loc9_ = _loc3_ - 16;
         si32(_loc9_,_loc2_ + 8);
         si32(2,_loc2_ + 4);
         _loc9_ = _loc3_ - 12;
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_sysctl();
         _loc2_ += 32;
         while(true)
         {
            _loc9_ = wdnative.eax;
            if(_loc9_ == 0)
            {
               _loc1_ = li32(_loc3_ - 16);
               if(_loc1_ >= 1)
               {
                  _loc9_ = li32(_loc3_ - 4);
                  if(_loc9_ == 4)
                  {
                     si32(_loc1_,wdnative_nternal._osreldate_2E_1497);
                     break;
                  }
               }
            }
            _loc1_ = li32(wdnative_nternal._osreldate_2E_1497);
            break;
         }
      }
      _loc8_ = li32(_loc3_ + 16);
      _loc7_ = li32(_loc3_ + 12);
      _loc6_ = li32(_loc3_ + 8);
      _loc5_ = li32(_loc3_ + 4);
      _loc4_ = li32(_loc3_);
      if(_loc1_ >= 700051)
      {
         _loc2_ -= 32;
         si32(0,_loc2_ + 24);
         si32(0,_loc2_ + 20);
         si32(_loc8_,_loc2_ + 16);
         si32(_loc7_,_loc2_ + 12);
         si32(_loc6_,_loc2_ + 8);
         si32(_loc5_,_loc2_ + 4);
         si32(_loc4_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___sys_mmap();
         _loc2_ += 32;
         _loc4_ = wdnative.eax;
      }
      else
      {
         _loc2_ -= 32;
         si32(_loc8_,_loc2_ + 16);
         si32(_loc7_,_loc2_ + 12);
         si32(_loc6_,_loc2_ + 8);
         si32(_loc5_,_loc2_ + 4);
         si32(_loc4_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___sys_freebsd6_mmap();
         _loc2_ += 32;
         _loc4_ = wdnative.eax;
      }
      wdnative.eax = _loc4_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

