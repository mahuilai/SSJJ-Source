package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_operator_name() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc13_ = li32(_loc1_ + 12);
      _loc12_ = li8(_loc13_);
      var _loc11_:int = _loc13_ + 1;
      si32(_loc11_,_loc1_ + 12);
      _loc10_ = si8(li8(_loc13_ + 1));
      _loc11_ = _loc13_ + 2;
      si32(_loc11_,_loc1_ + 12);
      loop1:
      while(true)
      {
         if(_loc12_ != 99)
         {
            _loc9_ = 49;
            _loc8_ = 0;
            if(_loc12_ == 118)
            {
               _loc11_ = _loc10_ + -48;
               var _temp_6:* = _loc11_ & 0xFF;
               _loc9_ = 49;
               _loc8_ = 0;
               if(uint(_temp_6) <= 9)
               {
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_source_name();
                  _loc2_ += 16;
                  _loc7_ = wdnative.eax;
                  _loc9_ = li32(_loc1_ + 20);
                  var _temp_8:* = li32(_loc1_ + 24);
                  _loc6_ = 0;
                  if(_loc9_ < _temp_8)
                  {
                     _loc8_ = li32(_loc1_ + 16);
                     _loc11_ = _loc9_ + 1;
                     si32(_loc11_,_loc1_ + 20);
                     _loc9_ *= 12;
                     _loc1_ = _loc8_ + _loc9_;
                     _loc6_ = 0;
                     if(_loc1_ != 0)
                     {
                        _loc10_ += -48;
                        if(_loc10_ >= 0)
                        {
                           if(_loc7_ != 0)
                           {
                              _loc11_ = _loc8_ + _loc9_;
                              si32(41,_loc11_);
                              si32(_loc10_,_loc11_ + 4);
                              si32(_loc7_,_loc11_ + 8);
                              _loc6_ = _loc1_;
                           }
                        }
                     }
                  }
                  break;
               }
            }
         }
         else
         {
            var _temp_11:* = _loc10_ & 0xFF;
            _loc9_ = 49;
            _loc8_ = 0;
            if(_temp_11 == 118)
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_type();
               _loc6_ = 0;
               _loc2_ += 16;
               _loc7_ = wdnative.eax;
               if(_loc7_ != 0)
               {
                  _loc8_ = li32(_loc1_ + 20);
                  var _temp_14:* = li32(_loc1_ + 24);
                  _loc6_ = 0;
                  if(_loc8_ < _temp_14)
                  {
                     _loc10_ = li32(_loc1_ + 16);
                     _loc11_ = _loc8_ + 1;
                     si32(_loc11_,_loc1_ + 20);
                     _loc8_ *= 12;
                     _loc1_ = _loc10_ + _loc8_;
                     _loc6_ = 0;
                     if(_loc1_ != 0)
                     {
                        _loc11_ = _loc10_ + _loc8_;
                        si32(42,_loc11_);
                        si32(_loc7_,_loc11_ + 4);
                        si32(0,_loc11_ + 8);
                        _loc6_ = _loc1_;
                     }
                  }
               }
               break;
            }
         }
         while(true)
         {
            _loc13_ = _loc9_ - _loc8_;
            _loc11_ = _loc13_ >>> 31;
            _loc11_ = _loc13_ + _loc11_;
            _loc11_ = _loc11_ >> 1;
            _loc5_ = _loc11_ + _loc8_;
            _loc11_ = _loc5_ << 4;
            _loc7_ = wdnative_nternal._cplus_demangle_operators + _loc11_;
            _loc4_ = li32(_loc7_);
            _loc6_ = li8(_loc4_);
            if(_loc6_ == _loc12_)
            {
               var _temp_24:* = _loc10_ & 0xFF;
               if((_loc11_ = li8(_loc4_ + 1)) == _temp_24)
               {
                  _loc8_ = li32(_loc1_ + 20);
                  var _temp_25:* = li32(_loc1_ + 24);
                  _loc6_ = 0;
                  if(_loc8_ < _temp_25)
                  {
                     _loc10_ = li32(_loc1_ + 16);
                     _loc11_ = _loc8_ + 1;
                     si32(_loc11_,_loc1_ + 20);
                     _loc1_ = _loc8_ * 12;
                     _loc8_ = _loc10_ + _loc1_;
                     _loc6_ = 0;
                     if(_loc8_ != 0)
                     {
                        _loc11_ = _loc10_ + _loc1_;
                        si32(40,_loc11_);
                        si32(_loc7_,_loc11_ + 4);
                        _loc6_ = _loc8_;
                     }
                  }
                  break loop1;
               }
            }
            _loc11_ = _loc12_ << 24;
            _loc11_ = _loc11_ >> 24;
            _loc13_ = _loc6_ << 24;
            _loc13_ = _loc13_ >> 24;
            if(_loc13_ <= _loc11_)
            {
               while(true)
               {
                  if(_loc6_ == _loc12_)
                  {
                     _loc11_ = si8(li8(_loc4_ + 1));
                     if(_loc11_ > _loc10_)
                     {
                        break;
                     }
                  }
                  _loc8_ = _loc5_ + 1;
                  _loc5_ = _loc9_;
                  break;
               }
            }
            _loc6_ = 0;
            _loc9_ = _loc5_;
            if(_loc8_ == _loc5_)
            {
               break loop1;
            }
         }
         break;
      }
      wdnative.eax = _loc6_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

