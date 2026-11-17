package wdnative_nternal
{
   import avm2.intrinsics.memory.li32;
   import avm2.intrinsics.memory.li8;
   import avm2.intrinsics.memory.si32;
   import avm2.intrinsics.memory.si8;
   import wdnative.ESP;
   import wdnative.eax;
   
   public function F_d_print_cast() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc8_:int = 0;
      var _loc10_:int = 0;
      var _loc4_:int = 0;
      var _loc7_:int = 0;
      var _loc1_:int = 0;
      var _loc5_:int = 0;
      var _loc9_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc2_ -= 16;
      _loc1_ = li32(_loc3_ + 4);
      _loc10_ = li32(_loc1_ + 4);
      _loc9_ = li32(_loc10_);
      _loc8_ = li32(_loc3_);
      if(_loc9_ != 4)
      {
         _loc2_ -= 16;
         si32(_loc10_,_loc2_ + 4);
         si32(_loc8_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
      }
      else
      {
         _loc10_ = li32(_loc8_ + 20);
         _loc7_ = 0;
         si32(_loc7_,_loc8_ + 20);
         _loc9_ = li32(_loc8_ + 16);
         si32(_loc9_,_loc3_ - 8);
         _loc9_ = _loc3_ - 8;
         si32(_loc9_,_loc8_ + 16);
         var _temp_7:* = _loc9_ | 4;
         var _loc6_:int;
         si32(_loc6_ = li32(_loc1_ + 4),_temp_7);
         var _temp_8:* = li32(_loc6_ + 4);
         _loc2_ -= 16;
         si32(_temp_8,_loc2_ + 4);
         si32(_loc8_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
         _loc9_ = li32(_loc3_ - 8);
         si32(_loc9_,_loc8_ + 16);
         _loc5_ = li32(_loc8_ + 4);
         if(_loc5_ != 0)
         {
            loop4:
            while(true)
            {
               _loc4_ = li32(_loc8_ + 8);
               if(_loc4_ != 0)
               {
                  _loc9_ = _loc4_ + _loc5_;
                  var _temp_14:* = li8(_loc9_ - 1);
                  _loc7_ = _loc4_;
                  if(_temp_14 == 60)
                  {
                     _loc7_ = li32(_loc8_ + 12);
                     while(true)
                     {
                        if(_loc5_ != 0)
                        {
                           if(uint(_loc4_) < uint(_loc7_))
                           {
                              var _temp_15:* = int(_loc5_ + _loc4_);
                              si8(32,_temp_15);
                              _loc7_ = _loc4_ + 1;
                              si32(_loc7_,_loc8_ + 8);
                              break;
                           }
                        }
                        if(uint(_loc4_) >= uint(_loc7_))
                        {
                           _loc4_ += 1;
                           while(true)
                           {
                              if(uint(_loc7_) < uint(_loc4_))
                              {
                                 _loc2_ -= 16;
                                 si32(_loc5_,_loc2_);
                                 _loc7_ <<= 1;
                                 si32(_loc7_,_loc2_ + 4);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_realloc();
                                 _loc2_ += 16;
                                 _loc5_ = wdnative.eax;
                                 if(_loc5_ == 0)
                                 {
                                    _loc5_ = li32(_loc8_ + 4);
                                    if(_loc5_ != 0)
                                    {
                                       _loc2_ -= 16;
                                       si32(_loc5_,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F_idalloc();
                                       _loc2_ += 16;
                                    }
                                    si32(0,_loc8_ + 4);
                                    si32(1,_loc8_ + 24);
                                    break loop4;
                                 }
                                 continue;
                              }
                              if(_loc5_ == 0)
                              {
                                 break loop4;
                              }
                              _loc4_ = li32(_loc8_ + 8);
                              si32(_loc5_,_loc8_ + 4);
                              si32(_loc7_,_loc8_ + 12);
                           }
                           break loop4;
                        }
                        _loc9_ = _loc5_ + _loc4_;
                        si8(32,_loc9_);
                        _loc9_ = li32(_loc8_ + 8);
                        _loc7_ = _loc9_ + 1;
                        si32(_loc7_,_loc8_ + 8);
                        break;
                     }
                  }
               }
               _loc4_ = li32(_loc8_ + 4);
               if(_loc4_ != 0)
               {
                  _loc5_ = li32(_loc8_ + 12);
                  if(uint(_loc7_) < uint(_loc5_))
                  {
                     var _temp_25:* = int(_loc4_ + _loc7_);
                     si8(60,_temp_25);
                     _loc9_ = _loc7_ + 1;
                     si32(_loc9_,_loc8_ + 8);
                     break;
                  }
                  _loc7_ += 1;
                  while(true)
                  {
                     if(uint(_loc5_) >= uint(_loc7_))
                     {
                        if(_loc4_ != 0)
                        {
                           var _temp_27:* = li32(_loc8_ + 8);
                           var _temp_28:* = int(_loc4_ + _temp_27);
                           si8(60,_temp_28);
                           _loc9_ = li32(_loc8_ + 8);
                           _loc9_ = _loc9_ + 1;
                           si32(_loc9_,_loc8_ + 8);
                        }
                        break loop4;
                     }
                     _loc2_ -= 16;
                     si32(_loc4_,_loc2_);
                     _loc5_ <<= 1;
                     si32(_loc5_,_loc2_ + 4);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_realloc();
                     _loc2_ += 16;
                     _loc4_ = wdnative.eax;
                     if(_loc4_ == 0)
                     {
                        _loc5_ = li32(_loc8_ + 4);
                        if(_loc5_ != 0)
                        {
                           _loc2_ -= 16;
                           si32(_loc5_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_idalloc();
                           _loc2_ += 16;
                        }
                        si32(0,_loc8_ + 4);
                        si32(1,_loc8_ + 24);
                        break loop4;
                     }
                     si32(_loc4_,_loc8_ + 4);
                     si32(_loc5_,_loc8_ + 12);
                  }
               }
               break;
            }
         }
         _loc9_ = li32(_loc1_ + 4);
         _loc9_ = li32(_loc9_ + 8);
         _loc2_ -= 16;
         si32(_loc9_,_loc2_ + 4);
         si32(_loc8_,_loc2_);
         wdnative.ESP = _loc2_;
         wdnative_nternal.F_d_print_comp();
         _loc2_ += 16;
         _loc1_ = li32(_loc8_ + 4);
         if(_loc1_ != 0)
         {
            _loc7_ = li32(_loc8_ + 8);
            _loc5_ = 0;
            loop6:
            while(true)
            {
               if(_loc7_ != 0)
               {
                  _loc9_ = _loc7_ + _loc1_;
                  var _temp_39:* = li8(_loc9_ - 1);
                  _loc5_ = _loc7_;
                  if(_temp_39 == 62)
                  {
                     _loc5_ = li32(_loc8_ + 12);
                     while(true)
                     {
                        if(_loc1_ != 0)
                        {
                           if(uint(_loc7_) < uint(_loc5_))
                           {
                              var _temp_40:* = int(_loc1_ + _loc7_);
                              si8(32,_temp_40);
                              _loc5_ = _loc7_ + 1;
                              si32(_loc5_,_loc8_ + 8);
                              break;
                           }
                        }
                        if(uint(_loc7_) >= uint(_loc5_))
                        {
                           _loc7_ += 1;
                           while(true)
                           {
                              if(uint(_loc5_) < uint(_loc7_))
                              {
                                 _loc2_ -= 16;
                                 si32(_loc1_,_loc2_);
                                 _loc5_ <<= 1;
                                 si32(_loc5_,_loc2_ + 4);
                                 wdnative.ESP = _loc2_;
                                 wdnative_nternal.F_realloc();
                                 _loc2_ += 16;
                                 _loc1_ = wdnative.eax;
                                 if(_loc1_ == 0)
                                 {
                                    _loc1_ = li32(_loc8_ + 4);
                                    if(_loc1_ != 0)
                                    {
                                       _loc2_ -= 16;
                                       si32(_loc1_,_loc2_);
                                       wdnative.ESP = _loc2_;
                                       wdnative_nternal.F_idalloc();
                                       _loc2_ += 16;
                                    }
                                    si32(0,_loc8_ + 4);
                                    si32(1,_loc8_ + 24);
                                    break loop6;
                                 }
                                 continue;
                              }
                              if(_loc1_ == 0)
                              {
                                 break loop6;
                              }
                              _loc7_ = li32(_loc8_ + 8);
                              si32(_loc1_,_loc8_ + 4);
                              si32(_loc5_,_loc8_ + 12);
                           }
                           break loop6;
                        }
                        _loc9_ = _loc1_ + _loc7_;
                        si8(32,_loc9_);
                        _loc9_ = li32(_loc8_ + 8);
                        _loc5_ = _loc9_ + 1;
                        si32(_loc5_,_loc8_ + 8);
                        break;
                     }
                  }
               }
               _loc1_ = li32(_loc8_ + 4);
               if(_loc1_ != 0)
               {
                  _loc7_ = li32(_loc8_ + 12);
                  if(uint(_loc5_) < uint(_loc7_))
                  {
                     var _temp_47:* = int(_loc1_ + _loc5_);
                     si8(62,_temp_47);
                     _loc9_ = _loc5_ + 1;
                     si32(_loc9_,_loc8_ + 8);
                     break;
                  }
                  _loc5_ += 1;
                  while(true)
                  {
                     if(uint(_loc7_) >= uint(_loc5_))
                     {
                        if(_loc1_ != 0)
                        {
                           var _temp_49:* = li32(_loc8_ + 8);
                           var _temp_50:* = int(_loc1_ + _temp_49);
                           si8(62,_temp_50);
                           _loc9_ = li32(_loc8_ + 8);
                           _loc9_ = _loc9_ + 1;
                           si32(_loc9_,_loc8_ + 8);
                        }
                        break loop6;
                     }
                     _loc2_ -= 16;
                     si32(_loc1_,_loc2_);
                     _loc7_ <<= 1;
                     si32(_loc7_,_loc2_ + 4);
                     wdnative.ESP = _loc2_;
                     wdnative_nternal.F_realloc();
                     _loc2_ += 16;
                     _loc1_ = wdnative.eax;
                     if(_loc1_ == 0)
                     {
                        _loc1_ = li32(_loc8_ + 4);
                        if(_loc1_ != 0)
                        {
                           _loc2_ -= 16;
                           si32(_loc1_,_loc2_);
                           wdnative.ESP = _loc2_;
                           wdnative_nternal.F_idalloc();
                           _loc2_ += 16;
                        }
                        si32(0,_loc8_ + 4);
                        si32(1,_loc8_ + 24);
                        break loop6;
                     }
                     si32(_loc1_,_loc8_ + 4);
                     si32(_loc7_,_loc8_ + 12);
                  }
               }
               break;
            }
         }
         si32(_loc10_,_loc8_ + 20);
      }
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

