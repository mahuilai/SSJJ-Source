package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_avail_tree_remove() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc14_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 16;
      _loc3_ = li32(_loc4_);
      _loc16_ = li32(_loc3_);
      si32(_loc16_,_loc4_ - 16);
      _loc15_ = _loc4_ - 16;
      _loc14_ = _loc15_ | 4;
      _loc13_ = _loc3_ + 4;
      var _loc12_:int = _loc13_ & -2;
      si32(_loc12_,_loc14_);
      _loc12_ = li32(_loc16_ + 8);
      _loc11_ = _loc12_ & -4096;
      _loc10_ = li32(_loc4_ + 4);
      _loc9_ = li32(_loc10_ + 8);
      _loc1_ = _loc9_ & -4096;
      _loc6_ = _loc5_ = 1;
      if(uint(_loc1_) >= uint(_loc11_))
      {
         _loc6_ = 0;
      }
      if(uint(_loc1_) <= uint(_loc11_))
      {
         _loc5_ = 0;
      }
      _loc12_ = _loc6_ & 1;
      _loc14_ = _loc5_ & 1;
      _loc5_ = _loc14_ - _loc12_;
      if(_loc1_ == _loc11_)
      {
         var _temp_10:* = _loc9_ & 0x10;
         _loc5_ = 0;
         if(_temp_10 == 0)
         {
            _loc5_ = _loc10_;
         }
         _loc9_ = _loc11_ = 1;
         if(uint(_loc5_) >= uint(_loc16_))
         {
            _loc9_ = 0;
         }
         if(uint(_loc5_) <= uint(_loc16_))
         {
            _loc11_ = 0;
         }
         _loc12_ = _loc9_ & 1;
         _loc14_ = _loc11_ & 1;
         _loc5_ = _loc14_ - _loc12_;
      }
      loop3:
      while(true)
      {
         if(_loc5_ <= -1)
         {
            _loc9_ = li32(_loc16_);
            _loc1_ = li32(_loc9_ + 4);
            var _temp_13:* = _loc1_ & 1;
            _loc11_ = _loc13_;
            _loc15_ = _loc16_;
            if(_temp_13 == 0)
            {
               _loc12_ = li32(_loc9_);
               _loc12_ = li8(_loc12_ + 4);
               var _temp_16:* = _loc12_ & 1;
               _loc15_ = _loc16_;
               if(_temp_16 == 0)
               {
                  _loc12_ = _loc1_ | 1;
                  si32(_loc12_,_loc9_ + 4);
                  _loc15_ = li32(_loc16_ + 4);
                  _loc9_ = _loc15_ & -2;
                  _loc11_ = li32(_loc9_);
                  _loc1_ = li32(_loc11_ + 4);
                  _loc12_ = _loc1_ & 1;
                  if(_loc12_ != 0)
                  {
                     _loc12_ = _loc1_ & -2;
                     si32(_loc12_,_loc9_);
                     _loc12_ = li32(_loc11_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc9_;
                     si32(_loc12_,_loc11_ + 4);
                     _loc12_ = li32(_loc16_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc11_;
                     si32(_loc12_,_loc16_ + 4);
                     _loc12_ = _loc12_ & 1 | li32(_loc9_ = _loc11_ & -2);
                     si32(_loc12_,_loc16_ + 4);
                     si32(_loc16_,_loc9_);
                     _loc12_ = li32(_loc16_ + 4);
                     _loc11_ = _loc12_ & -2;
                     _loc15_ = li32(_loc11_ + 4);
                     _loc12_ = _loc15_ & 1;
                     if(_loc12_ != 0)
                     {
                        _loc12_ = _loc15_ & -2;
                        si32(_loc12_,_loc11_ + 4);
                        _loc14_ = li32(_loc16_ + 4);
                        _loc12_ = _loc14_ | 1;
                        si32(_loc12_,_loc16_ + 4);
                        _loc12_ = _loc14_ & -2;
                        _loc14_ = li32(_loc12_);
                        _loc14_ = _loc14_ | 1;
                        si32(_loc14_,_loc16_ + 4);
                        si32(_loc16_,_loc12_);
                        si32(_loc12_,_loc9_);
                     }
                     else
                     {
                        si32(_loc11_,_loc16_ + 4);
                     }
                  }
                  else
                  {
                     _loc12_ = _loc15_ | 1;
                     si32(_loc12_,_loc16_ + 4);
                     _loc12_ = li32(_loc9_);
                     _loc12_ = _loc12_ | 1;
                     si32(_loc12_,_loc16_ + 4);
                     si32(_loc16_,_loc9_);
                  }
                  _loc12_ = li32(_loc9_ + 4);
                  _loc12_ = _loc12_ & -2;
                  si32(_loc12_,_loc9_ + 4);
                  si32(_loc9_,_loc4_ - 16);
                  _loc15_ = _loc4_ - 16;
               }
               addr0687:
               _loc11_ = _loc13_;
               if(_loc5_ == 0)
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
                  _loc9_ = _loc16_;
                  if(_loc5_ == 1)
                  {
                     _loc1_ = _loc16_ + 4;
                     _loc11_ = _loc13_;
                  }
                  else
                  {
                     §§goto(addr0687);
                  }
               }
               else
               {
                  _loc1_ = _loc16_ + 4;
                  _loc12_ = li32(_loc16_ + 4);
                  var _temp_47:* = _loc12_ & -2;
                  _loc11_ = _loc4_ - 16;
                  if(_temp_47 == _loc13_)
                  {
                     _loc15_ = li32(_loc16_);
                     _loc11_ = _loc13_;
                     if(_loc15_ != _loc13_)
                     {
                        _loc12_ = li32(_loc15_ + 4);
                        _loc12_ = _loc12_ & -2;
                        si32(_loc12_,_loc16_);
                        _loc12_ = li32(_loc15_ + 4);
                        _loc12_ = _loc12_ & 1;
                        _loc12_ = _loc12_ | _loc16_;
                        si32(_loc12_,_loc15_ + 4);
                        var _temp_55:* = _loc16_ & -2;
                        _loc12_ = (_loc14_ = (_loc14_ = li32(_loc16_ + 4)) & 1) | _temp_55;
                        si32(_loc12_,_loc15_ + 4);
                        _loc12_ = li32(_loc16_ + 4);
                        _loc12_ = _loc12_ | 1;
                        si32(_loc12_,_loc16_ + 4);
                        _loc12_ = li32(_loc15_ + 4);
                        _loc12_ = _loc12_ & 1;
                        _loc12_ = _loc12_ | _loc13_;
                        si32(_loc12_,_loc15_ + 4);
                        _loc11_ = _loc15_;
                     }
                     si32(_loc11_,_loc4_ - 16);
                     _loc15_ = _loc4_ - 16;
                     _loc11_ = _loc13_;
                     _loc9_ = _loc16_;
                     if(_loc5_ != 1)
                     {
                        §§goto(addr0687);
                     }
                  }
               }
               _loc5_ = li32(_loc1_);
               _loc9_ = _loc5_ & -2;
               _loc12_ = li32(_loc9_);
               _loc12_ = li8(_loc12_ + 4);
               _loc12_ = _loc12_ & 1;
               _loc15_ = _loc16_;
               if(_loc12_ == 0)
               {
                  _loc15_ = li32(_loc16_);
                  _loc9_ = li32(_loc15_ + 4);
                  _loc12_ = _loc9_ & 1;
                  if(_loc12_ != 0)
                  {
                     _loc6_ = _loc9_ & -2;
                     _loc9_ = li32(_loc6_);
                     _loc12_ = li8(_loc9_ + 4);
                     _loc12_ = _loc12_ & 1;
                     if(_loc12_ != 0)
                     {
                        var _temp_75:* = _loc5_ & 1;
                        _loc12_ = (_loc14_ = (_loc14_ = li32(_loc6_ + 4)) & -2) | _temp_75;
                        si32(_loc12_,_loc6_ + 4);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & -2;
                        si32(_loc12_,_loc9_ + 4);
                        _loc14_ = li32(_loc15_ + 4);
                        var _temp_82:* = _loc14_ & 1;
                        _loc12_ = (_loc14_ = li32(_loc9_ = _loc14_ & -2)) | _temp_82;
                        si32(_loc12_,_loc15_ + 4);
                        si32(_loc15_,_loc9_);
                        si32(_loc9_,_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & -2;
                        si32(_loc12_,_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & 1;
                        _loc12_ = _loc12_ | _loc16_;
                        si32(_loc12_,_loc9_ + 4);
                        _loc12_ = li32(_loc1_);
                        var _temp_92:* = _loc12_ & 1;
                        var _loc7_:int;
                        _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_92;
                        si32(_loc14_,_loc1_);
                        si32(_loc16_,_loc12_);
                        _loc14_ = li32(_loc9_ + 4);
                        _loc14_ = _loc14_ & 1;
                        _loc12_ = _loc14_ | _loc12_;
                        si32(_loc12_,_loc9_ + 4);
                     }
                     else
                     {
                        var _temp_97:* = _loc5_ & 1;
                        _loc12_ = _loc6_ | _temp_97;
                        si32(_loc12_,_loc15_ + 4);
                        _loc12_ = li32(_loc6_ + 4);
                        _loc12_ = _loc12_ | 1;
                        si32(_loc12_,_loc6_ + 4);
                        _loc9_ = li32(_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & -2;
                        si32(_loc12_,_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & 1;
                        _loc12_ = _loc12_ | _loc16_;
                        si32(_loc12_,_loc9_ + 4);
                        _loc12_ = li32(_loc1_);
                        var _temp_110:* = _loc12_ & 1;
                        _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_110;
                        si32(_loc14_,_loc1_);
                        si32(_loc16_,_loc12_);
                        _loc14_ = li32(_loc9_ + 4);
                        _loc14_ = _loc14_ & 1;
                        _loc12_ = _loc14_ | _loc12_;
                        si32(_loc12_,_loc9_ + 4);
                     }
                     _loc12_ = li32(_loc1_);
                     _loc12_ = _loc12_ | 1;
                     si32(_loc12_,_loc1_);
                  }
                  else
                  {
                     _loc12_ = _loc5_ | 1;
                     si32(_loc12_,_loc1_);
                     _loc5_ = li32(_loc15_);
                     _loc9_ = li32(_loc5_ + 4);
                     _loc12_ = _loc9_ & 1;
                     if(_loc12_ != 0)
                     {
                        _loc12_ = _loc9_ & -2;
                        si32(_loc12_,_loc5_ + 4);
                        _loc9_ = li32(_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & -2;
                        si32(_loc12_,_loc16_);
                        _loc12_ = li32(_loc9_ + 4);
                        _loc12_ = _loc12_ & 1;
                        _loc12_ = _loc12_ | _loc16_;
                        si32(_loc12_,_loc9_ + 4);
                        _loc12_ = li32(_loc1_);
                        var _temp_131:* = _loc12_ & 1;
                        _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_131;
                        si32(_loc14_,_loc1_);
                        si32(_loc16_,_loc12_);
                        _loc14_ = li32(_loc9_ + 4);
                        _loc14_ = _loc14_ & 1;
                        _loc12_ = _loc14_ | _loc12_;
                        si32(_loc12_,_loc9_ + 4);
                     }
                     else
                     {
                        _loc12_ = li32(_loc15_ + 4);
                        _loc12_ = _loc12_ | 1;
                        si32(_loc12_,_loc15_ + 4);
                        _loc14_ = li32(_loc1_);
                        var _temp_141:* = _loc14_ & 1;
                        _loc12_ = (_loc14_ = li32(_loc9_ = _loc14_ & -2)) | _temp_141;
                        si32(_loc12_,_loc1_);
                        si32(_loc16_,_loc9_);
                     }
                  }
                  si32(_loc9_,_loc4_ - 16);
                  _loc15_ = _loc4_ - 16;
               }
               break;
            }
         }
         while(true)
         {
            loop1:
            while(true)
            {
               _loc16_ = _loc15_;
               _loc15_ = _loc9_;
               while(true)
               {
                  _loc12_ = li32(_loc15_ + 8);
                  _loc6_ = _loc12_ & -4096;
                  _loc5_ = li32(_loc10_ + 8);
                  _loc9_ = _loc5_ & -4096;
                  _loc1_ = _loc8_ = 1;
                  if(uint(_loc9_) >= uint(_loc6_))
                  {
                     _loc1_ = 0;
                  }
                  if(uint(_loc9_) <= uint(_loc6_))
                  {
                     _loc8_ = 0;
                  }
                  _loc12_ = _loc1_ & 1;
                  _loc14_ = _loc8_ & 1;
                  _loc1_ = _loc14_ - _loc12_;
                  if(_loc9_ == _loc6_)
                  {
                     var _temp_146:* = _loc5_ & 0x10;
                     _loc1_ = _loc10_;
                     if(_temp_146 != 0)
                     {
                        _loc1_ = 0;
                     }
                     _loc5_ = _loc9_ = 1;
                     if(uint(_loc1_) >= uint(_loc15_))
                     {
                        _loc5_ = 0;
                     }
                     if(uint(_loc1_) <= uint(_loc15_))
                     {
                        _loc9_ = 0;
                     }
                     _loc12_ = _loc5_ & 1;
                     _loc14_ = _loc9_ & 1;
                     _loc1_ = _loc14_ - _loc12_;
                  }
                  if(_loc1_ > -1)
                  {
                     break loop1;
                  }
                  _loc9_ = li32(_loc15_);
                  if(_loc13_ == _loc9_)
                  {
                     break;
                  }
                  _loc5_ = li32(_loc9_ + 4);
                  _loc12_ = _loc5_ & 1;
                  if(_loc12_ == 0)
                  {
                     _loc12_ = li32(_loc9_);
                     _loc12_ = li8(_loc12_ + 4);
                     _loc12_ = _loc12_ & 1;
                     if(_loc12_ == 0)
                     {
                        _loc12_ = _loc5_ | 1;
                        si32(_loc12_,_loc9_ + 4);
                        _loc6_ = li32(_loc15_ + 4);
                        _loc9_ = _loc6_ & -2;
                        _loc1_ = li32(_loc9_);
                        _loc5_ = li32(_loc1_ + 4);
                        _loc12_ = _loc5_ & 1;
                        if(_loc12_ != 0)
                        {
                           _loc12_ = _loc5_ & -2;
                           si32(_loc12_,_loc9_);
                           _loc12_ = li32(_loc1_ + 4);
                           _loc12_ = _loc12_ & 1;
                           _loc12_ = _loc12_ | _loc9_;
                           si32(_loc12_,_loc1_ + 4);
                           _loc12_ = li32(_loc15_ + 4);
                           _loc12_ = _loc12_ & 1;
                           _loc12_ = _loc12_ | _loc1_;
                           si32(_loc12_,_loc15_ + 4);
                           _loc12_ = _loc12_ & 1 | li32(_loc9_ = _loc1_ & -2);
                           si32(_loc12_,_loc15_ + 4);
                           si32(_loc15_,_loc9_);
                           _loc12_ = li32(_loc15_ + 4);
                           _loc5_ = _loc12_ & -2;
                           _loc1_ = li32(_loc5_ + 4);
                           _loc12_ = _loc1_ & 1;
                           if(_loc12_ != 0)
                           {
                              _loc12_ = _loc1_ & -2;
                              si32(_loc12_,_loc5_ + 4);
                              _loc12_ = li32(_loc15_ + 4);
                              _loc14_ = _loc12_ | 1;
                              si32(_loc14_,_loc15_ + 4);
                              _loc12_ &= -2;
                              _loc14_ = li32(_loc12_);
                              _loc14_ = _loc14_ | 1;
                              si32(_loc14_,_loc15_ + 4);
                              si32(_loc15_,_loc12_);
                              si32(_loc12_,_loc9_);
                           }
                           else
                           {
                              si32(_loc5_,_loc15_ + 4);
                           }
                        }
                        else
                        {
                           _loc12_ = _loc6_ | 1;
                           si32(_loc12_,_loc15_ + 4);
                           _loc12_ = li32(_loc9_);
                           _loc12_ = _loc12_ | 1;
                           si32(_loc12_,_loc15_ + 4);
                           si32(_loc15_,_loc9_);
                        }
                        _loc12_ = li32(_loc16_);
                        if(_loc12_ == _loc15_)
                        {
                           si32(_loc9_,_loc16_);
                           _loc15_ = _loc9_;
                        }
                        else
                        {
                           _loc12_ = li32(_loc16_ + 4);
                           _loc12_ = _loc12_ & 1;
                           _loc12_ = _loc12_ | _loc9_;
                           si32(_loc12_,_loc16_ + 4);
                           _loc15_ = _loc9_;
                        }
                        continue;
                     }
                  }
                  continue loop1;
               }
               _loc12_ = li32(_loc11_);
               if(_loc12_ == _loc10_)
               {
                  si32(_loc15_,_loc11_);
               }
               else
               {
                  _loc12_ = li32(_loc11_ + 4);
                  _loc12_ = _loc12_ & 1;
                  _loc12_ = _loc12_ | _loc15_;
                  si32(_loc12_,_loc11_ + 4);
               }
               _loc12_ = li32(_loc10_);
               si32(_loc12_,_loc15_);
               _loc12_ = li32(_loc10_ + 4);
               _loc12_ = _loc12_ & -2;
               _loc14_ = li32(_loc15_ + 4);
               _loc14_ = _loc14_ & 1;
               _loc14_ = _loc14_ | _loc12_;
               si32(_loc14_,_loc15_ + 4);
               _loc14_ = li32(_loc10_ + 4);
               _loc14_ = _loc14_ & 1;
               _loc12_ = _loc14_ | _loc12_;
               si32(_loc12_,_loc15_ + 4);
               _loc12_ = li32(_loc16_);
               if(_loc12_ == _loc15_)
               {
                  si32(_loc13_,_loc16_);
                  break loop3;
               }
               _loc12_ = li32(_loc16_ + 4);
               _loc12_ = _loc12_ & 1;
               _loc12_ = _loc12_ | _loc13_;
               si32(_loc12_,_loc16_ + 4);
               break loop3;
            }
            _loc5_ = li32(_loc15_ + 4);
            _loc9_ = _loc5_ & -2;
            if(_loc1_ == 0)
            {
               _loc11_ = _loc16_;
               if(_loc9_ == _loc13_)
               {
                  _loc10_ = li32(_loc15_);
                  if(_loc10_ != _loc13_)
                  {
                     _loc12_ = li32(_loc10_ + 4);
                     _loc12_ = _loc12_ & -2;
                     si32(_loc12_,_loc15_);
                     _loc12_ = li32(_loc10_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc15_;
                     si32(_loc12_,_loc10_ + 4);
                     var _temp_208:* = _loc15_ & -2;
                     _loc12_ = (_loc14_ = (_loc14_ = li32(_loc15_ + 4)) & 1) | _temp_208;
                     si32(_loc12_,_loc10_ + 4);
                     _loc12_ = li32(_loc15_ + 4);
                     _loc12_ = _loc12_ | 1;
                     si32(_loc12_,_loc15_ + 4);
                     _loc12_ = li32(_loc10_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc13_;
                     si32(_loc12_,_loc10_ + 4);
                     _loc13_ = _loc10_;
                  }
                  _loc12_ = li32(_loc16_);
                  if(_loc12_ == _loc15_)
                  {
                     si32(_loc13_,_loc16_);
                     break loop3;
                  }
                  _loc12_ = li32(_loc16_ + 4);
                  _loc12_ = _loc12_ & 1;
                  _loc12_ = _loc12_ | _loc13_;
                  si32(_loc12_,_loc16_ + 4);
                  break loop3;
               }
            }
            _loc12_ = li32(_loc9_);
            _loc12_ = li8(_loc12_ + 4);
            _loc12_ = _loc12_ & 1;
            if(_loc12_ == 0)
            {
               _loc1_ = li32(_loc15_);
               _loc9_ = li32(_loc1_ + 4);
               _loc12_ = _loc9_ & 1;
               if(_loc12_ != 0)
               {
                  _loc9_ &= -2;
                  _loc6_ = li32(_loc9_);
                  _loc12_ = li8(_loc6_ + 4);
                  _loc12_ = _loc12_ & 1;
                  if(_loc12_ != 0)
                  {
                     var _temp_230:* = _loc5_ & 1;
                     _loc12_ = (_loc14_ = (_loc14_ = li32(_loc9_ + 4)) & -2) | _temp_230;
                     si32(_loc12_,_loc9_ + 4);
                     _loc12_ = li32(_loc6_ + 4);
                     _loc12_ = _loc12_ & -2;
                     si32(_loc12_,_loc6_ + 4);
                     _loc14_ = li32(_loc1_ + 4);
                     var _temp_237:* = _loc14_ & 1;
                     _loc12_ = (_loc14_ = li32(_loc9_ = _loc14_ & -2)) | _temp_237;
                     si32(_loc12_,_loc1_ + 4);
                     si32(_loc1_,_loc9_);
                     si32(_loc9_,_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & -2;
                     si32(_loc12_,_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc15_;
                     si32(_loc12_,_loc9_ + 4);
                     _loc12_ = li32(_loc15_ + 4);
                     var _temp_247:* = _loc12_ & 1;
                     _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_247;
                     si32(_loc14_,_loc15_ + 4);
                     si32(_loc15_,_loc12_);
                     _loc14_ = li32(_loc9_ + 4);
                     _loc14_ = _loc14_ & 1;
                     _loc12_ = _loc14_ | _loc12_;
                     si32(_loc12_,_loc9_ + 4);
                  }
                  else
                  {
                     var _temp_252:* = _loc5_ & 1;
                     _loc12_ = _loc9_ | _temp_252;
                     si32(_loc12_,_loc1_ + 4);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ | 1;
                     si32(_loc12_,_loc9_ + 4);
                     _loc9_ = li32(_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & -2;
                     si32(_loc12_,_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc15_;
                     si32(_loc12_,_loc9_ + 4);
                     _loc12_ = li32(_loc15_ + 4);
                     var _temp_265:* = _loc12_ & 1;
                     _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_265;
                     si32(_loc14_,_loc15_ + 4);
                     si32(_loc15_,_loc12_);
                     _loc14_ = li32(_loc9_ + 4);
                     _loc14_ = _loc14_ & 1;
                     _loc12_ = _loc14_ | _loc12_;
                     si32(_loc12_,_loc9_ + 4);
                  }
                  _loc12_ = li32(_loc15_ + 4);
                  _loc12_ = _loc12_ | 1;
                  si32(_loc12_,_loc15_ + 4);
               }
               else
               {
                  _loc12_ = _loc9_ | 1;
                  si32(_loc12_,_loc1_ + 4);
                  _loc9_ = li32(_loc1_);
                  _loc5_ = li32(_loc9_ + 4);
                  _loc12_ = _loc5_ & 1;
                  if(_loc12_ != 0)
                  {
                     _loc12_ = _loc5_ & -2;
                     si32(_loc12_,_loc9_ + 4);
                     _loc9_ = li32(_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & -2;
                     si32(_loc12_,_loc15_);
                     _loc12_ = li32(_loc9_ + 4);
                     _loc12_ = _loc12_ & 1;
                     _loc12_ = _loc12_ | _loc15_;
                     si32(_loc12_,_loc9_ + 4);
                     _loc12_ = li32(_loc15_ + 4);
                     var _temp_286:* = _loc12_ & 1;
                     _loc14_ = (_loc7_ = li32(_loc12_ &= -2)) | _temp_286;
                     si32(_loc14_,_loc15_ + 4);
                     si32(_loc15_,_loc12_);
                     _loc14_ = li32(_loc9_ + 4);
                     _loc14_ = _loc14_ & 1;
                     _loc12_ = _loc14_ | _loc12_;
                     si32(_loc12_,_loc9_ + 4);
                  }
                  else
                  {
                     _loc14_ = li32(_loc15_ + 4);
                     var _temp_294:* = _loc14_ & 1;
                     _loc12_ = (_loc14_ = li32(_loc9_ = _loc14_ & -2)) | _temp_294;
                     si32(_loc12_,_loc15_ + 4);
                     si32(_loc15_,_loc9_);
                  }
               }
               _loc12_ = li32(_loc16_);
               if(_loc12_ == _loc15_)
               {
                  si32(_loc9_,_loc16_);
                  _loc15_ = _loc16_;
               }
               else
               {
                  _loc12_ = li32(_loc16_ + 4);
                  _loc12_ = _loc12_ & 1;
                  _loc12_ = _loc12_ | _loc9_;
                  si32(_loc12_,_loc16_ + 4);
                  _loc15_ = _loc16_;
               }
            }
         }
         break;
      }
      _loc12_ = li32(_loc4_ - 16);
      si32(_loc12_,_loc3_);
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

