package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F__cleanup() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc9_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = 0;
      var _loc4_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc15_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc4_ = wdnative_nternal.___sglue;
      do
      {
         _loc17_ = li32(_loc4_ + 4);
         if(_loc17_ >= 1)
         {
            _loc16_ = li32(_loc4_ + 8);
            do
            {
               _loc15_ = si16(li16(_loc16_ + 12));
               if(_loc15_ >= 1)
               {
                  var _loc14_:int = _loc15_ & 8;
                  if(_loc14_ != 0)
                  {
                     _loc13_ = li32(_loc16_ + 16);
                     if(_loc13_ != 0)
                     {
                        _loc12_ = li32(_loc16_);
                        si32(_loc13_,_loc16_);
                        var _temp_8:* = _loc15_ & 3;
                        _loc11_ = 0;
                        if(_temp_8 == 0)
                        {
                           _loc11_ = li32(_loc16_ + 20);
                        }
                        _loc12_ -= _loc13_;
                        si32(_loc11_,_loc16_ + 8);
                        while(_loc12_ > 0)
                        {
                           _loc14_ = _loc15_ & 0x0100;
                           if(_loc14_ != 0)
                           {
                              _loc11_ = li32(wdnative_nternal._errno);
                              _loc3_ -= 16;
                              si32(2,_loc3_ + 4);
                              si32(_loc16_,_loc3_);
                              wdnative.ESP = _loc3_;
                              wdnative_nternal.F__sseek();
                              _loc3_ += 16;
                              _loc14_ = wdnative.eax & wdnative.edx;
                              if(_loc14_ == -1)
                              {
                                 _loc15_ = li16(_loc16_ + 12);
                                 _loc14_ = _loc15_ & 0x0400;
                                 if(_loc14_ != 0)
                                 {
                                    _loc14_ = _loc15_ | 0x40;
                                    si16(_loc14_,_loc16_ + 12);
                                    break;
                                 }
                              }
                              si32(_loc11_,wdnative_nternal._errno);
                           }
                           _loc14_ = li32(_loc16_ + 44);
                           var _loc10_:int = li32(_loc16_ + 28);
                           _loc3_ -= 16;
                           si32(_loc12_,_loc3_ + 8);
                           si32(_loc13_,_loc3_ + 4);
                           si32(_loc10_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.ptr2fun[_loc14_]();
                           _loc3_ += 16;
                           _loc1_ = wdnative.eax;
                           _loc15_ = li16(_loc16_ + 12);
                           if(_loc1_ < 0)
                           {
                              _loc15_ &= 61439;
                              si16(_loc15_,_loc16_ + 12);
                              _loc14_ = _loc15_ | 0x40;
                              si16(_loc14_,_loc16_ + 12);
                              break;
                           }
                           while(true)
                           {
                              _loc14_ = _loc15_ & 0x1100;
                              if(_loc14_ == 4352)
                              {
                                 var _temp_17:* = _loc1_ ^ -1;
                                 _loc6_ = li32(_loc16_ + 80);
                                 _loc8_ = _loc7_ = 1;
                                 if(uint(_loc6_) <= uint(_temp_17))
                                 {
                                    _loc8_ = 0;
                                 }
                                 _loc9_ = li32(_loc16_ + 84);
                                 _loc11_ = _loc1_ >> 31;
                                 _loc2_ = 2147483647 - _loc11_;
                                 if(_loc9_ <= _loc2_)
                                 {
                                    _loc7_ = 0;
                                 }
                                 if(_loc9_ != _loc2_)
                                 {
                                    _loc8_ = _loc7_;
                                 }
                                 if(_loc8_ == 0)
                                 {
                                    _loc2_ = _loc6_ + _loc1_;
                                    si32(_loc2_,_loc16_ + 80);
                                    _loc7_ = _loc8_ = 1;
                                    if(uint(_loc2_) >= uint(_loc6_))
                                    {
                                       _loc7_ = 0;
                                    }
                                    if(uint(_loc2_) >= uint(_loc1_))
                                    {
                                       _loc8_ = _loc7_;
                                    }
                                    _loc14_ = _loc9_ + _loc11_;
                                    _loc14_ = _loc14_ + _loc8_;
                                    si32(_loc14_,_loc16_ + 84);
                                    break;
                                 }
                              }
                              _loc15_ &= 61439;
                              si16(_loc15_,_loc16_ + 12);
                              break;
                           }
                           if(_loc1_ <= 0)
                           {
                              _loc14_ = _loc15_ | 0x40;
                              si16(_loc14_,_loc16_ + 12);
                              break;
                           }
                           _loc13_ += _loc1_;
                           _loc12_ -= _loc1_;
                        }
                     }
                  }
               }
            }
            while(_loc16_ += 232, _loc17_ += -1, _loc17_ != 0);
         }
      }
      while(_loc4_ = li32(_loc4_), _loc4_ != 0);
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

