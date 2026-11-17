package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F___pow5mult_D2A() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc9_ = _loc1_ & 3;
      _loc8_ = li32(_loc3_);
      if(_loc9_ != 0)
      {
         _loc2_ -= 16;
         si32(_loc8_,_loc2_);
         var _loc7_:int = _loc9_ << 2;
         _loc7_ = _loc7_ + wdnative_nternal._p05_2E_3360;
         _loc7_ = li32(_loc7_ - 4);
         si32(_loc7_,_loc2_ + 4);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___multadd_D2A();
         _loc2_ += 16;
         _loc8_ = wdnative.eax;
      }
      _loc6_ = _loc1_ >> 2;
      if(_loc6_ != 0)
      {
         _loc5_ = li32(wdnative_nternal._p5s);
         _loc9_ = _loc8_;
         if(_loc5_ == 0)
         {
            _loc5_ = li32(wdnative_nternal._freelist + 4);
            if(_loc5_ != 0)
            {
               _loc7_ = li32(_loc5_);
               si32(_loc7_,wdnative_nternal._freelist + 4);
            }
            else
            {
               _loc5_ = li32(wdnative_nternal._pmem_next);
               _loc7_ = _loc5_ - wdnative_nternal._private_mem;
               _loc7_ = _loc7_ >> 3;
               _loc7_ = _loc7_ + 4;
               if((uint(_loc7_)) <= 288)
               {
                  _loc7_ = _loc5_ + 32;
                  si32(_loc7_,wdnative_nternal._pmem_next);
               }
               else
               {
                  _loc2_ -= 16;
                  si32(32,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.F_malloc();
                  _loc2_ += 16;
                  _loc5_ = wdnative.eax;
               }
               si32(1,_loc5_ + 4);
               si32(2,_loc5_ + 8);
            }
            si32(0,_loc5_ + 12);
            si32(625,_loc5_ + 20);
            si32(1,_loc5_ + 16);
            si32(_loc5_,wdnative_nternal._p5s);
            si32(0,_loc5_);
            _loc9_ = _loc8_;
         }
         while(true)
         {
            _loc1_ = _loc5_;
            _loc7_ = _loc6_ & 1;
            _loc8_ = _loc9_;
            if(_loc7_ != 0)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_ + 4);
               si32(_loc9_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___mult_D2A();
               _loc2_ += 16;
               _loc8_ = wdnative.eax;
               if(_loc9_ != 0)
               {
                  _loc5_ = li32(_loc9_ + 4);
                  if(_loc5_ >= 10)
                  {
                     _loc2_ -= 16;
                     si32(_loc9_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                  }
                  else
                  {
                     var _temp_18:* = _loc5_ << 2;
                     _loc7_ = wdnative_nternal._freelist + _temp_18;
                     var _loc4_:int = li32(_loc7_);
                     si32(_loc4_,_loc9_);
                     si32(_loc9_,_loc7_);
                  }
               }
            }
            _loc6_ >>= 1;
            if(_loc6_ == 0)
            {
               break;
            }
            _loc5_ = li32(_loc1_);
            _loc9_ = _loc8_;
            if(_loc5_ == 0)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_ + 4);
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F___mult_D2A();
               _loc2_ += 16;
               _loc5_ = wdnative.eax;
               si32(_loc5_,_loc1_);
               si32(0,_loc5_);
               _loc9_ = _loc8_;
            }
         }
      }
      wdnative.eax = _loc8_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

