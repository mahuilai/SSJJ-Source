package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__sync_synchronize;
   
   public function F_avm2_wake_one() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li8(wdnative_nternal._sIsThreaded_2E_b);
      if(_loc1_ == 1)
      {
         threadArbMutexLock();
      }
      _loc10_ = li32(_loc3_);
      _loc9_ = 0;
      while(true)
      {
         _loc8_ = li32(wdnative_nternal._sArbRequestHead);
         if(_loc8_ != 0)
         {
            do
            {
               _loc1_ = li32(_loc8_ + 8);
               if(_loc1_ == 2)
               {
                  if(li32(_loc8_ + 12) == _loc10_)
                  {
                     _loc9_ = _loc8_;
                  }
               }
            }
            while(_loc8_ = li32(_loc8_), _loc8_ != 0);
            if(_loc9_ != 0)
            {
               _loc8_ = li32(_loc9_ + 16);
               _loc7_ = li32(_loc8_);
               _loc6_ = int(Boolean(workerClass));
               do
               {
                  _loc10_ = _loc7_;
                  _loc7_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
                  if(_loc7_ == -1)
                  {
                     si32(_loc6_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                     _loc7_ = _loc6_;
                  }
                  _loc5_ = _loc10_ | -2147483648;
                  if(_loc7_ != 0)
                  {
                     _loc7_ = casi32(_loc8_,_loc10_,_loc5_);
                  }
                  else
                  {
                     _loc7_ = li32(_loc8_);
                     if(_loc7_ == _loc10_)
                     {
                        si32(_loc5_,_loc8_);
                     }
                  }
               }
               while(_loc7_ != _loc10_);
               if(_loc10_ != 0)
               {
                  si32(1,_loc9_ + 8);
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
               }
               else
               {
                  var _temp_9:* = li32(_loc9_ + 16);
                  var _loc4_:int;
                  si32(_loc4_ = li32(_loc9_ + 20),_temp_9);
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  si32(0,_loc9_ + 8);
                  _loc9_ = li32(_loc9_ + 24);
                  if(li8(wdnative_nternal._sIsThreaded_2E_b) != 1)
                  {
                     break;
                  }
                  var _temp_11:* = _loc9_ & 0x1F;
                  var _temp_13:* = 1 << _temp_11;
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  threadArbCondsNotify(_temp_13);
               }
            }
         }
         _loc1_ = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc1_ == 1)
         {
            threadArbMutexUnlock();
         }
         break;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

