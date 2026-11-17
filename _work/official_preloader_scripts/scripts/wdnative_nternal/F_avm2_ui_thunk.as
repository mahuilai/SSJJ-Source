package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative._flascc_uiTickProc;
   import wdnative.eax;
   import wdnative.ptr2fun;
   import wdnative.tcbp;
   
   public function F_avm2_ui_thunk() : void
   {
      var _temp_1:* = this;
      var _loc7_:int = 0;
      var _loc34_:int = 0;
      var _loc35_:int = 0;
      var _loc16_:int = 0;
      var _loc30_:int = 0;
      var _loc13_:int = 0;
      var _loc18_:int = 0;
      var _loc24_:int = 0;
      var _loc15_:int = 0;
      var _loc4_:int = 0;
      var _loc26_:int = 0;
      var _loc17_:int = 0;
      var _loc22_:int = 0;
      var _loc12_:int = 0;
      var _loc9_:int = 0;
      var _loc25_:int = 0;
      var _loc29_:int = 0;
      var _loc21_:int = 0;
      var _loc27_:int = 0;
      var _loc19_:int = 0;
      var _loc20_:int = 0;
      var _loc11_:int = 0;
      var _loc8_:int = 0;
      var _loc14_:int = 0;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc1_:int = 0;
      var _loc28_:int = 0;
      var _loc31_:int = 0;
      var _loc3_:int = wdnative.ESP;
      _loc7_ = _loc3_;
      _loc3_ -= 32;
      _loc16_ = li32(wdnative_nternal._sUITID_2E_3986);
      _loc35_ = li32(_loc7_ + 4);
      _loc34_ = li32(_loc7_);
      while(true)
      {
         if(_loc16_ == -2)
         {
            wdnative.ESP = _loc3_;
            wdnative_nternal.F_uiThreadIdRaw();
            var _loc33_:int = wdnative.eax;
            si32(_loc33_,wdnative_nternal._sUITID_2E_3986);
            if(_loc33_ >= 0)
            {
               si8(1,wdnative_nternal._sIsThreaded_2E_b);
               addr00d6:
               var _loc32_:int = li32(wdnative_nternal._sUITID_2E_3986);
               _loc33_ = int(realThreadId);
               if(_loc33_ != _loc32_)
               {
                  _loc33_ = li8(wdnative_nternal._sRegged_2E_5935_2E_b);
                  if(_loc33_ == 0)
                  {
                     var _temp_6:* = int(threadId);
                     _loc3_ -= 16;
                     _loc33_ = _temp_6 + 8;
                     si32(_loc33_,_loc3_ + 4);
                     si32(wdnative_nternal._sThunkTickLock,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_lock_id();
                     _loc3_ += 16;
                     _loc33_ = li8(wdnative_nternal._sRegged_2E_5935_2E_b);
                     if(_loc33_ == 0)
                     {
                        _loc30_ = li32(wdnative._flascc_uiTickProc);
                        si32(_loc30_,wdnative_nternal._sOldUiTickProc);
                        _loc29_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
                        if(_loc29_ == -1)
                        {
                           _loc29_ = int(Boolean(workerClass));
                           si32(_loc29_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                        }
                        if(_loc29_ != 0)
                        {
                           _loc27_ = casi32(wdnative._flascc_uiTickProc,_loc30_,wdnative_nternal._uiThunkTickProc);
                        }
                        else
                        {
                           _loc27_ = li32(wdnative._flascc_uiTickProc);
                           if(_loc27_ == _loc30_)
                           {
                              si32(wdnative_nternal._uiThunkTickProc,wdnative._flascc_uiTickProc);
                           }
                        }
                        _loc33_ = li32(wdnative_nternal._sOldUiTickProc);
                        if(_loc27_ != _loc33_)
                        {
                           do
                           {
                              _loc13_ = _loc27_;
                              si32(_loc13_,wdnative_nternal._sOldUiTickProc);
                              _loc21_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
                              if(_loc21_ == -1)
                              {
                                 _loc21_ = int(Boolean(workerClass));
                                 si32(_loc21_,wdnative_nternal._avm2_haveWorkers_2E_4258);
                              }
                              if(_loc21_ != 0)
                              {
                                 _loc27_ = casi32(wdnative._flascc_uiTickProc,_loc13_,wdnative_nternal._uiThunkTickProc);
                              }
                              else
                              {
                                 _loc27_ = li32(wdnative._flascc_uiTickProc);
                                 if(_loc27_ == _loc13_)
                                 {
                                    si32(wdnative_nternal._uiThunkTickProc,wdnative._flascc_uiTickProc);
                                 }
                              }
                              _loc33_ = li32(wdnative_nternal._sOldUiTickProc);
                           }
                           while(_loc27_ != _loc33_);
                        }
                        si8(1,wdnative_nternal._sRegged_2E_5935_2E_b);
                     }
                     _loc3_ -= 16;
                     si32(wdnative_nternal._sThunkTickLock,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_unlock();
                     _loc3_ += 16;
                  }
                  _loc22_ = int(realThreadId);
                  _loc24_ = _loc22_ + 1;
                  while(true)
                  {
                     _loc32_ = int(threadId);
                     _loc33_ = tcbp;
                     si32(0,_loc7_ - 24);
                     _loc26_ = _loc7_ - 24;
                     _loc17_ = _loc26_ | 4;
                     si32(0,_loc17_);
                     si32(0,_loc7_ - 16);
                     si32(0,_loc7_ - 12);
                     si32(0,_loc7_ - 8);
                     si32(0,_loc7_ - 4);
                     si32(_loc34_,_loc7_ - 24);
                     si32(_loc35_,_loc17_);
                     si32(_loc32_,_loc7_ - 16);
                     si32(_loc33_,_loc7_ - 12);
                     _loc18_ = tcbp;
                     _loc19_ = wdnative_nternal._sLock_2E_3932;
                     if(_loc18_ != -1)
                     {
                        _loc19_ = _loc18_ + 16;
                     }
                     _loc20_ = li32(wdnative_nternal._sLock_2E_3932);
                     if(_loc20_ == -1)
                     {
                        si32(_loc24_,wdnative_nternal._sLock_2E_3932);
                        _loc20_ = _loc24_;
                     }
                     if(_loc20_ != 0)
                     {
                        if(_loc19_ != wdnative_nternal._sLock_2E_3932)
                        {
                           si32(_loc20_,_loc19_);
                           si32(0,wdnative_nternal._sLock_2E_3932);
                        }
                     }
                     _loc15_ = _loc22_ + 1;
                     _loc33_ = li32(_loc19_);
                     _loc33_ = _loc33_ & 0x7FFFFFFF;
                     _loc14_ = 0;
                     if(_loc33_ == _loc15_)
                     {
                        _loc12_ = tcbp;
                        if(_loc12_ == -1)
                        {
                           li32(wdnative_nternal._sCounter_2E_3947);
                           _loc11_ = wdnative_nternal._sCounter_2E_3947;
                        }
                        else
                        {
                           _loc11_ = _loc12_ + 20;
                           _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                           if(_loc33_ != 0)
                           {
                              if(_loc11_ != wdnative_nternal._sCounter_2E_3947)
                              {
                                 _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                                 si32(_loc33_,_loc11_);
                                 si32(0,wdnative_nternal._sCounter_2E_3947);
                              }
                           }
                        }
                        _loc8_ = li32(_loc11_);
                        _loc14_ = _loc15_;
                     }
                     _loc33_ = int(threadId);
                     _loc3_ -= 16;
                     _loc33_ += 8;
                     si32(_loc33_,_loc3_ + 4);
                     si32(wdnative_nternal._sThunkTickLock,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_lock_id();
                     _loc3_ += 16;
                     _loc33_ = li32(wdnative_nternal._sThunkTickHead);
                     si32(_loc33_,_loc7_ - 4);
                     si32(_loc26_,wdnative_nternal._sThunkTickHead);
                     _loc3_ -= 16;
                     si32(wdnative_nternal._sThunkTickHead,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_wake_one();
                     _loc3_ += 16;
                     if(_loc14_ == 0)
                     {
                        _loc3_ -= 16;
                        si32(0,_loc3_ + 8);
                        si32(wdnative_nternal._sThunkTickLock,_loc3_ + 4);
                        si32(_loc26_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_avm2_msleep();
                        _loc3_ += 16;
                     }
                     else
                     {
                        _loc9_ = tcbp;
                        if(_loc9_ == -1)
                        {
                           li32(wdnative_nternal._sCounter_2E_3947);
                           _loc6_ = wdnative_nternal._sCounter_2E_3947;
                        }
                        else
                        {
                           _loc6_ = _loc9_ + 20;
                           _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                           if(_loc33_ != 0)
                           {
                              if(_loc6_ != wdnative_nternal._sCounter_2E_3947)
                              {
                                 _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                                 si32(_loc33_,_loc6_);
                                 si32(0,wdnative_nternal._sCounter_2E_3947);
                              }
                           }
                        }
                        si32(0,_loc6_);
                        _loc3_ -= 16;
                        si32(_loc19_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_avm2_unlock();
                        _loc3_ += 16;
                        _loc3_ -= 16;
                        si32(0,_loc3_ + 8);
                        si32(wdnative_nternal._sThunkTickLock,_loc3_ + 4);
                        si32(_loc26_,_loc3_);
                        wdnative.ESP = _loc3_;
                        wdnative_nternal.F_avm2_msleep();
                        _loc3_ += 16;
                        if(_loc14_ != 0)
                        {
                           _loc2_ = wdnative_nternal._sLock_2E_3932;
                           _loc4_ = tcbp;
                           if(_loc4_ != -1)
                           {
                              _loc2_ = _loc4_ + 16;
                           }
                           _loc1_ = li32(wdnative_nternal._sLock_2E_3932);
                           if(_loc1_ == -1)
                           {
                              _loc1_ = _loc22_ + 1;
                              si32(_loc1_,wdnative_nternal._sLock_2E_3932);
                           }
                           if(_loc1_ != 0)
                           {
                              if(_loc2_ != wdnative_nternal._sLock_2E_3932)
                              {
                                 si32(_loc1_,_loc2_);
                                 si32(0,wdnative_nternal._sLock_2E_3932);
                              }
                           }
                           _loc3_ -= 16;
                           si32(_loc14_,_loc3_ + 4);
                           si32(_loc2_,_loc3_);
                           wdnative.ESP = _loc3_;
                           wdnative_nternal.F_avm2_lock_id();
                           _loc3_ += 16;
                           _loc25_ = tcbp;
                           if(_loc25_ == -1)
                           {
                              li32(wdnative_nternal._sCounter_2E_3947);
                              _loc28_ = wdnative_nternal._sCounter_2E_3947;
                           }
                           else
                           {
                              _loc28_ = _loc25_ + 20;
                              _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                              if(_loc33_ != 0)
                              {
                                 if(_loc28_ != wdnative_nternal._sCounter_2E_3947)
                                 {
                                    _loc33_ = li32(wdnative_nternal._sCounter_2E_3947);
                                    si32(_loc33_,_loc28_);
                                    si32(0,wdnative_nternal._sCounter_2E_3947);
                                 }
                              }
                           }
                           si32(_loc8_,_loc28_);
                        }
                     }
                     _loc3_ -= 16;
                     si32(wdnative_nternal._sThunkTickLock,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_unlock();
                     _loc3_ += 16;
                     _loc33_ = li32(_loc7_ - 8);
                     if(_loc33_ == 0)
                     {
                        break;
                     }
                     _loc3_ -= 16;
                     si32(5,_loc3_ + 4);
                     si32(wdnative_nternal._sEnterFrame,_loc3_);
                     wdnative.ESP = _loc3_;
                     wdnative_nternal.F_avm2_self_msleep();
                     _loc3_ += 16;
                  }
                  _loc31_ = li32(_loc17_);
                  break;
               }
            }
         }
         else if(_loc16_ >= 0)
         {
            §§goto(addr00d6);
         }
         _loc3_ -= 16;
         si32(_loc35_,_loc3_);
         wdnative.ESP = _loc3_;
         wdnative.ptr2fun[_loc34_]();
         _loc3_ += 16;
         _loc31_ = wdnative.eax;
         break;
      }
      wdnative.eax = _loc31_;
      _loc3_ = _loc7_;
      wdnative.ESP = _loc3_;
   }
}

