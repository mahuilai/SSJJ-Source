package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_extent_tree_ad_remove() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc16_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc15_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 24;
      _loc3_ = li32(_loc4_);
      _loc16_ = li32(_loc3_);
      si32(_loc16_,_loc4_ - 16);
      _loc15_ = _loc3_ + 4;
      var _loc14_:int = _loc15_ & -2;
      si32(_loc14_,_loc4_ - 12);
      _loc13_ = li32(_loc16_ + 16);
      _loc12_ = li32(_loc4_ + 4);
      _loc11_ = li32(_loc12_ + 16);
      _loc9_ = _loc10_ = 1;
      if(uint(_loc11_) >= uint(_loc13_))
      {
         _loc9_ = 0;
      }
      if(uint(_loc11_) <= uint(_loc13_))
      {
         _loc10_ = 0;
      }
      _loc14_ = _loc9_ & 1;
      var _loc1_:int = _loc10_ & 1;
      loop3:
      while(true)
      {
         _loc5_ = _loc1_ - _loc14_;
         if(_loc5_ <= -1)
         {
            _loc6_ = li32(_loc16_ + 8);
            _loc7_ = li32(_loc6_ + 12);
            var _temp_9:* = _loc7_ & 1;
            _loc9_ = _loc15_;
            _loc10_ = _loc16_;
            if(_temp_9 == 0)
            {
               _loc14_ = li32(_loc6_ + 8);
               _loc14_ = li8(_loc14_ + 12);
               var _temp_12:* = _loc14_ & 1;
               _loc10_ = _loc16_;
               if(_temp_12 == 0)
               {
                  _loc14_ = _loc7_ | 1;
                  si32(_loc14_,_loc6_ + 12);
                  _loc9_ = li32(_loc16_ + 12);
                  _loc6_ = _loc9_ & -2;
                  _loc10_ = li32(_loc6_ + 8);
                  _loc7_ = li32(_loc10_ + 12);
                  _loc14_ = _loc7_ & 1;
                  if(_loc14_ != 0)
                  {
                     _loc14_ = _loc7_ & -2;
                     si32(_loc14_,_loc6_ + 8);
                     _loc14_ = li32(_loc10_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc6_;
                     si32(_loc14_,_loc10_ + 12);
                     _loc14_ = li32(_loc16_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc10_;
                     si32(_loc14_,_loc16_ + 12);
                     _loc14_ = _loc14_ & 1 | li32((_loc6_ = _loc10_ & -2) + 8);
                     si32(_loc14_,_loc16_ + 12);
                     si32(_loc16_,_loc6_ + 8);
                     _loc14_ = li32(_loc16_ + 12);
                     _loc9_ = _loc14_ & -2;
                     _loc10_ = li32(_loc9_ + 12);
                     _loc14_ = _loc10_ & 1;
                     if(_loc14_ != 0)
                     {
                        _loc14_ = _loc10_ & -2;
                        si32(_loc14_,_loc9_ + 12);
                        var _temp_33:* = li32(_loc16_ + 12);
                        si32(_loc14_ = _temp_33 | 1,_loc16_ + 12);
                        _loc14_ = _temp_33 & -2;
                        si32(li32(_loc14_ + 8) | 1,_loc16_ + 12);
                        si32(_loc16_,_loc14_ + 8);
                        si32(_loc14_,_loc6_ + 8);
                     }
                     else
                     {
                        si32(_loc9_,_loc16_ + 12);
                     }
                  }
                  else
                  {
                     _loc14_ = _loc9_ | 1;
                     si32(_loc14_,_loc16_ + 12);
                     _loc14_ = li32(_loc6_ + 8);
                     _loc14_ = _loc14_ | 1;
                     si32(_loc14_,_loc16_ + 12);
                     si32(_loc16_,_loc6_ + 8);
                  }
                  _loc14_ = li32(_loc6_ + 12);
                  _loc14_ = _loc14_ & -2;
                  si32(_loc14_,_loc6_ + 12);
                  si32(_loc6_,_loc4_ - 16);
                  _loc10_ = _loc4_ - 24;
               }
               addr0652:
               _loc9_ = _loc15_;
               if(_loc11_ == _loc13_)
               {
                  break;
               }
            }
         }
         else
         {
            while(true)
            {
               if(_loc5_ != 0)
               {
                  _loc10_ = _loc4_ - 24;
                  _loc6_ = _loc16_;
                  if(_loc5_ == 1)
                  {
                     _loc7_ = _loc16_ + 12;
                     _loc9_ = _loc15_;
                  }
                  else
                  {
                     §§goto(addr0652);
                  }
               }
               else
               {
                  _loc7_ = _loc16_ + 12;
                  _loc14_ = li32(_loc16_ + 12);
                  var _temp_42:* = _loc14_ & -2;
                  _loc9_ = _loc4_ - 24;
                  if(_temp_42 == _loc15_)
                  {
                     _loc10_ = li32(_loc16_ + 8);
                     _loc9_ = _loc15_;
                     if(_loc10_ != _loc15_)
                     {
                        _loc14_ = li32(_loc10_ + 12);
                        _loc14_ = _loc14_ & -2;
                        si32(_loc14_,_loc16_ + 8);
                        _loc14_ = li32(_loc10_ + 12);
                        _loc14_ = _loc14_ & 1;
                        _loc14_ = _loc14_ | _loc16_;
                        si32(_loc14_,_loc10_ + 12);
                        var _temp_48:* = _loc16_ & -2;
                        _loc14_ = li32(_loc16_ + 12) & 1 | _temp_48;
                        si32(_loc14_,_loc10_ + 12);
                        _loc14_ = li32(_loc16_ + 12);
                        _loc14_ = _loc14_ | 1;
                        si32(_loc14_,_loc16_ + 12);
                        _loc14_ = li32(_loc10_ + 12);
                        _loc14_ = _loc14_ & 1;
                        _loc14_ = _loc14_ | _loc15_;
                        si32(_loc14_,_loc10_ + 12);
                        _loc9_ = _loc10_;
                     }
                     si32(_loc9_,_loc4_ - 16);
                     _loc10_ = _loc4_ - 24;
                     _loc9_ = _loc15_;
                     _loc6_ = _loc16_;
                     if(_loc5_ != 1)
                     {
                        §§goto(addr0652);
                     }
                  }
               }
               _loc13_ = li32(_loc7_);
               _loc6_ = _loc13_ & -2;
               _loc14_ = li32(_loc6_ + 8);
               _loc14_ = li8(_loc14_ + 12);
               _loc14_ = _loc14_ & 1;
               _loc10_ = _loc16_;
               if(_loc14_ == 0)
               {
                  _loc10_ = li32(_loc16_ + 8);
                  _loc6_ = li32(_loc10_ + 12);
                  _loc14_ = _loc6_ & 1;
                  if(_loc14_ != 0)
                  {
                     _loc6_ &= -2;
                     _loc11_ = li32(_loc6_ + 8);
                     _loc14_ = li8(_loc11_ + 12);
                     _loc14_ = _loc14_ & 1;
                     if(_loc14_ != 0)
                     {
                        var _temp_66:* = _loc13_ & 1;
                        _loc14_ = li32(_loc6_ + 12) & -2 | _temp_66;
                        si32(_loc14_,_loc6_ + 12);
                        _loc14_ = li32(_loc11_ + 12);
                        _loc14_ = _loc14_ & -2;
                        si32(_loc14_,_loc11_ + 12);
                        var _temp_70:* = li32(_loc10_ + 12);
                        _loc14_ = _temp_70 & 1;
                        _loc6_ = _temp_70 & -2;
                        _loc14_ = li32(_loc6_ + 8) | _loc14_;
                        si32(_loc14_,_loc10_ + 12);
                        si32(_loc10_,_loc6_ + 8);
                        si32(_loc6_,_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & -2;
                        si32(_loc14_,_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & 1;
                        _loc14_ = _loc14_ | _loc16_;
                        si32(_loc14_,_loc6_ + 12);
                        _loc14_ = li32(_loc7_);
                        var _temp_81:* = _loc14_ & 1;
                        var _loc8_:int;
                        si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_81,_loc7_);
                        si32(_loc16_,_loc14_ + 8);
                        _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                        si32(_loc14_,_loc6_ + 12);
                     }
                     else
                     {
                        var _temp_83:* = _loc13_ & 1;
                        _loc14_ = _loc6_ | _temp_83;
                        si32(_loc14_,_loc10_ + 12);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ | 1;
                        si32(_loc14_,_loc6_ + 12);
                        _loc6_ = li32(_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & -2;
                        si32(_loc14_,_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & 1;
                        _loc14_ = _loc14_ | _loc16_;
                        si32(_loc14_,_loc6_ + 12);
                        _loc14_ = li32(_loc7_);
                        var _temp_96:* = _loc14_ & 1;
                        si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_96,_loc7_);
                        si32(_loc16_,_loc14_ + 8);
                        _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                        si32(_loc14_,_loc6_ + 12);
                     }
                     _loc14_ = li32(_loc7_);
                     _loc14_ = _loc14_ | 1;
                     si32(_loc14_,_loc7_);
                  }
                  else
                  {
                     _loc14_ = _loc13_ | 1;
                     si32(_loc14_,_loc7_);
                     _loc6_ = li32(_loc10_ + 8);
                     _loc13_ = li32(_loc6_ + 12);
                     _loc14_ = _loc13_ & 1;
                     if(_loc14_ != 0)
                     {
                        _loc14_ = _loc13_ & -2;
                        si32(_loc14_,_loc6_ + 12);
                        _loc6_ = li32(_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & -2;
                        si32(_loc14_,_loc16_ + 8);
                        _loc14_ = li32(_loc6_ + 12);
                        _loc14_ = _loc14_ & 1;
                        _loc14_ = _loc14_ | _loc16_;
                        si32(_loc14_,_loc6_ + 12);
                        _loc14_ = li32(_loc7_);
                        var _temp_114:* = _loc14_ & 1;
                        si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_114,_loc7_);
                        si32(_loc16_,_loc14_ + 8);
                        _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                        si32(_loc14_,_loc6_ + 12);
                     }
                     else
                     {
                        _loc14_ = li32(_loc10_ + 12);
                        _loc14_ = _loc14_ | 1;
                        si32(_loc14_,_loc10_ + 12);
                        var _temp_118:* = li32(_loc7_);
                        _loc14_ = _temp_118 & 1;
                        _loc6_ = _temp_118 & -2;
                        _loc14_ = li32(_loc6_ + 8) | _loc14_;
                        si32(_loc14_,_loc7_);
                        si32(_loc16_,_loc6_ + 8);
                     }
                  }
                  si32(_loc6_,_loc4_ - 16);
                  _loc10_ = _loc4_ - 24;
               }
               break;
            }
         }
         while(true)
         {
            loop1:
            while(true)
            {
               _loc16_ = _loc10_;
               _loc10_ = _loc6_;
               while(true)
               {
                  _loc11_ = li32(_loc10_ + 16);
                  _loc7_ = li32(_loc12_ + 16);
                  _loc13_ = _loc6_ = 1;
                  if(uint(_loc7_) >= uint(_loc11_))
                  {
                     _loc13_ = 0;
                  }
                  if(uint(_loc7_) <= uint(_loc11_))
                  {
                     _loc6_ = 0;
                  }
                  _loc1_ = _loc13_ & 1;
                  _loc14_ = _loc6_ & 1;
                  _loc14_ = _loc14_ - _loc1_;
                  if(_loc14_ > -1)
                  {
                     break loop1;
                  }
                  _loc6_ = li32(_loc10_ + 8);
                  if(_loc15_ == _loc6_)
                  {
                     break;
                  }
                  _loc13_ = li32(_loc6_ + 12);
                  _loc14_ = _loc13_ & 1;
                  if(_loc14_ == 0)
                  {
                     _loc14_ = li32(_loc6_ + 8);
                     _loc14_ = li8(_loc14_ + 12);
                     _loc14_ = _loc14_ & 1;
                     if(_loc14_ == 0)
                     {
                        _loc14_ = _loc13_ | 1;
                        si32(_loc14_,_loc6_ + 12);
                        _loc7_ = li32(_loc10_ + 12);
                        _loc6_ = _loc7_ & -2;
                        _loc11_ = li32(_loc6_ + 8);
                        _loc13_ = li32(_loc11_ + 12);
                        _loc14_ = _loc13_ & 1;
                        if(_loc14_ != 0)
                        {
                           _loc14_ = _loc13_ & -2;
                           si32(_loc14_,_loc6_ + 8);
                           _loc14_ = li32(_loc11_ + 12);
                           _loc14_ = _loc14_ & 1;
                           _loc14_ = _loc14_ | _loc6_;
                           si32(_loc14_,_loc11_ + 12);
                           _loc14_ = li32(_loc10_ + 12);
                           _loc14_ = _loc14_ & 1;
                           _loc14_ = _loc14_ | _loc11_;
                           si32(_loc14_,_loc10_ + 12);
                           _loc14_ = _loc14_ & 1 | li32((_loc6_ = _loc11_ & -2) + 8);
                           si32(_loc14_,_loc10_ + 12);
                           si32(_loc10_,_loc6_ + 8);
                           _loc14_ = li32(_loc10_ + 12);
                           _loc13_ = _loc14_ & -2;
                           _loc11_ = li32(_loc13_ + 12);
                           _loc14_ = _loc11_ & 1;
                           if(_loc14_ != 0)
                           {
                              _loc14_ = _loc11_ & -2;
                              si32(_loc14_,_loc13_ + 12);
                              var _temp_148:* = li32(_loc10_ + 12);
                              si32(_loc14_ = _temp_148 | 1,_loc10_ + 12);
                              _loc14_ = _temp_148 & -2;
                              si32(li32(_loc14_ + 8) | 1,_loc10_ + 12);
                              si32(_loc10_,_loc14_ + 8);
                              si32(_loc14_,_loc6_ + 8);
                           }
                           else
                           {
                              si32(_loc13_,_loc10_ + 12);
                           }
                        }
                        else
                        {
                           _loc14_ = _loc7_ | 1;
                           si32(_loc14_,_loc10_ + 12);
                           _loc14_ = li32(_loc6_ + 8);
                           _loc14_ = _loc14_ | 1;
                           si32(_loc14_,_loc10_ + 12);
                           si32(_loc10_,_loc6_ + 8);
                        }
                        _loc14_ = li32(_loc16_ + 8);
                        if(_loc14_ == _loc10_)
                        {
                           si32(_loc6_,_loc16_ + 8);
                           _loc10_ = _loc6_;
                        }
                        else
                        {
                           _loc14_ = li32(_loc16_ + 12);
                           _loc14_ = _loc14_ & 1;
                           _loc14_ = _loc14_ | _loc6_;
                           si32(_loc14_,_loc16_ + 12);
                           _loc10_ = _loc6_;
                        }
                        continue;
                     }
                  }
                  continue loop1;
               }
               _loc14_ = li32(_loc9_ + 8);
               if(_loc14_ == _loc12_)
               {
                  si32(_loc10_,_loc9_ + 8);
               }
               else
               {
                  _loc14_ = li32(_loc9_ + 12);
                  _loc14_ = _loc14_ & 1;
                  _loc14_ = _loc14_ | _loc10_;
                  si32(_loc14_,_loc9_ + 12);
               }
               _loc14_ = li32(_loc12_ + 8);
               si32(_loc14_,_loc10_ + 8);
               _loc14_ = li32(_loc12_ + 12);
               _loc14_ = _loc14_ & -2;
               _loc1_ = li32(_loc10_ + 12);
               _loc1_ &= 1;
               _loc1_ |= _loc14_;
               si32(_loc1_,_loc10_ + 12);
               _loc1_ = li32(_loc12_ + 12);
               _loc1_ &= 1;
               _loc14_ = _loc1_ | _loc14_;
               si32(_loc14_,_loc10_ + 12);
               _loc14_ = li32(_loc16_ + 8);
               if(_loc14_ == _loc10_)
               {
                  si32(_loc15_,_loc16_ + 8);
                  break loop3;
               }
               _loc14_ = li32(_loc16_ + 12);
               _loc14_ = _loc14_ & 1;
               _loc14_ = _loc14_ | _loc15_;
               si32(_loc14_,_loc16_ + 12);
               break loop3;
            }
            _loc13_ = li32(_loc10_ + 12);
            _loc6_ = _loc13_ & -2;
            if(_loc7_ == _loc11_)
            {
               _loc9_ = _loc16_;
               if(_loc6_ == _loc15_)
               {
                  _loc12_ = li32(_loc10_ + 8);
                  if(_loc12_ != _loc15_)
                  {
                     _loc14_ = li32(_loc12_ + 12);
                     _loc14_ = _loc14_ & -2;
                     si32(_loc14_,_loc10_ + 8);
                     _loc14_ = li32(_loc12_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc10_;
                     si32(_loc14_,_loc12_ + 12);
                     var _temp_176:* = _loc10_ & -2;
                     _loc14_ = li32(_loc10_ + 12) & 1 | _temp_176;
                     si32(_loc14_,_loc12_ + 12);
                     _loc14_ = li32(_loc10_ + 12);
                     _loc14_ = _loc14_ | 1;
                     si32(_loc14_,_loc10_ + 12);
                     _loc14_ = li32(_loc12_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc15_;
                     si32(_loc14_,_loc12_ + 12);
                     _loc15_ = _loc12_;
                  }
                  _loc14_ = li32(_loc16_ + 8);
                  if(_loc14_ == _loc10_)
                  {
                     si32(_loc15_,_loc16_ + 8);
                     break loop3;
                  }
                  _loc14_ = li32(_loc16_ + 12);
                  _loc14_ = _loc14_ & 1;
                  _loc14_ = _loc14_ | _loc15_;
                  si32(_loc14_,_loc16_ + 12);
                  break loop3;
               }
            }
            _loc14_ = li32(_loc6_ + 8);
            _loc14_ = li8(_loc14_ + 12);
            _loc14_ = _loc14_ & 1;
            if(_loc14_ == 0)
            {
               _loc11_ = li32(_loc10_ + 8);
               _loc6_ = li32(_loc11_ + 12);
               _loc14_ = _loc6_ & 1;
               if(_loc14_ != 0)
               {
                  _loc7_ = _loc6_ & -2;
                  _loc6_ = li32(_loc7_ + 8);
                  _loc14_ = li8(_loc6_ + 12);
                  _loc14_ = _loc14_ & 1;
                  if(_loc14_ != 0)
                  {
                     var _temp_197:* = _loc13_ & 1;
                     _loc14_ = li32(_loc7_ + 12) & -2 | _temp_197;
                     si32(_loc14_,_loc7_ + 12);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & -2;
                     si32(_loc14_,_loc6_ + 12);
                     var _temp_201:* = li32(_loc11_ + 12);
                     _loc14_ = _temp_201 & 1;
                     _loc6_ = _temp_201 & -2;
                     _loc14_ = li32(_loc6_ + 8) | _loc14_;
                     si32(_loc14_,_loc11_ + 12);
                     si32(_loc11_,_loc6_ + 8);
                     si32(_loc6_,_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & -2;
                     si32(_loc14_,_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc10_;
                     si32(_loc14_,_loc6_ + 12);
                     _loc14_ = li32(_loc10_ + 12);
                     var _temp_212:* = _loc14_ & 1;
                     si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_212,_loc10_ + 12);
                     si32(_loc10_,_loc14_ + 8);
                     _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                     si32(_loc14_,_loc6_ + 12);
                  }
                  else
                  {
                     var _temp_214:* = _loc13_ & 1;
                     _loc14_ = _loc7_ | _temp_214;
                     si32(_loc14_,_loc11_ + 12);
                     _loc14_ = li32(_loc7_ + 12);
                     _loc14_ = _loc14_ | 1;
                     si32(_loc14_,_loc7_ + 12);
                     _loc6_ = li32(_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & -2;
                     si32(_loc14_,_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc10_;
                     si32(_loc14_,_loc6_ + 12);
                     _loc14_ = li32(_loc10_ + 12);
                     var _temp_227:* = _loc14_ & 1;
                     si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_227,_loc10_ + 12);
                     si32(_loc10_,_loc14_ + 8);
                     _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                     si32(_loc14_,_loc6_ + 12);
                  }
                  _loc14_ = li32(_loc10_ + 12);
                  _loc14_ = _loc14_ | 1;
                  si32(_loc14_,_loc10_ + 12);
               }
               else
               {
                  _loc14_ = _loc6_ | 1;
                  si32(_loc14_,_loc11_ + 12);
                  _loc6_ = li32(_loc11_ + 8);
                  _loc13_ = li32(_loc6_ + 12);
                  _loc14_ = _loc13_ & 1;
                  if(_loc14_ != 0)
                  {
                     _loc14_ = _loc13_ & -2;
                     si32(_loc14_,_loc6_ + 12);
                     _loc6_ = li32(_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & -2;
                     si32(_loc14_,_loc10_ + 8);
                     _loc14_ = li32(_loc6_ + 12);
                     _loc14_ = _loc14_ & 1;
                     _loc14_ = _loc14_ | _loc10_;
                     si32(_loc14_,_loc6_ + 12);
                     _loc14_ = li32(_loc10_ + 12);
                     var _temp_245:* = _loc14_ & 1;
                     si32((_loc8_ = li32((_loc14_ &= -2) + 8)) | _temp_245,_loc10_ + 12);
                     si32(_loc10_,_loc14_ + 8);
                     _loc14_ = li32(_loc6_ + 12) & 1 | _loc14_;
                     si32(_loc14_,_loc6_ + 12);
                  }
                  else
                  {
                     var _temp_247:* = li32(_loc10_ + 12);
                     _loc14_ = _temp_247 & 1;
                     _loc6_ = _temp_247 & -2;
                     _loc14_ = li32(_loc6_ + 8) | _loc14_;
                     si32(_loc14_,_loc10_ + 12);
                     si32(_loc10_,_loc6_ + 8);
                  }
               }
               _loc14_ = li32(_loc16_ + 8);
               if(_loc14_ == _loc10_)
               {
                  si32(_loc6_,_loc16_ + 8);
                  _loc10_ = _loc16_;
               }
               else
               {
                  _loc14_ = li32(_loc16_ + 12);
                  _loc14_ = _loc14_ & 1;
                  _loc14_ = _loc14_ | _loc6_;
                  si32(_loc14_,_loc16_ + 12);
                  _loc10_ = _loc16_;
               }
            }
         }
         break;
      }
      _loc14_ = li32(_loc4_ - 16);
      si32(_loc14_,_loc3_);
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

