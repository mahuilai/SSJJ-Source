package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.Fmemset;
   import wdnative.eax;
   
   public function F_arena_malloc() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc18_:int = 0;
      var _loc14_:int = 0;
      var _loc4_:int = 0;
      var _loc15_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc11_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc7_ = _loc3_;
      _loc4_ = 3840;
      var _loc19_:int = li8(wdnative_nternal._sspace_max_2E_b);
      if(_loc19_ == 0)
      {
         _loc4_ = 0;
      }
      _loc18_ = li32(_loc7_ + 8);
      _loc17_ = li32(_loc7_ + 4);
      _loc16_ = li32(_loc7_);
      if(uint(_loc4_) < uint(_loc17_))
      {
         _loc3_ -= 16;
         si32(_loc18_,_loc3_ + 12);
         si32(1,_loc3_ + 8);
         si32(_loc16_,_loc3_);
         _loc19_ = _loc17_ + 4095;
         _loc17_ = _loc19_ & -4096;
         si32(_loc17_,_loc3_ + 4);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F_arena_run_alloc();
         _loc14_ = 0;
         _loc3_ += 16;
         _loc4_ = wdnative.eax;
         if(_loc4_ != 0)
         {
            _loc14_ = _loc4_;
            if(_loc18_ == 0)
            {
               _loc19_ = li8(wdnative_nternal._opt_junk_2E_b);
               if(_loc19_ == 1)
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_ + 8);
                  si32(165,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.Fmemset();
                  _loc3_ += 16;
                  _loc14_ = _loc4_;
                  break loop4;
               }
               var _temp_129:* = li8(wdnative_nternal._opt_zero_2E_b);
               _loc14_ = _loc4_;
               if(_temp_129 == 1)
               {
                  _loc3_ -= 16;
                  si32(_loc17_,_loc3_ + 8);
                  si32(0,_loc3_ + 4);
                  si32(_loc4_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.Fmemset();
                  _loc3_ += 16;
                  _loc14_ = _loc4_;
               }
            }
         }
         break loop4;
      }
      _loc19_ = li32(wdnative_nternal._size2bin);
      _loc19_ = _loc19_ + _loc17_;
      _loc19_ = li8(_loc19_);
      var _temp_6:* = int(_loc19_ * 40);
      _loc17_ = _loc16_ + _temp_6;
      _loc15_ = li32(_loc17_ + 60);
      _loc4_ = li32(_loc17_ + 80);
      loop4:
      while(true)
      {
         while(true)
         {
            if(_loc15_ != 0)
            {
               _loc19_ = li32(_loc15_ + 8);
               if(_loc19_ != 0)
               {
                  _loc14_ = li32(_loc15_ + 4);
                  var _temp_10:* = _loc14_ << 2;
                  _loc16_ = _loc15_ + _temp_10;
                  _loc13_ = li32(_loc16_ + 12);
                  if(_loc13_ == 0)
                  {
                     _loc12_ = li32(_loc17_ + 92);
                     _loc1_ = _loc4_ << 5;
                     _loc8_ = _loc16_ = 0;
                     _loc13_ = _loc14_;
                     while(true)
                     {
                        _loc5_ = _loc13_ + 1;
                        if(uint(_loc12_) <= uint(_loc5_))
                        {
                           break;
                        }
                        _loc8_ += _loc1_;
                        var _temp_13:* = _loc13_ << 2;
                        _loc11_ = _loc15_ + _temp_13;
                        _loc2_ = li32(_loc11_ + 16);
                        _loc13_ = _loc5_;
                        if(_loc2_ != 0)
                        {
                           var _temp_16:* = int(_loc2_ + -1);
                           _loc19_ = (_loc19_ = _loc2_ ^ -1) & _temp_16;
                           var _loc9_:int = _loc19_ >>> 1;
                           var _temp_19:* = _loc9_ & 0x55555555;
                           _loc9_ = _loc19_ - _temp_19;
                           _loc9_ = (_loc9_ & 0x33333333) + ((_loc9_ >>>= 2) & 0x33333333);
                           var _temp_23:* = _loc9_ >>> 4;
                           _loc19_ = _loc9_ + _temp_23;
                           _loc19_ = _loc19_ & 0x0F0F0F0F;
                           _loc19_ = _loc19_ * 16843009;
                           _loc9_ = _loc19_ >>> 24;
                           _loc19_ = 1 << _loc9_;
                           var _temp_28:* = _loc19_ ^ _loc2_;
                           _loc19_ = li32(_loc17_ + 96);
                           si32(_temp_28,_loc11_ + 16);
                           si32(_loc5_,_loc15_ + 4);
                           var _temp_29:* = _loc14_ << 5;
                           var _temp_30:* = int(_loc9_ + _temp_29);
                           var _temp_32:* = int(_loc4_ * _temp_30);
                           _loc19_ = (_loc19_ = _loc15_ + _loc19_) + _temp_32;
                           _loc16_ = _loc19_ + _loc8_;
                           break;
                        }
                     }
                  }
                  else
                  {
                     var _temp_35:* = int(_loc13_ + -1);
                     _loc19_ = (_loc19_ = _loc13_ ^ -1) & _temp_35;
                     _loc9_ = _loc19_ >>> 1;
                     var _temp_38:* = _loc9_ & 0x55555555;
                     _loc9_ = _loc19_ - _temp_38;
                     _loc9_ = (_loc9_ & 0x33333333) + ((_loc9_ >>>= 2) & 0x33333333);
                     var _temp_42:* = _loc9_ >>> 4;
                     _loc19_ = _loc9_ + _temp_42;
                     _loc19_ = _loc19_ & 0x0F0F0F0F;
                     _loc19_ = _loc19_ * 16843009;
                     _loc9_ = _loc19_ >>> 24;
                     _loc19_ = 1 << _loc9_;
                     var _temp_47:* = _loc19_ ^ _loc13_;
                     _loc19_ = li32(_loc17_ + 96);
                     si32(_temp_47,_loc16_ + 12);
                     var _temp_48:* = _loc14_ << 5;
                     _loc9_ += _temp_48;
                     var _temp_51:* = int(_loc9_ * _loc4_);
                     _loc16_ = (_loc19_ += _loc15_) + _temp_51;
                  }
                  _loc19_ = li32(_loc15_ + 8);
                  _loc19_ = _loc19_ + -1;
                  si32(_loc19_,_loc15_ + 8);
                  break;
               }
            }
            _loc14_ = _loc17_ + 60;
            _loc8_ = li32(_loc17_ + 64);
            _loc15_ = _loc17_ + 68;
            while(true)
            {
               _loc13_ = _loc8_;
               _loc8_ = li32(_loc13_);
               if(_loc8_ == _loc15_)
               {
                  break;
               }
            }
            _loc8_ = 0;
            if(_loc15_ != _loc13_)
            {
               _loc8_ = _loc13_;
            }
            if(_loc8_ != 0)
            {
               var _temp_56:* = int(_loc17_ + 64);
               _loc3_ -= 16;
               si32(_temp_56,_loc3_);
               si32(_loc8_,_loc3_ + 4);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_arena_run_tree_remove();
               _loc3_ += 16;
               _loc19_ = li32(_loc8_ + 8);
               _loc15_ = _loc19_ & -4096;
            }
            else
            {
               var _temp_59:* = li32(_loc17_ + 84);
               _loc3_ -= 16;
               _loc13_ = 0;
               si32(_loc13_,_loc3_ + 12);
               si32(_loc13_,_loc3_ + 8);
               si32(_temp_59,_loc3_ + 4);
               si32(_loc16_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_arena_run_alloc();
               _loc3_ += 16;
               _loc15_ = wdnative.eax;
               if(_loc15_ == 0)
               {
                  _loc14_ = 0;
                  si32(_loc14_,_loc17_ + 60);
                  break loop4;
               }
               si32(_loc14_,_loc15_);
               _loc19_ = li32(_loc17_ + 92);
               if(_loc19_ != 1)
               {
                  _loc13_ = 0;
                  do
                  {
                     _loc19_ = _loc13_ << 2;
                     _loc19_ = _loc15_ + _loc19_;
                     si32(-1,_loc19_ + 12);
                     _loc19_ = li32(_loc17_ + 92);
                     _loc19_ = _loc19_ + -1;
                     _loc13_ += 1;
                  }
                  while(uint(_loc19_) > uint(_loc13_));
               }
               _loc19_ = li32(_loc17_ + 88);
               _loc16_ = _loc19_ & 0x1F;
               if(_loc16_ == 0)
               {
                  var _temp_66:* = _loc13_ << 2;
                  var _temp_67:* = int(_loc15_ + _temp_66);
                  si32(-1,_temp_67 + 12);
               }
               else
               {
                  var _temp_68:* = int(32 - _loc16_);
                  var _temp_70:* = -1 >>> _temp_68;
                  var _temp_69:* = _loc13_ << 2;
                  si32(_temp_70,int(_loc15_ + _temp_69) + 12);
               }
               si32(0,_loc15_ + 4);
               _loc19_ = li32(_loc17_ + 88);
               si32(_loc19_,_loc15_ + 8);
            }
            si32(_loc15_,_loc17_ + 60);
            _loc14_ = 0;
            if(_loc15_ != 0)
            {
               _loc14_ = li32(_loc15_ + 4);
               var _temp_73:* = _loc14_ << 2;
               _loc16_ = _loc15_ + _temp_73;
               _loc13_ = li32(_loc16_ + 12);
               if(_loc13_ == 0)
               {
                  _loc8_ = li32(_loc17_ + 92);
                  _loc16_ = 0;
                  _loc12_ = _loc14_;
                  _loc11_ = _loc16_;
                  while(true)
                  {
                     _loc5_ = _loc12_ + 1;
                     if(uint(_loc8_) <= uint(_loc5_))
                     {
                        break;
                     }
                     var _temp_76:* = _loc12_ << 2;
                     _loc1_ = _loc15_ + _temp_76;
                     _loc13_ = li32(_loc1_ + 16);
                     _loc11_ += 1;
                     _loc12_ = _loc5_;
                     if(_loc13_ != 0)
                     {
                        var _temp_78:* = int(_loc13_ + -1);
                        _loc19_ = (_loc19_ = _loc13_ ^ -1) & _temp_78;
                        _loc9_ = _loc19_ >>> 1;
                        var _temp_81:* = _loc9_ & 0x55555555;
                        _loc9_ = _loc19_ - _temp_81;
                        _loc9_ = (_loc9_ & 0x33333333) + ((_loc9_ >>>= 2) & 0x33333333);
                        var _temp_85:* = _loc9_ >>> 4;
                        _loc19_ = _loc9_ + _temp_85;
                        _loc19_ = _loc19_ & 0x0F0F0F0F;
                        _loc19_ = _loc19_ * 16843009;
                        var _loc10_:int = _loc19_ >>> 24;
                        _loc19_ = 1 << _loc10_;
                        var _temp_90:* = _loc19_ ^ _loc13_;
                        _loc9_ = li32(_loc17_ + 96);
                        _loc19_ = li32(_loc17_ + 80);
                        si32(_temp_90,_loc1_ + 16);
                        si32(_loc5_,_loc15_ + 4);
                        var _temp_91:* = _loc14_ << 5;
                        var _temp_92:* = int(_loc10_ + _temp_91);
                        var _temp_94:* = int(_loc19_ * _temp_92);
                        var _temp_97:* = int((_loc9_ = _loc15_ + _loc9_) + _temp_94);
                        _loc16_ = (_loc19_ = (_loc19_ *= _loc11_) << 5) + _temp_97;
                        break;
                     }
                  }
               }
               else
               {
                  var _temp_99:* = int(_loc13_ + -1);
                  _loc19_ = (_loc9_ = _loc13_ ^ -1) & _temp_99;
                  _loc9_ = _loc19_ >>> 1;
                  var _temp_102:* = _loc9_ & 0x55555555;
                  _loc9_ = _loc19_ - _temp_102;
                  _loc9_ = (_loc9_ & 0x33333333) + ((_loc9_ >>>= 2) & 0x33333333);
                  var _temp_106:* = _loc9_ >>> 4;
                  _loc19_ = _loc9_ + _temp_106;
                  _loc19_ = _loc19_ & 0x0F0F0F0F;
                  _loc19_ = _loc19_ * 16843009;
                  _loc10_ = _loc19_ >>> 24;
                  _loc19_ = 1 << _loc10_;
                  var _temp_111:* = _loc19_ ^ _loc13_;
                  _loc19_ = li32(_loc17_ + 96);
                  _loc9_ = li32(_loc17_ + 80);
                  si32(_temp_111,_loc16_ + 12);
                  var _temp_112:* = _loc14_ << 5;
                  var _temp_113:* = int(_loc10_ + _temp_112);
                  var _temp_115:* = int(_loc9_ * _temp_113);
                  _loc16_ = (_loc19_ += _loc15_) + _temp_115;
               }
               _loc19_ = li32(_loc15_ + 8);
               _loc19_ = _loc19_ + -1;
               si32(_loc19_,_loc15_ + 8);
               break;
            }
            break loop4;
         }
         _loc14_ = 0;
         if(_loc16_ != 0)
         {
            if(_loc18_ == 0)
            {
               _loc19_ = li8(wdnative_nternal._opt_junk_2E_b);
               if(_loc19_ == 1)
               {
                  _loc3_ -= 16;
                  si32(_loc4_,_loc3_ + 8);
                  si32(165,_loc3_ + 4);
                  si32(_loc16_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.Fmemset();
                  _loc3_ += 16;
                  _loc14_ = _loc16_;
                  break;
               }
               var _temp_120:* = li8(wdnative_nternal._opt_zero_2E_b);
               _loc14_ = _loc16_;
               if(_temp_120 == 1)
               {
                  _loc3_ -= 16;
                  si32(_loc4_,_loc3_ + 8);
                  si32(0,_loc3_ + 4);
                  si32(_loc16_,_loc3_);
                  wdnative.ESP = _loc3_;
                  wdnative.Fmemset();
                  _loc3_ += 16;
                  _loc14_ = _loc16_;
               }
               break;
            }
            _loc3_ -= 16;
            si32(_loc4_,_loc3_ + 8);
            si32(0,_loc3_ + 4);
            si32(_loc16_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative.Fmemset();
            _loc3_ += 16;
            _loc14_ = _loc16_;
         }
         break;
      }
      break loop4;
   }
}

