package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_arena_run_alloc() : void
   {
      var _temp_1:* = this;
      var _loc4_:int = 0;
      var _loc15_:int = 0;
      var _loc3_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc13_:int = 0;
      var _loc5_:int = 0;
      var _loc12_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc16_:int = 0;
      var _loc14_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc4_ = _loc2_;
      _loc3_ = li32(_loc4_ + 4);
      _loc16_ = _loc3_ & -4096;
      _loc15_ = li32(_loc4_);
      _loc14_ = _loc15_ + 48;
      _loc13_ = _loc15_ + 44;
      _loc12_ = 0;
      _loc11_ = li32(_loc4_ + 12);
      _loc10_ = li32(_loc4_ + 8);
      _loc9_ = _loc13_;
      loop0:
      while(true)
      {
         _loc9_ = li32(_loc9_);
         while(true)
         {
            _loc5_ = _loc12_;
            if(_loc14_ == _loc9_)
            {
               break loop0;
            }
            _loc5_ = li32(_loc9_ + 8) & -4096;
            _loc7_ = _loc6_ = 1;
            if(uint(_loc16_) >= uint(_loc5_))
            {
               _loc7_ = 0;
            }
            if(uint(_loc16_) <= uint(_loc5_))
            {
               _loc6_ = 0;
            }
            var _loc8_:int = _loc7_ & 1;
            var _loc1_:int = _loc6_ & 1;
            _loc7_ = _loc1_ - _loc8_;
            if(_loc16_ == _loc5_)
            {
               _loc7_ = -1;
               if(_loc9_ == 0)
               {
                  _loc7_ = 0;
               }
            }
            if(_loc7_ <= -1)
            {
               break;
            }
            _loc5_ = _loc9_;
            if(_loc7_ < 1)
            {
               break loop0;
            }
            _loc9_ = li32(_loc9_ + 4) & -2;
         }
         _loc12_ = _loc9_;
      }
      if(_loc5_ != 0)
      {
         var _temp_4:* = li32(wdnative_nternal._chunksize_mask);
         _loc2_ -= 32;
         si32(_loc11_,_loc2_ + 16);
         si32(_loc10_,_loc2_ + 12);
         si32(_loc3_,_loc2_ + 8);
         si32(_loc15_,_loc2_);
         var _temp_5:* = _temp_4 ^ -1;
         _loc1_ = _loc5_ & _temp_5;
         var _temp_6:* = int(_loc1_ + 16);
         _loc8_ = _loc5_ - _temp_6;
         _loc8_ = (uint(_loc8_)) / 12;
         _loc8_ = _loc8_ << 12;
         _loc16_ = _loc8_ + _loc1_;
         si32(_loc16_,_loc2_ + 4);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_arena_run_split();
         _loc2_ += 32;
      }
      else
      {
         _loc9_ = li32(_loc15_ + 36);
         if(_loc9_ != 0)
         {
            si32(0,_loc15_ + 36);
            addr02d1:
            _loc1_ = li32(wdnative_nternal._arena_chunk_header_npages);
            _loc2_ -= 16;
            si32(_loc13_,_loc2_);
            _loc1_ *= 12;
            _loc1_ = _loc9_ + _loc1_;
            _loc1_ += 16;
            si32(_loc1_,_loc2_ + 4);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_arena_avail_tree_insert();
            _loc2_ += 16;
            _loc16_ = 0;
            if(_loc9_ != 0)
            {
               var _temp_14:* = li32(wdnative_nternal._arena_chunk_header_npages);
               _loc2_ -= 32;
               si32(_loc11_,_loc2_ + 16);
               si32(_loc10_,_loc2_ + 12);
               si32(_loc3_,_loc2_ + 8);
               si32(_loc15_,_loc2_);
               _loc16_ = (_temp_14 << 12) + _loc9_;
               si32(_loc16_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_arena_run_split();
               _loc2_ += 32;
            }
         }
         else
         {
            var _temp_17:* = li32(wdnative_nternal._chunksize);
            _loc2_ -= 16;
            si32(1,_loc2_ + 4);
            si32(_temp_17,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_chunk_alloc();
            _loc16_ = 0;
            _loc2_ += 16;
            _loc9_ = wdnative.eax;
            if(_loc9_ != 0)
            {
               si32(_loc15_,_loc9_);
               _loc16_ = 0;
               si32(_loc16_,_loc9_ + 12);
               if(li32(wdnative_nternal._arena_chunk_header_npages) != 0)
               {
                  _loc16_ = 0;
                  do
                  {
                     _loc1_ = _loc16_ * 3;
                     _loc1_ <<= 2;
                     _loc1_ = _loc9_ + _loc1_;
                     si32(0,_loc1_ + 24);
                     _loc16_ += 1;
                     _loc1_ = li32(wdnative_nternal._arena_chunk_header_npages);
                  }
                  while(uint(_loc16_) < uint(_loc1_));
               }
               _loc12_ = _loc16_ * 12;
               _loc1_ = _loc9_ + _loc12_;
               _loc8_ = li32(wdnative_nternal._arena_maxclass);
               _loc8_ = _loc8_ | 4;
               si32(_loc8_,_loc1_ + 24);
               _loc14_ = _loc16_ + 1;
               _loc1_ = li32(wdnative_nternal._chunk_npages);
               _loc16_ = _loc1_ + -1;
               if((uint(_loc16_)) > uint(_loc14_))
               {
                  _loc12_ = int(_loc12_ + _loc9_) + 36;
                  do
                  {
                     si32(4,_loc12_);
                     _loc14_ += 1;
                     _loc12_ += 12;
                     _loc1_ = li32(wdnative_nternal._chunk_npages);
                  }
                  while(_loc16_ = _loc1_ + -1, (uint(_loc16_)) > uint(_loc14_));
               }
               _loc1_ = _loc16_ * 12;
               _loc1_ = _loc9_ + _loc1_;
               _loc8_ = li32(wdnative_nternal._arena_maxclass);
               _loc8_ = _loc8_ | 4;
               si32(_loc8_,_loc1_ + 24);
               §§goto(addr02d1);
            }
         }
      }
      wdnative.eax = _loc16_;
      _loc2_ = _loc4_;
      wdnative.ESP = _loc2_;
   }
}

