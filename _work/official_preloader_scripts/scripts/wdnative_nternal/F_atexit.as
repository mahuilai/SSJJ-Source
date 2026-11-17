package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.F_malloc;
   import wdnative.eax;
   
   public function F_atexit() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal.___atexit);
      _loc7_ = li32(_loc3_);
      if(_loc1_ == 0)
      {
         _loc1_ = wdnative_nternal.___atexit0_2E_2723;
         si32(_loc1_,wdnative_nternal.___atexit);
         _loc6_ = li32(wdnative_nternal.___atexit0_2E_2723 + 4);
      }
      else
      {
         while(true)
         {
            _loc6_ = li32(_loc1_ + 4);
            if(_loc6_ > 31)
            {
               _loc2_ -= 16;
               si32(520,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.F_malloc();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
               if(_loc6_ == 0)
               {
                  break;
               }
               _loc5_ = li32(wdnative_nternal.___atexit);
               if(_loc1_ != _loc5_)
               {
                  _loc2_ -= 16;
                  si32(_loc6_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_idalloc();
                  _loc2_ += 16;
                  _loc1_ = li32(wdnative_nternal.___atexit);
               }
               else
               {
                  si32(0,_loc6_ + 4);
                  si32(_loc5_,_loc6_);
                  si32(_loc6_,wdnative_nternal.___atexit);
                  _loc1_ = _loc6_;
               }
               continue;
            }
         }
         §§goto(addr010d);
      }
      var _loc4_:int = _loc6_ << 4;
      _loc4_ = _loc1_ + _loc4_;
      si32(1,_loc4_ + 8);
      si32(_loc7_,_loc4_ + 12);
      si32(0,_loc4_ + 16);
      si32(0,_loc4_ + 20);
      _loc4_ = _loc6_ + 1;
      si32(_loc4_,_loc1_ + 4);
      addr010d:
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

