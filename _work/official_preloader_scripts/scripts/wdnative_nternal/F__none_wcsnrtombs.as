package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F__none_wcsnrtombs() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc4_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc10_ = li32(_loc1_);
      _loc9_ = 0;
      _loc8_ = li32(_loc3_ + 8);
      _loc7_ = li32(_loc3_);
      if(_loc7_ != 0)
      {
         var _temp_3:* = li32(_loc3_ + 12);
         _loc9_ = 0 - _temp_3;
         _loc5_ = 0 - _loc8_;
         _loc8_ = 0;
         while(true)
         {
            if(_loc9_ != _loc8_)
            {
               if(_loc5_ != _loc8_)
               {
                  _loc4_ = li32(_loc10_);
                  if((uint(_loc4_)) >= 256)
                  {
                     si32(86,wdnative_nternal._errno);
                     _loc10_ = -1;
                     break;
                  }
                  var _temp_5:* = int(_loc7_ - _loc8_);
                  si8(_loc4_,_temp_5);
                  var _loc6_:int = _loc4_ & 0xFF;
                  if(_loc6_ == 0)
                  {
                     si32(0,_loc1_);
                     _loc10_ = 0 - _loc8_;
                     break;
                  }
                  continue;
               }
            }
            si32(_loc10_,_loc1_);
            _loc10_ = 0 - _loc8_;
            break;
            _loc10_ += 4;
            _loc8_ += -1;
         }
      }
      else
      {
         while(true)
         {
            if(_loc8_ != 0)
            {
               _loc6_ = _loc10_ - _loc9_;
               _loc7_ = li32(_loc6_);
               if(_loc7_ != 0)
               {
                  if(uint(_loc7_) >= 256)
                  {
                     si32(86,wdnative_nternal._errno);
                     _loc10_ = -1;
                     break;
                  }
                  continue;
               }
            }
            _loc6_ = 0 - _loc9_;
            _loc10_ = _loc6_ >> 2;
            break;
            _loc8_ += -1;
            _loc9_ += -4;
         }
      }
      wdnative.eax = _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

