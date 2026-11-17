package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__sync_synchronize;
   
   public function F_avm2_lock_id() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 32;
      _loc1_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
      if(_loc1_ == -1)
      {
         _loc1_ = int(Boolean(workerClass));
         si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
      }
      _loc9_ = li32(_loc3_ + 4);
      _loc8_ = li32(_loc3_);
      if(_loc1_ == 0)
      {
         var _loc7_:int = li32(_loc8_);
         if(_loc7_ == 0)
         {
            si32(_loc9_,_loc8_);
         }
         else
         {
            addr0084:
            _loc7_ = li8(wdnative_nternal._sIsThreaded_2E_b);
            if(_loc7_ == 1)
            {
               threadArbMutexLock();
            }
            _loc6_ = li32(_loc8_);
            _loc1_ = int(Boolean(workerClass));
            do
            {
               _loc5_ = _loc6_;
               _loc6_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
               if(_loc6_ == -1)
               {
                  si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                  _loc6_ = _loc1_;
               }
               _loc4_ = _loc5_ | -2147483648;
               if(_loc6_ != 0)
               {
                  _loc6_ = casi32(_loc8_,_loc5_,_loc4_);
               }
               else
               {
                  _loc6_ = li32(_loc8_);
                  if(_loc6_ == _loc5_)
                  {
                     si32(_loc4_,_loc8_);
                  }
               }
            }
            while(_loc6_ != _loc5_);
            if(_loc5_ == 0)
            {
               si32(_loc9_,_loc8_);
               wdnative.ESP = _loc2_;
               wdnative.F__sync_synchronize();
            }
            else
            {
               si32(1,_loc3_ - 24);
               si32(_loc8_,_loc3_ - 16);
               si32(_loc9_,_loc3_ - 12);
               _loc7_ = int(threadId);
               si32(_loc7_,_loc3_ - 8);
               _loc7_ = li32(wdnative_nternal._sArbRequestHead);
               si32(_loc7_,_loc3_ - 32);
               _loc8_ = _loc3_ - 32;
               si32(_loc8_,wdnative_nternal._sArbRequestHead);
               do
               {
                  _loc7_ = li8(wdnative_nternal._sIsThreaded_2E_b);
                  if(_loc7_ == 1)
                  {
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                     _loc9_ = int(threadArbCondWait(3000));
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                  }
                  _loc1_ = wdnative_nternal._sArbRequestHead;
               }
               while(_loc7_ = li32(_loc3_ - 24), _loc7_ != 0);
               while(true)
               {
                  _loc9_ = _loc1_;
                  _loc1_ = li32(_loc9_);
                  if(_loc1_ == 0)
                  {
                     break;
                  }
                  if(_loc1_ == _loc8_)
                  {
                     _loc7_ = li32(_loc1_);
                     si32(_loc7_,_loc9_);
                     break;
                  }
               }
            }
            _loc7_ = li8(wdnative_nternal._sIsThreaded_2E_b);
            if(_loc7_ == 1)
            {
               threadArbMutexUnlock();
            }
         }
      }
      else
      {
         _loc7_ = casi32(_loc8_,0,_loc9_);
         if(_loc7_ != 0)
         {
            §§goto(addr0084);
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

