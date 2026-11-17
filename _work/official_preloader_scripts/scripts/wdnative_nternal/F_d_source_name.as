package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_source_name() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc4_:int = 0;
      var _loc12_:int = 0;
      var _loc7_:int = 0;
      var _loc11_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc12_ = li32(_loc1_ + 12);
      _loc11_ = li8(_loc12_);
      _loc9_ = _loc10_ = 0;
      if(_loc11_ == 110)
      {
         var _loc8_:int = _loc12_ + 1;
         si32(_loc8_,_loc1_ + 12);
         _loc11_ = li8(_loc12_ + 1);
         _loc9_ = 1;
         _loc12_ = _loc8_;
      }
      _loc8_ = _loc11_ + -48;
      _loc8_ = _loc8_ & 0xFF;
      _loc7_ = _loc10_;
      if(uint(_loc8_) <= 9)
      {
         do
         {
            _loc8_ = _loc12_ + 1;
            si32(_loc8_,_loc1_ + 12);
            var _loc6_:int = _loc7_ * 10;
            var _loc5_:int = _loc11_ << 24;
            _loc5_ = _loc5_ >> 24;
            _loc6_ += _loc5_;
            _loc7_ = _loc6_ + -48;
            _loc11_ = li8(_loc12_ + 1);
            _loc6_ = _loc11_ + -48;
            _loc6_ = _loc6_ & 0xFF;
            _loc12_ = _loc8_;
         }
         while(uint(_loc6_) < 10);
      }
      if(_loc9_ != _loc10_)
      {
         _loc7_ = 0 - _loc7_;
      }
      if(_loc7_ >= 1)
      {
         _loc8_ = li32(_loc1_ + 4);
         var _temp_11:* = int(_loc8_ - _loc12_);
         _loc10_ = 0;
         if(_temp_11 >= _loc7_)
         {
            _loc10_ = _loc12_ + _loc7_;
            si32(_loc10_,_loc1_ + 12);
            _loc8_ = li8(_loc1_ + 8);
            _loc8_ = _loc8_ & 4;
            if(_loc8_ != 0)
            {
               _loc8_ = li8(_loc10_);
               if(_loc8_ == 36)
               {
                  _loc8_ = _loc7_ + _loc12_;
                  _loc8_ = _loc8_ + 1;
                  si32(_loc8_,_loc1_ + 12);
               }
            }
            _loc10_ = 0;
            loop2:
            while(true)
            {
               if(_loc7_ >= 10)
               {
                  while(true)
                  {
                     _loc8_ = wdnative_nternal.L__2E_str16403 - _loc10_;
                     _loc8_ = li8(_loc8_);
                     _loc6_ = _loc12_ - _loc10_;
                     _loc6_ = li8(_loc6_);
                     if(_loc6_ == _loc8_)
                     {
                        _loc10_ += -1;
                        if(_loc10_ != -8)
                        {
                           continue;
                        }
                        while(true)
                        {
                           _loc10_ = li8(_loc12_ + 8);
                           if(_loc10_ != 36)
                           {
                              if(_loc10_ != 46)
                              {
                                 if(_loc10_ != 95)
                                 {
                                    break;
                                 }
                              }
                           }
                           _loc8_ = li8(_loc12_ + 9);
                           if(_loc8_ == 78)
                           {
                              var _temp_33:* = li32(_loc1_ + 48);
                              _loc8_ = (_loc8_ = 22 - _loc7_) + _temp_33;
                              si32(_loc8_,_loc1_ + 48);
                              _loc7_ = li32(_loc1_ + 20);
                              var _temp_35:* = li32(_loc1_ + 24);
                              _loc10_ = 0;
                              if(_loc7_ < _temp_35)
                              {
                                 _loc12_ = li32(_loc1_ + 16);
                                 _loc8_ = _loc7_ + 1;
                                 si32(_loc8_,_loc1_ + 20);
                                 _loc9_ = _loc7_ * 12;
                                 _loc7_ = _loc12_ + _loc9_;
                                 _loc10_ = 0;
                                 if(_loc7_ != 0)
                                 {
                                    _loc8_ = _loc12_ + _loc9_;
                                    si32(0,_loc8_);
                                    si32(wdnative_nternal.L__2E_str17404,_loc8_ + 4);
                                    si32(21,_loc8_ + 8);
                                    _loc10_ = _loc7_;
                                 }
                              }
                              break loop2;
                           }
                           break;
                        }
                     }
                  }
                  break;
               }
               _loc11_ = li32(_loc1_ + 20);
               _loc8_ = li32(_loc1_ + 24);
               _loc10_ = 0;
               if(_loc11_ < _loc8_)
               {
                  _loc9_ = li32(_loc1_ + 16);
                  _loc8_ = _loc11_ + 1;
                  si32(_loc8_,_loc1_ + 20);
                  _loc4_ = _loc11_ * 12;
                  _loc11_ = _loc9_ + _loc4_;
                  _loc10_ = 0;
                  if(_loc11_ != 0)
                  {
                     if(_loc12_ != 0)
                     {
                        if(_loc7_ != 0)
                        {
                           _loc8_ = _loc9_ + _loc4_;
                           si32(0,_loc8_);
                           si32(_loc12_,_loc8_ + 4);
                           si32(_loc7_,_loc8_ + 8);
                           _loc10_ = _loc11_;
                        }
                     }
                  }
               }
               break;
            }
         }
         si32(_loc10_,_loc1_ + 44);
      }
      wdnative.eax = _loc10_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

