package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.F__Unwind_SjLj_Unregister;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__Unwind_ForcedUnwind_Phase2() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc13_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc5_:int = 0;
      var _loc14_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc14_ = li32(_loc1_);
      _loc13_ = li32(_loc3_);
      _loc12_ = li32(_loc13_ + 16);
      _loc11_ = li32(_loc13_ + 12);
      while(true)
      {
         _loc10_ = 26;
         _loc9_ = 0;
         _loc8_ = 5;
         if(_loc14_ != 0)
         {
            _loc9_ = li32(_loc14_ + 24);
            _loc8_ = 0;
            _loc10_ = 10;
         }
         var _loc7_:int = li32(_loc13_);
         var _loc6_:int = li32(_loc13_ + 4);
         _loc2_ -= 32;
         si32(_loc12_,_loc2_ + 24);
         si32(_loc1_,_loc2_ + 20);
         si32(_loc13_,_loc2_ + 16);
         si32(_loc6_,_loc2_ + 12);
         si32(_loc7_,_loc2_ + 8);
         si32(_loc10_,_loc2_ + 4);
         si32(1,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.ptr2fun[_loc11_]();
         _loc2_ += 32;
         _loc7_ = wdnative.eax;
         if(_loc7_ == 0)
         {
            _loc4_ = 5;
            if(_loc8_ == 5)
            {
               break;
            }
            if(_loc9_ == 0)
            {
               continue;
            }
            var _temp_10:* = li32(_loc13_);
            var _temp_9:* = li32(_loc13_ + 4);
            _loc2_ -= 32;
            si32(_loc1_,_loc2_ + 20);
            si32(_loc13_,_loc2_ + 16);
            si32(_temp_9,_loc2_ + 12);
            si32(_temp_10,_loc2_ + 8);
            si32(10,_loc2_ + 4);
            si32(1,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative.ptr2fun[_loc9_]();
            _loc4_ = 7;
            _loc2_ += 32;
            _loc5_ = wdnative.eax;
            if(_loc5_ == 7)
            {
               break;
            }
            if(_loc5_ == 8)
            {
               continue;
            }
         }
         _loc4_ = 2;
         break;
         _loc7_ = li32(_loc1_);
         _loc2_ -= 16;
         si32(_loc7_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative.F__Unwind_SjLj_Unregister();
         _loc2_ += 16;
         _loc7_ = li32(_loc1_);
         _loc14_ = li32(_loc7_);
         si32(_loc14_,_loc1_);
      }
      wdnative.eax = _loc4_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

