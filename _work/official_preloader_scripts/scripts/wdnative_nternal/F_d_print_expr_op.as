package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   
   public function F_d_print_expr_op() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc6_:int = 0;
      var _loc12_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc12_ = li32(_loc1_);
      _loc11_ = li32(_loc3_);
      if(_loc12_ == 40)
      {
         _loc10_ = li32(_loc11_ + 4);
         if(_loc10_ != 0)
         {
            _loc9_ = li32(_loc11_ + 8);
            _loc8_ = li32(_loc1_ + 4);
            _loc7_ = li32(_loc8_ + 8);
            _loc6_ = _loc7_ + _loc9_;
            _loc5_ = li32(_loc11_ + 12);
            if(uint(_loc6_) <= uint(_loc5_))
            {
               var _temp_5:* = li32(_loc8_ + 4);
               _loc2_ -= 16;
               si32(_loc7_,_loc2_ + 8);
               si32(_temp_5,_loc2_ + 4);
               _loc12_ = _loc10_ + _loc9_;
               si32(_loc12_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative.Fmemcpy();
               _loc2_ += 16;
               var _temp_10:* = li32(_loc11_ + 8);
               var _loc4_:int;
               _loc12_ = (_loc4_ = li32((_loc4_ = li32(_loc1_ + 4)) + 8)) + _temp_10;
               si32(_loc12_,_loc11_ + 8);
            }
            else
            {
               _loc1_ = li32(_loc8_ + 4);
               while(true)
               {
                  if(uint(_loc5_) >= uint(_loc6_))
                  {
                     if(_loc10_ != 0)
                     {
                        var _temp_12:* = li32(_loc11_ + 8);
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_ + 4);
                        _loc12_ = _loc10_ + _temp_12;
                        si32(_loc12_,_loc2_);
                        si32(_loc7_,_loc2_ + 8);
                        wdnative.ESP = _loc2_;
                        wdnative.Fmemcpy();
                        _loc2_ += 16;
                        _loc12_ = li32(_loc11_ + 8);
                        _loc12_ = _loc12_ + _loc7_;
                        si32(_loc12_,_loc11_ + 8);
                     }
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc10_,_loc2_);
                  _loc5_ <<= 1;
                  si32(_loc5_,_loc2_ + 4);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_realloc();
                  _loc2_ += 16;
                  _loc10_ = wdnative.eax;
                  if(_loc10_ == 0)
                  {
                     _loc5_ = li32(_loc11_ + 4);
                     if(_loc5_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(_loc5_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_idalloc();
                        _loc2_ += 16;
                     }
                     si32(0,_loc11_ + 4);
                     si32(1,_loc11_ + 24);
                     break;
                  }
                  si32(_loc10_,_loc11_ + 4);
                  si32(_loc5_,_loc11_ + 12);
               }
            }
         }
      }
      else
      {
         _loc2_ -= 16;
         si32(_loc1_,_loc2_ + 4);
         si32(_loc11_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

