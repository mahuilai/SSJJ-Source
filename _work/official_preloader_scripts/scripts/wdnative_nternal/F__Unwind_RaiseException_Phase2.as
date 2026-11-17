package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__Unwind_RaiseException_Phase2() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc12_ = li32(_loc1_);
      _loc11_ = li32(_loc3_);
      while(true)
      {
         if(_loc12_ != 0)
         {
            _loc10_ = li32(_loc11_ + 16);
            _loc9_ = li32(_loc12_ + 24);
            if(_loc9_ != 0)
            {
               var _temp_7:* = li32(_loc11_);
               var _temp_6:* = li32(_loc11_ + 4);
               _loc2_ -= 32;
               si32(_loc1_,_loc2_ + 20);
               si32(_loc11_,_loc2_ + 16);
               si32(_temp_6,_loc2_ + 12);
               si32(_temp_7,_loc2_ + 8);
               _loc6_ = 6;
               if(_loc12_ != _loc10_)
               {
                  _loc6_ = 2;
               }
               si32(_loc6_,_loc2_ + 4);
               si32(1,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.ptr2fun[_loc9_]();
               _loc5_ = 7;
               _loc2_ += 32;
               _loc4_ = wdnative.eax;
               if(_loc4_ == 7)
               {
                  break;
               }
               if(_loc4_ != 8)
               {
                  addr00fd:
                  _loc5_ = 2;
                  break;
               }
            }
            if(_loc12_ == _loc10_)
            {
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_abort();
            }
            var _loc8_:int = li32(_loc1_);
            _loc12_ = li32(_loc8_);
            si32(_loc12_,_loc1_);
            continue;
         }
         §§goto(addr00fd);
      }
      wdnative.eax = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

