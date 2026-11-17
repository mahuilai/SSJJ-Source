package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__sync_synchronize;
   import wdnative.eax;
   
   public function F_avm2_msleep() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc15_:int = 0;
      var _loc13_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:Number = NaN;
      var _loc16_:Number = NaN;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:Number = NaN;
      var _loc3_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 32;
      _loc9_ = new Date().time;
      _loc3_ = 0;
      var _loc17_:int = li8(wdnative_nternal._sIsThreaded_2E_b);
      if(_loc17_ == 1)
      {
         _loc15_ = li32(_loc4_ + 4);
         _loc17_ = li32(_loc15_);
         _loc13_ = _loc17_ & 0x7FFFFFFF;
         var _temp_5:* = li32(_loc4_);
         si32(2,_loc4_ - 24);
         si32(_temp_5,_loc4_ - 20);
         si32(_loc15_,_loc4_ - 16);
         si32(_loc13_,_loc4_ - 12);
         _loc17_ = int(threadId);
         si32(_loc17_,_loc4_ - 8);
         _loc17_ = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc17_ == 1)
         {
            threadArbMutexLock();
         }
         var _loc7_:Number = _loc17_ = li32(_loc4_ + 8);
         _loc14_ = _loc7_ + _loc9_;
         var _loc12_:int = li32(wdnative_nternal._sArbRequestHead);
         si32(_loc12_,_loc4_ - 32);
         _loc3_ = _loc4_ - 32;
         si32(_loc3_,wdnative_nternal._sArbRequestHead);
         _loc2_ -= 16;
         si32(_loc15_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_avm2_unlock();
         _loc2_ += 16;
         if(_loc17_ == 0)
         {
            _loc10_ = wdnative_nternal._sArbRequestHead;
            _loc17_ = li32(_loc4_ - 24);
            if(_loc17_ != 0)
            {
               do
               {
                  _loc17_ = li8(wdnative_nternal._sIsThreaded_2E_b);
                  if(_loc17_ != 0)
                  {
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                     _loc8_ = int(threadArbCondWait(3000));
                     wdnative.ESP = _loc2_;
                     wdnative.F__sync_synchronize();
                  }
                  _loc14_ = new Date().time;
                  _loc10_ = wdnative_nternal._sArbRequestHead;
               }
               while(_loc17_ = li32(_loc4_ - 24), _loc17_ != 0);
            }
         }
         else
         {
            while(true)
            {
               _loc10_ = wdnative_nternal._sArbRequestHead;
               if(_loc9_ >= _loc14_)
               {
                  break;
               }
               _loc10_ = wdnative_nternal._sArbRequestHead;
               _loc17_ = li32(_loc4_ - 24);
               if(_loc17_ == 0)
               {
                  break;
               }
               _loc17_ = li8(wdnative_nternal._sIsThreaded_2E_b);
               if(_loc17_ == 1)
               {
                  var _loc11_:Number;
                  _loc6_ = _loc11_ = _loc14_ - _loc9_;
                  _loc16_ = -1;
                  if(_loc6_ != 0)
                  {
                     _loc16_ = _loc6_;
                  }
                  _loc5_ = 1;
                  _loc9_ = 3000;
                  _loc1_ = _loc5_;
                  if(_loc16_ <= _loc9_)
                  {
                     _loc1_ = 0;
                  }
                  if(_loc16_ >= 0)
                  {
                     _loc5_ = 0;
                  }
                  _loc17_ = _loc5_ | _loc1_;
                  if(_loc17_ == 0)
                  {
                     _loc9_ = _loc16_;
                  }
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
                  _loc10_ = int(threadArbCondWait(_loc9_));
                  wdnative.ESP = _loc2_;
                  wdnative.F__sync_synchronize();
               }
               _loc9_ = new Date().time;
            }
         }
         while(true)
         {
            _loc8_ = _loc10_;
            _loc10_ = li32(_loc8_);
            if(_loc10_ == 0)
            {
               break;
            }
            if(_loc10_ == _loc3_)
            {
               _loc17_ = li32(_loc10_);
               si32(_loc17_,_loc8_);
               break;
            }
         }
         _loc17_ = li32(_loc4_ - 24);
         if(_loc17_ != 0)
         {
            _loc2_ -= 16;
            si32(_loc13_,_loc2_ + 4);
            si32(_loc15_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_avm2_lock_id();
            _loc2_ += 16;
         }
         _loc17_ = li8(wdnative_nternal._sIsThreaded_2E_b);
         if(_loc17_ == 1)
         {
            threadArbMutexUnlock();
         }
         _loc3_ = 1;
         _loc17_ = li32(_loc4_ - 24);
         if(_loc17_ != 0)
         {
            _loc3_ = 0;
         }
         _loc3_ &= 1;
      }
      wdnative.eax = _loc3_;
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

