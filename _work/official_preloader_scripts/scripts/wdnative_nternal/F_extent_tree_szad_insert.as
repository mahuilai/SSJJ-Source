package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_extent_tree_szad_insert() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc6_:int = 0;
      var _loc11_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc9_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 24;
      _loc1_ = li32(wdnative_nternal._dss_chunks_szad);
      si32(_loc1_,_loc3_ - 24);
      _loc11_ = _loc3_ - 24;
      _loc10_ = _loc11_ | 4;
      _loc9_ = wdnative_nternal._dss_chunks_szad + 4;
      var _loc8_:int = _loc9_ & -2;
      si32(_loc8_,_loc10_);
      _loc7_ = 0;
      _loc6_ = li32(_loc3_);
      loop0:
      while(true)
      {
         _loc5_ = _loc1_;
         _loc4_ = _loc11_;
         while(true)
         {
            _loc11_ = wdnative_nternal._dss_chunks_szad + 4;
            if(_loc5_ == _loc11_)
            {
               break loop0;
            }
            _loc11_ = li32(_loc5_);
            _loc7_ = li32(_loc11_ + 4);
            _loc10_ = _loc7_ & 1;
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = li32(_loc11_);
            _loc10_ = li8(_loc10_ + 4);
            _loc10_ = _loc10_ & 1;
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = _loc7_ & -2;
            si32(_loc10_,_loc5_);
            _loc10_ = li32(_loc11_ + 4);
            _loc10_ = _loc10_ & 1;
            _loc10_ = _loc10_ | _loc5_;
            si32(_loc10_,_loc11_ + 4);
            _loc10_ = li32(_loc11_);
            _loc8_ = li32(_loc10_ + 4);
            _loc8_ = _loc8_ & -2;
            si32(_loc8_,_loc10_ + 4);
            _loc10_ = li32(_loc4_);
            if(_loc10_ == _loc5_)
            {
               si32(_loc11_,_loc4_);
               _loc5_ = _loc11_;
               break;
            }
            _loc10_ = li32(_loc4_ + 4);
            _loc10_ = _loc10_ & 1;
            _loc10_ = _loc10_ | _loc11_;
            si32(_loc10_,_loc4_ + 4);
            _loc10_ = _loc10_ & 1 | li32(_loc11_ &= -2);
            si32(_loc10_,_loc4_ + 4);
            si32(_loc4_,_loc11_);
            _loc10_ = li32(_loc4_ + 4);
            var _temp_27:* = _loc10_ & 1;
            _loc10_ = (_loc8_ = (_loc8_ = li32(_loc11_ + 4)) & -2) | _temp_27;
            si32(_loc10_,_loc11_ + 4);
            _loc10_ = li32(_loc4_ + 4);
            _loc10_ = _loc10_ | 1;
            si32(_loc10_,_loc4_ + 4);
            _loc10_ = li32(_loc9_);
            if(_loc10_ == _loc4_)
            {
               si32(_loc11_,_loc9_);
            }
            else
            {
               _loc10_ = li32(_loc9_ + 4);
               _loc10_ = _loc10_ & 1;
               _loc10_ = _loc10_ | _loc11_;
               si32(_loc10_,_loc9_ + 4);
            }
            _loc4_ = li32(_loc11_ + 20);
            _loc5_ = li32(_loc6_ + 20);
            _loc1_ = 1;
            _loc7_ = _loc1_;
            if(uint(_loc5_) >= uint(_loc4_))
            {
               _loc7_ = 0;
            }
            if(uint(_loc5_) <= uint(_loc4_))
            {
               _loc1_ = 0;
            }
            _loc10_ = _loc7_ & 1;
            _loc8_ = _loc1_ & 1;
            _loc7_ = _loc8_ - _loc10_;
            if(_loc5_ == _loc4_)
            {
               _loc4_ = li32(_loc11_ + 16);
               _loc5_ = li32(_loc6_ + 16);
               _loc1_ = 1;
               _loc7_ = _loc1_;
               if(uint(_loc5_) >= uint(_loc4_))
               {
                  _loc7_ = 0;
               }
               if(uint(_loc5_) <= uint(_loc4_))
               {
                  _loc1_ = 0;
               }
               _loc10_ = _loc7_ & 1;
               _loc8_ = _loc1_ & 1;
               _loc7_ = _loc8_ - _loc10_;
            }
            if(_loc7_ <= -1)
            {
               _loc5_ = li32(_loc11_);
               _loc4_ = _loc11_;
            }
            else
            {
               _loc10_ = li32(_loc11_ + 4);
               _loc5_ = _loc10_ & -2;
               _loc4_ = _loc11_;
            }
         }
         _loc9_ = li32(_loc5_ + 20);
         _loc11_ = li32(_loc6_ + 20);
         _loc1_ = 1;
         _loc7_ = _loc1_;
         if(uint(_loc11_) >= uint(_loc9_))
         {
            _loc7_ = 0;
         }
         if(uint(_loc11_) <= uint(_loc9_))
         {
            _loc1_ = 0;
         }
         _loc10_ = _loc7_ & 1;
         _loc8_ = _loc1_ & 1;
         _loc7_ = _loc8_ - _loc10_;
         if(_loc11_ == _loc9_)
         {
            _loc11_ = li32(_loc5_ + 16);
            _loc9_ = li32(_loc6_ + 16);
            _loc1_ = 1;
            _loc7_ = _loc1_;
            if(uint(_loc9_) >= uint(_loc11_))
            {
               _loc7_ = 0;
            }
            if(uint(_loc9_) <= uint(_loc11_))
            {
               _loc1_ = 0;
            }
            _loc10_ = _loc7_ & 1;
            _loc8_ = _loc1_ & 1;
            _loc7_ = _loc8_ - _loc10_;
         }
         if(_loc7_ <= -1)
         {
            _loc1_ = li32(_loc5_);
            _loc11_ = _loc5_;
            _loc9_ = _loc4_;
         }
         else
         {
            _loc10_ = li32(_loc5_ + 4);
            _loc1_ = _loc10_ & -2;
            _loc11_ = _loc5_;
            _loc9_ = _loc4_;
         }
      }
      si32(_loc11_,_loc6_);
      _loc10_ = _loc11_ | 1;
      si32(_loc10_,_loc6_ + 4);
      if(_loc7_ >= 1)
      {
         _loc10_ = li32(_loc4_ + 4);
         _loc10_ = _loc10_ & 1;
         _loc10_ = _loc10_ | _loc6_;
         si32(_loc10_,_loc4_ + 4);
         _loc10_ = _loc10_ & 1 | li32(_loc5_ = _loc6_ & -2);
         si32(_loc10_,_loc4_ + 4);
         si32(_loc4_,_loc5_);
         _loc10_ = li32(_loc4_ + 4);
         var _temp_50:* = _loc10_ & 1;
         _loc10_ = (_loc8_ = (_loc8_ = li32(_loc5_ + 4)) & -2) | _temp_50;
         si32(_loc10_,_loc5_ + 4);
         _loc10_ = li32(_loc4_ + 4);
         _loc10_ = _loc10_ | 1;
         si32(_loc10_,_loc4_ + 4);
         _loc10_ = li32(_loc9_);
         if(_loc10_ == _loc4_)
         {
            si32(_loc5_,_loc9_);
         }
         else
         {
            _loc6_ = li32(_loc9_ + 4);
            _loc10_ = _loc6_ & -2;
            if(_loc10_ == _loc4_)
            {
               _loc10_ = _loc6_ & 1;
               _loc10_ = _loc10_ | _loc5_;
               si32(_loc10_,_loc9_ + 4);
            }
         }
      }
      else
      {
         si32(_loc6_,_loc4_);
      }
      _loc10_ = li32(_loc3_ - 24);
      si32(_loc10_,wdnative_nternal._dss_chunks_szad);
      _loc8_ = li32(_loc10_ + 4);
      _loc8_ = _loc8_ & -2;
      si32(_loc8_,_loc10_ + 4);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

