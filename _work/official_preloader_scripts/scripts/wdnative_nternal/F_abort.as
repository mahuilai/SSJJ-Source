package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_abort() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(wdnative_nternal.___cleanup);
      if(_loc1_ != 0)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__cleanup();
      }
      si32(-1,_loc3_ - 4);
      si32(-1,_loc3_ - 8);
      si32(-1,_loc3_ - 12);
      si32(-1,_loc3_ - 16);
      si32(-33,_loc3_ - 16);
      _loc2_ -= 16;
      si32(0,_loc2_ + 8);
      var _loc5_:int = _loc3_ - 24;
      _loc1_ = _loc5_ + 8;
      si32(_loc1_,_loc2_ + 4);
      si32(3,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_sigprocmask();
      _loc2_ += 16;
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_getpid();
      var _loc4_:int = wdnative.eax;
      _loc2_ -= 16;
      si32(6,_loc2_ + 4);
      si32(_loc4_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_kill();
      _loc2_ += 16;
      si32(0,_loc3_ - 24);
      _loc5_ |= 4;
      si32(0,_loc5_);
      si32(-1,_loc3_ - 4);
      si32(-1,_loc3_ - 8);
      si32(-1,_loc3_ - 12);
      si32(-1,_loc3_ - 16);
      si32(-33,_loc3_ - 16);
      _loc2_ -= 16;
      si32(0,_loc2_ + 8);
      si32(_loc1_,_loc2_ + 4);
      si32(3,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_sigprocmask();
      _loc2_ += 16;
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_getpid();
      _loc1_ = wdnative.eax;
      _loc2_ -= 16;
      si32(6,_loc2_ + 4);
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_kill();
      _loc2_ += 16;
      _loc2_ -= 16;
      si32(1,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_exit();
      _loc2_ += 16;
   }
}

