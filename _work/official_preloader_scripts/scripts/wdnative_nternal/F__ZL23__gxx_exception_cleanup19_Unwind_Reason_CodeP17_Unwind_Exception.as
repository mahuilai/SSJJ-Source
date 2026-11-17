package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.ptr2fun;
   
   public function F__ZL23__gxx_exception_cleanup19_Unwind_Reason_CodeP17_Unwind_Exception() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc7_ = _loc1_ + -48;
      _loc1_ = li32(_loc3_);
      if(uint(_loc1_) >= 2)
      {
         var _temp_2:* = li32(_loc7_ + 12);
         _loc2_ -= 16;
         si32(_temp_2,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F__ZN10__cxxabiv111__terminateEPFvvE();
         _loc2_ += 16;
      }
      _loc6_ = _loc7_ + 80;
      _loc5_ = li32(_loc7_ + 4);
      if(_loc5_ != 0)
      {
         _loc2_ -= 16;
         si32(_loc6_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.ptr2fun[_loc5_]();
         _loc2_ += 16;
      }
      while(true)
      {
         if(uint(_loc6_) >= uint(wdnative_nternal.__ZL16emergency_buffer))
         {
            var _temp_7:* = int(wdnative_nternal.__ZL16emergency_buffer + 16384);
            if(uint(_loc6_) < uint(_temp_7))
            {
               var _temp_8:* = int(_loc6_ - wdnative_nternal.__ZL16emergency_buffer) >>> 9;
               var _temp_10:* = 1 << _temp_8 ^ -1;
               var _loc4_:int;
               si32((_loc4_ = li32(wdnative_nternal.__ZL14emergency_used)) & _temp_10,wdnative_nternal.__ZL14emergency_used);
               break;
            }
         }
         if(_loc7_ != 0)
         {
            _loc2_ -= 16;
            si32(_loc7_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_idalloc();
            _loc2_ += 16;
         }
         break;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

