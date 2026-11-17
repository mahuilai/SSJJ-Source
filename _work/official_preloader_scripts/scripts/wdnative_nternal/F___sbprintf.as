package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.Fmemset;
   import wdnative.eax;
   import wdnative.edx;
   import wdnative.ptr2fun;
   
   public function F___sbprintf() : void
   {
      var _temp_1:* = this;
      var _loc6_:int = 0;
      var _loc18_:int = 0;
      var _loc14_:int = 0;
      var _loc8_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc15_:int = 0;
      var _loc13_:int = 0;
      var _loc4_:int = 0;
      var _loc16_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc2_:int = 0;
      var _loc17_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc6_ = _loc3_;
      _loc3_ -= 1264;
      _loc3_ -= 16;
      si32(232,_loc3_ + 8);
      si32(0,_loc3_ + 4);
      _loc4_ = _loc6_ - 232;
      si32(_loc4_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative.Fmemset();
      _loc3_ += 16;
      si16(-1,_loc6_ - 218);
      _loc18_ = li32(_loc6_);
      _loc17_ = li16(_loc18_ + 12);
      _loc16_ = _loc17_ & 8;
      _loc15_ = li32(_loc6_ + 8);
      _loc14_ = li32(_loc6_ + 4);
      while(true)
      {
         if(_loc16_ != 0)
         {
            _loc16_ = li32(_loc18_ + 16);
            if(_loc16_ != 0)
            {
               break;
            }
            _loc16_ = _loc17_ & 0x0200;
            if(_loc16_ != 0)
            {
               break;
            }
         }
         _loc3_ -= 16;
         si32(_loc18_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F___swsetup();
         _loc17_ = -1;
         _loc3_ += 16;
         _loc16_ = wdnative.eax;
         if(_loc16_ == 0)
         {
            _loc17_ = li16(_loc18_ + 12);
            break;
         }
         §§goto(addr061f);
      }
      _loc16_ = _loc17_ & 0xFFFD;
      si16(_loc16_,_loc6_ - 220);
      _loc16_ = li16(_loc18_ + 14);
      si16(_loc16_,_loc6_ - 218);
      _loc16_ = li32(_loc18_ + 28);
      si32(_loc16_,_loc6_ - 204);
      _loc16_ = li32(_loc18_ + 44);
      si32(_loc16_,_loc6_ - 188);
      _loc16_ = li32(_loc18_ + 100);
      si32(_loc16_,_loc6_ - 132);
      _loc3_ -= 16;
      si32(128,_loc3_ + 8);
      _loc16_ = _loc18_ + 104;
      si32(_loc16_,_loc3_ + 4);
      _loc16_ = _loc4_ + 104;
      si32(_loc16_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative.Fmemcpy();
      _loc3_ += 16;
      _loc16_ = _loc6_ - 1256;
      si32(_loc16_,_loc6_ - 232);
      si32(_loc16_,_loc6_ - 216);
      si32(1024,_loc6_ - 224);
      si32(1024,_loc6_ - 212);
      si32(0,_loc6_ - 208);
      _loc3_ -= 16;
      si32(_loc15_,_loc3_ + 8);
      si32(_loc14_,_loc3_ + 4);
      si32(_loc4_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative_nternal.F___vfprintf();
      _loc3_ += 16;
      _loc17_ = wdnative.eax;
      _loc14_ = li16(_loc6_ - 220);
      if(_loc17_ >= 0)
      {
         _loc16_ = _loc14_ & 0x18;
         if(_loc16_ == 0)
         {
            si32(9,wdnative_nternal._errno);
            _loc17_ = -1;
         }
         else
         {
            _loc16_ = _loc14_ << 16;
            _loc13_ = _loc16_ >> 16;
            _loc16_ = _loc13_ & 8;
            if(_loc16_ != 0)
            {
               _loc15_ = li32(_loc6_ - 216);
               if(_loc15_ != 0)
               {
                  _loc12_ = li32(_loc6_ - 232);
                  si32(_loc15_,_loc6_ - 232);
                  var _temp_27:* = _loc13_ & 3;
                  _loc13_ = li32(_loc6_ - 212);
                  if(_temp_27 != 0)
                  {
                     _loc13_ = 0;
                  }
                  si32(_loc13_,_loc6_ - 224);
                  _loc13_ = _loc12_ - _loc15_;
                  _loc12_ = _loc4_ + 64;
                  loop0:
                  while(_loc13_ > 0)
                  {
                     while(true)
                     {
                        _loc16_ = _loc14_ & 0x0100;
                        if(_loc16_ != 0)
                        {
                           _loc11_ = li32(wdnative_nternal._errno);
                           si32(0,wdnative_nternal._errno);
                           var _loc1_:int = li32(_loc6_ - 192);
                           var _temp_29:* = li32(_loc6_ - 204);
                           _loc3_ -= 16;
                           si32(2,_loc3_ + 12);
                           si32(0,_loc3_ + 8);
                           si32(0,_loc3_ + 4);
                           si32(_temp_29,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative.ptr2fun[_loc1_]();
                           _loc3_ += 16;
                           _loc7_ = wdnative.eax;
                           _loc8_ = wdnative.edx;
                           _loc14_ = li32(wdnative_nternal._errno);
                           if(_loc14_ == 0)
                           {
                              si32(_loc11_,wdnative_nternal._errno);
                           }
                           if(_loc8_ <= -1)
                           {
                              if(_loc14_ != 0)
                              {
                                 if(_loc14_ != 29)
                                 {
                                    _loc14_ = li16(_loc6_ - 220);
                                 }
                                 else
                                 {
                                    _loc16_ = li16(_loc6_ - 220);
                                    _loc14_ = _loc16_ & -257;
                                    si16(_loc14_,_loc6_ - 220);
                                 }
                              }
                              else
                              {
                                 _loc14_ = li32(_loc6_ - 184);
                                 if(_loc14_ != 0)
                                 {
                                    if(_loc14_ != _loc12_)
                                    {
                                       if(_loc14_ != 0)
                                       {
                                          _loc3_ -= 16;
                                          si32(_loc14_,_loc3_);
                                          wdnative.ESP = _loc3_;
                                          wdnative_nternal.F_idalloc();
                                          _loc3_ += 16;
                                       }
                                    }
                                    si32(0,_loc6_ - 184);
                                 }
                                 _loc16_ = li32(_loc6_ - 216);
                                 si32(_loc16_,_loc6_ - 232);
                                 _loc16_ = _loc4_ | 4;
                                 si32(0,_loc16_);
                                 _loc16_ = li16(_loc6_ - 220);
                                 _loc16_ = _loc16_ & -97;
                                 _loc14_ = _loc16_ | 0x40;
                                 si16(_loc14_,_loc6_ - 220);
                                 si32(22,wdnative_nternal._errno);
                              }
                              _loc14_ &= 61439;
                              si16(_loc14_,_loc6_ - 220);
                              addr0469:
                              _loc16_ = _loc14_ & 0x0400;
                              if(_loc16_ != 0)
                              {
                                 break;
                              }
                           }
                           else
                           {
                              _loc14_ = li16(_loc6_ - 220);
                              _loc16_ = _loc14_ & 0x0400;
                              if(_loc16_ != 0)
                              {
                                 _loc14_ |= 4096;
                                 si16(_loc14_,_loc6_ - 220);
                                 si32(_loc8_,_loc6_ - 148);
                                 si32(_loc7_,_loc6_ - 152);
                              }
                              _loc16_ = _loc7_ & _loc8_;
                              if(_loc16_ == -1)
                              {
                                 §§goto(addr0469);
                              }
                           }
                           si32(_loc11_,wdnative_nternal._errno);
                        }
                        _loc1_ = li32(_loc6_ - 188);
                        _loc16_ = li32(_loc6_ - 204);
                        _loc3_ -= 16;
                        si32(_loc13_,_loc3_ + 8);
                        si32(_loc15_,_loc3_ + 4);
                        si32(_loc16_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative.ptr2fun[_loc1_]();
                        _loc3_ += 16;
                        _loc8_ = wdnative.eax;
                        _loc14_ = li16(_loc6_ - 220);
                        if(_loc8_ < 0)
                        {
                           _loc14_ &= 61439;
                           si16(_loc14_,_loc6_ - 220);
                           break;
                        }
                        while(true)
                        {
                           _loc16_ = _loc14_ & 0x1100;
                           if(_loc16_ == 4352)
                           {
                              var _temp_50:* = _loc8_ ^ -1;
                              _loc9_ = 1;
                              _loc11_ = li32(_loc6_ - 152);
                              _loc10_ = _loc9_;
                              if(uint(_loc11_) <= uint(_temp_50))
                              {
                                 _loc10_ = 0;
                              }
                              _loc7_ = _loc8_ >> 31;
                              _loc2_ = 2147483647 - _loc7_;
                              _loc5_ = li32(_loc6_ - 148);
                              if(_loc5_ <= _loc2_)
                              {
                                 _loc9_ = 0;
                              }
                              if(_loc5_ != _loc2_)
                              {
                                 _loc10_ = _loc9_;
                              }
                              if(_loc10_ == 0)
                              {
                                 _loc9_ = _loc11_ + _loc8_;
                                 si32(_loc9_,_loc6_ - 152);
                                 _loc2_ = _loc10_ = 1;
                                 if(uint(_loc9_) >= uint(_loc11_))
                                 {
                                    _loc2_ = 0;
                                 }
                                 if(uint(_loc9_) >= uint(_loc8_))
                                 {
                                    _loc10_ = _loc2_;
                                 }
                                 _loc16_ = _loc5_ + _loc7_;
                                 _loc16_ = _loc16_ + _loc10_;
                                 si32(_loc16_,_loc6_ - 148);
                                 break;
                              }
                           }
                           _loc14_ &= 61439;
                           si16(_loc14_,_loc6_ - 220);
                           break;
                        }
                        if(_loc8_ <= 0)
                        {
                           break;
                        }
                        _loc15_ += _loc8_;
                        _loc13_ -= _loc8_;
                        continue loop0;
                     }
                     _loc14_ |= 64;
                     si16(_loc14_,_loc6_ - 220);
                     _loc17_ = -1;
                     break;
                  }
               }
            }
         }
      }
      _loc16_ = _loc14_ & 0x40;
      if(_loc16_ != 0)
      {
         _loc16_ = li16(_loc18_ + 12);
         _loc16_ = _loc16_ | 0x40;
         si16(_loc16_,_loc18_ + 12);
      }
      addr061f:
      wdnative.eax = _loc17_;
      _loc3_ = _loc6_;
      wdnative.ESP = _loc3_;
   }
}

