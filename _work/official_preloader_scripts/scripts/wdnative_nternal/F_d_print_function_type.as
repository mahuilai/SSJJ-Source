package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_print_function_type() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc9_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc1_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc10_:int = 0;
      var _loc5_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = 0;
      _loc11_ = li32(_loc3_ + 8);
      _loc10_ = li32(_loc3_ + 4);
      _loc9_ = li32(_loc3_);
      _loc8_ = _loc11_;
      for(; _loc8_ != 0; _loc8_ = li32(_loc8_),_loc1_ = 1)
      {
         var _loc7_:int = li32(_loc8_ + 8);
         if(_loc7_ != 0)
         {
            break;
         }
         _loc7_ = li32(_loc8_ + 4);
         _loc7_ = li32(_loc7_);
         _loc1_ = _loc7_ + -22;
         if(uint(_loc1_) <= 15)
         {
            _loc1_ = 1 << _loc1_;
            _loc7_ = _loc1_ & 0x8647;
            if(_loc7_ == 0)
            {
               _loc7_ = _loc1_ & 0x0180;
               if(_loc7_ == 0)
               {
                  continue;
               }
               addr00d1:
               _loc1_ = li32(_loc9_ + 4);
               if(_loc1_ != 0)
               {
                  _loc8_ = _loc9_ + 4;
                  loop6:
                  while(true)
                  {
                     _loc6_ = li32(_loc9_ + 8);
                     if(_loc6_ != 0)
                     {
                        _loc7_ = _loc6_ + _loc1_;
                        _loc7_ = li8(_loc7_ - 1);
                        _loc7_ = _loc7_ | 2;
                        _loc7_ = _loc7_ & 0xFF;
                        if(_loc7_ == 42)
                        {
                           break;
                        }
                     }
                     addr0136:
                     _loc5_ = li32(_loc9_ + 8);
                     if(_loc5_ != 0)
                     {
                        _loc7_ = _loc5_ + _loc1_;
                        _loc7_ = li8(_loc7_ - 1);
                        if(_loc7_ == 32)
                        {
                           break;
                        }
                     }
                     _loc6_ = li32(_loc9_ + 12);
                     if(uint(_loc5_) < uint(_loc6_))
                     {
                        var _temp_15:* = int(_loc1_ + _loc5_);
                        si8(32,_temp_15);
                        _loc7_ = _loc5_ + 1;
                        si32(_loc7_,_loc9_ + 8);
                        break;
                     }
                     _loc5_ += 1;
                     while(true)
                     {
                        if(uint(_loc6_) >= uint(_loc5_))
                        {
                           if(_loc1_ != 0)
                           {
                              var _temp_17:* = li32(_loc9_ + 8);
                              var _temp_18:* = int(_loc1_ + _temp_17);
                              si8(32,_temp_18);
                              _loc7_ = li32(_loc9_ + 8);
                              _loc7_ = _loc7_ + 1;
                              si32(_loc7_,_loc9_ + 8);
                           }
                           break loop6;
                        }
                        _loc2_ -= 16;
                        si32(_loc1_,_loc2_);
                        _loc6_ <<= 1;
                        si32(_loc6_,_loc2_ + 4);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_realloc();
                        _loc2_ += 16;
                        _loc1_ = wdnative.eax;
                        if(_loc1_ == 0)
                        {
                           _loc1_ = li32(_loc8_);
                           if(_loc1_ != 0)
                           {
                              _loc2_ -= 16;
                              si32(_loc1_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_idalloc();
                              _loc2_ += 16;
                           }
                           si32(0,_loc8_);
                           si32(1,_loc9_ + 24);
                           break loop6;
                        }
                        si32(_loc1_,_loc8_);
                        si32(_loc6_,_loc9_ + 12);
                     }
                     break;
                  }
               }
            }
            else
            {
               _loc1_ = li32(_loc9_ + 4);
               _loc8_ = _loc9_ + 4;
               if(_loc1_ != 0)
               {
                  §§goto(addr0136);
               }
            }
            _loc1_ = li32(_loc9_ + 4);
            _loc8_ = _loc9_ + 4;
            _loc6_ = 0;
            if(_loc1_ != 0)
            {
               _loc6_ = li32(_loc9_ + 12);
               _loc5_ = li32(_loc9_ + 8);
               if((uint(_loc5_)) < uint(_loc6_))
               {
                  var _temp_25:* = int(_loc1_ + _loc5_);
                  si8(40,_temp_25);
                  _loc7_ = _loc5_ + 1;
                  si32(_loc7_,_loc9_ + 8);
                  _loc6_ = 0;
               }
               else
               {
                  _loc5_ += 1;
                  while(true)
                  {
                     if(uint(_loc6_) >= uint(_loc5_))
                     {
                        _loc6_ = 0;
                        if(_loc1_ != 0)
                        {
                           var _temp_27:* = li32(_loc9_ + 8);
                           var _temp_28:* = int(_loc1_ + _temp_27);
                           si8(40,_temp_28);
                           _loc7_ = li32(_loc9_ + 8);
                           _loc7_ = _loc7_ + 1;
                           si32(_loc7_,_loc9_ + 8);
                           _loc6_ = 0;
                        }
                        break;
                     }
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     _loc6_ <<= 1;
                     si32(_loc6_,_loc2_ + 4);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_realloc();
                     _loc2_ += 16;
                     _loc1_ = wdnative.eax;
                     if(_loc1_ == 0)
                     {
                        _loc1_ = li32(_loc8_);
                        if(_loc1_ != 0)
                        {
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_idalloc();
                           _loc2_ += 16;
                        }
                        _loc6_ = 0;
                        si32(_loc6_,_loc9_ + 4);
                        si32(1,_loc9_ + 24);
                        break;
                     }
                     si32(_loc1_,_loc9_ + 4);
                     si32(_loc6_,_loc9_ + 12);
                  }
               }
            }
            §§goto(addr0381);
         }
      }
      while(true)
      {
         if(_loc1_ == 0)
         {
            _loc7_ = li32(_loc10_ + 4);
            if(_loc7_ != 0)
            {
               §§goto(addr00d1);
            }
         }
         _loc8_ = _loc9_ + 4;
         _loc6_ = 1;
         break;
      }
      addr0381:
      _loc1_ = li32(_loc9_ + 20);
      si32(0,_loc9_ + 20);
      _loc2_ -= 16;
      si32(0,_loc2_ + 8);
      si32(_loc11_,_loc2_ + 4);
      si32(_loc9_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_d_print_mod_list();
      _loc2_ += 16;
      loop7:
      while(true)
      {
         if(_loc6_ == 0)
         {
            _loc5_ = li32(_loc8_);
            if(_loc5_ == 0)
            {
               break;
            }
            _loc6_ = li32(_loc9_ + 12);
            _loc4_ = li32(_loc9_ + 8);
            if((uint(_loc4_)) < uint(_loc6_))
            {
               var _temp_37:* = int(_loc5_ + _loc4_);
               si8(41,_temp_37);
               _loc7_ = _loc4_ + 1;
               si32(_loc7_,_loc9_ + 8);
            }
            else
            {
               _loc4_ += 1;
               while(true)
               {
                  if(uint(_loc6_) >= uint(_loc4_))
                  {
                     if(_loc5_ != 0)
                     {
                        var _temp_39:* = li32(_loc9_ + 8);
                        var _temp_40:* = int(_loc5_ + _temp_39);
                        si8(41,_temp_40);
                        _loc7_ = li32(_loc9_ + 8);
                        _loc7_ = _loc7_ + 1;
                        si32(_loc7_,_loc9_ + 8);
                     }
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc5_,_loc2_);
                  _loc6_ <<= 1;
                  si32(_loc6_,_loc2_ + 4);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_realloc();
                  _loc2_ += 16;
                  _loc5_ = wdnative.eax;
                  if(_loc5_ == 0)
                  {
                     _loc6_ = li32(_loc8_);
                     if(_loc6_ != 0)
                     {
                        _loc2_ -= 16;
                        si32(_loc6_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_idalloc();
                        _loc2_ += 16;
                     }
                     si32(0,_loc8_);
                     si32(1,_loc9_ + 24);
                     break;
                  }
                  si32(_loc5_,_loc8_);
                  si32(_loc6_,_loc9_ + 12);
               }
            }
         }
         _loc6_ = li32(_loc8_);
         if(_loc6_ != 0)
         {
            _loc5_ = li32(_loc9_ + 12);
            _loc4_ = li32(_loc9_ + 8);
            if((uint(_loc4_)) < uint(_loc5_))
            {
               var _temp_50:* = int(_loc6_ + _loc4_);
               si8(40,_temp_50);
               _loc7_ = _loc4_ + 1;
               si32(_loc7_,_loc9_ + 8);
               break;
            }
            _loc4_ += 1;
            while(true)
            {
               if(uint(_loc5_) >= uint(_loc4_))
               {
                  if(_loc6_ != 0)
                  {
                     var _temp_52:* = li32(_loc9_ + 8);
                     var _temp_53:* = int(_loc6_ + _temp_52);
                     si8(40,_temp_53);
                     _loc7_ = li32(_loc9_ + 8);
                     _loc7_ = _loc7_ + 1;
                     si32(_loc7_,_loc9_ + 8);
                  }
                  break loop7;
               }
               _loc2_ -= 16;
               si32(_loc6_,_loc2_);
               _loc5_ <<= 1;
               si32(_loc5_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_realloc();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
               if(_loc6_ == 0)
               {
                  _loc6_ = li32(_loc8_);
                  if(_loc6_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(_loc6_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                  }
                  si32(0,_loc8_);
                  si32(1,_loc9_ + 24);
                  break loop7;
               }
               si32(_loc6_,_loc8_);
               si32(_loc5_,_loc9_ + 12);
            }
         }
         break;
      }
      _loc10_ = li32(_loc10_ + 8);
      if(_loc10_ != 0)
      {
         _loc2_ -= 16;
         si32(_loc10_,_loc2_ + 4);
         si32(_loc9_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
      }
      _loc6_ = li32(_loc8_);
      if(_loc6_ != 0)
      {
         _loc10_ = li32(_loc9_ + 12);
         _loc5_ = li32(_loc9_ + 8);
         if((uint(_loc5_)) < uint(_loc10_))
         {
            var _temp_65:* = int(_loc6_ + _loc5_);
            si8(41,_temp_65);
            _loc7_ = _loc5_ + 1;
            si32(_loc7_,_loc9_ + 8);
         }
         else
         {
            _loc5_ += 1;
            while(true)
            {
               if(uint(_loc10_) >= uint(_loc5_))
               {
                  if(_loc6_ != 0)
                  {
                     var _temp_67:* = li32(_loc9_ + 8);
                     var _temp_68:* = int(_loc6_ + _temp_67);
                     si8(41,_temp_68);
                     _loc7_ = li32(_loc9_ + 8);
                     _loc7_ = _loc7_ + 1;
                     si32(_loc7_,_loc9_ + 8);
                  }
                  break;
               }
               _loc2_ -= 16;
               si32(_loc6_,_loc2_);
               _loc10_ <<= 1;
               si32(_loc10_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_realloc();
               _loc2_ += 16;
               _loc6_ = wdnative.eax;
               if(_loc6_ == 0)
               {
                  _loc10_ = li32(_loc8_);
                  if(_loc10_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(_loc10_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                  }
                  si32(0,_loc8_);
                  si32(1,_loc9_ + 24);
                  break;
               }
               si32(_loc6_,_loc8_);
               si32(_loc10_,_loc9_ + 12);
            }
         }
      }
      _loc2_ -= 16;
      si32(1,_loc2_ + 8);
      si32(_loc11_,_loc2_ + 4);
      si32(_loc9_,_loc2_);
      wdnative.ESP = _loc2_;
      wdnative_nternal.F_d_print_mod_list();
      _loc2_ += 16;
      si32(_loc1_,_loc9_ + 20);
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

