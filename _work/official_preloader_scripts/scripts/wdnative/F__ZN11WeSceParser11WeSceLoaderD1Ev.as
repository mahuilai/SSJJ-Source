package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F_idalloc;
   
   public function F__ZN11WeSceParser11WeSceLoaderD1Ev() : void
   {
      var _temp_1:* = this;
      var _loc5_:int = 0;
      var _loc17_:int = 0;
      var _loc12_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc13_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:int = 0;
      var _loc16_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc5_ = _loc3_;
      _loc4_ = wdnative.__ZTVN11WeSceParser11WeSceLoaderE + 8;
      _loc17_ = li32(_loc5_);
      si32(_loc4_,_loc17_);
      _loc16_ = li32(_loc17_ + 556);
      if(_loc16_ != 0)
      {
         _loc15_ = li32(_loc17_ + 136);
         _loc14_ = 0;
         while(true)
         {
            if(_loc15_ >= 1)
            {
               do
               {
                  _loc4_ = _loc14_ * 3;
                  _loc13_ = _loc4_ << 2;
                  _loc4_ = _loc16_ + _loc13_;
                  _loc12_ = li32(_loc4_);
                  if(_loc12_ != 0)
                  {
                     _loc3_ -= 16;
                     si32(_loc12_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_idalloc();
                     _loc3_ += 16;
                     _loc4_ = li32(_loc17_ + 556);
                     var _temp_8:* = int(_loc4_ + _loc13_);
                     si32(0,_temp_8);
                     _loc15_ = li32(_loc17_ + 136);
                     _loc16_ = li32(_loc17_ + 556);
                  }
                  _loc14_ += 1;
               }
               while(_loc15_ > _loc14_);
               if(_loc16_ == 0)
               {
                  break;
               }
            }
            _loc3_ -= 16;
            si32(_loc16_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_idalloc();
            _loc3_ += 16;
            si32(0,_loc17_ + 556);
            break;
         }
      }
      _loc11_ = li32(_loc17_ + 560);
      if(_loc11_ != 0)
      {
         var _temp_11:* = li32(_loc17_ + 124);
         _loc10_ = 0;
         while(true)
         {
            if(_temp_11 >= 1)
            {
               do
               {
                  _loc4_ = _loc10_ * 7;
                  _loc1_ = _loc4_ << 2;
                  _loc4_ = _loc11_ + _loc1_;
                  _loc6_ = li32(_loc4_ + 12);
                  if(_loc6_ != 0)
                  {
                     _loc3_ -= 16;
                     si32(_loc6_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_idalloc();
                     _loc3_ += 16;
                     _loc4_ = li32(_loc17_ + 560);
                     var _temp_17:* = int(_loc4_ + _loc1_);
                     si32(0,_temp_17 + 12);
                     _loc11_ = li32(_loc17_ + 560);
                  }
                  _loc4_ = _loc11_ + _loc1_;
                  _loc7_ = li32(_loc4_ + 16);
                  if(_loc7_ != 0)
                  {
                     _loc3_ -= 16;
                     si32(_loc7_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_idalloc();
                     _loc3_ += 16;
                     _loc4_ = li32(_loc17_ + 560);
                     var _temp_22:* = int(_loc4_ + _loc1_);
                     si32(0,_temp_22 + 16);
                     _loc11_ = li32(_loc17_ + 560);
                  }
                  _loc4_ = _loc11_ + _loc1_;
                  _loc8_ = li32(_loc4_ + 20);
                  if(_loc8_ != 0)
                  {
                     _loc3_ -= 16;
                     si32(_loc8_,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_idalloc();
                     _loc3_ += 16;
                     _loc4_ = li32(_loc17_ + 560);
                     var _temp_27:* = int(_loc4_ + _loc1_);
                     si32(0,_temp_27 + 20);
                     _loc11_ = li32(_loc17_ + 560);
                  }
                  _loc10_ += 1;
               }
               while(_loc4_ = li32(_loc17_ + 124), _loc4_ > _loc10_);
               if(_loc11_ == 0)
               {
                  break;
               }
            }
            _loc3_ -= 16;
            si32(_loc11_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_idalloc();
            _loc3_ += 16;
            si32(0,_loc17_ + 560);
            break;
         }
      }
      _loc4_ = wdnative.__ZTV20WeLittleEndianReader + 8;
      si32(_loc4_,_loc17_ + 40);
      _loc9_ = li32(_loc17_ + 76);
      if(_loc9_ != 0)
      {
         _loc4_ = li8(_loc17_ + 80);
         if(_loc4_ == 0)
         {
            _loc3_ -= 16;
            si32(_loc9_,_loc3_);
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_idalloc();
            _loc3_ += 16;
            si32(0,_loc17_ + 76);
         }
      }
      var _loc2_:int = wdnative.__ZTV8WeObject + 8;
      si32(_loc2_,_loc17_ + 40);
      _loc4_ = li32(_loc17_ + 60);
      _loc3_ -= 16;
      si32(_loc4_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative.F__ZNSt8_Rb_treeIN7WeEvent4EnumESt4pairIKS1_St6vectorI10WeObserverSaIS5_EEESt10_Select1stIS8_ESt4lessIS1_ESaIS8_EE8_M_eraseEPSt13_Rb_tree_nodeIS8_E();
      _loc3_ += 16;
      si32(_loc2_,_loc17_);
      _loc4_ = li32(_loc17_ + 20);
      _loc3_ -= 16;
      si32(_loc4_,_loc3_);
      wdnative.ESP = _loc3_;
      wdnative.F__ZNSt8_Rb_treeIN7WeEvent4EnumESt4pairIKS1_St6vectorI10WeObserverSaIS5_EEESt10_Select1stIS8_ESt4lessIS1_ESaIS8_EE8_M_eraseEPSt13_Rb_tree_nodeIS8_E();
      _loc3_ += 16;
      _loc3_ = _loc5_;
      wdnative.ESP = _loc3_;
   }
}

