package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F_load_msgcat() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 96;
      _loc2_ -= 16;
      si32(0,_loc2_ + 8);
      si32(0,_loc2_ + 4);
      _loc1_ = li32(_loc3_);
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F___sys_open();
      _loc6_ = -1;
      _loc2_ += 16;
      _loc5_ = wdnative.eax;
      if(_loc5_ != -1)
      {
         _loc2_ -= 16;
         si32(int(_loc3_ - 96),_loc2_ + 4);
         si32(_loc5_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F___sys_fstat();
         _loc2_ += 16;
         if(wdnative.eax != 0)
         {
            _loc2_ -= 16;
            si32(_loc5_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F___sys_close();
            _loc2_ += 16;
            _loc6_ = -1;
         }
         else
         {
            var _temp_6:* = li32(_loc3_ - 48);
            _loc2_ -= 32;
            si32(_loc5_,_loc2_ + 16);
            si32(1,_loc2_ + 12);
            si32(1,_loc2_ + 8);
            si32(_temp_6,_loc2_ + 4);
            si32(0,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_mmap();
            _loc2_ += 32;
            _loc4_ = wdnative.eax;
            _loc2_ -= 16;
            si32(_loc5_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F___sys_close();
            _loc2_ += 16;
            _loc6_ = -1;
            if(_loc4_ != -1)
            {
               if(li32(_loc4_) != -1979741953)
               {
                  var _temp_9:* = li32(_loc3_ - 48);
                  _loc2_ -= 16;
                  si32(_temp_9,_loc2_ + 4);
                  si32(_loc4_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_munmap();
                  _loc2_ += 16;
                  si32(22,wdnative_nternal._errno);
                  _loc6_ = -1;
               }
               else
               {
                  _loc2_ -= 16;
                  si32(8,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.F_malloc();
                  _loc2_ += 16;
                  _loc6_ = wdnative.eax;
                  if(_loc6_ == 0)
                  {
                     var _temp_13:* = li32(_loc3_ - 48);
                     _loc2_ -= 16;
                     si32(_temp_13,_loc2_ + 4);
                     si32(_loc4_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_munmap();
                     _loc2_ += 16;
                     _loc6_ = -1;
                  }
                  else
                  {
                     si32(_loc4_,_loc6_);
                     si32(li32(_loc3_ - 48),_loc6_ + 4);
                  }
               }
            }
         }
      }
      wdnative.eax = _loc6_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

