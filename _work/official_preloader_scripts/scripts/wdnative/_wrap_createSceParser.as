package wdnative
{
   import avm2.intrinsics.memory.*;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.F_idalloc;
   import wdnative_nternal.L__2E_str42;
   import wdnative_nternal.L__2E_str648;
   import wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__;
   
   public function _wrap_createSceParser(param1:int, param2:int, param3:int) : int
   {
      var _loc7_:int = 0;
      var _loc41_:int = 0;
      var _loc37_:int = 0;
      var _loc80_:int = 0;
      var _loc34_:int = 0;
      var _loc40_:int = 0;
      var _loc42_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc12_:int = 0;
      var _loc15_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc11_:int = 0;
      var _loc72_:int = 0;
      var _loc86_:int = 0;
      var _loc59_:int = 0;
      var _loc57_:int = 0;
      var _loc53_:int = 0;
      var _loc51_:int = 0;
      var _loc29_:int = 0;
      var _loc26_:int = 0;
      var _loc18_:int = 0;
      var _loc5_:int = 0;
      var _loc30_:int = 0;
      var _loc47_:int = 0;
      var _loc45_:int = 0;
      var _loc33_:int = 0;
      var _loc75_:int = 0;
      var _loc71_:int = 0;
      var _loc64_:int = 0;
      var _loc63_:int = 0;
      var _loc60_:int = 0;
      var _loc82_:int = 0;
      var _loc83_:int = 0;
      var _loc56_:int = 0;
      var _loc58_:int = 0;
      var _loc54_:int = 0;
      var _loc49_:int = 0;
      var _loc32_:int = 0;
      var _loc31_:int = 0;
      var _loc38_:int = 0;
      var _loc14_:int = 0;
      var _loc25_:int = 0;
      var _loc39_:int = 0;
      var _loc81_:int = 0;
      var _loc43_:int = 0;
      var _loc77_:int = 0;
      var _loc79_:int = 0;
      var _loc70_:int = 0;
      var _loc62_:int = 0;
      var _loc73_:int = 0;
      var _loc61_:int = 0;
      var _loc52_:int = 0;
      var _loc44_:int = 0;
      var _loc36_:int = 0;
      var _loc78_:int = 0;
      var _loc76_:int = 0;
      var _loc87_:int = 0;
      var _loc74_:int = 0;
      var _loc13_:int = 0;
      var _loc85_:int = 0;
      var _loc84_:int = 0;
      var _loc55_:int = 0;
      var _loc65_:int = 0;
      var _loc24_:int = 0;
      var _loc19_:int = 0;
      var _loc66_:int = 0;
      var _loc20_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int;
      _loc7_ = _loc6_ = wdnative.ESP;
      _loc30_ = param1;
      _loc47_ = param2;
      _loc45_ = param3;
      _loc6_ -= 16;
      si32(596,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN11WeAllocator8allocateEjPKcS1_i();
      _loc43_ = 0;
      _loc6_ += 16;
      _loc41_ = wdnative.eax;
      si32(_loc43_,_loc41_ + 4);
      si32(-1,_loc41_ + 8);
      si32(_loc43_,_loc41_ + 32);
      si32(_loc43_,_loc41_ + 28);
      si32(_loc43_,_loc41_ + 24);
      si32(_loc43_,_loc41_ + 20);
      si32(_loc43_,_loc41_ + 16);
      _loc39_ = _loc41_ + 16;
      si32(_loc39_,_loc41_ + 24);
      si32(_loc39_,_loc41_ + 28);
      _loc39_ = wdnative.__ZTVN11WeSceParser11WeSceLoaderE + 8;
      si32(_loc39_,_loc41_);
      si32(_loc45_,_loc41_ + 36);
      si32(_loc43_,_loc41_ + 44);
      si32(-1,_loc41_ + 48);
      si32(_loc43_,_loc41_ + 72);
      si32(_loc43_,_loc41_ + 68);
      si32(_loc43_,_loc41_ + 64);
      si32(_loc43_,_loc41_ + 60);
      si32(_loc43_,_loc41_ + 56);
      _loc39_ = _loc41_ + 56;
      si32(_loc39_,_loc41_ + 64);
      si32(_loc39_,_loc41_ + 68);
      _loc39_ = wdnative.__ZTV20WeLittleEndianReader + 8;
      si32(_loc39_,_loc41_ + 40);
      si32(_loc43_,_loc41_ + 556);
      si32(_loc43_,_loc41_ + 560);
      si32(-1,_loc41_ + 592);
      si32(_loc30_,_loc41_ + 76);
      si8(1,_loc41_ + 80);
      si32(_loc47_,_loc41_ + 84);
      _loc6_ -= 16;
      si32(128,_loc6_ + 8);
      si32(_loc43_,_loc6_ + 4);
      _loc39_ = _loc41_ + 88;
      si32(_loc39_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.Fmemset();
      _loc6_ += 16;
      _loc6_ = _loc6_ - 16;
      _loc37_ = _loc41_ + 40;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 92);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 96);
      if(_loc39_ >= 106)
      {
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 100);
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 104);
      }
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 108);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 112);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 116);
      _loc39_ = li32(_loc41_ + 96);
      if(_loc39_ >= 106)
      {
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 132);
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 136);
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 140);
      }
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 120);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 124);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 128);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 144);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 148);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 152);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 156);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 160);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 164);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 168);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 172);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 176);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 180);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 184);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 188);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 192);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 196);
      _loc6_ -= 16;
      si32(_loc37_,_loc6_);
      wdnative.ESP = _loc6_;
      wdnative.F__ZN20WeLittleEndianReader7readIntEv();
      _loc6_ += 16;
      _loc39_ = wdnative.eax;
      si32(_loc39_,_loc41_ + 200);
      _loc39_ = li32(_loc41_ + 96);
      if(_loc39_ >= 105)
      {
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 204);
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 208);
         _loc6_ -= 16;
         si32(_loc37_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative.F__ZN20WeLittleEndianReader7readIntEv();
         _loc6_ += 16;
         _loc39_ = wdnative.eax;
         si32(_loc39_,_loc41_ + 212);
      }
      loop14:
      while(true)
      {
         loop15:
         while(true)
         {
            _loc39_ = li32(_loc41_ + 44);
            if(_loc39_ != 1)
            {
               var _loc35_:int = li32(_loc41_ + 108);
               si32(_loc35_,_loc41_ + 88);
               var _temp_80:* = li32(_loc41_ + 84);
               if(_loc35_ >= _temp_80)
               {
                  si32(1,_loc41_ + 44);
                  si32(1,_loc41_ + 48);
               }
               _loc6_ -= 16;
               si32(340,_loc6_ + 8);
               si32(_loc43_,_loc6_ + 4);
               _loc33_ = _loc41_ + 216;
               si32(_loc33_,_loc6_);
               wdnative.ESP = _loc6_;
               wdnative.Fmemset();
               _loc6_ += 16;
               var _loc22_:int = li32(_loc41_ + 96);
               _loc6_ -= 16;
               si32(_loc37_,_loc6_);
               wdnative.ESP = _loc6_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc6_ += 16;
               _loc80_ = wdnative.eax;
               si32(_loc80_,_loc41_ + 216);
               _loc39_ = _loc22_ + -104;
               if((uint(_loc39_)) <= 1)
               {
                  _loc81_ = 0;
                  if(_loc80_ > 0)
                  {
                     do
                     {
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc82_ = wdnative.eax;
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc83_ = wdnative.eax;
                        if(_loc82_ >= 16)
                        {
                           _loc6_ -= 16;
                           si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                           si32(160,_loc6_ + 8);
                           si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                           si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative_nternal.F___assert();
                           _loc6_ += 16;
                        }
                        _loc39_ = _loc82_ << 2;
                        _loc39_ = _loc33_ + _loc39_;
                        si32(_loc83_,_loc39_ + 4);
                        _loc81_ += 1;
                     }
                     while(_loc39_ = li32(_loc41_ + 216), _loc39_ > _loc81_);
                  }
                  _loc6_ -= 16;
                  si32(_loc37_,_loc6_);
                  wdnative.ESP = _loc6_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc6_ += 16;
                  _loc39_ = wdnative.eax;
                  si32(_loc39_,_loc41_ + 284);
                  _loc73_ = 0;
                  loop16:
                  while(true)
                  {
                     while(true)
                     {
                        if(_loc39_ <= 0)
                        {
                           _loc6_ -= 16;
                           si32(_loc37_,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                           _loc6_ += 16;
                           _loc39_ = wdnative.eax;
                           si32(_loc39_,_loc41_ + 352);
                           _loc61_ = 0;
                           if(_loc39_ > 0)
                           {
                              while(true)
                              {
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc54_ = wdnative.eax;
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc49_ = wdnative.eax;
                                 if(_loc54_ >= 16)
                                 {
                                    _loc6_ -= 16;
                                    si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                                    si32(160,_loc6_ + 8);
                                    si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                                    si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                                    wdnative.ESP = _loc6_;
                                    wdnative_nternal.F___assert();
                                    _loc6_ += 16;
                                    §§goto(addr1160);
                                 }
                                 else
                                 {
                                    var _temp_111:* = _loc54_ << 2;
                                    var _temp_112:* = int((_loc35_ = _loc41_ + 352) + _temp_111);
                                    si32(_loc49_,_temp_112 + 4);
                                    _loc61_ += 1;
                                    _loc39_ = li32(_loc41_ + 352);
                                    if(_loc39_ > _loc61_)
                                    {
                                       continue;
                                    }
                                 }
                              }
                              break loop16;
                           }
                        }
                        else
                        {
                           while(true)
                           {
                              _loc6_ -= 16;
                              si32(_loc37_,_loc6_);
                              wdnative.ESP = _loc6_;
                              wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                              _loc6_ += 16;
                              _loc56_ = wdnative.eax;
                              _loc6_ -= 16;
                              si32(_loc37_,_loc6_);
                              wdnative.ESP = _loc6_;
                              wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                              _loc6_ += 16;
                              _loc58_ = wdnative.eax;
                              if(_loc56_ >= 16)
                              {
                                 _loc6_ -= 16;
                                 si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                                 si32(160,_loc6_ + 8);
                                 si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                                 si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative_nternal.F___assert();
                                 _loc6_ += 16;
                                 break;
                              }
                              var _temp_133:* = _loc56_ << 2;
                              var _temp_134:* = int((_loc35_ = _loc41_ + 284) + _temp_133);
                              si32(_loc58_,_temp_134 + 4);
                              _loc73_ += 1;
                              _loc39_ = li32(_loc41_ + 284);
                              if(_loc39_ > _loc73_)
                              {
                                 continue;
                              }
                              §§goto(addr0f32);
                           }
                        }
                        §§goto(addr1049);
                     }
                  }
                  while(true)
                  {
                     _loc6_ -= 16;
                     si32(_loc37_,_loc6_);
                     wdnative.ESP = _loc6_;
                     wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                     _loc6_ += 16;
                     _loc32_ = wdnative.eax;
                     _loc6_ -= 16;
                     si32(_loc37_,_loc6_);
                     wdnative.ESP = _loc6_;
                     wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                     _loc6_ += 16;
                     _loc31_ = wdnative.eax;
                     if(_loc32_ >= 16)
                     {
                        _loc6_ -= 16;
                        si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                        si32(160,_loc6_ + 8);
                        si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                        si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative_nternal.F___assert();
                        _loc6_ += 16;
                        break loop17;
                     }
                     addr1160:
                     _loc39_ = _loc32_ << 2;
                     _loc35_ = _loc41_ + 420;
                     _loc39_ = _loc35_ + _loc39_;
                     si32(_loc31_,_loc39_ + 4);
                     _loc52_ += 1;
                     _loc39_ = li32(_loc41_ + 420);
                     if(_loc39_ <= _loc52_)
                     {
                        break loop17;
                     }
                  }
                  addr1049:
                  _loc6_ -= 16;
                  si32(_loc37_,_loc6_);
                  wdnative.ESP = _loc6_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc6_ += 16;
                  _loc39_ = wdnative.eax;
                  si32(_loc39_,_loc41_ + 420);
                  _loc52_ = 0;
                  addr1198:
                  if(_loc39_ > 0)
                  {
                     §§goto(addr1198);
                  }
                  break loop17;
               }
               if(_loc80_ > 0)
               {
                  do
                  {
                     _loc6_ -= 16;
                     si32(_loc37_,_loc6_);
                     wdnative.ESP = _loc6_;
                     wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                     _loc6_ += 16;
                     _loc75_ = wdnative.eax;
                     if(_loc75_ >= 16)
                     {
                        _loc6_ -= 16;
                        si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                        si32(174,_loc6_ + 8);
                        si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                        si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative_nternal.F___assert();
                        _loc6_ += 16;
                     }
                     _loc39_ = _loc75_ << 2;
                     _loc39_ = _loc33_ + _loc39_;
                     si32(1,_loc39_ + 4);
                     _loc43_ += 1;
                  }
                  while(_loc39_ = li32(_loc41_ + 216), _loc39_ > _loc43_);
               }
               _loc6_ -= 16;
               si32(_loc37_,_loc6_);
               wdnative.ESP = _loc6_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc6_ += 16;
               _loc39_ = wdnative.eax;
               si32(_loc39_,_loc41_ + 284);
               _loc77_ = 0;
               loop18:
               while(true)
               {
                  if(_loc39_ > 0)
                  {
                     while(true)
                     {
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc71_ = wdnative.eax;
                        if(_loc71_ >= 16)
                        {
                           _loc6_ -= 16;
                           si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                           si32(174,_loc6_ + 8);
                           si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                           si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative_nternal.F___assert();
                           _loc6_ += 16;
                           break;
                        }
                        var _temp_150:* = _loc71_ << 2;
                        var _temp_151:* = int((_loc35_ = _loc41_ + 284) + _temp_150);
                        si32(1,_temp_151 + 4);
                        _loc77_ += 1;
                        _loc39_ = li32(_loc41_ + 284);
                        if(_loc39_ > _loc77_)
                        {
                           continue;
                        }
                     }
                     addr0caf:
                     _loc6_ -= 16;
                     si32(_loc37_,_loc6_);
                     wdnative.ESP = _loc6_;
                     wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                     _loc6_ += 16;
                     _loc39_ = wdnative.eax;
                     si32(_loc39_,_loc41_ + 420);
                     _loc70_ = 0;
                     if(_loc39_ <= 0)
                     {
                        break;
                     }
                     while(true)
                     {
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc63_ = wdnative.eax;
                        if(_loc63_ >= 16)
                        {
                           _loc6_ -= 16;
                           si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                           si32(174,_loc6_ + 8);
                           si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                           si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative_nternal.F___assert();
                           _loc6_ += 16;
                           _loc35_ = _loc60_ << 2;
                           _loc39_ = _loc41_ + 488;
                           _loc39_ = _loc39_ + _loc35_;
                           si32(1,_loc39_ + 4);
                           _loc62_ += 1;
                           _loc39_ = li32(_loc41_ + 488);
                           if(_loc39_ > _loc62_)
                           {
                              break;
                           }
                           _loc39_ = li32(_loc41_ + 44);
                           if(_loc39_ != 1)
                           {
                              while(true)
                              {
                                 _loc36_ = li32(_loc41_ + 36);
                                 _loc39_ = _loc36_ & 0x10;
                                 if(_loc39_ != 0)
                                 {
                                    _loc39_ = li32(_loc41_ + 96);
                                    _loc39_ = _loc39_ + -104;
                                    if((uint(_loc39_)) < 2)
                                    {
                                       break;
                                    }
                                    _loc39_ = li32(_loc41_ + 132);
                                    si32(_loc39_,_loc41_ + 88);
                                    var _temp_170:* = li32(_loc41_ + 84);
                                    if(_loc39_ >= _temp_170)
                                    {
                                       si32(1,_loc41_ + 44);
                                       si32(1,_loc41_ + 48);
                                    }
                                    _loc34_ = li32(_loc41_ + 136);
                                    _loc6_ -= 16;
                                    _loc40_ = _loc34_ * 12;
                                    si32(_loc40_,_loc6_);
                                    wdnative.ESP = _loc6_;
                                    wdnative.F__ZN11WeAllocator8allocateEjPKcS1_i();
                                    _loc6_ += 16;
                                    _loc38_ = wdnative.eax;
                                    si32(_loc38_,_loc41_ + 556);
                                    if(_loc38_ == 0)
                                    {
                                       si32(1,_loc41_ + 4);
                                       si32(2,_loc41_ + 8);
                                       break loop15;
                                    }
                                    _loc6_ -= 16;
                                    si32(_loc40_,_loc6_ + 8);
                                    _loc44_ = 0;
                                    si32(_loc44_,_loc6_ + 4);
                                    si32(_loc38_,_loc6_);
                                    wdnative.ESP = _loc6_;
                                    wdnative.Fmemset();
                                    _loc6_ += 16;
                                    if(_loc34_ >= 1)
                                    {
                                       do
                                       {
                                          _loc42_ = li32(_loc41_ + 556);
                                          _loc39_ = li32(_loc41_ + 220);
                                          if(_loc39_ != 0)
                                          {
                                             _loc6_ -= 16;
                                             si32(_loc37_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                             _loc6_ += 16;
                                             si32(wdnative.eax,(_loc6_ -= 16) + 4);
                                             si32(_loc41_,_loc6_);
                                             _loc39_ = _loc44_ * 3;
                                             var _temp_179:* = _loc39_ << 2;
                                             var _temp_182:* = int(_loc42_ + _temp_179);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN11WeSceParser11WeSceLoader13readCharArrayEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_temp_182);
                                          }
                                          _loc39_ = li32(_loc41_ + 224);
                                          if(_loc39_ != 0)
                                          {
                                             _loc6_ -= 16;
                                             si32(_loc37_,_loc6_);
                                             _loc39_ = _loc44_ * 3;
                                             var _temp_185:* = _loc39_ << 2;
                                             var _temp_188:* = int(_loc42_ + _temp_185);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_temp_188 + 4);
                                          }
                                          _loc39_ = li32(_loc41_ + 228);
                                          if(_loc39_ != 0)
                                          {
                                             _loc6_ -= 16;
                                             si32(_loc37_,_loc6_);
                                             _loc39_ = _loc44_ * 3;
                                             var _temp_191:* = _loc39_ << 2;
                                             var _temp_194:* = int(_loc42_ + _temp_191);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_temp_194 + 8);
                                          }
                                          _loc44_ += 1;
                                       }
                                       while(_loc34_ != _loc44_);
                                    }
                                 }
                                 _loc39_ = li32(_loc41_ + 44);
                                 if(_loc39_ != 1)
                                 {
                                    _loc36_ = li32(_loc41_ + 36);
                                    break;
                                 }
                              }
                              _loc39_ = _loc36_ & 4;
                              if(_loc39_ != 0)
                              {
                                 _loc39_ = li32(_loc41_ + 120);
                                 si32(_loc39_,_loc41_ + 88);
                                 var _temp_198:* = li32(_loc41_ + 84);
                                 if(_loc39_ >= _temp_198)
                                 {
                                    si32(1,_loc41_ + 44);
                                    si32(1,_loc41_ + 48);
                                 }
                                 _loc9_ = li32(_loc41_ + 124);
                                 _loc6_ -= 16;
                                 _loc8_ = _loc9_ * 28;
                                 si32(_loc8_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN11WeAllocator8allocateEjPKcS1_i();
                                 _loc6_ += 16;
                                 _loc14_ = wdnative.eax;
                                 si32(_loc14_,_loc41_ + 560);
                                 if(_loc14_ == 0)
                                 {
                                    si32(1,_loc41_ + 4);
                                    si32(2,_loc41_ + 8);
                                    break loop15;
                                 }
                                 _loc6_ -= 16;
                                 si32(_loc8_,_loc6_ + 8);
                                 _loc13_ = 0;
                                 si32(_loc13_,_loc6_ + 4);
                                 si32(_loc14_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.Fmemset();
                                 _loc6_ += 16;
                                 _loc39_ = li32(_loc41_ + 96);
                                 var _temp_206:* = int(_loc39_ + -104);
                                 _loc12_ = (_loc35_ = (_loc35_ = li32(_loc41_ + 36)) >>> 3) & 1;
                                 if(uint(_temp_206) <= 1)
                                 {
                                    if(_loc9_ >= 1)
                                    {
                                       _loc11_ = li32(_loc41_ + 232);
                                       _loc17_ = li32(_loc41_ + 228);
                                       _loc16_ = li32(_loc41_ + 224);
                                       _loc15_ = li32(_loc41_ + 220);
                                       _loc74_ = 0;
                                       if(_loc12_ == 0)
                                       {
                                          _loc72_ = _loc11_ + _loc17_;
                                          _loc78_ = li32(_loc41_ + 84);
                                          _loc76_ = li32(_loc41_ + 88);
                                          _loc87_ = 0;
                                          do
                                          {
                                             _loc39_ = _loc76_ + _loc15_;
                                             _loc86_ = li32(_loc41_ + 560);
                                             si32(_loc39_,_loc41_ + 88);
                                             if(_loc39_ >= _loc78_)
                                             {
                                                si32(1,_loc41_ + 44);
                                                si32(1,_loc41_ + 48);
                                             }
                                             _loc6_ -= 16;
                                             si32(_loc16_,_loc6_ + 4);
                                             si32(_loc37_,_loc6_);
                                             _loc39_ = _loc87_ * 7;
                                             _loc39_ = _loc39_ << 2;
                                             var _loc89_:int = _loc86_ + _loc39_;
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_loc89_);
                                             _loc39_ = li32(_loc41_ + 88);
                                             _loc76_ = _loc72_ + _loc39_;
                                             si32(_loc76_,_loc41_ + 88);
                                             _loc78_ = li32(_loc41_ + 84);
                                             if(_loc76_ >= _loc78_)
                                             {
                                                si32(1,_loc41_ + 44);
                                                si32(1,_loc41_ + 48);
                                             }
                                             _loc87_ += 1;
                                          }
                                          while(_loc9_ != _loc87_);
                                       }
                                       else
                                       {
                                          do
                                          {
                                             _loc39_ = li32(_loc41_ + 560);
                                             _loc6_ -= 16;
                                             si32(_loc15_,_loc6_ + 4);
                                             si32(_loc41_,_loc6_);
                                             _loc35_ = _loc74_ * 7;
                                             _loc35_ = _loc35_ << 2;
                                             var _loc88_:int = _loc39_ + _loc35_;
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN11WeSceParser11WeSceLoader13readCharArrayEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_loc88_ + 16);
                                             _loc6_ -= 16;
                                             si32(_loc16_,_loc6_ + 4);
                                             si32(_loc37_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_loc88_);
                                             _loc6_ -= 16;
                                             si32(_loc11_,_loc6_ + 4);
                                             si32(_loc37_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_loc88_ + 4);
                                             _loc6_ -= 16;
                                             si32(_loc17_,_loc6_ + 4);
                                             si32(_loc37_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader12readIntByLenEi();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_loc88_ + 8);
                                             _loc74_ += 1;
                                          }
                                          while(_loc9_ != _loc74_);
                                       }
                                    }
                                 }
                                 else
                                 {
                                    _loc39_ = li32(_loc41_ + 292);
                                    if(_loc39_ != _loc13_)
                                    {
                                       _loc13_ = 4;
                                    }
                                    if(_loc9_ >= 1)
                                    {
                                       var _temp_221:* = li32(_loc41_ + 296);
                                       _loc85_ = 0;
                                       if(_temp_221 != 0)
                                       {
                                          _loc85_ = -4;
                                       }
                                       _loc39_ = li32(_loc41_ + 300);
                                       _loc84_ = 0;
                                       if(_loc39_ != 0)
                                       {
                                          _loc84_ = -4;
                                       }
                                       _loc39_ = -8 - _loc13_;
                                       _loc39_ = _loc39_ + _loc84_;
                                       _loc59_ = _loc39_ + _loc85_;
                                       _loc39_ = _loc85_ + _loc84_;
                                       _loc39_ = _loc39_ + -9;
                                       _loc57_ = _loc39_ - _loc13_;
                                       _loc55_ = 0;
                                       do
                                       {
                                          _loc53_ = li32(_loc41_ + 560);
                                          _loc39_ = li32(_loc41_ + 288);
                                          _loc51_ = 0;
                                          if(_loc39_ != 0)
                                          {
                                             _loc6_ -= 16;
                                             si32(_loc37_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                             _loc6_ += 16;
                                             _loc51_ = wdnative.eax;
                                          }
                                          _loc39_ = li32(_loc41_ + 292);
                                          if(_loc39_ != 0)
                                          {
                                             _loc6_ -= 16;
                                             si32(_loc37_,_loc6_);
                                             _loc39_ = _loc55_ * 7;
                                             var _temp_229:* = _loc39_ << 2;
                                             var _temp_232:* = int(_loc53_ + _temp_229);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                             _loc6_ += 16;
                                             _loc39_ = wdnative.eax;
                                             si32(_loc39_,_temp_232);
                                          }
                                          if(_loc12_ == 0)
                                          {
                                             var _temp_234:* = int(_loc51_ - _loc13_);
                                             _loc35_ = (_loc35_ = li32(_loc41_ + 88)) + _temp_234;
                                             si32(_loc35_,_loc41_ + 88);
                                             var _temp_236:* = li32(_loc41_ + 84);
                                             if(_loc35_ >= _temp_236)
                                             {
                                                si32(1,_loc41_ + 44);
                                                si32(1,_loc41_ + 48);
                                             }
                                          }
                                          else
                                          {
                                             _loc39_ = li32(_loc41_ + 296);
                                             if(_loc39_ != 0)
                                             {
                                                _loc6_ -= 16;
                                                si32(_loc37_,_loc6_);
                                                _loc39_ = _loc55_ * 7;
                                                var _temp_239:* = _loc39_ << 2;
                                                var _temp_242:* = int(_loc53_ + _temp_239);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                                _loc6_ += 16;
                                                _loc39_ = wdnative.eax;
                                                si32(_loc39_,_temp_242 + 4);
                                             }
                                             _loc39_ = li32(_loc41_ + 300);
                                             if(_loc39_ != 0)
                                             {
                                                _loc6_ -= 16;
                                                si32(_loc37_,_loc6_);
                                                _loc39_ = _loc55_ * 7;
                                                var _temp_245:* = _loc39_ << 2;
                                                var _temp_248:* = int(_loc53_ + _temp_245);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                                _loc6_ += 16;
                                                _loc39_ = wdnative.eax;
                                                si32(_loc39_,_temp_248 + 8);
                                             }
                                             _loc39_ = li32(_loc41_ + 304);
                                             _loc65_ = _loc66_ = 0;
                                             if(_loc39_ != 0)
                                             {
                                                _loc6_ -= 16;
                                                si32(_loc37_,_loc6_);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                                _loc6_ += 16;
                                                _loc65_ = wdnative.eax;
                                                _loc6_ -= 16;
                                                si32(_loc65_,_loc6_ + 4);
                                                si32(_loc41_,_loc6_);
                                                _loc39_ = _loc55_ * 7;
                                                var _temp_251:* = _loc39_ << 2;
                                                var _temp_254:* = int(_loc53_ + _temp_251);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN11WeSceParser11WeSceLoader13readCharArrayEi();
                                                _loc6_ += 16;
                                                _loc39_ = wdnative.eax;
                                                si32(_loc39_,_temp_254 + 12);
                                             }
                                             _loc39_ = li32(_loc41_ + 308);
                                             _loc24_ = _loc66_;
                                             if(_loc39_ != 0)
                                             {
                                                _loc6_ -= 16;
                                                si32(_loc37_,_loc6_);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                                _loc6_ += 16;
                                                _loc24_ = wdnative.eax;
                                                _loc6_ -= 16;
                                                si32(_loc24_,_loc6_ + 4);
                                                si32(_loc41_,_loc6_);
                                                _loc39_ = _loc55_ * 7;
                                                var _temp_257:* = _loc39_ << 2;
                                                var _temp_260:* = int(_loc53_ + _temp_257);
                                                wdnative.ESP = _loc6_;
                                                wdnative.F__ZN11WeSceParser11WeSceLoader13readCharArrayEi();
                                                _loc6_ += 16;
                                                _loc39_ = wdnative.eax;
                                                si32(_loc39_,_temp_260 + 16);
                                             }
                                             _loc39_ = _loc59_ + _loc51_;
                                             _loc39_ = _loc39_ - _loc65_;
                                             _loc29_ = _loc39_ - _loc24_;
                                             _loc39_ = _loc55_ * 7;
                                             _loc39_ = _loc39_ << 2;
                                             _loc25_ = _loc53_ + _loc39_;
                                             si32(_loc29_,_loc25_ + 24);
                                             _loc6_ -= 16;
                                             si32(_loc29_,_loc6_);
                                             wdnative.ESP = _loc6_;
                                             wdnative.F__ZN11WeAllocator8allocateEjPKcS1_i();
                                             _loc6_ += 16;
                                             _loc26_ = wdnative.eax;
                                             if(_loc26_ == 0)
                                             {
                                                si32(1,_loc41_ + 4);
                                                si32(2,_loc41_ + 8);
                                                _loc20_ = 0;
                                             }
                                             else
                                             {
                                                while(true)
                                                {
                                                   _loc20_ = _loc26_;
                                                   if(_loc66_ >= _loc29_)
                                                   {
                                                      break;
                                                   }
                                                   _loc39_ = li32(_loc37_);
                                                   var _loc21_:int = li32(_loc39_ + 8);
                                                   _loc6_ -= 16;
                                                   si32(_loc37_,_loc6_);
                                                   wdnative.ESP = _loc6_;
                                                   wdnative.ptr2fun[_loc21_]();
                                                   _loc6_ += 16;
                                                   _loc39_ = wdnative.eax;
                                                   if(_loc39_ == 0)
                                                   {
                                                      _loc18_ = li32(_loc41_ + 88);
                                                      var _temp_274:* = li32(_loc41_ + 84);
                                                      if(_loc18_ >= _temp_274)
                                                      {
                                                         si32(1,_loc41_ + 44);
                                                         si32(1,_loc41_ + 48);
                                                         _loc19_ = 0;
                                                      }
                                                      else
                                                      {
                                                         _loc39_ = li32(_loc41_ + 76);
                                                         _loc39_ = _loc39_ + _loc18_;
                                                         _loc19_ = li8(_loc39_);
                                                         _loc39_ = _loc18_ + 1;
                                                         si32(_loc39_,_loc41_ + 88);
                                                      }
                                                      _loc39_ = _loc26_ + _loc66_;
                                                      si8(_loc19_,_loc39_);
                                                      _loc66_ += 1;
                                                      continue;
                                                   }
                                                   _loc39_ = _loc57_ + _loc51_;
                                                   _loc39_ = _loc39_ - _loc24_;
                                                   var _temp_280:* = int(_loc39_ - _loc65_);
                                                   _loc20_ = _loc26_;
                                                   if(_temp_280 != _loc66_)
                                                   {
                                                      si32(1,_loc41_ + 4);
                                                      si32(1,_loc41_ + 8);
                                                      _loc20_ = 0;
                                                      if(_loc26_ != 0)
                                                      {
                                                         _loc6_ -= 16;
                                                         si32(_loc26_,_loc6_);
                                                         wdnative.ESP = _loc6_;
                                                         wdnative_nternal.F_idalloc();
                                                         _loc6_ += 16;
                                                         _loc20_ = 0;
                                                      }
                                                   }
                                                }
                                             }
                                             si32(_loc20_,_loc25_ + 20);
                                          }
                                          _loc55_ += 1;
                                       }
                                       while(_loc9_ != _loc55_);
                                    }
                                 }
                              }
                              _loc39_ = li32(_loc41_ + 44);
                              if(_loc39_ != 1)
                              {
                                 si32(0,_loc41_ + 588);
                                 si32(0,_loc41_ + 584);
                                 si32(0,_loc41_ + 580);
                                 si32(0,_loc41_ + 576);
                                 si32(0,_loc41_ + 572);
                                 si32(0,_loc41_ + 568);
                                 si32(0,_loc41_ + 564);
                                 _loc39_ = li8(_loc41_ + 36);
                                 var _temp_284:* = _loc39_ & 0x20;
                                 _loc4_ = _loc41_;
                                 if(_temp_284 == 0)
                                 {
                                    break loop14;
                                 }
                                 _loc5_ = li32(_loc41_ + 180);
                                 var _temp_285:* = li32(_loc41_ + 84);
                                 _loc4_ = _loc41_;
                                 if(_loc5_ >= _temp_285)
                                 {
                                    break loop14;
                                 }
                                 si32(_loc5_,_loc41_ + 88);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 564);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 568);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 572);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 576);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 580);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 584);
                                 _loc6_ -= 16;
                                 si32(_loc37_,_loc6_);
                                 wdnative.ESP = _loc6_;
                                 wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                                 _loc6_ += 16;
                                 _loc39_ = wdnative.eax;
                                 si32(_loc39_,_loc41_ + 588);
                                 var _temp_300:* = li32(_loc41_ + 44);
                                 _loc4_ = _loc41_;
                                 if(_temp_300 != 1)
                                 {
                                    break loop14;
                                 }
                              }
                           }
                           _loc4_ = 0;
                           if(_loc41_ != 0)
                           {
                              break loop15;
                           }
                           break loop14;
                        }
                        var _temp_302:* = _loc63_ << 2;
                        var _temp_303:* = int((_loc35_ = _loc41_ + 420) + _temp_302);
                        si32(1,_temp_303 + 4);
                        _loc70_ += 1;
                        _loc39_ = li32(_loc41_ + 420);
                        if(_loc39_ <= _loc70_)
                        {
                           break loop18;
                        }
                     }
                     while(true)
                     {
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc60_ = wdnative.eax;
                        if(_loc60_ >= 16)
                        {
                           _loc6_ -= 16;
                           si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                           si32(174,_loc6_ + 8);
                           si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                           si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative_nternal.F___assert();
                           _loc6_ += 16;
                           §§goto(addr0f32);
                        }
                        else
                        {
                           §§goto(addr0e85);
                        }
                        addr0e85:
                     }
                     break;
                  }
                  _loc6_ -= 16;
                  si32(_loc37_,_loc6_);
                  wdnative.ESP = _loc6_;
                  wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                  _loc6_ += 16;
                  _loc39_ = wdnative.eax;
                  si32(_loc39_,_loc41_ + 352);
                  _loc79_ = 0;
                  if(_loc39_ > 0)
                  {
                     while(true)
                     {
                        _loc6_ -= 16;
                        si32(_loc37_,_loc6_);
                        wdnative.ESP = _loc6_;
                        wdnative.F__ZN20WeLittleEndianReader7readIntEv();
                        _loc6_ += 16;
                        _loc64_ = wdnative.eax;
                        if(_loc64_ >= 16)
                        {
                           _loc6_ -= 16;
                           si32(wdnative_nternal.L__2E_str648,_loc6_ + 12);
                           si32(174,_loc6_ + 8);
                           si32(wdnative_nternal.L__2E_str42,_loc6_ + 4);
                           si32(wdnative_nternal.__ZZN11WeSceParser11WeSceLoader18loadFlagIdentifierEvE8__func__,_loc6_);
                           wdnative.ESP = _loc6_;
                           wdnative_nternal.F___assert();
                           _loc6_ += 16;
                           break loop18;
                        }
                        var _temp_480:* = _loc64_ << 2;
                        var _temp_481:* = int((_loc39_ = _loc41_ + 352) + _temp_480);
                        si32(1,_temp_481 + 4);
                        _loc79_ += 1;
                        _loc39_ = li32(_loc41_ + 352);
                        if(_loc39_ > _loc79_)
                        {
                           continue;
                        }
                        §§goto(addr0caf);
                     }
                     break;
                  }
                  §§goto(addr0caf);
               }
               _loc6_ -= 16;
               si32(_loc37_,_loc6_);
               wdnative.ESP = _loc6_;
               wdnative.F__ZN20WeLittleEndianReader7readIntEv();
               _loc6_ += 16;
               _loc39_ = wdnative.eax;
               si32(_loc39_,_loc41_ + 488);
               _loc62_ = 0;
               if(_loc39_ > 0)
               {
                  §§goto(addr0ebd);
               }
               §§goto(addr1239);
            }
            §§goto(addr1ec2);
         }
         _loc6_ -= 16;
         si32(_loc41_,_loc6_);
         wdnative.ESP = _loc6_;
         wdnative_nternal.F_idalloc();
         _loc6_ += 16;
         _loc4_ = 0;
         break;
      }
      var _loc50_:int;
      var _loc27_:int = _loc50_ = _loc4_;
      wdnative.ESP = _loc6_ = _loc7_;
      return _loc27_;
   }
}

