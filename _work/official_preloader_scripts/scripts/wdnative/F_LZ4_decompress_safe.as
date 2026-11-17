package wdnative
{
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative_nternal._dec32table_2E_2408;
   import wdnative_nternal._dec64table_2E_2409;
   
   public function F_LZ4_decompress_safe() : void
   {
      var _temp_1:* = this;
      var _loc2_:int = 0;
      var _loc25_:int = 0;
      var _loc22_:int = 0;
      var _loc26_:int = 0;
      var _loc10_:int = 0;
      var _loc21_:int = 0;
      var _loc16_:int = 0;
      var _loc15_:int = 0;
      var _loc7_:int = 0;
      var _loc19_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc12_:int = 0;
      var _loc17_:int = 0;
      var _loc18_:int = 0;
      var _loc14_:int = 0;
      var _loc11_:int = 0;
      var _loc13_:int = 0;
      var _loc23_:int = 0;
      var _loc1_:int = wdnative.ESP;
      _loc2_ = _loc1_;
      _loc10_ = li32(_loc2_ + 12);
      _loc26_ = li32(_loc2_ + 8);
      _loc25_ = li32(_loc2_);
      if(_loc10_ == 0)
      {
         while(true)
         {
            if(_loc26_ == 1)
            {
               var _temp_2:* = li8(_loc25_);
               _loc23_ = 0;
               if(_temp_2 == 0)
               {
                  break;
               }
            }
            _loc23_ = -1;
            break;
         }
      }
      else
      {
         _loc22_ = li32(_loc2_ + 4);
         _loc23_ = _loc22_ + _loc10_;
         _loc21_ = _loc25_ + _loc26_;
         var _loc24_:int = _loc26_ + _loc25_;
         _loc26_ = _loc24_ + -8;
         var _loc20_:int = _loc10_ + _loc22_;
         _loc19_ = _loc20_ + -12;
         _loc7_ = _loc20_ + -5;
         _loc15_ = _loc24_ + -5;
         _loc16_ = _loc20_ + -8;
         _loc10_ = _loc24_ + -15;
         _loc17_ = _loc25_;
         _loc18_ = _loc22_;
         loop0:
         while(true)
         {
            _loc11_ = _loc18_;
            _loc12_ = _loc17_ + 1;
            loop8:
            while(true)
            {
               _loc18_ = li8(_loc17_);
               _loc13_ = _loc18_ >>> 4;
               if(_loc13_ == 15)
               {
                  _loc14_ = _loc17_ + 2;
                  _loc12_ = _loc17_ + 1;
                  _loc13_ = 15;
                  do
                  {
                     _loc17_ = li8(_loc12_);
                     _loc13_ = _loc17_ + _loc13_;
                     _loc12_ += 1;
                     if(uint(_loc10_) <= uint(_loc14_))
                     {
                        break;
                     }
                     _loc14_ += 1;
                  }
                  while(_loc17_ == 255);
                  if(_loc13_ < 0)
                  {
                     break;
                  }
                  _loc24_ = _loc13_ + 1;
                  if(_loc24_ < 1)
                  {
                     break;
                  }
               }
               _loc17_ = _loc12_ + _loc13_;
               _loc14_ = _loc11_ + _loc13_;
               if(uint(_loc19_) >= uint(_loc14_))
               {
                  if(uint(_loc17_) <= uint(_loc26_))
                  {
                     _loc9_ = 0;
                     if(_loc13_ <= 8)
                     {
                        _loc24_ = li32(_loc12_);
                        si32(_loc24_,_loc11_);
                        _loc24_ = li32(_loc12_ + 4);
                        si32(_loc24_,_loc11_ + 4);
                        _loc12_ += 8;
                        _loc17_ = _loc11_ + 8;
                     }
                     else
                     {
                        do
                        {
                           _loc24_ = _loc11_ + _loc9_;
                           var _loc8_:int = _loc12_ + _loc9_;
                           _loc20_ = li32(_loc8_);
                           si32(_loc20_,_loc24_);
                           _loc20_ = li32(_loc8_ + 4);
                           si32(_loc20_,_loc24_ + 4);
                        }
                        while(_loc9_ += 8, _loc9_ < _loc13_);
                        _loc17_ = _loc11_ + _loc9_;
                        _loc12_ += _loc9_;
                     }
                     _loc24_ = _loc14_ - _loc17_;
                     _loc9_ = _loc12_ + _loc24_;
                     _loc24_ = li16(_loc9_);
                     _loc6_ = _loc13_ - _loc24_;
                     _loc4_ = _loc11_ + _loc6_;
                     _loc12_ = _loc9_ + 2;
                     if(uint(_loc4_) < uint(_loc22_))
                     {
                        break;
                     }
                     _loc18_ &= 15;
                     _loc17_ = _loc12_;
                     if(_loc18_ == 15)
                     {
                        _loc12_ = _loc9_ + 2;
                        _loc18_ = 15;
                        while(true)
                        {
                           if(uint(_loc15_) < uint(_loc12_))
                           {
                              break loop8;
                           }
                           _loc24_ = li8(_loc12_);
                           _loc18_ = _loc24_ + _loc18_;
                           _loc12_ += 1;
                           if(_loc24_ == 255)
                           {
                              continue;
                           }
                           var _temp_18:* = int(_loc18_ + _loc13_);
                           _loc17_ = _loc12_;
                           if(_temp_18 < _loc13_)
                           {
                              break loop8;
                           }
                        }
                        break;
                     }
                     _loc12_ = _loc14_ - _loc4_;
                     _loc5_ = _loc13_ + 4;
                     _loc9_ = _loc18_ + _loc5_;
                     _loc18_ = _loc11_ + _loc9_;
                     if(_loc12_ <= 3)
                     {
                        _loc24_ = li8(_loc4_);
                        si8(_loc24_,_loc14_);
                        _loc24_ = li8(_loc4_ + 1);
                        si8(_loc24_,_loc14_ + 1);
                        _loc24_ = li8(_loc4_ + 2);
                        si8(_loc24_,_loc14_ + 2);
                        _loc24_ = li8(_loc4_ + 3);
                        si8(_loc24_,_loc14_ + 3);
                        var _temp_25:* = int(_loc11_ + _loc5_);
                        _loc24_ = _loc12_ << 2;
                        _loc20_ = wdnative_nternal._dec32table_2E_2408 + _loc24_;
                        _loc20_ = li32(_loc20_);
                        _loc20_ = _loc20_ + _loc6_;
                        si32(li32(int(_loc11_ + _loc20_)),_temp_25);
                        _loc24_ = wdnative_nternal._dec64table_2E_2409 + _loc24_;
                        var _temp_27:* = li32(_loc24_);
                        _loc6_ = _loc20_ - _temp_27;
                     }
                     else
                     {
                        _loc24_ = li32(_loc4_);
                        si32(_loc24_,_loc14_);
                        var _temp_30:* = int(_loc11_ + _loc5_);
                        si32(_loc20_ = li32(_loc4_ + 4),_temp_30);
                        _loc6_ += 8;
                     }
                     _loc5_ = _loc13_ + _loc11_;
                     _loc4_ = _loc5_ + 8;
                     if(uint(_loc19_) < uint(_loc18_))
                     {
                        _loc12_ = _loc17_;
                        if(uint(_loc7_) < uint(_loc18_))
                        {
                           break;
                        }
                        _loc13_ = _loc11_ + _loc6_;
                        if(uint(_loc16_) > uint(_loc4_))
                        {
                           _loc24_ = _loc16_ - _loc4_;
                           if(_loc24_ >= 9)
                           {
                              _loc13_ = _loc11_ + _loc6_;
                              _loc4_ = _loc14_ + 8;
                              do
                              {
                                 _loc24_ = li32(_loc13_);
                                 si32(_loc24_,_loc4_);
                                 _loc24_ = li32(_loc13_ + 4);
                                 si32(_loc24_,_loc4_ + 4);
                                 _loc4_ += 8;
                                 _loc13_ += 8;
                              }
                              while(uint(_loc16_) > uint(_loc4_));
                           }
                           else
                           {
                              _loc24_ = _loc11_ + _loc6_;
                              _loc20_ = li32(_loc24_);
                              si32(_loc20_,_loc4_);
                              _loc20_ = li32(_loc24_ + 4);
                              si32(_loc20_,_loc5_ + 12);
                              _loc13_ = _loc24_ + 8;
                              _loc4_ = _loc5_ + 16;
                           }
                        }
                        if(uint(_loc4_) < uint(_loc18_))
                        {
                           var _temp_38:* = int(_loc9_ - _loc4_);
                           _loc11_ += _temp_38;
                           while(true)
                           {
                              _loc24_ = li8(_loc13_);
                              si8(_loc24_,_loc4_);
                              _loc4_ += 1;
                              _loc13_ += 1;
                              _loc11_ += -1;
                              if(_loc11_ != 0)
                              {
                                 continue;
                              }
                              continue loop8;
                           }
                        }
                     }
                     else
                     {
                        _loc24_ = _loc18_ - _loc4_;
                        if(_loc24_ >= 9)
                        {
                           _loc24_ = _loc11_ + _loc6_;
                           _loc14_ = _loc24_ + 4;
                           _loc13_ += 8;
                           do
                           {
                              _loc24_ = _loc11_ + _loc13_;
                              _loc20_ = li32(_loc14_ - 4);
                              si32(_loc20_,_loc24_);
                              _loc20_ = li32(_loc14_);
                              si32(_loc20_,_loc24_ + 4);
                              _loc14_ += 8;
                           }
                           while(_loc13_ += 8, _loc13_ < _loc9_);
                        }
                        else
                        {
                           _loc24_ = _loc11_ + _loc6_;
                           _loc20_ = li32(_loc24_);
                           si32(_loc20_,_loc4_);
                           _loc24_ = li32(_loc24_ + 4);
                           si32(_loc24_,_loc5_ + 12);
                        }
                     }
                     continue;
                  }
               }
               if(_loc17_ == _loc21_)
               {
                  if(uint(_loc14_) <= uint(_loc23_))
                  {
                     _loc1_ -= 16;
                     si32(_loc13_,_loc1_ + 8);
                     si32(_loc12_,_loc1_ + 4);
                     si32(_loc11_,_loc1_);
                     _loc23_ = _loc14_ - _loc22_;
                     wdnative.ESP = _loc1_;
                     wdnative.Fmemcpy();
                     _loc1_ += 16;
                     break loop0;
                  }
               }
               break;
            }
            _loc24_ = _loc25_ + -1;
            _loc23_ = _loc24_ - _loc12_;
            break;
         }
      }
      break loop0;
   }
}

