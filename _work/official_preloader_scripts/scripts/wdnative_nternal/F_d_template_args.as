package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_template_args() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc9_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_);
      _loc9_ = li32(_loc1_ + 44);
      _loc8_ = li32(_loc1_ + 12);
      _loc7_ = li8(_loc8_);
      _loc6_ = _loc8_ + 1;
      si32(_loc6_,_loc1_ + 12);
      _loc5_ = 0;
      if(_loc7_ == 73)
      {
         si32(0,_loc3_ - 4);
         _loc5_ = li8(_loc6_);
         _loc4_ = _loc3_ - 4;
         while(true)
         {
            _loc8_ = _loc5_ & 0xFF;
            if(_loc8_ != 76)
            {
               _loc8_ = _loc5_ << 24;
               _loc8_ = _loc8_ >> 24;
               if(_loc8_ == 88)
               {
                  _loc8_ = _loc6_ + 1;
                  si32(_loc8_,_loc1_ + 12);
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_expression();
                  _loc2_ += 16;
                  _loc6_ = wdnative.eax;
                  _loc7_ = li32(_loc1_ + 12);
                  var _temp_14:* = li8(_loc7_);
                  si32(_loc7_ += 1,_loc1_ + 12);
                  if(_temp_14 != 69)
                  {
                     _loc6_ = 0;
                  }
               }
               else
               {
                  _loc2_ -= 16;
                  si32(_loc1_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_type();
                  _loc2_ += 16;
                  _loc6_ = wdnative.eax;
               }
            }
            else
            {
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_d_expr_primary();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
            }
            _loc5_ = 0;
            if(_loc6_ != 0)
            {
               _loc5_ = li32(_loc1_ + 20);
               var _temp_17:* = li32(_loc1_ + 24);
               if(_loc5_ < _temp_17)
               {
                  var _temp_19:* = li32(_loc1_ + 16);
                  si32(_loc7_ = _loc5_ + 1,_loc1_ + 20);
                  _loc5_ = _temp_19 + int(_loc5_ * 12);
                  if(_loc5_ != 0)
                  {
                     si32(39,_loc5_);
                     si32(_loc6_,_loc5_ + 4);
                     si32(0,_loc5_ + 8);
                     si32(_loc5_,_loc4_);
                     _loc4_ = _loc5_ + 8;
                     _loc6_ = li32(_loc1_ + 12);
                     _loc5_ = li8(_loc6_);
                     if(_loc5_ == 69)
                     {
                        _loc8_ = _loc6_ + 1;
                        si32(_loc8_,_loc1_ + 12);
                        si32(_loc9_,_loc1_ + 44);
                        _loc5_ = li32(_loc3_ - 4);
                        break;
                     }
                     continue;
                  }
               }
               _loc5_ = 0;
               si32(_loc5_,_loc4_);
            }
            break;
         }
      }
      wdnative.eax = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

