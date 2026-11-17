package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.eax;
   import wdnative.ptr2fun;
   
   public function F__ZNK10__cxxabiv121__vmi_class_type_info12__do_dyncastEiNS_17__class_type_info10__sub_kindEPKS1_PKvS4_S6_RNS1_16__dyncast_resultE() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc39_:int = 0;
      var _loc13_:int = 0;
      var _loc32_:int = 0;
      var _loc28_:int = 0;
      var _loc34_:int = 0;
      var _loc36_:int = 0;
      var _loc38_:int = 0;
      var _loc16_:int = 0;
      var _loc30_:int = 0;
      var _loc19_:int = 0;
      var _loc8_:int = 0;
      var _loc4_:int = 0;
      var _loc29_:int = 0;
      var _loc33_:int = 0;
      var _loc35_:int = 0;
      var _loc20_:int = 0;
      var _loc31_:int = 0;
      var _loc11_:int = 0;
      var _loc40_:int = 0;
      var _loc22_:int = 0;
      var _loc15_:int = 0;
      var _loc14_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc5_:int = 0;
      var _loc25_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc26_:int = 0;
      var _loc24_:int = 0;
      var _loc37_:int = 0;
      var _loc21_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc7_ = _loc3_;
      _loc3_ -= 32;
      _loc16_ = li32(_loc7_ + 28);
      _loc40_ = li8(_loc16_ + 16);
      _loc40_ = _loc40_ & 0x10;
      _loc39_ = li32(_loc7_);
      if(_loc40_ != 0)
      {
         _loc40_ = li32(_loc39_ + 8);
         si32(_loc40_,_loc16_ + 16);
      }
      _loc38_ = li32(_loc7_ + 24);
      _loc36_ = li32(_loc7_ + 20);
      _loc34_ = li32(_loc7_ + 16);
      _loc32_ = li32(_loc7_ + 8);
      _loc30_ = li32(_loc39_ + 4);
      loop2:
      while(true)
      {
         if(_loc34_ == _loc38_)
         {
            var _temp_5:* = li32(_loc36_ + 4);
            if(_loc30_ == _temp_5)
            {
               si32(_loc32_,_loc16_ + 8);
               _loc21_ = 0;
               break;
            }
         }
         _loc28_ = li32(_loc7_ + 12);
         _loc13_ = li32(_loc7_ + 4);
         _loc40_ = li32(_loc28_ + 4);
         if(_loc30_ != _loc40_)
         {
            _loc24_ = li32(_loc39_ + 12);
            _loc26_ = 0;
            loop0:
            while(true)
            {
               _loc21_ = _loc26_;
               if(_loc13_ == -2)
               {
                  while(true)
                  {
                     if(_loc24_ == 0)
                     {
                        break loop2;
                     }
                     _loc33_ = li32(_loc16_ + 16);
                     si32(0,_loc7_ - 24);
                     _loc40_ = _loc7_ - 24;
                     var _temp_8:* = _loc40_ | 4;
                     si32(0,_temp_8);
                     si32(0,_loc7_ - 16);
                     si32(0,_loc7_ - 12);
                     si32(_loc33_,_loc7_ - 8);
                     var _temp_9:* = _loc24_ << 3;
                     _loc40_ = _loc39_ + _temp_9;
                     _loc35_ = li32(_loc40_ + 12);
                     _loc31_ = _loc35_ & 1;
                     _loc37_ = _loc35_ >> 8;
                     if(_loc31_ != 0)
                     {
                        _loc40_ = li32(_loc34_);
                        _loc40_ = _loc40_ + _loc37_;
                        _loc37_ = li32(_loc40_);
                     }
                     _loc14_ = _loc31_ | _loc32_;
                     _loc12_ = _loc34_ + _loc37_;
                     _loc40_ = _loc35_ & 2;
                     if(_loc40_ != 0)
                     {
                        _loc24_ += -1;
                     }
                     else
                     {
                        _loc24_ += -1;
                        _loc40_ = _loc33_ & 3;
                        if(_loc40_ == 0)
                        {
                           continue;
                        }
                        _loc14_ &= -3;
                     }
                  }
                  continue;
               }
               if(_loc24_ == 0)
               {
                  break loop2;
               }
               var _temp_19:* = _loc24_ << 1;
               var _temp_18:* = li32(_loc16_ + 16);
               si32(0,_loc7_ - 24);
               var _loc18_:int = _loc7_ - 24;
               var _temp_17:* = _loc18_ | 4;
               si32(0,_temp_17);
               si32(0,_loc7_ - 16);
               si32(0,_loc7_ - 12);
               si32(_temp_18,_loc7_ - 8);
               var _temp_20:* = _temp_19 << 2;
               _loc40_ = _loc39_ + _temp_20;
               _loc19_ = li32(_loc40_ + 12);
               _loc20_ = _loc19_ & 1;
               _loc15_ = _loc19_ >> 8;
               if(_loc20_ != 0)
               {
                  _loc40_ = li32(_loc34_);
                  _loc40_ = _loc40_ + _loc15_;
                  _loc15_ = li32(_loc40_);
               }
               _loc24_ += -1;
               _loc14_ = _loc20_ | _loc32_;
               _loc12_ = _loc34_ + _loc15_;
               _loc40_ = _loc19_ & 2;
               if(_loc40_ == 0)
               {
                  §§goto(addr0241);
               }
               _loc40_ = _loc24_ << 3;
               _loc40_ = _loc39_ + _loc40_;
               _loc40_ = li32(_loc40_ + 16);
               var _loc17_:int = li32(_loc40_);
               var _loc10_:int = li32(_loc17_ + 28);
               _loc3_ -= 32;
               _loc11_ = _loc7_ - 24;
               si32(_loc11_,_loc3_ + 28);
               si32(_loc38_,_loc3_ + 24);
               si32(_loc36_,_loc3_ + 20);
               si32(_loc12_,_loc3_ + 16);
               si32(_loc28_,_loc3_ + 12);
               si32(_loc14_,_loc3_ + 8);
               si32(_loc13_,_loc3_ + 4);
               si32(_loc40_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative.ptr2fun[_loc10_]();
               _loc3_ += 32;
               _loc26_ = wdnative.eax;
               _loc17_ = li32(_loc16_ + 8);
               _loc40_ = li32(_loc7_ - 16);
               _loc8_ = _loc40_ | _loc17_;
               si32(_loc8_,_loc16_ + 8);
               _loc9_ = li32(_loc7_ - 12);
               _loc40_ = _loc9_ | 4;
               if(_loc40_ == 6)
               {
                  _loc40_ = li32(_loc7_ - 24);
                  si32(_loc40_,_loc16_);
                  _loc40_ = _loc11_ | 4;
                  _loc40_ = li32(_loc40_);
                  si32(_loc40_,_loc16_ + 4);
                  si32(_loc9_,_loc16_ + 12);
                  _loc21_ = _loc26_;
                  break loop2;
               }
               _loc5_ = li32(_loc16_);
               loop3:
               while(true)
               {
                  loop4:
                  while(true)
                  {
                     while(true)
                     {
                        _loc40_ = _loc21_ & 0xFF;
                        if(_loc40_ == 0)
                        {
                           if(_loc5_ == 0)
                           {
                              _loc40_ = li32(_loc7_ - 24);
                              si32(_loc40_,_loc16_);
                              _loc17_ = _loc11_ | 4;
                              _loc17_ = li32(_loc17_);
                              si32(_loc17_,_loc16_ + 4);
                              if(_loc40_ == 0)
                              {
                                 break;
                              }
                              if(_loc8_ != 0)
                              {
                                 _loc40_ = li8(_loc39_ + 8);
                                 var _temp_69:* = _loc40_ & 1;
                                 _loc21_ = _loc26_;
                                 if(_temp_69 != 0)
                                 {
                                    break;
                                 }
                                 break loop2;
                              }
                              continue loop0;
                           }
                        }
                        else if(_loc5_ == 0)
                        {
                           _loc6_ = 1;
                           _loc2_ = 0;
                           _loc40_ = li32(_loc7_ - 24);
                           if(_loc40_ == _loc2_)
                           {
                              _loc6_ = _loc2_;
                           }
                           _loc5_ = _loc2_;
                           break loop4;
                        }
                        _loc4_ = li32(_loc7_ - 24);
                        if(_loc5_ == _loc4_)
                        {
                           var _temp_73:* = li32(_loc16_ + 4);
                           _loc40_ = (_loc17_ = li32(_loc17_ = _loc11_ | 4)) | _temp_73;
                           si32(_loc40_,_loc16_ + 4);
                           _loc26_ = _loc21_;
                           break;
                        }
                        _loc2_ = 1;
                        _loc6_ = 0;
                        if(_loc4_ == 0)
                        {
                           break loop4;
                        }
                        break loop3;
                     }
                     §§goto(addr06a2);
                  }
                  _loc40_ = _loc26_ & _loc2_;
                  if(_loc40_ == 0)
                  {
                     _loc40_ = _loc6_ & _loc21_;
                     var _temp_64:* = _loc40_ & 1;
                     _loc26_ = _loc21_;
                     if(_temp_64 != 0)
                     {
                        break;
                     }
                     break loop7;
                  }
                  break;
               }
               _loc1_ = li32(_loc16_ + 12);
               loop5:
               while(true)
               {
                  if(_loc8_ >= 4)
                  {
                     _loc40_ = _loc8_ & 1;
                     if(_loc40_ != 0)
                     {
                        _loc40_ = li8(_loc16_ + 16);
                        _loc40_ = _loc40_ & 2;
                        if(_loc40_ != 0)
                        {
                           addr046f:
                           if(_loc1_ < 1)
                           {
                              while(true)
                              {
                                 if(_loc9_ >= 4)
                                 {
                                    var _temp_43:* = _loc9_ & 1;
                                    _loc1_ = 1;
                                    if(_temp_43 == 0)
                                    {
                                       break loop5;
                                    }
                                    _loc40_ = li8(_loc39_ + 8);
                                    var _temp_45:* = _loc40_ & 2;
                                    _loc1_ = 1;
                                    if(_temp_45 == 0)
                                    {
                                       break;
                                    }
                                 }
                                 if(_loc13_ >= 0)
                                 {
                                    var _temp_46:* = int(_loc5_ + _loc13_);
                                    _loc1_ = 6;
                                    if(_temp_46 != _loc38_)
                                    {
                                       _loc1_ = 1;
                                    }
                                    break;
                                 }
                                 _loc1_ = 1;
                                 if(_loc13_ != -2)
                                 {
                                    _loc40_ = li32(_loc28_);
                                    var _loc23_:int = li32(_loc40_ + 32);
                                    _loc3_ -= 32;
                                    si32(_loc38_,_loc3_ + 16);
                                    si32(_loc36_,_loc3_ + 12);
                                    si32(_loc5_,_loc3_ + 8);
                                    si32(_loc13_,_loc3_ + 4);
                                    si32(_loc28_,_loc3_);
                                    wdnative.ESP = _loc3_;
                                    wdnative.ptr2fun[_loc23_]();
                                    _loc3_ += 32;
                                    _loc1_ = wdnative.eax;
                                 }
                                 break;
                              }
                           }
                           if(_loc9_ <= 0)
                           {
                              if(_loc1_ >= 4)
                              {
                                 var _temp_50:* = _loc1_ & 1;
                                 _loc9_ = 1;
                                 if(_temp_50 == 0)
                                 {
                                    break;
                                 }
                                 _loc40_ = li8(_loc39_ + 8);
                                 var _temp_52:* = _loc40_ & 2;
                                 _loc9_ = 1;
                                 if(_temp_52 == 0)
                                 {
                                    break;
                                 }
                              }
                              _loc29_ = li32(_loc7_ - 24);
                              if(_loc13_ >= 0)
                              {
                                 var _temp_53:* = int(_loc29_ + _loc13_);
                                 _loc9_ = 6;
                                 if(_temp_53 != _loc38_)
                                 {
                                    _loc9_ = 1;
                                 }
                                 break;
                              }
                              _loc9_ = 1;
                              if(_loc13_ != -2)
                              {
                                 _loc40_ = li32(_loc28_);
                                 var _loc27_:int = li32(_loc40_ + 32);
                                 _loc3_ -= 32;
                                 si32(_loc38_,_loc3_ + 16);
                                 si32(_loc36_,_loc3_ + 12);
                                 si32(_loc29_,_loc3_ + 8);
                                 si32(_loc13_,_loc3_ + 4);
                                 si32(_loc28_,_loc3_);
                                 wdnative.ESP = _loc3_;
                                 wdnative.ptr2fun[_loc27_]();
                                 _loc3_ += 32;
                                 _loc9_ = wdnative.eax;
                              }
                           }
                           break;
                        }
                     }
                     _loc25_ = 1;
                     if(_loc1_ != 0)
                     {
                        _loc25_ = _loc1_;
                     }
                     _loc1_ = _loc25_;
                     if(_loc9_ == 0)
                     {
                        _loc9_ = 1;
                        _loc1_ = _loc25_;
                     }
                     break;
                  }
                  §§goto(addr046f);
               }
               _loc40_ = _loc1_ ^ _loc9_;
               if(_loc40_ >= 4)
               {
                  _loc26_ = _loc21_;
                  if(_loc9_ >= 4)
                  {
                     _loc40_ = li32(_loc7_ - 24);
                     si32(_loc40_,_loc16_);
                     _loc40_ = _loc11_ | 4;
                     _loc40_ = li32(_loc40_);
                     si32(_loc40_,_loc16_ + 4);
                     _loc26_ = 0;
                     _loc1_ = _loc9_;
                  }
                  si32(_loc1_,_loc16_ + 12);
                  _loc40_ = _loc1_ & 3;
                  _loc21_ = 0;
                  if(_loc40_ != 1)
                  {
                     break loop2;
                  }
               }
               else
               {
                  si32(0,_loc16_);
                  _loc40_ = _loc1_ & _loc9_;
                  if(_loc40_ >= 4)
                  {
                     si32(2,_loc16_ + 12);
                     _loc21_ = 1;
                     break loop2;
                  }
                  _loc26_ = 1;
                  si32(_loc26_,_loc16_ + 12);
               }
               addr06a2:
               _loc40_ = li32(_loc16_ + 8);
               _loc21_ = _loc26_;
               if(_loc40_ == 4)
               {
                  break loop2;
               }
            }
            break;
         }
         si32(_loc34_,_loc16_);
         si32(_loc32_,_loc16_ + 4);
         if(_loc13_ >= 0)
         {
            var _temp_75:* = int(_loc34_ + _loc13_);
            _loc22_ = 6;
            if(_temp_75 != _loc38_)
            {
               _loc22_ = 1;
            }
            si32(_loc22_,_loc16_ + 12);
            _loc21_ = 0;
            break;
         }
         _loc21_ = 0;
         if(_loc13_ == -2)
         {
            si32(1,_loc16_ + 12);
            _loc21_ = 0;
         }
         break;
      }
      wdnative.eax = _loc40_ = _loc21_ & 0xFF;
      _loc3_ = _loc7_;
      wdnative.ESP = _loc3_;
   }
}

