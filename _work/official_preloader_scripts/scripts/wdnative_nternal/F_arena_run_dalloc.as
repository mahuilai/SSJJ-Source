package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_run_dalloc() : void
   {
      var _temp_1:* = this;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc13_:int = 0;
      var _loc19_:int = 0;
      var _loc18_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc4_:int = 0;
      var _loc16_:int = 0;
      var _loc17_:int = 0;
      var _loc15_:int = 0;
      var _loc9_:int = 0;
      var _loc20_:int = 0;
      var _loc14_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc8_ = _loc3_;
      _loc3_ -= 32;
      _loc4_ = li32(wdnative_nternal._chunksize_mask);
      _loc4_ = _loc4_ ^ -1;
      _loc20_ = li32(_loc8_ + 4);
      _loc19_ = _loc20_ & _loc4_;
      _loc18_ = _loc20_ - _loc19_;
      _loc17_ = _loc18_ >>> 12;
      _loc16_ = _loc17_ * 12;
      _loc15_ = _loc19_ + _loc16_;
      _loc14_ = li32(_loc15_ + 24);
      _loc4_ = _loc14_ & 2;
      _loc13_ = li32(_loc8_ + 8);
      _loc1_ = li32(_loc8_);
      if(_loc4_ != 0)
      {
         _loc14_ &= -4096;
      }
      else
      {
         _loc4_ = li32(_loc20_);
         _loc14_ = li32(_loc4_ + 24);
      }
      _loc20_ = _loc14_ >>> 12;
      if(_loc13_ == 0)
      {
         if(_loc20_ != 0)
         {
            _loc4_ = _loc18_ >>> 12;
            _loc4_ = _loc4_ * 12;
            _loc4_ = _loc4_ + _loc19_;
            _loc18_ = _loc4_ + 24;
            _loc13_ = _loc14_ >>> 12;
            do
            {
               _loc4_ = li32(_loc18_);
               _loc4_ = _loc4_ & -4;
               si32(_loc4_,_loc18_);
               _loc18_ += 12;
            }
            while(_loc13_ += -1, _loc13_ != 0);
         }
      }
      else
      {
         if(_loc20_ != 0)
         {
            _loc4_ = _loc18_ >>> 12;
            _loc4_ = _loc4_ * 12;
            _loc4_ = _loc4_ + _loc19_;
            _loc18_ = _loc4_ + 24;
            _loc13_ = _loc20_;
            do
            {
               si32(8,_loc18_);
               _loc18_ += 12;
            }
            while(_loc13_ += -1, _loc13_ != 0);
         }
         _loc18_ = li32(_loc19_ + 12);
         if(_loc18_ == 0)
         {
            _loc9_ = li32(_loc1_ + 4);
            _loc10_ = _loc8_ - 32;
            var _temp_21:* = _loc10_ | 4;
            si32(_loc9_,_temp_21);
            _loc18_ = _loc1_ + 8;
            _loc4_ = _loc18_ & -2;
            si32(_loc4_,_loc8_ - 24);
            _loc11_ = 0;
            _loc13_ = _loc18_;
            loop2:
            while(true)
            {
               _loc12_ = _loc9_;
               _loc5_ = _loc10_;
               while(true)
               {
                  if(_loc18_ == _loc12_)
                  {
                     break loop2;
                  }
                  _loc11_ = li32(_loc12_ + 4);
                  _loc10_ = li32(_loc11_ + 8);
                  _loc4_ = _loc10_ & 1;
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc4_ = li32(_loc11_ + 4);
                  _loc4_ = li8(_loc4_ + 8);
                  _loc4_ = _loc4_ & 1;
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc4_ = _loc10_ & -2;
                  si32(_loc4_,_loc12_ + 4);
                  _loc4_ = li32(_loc11_ + 8);
                  _loc4_ = _loc4_ & 1;
                  _loc4_ = _loc4_ | _loc12_;
                  si32(_loc4_,_loc11_ + 8);
                  _loc4_ = li32(_loc11_ + 4);
                  si32(li32(_loc4_ + 8) & -2,_loc4_ + 8);
                  _loc4_ = li32(_loc5_ + 4);
                  if(_loc4_ == _loc12_)
                  {
                     si32(_loc11_,_loc5_ + 4);
                     _loc12_ = _loc11_;
                     break;
                  }
                  _loc4_ = li32(_loc5_ + 8);
                  _loc4_ = _loc4_ & 1;
                  _loc4_ = _loc4_ | _loc11_;
                  si32(_loc4_,_loc5_ + 8);
                  _loc4_ = _loc4_ & 1 | li32((_loc10_ = _loc11_ & -2) + 4);
                  si32(_loc4_,_loc5_ + 8);
                  si32(_loc5_,_loc10_ + 4);
                  _loc4_ = li32(_loc5_ + 8);
                  var _temp_42:* = _loc4_ & 1;
                  _loc4_ = li32(_loc10_ + 8) & -2 | _temp_42;
                  si32(_loc4_,_loc10_ + 8);
                  _loc4_ = li32(_loc5_ + 8);
                  _loc4_ = _loc4_ | 1;
                  si32(_loc4_,_loc5_ + 8);
                  _loc4_ = li32(_loc13_ + 4);
                  if(_loc4_ == _loc5_)
                  {
                     si32(_loc10_,_loc13_ + 4);
                  }
                  else
                  {
                     _loc4_ = li32(_loc13_ + 8);
                     _loc4_ = _loc4_ & 1;
                     _loc4_ = _loc4_ | _loc10_;
                     si32(_loc4_,_loc13_ + 8);
                  }
                  _loc12_ = _loc5_ = 1;
                  if(uint(_loc10_) <= uint(_loc19_))
                  {
                     _loc12_ = 0;
                  }
                  if(uint(_loc10_) >= uint(_loc19_))
                  {
                     _loc5_ = 0;
                  }
                  var _loc2_:int = _loc12_ & 1;
                  _loc4_ = _loc5_ & 1;
                  _loc11_ = _loc4_ - _loc2_;
                  if(_loc11_ <= -1)
                  {
                     _loc12_ = li32(_loc10_ + 4);
                     _loc5_ = _loc10_;
                  }
                  else
                  {
                     _loc4_ = li32(_loc10_ + 8);
                     _loc12_ = _loc4_ & -2;
                     _loc5_ = _loc10_;
                  }
               }
               _loc13_ = _loc11_ = 1;
               if(uint(_loc12_) <= uint(_loc19_))
               {
                  _loc13_ = 0;
               }
               if(uint(_loc12_) >= uint(_loc19_))
               {
                  _loc11_ = 0;
               }
               _loc2_ = _loc13_ & 1;
               _loc4_ = _loc11_ & 1;
               _loc11_ = _loc4_ - _loc2_;
               if(_loc11_ <= -1)
               {
                  _loc9_ = li32(_loc12_ + 4);
                  _loc10_ = _loc12_;
                  _loc13_ = _loc5_;
               }
               else
               {
                  _loc4_ = li32(_loc12_ + 8);
                  _loc9_ = _loc4_ & -2;
                  _loc10_ = _loc12_;
                  _loc13_ = _loc5_;
               }
            }
            si32(_loc18_,_loc19_ + 4);
            _loc4_ = _loc18_ | 1;
            si32(_loc4_,_loc19_ + 8);
            if(_loc11_ >= 1)
            {
               _loc4_ = li32(_loc5_ + 8);
               _loc4_ = _loc4_ & 1;
               _loc4_ = _loc4_ | _loc19_;
               si32(_loc4_,_loc5_ + 8);
               _loc4_ = _loc4_ & 1 | li32((_loc18_ = _loc19_ & -2) + 4);
               si32(_loc4_,_loc5_ + 8);
               si32(_loc5_,_loc18_ + 4);
               _loc4_ = li32(_loc5_ + 8);
               var _temp_63:* = _loc4_ & 1;
               _loc4_ = li32(_loc18_ + 8) & -2 | _temp_63;
               si32(_loc4_,_loc18_ + 8);
               _loc4_ = li32(_loc5_ + 8);
               _loc4_ = _loc4_ | 1;
               si32(_loc4_,_loc5_ + 8);
               _loc4_ = li32(_loc13_ + 4);
               if(_loc4_ == _loc5_)
               {
                  si32(_loc18_,_loc13_ + 4);
               }
               else
               {
                  _loc12_ = li32(_loc13_ + 8);
                  _loc4_ = _loc12_ & -2;
                  if(_loc4_ == _loc5_)
                  {
                     _loc4_ = _loc12_ & 1;
                     _loc4_ = _loc4_ | _loc18_;
                     si32(_loc4_,_loc13_ + 8);
                  }
               }
            }
            else
            {
               si32(_loc19_,_loc5_ + 4);
            }
            _loc4_ = _loc8_ - 32;
            _loc4_ = _loc4_ | 4;
            _loc4_ = li32(_loc4_);
            si32(_loc4_,_loc1_ + 4);
            _loc2_ = li32(_loc4_ + 8);
            _loc2_ &= -2;
            si32(_loc2_,_loc4_ + 8);
            _loc18_ = li32(_loc19_ + 12);
         }
         _loc4_ = _loc18_ + _loc20_;
         si32(_loc4_,_loc19_ + 12);
         _loc4_ = li32(_loc1_ + 40);
         _loc4_ = _loc4_ + _loc20_;
         si32(_loc4_,_loc1_ + 40);
      }
      _loc4_ = li32(_loc15_ + 24);
      _loc4_ = _loc4_ & 0x0FFF;
      _loc4_ = _loc4_ | _loc14_;
      si32(_loc4_,_loc15_ + 24);
      _loc4_ = _loc20_ + _loc17_;
      _loc18_ = _loc4_ * 12;
      _loc2_ = _loc18_ + _loc19_;
      var _loc6_:int = li32(_loc2_ + 12);
      _loc6_ = _loc6_ & 0x0FFF;
      _loc6_ = _loc6_ | _loc14_;
      si32(_loc6_,_loc2_ + 12);
      _loc2_ = li32(wdnative_nternal._chunk_npages);
      if(uint(_loc4_) < uint(_loc2_))
      {
         _loc4_ = _loc19_ + _loc18_;
         _loc20_ = li32(_loc4_ + 24);
         _loc4_ = _loc20_ & 1;
         if(_loc4_ == 0)
         {
            _loc3_ -= 16;
            _loc4_ = _loc1_ + 44;
            si32(_loc4_,_loc3_);
            _loc4_ = _loc19_ + 16;
            si32(int(_loc4_ + _loc18_),_loc3_ + 4);
            _loc14_ = (_loc20_ & -4096) + _loc14_;
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_arena_avail_tree_remove();
            _loc3_ += 16;
            si32(li32(_loc15_ + 24) & 0x0FFF | _loc14_,_loc15_ + 24);
            var _temp_92:* = _loc14_ >>> 12;
            _loc4_ = int((int(_loc17_ + _temp_92)) * 12) + _loc4_;
            si32(li32(_loc4_ - 4) & 0x0FFF | _loc14_,_loc4_ - 4);
         }
      }
      _loc4_ = li32(wdnative_nternal._arena_chunk_header_npages);
      if(uint(_loc17_) > uint(_loc4_))
      {
         _loc4_ = _loc16_ + _loc19_;
         _loc16_ = li32(_loc4_ + 12);
         _loc4_ = _loc16_ & 1;
         if(_loc4_ == 0)
         {
            _loc3_ -= 16;
            _loc4_ = _loc1_ + 44;
            si32(_loc4_,_loc3_);
            var _temp_98:* = _loc16_ >>> 12;
            _loc17_ -= _temp_98;
            var _temp_100:* = int(_loc17_ * 12);
            _loc2_ = _loc19_ + 16;
            _loc6_ = _loc2_ + _temp_100;
            si32(_loc6_,_loc3_ + 4);
            _loc4_ = _loc16_ & -4096;
            _loc4_ = _loc4_ + _loc14_;
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_arena_avail_tree_remove();
            _loc3_ += 16;
            var _loc7_:int = li32(_loc6_ + 8);
            _loc7_ = _loc7_ & 0x0FFF;
            _loc7_ = _loc7_ | _loc4_;
            si32(_loc7_,_loc6_ + 8);
            var _temp_107:* = _loc4_ >>> 12;
            _loc6_ = _loc17_ + _temp_107;
            _loc6_ = _loc6_ * 12;
            _loc2_ = _loc6_ + _loc2_;
            _loc6_ = li32(_loc2_ - 4);
            _loc6_ = _loc6_ & 0x0FFF;
            _loc4_ = _loc6_ | _loc4_;
            si32(_loc4_,_loc2_ - 4);
         }
      }
      _loc3_ -= 16;
      _loc16_ = _loc1_ + 44;
      si32(_loc16_,_loc3_);
      _loc2_ = _loc17_ * 12;
      _loc4_ = _loc19_ + 16;
      _loc2_ = _loc4_ + _loc2_;
      si32(_loc2_,_loc3_ + 4);
      wdnative.ESP = _loc3_;
      wdnative_nternal.F_arena_avail_tree_insert();
      _loc3_ += 16;
      _loc17_ = li32(wdnative_nternal._arena_chunk_header_npages);
      _loc2_ = _loc17_ * 12;
      _loc4_ += _loc2_;
      _loc4_ = li32(_loc4_ + 8);
      _loc4_ = _loc4_ & -4095;
      _loc2_ = li32(wdnative_nternal._arena_maxclass);
      if(_loc4_ == _loc2_)
      {
         _loc15_ = li32(_loc1_ + 36);
         if(_loc15_ != 0)
         {
            _loc4_ = li32(_loc15_ + 12);
            if(_loc4_ != 0)
            {
               var _temp_121:* = li32(_loc19_);
               _loc3_ -= 16;
               si32(_loc15_,_loc3_ + 4);
               _loc4_ = _temp_121 + 4;
               si32(_loc4_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_arena_chunk_tree_dirty_remove();
               _loc3_ += 16;
               _loc4_ = li32(_loc1_ + 40) - li32((_loc15_ = li32(_loc1_ + 36)) + 12);
               si32(_loc4_,_loc1_ + 40);
            }
            _loc4_ = li32(wdnative_nternal._chunksize);
            _loc3_ -= 16;
            si32(_loc4_,_loc3_ + 4);
            si32(_loc15_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_chunk_dealloc();
            _loc3_ += 16;
            _loc17_ = li32(wdnative_nternal._arena_chunk_header_npages);
         }
         _loc3_ -= 16;
         si32(_loc16_,_loc3_);
         _loc4_ = _loc17_ * 12;
         _loc4_ = _loc19_ + _loc4_;
         _loc4_ = _loc4_ + 16;
         si32(_loc4_,_loc3_ + 4);
         wdnative.ESP = _loc3_;
         wdnative_nternal.F_arena_avail_tree_remove();
         _loc3_ += 16;
         si32(_loc19_,_loc1_ + 36);
      }
      _loc17_ = li32(wdnative_nternal._opt_dirty_max);
      _loc19_ = li32(_loc1_ + 40);
      if((uint(_loc19_)) > uint(_loc17_))
      {
         var _temp_131:* = _loc17_ >>> 1;
         if(uint(_loc19_) > uint(_temp_131))
         {
            _loc19_ = _loc1_ + 8;
            _loc17_ = _loc1_ + 4;
            loop4:
            do
            {
               _loc16_ = li32(_loc1_ + 4);
               while(true)
               {
                  _loc15_ = _loc16_;
                  _loc4_ = li32(_loc15_ + 8);
                  _loc16_ = _loc4_ & -2;
                  if(_loc16_ == _loc19_)
                  {
                     break;
                  }
               }
               _loc16_ = 0;
               if(_loc19_ != _loc15_)
               {
                  _loc16_ = _loc15_;
               }
               _loc15_ = li32(wdnative_nternal._chunk_npages);
               while(true)
               {
                  _loc20_ = _loc15_;
                  _loc4_ = li32(_loc16_ + 12);
                  if(_loc4_ == 0)
                  {
                     break;
                  }
                  _loc15_ = _loc20_ + -1;
                  var _temp_136:* = int(_loc20_ * 12);
                  _loc14_ = _loc16_ + _temp_136;
                  _loc18_ = li32(_loc14_ + 12);
                  _loc4_ = _loc18_ & 8;
                  if(_loc4_ != 0)
                  {
                     _loc4_ = _loc18_ ^ 8;
                     si32(_loc4_,_loc14_ + 12);
                     _loc15_ = _loc20_ + -1;
                     _loc18_ = -1;
                     while(true)
                     {
                        _loc4_ = li32(wdnative_nternal._arena_chunk_header_npages);
                        if(uint(_loc15_) <= uint(_loc4_))
                        {
                           break;
                        }
                        _loc4_ = _loc15_ * 3;
                        var _temp_148:* = _loc4_ << 2;
                        _loc14_ = _loc16_ + _temp_148;
                        _loc20_ = li32(_loc14_ + 12);
                        _loc4_ = _loc20_ & 8;
                        if(_loc4_ == 0)
                        {
                           break;
                        }
                        _loc4_ = _loc20_ ^ 8;
                        si32(_loc4_,_loc14_ + 12);
                        _loc18_ += -1;
                        _loc15_ += -1;
                     }
                     _loc4_ = li32(_loc16_ + 12);
                     _loc4_ = _loc4_ + _loc18_;
                     si32(_loc4_,_loc16_ + 12);
                     _loc4_ = li32(_loc1_ + 40);
                     _loc14_ = _loc4_ + _loc18_;
                     si32(_loc14_,_loc1_ + 40);
                     _loc20_ = li32(wdnative_nternal._opt_dirty_max);
                     _loc4_ = _loc20_ >>> 1;
                     if(uint(_loc14_) > uint(_loc4_))
                     {
                        continue;
                     }
                     _loc4_ = li32(_loc16_ + 12);
                     if(_loc4_ == 0)
                     {
                        break;
                     }
                     continue loop4;
                  }
               }
               _loc3_ -= 16;
               si32(_loc16_,_loc3_ + 4);
               si32(_loc17_,_loc3_);
               wdnative.ESP = _loc3_;
               wdnative_nternal.F_arena_chunk_tree_dirty_remove();
               _loc3_ += 16;
               _loc14_ = li32(_loc1_ + 40);
               _loc20_ = li32(wdnative_nternal._opt_dirty_max);
            }
            while(_loc4_ = _loc20_ >>> 1, uint(_loc14_) > uint(_loc4_));
         }
      }
      _loc3_ = _loc8_;
      wdnative.ESP = _loc3_;
   }
}

