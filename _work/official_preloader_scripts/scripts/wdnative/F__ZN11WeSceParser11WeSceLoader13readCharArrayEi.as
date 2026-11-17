package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F_idalloc;
   
   public function F__ZN11WeSceParser11WeSceLoader13readCharArrayEi() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc7_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_ + 4);
      var _loc12_:int = _loc1_ + 1;
      si32(_loc12_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.F__ZN11WeAllocator8allocateEjPKcS1_i();
      _loc11_ = li32(_loc3_);
      _loc2_ += 16;
      _loc10_ = wdnative.eax;
      if(_loc10_ == 0)
      {
         si32(1,_loc11_ + 4);
         si32(2,_loc11_ + 8);
         _loc9_ = 0;
      }
      else
      {
         _loc8_ = _loc11_ + 40;
         _loc7_ = 0;
         while(true)
         {
            if(_loc7_ < _loc1_)
            {
               _loc12_ = li32(_loc11_ + 40);
               var _loc6_:int = li32(_loc12_ + 8);
               _loc2_ -= 16;
               si32(_loc8_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.ptr2fun[_loc6_]();
               _loc2_ += 16;
               _loc12_ = wdnative.eax;
               if(_loc12_ == 0)
               {
                  _loc5_ = li32(_loc11_ + 88);
                  var _temp_13:* = li32(_loc11_ + 84);
                  if(_loc5_ >= _temp_13)
                  {
                     si32(1,_loc11_ + 44);
                     si32(1,_loc11_ + 48);
                     _loc4_ = 0;
                  }
                  else
                  {
                     _loc12_ = li32(_loc11_ + 76);
                     _loc12_ = _loc12_ + _loc5_;
                     _loc4_ = li8(_loc12_);
                     _loc12_ = _loc5_ + 1;
                     si32(_loc12_,_loc11_ + 88);
                  }
                  _loc12_ = _loc10_ + _loc7_;
                  si8(_loc4_,_loc12_);
                  _loc7_ += 1;
                  continue;
               }
               _loc12_ = _loc1_ + -1;
               if(_loc12_ != _loc7_)
               {
                  si32(1,_loc11_ + 4);
                  si32(1,_loc11_ + 8);
                  _loc9_ = 0;
                  if(_loc10_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(_loc10_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                     _loc9_ = 0;
                  }
                  break;
               }
            }
            _loc12_ = _loc10_ + _loc1_;
            si8(0,_loc12_);
            _loc9_ = _loc10_;
            break;
         }
      }
      wdnative.eax = _loc9_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

