package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_bare_function_type() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc10_ = li32(_loc1_ + 12);
      _loc9_ = li8(_loc10_);
      _loc8_ = li32(_loc3_ + 4);
      if(_loc9_ == 74)
      {
         _loc9_ = _loc10_ + 1;
         si32(_loc9_,_loc1_ + 12);
         _loc8_ = 1;
      }
      _loc10_ = 0;
      si32(_loc10_,_loc3_ - 4);
      while(true)
      {
         _loc7_ = _loc3_ - 4;
         if(_loc8_ == 0)
         {
            for(; (_loc8_ = li8(_loc9_ = li32(_loc1_ + 12))) != 0; si32(38,_loc8_),si32(_loc6_,_loc8_ + 4),si32(0,_loc8_ + 8),si32(_loc8_,_loc7_),_loc7_ = _loc8_ + 8)
            {
               if(_loc8_ != 69)
               {
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_type();
                  _loc8_ = 0;
                  _loc2_ += 16;
                  _loc6_ = wdnative.eax;
                  if(_loc6_ != 0)
                  {
                     _loc8_ = li32(_loc1_ + 20);
                     var _temp_8:* = li32(_loc1_ + 24);
                     if(_loc8_ < _temp_8)
                     {
                        var _temp_10:* = li32(_loc1_ + 16);
                        var _loc5_:int;
                        si32(_loc5_ = _loc8_ + 1,_loc1_ + 20);
                        _loc8_ = _temp_10 + int(_loc8_ * 12);
                        if(_loc8_ != 0)
                        {
                           continue;
                        }
                     }
                     _loc8_ = 0;
                     si32(_loc8_,_loc7_);
                  }
                  break;
               }
            }
            break;
         }
         addr027a:
         _loc9_ = li32(_loc1_ + 12);
         _loc8_ = li8(_loc9_);
         if(_loc8_ == 0)
         {
            break;
         }
         if(_loc8_ == 69)
         {
            break;
         }
         _loc2_ -= 16;
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_type();
         _loc8_ = 0;
         _loc2_ += 16;
         _loc10_ = wdnative.eax;
         if(_loc10_ == 0)
         {
            wdnative.eax = _loc8_;
            _loc2_ = _loc3_;
            wdnative.ESP = _loc2_;
         }
         continue;
         return;
         _loc8_ = 0;
      }
      _loc8_ = 0;
      _loc7_ = li32(_loc3_ - 4);
      if(_loc7_ != 0)
      {
         _loc9_ = li32(_loc7_ + 8);
         if(_loc9_ == 0)
         {
            _loc8_ = li32(_loc7_ + 4);
            _loc9_ = li32(_loc8_);
            if(_loc9_ == 33)
            {
               _loc8_ = li32(_loc8_ + 4);
               _loc9_ = li32(_loc8_ + 16);
               if(_loc9_ == 9)
               {
                  var _temp_25:* = li32(_loc8_ + 4);
                  _loc9_ = (_loc9_ = li32(_loc1_ + 48)) - _temp_25;
                  si32(_loc9_,_loc1_ + 48);
                  _loc7_ = 0;
                  si32(_loc7_,_loc3_ - 4);
               }
            }
         }
         _loc4_ = li32(_loc1_ + 20);
         _loc9_ = li32(_loc1_ + 24);
         _loc8_ = 0;
         if(_loc4_ < _loc9_)
         {
            _loc6_ = li32(_loc1_ + 16);
            _loc9_ = _loc4_ + 1;
            si32(_loc9_,_loc1_ + 20);
            _loc4_ *= 12;
            _loc1_ = _loc6_ + _loc4_;
            _loc8_ = 0;
            if(_loc1_ != 0)
            {
               _loc9_ = _loc6_ + _loc4_;
               si32(35,_loc9_);
               si32(_loc10_,_loc9_ + 4);
               si32(_loc7_,_loc9_ + 8);
               _loc8_ = _loc1_;
            }
         }
      }
      §§goto(addr027a);
   }
}

