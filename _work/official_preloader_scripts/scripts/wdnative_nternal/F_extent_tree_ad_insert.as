package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_extent_tree_ad_insert() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc12_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc13_:int = 0;
      var _loc9_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 24;
      _loc1_ = li32(_loc3_);
      _loc13_ = li32(_loc1_);
      si32(_loc13_,_loc3_ - 16);
      _loc12_ = _loc1_ + 4;
      var _loc11_:int = _loc12_ & -2;
      si32(_loc11_,_loc3_ - 12);
      _loc10_ = 0;
      _loc9_ = _loc3_ - 24;
      _loc8_ = li32(_loc3_ + 4);
      _loc7_ = _loc12_;
      loop0:
      while(true)
      {
         _loc6_ = _loc13_;
         _loc4_ = _loc9_;
         while(true)
         {
            if(_loc12_ == _loc6_)
            {
               break loop0;
            }
            _loc10_ = li32(_loc6_ + 8);
            _loc9_ = li32(_loc10_ + 12);
            _loc11_ = _loc9_ & 1;
            if(_loc11_ == 0)
            {
               break;
            }
            _loc11_ = li32(_loc10_ + 8);
            _loc11_ = li8(_loc11_ + 12);
            _loc11_ = _loc11_ & 1;
            if(_loc11_ == 0)
            {
               break;
            }
            _loc11_ = _loc9_ & -2;
            si32(_loc11_,_loc6_ + 8);
            _loc11_ = li32(_loc10_ + 12);
            _loc11_ = _loc11_ & 1;
            _loc11_ = _loc11_ | _loc6_;
            si32(_loc11_,_loc10_ + 12);
            _loc11_ = li32(_loc10_ + 8);
            var _loc5_:int = li32(_loc11_ + 12);
            _loc5_ = _loc5_ & -2;
            si32(_loc5_,_loc11_ + 12);
            _loc11_ = li32(_loc4_ + 8);
            if(_loc11_ == _loc6_)
            {
               si32(_loc10_,_loc4_ + 8);
               _loc6_ = _loc10_;
               break;
            }
            _loc11_ = li32(_loc4_ + 12);
            _loc11_ = _loc11_ & 1;
            _loc11_ = _loc11_ | _loc10_;
            si32(_loc11_,_loc4_ + 12);
            _loc11_ = _loc11_ & 1 | li32((_loc9_ = _loc10_ & -2) + 8);
            si32(_loc11_,_loc4_ + 12);
            si32(_loc4_,_loc9_ + 8);
            _loc11_ = li32(_loc4_ + 12);
            var _temp_27:* = _loc11_ & 1;
            _loc11_ = (_loc5_ = (_loc5_ = li32(_loc9_ + 12)) & -2) | _temp_27;
            si32(_loc11_,_loc9_ + 12);
            _loc11_ = li32(_loc4_ + 12);
            _loc11_ = _loc11_ | 1;
            si32(_loc11_,_loc4_ + 12);
            _loc11_ = li32(_loc7_ + 8);
            if(_loc11_ == _loc4_)
            {
               si32(_loc9_,_loc7_ + 8);
            }
            else
            {
               _loc11_ = li32(_loc7_ + 12);
               _loc11_ = _loc11_ & 1;
               _loc11_ = _loc11_ | _loc9_;
               si32(_loc11_,_loc7_ + 12);
            }
            _loc4_ = li32(_loc9_ + 16);
            _loc6_ = li32(_loc8_ + 16);
            _loc13_ = _loc10_ = 1;
            if(uint(_loc6_) >= uint(_loc4_))
            {
               _loc13_ = 0;
            }
            if(uint(_loc6_) <= uint(_loc4_))
            {
               _loc10_ = 0;
            }
            _loc5_ = _loc13_ & 1;
            _loc11_ = _loc10_ & 1;
            _loc10_ = _loc11_ - _loc5_;
            if(_loc10_ <= -1)
            {
               _loc6_ = li32(_loc9_ + 8);
               _loc4_ = _loc9_;
            }
            else
            {
               _loc11_ = li32(_loc9_ + 12);
               _loc6_ = _loc11_ & -2;
               _loc4_ = _loc9_;
            }
         }
         _loc10_ = li32(_loc6_ + 16);
         _loc13_ = li32(_loc8_ + 16);
         _loc9_ = _loc7_ = 1;
         if(uint(_loc13_) >= uint(_loc10_))
         {
            _loc9_ = 0;
         }
         if(uint(_loc13_) <= uint(_loc10_))
         {
            _loc7_ = 0;
         }
         _loc5_ = _loc9_ & 1;
         _loc11_ = _loc7_ & 1;
         _loc10_ = _loc11_ - _loc5_;
         if(_loc10_ <= -1)
         {
            _loc13_ = li32(_loc6_ + 8);
            _loc9_ = _loc6_;
            _loc7_ = _loc4_;
         }
         else
         {
            _loc11_ = li32(_loc6_ + 12);
            _loc13_ = _loc11_ & -2;
            _loc9_ = _loc6_;
            _loc7_ = _loc4_;
         }
      }
      si32(_loc12_,_loc8_ + 8);
      _loc11_ = _loc12_ | 1;
      si32(_loc11_,_loc8_ + 12);
      if(_loc10_ >= 1)
      {
         _loc11_ = li32(_loc4_ + 12);
         _loc11_ = _loc11_ & 1;
         _loc11_ = _loc11_ | _loc8_;
         si32(_loc11_,_loc4_ + 12);
         _loc11_ = _loc11_ & 1 | li32((_loc12_ = _loc8_ & -2) + 8);
         si32(_loc11_,_loc4_ + 12);
         si32(_loc4_,_loc12_ + 8);
         _loc11_ = li32(_loc4_ + 12);
         var _temp_50:* = _loc11_ & 1;
         _loc11_ = (_loc5_ = (_loc5_ = li32(_loc12_ + 12)) & -2) | _temp_50;
         si32(_loc11_,_loc12_ + 12);
         _loc11_ = li32(_loc4_ + 12);
         _loc11_ = _loc11_ | 1;
         si32(_loc11_,_loc4_ + 12);
         _loc11_ = li32(_loc7_ + 8);
         if(_loc11_ == _loc4_)
         {
            si32(_loc12_,_loc7_ + 8);
         }
         else
         {
            _loc8_ = li32(_loc7_ + 12);
            _loc11_ = _loc8_ & -2;
            if(_loc11_ == _loc4_)
            {
               _loc11_ = _loc8_ & 1;
               _loc11_ = _loc11_ | _loc12_;
               si32(_loc11_,_loc7_ + 12);
            }
         }
      }
      else
      {
         si32(_loc8_,_loc4_ + 8);
      }
      _loc11_ = li32(_loc3_ - 16);
      si32(_loc11_,_loc1_);
      _loc5_ = li32(_loc11_ + 12);
      _loc5_ = _loc5_ & -2;
      si32(_loc5_,_loc11_ + 12);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

