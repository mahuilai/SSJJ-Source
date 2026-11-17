package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si16;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_print_mod_list() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc11_:int = 0;
      var _loc4_:int = 0;
      var _loc9_:int = 0;
      var _loc6_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_ + 4);
      _loc11_ = li32(_loc3_);
      var _loc10_:int = li32(_loc3_ + 8);
      if(_loc10_ == 0)
      {
         while(_loc1_ != 0)
         {
            _loc10_ = li32(_loc11_ + 4);
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = li32(_loc1_ + 8);
            if(_loc10_ == 0)
            {
               _loc10_ = li32(_loc1_ + 4);
               _loc10_ = li32(_loc10_);
               _loc10_ = _loc10_ + -25;
               if((uint(_loc10_)) >= 3)
               {
                  _loc7_ = _loc1_ + 4;
                  si32(1,_loc1_ + 8);
                  _loc8_ = li32(_loc11_ + 16);
                  _loc10_ = li32(_loc1_ + 12);
                  si32(_loc10_,_loc11_ + 16);
                  _loc9_ = li32(_loc1_ + 4);
                  _loc6_ = li32(_loc9_);
                  if(_loc6_ == 2)
                  {
                     addr0207:
                     _loc10_ = li32(_loc11_ + 20);
                     si32(0,_loc11_ + 20);
                     var _loc5_:int = li32(_loc7_);
                     _loc5_ = li32(_loc5_ + 4);
                     _loc2_ -= 16;
                     si32(_loc5_,_loc2_ + 4);
                     si32(_loc11_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_print_comp();
                     _loc2_ += 16;
                     si32(_loc10_,_loc11_ + 20);
                     _loc9_ = li32(_loc11_ + 4);
                     _loc10_ = li8(_loc11_);
                     _loc10_ = _loc10_ & 4;
                     if(_loc10_ == 0)
                     {
                        if(_loc9_ != 0)
                        {
                           _loc1_ = li32(_loc11_ + 12);
                           _loc6_ = li32(_loc11_ + 8);
                           _loc4_ = _loc6_ + 2;
                           if((uint(_loc4_)) <= uint(_loc1_))
                           {
                              var _temp_20:* = int(_loc9_ + _loc6_);
                              si16(14906,_temp_20);
                              _loc10_ = li32(_loc11_ + 8);
                              _loc10_ = _loc10_ + 2;
                              si32(_loc10_,_loc11_ + 8);
                           }
                           else
                           {
                              while(true)
                              {
                                 if(uint(_loc1_) >= uint(_loc4_))
                                 {
                                    if(_loc9_ != 0)
                                    {
                                       var _temp_23:* = li32(_loc11_ + 8);
                                       var _temp_24:* = int(_loc9_ + _temp_23);
                                       si16(14906,_temp_24);
                                       _loc10_ = li32(_loc11_ + 8);
                                       _loc10_ = _loc10_ + 2;
                                       si32(_loc10_,_loc11_ + 8);
                                    }
                                    break;
                                 }
                                 _loc2_ -= 16;
                                 si32(_loc9_,_loc2_);
                                 _loc1_ <<= 1;
                                 si32(_loc1_,_loc2_ + 4);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_realloc();
                                 _loc2_ += 16;
                                 _loc9_ = wdnative.eax;
                                 if(_loc9_ == 0)
                                 {
                                    _loc9_ = li32(_loc11_ + 4);
                                    if(_loc9_ != 0)
                                    {
                                       _loc2_ -= 16;
                                       si32(_loc9_,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F_idalloc();
                                       _loc2_ += 16;
                                    }
                                    si32(0,_loc11_ + 4);
                                    si32(1,_loc11_ + 24);
                                    break;
                                 }
                                 si32(_loc9_,_loc11_ + 4);
                                 si32(_loc1_,_loc11_ + 12);
                              }
                           }
                        }
                     }
                     else if(_loc9_ != 0)
                     {
                        _loc1_ = li32(_loc11_ + 12);
                        _loc6_ = li32(_loc11_ + 8);
                        if((uint(_loc6_)) < uint(_loc1_))
                        {
                           var _temp_32:* = int(_loc9_ + _loc6_);
                           si8(46,_temp_32);
                           _loc10_ = _loc6_ + 1;
                           si32(_loc10_,_loc11_ + 8);
                        }
                        else
                        {
                           _loc6_ += 1;
                           while(true)
                           {
                              if(uint(_loc1_) >= uint(_loc6_))
                              {
                                 if(_loc9_ != 0)
                                 {
                                    var _temp_34:* = li32(_loc11_ + 8);
                                    var _temp_35:* = int(_loc9_ + _temp_34);
                                    si8(46,_temp_35);
                                    _loc10_ = li32(_loc11_ + 8);
                                    _loc10_ = _loc10_ + 1;
                                    si32(_loc10_,_loc11_ + 8);
                                 }
                                 break;
                              }
                              _loc2_ -= 16;
                              si32(_loc9_,_loc2_);
                              _loc1_ <<= 1;
                              si32(_loc1_,_loc2_ + 4);
                              wdnative.ESP = _loc2_;
                              wdnative_nternal.F_realloc();
                              _loc2_ += 16;
                              _loc9_ = wdnative.eax;
                              if(_loc9_ == 0)
                              {
                                 _loc9_ = li32(_loc11_ + 4);
                                 if(_loc9_ != 0)
                                 {
                                    _loc2_ -= 16;
                                    si32(_loc9_,_loc2_);
                                    wdnative.ESP = _loc2_;
                                    wdnative_nternal.F_idalloc();
                                    _loc2_ += 16;
                                 }
                                 si32(0,_loc11_ + 4);
                                 si32(1,_loc11_ + 24);
                                 break;
                              }
                              si32(_loc9_,_loc11_ + 4);
                              si32(_loc1_,_loc11_ + 12);
                           }
                        }
                     }
                     _loc10_ = li32(_loc7_);
                     _loc7_ = li32(_loc10_ + 8);
                     _loc10_ = li32(_loc7_);
                     _loc10_ = _loc10_ + -25;
                     if((uint(_loc10_)) <= 2)
                     {
                        while(true)
                        {
                           _loc7_ = li32(_loc7_ + 4);
                           _loc10_ = li32(_loc7_);
                           _loc10_ = _loc10_ + -25;
                           if((uint(_loc10_)) >= 3)
                           {
                              break;
                           }
                        }
                     }
                     _loc2_ -= 16;
                     si32(_loc7_,_loc2_ + 4);
                     si32(_loc11_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_print_comp();
                     _loc2_ += 16;
                     si32(_loc8_,_loc11_ + 16);
                     break;
                  }
                  if(_loc6_ == 35)
                  {
                     addr018b:
                     _loc10_ = li32(_loc1_);
                     _loc2_ -= 16;
                     si32(_loc10_,_loc2_ + 8);
                     si32(_loc9_,_loc2_ + 4);
                     si32(_loc11_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_print_function_type();
                     _loc2_ += 16;
                     si32(_loc8_,_loc11_ + 16);
                     break;
                  }
                  if(_loc6_ == 36)
                  {
                     addr01c9:
                     _loc10_ = li32(_loc1_);
                     _loc2_ -= 16;
                     si32(_loc10_,_loc2_ + 8);
                     si32(_loc9_,_loc2_ + 4);
                     si32(_loc11_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_print_array_type();
                     _loc2_ += 16;
                     si32(_loc8_,_loc11_ + 16);
                     break;
                  }
                  _loc2_ -= 16;
                  si32(_loc9_,_loc2_ + 4);
                  si32(_loc11_,_loc2_);
                  wdnative.ESP = _loc2_;
                  wdnative_nternal.F_d_print_mod();
                  _loc2_ += 16;
                  si32(_loc8_,_loc11_ + 16);
               }
            }
            _loc1_ = li32(_loc1_);
         }
      }
      else
      {
         for(; _loc1_ != 0; _loc1_ = li32(_loc1_))
         {
            _loc10_ = li32(_loc11_ + 4);
            if(_loc10_ == 0)
            {
               break;
            }
            _loc10_ = li32(_loc1_ + 8);
            if(_loc10_ != 0)
            {
               continue;
            }
            si32(1,_loc1_ + 8);
            _loc8_ = li32(_loc11_ + 16);
            _loc10_ = li32(_loc1_ + 12);
            si32(_loc10_,_loc11_ + 16);
            _loc7_ = _loc1_ + 4;
            _loc9_ = li32(_loc1_ + 4);
            _loc6_ = li32(_loc9_);
            if(_loc6_ != 2)
            {
               if(_loc6_ != 36)
               {
                  if(_loc6_ != 35)
                  {
                     _loc2_ -= 16;
                     si32(_loc9_,_loc2_ + 4);
                     si32(_loc11_,_loc2_);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_d_print_mod();
                     _loc2_ += 16;
                     si32(_loc8_,_loc11_ + 16);
                     continue;
                  }
                  §§goto(addr018b);
               }
               else
               {
                  §§goto(addr01c9);
               }
            }
            else
            {
               §§goto(addr0207);
            }
         }
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

