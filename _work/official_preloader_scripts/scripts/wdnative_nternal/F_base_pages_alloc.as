package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_base_pages_alloc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      loop1:
      while(true)
      {
         var _loc8_:int = li8(wdnative_nternal._opt_mmap_2E_b);
         if(_loc8_ == 0)
         {
            if(_loc1_ != 0)
            {
               _loc2_ -= 16;
               _loc7_ = 0;
               si32(_loc7_,_loc2_);
               _loc8_ = _loc1_ + 4095;
               _loc6_ = _loc8_ & -4096;
               si32(_loc6_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_pages_map();
               _loc2_ += 16;
               _loc5_ = wdnative.eax;
               if(_loc5_ != 0)
               {
                  si32(_loc5_,wdnative_nternal._base_next_addr);
                  _loc8_ = _loc5_ + _loc6_;
                  si32(_loc8_,wdnative_nternal._base_past_addr);
                  break;
               }
            }
         }
         _loc7_ = 1;
         _loc8_ = li8(wdnative_nternal._opt_dss_2E_b);
         if(_loc8_ == 0)
         {
            _loc8_ = li32(wdnative_nternal._dss_prev);
            if(_loc8_ != -1)
            {
               var _loc4_:int = li32(wdnative_nternal._chunksize_mask);
               _loc5_ = int(_loc4_ + _loc1_) & (_loc4_ ^ -1);
               while(true)
               {
                  _loc7_ = int(ramGetLength());
                  if(_loc7_ == -1)
                  {
                     _loc2_ -= 16;
                     si32(_loc7_,_loc2_ + 8);
                     si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                     si32(wdnative_nternal.L__2E_str239,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_tprintf();
                     _loc2_ += 16;
                     si32(12,wdnative_nternal._errno);
                  }
                  si32(_loc7_,wdnative_nternal._dss_max);
                  _loc8_ = li32(wdnative_nternal._chunksize_mask);
                  _loc4_ = _loc8_ & _loc7_;
                  _loc8_ = li32(wdnative_nternal._chunksize);
                  _loc7_ = _loc8_ - _loc4_;
                  _loc6_ = _loc5_;
                  if(uint(_loc7_) >= uint(_loc1_))
                  {
                     _loc6_ = 0;
                  }
                  _loc7_ = _loc6_ + _loc7_;
                  if(_loc7_ == 0)
                  {
                     _loc6_ = int(ramGetLength());
                  }
                  else
                  {
                     _loc8_ = _loc7_ + 4095;
                     var _temp_17:* = _loc8_ & -4096;
                     _loc6_ = int(sbrk(_temp_17,4096));
                  }
                  if(_loc6_ == -1)
                  {
                     _loc2_ -= 16;
                     si32(_loc6_,_loc2_ + 8);
                     si32(wdnative_nternal.L__2E_str1240,_loc2_ + 4);
                     si32(wdnative_nternal.L__2E_str239,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_tprintf();
                     _loc2_ += 16;
                     si32(12,wdnative_nternal._errno);
                  }
                  si32(_loc6_,wdnative_nternal._dss_prev);
                  _loc8_ = li32(wdnative_nternal._dss_max);
                  if(_loc6_ == _loc8_)
                  {
                     _loc8_ = _loc6_ + _loc7_;
                     si32(_loc8_,wdnative_nternal._dss_max);
                     si32(_loc6_,wdnative_nternal._base_next_addr);
                     si32(_loc8_,wdnative_nternal._base_past_addr);
                     _loc7_ = 0;
                     break loop1;
                  }
                  _loc7_ = 1;
                  if(_loc6_ == -1)
                  {
                     break loop1;
                  }
               }
            }
         }
         break;
      }
      wdnative.eax = _loc7_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

