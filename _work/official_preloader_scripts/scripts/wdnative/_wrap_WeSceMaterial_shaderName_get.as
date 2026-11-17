package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   
   public function _wrap_WeSceMaterial_shaderName_get(param1:*) : String
   {
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc7_:int = 0;
      var _loc4_:int;
      _loc5_ = _loc4_ = wdnative.ESP;
      _loc3_ = param1;
      _loc12_ = li32(_loc3_ + 16);
      _loc11_ = _loc12_ & -4;
      _loc9_ = li32(_loc11_);
      _loc3_ = _loc9_ + -16843009;
      _loc9_ &= -2139062144;
      _loc9_ = _loc9_ ^ -2139062144;
      _loc3_ = _loc9_ & _loc3_;
      if(_loc3_ != 0)
      {
         _loc8_ = _loc11_ + 4;
         _loc7_ = 0;
         while(true)
         {
            _loc6_ = _loc12_ + _loc7_;
            if((uint(_loc6_)) < uint(_loc8_))
            {
               if(li8(_loc6_) == 0)
               {
                  break;
               }
               _loc7_ += 1;
               continue;
            }
         }
         §§goto(addr0146);
      }
      _loc11_ += 4;
      while(true)
      {
         _loc7_ = li32(_loc11_);
         _loc3_ = _loc7_ + -16843009;
         _loc9_ = _loc7_ & -2139062144;
         _loc9_ = _loc9_ ^ -2139062144;
         _loc3_ = _loc9_ & _loc3_;
         if(_loc3_ != 0)
         {
            if((_loc7_ & 0xFF) == 0)
            {
               _loc7_ = _loc11_ - _loc12_;
               break;
            }
            if(li8(_loc11_ + 1) == 0)
            {
               _loc7_ = int(1 - _loc12_) + _loc11_;
               break;
            }
            if(li8(_loc11_ + 2) == 0)
            {
               _loc7_ = int(2 - _loc12_) + _loc11_;
               break;
            }
            if(li8(_loc11_ + 3) == 0)
            {
               _loc7_ = int(3 - _loc12_) + _loc11_;
               break;
            }
         }
         _loc11_ += 4;
      }
      addr0146:
      var _loc2_:String = CModule.readString(_loc12_,_loc7_);
      var _loc10_:String = _loc2_;
      wdnative.ESP = _loc4_ = _loc5_;
      return _loc10_;
   }
}

