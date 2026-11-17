package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_run_tree_remove() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc15_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc14_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc2_ -= 16;
      _loc3_ = li32(_loc4_);
      _loc15_ = li32(_loc3_);
      si32(_loc15_,_loc4_ - 16);
      _loc14_ = _loc4_ - 16;
      _loc13_ = _loc14_ | 4;
      _loc12_ = _loc3_ + 4;
      var _loc11_:int = _loc12_ & -2;
      si32(_loc11_,_loc13_);
      _loc10_ = 1;
      _loc9_ = li32(_loc4_ + 4);
      _loc8_ = _loc10_;
      if(uint(_loc15_) <= uint(_loc9_))
      {
         _loc8_ = 0;
      }
      if(uint(_loc15_) >= uint(_loc9_))
      {
         _loc10_ = 0;
      }
      _loc13_ = _loc8_ & 1;
      _loc11_ = _loc10_ & 1;
      _loc1_ = _loc11_ - _loc13_;
      loop3:
      while(true)
      {
         if(_loc1_ <= -1)
         {
            _loc8_ = li32(_loc15_);
            _loc5_ = li32(_loc8_ + 4);
            var _temp_9:* = _loc5_ & 1;
            _loc10_ = _loc12_;
            _loc14_ = _loc15_;
            if(_temp_9 == 0)
            {
               _loc13_ = li32(_loc8_);
               _loc13_ = li8(_loc13_ + 4);
               var _temp_12:* = _loc13_ & 1;
               _loc14_ = _loc15_;
               if(_temp_12 == 0)
               {
                  _loc13_ = _loc5_ | 1;
                  si32(_loc13_,_loc8_ + 4);
                  _loc10_ = li32(_loc15_ + 4);
                  _loc8_ = _loc10_ & -2;
                  _loc14_ = li32(_loc8_);
                  _loc5_ = li32(_loc14_ + 4);
                  _loc13_ = _loc5_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc13_ = _loc5_ & -2;
                     si32(_loc13_,_loc8_);
                     _loc13_ = li32(_loc14_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc8_;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc15_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc15_ + 4);
                     _loc13_ = _loc13_ & 1 | li32(_loc8_ = _loc14_ & -2);
                     si32(_loc13_,_loc15_ + 4);
                     si32(_loc15_,_loc8_);
                     _loc13_ = li32(_loc15_ + 4);
                     _loc14_ = _loc13_ & -2;
                     _loc10_ = li32(_loc14_ + 4);
                     _loc13_ = _loc10_ & 1;
                     if(_loc13_ != 0)
                     {
                        _loc13_ = _loc10_ & -2;
                        si32(_loc13_,_loc14_ + 4);
                        _loc13_ = li32(_loc15_ + 4);
                        _loc11_ = _loc13_ | 1;
                        si32(_loc11_,_loc15_ + 4);
                        _loc13_ &= -2;
                        _loc11_ = li32(_loc13_);
                        _loc11_ = _loc11_ | 1;
                        si32(_loc11_,_loc15_ + 4);
                        si32(_loc15_,_loc13_);
                        si32(_loc13_,_loc8_);
                     }
                     else
                     {
                        si32(_loc14_,_loc15_ + 4);
                     }
                  }
                  else
                  {
                     _loc13_ = _loc10_ | 1;
                     si32(_loc13_,_loc15_ + 4);
                     _loc13_ = li32(_loc8_);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc15_ + 4);
                     si32(_loc15_,_loc8_);
                  }
                  _loc13_ = li32(_loc8_ + 4);
                  _loc13_ = _loc13_ & -2;
                  si32(_loc13_,_loc8_ + 4);
                  si32(_loc8_,_loc4_ - 16);
                  _loc14_ = _loc4_ - 16;
               }
               addr0613:
               _loc10_ = _loc12_;
               if(_loc15_ == _loc9_)
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
                  _loc8_ = _loc15_;
                  if(_loc1_ == 1)
                  {
                     _loc5_ = _loc15_ + 4;
                     _loc10_ = _loc12_;
                  }
                  else
                  {
                     §§goto(addr0613);
                  }
               }
               else
               {
                  _loc5_ = _loc15_ + 4;
                  _loc13_ = li32(_loc15_ + 4);
                  var _temp_44:* = _loc13_ & -2;
                  _loc10_ = _loc4_ - 16;
                  if(_temp_44 == _loc12_)
                  {
                     _loc10_ = li32(_loc15_);
                     _loc14_ = _loc12_;
                     if(_loc10_ != _loc12_)
                     {
                        _loc13_ = li32(_loc10_ + 4);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_);
                        _loc13_ = li32(_loc10_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc10_ + 4);
                        var _temp_52:* = _loc15_ & -2;
                        _loc13_ = (_loc11_ = (_loc11_ = li32(_loc15_ + 4)) & 1) | _temp_52;
                        si32(_loc13_,_loc10_ + 4);
                        _loc13_ = li32(_loc15_ + 4);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc15_ + 4);
                        _loc13_ = li32(_loc10_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc12_;
                        si32(_loc13_,_loc10_ + 4);
                        _loc14_ = _loc10_;
                     }
                     si32(_loc14_,_loc4_ - 16);
                     _loc14_ = _loc4_ - 16;
                     _loc10_ = _loc12_;
                     _loc8_ = _loc15_;
                     if(_loc1_ != 1)
                     {
                        §§goto(addr0613);
                     }
                  }
               }
               _loc1_ = li32(_loc5_);
               _loc8_ = _loc1_ & -2;
               _loc13_ = li32(_loc8_);
               _loc13_ = li8(_loc13_ + 4);
               _loc13_ = _loc13_ & 1;
               _loc14_ = _loc15_;
               if(_loc13_ == 0)
               {
                  _loc14_ = li32(_loc15_);
                  _loc8_ = li32(_loc14_ + 4);
                  _loc13_ = _loc8_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc6_ = _loc8_ & -2;
                     _loc8_ = li32(_loc6_);
                     _loc13_ = li8(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     if(_loc13_ != 0)
                     {
                        var _temp_71:* = _loc1_ & 1;
                        _loc13_ = (_loc11_ = (_loc11_ = li32(_loc6_ + 4)) & -2) | _temp_71;
                        si32(_loc13_,_loc6_ + 4);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc8_ + 4);
                        _loc11_ = li32(_loc14_ + 4);
                        var _temp_78:* = _loc11_ & 1;
                        _loc13_ = (_loc11_ = li32(_loc8_ = _loc11_ & -2)) | _temp_78;
                        si32(_loc13_,_loc14_ + 4);
                        si32(_loc14_,_loc8_);
                        si32(_loc8_,_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc8_ + 4);
                        _loc13_ = li32(_loc5_);
                        var _temp_88:* = _loc13_ & 1;
                        var _loc7_:int;
                        _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_88;
                        si32(_loc11_,_loc5_);
                        si32(_loc15_,_loc13_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc13_ = _loc11_ | _loc13_;
                        si32(_loc13_,_loc8_ + 4);
                     }
                     else
                     {
                        var _temp_93:* = _loc1_ & 1;
                        _loc13_ = _loc6_ | _temp_93;
                        si32(_loc13_,_loc14_ + 4);
                        _loc13_ = li32(_loc6_ + 4);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc6_ + 4);
                        _loc8_ = li32(_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc8_ + 4);
                        _loc13_ = li32(_loc5_);
                        var _temp_106:* = _loc13_ & 1;
                        _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_106;
                        si32(_loc11_,_loc5_);
                        si32(_loc15_,_loc13_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc13_ = _loc11_ | _loc13_;
                        si32(_loc13_,_loc8_ + 4);
                     }
                     _loc13_ = li32(_loc5_);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc5_);
                  }
                  else
                  {
                     _loc13_ = _loc1_ | 1;
                     si32(_loc13_,_loc5_);
                     _loc8_ = li32(_loc14_);
                     _loc1_ = li32(_loc8_ + 4);
                     _loc13_ = _loc1_ & 1;
                     if(_loc13_ != 0)
                     {
                        _loc13_ = _loc1_ & -2;
                        si32(_loc13_,_loc8_ + 4);
                        _loc8_ = li32(_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & -2;
                        si32(_loc13_,_loc15_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc13_ = _loc13_ | _loc15_;
                        si32(_loc13_,_loc8_ + 4);
                        _loc13_ = li32(_loc5_);
                        var _temp_126:* = _loc13_ & 1;
                        _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_126;
                        si32(_loc11_,_loc5_);
                        si32(_loc15_,_loc13_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc13_ = _loc11_ | _loc13_;
                        si32(_loc13_,_loc8_ + 4);
                     }
                     else
                     {
                        _loc13_ = li32(_loc14_ + 4);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc14_ + 4);
                        _loc11_ = li32(_loc5_);
                        var _temp_136:* = _loc11_ & 1;
                        _loc13_ = (_loc11_ = li32(_loc8_ = _loc11_ & -2)) | _temp_136;
                        si32(_loc13_,_loc5_);
                        si32(_loc15_,_loc8_);
                     }
                  }
                  si32(_loc8_,_loc4_ - 16);
                  _loc14_ = _loc4_ - 16;
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
               _loc14_ = _loc8_;
               while(true)
               {
                  _loc5_ = _loc8_ = 1;
                  if(uint(_loc14_) <= uint(_loc9_))
                  {
                     _loc5_ = 0;
                  }
                  if(uint(_loc14_) >= uint(_loc9_))
                  {
                     _loc8_ = 0;
                  }
                  _loc11_ = _loc5_ & 1;
                  _loc13_ = _loc8_ & 1;
                  _loc13_ = _loc13_ - _loc11_;
                  if(_loc13_ > -1)
                  {
                     break loop1;
                  }
                  _loc8_ = li32(_loc14_);
                  if(_loc12_ == _loc8_)
                  {
                     break;
                  }
                  _loc5_ = li32(_loc8_ + 4);
                  _loc13_ = _loc5_ & 1;
                  if(_loc13_ == 0)
                  {
                     _loc13_ = li32(_loc8_);
                     _loc13_ = li8(_loc13_ + 4);
                     _loc13_ = _loc13_ & 1;
                     if(_loc13_ == 0)
                     {
                        _loc13_ = _loc5_ | 1;
                        si32(_loc13_,_loc8_ + 4);
                        _loc6_ = li32(_loc14_ + 4);
                        _loc8_ = _loc6_ & -2;
                        _loc1_ = li32(_loc8_);
                        _loc5_ = li32(_loc1_ + 4);
                        _loc13_ = _loc5_ & 1;
                        if(_loc13_ != 0)
                        {
                           _loc13_ = _loc5_ & -2;
                           si32(_loc13_,_loc8_);
                           _loc13_ = li32(_loc1_ + 4);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc8_;
                           si32(_loc13_,_loc1_ + 4);
                           _loc13_ = li32(_loc14_ + 4);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc1_;
                           si32(_loc13_,_loc14_ + 4);
                           _loc13_ = _loc13_ & 1 | li32(_loc8_ = _loc1_ & -2);
                           si32(_loc13_,_loc14_ + 4);
                           si32(_loc14_,_loc8_);
                           _loc13_ = li32(_loc14_ + 4);
                           _loc1_ = _loc13_ & -2;
                           _loc5_ = li32(_loc1_ + 4);
                           _loc13_ = _loc5_ & 1;
                           if(_loc13_ != 0)
                           {
                              _loc13_ = _loc5_ & -2;
                              si32(_loc13_,_loc1_ + 4);
                              _loc11_ = li32(_loc14_ + 4);
                              _loc13_ = _loc11_ | 1;
                              si32(_loc13_,_loc14_ + 4);
                              _loc13_ = _loc11_ & -2;
                              _loc11_ = li32(_loc13_);
                              _loc11_ = _loc11_ | 1;
                              si32(_loc11_,_loc14_ + 4);
                              si32(_loc14_,_loc13_);
                              si32(_loc13_,_loc8_);
                           }
                           else
                           {
                              si32(_loc1_,_loc14_ + 4);
                           }
                        }
                        else
                        {
                           _loc13_ = _loc6_ | 1;
                           si32(_loc13_,_loc14_ + 4);
                           _loc13_ = li32(_loc8_);
                           _loc13_ = _loc13_ | 1;
                           si32(_loc13_,_loc14_ + 4);
                           si32(_loc14_,_loc8_);
                        }
                        _loc13_ = li32(_loc15_);
                        if(_loc13_ == _loc14_)
                        {
                           si32(_loc8_,_loc15_);
                           _loc14_ = _loc8_;
                        }
                        else
                        {
                           _loc13_ = li32(_loc15_ + 4);
                           _loc13_ = _loc13_ & 1;
                           _loc13_ = _loc13_ | _loc8_;
                           si32(_loc13_,_loc15_ + 4);
                           _loc14_ = _loc8_;
                        }
                        continue;
                     }
                  }
                  continue loop1;
               }
               _loc13_ = li32(_loc10_);
               if(_loc13_ == _loc9_)
               {
                  si32(_loc14_,_loc10_);
               }
               else
               {
                  _loc13_ = li32(_loc10_ + 4);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc14_;
                  si32(_loc13_,_loc10_ + 4);
               }
               _loc13_ = li32(_loc9_);
               si32(_loc13_,_loc14_);
               _loc13_ = li32(_loc9_ + 4);
               _loc13_ = _loc13_ & -2;
               _loc11_ = li32(_loc14_ + 4);
               _loc11_ = _loc11_ & 1;
               _loc11_ = _loc11_ | _loc13_;
               si32(_loc11_,_loc14_ + 4);
               _loc11_ = li32(_loc9_ + 4);
               _loc11_ = _loc11_ & 1;
               _loc13_ = _loc11_ | _loc13_;
               si32(_loc13_,_loc14_ + 4);
               _loc13_ = li32(_loc15_);
               if(_loc13_ == _loc14_)
               {
                  si32(_loc12_,_loc15_);
                  break loop3;
               }
               _loc13_ = li32(_loc15_ + 4);
               _loc13_ = _loc13_ & 1;
               _loc13_ = _loc13_ | _loc12_;
               si32(_loc13_,_loc15_ + 4);
               break loop3;
            }
            _loc5_ = li32(_loc14_ + 4);
            _loc8_ = _loc5_ & -2;
            if(_loc14_ == _loc9_)
            {
               _loc10_ = _loc15_;
               if(_loc8_ == _loc12_)
               {
                  _loc9_ = li32(_loc14_);
                  if(_loc9_ != _loc12_)
                  {
                     _loc13_ = li32(_loc9_ + 4);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_);
                     _loc13_ = li32(_loc9_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc9_ + 4);
                     var _temp_200:* = _loc14_ & -2;
                     _loc13_ = (_loc11_ = (_loc11_ = li32(_loc14_ + 4)) & 1) | _temp_200;
                     si32(_loc13_,_loc9_ + 4);
                     _loc13_ = li32(_loc14_ + 4);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc14_ + 4);
                     _loc13_ = li32(_loc9_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc12_;
                     si32(_loc13_,_loc9_ + 4);
                     _loc12_ = _loc9_;
                  }
                  _loc13_ = li32(_loc15_);
                  if(_loc13_ == _loc14_)
                  {
                     si32(_loc12_,_loc15_);
                     break loop3;
                  }
                  _loc13_ = li32(_loc15_ + 4);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc12_;
                  si32(_loc13_,_loc15_ + 4);
                  break loop3;
               }
            }
            _loc13_ = li32(_loc8_);
            _loc13_ = li8(_loc13_ + 4);
            _loc13_ = _loc13_ & 1;
            if(_loc13_ == 0)
            {
               _loc1_ = li32(_loc14_);
               _loc8_ = li32(_loc1_ + 4);
               _loc13_ = _loc8_ & 1;
               if(_loc13_ != 0)
               {
                  _loc6_ = _loc8_ & -2;
                  _loc8_ = li32(_loc6_);
                  _loc13_ = li8(_loc8_ + 4);
                  _loc13_ = _loc13_ & 1;
                  if(_loc13_ != 0)
                  {
                     var _temp_222:* = _loc5_ & 1;
                     _loc13_ = (_loc11_ = (_loc11_ = li32(_loc6_ + 4)) & -2) | _temp_222;
                     si32(_loc13_,_loc6_ + 4);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc8_ + 4);
                     _loc11_ = li32(_loc1_ + 4);
                     var _temp_229:* = _loc11_ & 1;
                     _loc13_ = (_loc11_ = li32(_loc8_ = _loc11_ & -2)) | _temp_229;
                     si32(_loc13_,_loc1_ + 4);
                     si32(_loc1_,_loc8_);
                     si32(_loc8_,_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc8_ + 4);
                     _loc13_ = li32(_loc14_ + 4);
                     var _temp_239:* = _loc13_ & 1;
                     _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_239;
                     si32(_loc11_,_loc14_ + 4);
                     si32(_loc14_,_loc13_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc13_ = _loc11_ | _loc13_;
                     si32(_loc13_,_loc8_ + 4);
                  }
                  else
                  {
                     var _temp_244:* = _loc5_ & 1;
                     _loc13_ = _loc6_ | _temp_244;
                     si32(_loc13_,_loc1_ + 4);
                     _loc13_ = li32(_loc6_ + 4);
                     _loc13_ = _loc13_ | 1;
                     si32(_loc13_,_loc6_ + 4);
                     _loc8_ = li32(_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc8_ + 4);
                     _loc13_ = li32(_loc14_ + 4);
                     var _temp_257:* = _loc13_ & 1;
                     _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_257;
                     si32(_loc11_,_loc14_ + 4);
                     si32(_loc14_,_loc13_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc13_ = _loc11_ | _loc13_;
                     si32(_loc13_,_loc8_ + 4);
                  }
                  _loc13_ = li32(_loc14_ + 4);
                  _loc13_ = _loc13_ | 1;
                  si32(_loc13_,_loc14_ + 4);
               }
               else
               {
                  _loc13_ = _loc8_ | 1;
                  si32(_loc13_,_loc1_ + 4);
                  _loc8_ = li32(_loc1_);
                  _loc5_ = li32(_loc8_ + 4);
                  _loc13_ = _loc5_ & 1;
                  if(_loc13_ != 0)
                  {
                     _loc13_ = _loc5_ & -2;
                     si32(_loc13_,_loc8_ + 4);
                     _loc8_ = li32(_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & -2;
                     si32(_loc13_,_loc14_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc13_ = _loc13_ | _loc14_;
                     si32(_loc13_,_loc8_ + 4);
                     _loc13_ = li32(_loc14_ + 4);
                     var _temp_278:* = _loc13_ & 1;
                     _loc11_ = (_loc7_ = li32(_loc13_ &= -2)) | _temp_278;
                     si32(_loc11_,_loc14_ + 4);
                     si32(_loc14_,_loc13_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc13_ = _loc11_ | _loc13_;
                     si32(_loc13_,_loc8_ + 4);
                  }
                  else
                  {
                     _loc11_ = li32(_loc14_ + 4);
                     var _temp_286:* = _loc11_ & 1;
                     _loc13_ = (_loc11_ = li32(_loc8_ = _loc11_ & -2)) | _temp_286;
                     si32(_loc13_,_loc14_ + 4);
                     si32(_loc14_,_loc8_);
                  }
               }
               _loc13_ = li32(_loc15_);
               if(_loc13_ == _loc14_)
               {
                  si32(_loc8_,_loc15_);
                  _loc14_ = _loc15_;
               }
               else
               {
                  _loc13_ = li32(_loc15_ + 4);
                  _loc13_ = _loc13_ & 1;
                  _loc13_ = _loc13_ | _loc8_;
                  si32(_loc13_,_loc15_ + 4);
                  _loc14_ = _loc15_;
               }
            }
         }
         break;
      }
      _loc13_ = li32(_loc4_ - 16);
      si32(_loc13_,_loc3_);
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

