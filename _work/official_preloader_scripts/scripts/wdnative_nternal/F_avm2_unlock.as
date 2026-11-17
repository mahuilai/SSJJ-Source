package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__sync_synchronize;
   
   public function F_avm2_unlock() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      loop1:
      while(true)
      {
         _loc9_ = li32(_loc1_);
         if(_loc9_ >= 0)
         {
            _loc8_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
            if(_loc8_ == -1)
            {
               _loc8_ = int(Boolean(workerClass));
               si32(_loc8_,wdnative_nternal._avm2_haveWorkers_2E_4258);
            }
            if(_loc8_ != 0)
            {
               _loc8_ = casi32(_loc1_,_loc9_,0);
            }
            else
            {
               _loc8_ = li32(_loc1_);
               if(_loc8_ == _loc9_)
               {
                  si32(0,_loc1_);
               }
            }
            if(_loc8_ == _loc9_)
            {
               break;
            }
         }
         var _loc7_:int = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc7_ == 1)
         {
            threadArbMutexLock();
         }
         _loc8_ = 0;
         _loc6_ = li32(wdnative_nternal._sArbRequestHead);
         _loc9_ = _loc8_;
         while(true)
         {
            if(_loc6_ != 0)
            {
               do
               {
                  _loc7_ = li32(_loc6_ + 8);
                  if(_loc7_ == 1)
                  {
                     _loc5_ = li32(_loc6_ + 16);
                     _loc4_ = 1;
                     if(_loc5_ != _loc1_)
                     {
                        _loc4_ = 0;
                     }
                     _loc7_ = _loc4_ & 1;
                     _loc8_ = _loc7_ + _loc8_;
                     if(_loc5_ == _loc1_)
                     {
                        _loc9_ = _loc6_;
                     }
                  }
               }
               while(_loc6_ = li32(_loc6_), _loc6_ != 0);
               if(_loc9_ != 0)
               {
                  _loc4_ = li32(_loc9_ + 20);
                  _loc6_ = _loc4_ | -2147483648;
                  if(_loc8_ <= 1)
                  {
                     _loc6_ = _loc4_;
                  }
                  si32(_loc6_,_loc1_);
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  si32(0,_loc9_ + 8);
                  _loc1_ = li32(_loc9_ + 24);
                  _loc7_ = li8(wdnative_nternal._sIsThreaded_2E_b);
                  if(_loc7_ == 1)
                  {
                     var _temp_13:* = _loc1_ & 0x1F;
                     var _temp_15:* = 1 << _temp_13;
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                     threadArbCondsNotify(_temp_15);
                     break;
                  }
                  break loop1;
               }
            }
            si32(0,_loc1_);
            wdnative.ESP = _loc2_;
            wdnative.F__sync_synchronize();
            break;
         }
         _loc7_ = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc7_ == 1)
         {
            threadArbMutexUnlock();
         }
         break;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

