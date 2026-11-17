package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__sync_synchronize;
   import wdnative.eax;
   
   public function F_avm2_wake() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li8(wdnative_nternal._sIsThreaded_2E_b);
      if(_loc1_ == 1)
      {
         threadArbMutexLock();
      }
      _loc11_ = li32(_loc3_);
      _loc10_ = 0;
      _loc9_ = li32(wdnative_nternal._sArbRequestHead);
      _loc8_ = _loc10_;
      _loc7_ = _loc10_;
      loop3:
      while(true)
      {
         if(_loc9_ != 0)
         {
            do
            {
               _loc1_ = li32(_loc9_ + 8);
               if(_loc1_ == 2)
               {
                  if(li32(_loc9_ + 12) == _loc11_)
                  {
                     si32(_loc8_,_loc9_ + 4);
                     _loc10_ = 1;
                     _loc8_ = _loc9_;
                  }
               }
            }
            while(_loc9_ = li32(_loc9_), _loc9_ != 0);
            _loc11_ = 0;
            while(true)
            {
               if(_loc8_ != 0)
               {
                  do
                  {
                     _loc6_ = li32(_loc8_ + 16);
                     _loc5_ = li32(_loc6_);
                     do
                     {
                        _loc9_ = _loc5_;
                        _loc5_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
                        if(_loc5_ == -1)
                        {
                           _loc5_ = int(Boolean(workerClass));
                           si32(_loc5_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                        }
                        _loc7_ = _loc9_ | -2147483648;
                        if(_loc5_ != 0)
                        {
                           _loc5_ = casi32(_loc6_,_loc9_,_loc7_);
                        }
                        else
                        {
                           _loc5_ = li32(_loc6_);
                           if(_loc5_ == _loc9_)
                           {
                              si32(_loc7_,_loc6_);
                           }
                        }
                     }
                     while(_loc5_ != _loc9_);
                     if(_loc9_ == 0)
                     {
                        var _temp_7:* = li32(_loc8_ + 16);
                        si32(li32(_loc8_ + 20),_temp_7);
                        wdnative.ESP = _loc2_;
                        wdnative.F__sync_synchronize();
                        si32(0,_loc8_ + 8);
                        var _temp_9:* = li32(_loc8_ + 24) & 0x1F;
                        _loc11_ = 1 << _temp_9 | _loc11_;
                     }
                     else
                     {
                        si32(1,_loc8_ + 8);
                     }
                  }
                  while(_loc8_ = li32(_loc8_ + 4), _loc8_ != 0);
                  if(_loc11_ != 0)
                  {
                     var _temp_11:* = li8(wdnative_nternal._sIsThreaded_2E_b);
                     _loc7_ = _loc10_;
                     if(_temp_11 == 1)
                     {
                        wdnative.ESP = _loc2_;
                        wdnative.F__sync_synchronize();
                        threadArbCondsNotify(_loc11_);
                        _loc7_ = _loc10_;
                        break;
                     }
                     break loop3;
                  }
               }
               _loc1_ = _loc10_ & 0xFF;
               _loc7_ = 0;
               if(_loc1_ != 0)
               {
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  _loc7_ = _loc10_;
               }
               break;
            }
         }
         _loc1_ = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc1_ == 1)
         {
            threadArbMutexUnlock();
         }
         break;
      }
      _loc1_ = _loc7_ & 0xFF;
      wdnative.eax = _loc1_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

