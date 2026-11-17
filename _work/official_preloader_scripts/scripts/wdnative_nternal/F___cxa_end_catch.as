package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.ptr2fun;
   
   public function F___cxa_end_catch() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative_nternal.__ZL10eh_globals;
      var _loc11_:int = li8(wdnative_nternal.__ZL4init + 4);
      if(_loc11_ != 0)
      {
         _loc1_ = 0;
         _loc10_ = li32(wdnative_nternal.__ZL4init);
         if(_loc10_ >= 0)
         {
            _loc11_ = li32(wdnative_nternal._sEntryCount);
            if(_loc11_ > _loc10_)
            {
               var _temp_6:* = _loc10_ << 3;
               var _loc9_:int;
               _loc11_ = (_loc9_ = li32(wdnative_nternal._sEntries)) + _temp_6;
               _loc1_ = li32(_loc11_);
            }
         }
      }
      _loc8_ = li32(_loc1_);
      if(_loc8_ != 0)
      {
         _loc11_ = li32(_loc8_ + 52);
         var _temp_12:* = _loc11_ ^ 0x474E5543;
         _loc11_ = (_loc9_ = (_loc9_ = li32(_loc8_ + 48)) ^ 0x432B2B00) | _temp_12;
         if(_loc11_ != 0)
         {
            si32(0,_loc1_);
            _loc7_ = li32(_loc8_ + 56);
            if(_loc7_ != 0)
            {
               _loc2_ -= 16;
               si32(1,_loc2_);
               _loc11_ = _loc8_ + 48;
               si32(_loc11_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative.ptr2fun[_loc7_]();
               _loc2_ += 16;
            }
         }
         else
         {
            while(true)
            {
               _loc6_ = li32(_loc8_ + 20);
               if(_loc6_ <= -1)
               {
                  _loc5_ = _loc6_ + 1;
                  if(_loc5_ == 0)
                  {
                     _loc11_ = li32(_loc8_ + 16);
                     si32(_loc11_,_loc1_);
                     _loc5_ = 0;
                  }
               }
               else
               {
                  _loc5_ = _loc6_ + -1;
                  if(_loc5_ == 0)
                  {
                     _loc11_ = li32(_loc8_ + 16);
                     si32(_loc11_,_loc1_);
                     _loc4_ = li32(_loc8_ + 56);
                     if(_loc4_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(1,_loc2_);
                        _loc11_ = _loc8_ + 48;
                        si32(_loc11_,_loc2_ + 4);
                        wdnative.ESP = _loc2_;
                        wdnative.ptr2fun[_loc4_]();
                        _loc2_ += 16;
                     }
                     break;
                  }
                  if(_loc5_ <= -1)
                  {
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F__ZSt9terminatev();
                  }
               }
               si32(_loc5_,_loc8_ + 20);
               break;
            }
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

