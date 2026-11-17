package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Exit;
   import wdnative.ptr2fun;
   
   public function F_exit() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal.___atexit);
      if(_loc1_ != 0)
      {
         do
         {
            _loc10_ = li32(_loc1_ + 4);
            if(_loc10_ >= 1)
            {
               var _temp_3:* = _loc10_ << 4;
               _loc8_ = _loc1_ + _temp_3;
               _loc7_ = 0 - _loc10_;
               _loc10_ = 0;
               do
               {
                  var _loc9_:int = _loc10_ << 4;
                  _loc6_ = _loc8_ + _loc9_;
                  _loc5_ = li32(_loc6_ - 8);
                  if(_loc5_ != 0)
                  {
                     var _temp_6:* = _loc10_ << 2;
                     _loc4_ = li32(_loc6_);
                     _loc6_ = li32(_loc6_ - 4);
                     var _temp_7:* = _temp_6 << 2;
                     var _temp_8:* = int(_loc8_ + _temp_7);
                     si32(0,_temp_8 - 8);
                     if(_loc5_ != 1)
                     {
                        if(_loc5_ == 2)
                        {
                           _loc2_ -= 16;
                           si32(_loc4_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative.ptr2fun[_loc6_]();
                           _loc2_ += 16;
                        }
                     }
                     else
                     {
                        wdnative.ESP = _loc2_;
                        wdnative.ptr2fun[_loc6_]();
                     }
                  }
                  _loc10_ += -1;
               }
               while(_loc7_ != _loc10_);
            }
            _loc1_ = li32(_loc1_);
         }
         while(_loc1_ != 0);
      }
      _loc9_ = li32(wdnative_nternal.___cleanup);
      if(_loc9_ != 0)
      {
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__cleanup();
      }
      _loc9_ = li32(_loc3_);
      _loc2_ -= 16;
      si32(_loc9_,_loc2_ + 4);
      si32(wdnative_nternal._delegateExitToActiveConsoleThunk,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_avm2_ui_thunk();
      _loc2_ += 16;
      throw new Exit(_loc9_);
   }
}

