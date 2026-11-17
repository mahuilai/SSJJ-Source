package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.ptr2fun;
   
   public function F__GLOBAL__D___cxa_get_globals_fast() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li8(wdnative_nternal.__ZL4init + 4);
      if(_loc1_ != 0)
      {
         _loc9_ = li32(wdnative_nternal.__ZL4init);
         if(_loc9_ >= 0)
         {
            if(li32(wdnative_nternal._sEntryCount) > _loc9_)
            {
               _loc7_ = li32(wdnative_nternal._sEntries) + (_loc8_ = _loc9_ << 3);
               _loc6_ = li32(_loc7_ + 4);
               if(_loc6_ != 0)
               {
                  _loc5_ = li32(_loc7_);
                  if(_loc5_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(_loc5_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative.ptr2fun[_loc6_]();
                     _loc2_ += 16;
                  }
               }
               si32(0,_loc7_);
               _loc1_ = li32(wdnative_nternal._sEntries);
               _loc1_ += _loc8_;
               var _loc4_:int = li32(wdnative_nternal._sFirstFree);
               si32(_loc4_,_loc1_ + 4);
               si32(_loc9_,wdnative_nternal._sFirstFree);
            }
         }
      }
      si8(0,wdnative_nternal.__ZL4init + 4);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

