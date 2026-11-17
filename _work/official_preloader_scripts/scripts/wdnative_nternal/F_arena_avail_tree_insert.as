package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_avail_tree_insert() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc4_:int = 0;
      var _loc9_:int = 0;
      var _loc5_:int = 0;
      var _loc13_:int = 0;
      var _loc7_:int = 0;
      var _loc14_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc14_ = li32(_loc1_);
      si32(_loc14_,_loc3_ - 16);
      _loc13_ = _loc3_ - 16;
      _loc12_ = _loc13_ | 4;
      _loc11_ = _loc1_ + 4;
      var _loc10_:int = _loc11_ & -2;
      si32(_loc10_,_loc12_);
      _loc9_ = 0;
      _loc8_ = li32(_loc3_ + 4);
      _loc7_ = _loc11_;
      loop0:
      while(true)
      {
         _loc6_ = _loc14_;
         _loc4_ = _loc13_;
         while(true)
         {
            if(_loc11_ == _loc6_)
            {
               break loop0;
            }
            _loc9_ = li32(_loc6_);
            _loc13_ = li32(_loc9_ + 4);
            _loc10_ = _loc13_ & 1;
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = li32(_loc9_);
            _loc10_ = li8(_loc10_ + 4);
            _loc10_ = _loc10_ & 1;
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = _loc13_ & -2;
            si32(_loc10_,_loc6_);
            _loc10_ = li32(_loc9_ + 4);
            _loc10_ = _loc10_ & 1;
            _loc10_ = _loc10_ | _loc6_;
            si32(_loc10_,_loc9_ + 4);
            _loc10_ = li32(_loc9_);
            _loc12_ = li32(_loc10_ + 4);
            _loc12_ = _loc12_ & -2;
            si32(_loc12_,_loc10_ + 4);
            _loc10_ = li32(_loc4_);
            if(_loc10_ == _loc6_)
            {
               si32(_loc9_,_loc4_);
               _loc6_ = _loc9_;
               break;
            }
            _loc10_ = li32(_loc4_ + 4);
            _loc10_ = _loc10_ & 1;
            _loc10_ = _loc10_ | _loc9_;
            si32(_loc10_,_loc4_ + 4);
            _loc10_ = _loc10_ & 1 | li32(_loc13_ = _loc9_ & -2);
            si32(_loc10_,_loc4_ + 4);
            si32(_loc4_,_loc13_);
            _loc10_ = li32(_loc4_ + 4);
            var _temp_28:* = _loc10_ & 1;
            _loc10_ = (_loc12_ = (_loc12_ = li32(_loc13_ + 4)) & -2) | _temp_28;
            si32(_loc10_,_loc13_ + 4);
            _loc10_ = li32(_loc4_ + 4);
            _loc10_ = _loc10_ | 1;
            si32(_loc10_,_loc4_ + 4);
            _loc10_ = li32(_loc7_);
            if(_loc10_ == _loc4_)
            {
               si32(_loc13_,_loc7_);
            }
            else
            {
               _loc10_ = li32(_loc7_ + 4);
               _loc10_ = _loc10_ & 1;
               _loc10_ = _loc10_ | _loc13_;
               si32(_loc10_,_loc7_ + 4);
            }
            _loc10_ = li32(_loc13_ + 8);
            _loc6_ = _loc10_ & -4096;
            _loc14_ = li32(_loc8_ + 8);
            _loc4_ = _loc14_ & -4096;
            _loc5_ = _loc9_ = 1;
            if(uint(_loc4_) >= uint(_loc6_))
            {
               _loc5_ = 0;
            }
            if(uint(_loc4_) <= uint(_loc6_))
            {
               _loc9_ = 0;
            }
            _loc10_ = _loc5_ & 1;
            _loc12_ = _loc9_ & 1;
            _loc9_ = _loc12_ - _loc10_;
            if(_loc4_ == _loc6_)
            {
               var _temp_39:* = _loc14_ & 0x10;
               _loc4_ = _loc8_;
               if(_temp_39 != 0)
               {
                  _loc4_ = 0;
               }
               _loc6_ = _loc9_ = 1;
               if(uint(_loc4_) >= uint(_loc13_))
               {
                  _loc6_ = 0;
               }
               if(uint(_loc4_) <= uint(_loc13_))
               {
                  _loc9_ = 0;
               }
               _loc12_ = _loc6_ & 1;
               _loc10_ = _loc9_ & 1;
               _loc9_ = _loc10_ - _loc12_;
            }
            if(_loc9_ <= -1)
            {
               _loc6_ = li32(_loc13_);
               _loc4_ = _loc13_;
            }
            else
            {
               _loc10_ = li32(_loc13_ + 4);
               _loc6_ = _loc10_ & -2;
               _loc4_ = _loc13_;
            }
         }
         _loc10_ = li32(_loc6_ + 8);
         _loc7_ = _loc10_ & -4096;
         _loc14_ = li32(_loc8_ + 8);
         _loc13_ = _loc14_ & -4096;
         _loc9_ = _loc5_ = 1;
         if(uint(_loc13_) >= uint(_loc7_))
         {
            _loc9_ = 0;
         }
         if(uint(_loc13_) <= uint(_loc7_))
         {
            _loc5_ = 0;
         }
         _loc10_ = _loc9_ & 1;
         _loc12_ = _loc5_ & 1;
         _loc9_ = _loc12_ - _loc10_;
         if(_loc13_ == _loc7_)
         {
            var _temp_45:* = _loc14_ & 0x10;
            _loc9_ = _loc8_;
            if(_temp_45 != 0)
            {
               _loc9_ = 0;
            }
            _loc13_ = _loc7_ = 1;
            if(uint(_loc9_) >= uint(_loc6_))
            {
               _loc13_ = 0;
            }
            if(uint(_loc9_) <= uint(_loc6_))
            {
               _loc7_ = 0;
            }
            _loc10_ = _loc13_ & 1;
            _loc12_ = _loc7_ & 1;
            _loc9_ = _loc12_ - _loc10_;
         }
         if(_loc9_ <= -1)
         {
            _loc14_ = li32(_loc6_);
            _loc13_ = _loc6_;
            _loc7_ = _loc4_;
         }
         else
         {
            _loc10_ = li32(_loc6_ + 4);
            _loc14_ = _loc10_ & -2;
            _loc13_ = _loc6_;
            _loc7_ = _loc4_;
         }
      }
      si32(_loc11_,_loc8_);
      _loc10_ = _loc11_ | 1;
      si32(_loc10_,_loc8_ + 4);
      if(_loc9_ >= 1)
      {
         _loc10_ = li32(_loc4_ + 4);
         _loc10_ = _loc10_ & 1;
         _loc10_ = _loc10_ | _loc8_;
         si32(_loc10_,_loc4_ + 4);
         _loc10_ = _loc10_ & 1 | li32(_loc11_ = _loc8_ & -2);
         si32(_loc10_,_loc4_ + 4);
         si32(_loc4_,_loc11_);
         _loc10_ = li32(_loc4_ + 4);
         var _temp_57:* = _loc10_ & 1;
         _loc10_ = (_loc12_ = (_loc12_ = li32(_loc11_ + 4)) & -2) | _temp_57;
         si32(_loc10_,_loc11_ + 4);
         _loc10_ = li32(_loc4_ + 4);
         _loc10_ = _loc10_ | 1;
         si32(_loc10_,_loc4_ + 4);
         _loc10_ = li32(_loc7_);
         if(_loc10_ == _loc4_)
         {
            si32(_loc11_,_loc7_);
         }
         else
         {
            _loc8_ = li32(_loc7_ + 4);
            _loc10_ = _loc8_ & -2;
            if(_loc10_ == _loc4_)
            {
               _loc10_ = _loc8_ & 1;
               _loc10_ = _loc10_ | _loc11_;
               si32(_loc10_,_loc7_ + 4);
            }
         }
      }
      else
      {
         si32(_loc8_,_loc4_);
      }
      _loc10_ = li32(_loc3_ - 16);
      si32(_loc10_,_loc1_);
      _loc12_ = li32(_loc10_ + 4);
      _loc12_ = _loc12_ & -2;
      si32(_loc12_,_loc10_ + 4);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

