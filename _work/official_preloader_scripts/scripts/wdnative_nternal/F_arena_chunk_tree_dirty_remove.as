package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_chunk_tree_dirty_remove() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc15_:int = 0;
      var _loc1_:int = 0;
      var _loc14_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 32;
      _loc3_ = li32(_loc4_);
      _loc15_ = li32(_loc3_);
      _loc14_ = _loc4_ - 32;
      _loc13_ = _loc14_ | 4;
      si32(_loc15_,_loc13_);
      _loc12_ = _loc3_ + 4;
      _loc13_ = _loc12_ & -2;
      si32(_loc13_,_loc4_ - 24);
      _loc11_ = 1;
      _loc10_ = li32(_loc4_ + 4);
      _loc9_ = _loc11_;
      if(uint(_loc15_) <= uint(_loc10_))
      {
         _loc9_ = 0;
      }
      if(uint(_loc15_) >= uint(_loc10_))
      {
         _loc11_ = 0;
      }
      var _loc8_:int = _loc9_ & 1;
      _loc13_ = _loc11_ & 1;
      _loc1_ = _loc13_ - _loc8_;
      loop3:
      while(true)
      {
         if(_loc1_ <= -1)
         {
            _loc9_ = li32(_loc15_ + 4);
            _loc5_ = li32(_loc9_ + 8);
            var _temp_8:* = _loc5_ & 1;
            _loc11_ = _loc12_;
            _loc14_ = _loc15_;
            if(_temp_8 == 0)
            {
               _loc13_ = li32(_loc9_ + 4);
               _loc13_ = li8(_loc13_ + 8);
               var _temp_11:* = _loc13_ & 1;
               _loc14_ = _loc15_;
               if(_temp_11 == 0)
               {
                  _loc13_ = _loc5_ | 1;
                  si32(_loc13_,_loc9_ + 8);
                  _loc11_ = li32(_loc15_ + 8);
                  _loc9_ = _loc11_ & -2;
                  _loc14_ = li32(_loc9_ + 4);
                  _loc5_ = li32(_loc14_ + 8);
                  _loc13_ = _loc5_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc13_ = _loc5_ & -2;
                     si32(_loc13_,_loc9_ + 4);
                     _loc13_ = li32(_loc14_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc9_;
                     si32(_loc13_,_loc14_ + 8);
                     _loc13_ = li32(_loc15_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc15_ + 8);
                     _loc13_ = _loc13_ & 1 | li32((_loc9_ = _loc14_ & -2) + 4);
                     si32(_loc13_,_loc15_ + 8);
                     si32(_loc15_,_loc9_ + 4);
                     _loc13_ = li32(_loc15_ + 8);
                     _loc14_ = _loc13_ & -2;
                     _loc11_ = li32(_loc14_ + 8);
                     _loc13_ = _loc11_ & 1;
                     if(_loc13_ != 0)
                     {
                        _loc13_ = _loc11_ & -2;
                        si32(_loc13_,_loc14_ + 8);
                        _loc8_ = li32(_loc15_ + 8);
                        _loc13_ = _loc8_ | 1;
                        si32(_loc13_,_loc15_ + 8);
                        _loc13_ = _loc8_ & -2;
                        _loc8_ = li32(_loc13_ + 4);
                        _loc8_ = _loc8_ | 1;
                        si32(_loc8_,_loc15_ + 8);
                        si32(_loc15_,_loc13_ + 4);
                        si32(_loc13_,_loc9_ + 4);
                     }
                     else
                     {
                        si32(_loc14_,_loc15_ + 8);
                     }
                  }
                  else
                  {
                     _loc13_ = _loc11_ | 1;
                     si32(_loc13_,_loc15_ + 8);
                     _loc13_ = li32(_loc9_ + 4);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc15_ + 8);
                     si32(_loc15_,_loc9_ + 4);
                  }
                  _loc13_ = li32(_loc9_ + 8);
                  _loc13_ = _loc13_ & -2;
                  si32(_loc13_,_loc9_ + 8);
                  _loc14_ = _loc4_ - 32;
                  _loc13_ = _loc14_ | 4;
                  si32(_loc9_,_loc13_);
               }
               addr0680:
               _loc11_ = _loc12_;
               if(_loc15_ == _loc10_)
               {
                  break;
               }
            }
         }
         else
         {
            while(true)
            {
               if(_loc1_ != 0)
               {
                  _loc9_ = _loc15_;
                  if(_loc1_ == 1)
                  {
                     _loc5_ = _loc15_ + 8;
                     _loc11_ = _loc12_;
                  }
                  else
                  {
                     §§goto(addr0680);
                  }
               }
               else
               {
                  _loc5_ = _loc15_ + 8;
                  _loc13_ = li32(_loc15_ + 8);
                  var _temp_44:* = _loc13_ & -2;
                  _loc11_ = _loc4_ - 32;
                  if(_temp_44 == _loc12_)
                  {
                     _loc14_ = li32(_loc15_ + 4);
                     _loc11_ = _loc12_;
                     if(_loc14_ != _loc12_)
                     {
                        _loc13_ = li32(_loc14_ + 8);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_ + 4);
                        _loc13_ = li32(_loc14_ + 8);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc14_ + 8);
                        var _temp_52:* = _loc15_ & -2;
                        _loc13_ = (_loc8_ = (_loc8_ = li32(_loc15_ + 8)) & 1) | _temp_52;
                        si32(_loc13_,_loc14_ + 8);
                        _loc13_ = li32(_loc15_ + 8);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc15_ + 8);
                        _loc13_ = li32(_loc14_ + 8);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc12_;
                        si32(_loc13_,_loc14_ + 8);
                        _loc11_ = _loc14_;
                     }
                     _loc14_ = _loc4_ - 32;
                     _loc13_ = _loc14_ | 4;
                     si32(_loc11_,_loc13_);
                     _loc11_ = _loc12_;
                     _loc9_ = _loc15_;
                     if(_loc1_ != 1)
                     {
                        §§goto(addr0680);
                     }
                  }
               }
               _loc1_ = li32(_loc5_);
               _loc9_ = _loc1_ & -2;
               _loc13_ = li32(_loc9_ + 4);
               _loc13_ = li8(_loc13_ + 8);
               _loc13_ = _loc13_ & 1;
               _loc14_ = _loc15_;
               if(_loc13_ == 0)
               {
                  _loc14_ = li32(_loc15_ + 4);
                  _loc9_ = li32(_loc14_ + 8);
                  _loc13_ = _loc9_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc9_ &= -2;
                     _loc6_ = li32(_loc9_ + 4);
                     _loc13_ = li8(_loc6_ + 8);
                     _loc13_ = _loc13_ & 1;
                     if(_loc13_ != 0)
                     {
                        var _temp_72:* = _loc1_ & 1;
                        _loc13_ = (_loc8_ = (_loc8_ = li32(_loc9_ + 8)) & -2) | _temp_72;
                        si32(_loc13_,_loc9_ + 8);
                        _loc13_ = li32(_loc6_ + 8);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc6_ + 8);
                        _loc8_ = li32(_loc14_ + 8);
                        var _temp_79:* = _loc8_ & 1;
                        _loc13_ = (_loc8_ = li32((_loc9_ = _loc8_ & -2) + 4)) | _temp_79;
                        si32(_loc13_,_loc14_ + 8);
                        si32(_loc14_,_loc9_ + 4);
                        si32(_loc9_,_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc9_ + 8);
                        _loc13_ = li32(_loc5_);
                        var _temp_89:* = _loc13_ & 1;
                        var _loc7_:int;
                        _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_89;
                        si32(_loc8_,_loc5_);
                        si32(_loc15_,_loc13_ + 4);
                        _loc8_ = li32(_loc9_ + 8);
                        _loc8_ = _loc8_ & 1;
                        _loc13_ = _loc8_ | _loc13_;
                        si32(_loc13_,_loc9_ + 8);
                     }
                     else
                     {
                        var _temp_94:* = _loc1_ & 1;
                        _loc13_ = _loc9_ | _temp_94;
                        si32(_loc13_,_loc14_ + 8);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc9_ + 8);
                        _loc9_ = li32(_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc9_ + 8);
                        _loc13_ = li32(_loc5_);
                        var _temp_107:* = _loc13_ & 1;
                        _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_107;
                        si32(_loc8_,_loc5_);
                        si32(_loc15_,_loc13_ + 4);
                        _loc8_ = li32(_loc9_ + 8);
                        _loc8_ = _loc8_ & 1;
                        _loc13_ = _loc8_ | _loc13_;
                        si32(_loc13_,_loc9_ + 8);
                     }
                     _loc13_ = li32(_loc5_);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc5_);
                  }
                  else
                  {
                     _loc13_ = _loc1_ | 1;
                     si32(_loc13_,_loc5_);
                     _loc9_ = li32(_loc14_ + 4);
                     _loc1_ = li32(_loc9_ + 8);
                     _loc13_ = _loc1_ & 1;
                     if(_loc13_ != 0)
                     {
                        _loc13_ = _loc1_ & -2;
                        si32(_loc13_,_loc9_ + 8);
                        _loc9_ = li32(_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_ + 4);
                        _loc13_ = li32(_loc9_ + 8);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc9_ + 8);
                        _loc13_ = li32(_loc5_);
                        var _temp_127:* = _loc13_ & 1;
                        _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_127;
                        si32(_loc8_,_loc5_);
                        si32(_loc15_,_loc13_ + 4);
                        _loc8_ = li32(_loc9_ + 8);
                        _loc8_ = _loc8_ & 1;
                        _loc13_ = _loc8_ | _loc13_;
                        si32(_loc13_,_loc9_ + 8);
                     }
                     else
                     {
                        _loc13_ = li32(_loc14_ + 8);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc14_ + 8);
                        _loc8_ = li32(_loc5_);
                        var _temp_137:* = _loc8_ & 1;
                        _loc13_ = (_loc8_ = li32((_loc9_ = _loc8_ & -2) + 4)) | _temp_137;
                        si32(_loc13_,_loc5_);
                        si32(_loc15_,_loc9_ + 4);
                     }
                  }
                  _loc14_ = _loc4_ - 32;
                  _loc13_ = _loc14_ | 4;
                  si32(_loc9_,_loc13_);
               }
               break;
            }
         }
         while(true)
         {
            loop1:
            while(true)
            {
               _loc15_ = _loc14_;
               _loc14_ = _loc9_;
               while(true)
               {
                  _loc9_ = _loc5_ = 1;
                  if(uint(_loc14_) <= uint(_loc10_))
                  {
                     _loc9_ = 0;
                  }
                  if(uint(_loc14_) >= uint(_loc10_))
                  {
                     _loc5_ = 0;
                  }
                  _loc13_ = _loc9_ & 1;
                  _loc8_ = _loc5_ & 1;
                  _loc13_ = _loc8_ - _loc13_;
                  if(_loc13_ > -1)
                  {
                     break loop1;
                  }
                  _loc9_ = li32(_loc14_ + 4);
                  if(_loc12_ == _loc9_)
                  {
                     break;
                  }
                  _loc5_ = li32(_loc9_ + 8);
                  _loc13_ = _loc5_ & 1;
                  if(_loc13_ == 0)
                  {
                     _loc13_ = li32(_loc9_ + 4);
                     _loc13_ = li8(_loc13_ + 8);
                     _loc13_ = _loc13_ & 1;
                     if(_loc13_ == 0)
                     {
                        _loc13_ = _loc5_ | 1;
                        si32(_loc13_,_loc9_ + 8);
                        _loc5_ = li32(_loc14_ + 8);
                        _loc9_ = _loc5_ & -2;
                        _loc1_ = li32(_loc9_ + 4);
                        _loc6_ = li32(_loc1_ + 8);
                        _loc13_ = _loc6_ & 1;
                        if(_loc13_ != 0)
                        {
                           _loc13_ = _loc6_ & -2;
                           si32(_loc13_,_loc9_ + 4);
                           _loc13_ = li32(_loc1_ + 8);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc9_;
                           si32(_loc13_,_loc1_ + 8);
                           _loc13_ = li32(_loc14_ + 8);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc1_;
                           si32(_loc13_,_loc14_ + 8);
                           _loc13_ = _loc13_ & 1 | li32((_loc9_ = _loc1_ & -2) + 4);
                           si32(_loc13_,_loc14_ + 8);
                           si32(_loc14_,_loc9_ + 4);
                           _loc13_ = li32(_loc14_ + 8);
                           _loc5_ = _loc13_ & -2;
                           _loc1_ = li32(_loc5_ + 8);
                           _loc13_ = _loc1_ & 1;
                           if(_loc13_ != 0)
                           {
                              _loc13_ = _loc1_ & -2;
                              si32(_loc13_,_loc5_ + 8);
                              _loc8_ = li32(_loc14_ + 8);
                              _loc13_ = _loc8_ | 1;
                              si32(_loc13_,_loc14_ + 8);
                              _loc13_ = _loc8_ & -2;
                              _loc8_ = li32(_loc13_ + 4);
                              _loc8_ = _loc8_ | 1;
                              si32(_loc8_,_loc14_ + 8);
                              si32(_loc14_,_loc13_ + 4);
                              si32(_loc13_,_loc9_ + 4);
                           }
                           else
                           {
                              si32(_loc5_,_loc14_ + 8);
                           }
                        }
                        else
                        {
                           _loc13_ = _loc5_ | 1;
                           si32(_loc13_,_loc14_ + 8);
                           _loc13_ = li32(_loc9_ + 4);
                           _loc13_ = _loc13_ | 1;
                           si32(_loc13_,_loc14_ + 8);
                           si32(_loc14_,_loc9_ + 4);
                        }
                        _loc13_ = li32(_loc15_ + 4);
                        if(_loc13_ == _loc14_)
                        {
                           si32(_loc9_,_loc15_ + 4);
                           _loc14_ = _loc9_;
                        }
                        else
                        {
                           _loc13_ = li32(_loc15_ + 8);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc9_;
                           si32(_loc13_,_loc15_ + 8);
                           _loc14_ = _loc9_;
                        }
                        continue;
                     }
                  }
                  continue loop1;
               }
               _loc13_ = li32(_loc11_ + 4);
               if(_loc13_ == _loc10_)
               {
                  si32(_loc14_,_loc11_ + 4);
               }
               else
               {
                  _loc13_ = li32(_loc11_ + 8);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc14_;
                  si32(_loc13_,_loc11_ + 8);
               }
               _loc13_ = li32(_loc10_ + 4);
               si32(_loc13_,_loc14_ + 4);
               _loc13_ = li32(_loc10_ + 8);
               _loc13_ = _loc13_ & -2;
               _loc8_ = li32(_loc14_ + 8);
               _loc8_ = _loc8_ & 1;
               _loc8_ = _loc8_ | _loc13_;
               si32(_loc8_,_loc14_ + 8);
               _loc8_ = li32(_loc10_ + 8);
               _loc8_ = _loc8_ & 1;
               _loc13_ = _loc8_ | _loc13_;
               si32(_loc13_,_loc14_ + 8);
               _loc13_ = li32(_loc15_ + 4);
               if(_loc13_ == _loc14_)
               {
                  si32(_loc12_,_loc15_ + 4);
                  break loop3;
               }
               _loc13_ = li32(_loc15_ + 8);
               _loc13_ = _loc13_ & 1;
               _loc13_ = _loc13_ | _loc12_;
               si32(_loc13_,_loc15_ + 8);
               break loop3;
            }
            _loc5_ = li32(_loc14_ + 8);
            _loc9_ = _loc5_ & -2;
            if(_loc14_ == _loc10_)
            {
               _loc11_ = _loc15_;
               if(_loc9_ == _loc12_)
               {
                  _loc10_ = li32(_loc14_ + 4);
                  if(_loc10_ != _loc12_)
                  {
                     _loc13_ = li32(_loc10_ + 8);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc10_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc10_ + 8);
                     var _temp_202:* = _loc14_ & -2;
                     _loc13_ = (_loc8_ = (_loc8_ = li32(_loc14_ + 8)) & 1) | _temp_202;
                     si32(_loc13_,_loc10_ + 8);
                     _loc13_ = li32(_loc14_ + 8);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc14_ + 8);
                     _loc13_ = li32(_loc10_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc12_;
                     si32(_loc13_,_loc10_ + 8);
                     _loc12_ = _loc10_;
                  }
                  _loc13_ = li32(_loc15_ + 4);
                  if(_loc13_ == _loc14_)
                  {
                     si32(_loc12_,_loc15_ + 4);
                     break loop3;
                  }
                  _loc13_ = li32(_loc15_ + 8);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc12_;
                  si32(_loc13_,_loc15_ + 8);
                  break loop3;
               }
            }
            _loc13_ = li32(_loc9_ + 4);
            _loc13_ = li8(_loc13_ + 8);
            _loc13_ = _loc13_ & 1;
            if(_loc13_ == 0)
            {
               _loc1_ = li32(_loc14_ + 4);
               _loc9_ = li32(_loc1_ + 8);
               _loc13_ = _loc9_ & 1;
               if(_loc13_ != 0)
               {
                  _loc9_ &= -2;
                  _loc6_ = li32(_loc9_ + 4);
                  _loc13_ = li8(_loc6_ + 8);
                  _loc13_ = _loc13_ & 1;
                  if(_loc13_ != 0)
                  {
                     var _temp_224:* = _loc5_ & 1;
                     _loc13_ = (_loc8_ = (_loc8_ = li32(_loc9_ + 8)) & -2) | _temp_224;
                     si32(_loc13_,_loc9_ + 8);
                     _loc13_ = li32(_loc6_ + 8);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc6_ + 8);
                     _loc8_ = li32(_loc1_ + 8);
                     var _temp_231:* = _loc8_ & 1;
                     _loc13_ = (_loc8_ = li32((_loc9_ = _loc8_ & -2) + 4)) | _temp_231;
                     si32(_loc13_,_loc1_ + 8);
                     si32(_loc1_,_loc9_ + 4);
                     si32(_loc9_,_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc9_ + 8);
                     _loc13_ = li32(_loc14_ + 8);
                     var _temp_241:* = _loc13_ & 1;
                     _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_241;
                     si32(_loc8_,_loc14_ + 8);
                     si32(_loc14_,_loc13_ + 4);
                     _loc8_ = li32(_loc9_ + 8);
                     _loc8_ = _loc8_ & 1;
                     _loc13_ = _loc8_ | _loc13_;
                     si32(_loc13_,_loc9_ + 8);
                  }
                  else
                  {
                     var _temp_246:* = _loc5_ & 1;
                     _loc13_ = _loc9_ | _temp_246;
                     si32(_loc13_,_loc1_ + 8);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc9_ + 8);
                     _loc9_ = li32(_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc9_ + 8);
                     _loc13_ = li32(_loc14_ + 8);
                     var _temp_259:* = _loc13_ & 1;
                     _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_259;
                     si32(_loc8_,_loc14_ + 8);
                     si32(_loc14_,_loc13_ + 4);
                     _loc8_ = li32(_loc9_ + 8);
                     _loc8_ = _loc8_ & 1;
                     _loc13_ = _loc8_ | _loc13_;
                     si32(_loc13_,_loc9_ + 8);
                  }
                  _loc13_ = li32(_loc14_ + 8);
                  _loc13_ = _loc13_ | 1;
                  si32(_loc13_,_loc14_ + 8);
               }
               else
               {
                  _loc13_ = _loc9_ | 1;
                  si32(_loc13_,_loc1_ + 8);
                  _loc5_ = li32(_loc1_ + 4);
                  _loc9_ = li32(_loc5_ + 8);
                  _loc13_ = _loc9_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc13_ = _loc9_ & -2;
                     si32(_loc13_,_loc5_ + 8);
                     _loc9_ = li32(_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 8);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc9_ + 8);
                     _loc13_ = li32(_loc14_ + 8);
                     var _temp_280:* = _loc13_ & 1;
                     _loc8_ = (_loc7_ = li32((_loc13_ &= -2) + 4)) | _temp_280;
                     si32(_loc8_,_loc14_ + 8);
                     si32(_loc14_,_loc13_ + 4);
                     _loc8_ = li32(_loc9_ + 8);
                     _loc8_ = _loc8_ & 1;
                     _loc13_ = _loc8_ | _loc13_;
                     si32(_loc13_,_loc9_ + 8);
                  }
                  else
                  {
                     _loc8_ = li32(_loc14_ + 8);
                     var _temp_288:* = _loc8_ & 1;
                     _loc13_ = (_loc8_ = li32((_loc9_ = _loc8_ & -2) + 4)) | _temp_288;
                     si32(_loc13_,_loc14_ + 8);
                     si32(_loc14_,_loc9_ + 4);
                  }
               }
               _loc13_ = li32(_loc15_ + 4);
               if(_loc13_ == _loc14_)
               {
                  si32(_loc9_,_loc15_ + 4);
                  _loc14_ = _loc15_;
               }
               else
               {
                  _loc13_ = li32(_loc15_ + 8);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc9_;
                  si32(_loc13_,_loc15_ + 8);
                  _loc14_ = _loc15_;
               }
            }
         }
         break;
      }
      _loc13_ = _loc4_ - 32;
      _loc13_ = _loc13_ | 4;
      _loc13_ = li32(_loc13_);
      si32(_loc13_,_loc3_);
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

