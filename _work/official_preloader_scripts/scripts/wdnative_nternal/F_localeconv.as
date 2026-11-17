package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   
   public function F_localeconv() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li8(wdnative_nternal.___mlocale_changed_2E_b);
      if(_loc1_ == 0)
      {
         _loc4_ = wdnative_nternal.__C_monetary_locale;
         if(li32(wdnative_nternal.__monetary_using_locale) != 0)
         {
            _loc4_ = wdnative_nternal.__monetary_locale;
         }
         _loc1_ = li32(_loc4_);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 12);
         _loc1_ = li32(_loc4_ + 4);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 16);
         _loc1_ = li32(_loc4_ + 8);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 20);
         _loc1_ = li32(_loc4_ + 12);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 24);
         _loc1_ = li32(_loc4_ + 16);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 28);
         _loc1_ = li32(_loc4_ + 20);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 32);
         _loc1_ = li32(_loc4_ + 24);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 36);
         _loc1_ = li32(_loc4_ + 28);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 40);
         _loc1_ = li32(_loc4_ + 32);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 41);
         _loc1_ = li32(_loc4_ + 36);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 42);
         _loc1_ = li32(_loc4_ + 40);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 43);
         _loc1_ = li32(_loc4_ + 44);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 44);
         _loc1_ = li32(_loc4_ + 48);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 45);
         _loc1_ = li32(_loc4_ + 52);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 46);
         _loc1_ = li32(_loc4_ + 56);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 47);
         _loc1_ = li32(_loc4_ + 60);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 48);
         _loc1_ = li32(_loc4_ + 64);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 49);
         _loc1_ = li32(_loc4_ + 68);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 50);
         _loc1_ = li32(_loc4_ + 72);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 51);
         _loc1_ = li32(_loc4_ + 76);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 52);
         _loc1_ = li32(_loc4_ + 80);
         _loc1_ = li8(_loc1_);
         si8(_loc1_,wdnative_nternal._ret_2E_1143 + 53);
         si8(1,wdnative_nternal.___mlocale_changed_2E_b);
      }
      _loc1_ = li8(wdnative_nternal.___nlocale_changed_2E_b);
      if(_loc1_ == 0)
      {
         _loc4_ = wdnative_nternal.__C_numeric_locale;
         if(li32(wdnative_nternal.__numeric_using_locale) != 0)
         {
            _loc4_ = wdnative_nternal.__numeric_locale;
         }
         _loc1_ = li32(_loc4_);
         si32(_loc1_,wdnative_nternal._ret_2E_1143);
         _loc1_ = li32(_loc4_ + 4);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 4);
         _loc1_ = li32(_loc4_ + 8);
         si32(_loc1_,wdnative_nternal._ret_2E_1143 + 8);
         si8(1,wdnative_nternal.___nlocale_changed_2E_b);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

