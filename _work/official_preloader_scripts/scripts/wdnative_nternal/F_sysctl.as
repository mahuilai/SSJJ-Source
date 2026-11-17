package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative.Fmemcpy;
   import wdnative.eax;
   
   public function F_sysctl() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc8_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      _loc1_ = li32(_loc3_);
      _loc8_ = li32(_loc1_);
      _loc7_ = li32(_loc3_ + 12);
      _loc6_ = li32(_loc3_ + 8);
      if(_loc8_ != 8)
      {
         if(_loc8_ != 6)
         {
            _loc5_ = -1;
            if(_loc8_ == 1)
            {
               _loc8_ = li32(_loc1_ + 4);
               _loc5_ = -1;
               if(_loc8_ <= 9)
               {
                  if(_loc8_ != 1)
                  {
                     if(_loc8_ != 2)
                     {
                        if(_loc8_ == 4)
                        {
                           si32(20,_loc7_);
                           var _loc4_:int = li8(wdnative_nternal.___avm2_version);
                           si8(_loc4_,_loc6_);
                           _loc5_ = 0;
                           if(_loc4_ != 0)
                           {
                              _loc7_ = wdnative_nternal.___avm2_version + 1;
                              _loc6_ += 1;
                              do
                              {
                                 _loc4_ = li8(_loc7_);
                                 si8(_loc4_,_loc6_);
                                 _loc6_ += 1;
                                 _loc7_ += 1;
                                 _loc5_ = 0;
                              }
                              while(_loc4_ != 0);
                           }
                        }
                     }
                     else
                     {
                        si32(12,_loc7_);
                        _loc4_ = li8(wdnative_nternal.___avm2_osrelease);
                        si8(_loc4_,_loc6_);
                        _loc5_ = 0;
                        if(_loc4_ != 0)
                        {
                           _loc7_ = wdnative_nternal.___avm2_osrelease + 1;
                           _loc6_ += 1;
                           do
                           {
                              _loc4_ = li8(_loc7_);
                              si8(_loc4_,_loc6_);
                              _loc6_ += 1;
                              _loc7_ += 1;
                              _loc5_ = 0;
                           }
                           while(_loc4_ != 0);
                        }
                     }
                  }
                  else
                  {
                     si32(8,_loc7_);
                     _loc4_ = li8(wdnative_nternal.___avm2_ostype);
                     si8(_loc4_,_loc6_);
                     _loc5_ = 0;
                     if(_loc4_ != 0)
                     {
                        _loc7_ = wdnative_nternal.___avm2_ostype + 1;
                        _loc6_ += 1;
                        do
                        {
                           _loc4_ = li8(_loc7_);
                           si8(_loc4_,_loc6_);
                           _loc6_ += 1;
                           _loc7_ += 1;
                           _loc5_ = 0;
                        }
                        while(_loc4_ != 0);
                     }
                  }
               }
               else if(_loc8_ != 10)
               {
                  if(_loc8_ != 24)
                  {
                     if(_loc8_ == 33)
                     {
                        si32(4,_loc7_);
                        _loc4_ = int(ESP_init);
                        si32(_loc4_,_loc6_);
                        _loc5_ = 0;
                     }
                  }
                  else
                  {
                     si32(4,_loc7_);
                     si32(800028,_loc6_);
                     _loc5_ = 0;
                  }
               }
               else
               {
                  si32(19,_loc7_);
                  _loc4_ = li8(wdnative_nternal.___avm2_hostname);
                  si8(_loc4_,_loc6_);
                  _loc5_ = 0;
                  if(_loc4_ != 0)
                  {
                     _loc7_ = wdnative_nternal.___avm2_hostname + 1;
                     _loc6_ += 1;
                     do
                     {
                        _loc4_ = li8(_loc7_);
                        si8(_loc4_,_loc6_);
                        _loc6_ += 1;
                        _loc7_ += 1;
                        _loc5_ = 0;
                     }
                     while(_loc4_ != 0);
                  }
               }
            }
         }
         else
         {
            _loc8_ = li32(_loc1_ + 4);
            if(_loc8_ != 7)
            {
               if(_loc8_ != 3)
               {
                  _loc5_ = -1;
                  if(_loc8_ == 1)
                  {
                     si32(5,_loc7_);
                     _loc4_ = li8(wdnative_nternal.___avm2_machine);
                     si8(_loc4_,_loc6_);
                     _loc5_ = 0;
                     if(_loc4_ != 0)
                     {
                        _loc7_ = wdnative_nternal.___avm2_machine + 1;
                        _loc6_ += 1;
                        do
                        {
                           _loc4_ = li8(_loc7_);
                           si8(_loc4_,_loc6_);
                           _loc6_ += 1;
                           _loc7_ += 1;
                           _loc5_ = 0;
                        }
                        while(_loc4_ != 0);
                     }
                  }
               }
               else
               {
                  si32(4,_loc7_);
                  si32(8,_loc6_);
                  _loc5_ = 0;
               }
            }
            else
            {
               si32(4,_loc7_);
               _loc4_ = int(pageSize);
               si32(_loc4_,_loc6_);
               _loc5_ = 0;
            }
         }
      }
      else
      {
         _loc4_ = li32(_loc3_ + 16);
         if(_loc4_ != 0)
         {
            si32(1,wdnative_nternal._errno);
            _loc5_ = -1;
         }
         else
         {
            _loc4_ = li32(_loc3_ + 4);
            if(_loc4_ != 2)
            {
               si32(22,wdnative_nternal._errno);
               _loc5_ = -1;
            }
            else
            {
               _loc4_ = li32(_loc1_ + 4);
               if(_loc4_ == 1)
               {
                  if(_loc6_ == 0)
                  {
                     si32(31,_loc7_);
                     _loc5_ = 0;
                  }
                  else
                  {
                     _loc4_ = li32(_loc7_);
                     if((uint(_loc4_)) <= 30)
                     {
                        si32(12,wdnative_nternal._errno);
                        _loc5_ = -1;
                     }
                     else
                     {
                        si32(31,_loc7_);
                        _loc2_ -= 16;
                        si32(31,_loc2_ + 8);
                        si32(wdnative_nternal.L__2E_str711,_loc2_ + 4);
                        si32(_loc6_,_loc2_);
                        wdnative.ESP = _loc2_;
                        wdnative.Fmemcpy();
                        _loc2_ += 16;
                        _loc5_ = 0;
                     }
                  }
               }
               else if(_loc6_ == 0)
               {
                  si32(4,_loc7_);
                  _loc5_ = 0;
               }
               else
               {
                  _loc4_ = li32(_loc7_);
                  if((uint(_loc4_)) <= 3)
                  {
                     si32(12,wdnative_nternal._errno);
                     _loc5_ = -1;
                  }
                  else
                  {
                     si32(4,_loc7_);
                     _loc5_ = li32(_loc1_ + 4);
                     if(_loc5_ <= 10)
                     {
                        if(_loc5_ <= 5)
                        {
                           if(_loc5_ <= 3)
                           {
                              if(_loc5_ != 2)
                              {
                                 if(_loc5_ != 3)
                                 {
                                    addr05e5:
                                    si32(22,wdnative_nternal._errno);
                                    _loc5_ = -1;
                                 }
                                 else
                                 {
                                    si32(2048,_loc6_);
                                    _loc5_ = 0;
                                 }
                              }
                              else
                              {
                                 si32(99,_loc6_);
                                 _loc5_ = 0;
                              }
                           }
                           else if(_loc5_ != 4)
                           {
                              if(_loc5_ != 5)
                              {
                                 §§goto(addr05e5);
                              }
                              else
                              {
                                 si32(1000,_loc6_);
                                 _loc5_ = 0;
                              }
                           }
                           else
                           {
                              si32(99,_loc6_);
                              _loc5_ = 0;
                           }
                        }
                        else if(_loc5_ <= 7)
                        {
                           if(_loc5_ != 6)
                           {
                              if(_loc5_ != 7)
                              {
                                 §§goto(addr05e5);
                              }
                              else
                              {
                                 si32(32,_loc6_);
                                 _loc5_ = 0;
                              }
                           }
                           else
                           {
                              _loc5_ = 0;
                              si32(_loc5_,_loc6_);
                           }
                        }
                        else if(_loc5_ != 8)
                        {
                           if(_loc5_ != 9)
                           {
                              if(_loc5_ != 10)
                              {
                                 §§goto(addr05e5);
                              }
                              else
                              {
                                 si32(199212,_loc6_);
                                 _loc5_ = 0;
                              }
                           }
                           else
                           {
                              si32(255,_loc6_);
                              _loc5_ = 0;
                           }
                        }
                        else
                        {
                           si32(2048,_loc6_);
                           _loc5_ = 0;
                        }
                     }
                     else if(_loc5_ <= 15)
                     {
                        if(_loc5_ <= 12)
                        {
                           if(_loc5_ != 11)
                           {
                              if(_loc5_ != 12)
                              {
                                 §§goto(addr05e5);
                              }
                              else
                              {
                                 _loc5_ = 0;
                                 si32(_loc5_,_loc6_);
                              }
                           }
                           else
                           {
                              _loc5_ = 0;
                              si32(_loc5_,_loc6_);
                           }
                        }
                        else if(_loc5_ != 13)
                        {
                           if(_loc5_ != 14)
                           {
                              if(_loc5_ != 15)
                              {
                                 §§goto(addr05e5);
                              }
                              else
                              {
                                 _loc5_ = 0;
                                 si32(_loc5_,_loc6_);
                              }
                           }
                           else
                           {
                              _loc5_ = 0;
                              si32(_loc5_,_loc6_);
                           }
                        }
                        else
                        {
                           _loc5_ = 0;
                           si32(_loc5_,_loc6_);
                        }
                     }
                     else if(_loc5_ <= 17)
                     {
                        if(_loc5_ != 16)
                        {
                           if(_loc5_ != 17)
                           {
                              §§goto(addr05e5);
                           }
                           else
                           {
                              _loc5_ = 0;
                              si32(_loc5_,_loc6_);
                           }
                        }
                        else
                        {
                           _loc5_ = 0;
                           si32(_loc5_,_loc6_);
                        }
                     }
                     else if(_loc5_ != 18)
                     {
                        if(_loc5_ != 19)
                        {
                           if(_loc5_ != 20)
                           {
                              §§goto(addr05e5);
                           }
                           else
                           {
                              si32(255,_loc6_);
                              _loc5_ = 0;
                           }
                        }
                        else
                        {
                           si32(20,_loc6_);
                           _loc5_ = 0;
                        }
                     }
                     else
                     {
                        _loc5_ = 0;
                        si32(_loc5_,_loc6_);
                     }
                  }
               }
            }
         }
      }
      wdnative.eax = _loc5_;
      _loc2_ = _loc3_;
      wdnative.ESP = _loc2_;
   }
}

