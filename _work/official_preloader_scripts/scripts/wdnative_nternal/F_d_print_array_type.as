package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_print_array_type() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc10_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc12_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 8);
      _loc12_ = li32(_loc3_ + 4);
      _loc11_ = li32(_loc3_);
      _loc10_ = _loc1_;
      loop6:
      while(true)
      {
         if(_loc1_ != 0)
         {
            while(true)
            {
               _loc8_ = 1;
               if(_loc10_ == 0)
               {
                  break;
               }
               var _loc9_:int = li32(_loc10_ + 8);
               if(_loc9_ != 0)
               {
                  continue;
               }
               _loc9_ = li32(_loc10_ + 4);
               _loc10_ = li32(_loc9_);
               _loc8_ = 1;
               if(_loc10_ == 36)
               {
                  _loc8_ = 0;
               }
               _loc8_ &= 1;
               if(_loc10_ == 36)
               {
                  break;
               }
               _loc7_ = li32(_loc11_ + 4);
               if(_loc7_ == 0)
               {
                  _loc2_ -= 16;
                  si32(0,_loc2_ + 8);
                  si32(_loc1_,_loc2_ + 4);
                  si32(_loc11_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_print_mod_list();
                  _loc2_ += 16;
                  addr022c:
                  _loc10_ = li32(_loc11_ + 4);
                  if(_loc10_ != 0)
                  {
                     _loc1_ = li32(_loc11_ + 12);
                     _loc6_ = li32(_loc11_ + 8);
                     if((uint(_loc6_)) < uint(_loc1_))
                     {
                        var _temp_8:* = int(_loc10_ + _loc6_);
                        si8(41,_temp_8);
                        _loc9_ = _loc6_ + 1;
                        si32(_loc9_,_loc11_ + 8);
                     }
                     else
                     {
                        _loc6_ += 1;
                        while(true)
                        {
                           if(uint(_loc1_) >= uint(_loc6_))
                           {
                              if(_loc10_ != 0)
                              {
                                 var _temp_10:* = li32(_loc11_ + 8);
                                 var _temp_11:* = int(_loc10_ + _temp_10);
                                 si8(41,_temp_11);
                                 _loc9_ = li32(_loc11_ + 8);
                                 _loc9_ = _loc9_ + 1;
                                 si32(_loc9_,_loc11_ + 8);
                              }
                              break;
                           }
                           _loc2_ -= 16;
                           si32(_loc10_,_loc2_);
                           _loc1_ <<= 1;
                           si32(_loc1_,_loc2_ + 4);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_realloc();
                           _loc2_ += 16;
                           _loc10_ = wdnative.eax;
                           if(_loc10_ == 0)
                           {
                              _loc1_ = li32(_loc11_ + 4);
                              if(_loc1_ != 0)
                              {
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_idalloc();
                                 _loc2_ += 16;
                              }
                              si32(0,_loc11_ + 4);
                              si32(1,_loc11_ + 24);
                              break;
                           }
                           si32(_loc10_,_loc11_ + 4);
                           si32(_loc1_,_loc11_ + 12);
                        }
                     }
                  }
               }
               else
               {
                  _loc6_ = li32(_loc11_ + 12);
                  _loc5_ = li32(_loc11_ + 8);
                  _loc4_ = _loc5_ + 2;
                  if((uint(_loc4_)) <= uint(_loc6_))
                  {
                     var _temp_19:* = int(_loc7_ + _loc5_);
                     si16(10272,_temp_19);
                     _loc9_ = li32(_loc11_ + 8);
                     _loc9_ = _loc9_ + 2;
                     si32(_loc9_,_loc11_ + 8);
                  }
                  else
                  {
                     while(true)
                     {
                        if(uint(_loc6_) >= uint(_loc4_))
                        {
                           if(_loc7_ != 0)
                           {
                              var _temp_22:* = li32(_loc11_ + 8);
                              var _temp_23:* = int(_loc7_ + _temp_22);
                              si16(10272,_temp_23);
                              _loc9_ = li32(_loc11_ + 8);
                              _loc9_ = _loc9_ + 2;
                              si32(_loc9_,_loc11_ + 8);
                           }
                           break;
                        }
                        _loc2_ -= 16;
                        si32(_loc7_,_loc2_);
                        _loc6_ <<= 1;
                        si32(_loc6_,_loc2_ + 4);
                        wdnative.ESP = _loc2_;
                        wdnative_nternal.F_realloc();
                        _loc2_ += 16;
                        _loc7_ = wdnative.eax;
                        if(_loc7_ == 0)
                        {
                           _loc6_ = li32(_loc11_ + 4);
                           if(_loc6_ != 0)
                           {
                              _loc2_ -= 16;
                              si32(_loc6_,_loc2_);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_idalloc();
                              _loc2_ += 16;
                           }
                           si32(0,_loc11_ + 4);
                           si32(1,_loc11_ + 24);
                           break;
                        }
                        si32(_loc7_,_loc11_ + 4);
                        si32(_loc6_,_loc11_ + 12);
                     }
                  }
                  _loc2_ -= 16;
                  si32(0,_loc2_ + 8);
                  si32(_loc1_,_loc2_ + 4);
                  si32(_loc11_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_print_mod_list();
                  _loc2_ += 16;
                  if(_loc10_ != 36)
                  {
                     §§goto(addr022c);
                  }
               }
               if(_loc8_ == 0)
               {
                  _loc8_ = _loc11_ + 4;
                  break loop6;
               }
               _loc10_ = li32(_loc10_);
            }
            _loc2_ -= 16;
            si32(0,_loc2_ + 8);
            si32(_loc1_,_loc2_ + 4);
            si32(_loc11_,_loc2_);
            wdnative.ESP = _loc2_;
            wdnative_nternal.F_d_print_mod_list();
            _loc2_ += 16;
            §§goto(addr0374);
         }
         _loc1_ = li32(_loc11_ + 4);
         _loc8_ = _loc11_ + 4;
         if(_loc1_ != 0)
         {
            _loc10_ = li32(_loc11_ + 12);
            _loc6_ = li32(_loc11_ + 8);
            if((uint(_loc6_)) < uint(_loc10_))
            {
               var _temp_34:* = int(_loc1_ + _loc6_);
               si8(32,_temp_34);
               _loc9_ = _loc6_ + 1;
               si32(_loc9_,_loc11_ + 8);
               break;
            }
            _loc6_ += 1;
            while(true)
            {
               if(uint(_loc10_) >= uint(_loc6_))
               {
                  if(_loc1_ != 0)
                  {
                     var _temp_36:* = li32(_loc11_ + 8);
                     var _temp_37:* = int(_loc1_ + _temp_36);
                     si8(32,_temp_37);
                     _loc9_ = li32(_loc11_ + 8);
                     _loc9_ = _loc9_ + 1;
                     si32(_loc9_,_loc11_ + 8);
                  }
                  break loop6;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               _loc10_ <<= 1;
               si32(_loc10_,_loc2_ + 4);
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
                  si32(0,_loc11_ + 4);
                  si32(1,_loc11_ + 24);
                  break loop6;
               }
               si32(_loc1_,_loc11_ + 4);
               si32(_loc10_,_loc11_ + 12);
            }
         }
         break;
      }
      _loc10_ = li32(_loc8_);
      if(_loc10_ != 0)
      {
         _loc1_ = li32(_loc11_ + 12);
         _loc6_ = li32(_loc11_ + 8);
         if((uint(_loc6_)) < uint(_loc1_))
         {
            var _temp_45:* = int(_loc10_ + _loc6_);
            si8(91,_temp_45);
            _loc9_ = _loc6_ + 1;
            si32(_loc9_,_loc11_ + 8);
         }
         else
         {
            _loc6_ += 1;
            while(true)
            {
               if(uint(_loc1_) >= uint(_loc6_))
               {
                  if(_loc10_ != 0)
                  {
                     var _temp_47:* = li32(_loc11_ + 8);
                     var _temp_48:* = int(_loc10_ + _temp_47);
                     si8(91,_temp_48);
                     _loc9_ = li32(_loc11_ + 8);
                     _loc9_ = _loc9_ + 1;
                     si32(_loc9_,_loc11_ + 8);
                  }
                  break;
               }
               _loc2_ -= 16;
               si32(_loc10_,_loc2_);
               _loc1_ <<= 1;
               si32(_loc1_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_realloc();
               _loc2_ += 16;
               _loc10_ = wdnative.eax;
               if(_loc10_ == 0)
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
                  si32(1,_loc11_ + 24);
                  break;
               }
               si32(_loc10_,_loc8_);
               si32(_loc1_,_loc11_ + 12);
            }
         }
      }
      _loc12_ = li32(_loc12_ + 4);
      if(_loc12_ != 0)
      {
         _loc2_ -= 16;
         si32(_loc12_,_loc2_ + 4);
         si32(_loc11_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
      }
      _loc1_ = li32(_loc8_);
      if(_loc1_ != 0)
      {
         _loc12_ = li32(_loc11_ + 12);
         _loc10_ = li32(_loc11_ + 8);
         if((uint(_loc10_)) < uint(_loc12_))
         {
            var _temp_57:* = int(_loc1_ + _loc10_);
            si8(93,_temp_57);
            _loc9_ = _loc10_ + 1;
            si32(_loc9_,_loc11_ + 8);
         }
         else
         {
            _loc10_ += 1;
            while(true)
            {
               if(uint(_loc12_) >= uint(_loc10_))
               {
                  if(_loc1_ != 0)
                  {
                     var _temp_59:* = li32(_loc11_ + 8);
                     var _temp_60:* = int(_loc1_ + _temp_59);
                     si8(93,_temp_60);
                     _loc9_ = li32(_loc11_ + 8);
                     _loc9_ = _loc9_ + 1;
                     si32(_loc9_,_loc11_ + 8);
                  }
                  break;
               }
               _loc2_ -= 16;
               si32(_loc1_,_loc2_);
               _loc12_ <<= 1;
               si32(_loc12_,_loc2_ + 4);
               wdnative.ESP = _loc2_;
               wdnative_nternal.F_realloc();
               _loc2_ += 16;
               _loc1_ = wdnative.eax;
               if(_loc1_ == 0)
               {
                  _loc12_ = li32(_loc8_);
                  if(_loc12_ != 0)
                  {
                     _loc2_ -= 16;
                     si32(_loc12_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_idalloc();
                     _loc2_ += 16;
                  }
                  si32(0,_loc8_);
                  si32(1,_loc11_ + 24);
                  break;
               }
               si32(_loc1_,_loc8_);
               si32(_loc12_,_loc11_ + 12);
            }
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

