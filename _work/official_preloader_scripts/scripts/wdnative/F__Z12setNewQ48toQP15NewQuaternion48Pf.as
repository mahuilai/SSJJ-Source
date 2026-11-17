package wdnative
{
   import avm2.intrinsics.memory.lf32;
   import avm2.intrinsics.memory.li16;
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.sf32;
   import avm2.intrinsics.memory.si32;
   
   public function F__Z12setNewQ48toQP15NewQuaternion48Pf() : void
   {
      var _temp_1:* = this;
      var _loc6_:int = 0;
      var _loc13_:int = 0;
      var _loc16_:Number = NaN;
      var _loc5_:int = 0;
      var _loc8_:Number = NaN;
      var _loc1_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc2_:Number = NaN;
      var _loc11_:Number = NaN;
      var _loc10_:Number = NaN;
      var _loc15_:Number = NaN;
      _loc6_ = wdnative.ESP;
      var _loc4_:int = _loc6_ - 16;
      _loc5_ = li32(_loc6_);
      var _loc17_:int = li16(_loc5_);
      _loc8_ = _loc17_ = _loc17_ + -32768;
      _loc1_ = _loc8_ = _loc8_ * 0.000030517578125;
      _loc13_ = li32(_loc6_ + 4);
      sf32(_loc1_,_loc13_);
      _loc17_ = li16(_loc5_ + 2);
      _loc8_ = _loc17_ = _loc17_ + -32768;
      _loc3_ = _loc8_ = _loc8_ * 0.000030517578125;
      sf32(_loc3_,_loc13_ + 4);
      _loc5_ = li16(_loc5_ + 4);
      _loc7_ = _loc5_ = _loc5_ + -32768;
      _loc2_ = _loc7_ = _loc7_ * 0.000030517578125;
      sf32(_loc2_,_loc13_ + 8);
      var _loc14_:Number;
      _loc11_ = _loc14_ = 1;
      _loc10_ = _loc1_;
      _loc1_ = _loc10_ *= _loc10_;
      _loc10_ = _loc1_;
      _loc1_ = _loc10_ = _loc11_ - _loc10_;
      _loc10_ = _loc1_;
      _loc8_ = _loc3_;
      _loc3_ = _loc8_ *= _loc8_;
      _loc8_ = _loc3_;
      _loc3_ = _loc8_ = _loc10_ - _loc8_;
      _loc8_ = _loc3_;
      _loc7_ = _loc2_;
      _loc2_ = _loc7_ *= _loc7_;
      _loc7_ = _loc2_;
      _loc16_ = _loc7_ = _loc8_ - _loc7_;
      sf32(_loc16_,_loc13_ + 12);
      _loc15_ = _loc16_;
      _loc2_ = 0;
      _loc7_ = _loc2_;
      if(!(_loc15_ >= _loc7_ | _loc15_ != _loc15_ | _loc7_ != _loc7_))
      {
         _loc7_ = -_loc15_;
         var _temp_27:* = _loc7_;
         sf32(_temp_27,_loc6_ - 12);
         _loc17_ = li32(_loc6_ - 12);
         var _temp_29:* = _loc17_ >> 1;
         _loc17_ = 1597463174 - _temp_29;
         si32(_loc17_,_loc6_ - 16);
         var _temp_31:* = -0.5;
         _loc8_ = _loc15_ * _temp_31;
         var _temp_33:* = _loc8_;
         _loc11_ = lf32(_loc6_ - 16);
         var _temp_37:* = _loc10_ = (_loc10_ = _loc10_ = _temp_33 * _loc11_) * _loc11_;
         var _loc9_:Number;
         var _loc12_:Number = _loc9_ = _loc12_ = (_loc10_ = 1.5) - _temp_37;
         _loc11_ = _loc14_ = _loc11_ = _loc12_ * _loc11_;
         var _temp_48:* = _loc9_ = _loc12_ = (_loc12_ = _loc9_ = _loc12_ = _temp_33 * _loc11_) * _loc11_;
         _loc12_ = _loc9_ = _loc12_ = _loc10_ - _temp_48;
         _loc11_ = _loc14_ = _loc11_ = _loc12_ * _loc11_;
         _loc8_ = _loc8_ = _temp_33 * _loc11_;
         _loc8_ = _loc8_ * _loc11_;
         var _temp_58:* = _loc8_;
         _loc8_ = _loc8_ = _loc10_ - _temp_58;
         _loc8_ = _loc8_ = _loc8_ * _loc11_;
         _loc16_ = _loc7_ = _loc8_ * _temp_27;
      }
      else
      {
         sf32(_loc16_,_loc6_ - 4);
         _loc5_ = li32(_loc6_ - 4);
         var _temp_65:* = _loc5_ >> 1;
         _loc5_ = 1597463174 - _temp_65;
         si32(_loc5_,_loc6_ - 8);
         var _temp_67:* = 0.5;
         _loc7_ = _loc15_ * _temp_67;
         var _temp_69:* = _loc7_;
         _loc10_ = lf32(_loc6_ - 8);
         var _temp_73:* = _loc8_ = (_loc8_ = _loc8_ = _temp_69 * _loc10_) * _loc10_;
         _loc11_ = _loc14_ = _loc11_ = (_loc8_ = 1.5) - _temp_73;
         _loc10_ = _loc10_ = _loc11_ * _loc10_;
         var _temp_83:* = _loc14_ = _loc11_ = (_loc11_ = _loc14_ = _loc11_ = _temp_69 * _loc10_) * _loc10_;
         _loc11_ = _loc14_ = _loc11_ = _loc8_ - _temp_83;
         _loc10_ = _loc10_ = _loc11_ * _loc10_;
         _loc7_ = _loc7_ = _temp_69 * _loc10_;
         _loc7_ = _loc7_ * _loc10_;
         var _temp_92:* = _loc7_;
         _loc7_ = _loc7_ = _loc8_ - _temp_92;
         _loc7_ = _loc7_ = _loc7_ * _loc10_;
         _loc16_ = _loc7_ = _loc7_ * _loc15_;
      }
      sf32(_loc16_,_loc13_ + 12);
      wdnative.ESP = _loc4_ = _loc6_;
   }
}

