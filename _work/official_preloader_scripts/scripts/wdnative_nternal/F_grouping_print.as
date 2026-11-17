package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.sxi8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_grouping_print() : void
   {
      var _temp_1:* = this;
      var _loc6_:int = 0;
      var _loc16_:int = 0;
      var _loc13_:int = 0;
      var _loc4_:int = 0;
      var _loc8_:int = 0;
      var _loc17_:int = 0;
      var _loc9_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = 0;
      var _loc5_:int = 0;
      var _loc10_:int = 0;
      var _loc18_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc6_ = _loc3_;
      _loc4_ = li32(_loc6_ + 8);
      _loc18_ = li32(_loc6_ + 12);
      _loc17_ = _loc18_ - _loc4_;
      _loc16_ = li32(_loc6_);
      _loc14_ = _loc15_ = li32(_loc16_ + 12);
      if(_loc17_ <= _loc15_)
      {
         _loc14_ = _loc17_;
      }
      _loc13_ = li32(_loc6_ + 4);
      loop3:
      while(true)
      {
         if(_loc14_ <= 0)
         {
            _loc17_ = _loc13_ + 12;
            _loc14_ = 0;
         }
         else
         {
            var _temp_7:* = int(_loc13_ + 16);
            var _loc11_:int = (_loc11_ = li32(_loc13_ + 8)) << 3;
            var _temp_8:* = int(_temp_7 + _loc11_);
            si32(_loc4_,_temp_8);
            _loc11_ = li32(_loc13_ + 8);
            var _temp_10:* = int(_temp_7 + (_loc11_ << 3));
            si32(_loc14_,_temp_10 + 4);
            var _loc12_:int = li32(_loc13_ + 12);
            _loc7_ = _loc12_ + _loc14_;
            si32(_loc7_,_loc13_ + 12);
            _loc12_ = _loc11_ + 1;
            si32(_loc12_,_loc13_ + 8);
            _loc17_ = _loc13_ + 12;
            if(_loc12_ >= 8)
            {
               if(_loc7_ == 0)
               {
                  si32(0,_loc13_ + 8);
               }
               else
               {
                  var _temp_15:* = li32(_loc13_);
                  _loc3_ -= 16;
                  _loc11_ = _loc13_ + 4;
                  si32(_loc11_,_loc3_ + 4);
                  si32(_temp_15,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___sfvwrite();
                  _loc3_ += 16;
                  var _temp_17:* = wdnative.eax;
                  si32(0,_loc13_ + 12);
                  si32(0,_loc13_ + 8);
                  _loc8_ = -1;
                  if(_temp_17 != 0)
                  {
                     break;
                  }
               }
            }
         }
         _loc7_ = _loc15_ - _loc14_;
         _loc14_ = _loc13_ + 4;
         while(true)
         {
            if(_loc7_ <= 0)
            {
               var _temp_18:* = li32(_loc16_ + 12);
               _loc15_ = _loc4_ + _temp_18;
               while(true)
               {
                  _loc8_ = li32(_loc16_ + 20);
                  while(true)
                  {
                     _loc7_ = li32(_loc16_ + 16);
                     if(_loc7_ <= 0)
                     {
                        if(_loc8_ <= 0)
                        {
                           if(uint(_loc15_) <= uint(_loc18_))
                           {
                              _loc18_ = _loc15_;
                           }
                           _loc8_ = _loc18_ - _loc4_;
                           break loop3;
                        }
                     }
                     else if(_loc8_ < 1)
                     {
                        _loc12_ = li32(_loc16_ + 8);
                        _loc12_ = _loc12_ + -1;
                        si32(_loc12_,_loc16_ + 8);
                        _loc12_ = _loc7_ + -1;
                        si32(_loc12_,_loc16_ + 16);
                        break;
                     }
                     _loc12_ = _loc8_ + -1;
                     si32(_loc12_,_loc16_ + 20);
                     break;
                  }
                  _loc12_ = li32(_loc16_ + 8);
                  var _temp_20:* = si8(li8(_loc12_));
                  _loc15_ += _temp_20;
                  _loc9_ = _loc13_ + 16;
                  _loc12_ = li32(_loc13_ + 8);
                  _loc12_ = _loc12_ << 3;
                  var _loc1_:int = _loc9_ + _loc12_;
                  _loc12_ = li32(_loc16_ + 4);
                  _loc11_ = li32(_loc16_);
                  si32(_loc11_,_loc1_);
                  _loc11_ = li32(_loc13_ + 8);
                  _loc1_ = _loc11_ << 3;
                  _loc1_ = _loc9_ + _loc1_;
                  si32(_loc12_,_loc1_ + 4);
                  _loc1_ = li32(_loc17_);
                  _loc8_ = _loc1_ + _loc12_;
                  si32(_loc8_,_loc17_);
                  _loc7_ = _loc11_ + 1;
                  si32(_loc7_,_loc13_ + 8);
                  if(_loc7_ >= 8)
                  {
                     if(_loc8_ == 0)
                     {
                        _loc7_ = 0;
                        si32(_loc7_,_loc13_ + 8);
                     }
                     else
                     {
                        var _temp_31:* = li32(_loc13_);
                        _loc3_ -= 16;
                        si32(_loc14_,_loc3_ + 4);
                        si32(_temp_31,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F___sfvwrite();
                        _loc3_ += 16;
                        var _temp_33:* = wdnative.eax;
                        si32(_loc7_ = 0,_loc17_);
                        si32(_loc7_,_loc13_ + 8);
                        _loc8_ = -1;
                        if(_temp_33 != 0)
                        {
                           break loop3;
                        }
                     }
                  }
                  _loc8_ = _loc18_ - _loc15_;
                  _loc12_ = li32(_loc16_ + 8);
                  _loc2_ = _loc10_ = si8(li8(_loc12_));
                  if(_loc8_ <= _loc10_)
                  {
                     _loc2_ = _loc8_;
                  }
                  _loc5_ = 0;
                  if(_loc2_ >= 1)
                  {
                     var _temp_36:* = _loc7_ << 3;
                     var _temp_37:* = int(_loc9_ + _temp_36);
                     si32(_loc15_,_temp_37);
                     _loc12_ = li32(_loc13_ + 8);
                     var _temp_39:* = _loc12_ << 3;
                     var _temp_40:* = int(_loc9_ + _temp_39);
                     si32(_loc2_,_temp_40 + 4);
                     _loc11_ = li32(_loc17_);
                     _loc8_ = _loc11_ + _loc2_;
                     si32(_loc8_,_loc17_);
                     _loc7_ = _loc12_ + 1;
                     si32(_loc7_,_loc13_ + 8);
                     _loc5_ = _loc2_;
                     if(_loc7_ >= 8)
                     {
                        if(_loc8_ == 0)
                        {
                           _loc7_ = 0;
                           si32(_loc7_,_loc13_ + 8);
                           _loc5_ = _loc2_;
                        }
                        else
                        {
                           var _temp_44:* = li32(_loc13_);
                           _loc3_ -= 16;
                           si32(_loc14_,_loc3_ + 4);
                           si32(_temp_44,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___sfvwrite();
                           _loc3_ += 16;
                           var _temp_46:* = wdnative.eax;
                           si32(_loc7_ = 0,_loc17_);
                           si32(_loc7_,_loc13_ + 8);
                           _loc8_ = -1;
                           _loc5_ = _loc2_;
                           if(_temp_46 != 0)
                           {
                              break loop3;
                           }
                        }
                     }
                  }
                  _loc2_ = _loc10_ - _loc5_;
                  while(_loc2_ > 0)
                  {
                     var _temp_47:* = _loc7_ << 3;
                     var _temp_48:* = int(_loc9_ + _temp_47);
                     si32(wdnative_nternal._zeroes,_temp_48);
                     _loc10_ = 16;
                     if(_loc2_ <= _loc10_)
                     {
                        _loc10_ = _loc2_;
                     }
                     _loc12_ = li32(_loc13_ + 8);
                     _loc11_ = _loc12_ << 3;
                     _loc11_ = _loc9_ + _loc11_;
                     si32(_loc10_,_loc11_ + 4);
                     _loc11_ = li32(_loc17_);
                     _loc8_ = _loc11_ + _loc10_;
                     si32(_loc8_,_loc17_);
                     _loc7_ = _loc12_ + 1;
                     si32(_loc7_,_loc13_ + 8);
                     if(_loc7_ >= 8)
                     {
                        if(_loc8_ == 0)
                        {
                           _loc7_ = 0;
                           si32(_loc7_,_loc13_ + 8);
                        }
                        else
                        {
                           var _temp_53:* = li32(_loc13_);
                           _loc3_ -= 16;
                           si32(_loc14_,_loc3_ + 4);
                           si32(_temp_53,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F___sfvwrite();
                           _loc3_ += 16;
                           var _temp_55:* = wdnative.eax;
                           si32(_loc7_ = 0,_loc17_);
                           si32(_loc7_,_loc13_ + 8);
                           _loc8_ = -1;
                           if(_temp_55 != 0)
                           {
                              break loop3;
                           }
                        }
                     }
                     _loc2_ -= _loc10_;
                  }
               }
               break loop3;
            }
            _loc8_ = _loc13_ + 16;
            _loc12_ = li32(_loc13_ + 8);
            var _temp_57:* = _loc12_ << 3;
            var _temp_58:* = int(_loc8_ + _temp_57);
            si32(wdnative_nternal._zeroes,_temp_58);
            _loc15_ = 16;
            if(_loc7_ <= _loc15_)
            {
               _loc15_ = _loc7_;
            }
            _loc12_ = li32(_loc13_ + 8);
            _loc11_ = _loc12_ << 3;
            _loc11_ = _loc8_ + _loc11_;
            si32(_loc15_,_loc11_ + 4);
            _loc11_ = li32(_loc17_);
            _loc8_ = _loc11_ + _loc15_;
            si32(_loc8_,_loc17_);
            _loc12_ += 1;
            si32(_loc12_,_loc13_ + 8);
            if(_loc12_ >= 8)
            {
               if(_loc8_ == 0)
               {
                  si32(0,_loc13_ + 8);
               }
               else
               {
                  var _temp_63:* = li32(_loc13_);
                  _loc3_ -= 16;
                  si32(_loc14_,_loc3_ + 4);
                  si32(_temp_63,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative_nternal.F___sfvwrite();
                  _loc3_ += 16;
                  var _temp_65:* = wdnative.eax;
                  si32(0,_loc17_);
                  si32(0,_loc13_ + 8);
                  _loc8_ = -1;
                  if(_temp_65 != 0)
                  {
                     break loop3;
                  }
               }
            }
            _loc7_ -= _loc15_;
         }
         break;
      }
      break loop1;
   }
}

