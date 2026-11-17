package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.Fmemset;
   
   public function F_idalloc() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc12_:int = 0;
      var _loc11_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(wdnative_nternal._chunksize_mask);
      _loc1_ ^= -1;
      _loc12_ = li32(_loc3_);
      _loc11_ = _loc12_ & _loc1_;
      if(_loc11_ != _loc12_)
      {
         var _temp_4:* = int((int(_loc12_ - _loc11_) >>> 12) * 12);
         _loc10_ = li32(int(_loc11_ + _temp_4) + 24);
         var _temp_6:* = _loc10_ & 2;
         _loc9_ = li32(_loc11_);
         if(_temp_6 == 0)
         {
            _loc10_ &= -4096;
            _loc8_ = li32(_loc10_);
            _loc7_ = li32(_loc8_ + 20);
            if(li8(wdnative_nternal._opt_junk_2E_b) == 1)
            {
               _loc2_ -= 16;
               si32(_loc7_,_loc2_ + 8);
               si32(90,_loc2_ + 4);
               si32(_loc12_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.Fmemset();
               _loc2_ += 16;
            }
            var _loc6_:int = _loc12_ - _loc10_;
            _loc1_ = li32(_loc8_ + 36);
            _loc5_ = _loc6_ - _loc1_;
            _loc12_ = _loc7_ + -1;
            _loc1_ = _loc12_ & _loc7_;
            if(_loc1_ == 0)
            {
               if(uint(_loc7_) <= 128)
               {
                  var _temp_11:* = li8(int(wdnative_nternal._log2_table_2E_10531 + _loc12_));
                  _loc7_ = _loc5_ >>> _temp_11;
               }
               else if(uint(_loc7_) <= 32768)
               {
                  var _temp_12:* = int(li8(int((_loc7_ >>> 8) + wdnative_nternal._log2_table_2E_10531) - 1) + 8);
                  _loc7_ = _loc5_ >>> _temp_12;
               }
               else
               {
                  _loc7_ = uint(_loc5_) / uint(_loc7_);
               }
            }
            else if(uint(li32(wdnative_nternal._qspace_max)) > uint(_loc7_))
            {
               if(uint(_loc7_) <= 112)
               {
                  _loc7_ = int(li32(int(((_loc7_ & -16) >>> 2) + wdnative_nternal._qsize_invs_2E_10532) - 12) * _loc5_) >>> 21;
               }
               else
               {
                  _loc7_ = uint(_loc5_) / uint(_loc7_);
               }
            }
            else if(uint(li32(wdnative_nternal._cspace_max)) > uint(_loc7_))
            {
               if(uint(_loc7_) <= 448)
               {
                  _loc7_ = int(li32(int(((_loc7_ & -64) >>> 4) + wdnative_nternal._csize_invs_2E_10533) - 12) * _loc5_) >>> 21;
               }
               else
               {
                  _loc7_ = uint(_loc5_) / uint(_loc7_);
               }
            }
            else if(uint(_loc7_) <= 3839)
            {
               _loc7_ = int(li32(int(((_loc7_ & -256) >>> 6) + wdnative_nternal._ssize_invs_2E_10534) - 12) * _loc5_) >>> 21;
            }
            else
            {
               _loc7_ = uint(_loc5_) / uint(_loc7_);
            }
            _loc12_ = _loc7_ >>> 5;
            _loc1_ = li32(_loc10_ + 4);
            if(uint(_loc1_) > uint(_loc12_))
            {
               si32(_loc12_,_loc10_ + 4);
            }
            _loc1_ = _loc7_ & 0x1F;
            _loc1_ = 1 << _loc1_;
            _loc6_ = _loc12_ << 2;
            _loc6_ = _loc10_ + _loc6_;
            var _loc4_:int = li32(_loc6_ + 12);
            _loc1_ = _loc4_ | _loc1_;
            si32(_loc1_,_loc6_ + 12);
            _loc12_ = li32(_loc10_ + 8);
            _loc1_ = _loc12_ + 1;
            si32(_loc1_,_loc10_ + 8);
            _loc7_ = li32(_loc8_ + 28);
            if(_loc1_ == _loc7_)
            {
               if(li32(_loc8_) == _loc10_)
               {
                  si32(0,_loc8_);
               }
               else if(_loc7_ != 1)
               {
                  _loc2_ -= 16;
                  si32(int(_loc8_ + 4),_loc2_);
                  var _temp_16:* = int((int(_loc10_ - _loc11_) >>> 12) * 12);
                  si32(int(int(_loc11_ + _temp_16) + 16),_loc2_ + 4);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_arena_run_tree_remove();
                  _loc2_ += 16;
               }
               _loc2_ -= 16;
               si32(1,_loc2_ + 8);
               si32(_loc10_,_loc2_ + 4);
               si32(_loc9_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_arena_run_dalloc();
               _loc2_ += 16;
            }
            else if(_loc12_ == 0)
            {
               _loc9_ = li32(_loc8_);
               if(_loc9_ != _loc10_)
               {
                  if(_loc9_ == 0)
                  {
                     si32(_loc10_,_loc8_);
                  }
                  else if(uint(_loc10_) < uint(_loc9_))
                  {
                     if(li32(_loc9_ + 8) != 0)
                     {
                        var _temp_20:* = li32(wdnative_nternal._chunksize_mask);
                        _loc2_ -= 16;
                        si32(int(_loc8_ + 4),_loc2_);
                        var _temp_21:* = _temp_20 ^ -1;
                        _loc1_ = _loc9_ & _temp_21;
                        _loc6_ = _loc9_ - _loc1_;
                        _loc6_ = _loc6_ >>> 12;
                        var _temp_24:* = int(_loc6_ * 12);
                        si32(int(int(_loc1_ + _temp_24) + 16),_loc2_ + 4);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_arena_run_tree_insert();
                        _loc2_ += 16;
                     }
                     si32(_loc10_,_loc8_);
                  }
                  else
                  {
                     _loc2_ -= 16;
                     si32(int(_loc8_ + 4),_loc2_);
                     var _temp_26:* = int((int(_loc10_ - _loc11_) >>> 12) * 12);
                     si32(int(int(_loc11_ + _temp_26) + 16),_loc2_ + 4);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_arena_run_tree_insert();
                     _loc2_ += 16;
                  }
               }
            }
         }
         else
         {
            if(li8(wdnative_nternal._opt_junk_2E_b) == 1)
            {
               _loc2_ -= 16;
               si32(90,_loc2_ + 4);
               si32(_loc12_,_loc2_);
               si32(_loc10_ & -4096,_loc2_ + 8);
               wdnative.ESP = _loc2_;
               wdnative.Fmemset();
               _loc2_ += 16;
            }
            _loc2_ -= 16;
            si32(1,_loc2_ + 8);
            si32(_loc12_,_loc2_ + 4);
            si32(_loc9_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_arena_run_dalloc();
            _loc2_ += 16;
         }
      }
      else
      {
         _loc11_ = li32(wdnative_nternal._huge);
         _loc9_ = wdnative_nternal._huge + 4;
         while(_loc11_ != _loc9_)
         {
            _loc10_ = li32(_loc11_ + 16);
            if(_loc10_ == _loc12_)
            {
               break;
            }
            _loc7_ = _loc8_ = 1;
            if(uint(_loc10_) <= uint(_loc12_))
            {
               _loc7_ = 0;
            }
            if(uint(_loc10_) >= uint(_loc12_))
            {
               _loc8_ = 0;
            }
            _loc1_ = _loc7_ & 1;
            _loc6_ = _loc8_ & 1;
            _loc1_ = _loc6_ - _loc1_;
            if(_loc1_ <= -1)
            {
               _loc11_ = li32(_loc11_ + 8);
            }
            else
            {
               _loc11_ = li32(_loc11_ + 12) & -2;
            }
         }
         _loc2_ -= 16;
         si32(wdnative_nternal._huge,_loc2_);
         _loc10_ = 0;
         if(_loc11_ != _loc9_)
         {
            _loc10_ = _loc11_;
         }
         si32(_loc10_,_loc2_ + 4);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_extent_tree_ad_remove();
         _loc2_ += 16;
         _loc1_ = li8(wdnative_nternal._opt_junk_2E_b);
         while(true)
         {
            if(_loc1_ == 1)
            {
               if((li8(wdnative_nternal._opt_dss_2E_b) ^ 1) != 0)
               {
                  var _temp_34:* = li32(_loc10_ + 16);
                  var _temp_33:* = li32(_loc10_ + 20);
                  _loc2_ -= 16;
                  si32(_temp_33,_loc2_ + 8);
                  si32(90,_loc2_ + 4);
                  si32(_temp_34,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative.Fmemset();
                  _loc2_ += 16;
                  break;
               }
            }
            break;
         }
         _loc1_ = li32(_loc10_ + 16);
         _loc6_ = li32(_loc10_ + 20);
         _loc2_ -= 16;
         si32(_loc6_,_loc2_ + 4);
         si32(_loc1_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_chunk_dealloc();
         _loc2_ += 16;
         _loc1_ = li32(wdnative_nternal._base_nodes);
         si32(_loc1_,_loc10_);
         si32(_loc10_,wdnative_nternal._base_nodes);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

