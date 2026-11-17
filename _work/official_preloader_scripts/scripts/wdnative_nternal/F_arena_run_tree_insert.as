package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   
   public function F_arena_run_tree_insert() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc8_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc13_ = li32(_loc1_);
      si32(_loc13_,_loc3_ - 16);
      _loc12_ = _loc3_ - 16;
      _loc11_ = _loc12_ | 4;
      _loc10_ = _loc1_ + 4;
      var _loc9_:int = _loc10_ & -2;
      si32(_loc9_,_loc11_);
      _loc8_ = 0;
      _loc7_ = li32(_loc3_ + 4);
      _loc6_ = _loc10_;
      loop0:
      while(true)
      {
         _loc5_ = _loc13_;
         _loc4_ = _loc12_;
         while(true)
         {
            if(_loc10_ == _loc5_)
            {
               break loop0;
            }
            _loc12_ = li32(_loc5_);
            _loc8_ = li32(_loc12_ + 4);
            _loc11_ = _loc8_ & 1;
            if(_loc11_ == 0)
            {
               break;
            }
            _loc11_ = li32(_loc12_);
            _loc11_ = li8(_loc11_ + 4);
            _loc11_ = _loc11_ & 1;
            if(_loc11_ == 0)
            {
               break;
            }
            _loc11_ = _loc8_ & -2;
            si32(_loc11_,_loc5_);
            _loc11_ = li32(_loc12_ + 4);
            _loc11_ = _loc11_ & 1;
            _loc11_ = _loc11_ | _loc5_;
            si32(_loc11_,_loc12_ + 4);
            _loc11_ = li32(_loc12_);
            _loc9_ = li32(_loc11_ + 4);
            _loc9_ = _loc9_ & -2;
            si32(_loc9_,_loc11_ + 4);
            _loc11_ = li32(_loc4_);
            if(_loc11_ == _loc5_)
            {
               si32(_loc12_,_loc4_);
               _loc5_ = _loc12_;
               break;
            }
            _loc11_ = li32(_loc4_ + 4);
            _loc11_ = _loc11_ & 1;
            _loc11_ = _loc11_ | _loc12_;
            si32(_loc11_,_loc4_ + 4);
            _loc11_ = _loc11_ & 1 | li32(_loc12_ &= -2);
            si32(_loc11_,_loc4_ + 4);
            si32(_loc4_,_loc12_);
            _loc11_ = li32(_loc4_ + 4);
            var _temp_28:* = _loc11_ & 1;
            _loc11_ = (_loc9_ = (_loc9_ = li32(_loc12_ + 4)) & -2) | _temp_28;
            si32(_loc11_,_loc12_ + 4);
            _loc11_ = li32(_loc4_ + 4);
            _loc11_ = _loc11_ | 1;
            si32(_loc11_,_loc4_ + 4);
            _loc11_ = li32(_loc6_);
            if(_loc11_ == _loc4_)
            {
               si32(_loc12_,_loc6_);
            }
            else
            {
               _loc11_ = li32(_loc6_ + 4);
               _loc11_ = _loc11_ & 1;
               _loc11_ = _loc11_ | _loc12_;
               si32(_loc11_,_loc6_ + 4);
            }
            _loc4_ = _loc5_ = 1;
            if(uint(_loc12_) <= uint(_loc7_))
            {
               _loc4_ = 0;
            }
            if(uint(_loc12_) >= uint(_loc7_))
            {
               _loc5_ = 0;
            }
            _loc9_ = _loc4_ & 1;
            _loc11_ = _loc5_ & 1;
            _loc8_ = _loc11_ - _loc9_;
            if(_loc8_ <= -1)
            {
               _loc5_ = li32(_loc12_);
               _loc4_ = _loc12_;
            }
            else
            {
               _loc11_ = li32(_loc12_ + 4);
               _loc5_ = _loc11_ & -2;
               _loc4_ = _loc12_;
            }
         }
         _loc6_ = _loc8_ = 1;
         if(uint(_loc5_) <= uint(_loc7_))
         {
            _loc6_ = 0;
         }
         if(uint(_loc5_) >= uint(_loc7_))
         {
            _loc8_ = 0;
         }
         _loc9_ = _loc6_ & 1;
         _loc11_ = _loc8_ & 1;
         _loc8_ = _loc11_ - _loc9_;
         if(_loc8_ <= -1)
         {
            _loc13_ = li32(_loc5_);
            _loc12_ = _loc5_;
            _loc6_ = _loc4_;
         }
         else
         {
            _loc11_ = li32(_loc5_ + 4);
            _loc13_ = _loc11_ & -2;
            _loc12_ = _loc5_;
            _loc6_ = _loc4_;
         }
      }
      si32(_loc10_,_loc7_);
      _loc11_ = _loc10_ | 1;
      si32(_loc11_,_loc7_ + 4);
      if(_loc8_ >= 1)
      {
         _loc11_ = li32(_loc4_ + 4);
         _loc11_ = _loc11_ & 1;
         _loc11_ = _loc11_ | _loc7_;
         si32(_loc11_,_loc4_ + 4);
         _loc11_ = _loc11_ & 1 | li32(_loc7_ &= -2);
         si32(_loc11_,_loc4_ + 4);
         si32(_loc4_,_loc7_);
         _loc11_ = li32(_loc4_ + 4);
         var _temp_51:* = _loc11_ & 1;
         _loc11_ = (_loc9_ = (_loc9_ = li32(_loc7_ + 4)) & -2) | _temp_51;
         si32(_loc11_,_loc7_ + 4);
         _loc11_ = li32(_loc4_ + 4);
         _loc11_ = _loc11_ | 1;
         si32(_loc11_,_loc4_ + 4);
         _loc11_ = li32(_loc6_);
         if(_loc11_ == _loc4_)
         {
            si32(_loc7_,_loc6_);
         }
         else
         {
            _loc10_ = li32(_loc6_ + 4);
            _loc11_ = _loc10_ & -2;
            if(_loc11_ == _loc4_)
            {
               _loc11_ = _loc10_ & 1;
               _loc11_ = _loc11_ | _loc7_;
               si32(_loc11_,_loc6_ + 4);
            }
         }
      }
      else
      {
         si32(_loc7_,_loc4_);
      }
      _loc11_ = li32(_loc3_ - 16);
      si32(_loc11_,_loc1_);
      _loc9_ = li32(_loc11_ + 4);
      _loc9_ = _loc9_ & -2;
      si32(_loc9_,_loc11_ + 4);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

