package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   
   public function _wrap_getSceLadderCount(param1:int) : int
   {
      var _loc5_:int = 0;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      _loc5_ = wdnative.ESP;
      var _loc4_:int = _loc5_ - 176;
      _loc3_ = param1;
      _loc9_ = li32(_loc3_ + 592);
      if(_loc9_ <= -1)
      {
         _loc9_ = 0;
         si32(_loc9_,_loc3_ + 592);
         var _loc8_:int = li32(_loc3_ + 172);
         if(_loc8_ >= 1)
         {
            _loc6_ = 0;
            do
            {
               _loc4_ -= 16;
               _loc8_ = _loc5_ - 168;
               si32(_loc8_,_loc4_ + 8);
               si32(_loc3_,_loc4_);
               si32(_loc6_,_loc4_ + 4);
               wdnative.ESP = _loc4_;
               wdnative.F__ZN11WeSceParser11WeSceLoader7getMeshEiR9WeSceMesh();
               _loc4_ += 16;
               _loc8_ = wdnative.eax;
               if(_loc8_ != 0)
               {
                  _loc8_ = li8(_loc5_ - 136);
                  _loc8_ = _loc8_ & 4;
                  if(_loc8_ != 0)
                  {
                     _loc8_ = li32(_loc3_ + 592);
                     _loc8_ = _loc8_ + 1;
                     si32(_loc8_,_loc3_ + 592);
                  }
               }
               _loc6_ += 1;
            }
            while(_loc8_ = li32(_loc3_ + 172), _loc8_ > _loc6_);
            _loc9_ = li32(_loc3_ + 592);
         }
      }
      var _loc2_:int = _loc9_;
      var _loc7_:int = _loc2_;
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc7_;
   }
}

