package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F__sseek() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._errno);
      si32(0,wdnative_nternal._errno);
      _loc10_ = li32(_loc3_);
      _loc9_ = li32(_loc10_ + 40);
      _loc8_ = li32(_loc10_ + 28);
      _loc2_ -= 16;
      _loc7_ = li32(_loc3_ + 4);
      si32(_loc7_,_loc2_ + 12);
      si32(0,_loc2_ + 8);
      si32(0,_loc2_ + 4);
      si32(_loc8_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.ptr2fun[_loc9_]();
      _loc2_ += 16;
      _loc6_ = wdnative.eax;
      _loc5_ = wdnative.edx;
      _loc4_ = li32(wdnative_nternal._errno);
      if(_loc4_ == 0)
      {
         si32(_loc1_,wdnative_nternal._errno);
      }
      if(_loc5_ <= -1)
      {
         if(_loc4_ != 0)
         {
            if(_loc4_ != 29)
            {
               _loc10_ += 12;
            }
            else
            {
               _loc8_ = li16(_loc10_ + 12);
               _loc8_ = _loc8_ & 0xFEFF;
               si16(_loc8_,_loc10_ + 12);
               _loc10_ += 12;
            }
         }
         else
         {
            if(_loc7_ == 1)
            {
               _loc6_ = li16(_loc10_ + 12);
            }
            else
            {
               _loc6_ = li32(_loc10_ + 48);
               if(_loc6_ != 0)
               {
                  var _temp_10:* = int(_loc10_ + 64);
                  if(_loc6_ != _temp_10)
                  {
                     if(_loc6_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(_loc6_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_idalloc();
                        _loc2_ += 16;
                     }
                  }
                  si32(0,_loc10_ + 48);
               }
               _loc8_ = li32(_loc10_ + 16);
               si32(_loc8_,_loc10_);
               si32(0,_loc10_ + 4);
               _loc8_ = li16(_loc10_ + 12);
               _loc6_ = _loc8_ & -33;
               si16(_loc6_,_loc10_ + 12);
            }
            _loc8_ = _loc6_ | 0x40;
            si16(_loc8_,_loc10_ + 12);
            si32(22,wdnative_nternal._errno);
            _loc10_ += 12;
         }
         _loc8_ = li16(_loc10_);
         _loc8_ = _loc8_ & 0xEFFF;
         si16(_loc8_,_loc10_);
         _loc5_ = _loc6_ = -1;
      }
      else
      {
         _loc7_ = li16(_loc10_ + 12);
         _loc8_ = _loc7_ & 0x0400;
         if(_loc8_ != 0)
         {
            _loc8_ = _loc7_ | 0x1000;
            si16(_loc8_,_loc10_ + 12);
            si32(_loc5_,_loc10_ + 84);
            si32(_loc6_,_loc10_ + 80);
         }
      }
      wdnative.eax = _loc6_;
      wdnative.edx = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

