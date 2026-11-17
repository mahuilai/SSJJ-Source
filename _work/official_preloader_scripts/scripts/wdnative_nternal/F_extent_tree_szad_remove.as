package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_extent_tree_szad_remove() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 24;
      _loc1_ = li32(wdnative_nternal._dss_chunks_szad);
      si32(_loc1_,_loc3_ - 24);
      _loc14_ = _loc3_ - 24;
      _loc13_ = _loc14_ | 4;
      _loc12_ = wdnative_nternal._dss_chunks_szad + 4;
      var _loc11_:int = _loc12_ & -2;
      si32(_loc11_,_loc13_);
      _loc10_ = li32(_loc1_ + 20);
      _loc9_ = li32(_loc3_);
      _loc8_ = li32(_loc9_ + 20);
      _loc6_ = _loc7_ = 1;
      if(uint(_loc8_) >= uint(_loc10_))
      {
         _loc6_ = 0;
      }
      if(uint(_loc8_) <= uint(_loc10_))
      {
         _loc7_ = 0;
      }
      _loc11_ = _loc6_ & 1;
      _loc13_ = _loc7_ & 1;
      _loc6_ = _loc13_ - _loc11_;
      if(_loc8_ == _loc10_)
      {
         _loc8_ = li32(_loc1_ + 16);
         _loc6_ = li32(_loc9_ + 16);
         _loc7_ = _loc10_ = 1;
         if(uint(_loc6_) >= uint(_loc8_))
         {
            _loc7_ = 0;
         }
         if(uint(_loc6_) <= uint(_loc8_))
         {
            _loc10_ = 0;
         }
         _loc13_ = _loc7_ & 1;
         _loc11_ = _loc10_ & 1;
         _loc6_ = _loc11_ - _loc13_;
      }
      loop3:
      while(true)
      {
         if(_loc6_ <= -1)
         {
            _loc12_ = wdnative_nternal._dss_chunks_szad + 4;
            _loc8_ = li32(_loc1_);
            _loc10_ = li32(_loc8_ + 4);
            var _temp_10:* = _loc10_ & 1;
            _loc14_ = _loc1_;
            if(_temp_10 == 0)
            {
               _loc11_ = li32(_loc8_);
               _loc11_ = li8(_loc11_ + 4);
               var _temp_13:* = _loc11_ & 1;
               _loc14_ = _loc1_;
               if(_temp_13 == 0)
               {
                  _loc11_ = _loc10_ | 1;
                  si32(_loc11_,_loc8_ + 4);
                  _loc12_ = li32(_loc1_ + 4);
                  _loc8_ = _loc12_ & -2;
                  _loc14_ = li32(_loc8_);
                  _loc10_ = li32(_loc14_ + 4);
                  _loc11_ = _loc10_ & 1;
                  if(_loc11_ != 0)
                  {
                     _loc11_ = _loc10_ & -2;
                     si32(_loc11_,_loc8_);
                     _loc11_ = li32(_loc14_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc8_;
                     si32(_loc11_,_loc14_ + 4);
                     _loc11_ = li32(_loc1_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc14_;
                     si32(_loc11_,_loc1_ + 4);
                     _loc11_ = _loc11_ & 1 | li32(_loc8_ = _loc14_ & -2);
                     si32(_loc11_,_loc1_ + 4);
                     si32(_loc1_,_loc8_);
                     _loc11_ = li32(_loc1_ + 4);
                     _loc14_ = _loc11_ & -2;
                     _loc12_ = li32(_loc14_ + 4);
                     _loc11_ = _loc12_ & 1;
                     if(_loc11_ != 0)
                     {
                        _loc11_ = _loc12_ & -2;
                        si32(_loc11_,_loc14_ + 4);
                        _loc13_ = li32(_loc1_ + 4);
                        _loc11_ = _loc13_ | 1;
                        si32(_loc11_,_loc1_ + 4);
                        _loc11_ = _loc13_ & -2;
                        _loc13_ = li32(_loc11_);
                        _loc13_ = _loc13_ | 1;
                        si32(_loc13_,_loc1_ + 4);
                        si32(_loc1_,_loc11_);
                        si32(_loc11_,_loc8_);
                     }
                     else
                     {
                        si32(_loc14_,_loc1_ + 4);
                     }
                  }
                  else
                  {
                     _loc11_ = _loc12_ | 1;
                     si32(_loc11_,_loc1_ + 4);
                     _loc11_ = li32(_loc8_);
                     _loc11_ = _loc11_ | 1;
                     si32(_loc11_,_loc1_ + 4);
                     si32(_loc1_,_loc8_);
                  }
                  _loc11_ = li32(_loc8_ + 4);
                  _loc11_ = _loc11_ & -2;
                  si32(_loc11_,_loc8_ + 4);
                  si32(_loc8_,_loc3_ - 24);
                  _loc14_ = _loc3_ - 24;
               }
               addr064f:
               _loc12_ = wdnative_nternal._dss_chunks_szad + 4;
               if(_loc6_ == 0)
               {
                  break;
               }
            }
         }
         else
         {
            while(true)
            {
               if(_loc6_ != 0)
               {
                  _loc8_ = _loc1_;
                  if(_loc6_ == 1)
                  {
                     _loc10_ = _loc1_ + 4;
                  }
                  else
                  {
                     §§goto(addr064f);
                  }
               }
               else
               {
                  _loc10_ = _loc1_ + 4;
                  _loc8_ = wdnative_nternal._dss_chunks_szad + 4;
                  _loc11_ = li32(_loc1_ + 4);
                  var _temp_45:* = _loc11_ & -2;
                  _loc12_ = _loc3_ - 24;
                  if(_temp_45 == _loc8_)
                  {
                     _loc14_ = li32(_loc1_);
                     _loc12_ = _loc8_;
                     if(_loc14_ != _loc8_)
                     {
                        _loc11_ = li32(_loc14_ + 4);
                        _loc11_ = _loc11_ & -2;
                        si32(_loc11_,_loc1_);
                        _loc11_ = li32(_loc14_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc11_ = _loc11_ | _loc1_;
                        si32(_loc11_,_loc14_ + 4);
                        var _temp_53:* = _loc1_ & -2;
                        _loc11_ = (_loc13_ = (_loc13_ = li32(_loc1_ + 4)) & 1) | _temp_53;
                        si32(_loc11_,_loc14_ + 4);
                        _loc11_ = li32(_loc1_ + 4);
                        _loc11_ = _loc11_ | 1;
                        si32(_loc11_,_loc1_ + 4);
                        var _temp_59:* = int(wdnative_nternal._dss_chunks_szad + 4);
                        _loc11_ = (_loc13_ = (_loc13_ = li32(_loc14_ + 4)) & 1) | _temp_59;
                        si32(_loc11_,_loc14_ + 4);
                        _loc12_ = _loc14_;
                     }
                     si32(_loc12_,_loc3_ - 24);
                     _loc14_ = _loc3_ - 24;
                     _loc12_ = _loc8_;
                     _loc8_ = _loc1_;
                     if(_loc6_ != 1)
                     {
                        §§goto(addr064f);
                     }
                  }
               }
               _loc6_ = li32(_loc10_);
               _loc8_ = _loc6_ & -2;
               _loc11_ = li32(_loc8_);
               _loc11_ = li8(_loc11_ + 4);
               _loc11_ = _loc11_ & 1;
               _loc14_ = _loc1_;
               if(_loc11_ == 0)
               {
                  _loc14_ = li32(_loc1_);
                  _loc8_ = li32(_loc14_ + 4);
                  _loc11_ = _loc8_ & 1;
                  if(_loc11_ != 0)
                  {
                     _loc8_ &= -2;
                     _loc7_ = li32(_loc8_);
                     _loc11_ = li8(_loc7_ + 4);
                     _loc11_ = _loc11_ & 1;
                     if(_loc11_ != 0)
                     {
                        var _temp_74:* = _loc6_ & 1;
                        _loc11_ = (_loc13_ = (_loc13_ = li32(_loc8_ + 4)) & -2) | _temp_74;
                        si32(_loc11_,_loc8_ + 4);
                        _loc11_ = li32(_loc7_ + 4);
                        _loc11_ = _loc11_ & -2;
                        si32(_loc11_,_loc7_ + 4);
                        _loc13_ = li32(_loc14_ + 4);
                        var _temp_81:* = _loc13_ & 1;
                        _loc11_ = (_loc13_ = li32(_loc8_ = _loc13_ & -2)) | _temp_81;
                        si32(_loc11_,_loc14_ + 4);
                        si32(_loc14_,_loc8_);
                        si32(_loc8_,_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & -2;
                        si32(_loc11_,_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc11_ = _loc11_ | _loc1_;
                        si32(_loc11_,_loc8_ + 4);
                        _loc11_ = li32(_loc10_);
                        var _temp_91:* = _loc11_ & 1;
                        var _loc4_:int;
                        _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_91;
                        si32(_loc13_,_loc10_);
                        si32(_loc1_,_loc11_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc11_ = _loc13_ | _loc11_;
                        si32(_loc11_,_loc8_ + 4);
                     }
                     else
                     {
                        var _temp_96:* = _loc6_ & 1;
                        _loc11_ = _loc8_ | _temp_96;
                        si32(_loc11_,_loc14_ + 4);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ | 1;
                        si32(_loc11_,_loc8_ + 4);
                        _loc8_ = li32(_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & -2;
                        si32(_loc11_,_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc11_ = _loc11_ | _loc1_;
                        si32(_loc11_,_loc8_ + 4);
                        _loc11_ = li32(_loc10_);
                        var _temp_109:* = _loc11_ & 1;
                        _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_109;
                        si32(_loc13_,_loc10_);
                        si32(_loc1_,_loc11_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc11_ = _loc13_ | _loc11_;
                        si32(_loc11_,_loc8_ + 4);
                     }
                     _loc11_ = li32(_loc10_);
                     _loc11_ = _loc11_ | 1;
                     si32(_loc11_,_loc10_);
                  }
                  else
                  {
                     _loc11_ = _loc6_ | 1;
                     si32(_loc11_,_loc10_);
                     _loc6_ = li32(_loc14_);
                     _loc8_ = li32(_loc6_ + 4);
                     _loc11_ = _loc8_ & 1;
                     if(_loc11_ != 0)
                     {
                        _loc11_ = _loc8_ & -2;
                        si32(_loc11_,_loc6_ + 4);
                        _loc8_ = li32(_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & -2;
                        si32(_loc11_,_loc1_);
                        _loc11_ = li32(_loc8_ + 4);
                        _loc11_ = _loc11_ & 1;
                        _loc11_ = _loc11_ | _loc1_;
                        si32(_loc11_,_loc8_ + 4);
                        _loc11_ = li32(_loc10_);
                        var _temp_130:* = _loc11_ & 1;
                        _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_130;
                        si32(_loc13_,_loc10_);
                        si32(_loc1_,_loc11_);
                        _loc13_ = li32(_loc8_ + 4);
                        _loc13_ = _loc13_ & 1;
                        _loc11_ = _loc13_ | _loc11_;
                        si32(_loc11_,_loc8_ + 4);
                     }
                     else
                     {
                        _loc11_ = li32(_loc14_ + 4);
                        _loc11_ = _loc11_ | 1;
                        si32(_loc11_,_loc14_ + 4);
                        _loc13_ = li32(_loc10_);
                        var _temp_140:* = _loc13_ & 1;
                        _loc11_ = (_loc13_ = li32(_loc8_ = _loc13_ & -2)) | _temp_140;
                        si32(_loc11_,_loc10_);
                        si32(_loc1_,_loc8_);
                     }
                  }
                  si32(_loc8_,_loc3_ - 24);
                  _loc14_ = _loc3_ - 24;
               }
               break;
            }
         }
         _loc6_ = wdnative_nternal._dss_chunks_szad + 4;
         while(true)
         {
            loop1:
            while(true)
            {
               _loc1_ = _loc14_;
               _loc14_ = _loc8_;
               while(true)
               {
                  _loc8_ = li32(_loc14_ + 20);
                  _loc10_ = li32(_loc9_ + 20);
                  _loc5_ = _loc7_ = 1;
                  if(uint(_loc10_) >= uint(_loc8_))
                  {
                     _loc5_ = 0;
                  }
                  if(uint(_loc10_) <= uint(_loc8_))
                  {
                     _loc7_ = 0;
                  }
                  _loc11_ = _loc5_ & 1;
                  _loc13_ = _loc7_ & 1;
                  _loc7_ = _loc13_ - _loc11_;
                  if(_loc10_ == _loc8_)
                  {
                     _loc7_ = li32(_loc14_ + 16);
                     _loc5_ = li32(_loc9_ + 16);
                     _loc8_ = _loc10_ = 1;
                     if(uint(_loc5_) >= uint(_loc7_))
                     {
                        _loc8_ = 0;
                     }
                     if(uint(_loc5_) <= uint(_loc7_))
                     {
                        _loc10_ = 0;
                     }
                     _loc13_ = _loc8_ & 1;
                     _loc11_ = _loc10_ & 1;
                     _loc7_ = _loc11_ - _loc13_;
                  }
                  if(_loc7_ > -1)
                  {
                     break loop1;
                  }
                  _loc8_ = li32(_loc14_);
                  if(_loc8_ == _loc6_)
                  {
                     break;
                  }
                  _loc10_ = li32(_loc8_ + 4);
                  _loc11_ = _loc10_ & 1;
                  if(_loc11_ == 0)
                  {
                     _loc11_ = li32(_loc8_);
                     _loc11_ = li8(_loc11_ + 4);
                     _loc11_ = _loc11_ & 1;
                     if(_loc11_ == 0)
                     {
                        _loc11_ = _loc10_ | 1;
                        si32(_loc11_,_loc8_ + 4);
                        _loc10_ = li32(_loc14_ + 4);
                        _loc8_ = _loc10_ & -2;
                        _loc7_ = li32(_loc8_);
                        _loc5_ = li32(_loc7_ + 4);
                        _loc11_ = _loc5_ & 1;
                        if(_loc11_ != 0)
                        {
                           _loc11_ = _loc5_ & -2;
                           si32(_loc11_,_loc8_);
                           _loc11_ = li32(_loc7_ + 4);
                           _loc11_ = _loc11_ & 1;
                           _loc11_ = _loc11_ | _loc8_;
                           si32(_loc11_,_loc7_ + 4);
                           _loc11_ = li32(_loc14_ + 4);
                           _loc11_ = _loc11_ & 1;
                           _loc11_ = _loc11_ | _loc7_;
                           si32(_loc11_,_loc14_ + 4);
                           _loc11_ = _loc11_ & 1 | li32(_loc8_ = _loc7_ & -2);
                           si32(_loc11_,_loc14_ + 4);
                           si32(_loc14_,_loc8_);
                           _loc11_ = li32(_loc14_ + 4);
                           _loc7_ = _loc11_ & -2;
                           _loc10_ = li32(_loc7_ + 4);
                           _loc11_ = _loc10_ & 1;
                           if(_loc11_ != 0)
                           {
                              _loc11_ = _loc10_ & -2;
                              si32(_loc11_,_loc7_ + 4);
                              _loc13_ = li32(_loc14_ + 4);
                              _loc11_ = _loc13_ | 1;
                              si32(_loc11_,_loc14_ + 4);
                              _loc11_ = _loc13_ & -2;
                              _loc13_ = li32(_loc11_);
                              _loc13_ = _loc13_ | 1;
                              si32(_loc13_,_loc14_ + 4);
                              si32(_loc14_,_loc11_);
                              si32(_loc11_,_loc8_);
                           }
                           else
                           {
                              si32(_loc7_,_loc14_ + 4);
                           }
                        }
                        else
                        {
                           _loc11_ = _loc10_ | 1;
                           si32(_loc11_,_loc14_ + 4);
                           _loc11_ = li32(_loc8_);
                           _loc11_ = _loc11_ | 1;
                           si32(_loc11_,_loc14_ + 4);
                           si32(_loc14_,_loc8_);
                        }
                        _loc11_ = li32(_loc1_);
                        if(_loc11_ == _loc14_)
                        {
                           si32(_loc8_,_loc1_);
                           _loc14_ = _loc8_;
                        }
                        else
                        {
                           _loc11_ = li32(_loc1_ + 4);
                           _loc11_ = _loc11_ & 1;
                           _loc11_ = _loc11_ | _loc8_;
                           si32(_loc11_,_loc1_ + 4);
                           _loc14_ = _loc8_;
                        }
                        continue;
                     }
                  }
                  continue loop1;
               }
               _loc11_ = li32(_loc12_);
               if(_loc11_ == _loc9_)
               {
                  si32(_loc14_,_loc12_);
               }
               else
               {
                  _loc11_ = li32(_loc12_ + 4);
                  _loc11_ = _loc11_ & 1;
                  _loc11_ = _loc11_ | _loc14_;
                  si32(_loc11_,_loc12_ + 4);
               }
               _loc11_ = li32(_loc9_);
               si32(_loc11_,_loc14_);
               _loc11_ = li32(_loc9_ + 4);
               _loc11_ = _loc11_ & -2;
               _loc13_ = li32(_loc14_ + 4);
               _loc13_ = _loc13_ & 1;
               _loc13_ = _loc13_ | _loc11_;
               si32(_loc13_,_loc14_ + 4);
               _loc13_ = li32(_loc9_ + 4);
               _loc13_ = _loc13_ & 1;
               _loc11_ = _loc13_ | _loc11_;
               si32(_loc11_,_loc14_ + 4);
               _loc11_ = li32(_loc1_);
               if(_loc11_ == _loc14_)
               {
                  _loc11_ = wdnative_nternal._dss_chunks_szad + 4;
                  si32(_loc11_,_loc1_);
                  break loop3;
               }
               var _temp_198:* = int(wdnative_nternal._dss_chunks_szad + 4);
               _loc11_ = (_loc13_ = (_loc13_ = li32(_loc1_ + 4)) & 1) | _temp_198;
               si32(_loc11_,_loc1_ + 4);
               break loop3;
            }
            _loc10_ = li32(_loc14_ + 4);
            _loc8_ = _loc10_ & -2;
            if(_loc7_ == 0)
            {
               _loc12_ = _loc1_;
               if(_loc8_ == _loc6_)
               {
                  _loc9_ = li32(_loc14_);
                  if(_loc9_ != _loc6_)
                  {
                     _loc11_ = li32(_loc9_ + 4);
                     _loc11_ = _loc11_ & -2;
                     si32(_loc11_,_loc14_);
                     _loc11_ = li32(_loc9_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc14_;
                     si32(_loc11_,_loc9_ + 4);
                     var _temp_209:* = _loc14_ & -2;
                     _loc11_ = (_loc13_ = (_loc13_ = li32(_loc14_ + 4)) & 1) | _temp_209;
                     si32(_loc11_,_loc9_ + 4);
                     _loc11_ = li32(_loc14_ + 4);
                     _loc11_ = _loc11_ | 1;
                     si32(_loc11_,_loc14_ + 4);
                     var _temp_215:* = int(wdnative_nternal._dss_chunks_szad + 4);
                     _loc11_ = (_loc13_ = (_loc13_ = li32(_loc9_ + 4)) & 1) | _temp_215;
                     si32(_loc11_,_loc9_ + 4);
                     _loc6_ = _loc9_;
                  }
                  _loc11_ = li32(_loc1_);
                  if(_loc11_ == _loc14_)
                  {
                     si32(_loc6_,_loc1_);
                     break loop3;
                  }
                  _loc11_ = li32(_loc1_ + 4);
                  _loc11_ = _loc11_ & 1;
                  _loc11_ = _loc11_ | _loc6_;
                  si32(_loc11_,_loc1_ + 4);
                  break loop3;
               }
            }
            _loc11_ = li32(_loc8_);
            _loc11_ = li8(_loc11_ + 4);
            _loc11_ = _loc11_ & 1;
            if(_loc11_ == 0)
            {
               _loc7_ = li32(_loc14_);
               _loc8_ = li32(_loc7_ + 4);
               _loc11_ = _loc8_ & 1;
               if(_loc11_ != 0)
               {
                  _loc5_ = _loc8_ & -2;
                  _loc8_ = li32(_loc5_);
                  _loc11_ = li8(_loc8_ + 4);
                  _loc11_ = _loc11_ & 1;
                  if(_loc11_ != 0)
                  {
                     var _temp_233:* = _loc10_ & 1;
                     _loc11_ = (_loc13_ = (_loc13_ = li32(_loc5_ + 4)) & -2) | _temp_233;
                     si32(_loc11_,_loc5_ + 4);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & -2;
                     si32(_loc11_,_loc8_ + 4);
                     _loc13_ = li32(_loc7_ + 4);
                     var _temp_240:* = _loc13_ & 1;
                     _loc11_ = (_loc13_ = li32(_loc8_ = _loc13_ & -2)) | _temp_240;
                     si32(_loc11_,_loc7_ + 4);
                     si32(_loc7_,_loc8_);
                     si32(_loc8_,_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & -2;
                     si32(_loc11_,_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc14_;
                     si32(_loc11_,_loc8_ + 4);
                     _loc11_ = li32(_loc14_ + 4);
                     var _temp_250:* = _loc11_ & 1;
                     _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_250;
                     si32(_loc13_,_loc14_ + 4);
                     si32(_loc14_,_loc11_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc11_ = _loc13_ | _loc11_;
                     si32(_loc11_,_loc8_ + 4);
                  }
                  else
                  {
                     var _temp_255:* = _loc10_ & 1;
                     _loc11_ = _loc5_ | _temp_255;
                     si32(_loc11_,_loc7_ + 4);
                     _loc11_ = li32(_loc5_ + 4);
                     _loc11_ = _loc11_ | 1;
                     si32(_loc11_,_loc5_ + 4);
                     _loc8_ = li32(_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & -2;
                     si32(_loc11_,_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc14_;
                     si32(_loc11_,_loc8_ + 4);
                     _loc11_ = li32(_loc14_ + 4);
                     var _temp_268:* = _loc11_ & 1;
                     _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_268;
                     si32(_loc13_,_loc14_ + 4);
                     si32(_loc14_,_loc11_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc11_ = _loc13_ | _loc11_;
                     si32(_loc11_,_loc8_ + 4);
                  }
                  _loc11_ = li32(_loc14_ + 4);
                  _loc11_ = _loc11_ | 1;
                  si32(_loc11_,_loc14_ + 4);
               }
               else
               {
                  _loc11_ = _loc8_ | 1;
                  si32(_loc11_,_loc7_ + 4);
                  _loc10_ = li32(_loc7_);
                  _loc8_ = li32(_loc10_ + 4);
                  _loc11_ = _loc8_ & 1;
                  if(_loc11_ != 0)
                  {
                     _loc11_ = _loc8_ & -2;
                     si32(_loc11_,_loc10_ + 4);
                     _loc8_ = li32(_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & -2;
                     si32(_loc11_,_loc14_);
                     _loc11_ = li32(_loc8_ + 4);
                     _loc11_ = _loc11_ & 1;
                     _loc11_ = _loc11_ | _loc14_;
                     si32(_loc11_,_loc8_ + 4);
                     _loc11_ = li32(_loc14_ + 4);
                     var _temp_289:* = _loc11_ & 1;
                     _loc13_ = (_loc4_ = li32(_loc11_ &= -2)) | _temp_289;
                     si32(_loc13_,_loc14_ + 4);
                     si32(_loc14_,_loc11_);
                     _loc13_ = li32(_loc8_ + 4);
                     _loc13_ = _loc13_ & 1;
                     _loc11_ = _loc13_ | _loc11_;
                     si32(_loc11_,_loc8_ + 4);
                  }
                  else
                  {
                     _loc13_ = li32(_loc14_ + 4);
                     var _temp_297:* = _loc13_ & 1;
                     _loc11_ = (_loc13_ = li32(_loc8_ = _loc13_ & -2)) | _temp_297;
                     si32(_loc11_,_loc14_ + 4);
                     si32(_loc14_,_loc8_);
                  }
               }
               _loc11_ = li32(_loc1_);
               if(_loc11_ == _loc14_)
               {
                  si32(_loc8_,_loc1_);
                  _loc14_ = _loc1_;
               }
               else
               {
                  _loc11_ = li32(_loc1_ + 4);
                  _loc11_ = _loc11_ & 1;
                  _loc11_ = _loc11_ | _loc8_;
                  si32(_loc11_,_loc1_ + 4);
                  _loc14_ = _loc1_;
               }
            }
         }
         break;
      }
      _loc11_ = li32(_loc3_ - 24);
      si32(_loc11_,wdnative_nternal._dss_chunks_szad);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

