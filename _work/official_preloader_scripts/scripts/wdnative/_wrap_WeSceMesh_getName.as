package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   
   public function _wrap_WeSceMesh_getName(param1:*) : String
   {
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:int;
      _loc6_ = _loc4_ = wdnative.ESP;
      _loc5_ = param1;
      _loc13_ = _loc5_ + 40;
      _loc12_ = _loc13_ & -4;
      _loc11_ = li32(_loc12_);
      _loc10_ = _loc11_ + -16843009;
      _loc11_ &= -2139062144;
      _loc11_ = _loc11_ ^ -2139062144;
      _loc10_ = _loc11_ & _loc10_;
      if(_loc10_ != 0)
      {
         _loc9_ = _loc5_ + 40;
         _loc8_ = _loc12_ + 4;
         _loc7_ = 0;
         while(true)
         {
            _loc5_ = _loc9_ + _loc7_;
            if((uint(_loc5_)) < uint(_loc8_))
            {
               _loc10_ = li8(_loc5_);
               if(_loc10_ == 0)
               {
                  break;
               }
               _loc7_ += 1;
               continue;
            }
         }
         §§goto(addr0172);
      }
      _loc5_ = _loc12_ + 4;
      while(true)
      {
         _loc12_ = li32(_loc5_);
         _loc10_ = _loc12_ + -16843009;
         _loc11_ = _loc12_ & -2139062144;
         _loc11_ = _loc11_ ^ -2139062144;
         _loc10_ = _loc11_ & _loc10_;
         if(_loc10_ != 0)
         {
            _loc10_ = _loc12_ & 0xFF;
            if(_loc10_ == 0)
            {
               _loc7_ = _loc5_ - _loc13_;
               break;
            }
            _loc10_ = li8(_loc5_ + 1);
            if(_loc10_ == 0)
            {
               _loc10_ = 1 - _loc13_;
               _loc7_ = _loc10_ + _loc5_;
               break;
            }
            _loc10_ = li8(_loc5_ + 2);
            if(_loc10_ == 0)
            {
               _loc10_ = 2 - _loc13_;
               _loc7_ = _loc10_ + _loc5_;
               break;
            }
            _loc10_ = li8(_loc5_ + 3);
            if(_loc10_ == 0)
            {
               _loc10_ = 3 - _loc13_;
               _loc7_ = _loc10_ + _loc5_;
               break;
            }
         }
         _loc5_ += 4;
      }
      addr0172:
      var _loc3_:String = CModule.readString(_loc13_,_loc7_);
      var _loc2_:String = _loc3_;
      wdnative.ESP = _loc4_ = _loc6_;
      return _loc2_;
   }
}

