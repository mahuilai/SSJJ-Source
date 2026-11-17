package wdnative
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F_idalloc;
   
   public function F__ZN20WeLittleEndianReaderD1Ev() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = wdnative.__ZTV20WeLittleEndianReader + 8;
      _loc5_ = li32(_loc3_);
      si32(_loc1_,_loc5_);
      _loc4_ = li32(_loc5_ + 36);
      if(_loc4_ != 0)
      {
         if(li8(_loc5_ + 40) == 0)
         {
            _loc2_ -= 16;
            si32(_loc4_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_idalloc();
            _loc2_ += 16;
            si32(0,_loc5_ + 36);
         }
      }
      _loc1_ = wdnative.__ZTV8WeObject + 8;
      si32(_loc1_,_loc5_);
      _loc1_ = li32(_loc5_ + 20);
      _loc2_ -= 16;
      si32(_loc1_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative.F__ZNSt8_Rb_treeIN7WeEvent4EnumESt4pairIKS1_St6vectorI10WeObserverSaIS5_EEESt10_Select1stIS8_ESt4lessIS1_ESaIS8_EE8_M_eraseEPSt13_Rb_tree_nodeIS8_E();
      _loc2_ += 16;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

