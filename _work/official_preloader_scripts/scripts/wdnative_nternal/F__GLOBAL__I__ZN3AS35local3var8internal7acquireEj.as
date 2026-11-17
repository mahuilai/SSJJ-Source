package wdnative_nternal
{
   import avm2.intrinsics.memory.*;
   import wdnative.ESP;
   import wdnative._flascc_uiTickProc;
   
   public function F__GLOBAL__I__ZN3AS35local3var8internal7acquireEj() : void
   {
      var _temp_1:* = this;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc6_:int = 0;
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc2_:int = wdnative.ESP;
      _loc3_ = _loc2_;
      si8(1,wdnative_nternal.__ZN3AS35local8internal5_nullE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS35local8internal5_trueE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS35local8internal6_falseE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS35localL5_nullE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS35localL5_trueE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS35localL6_falseE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32ui8internal5_nullE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32ui8internal5_trueE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32ui8internal6_falseE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32uiL5_nullE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32uiL5_trueE_2E_0_2E_0_2E_b);
      si8(1,wdnative_nternal.__ZN3AS32uiL6_falseE_2E_0_2E_0_2E_b);
      _loc1_ = int(Boolean(workerClass));
      do
      {
         _loc6_ = li32(wdnative._flascc_uiTickProc);
         si32(_loc6_,wdnative_nternal.__ZN3AS32uiL14sOldUITickProcE);
         _loc5_ = li32(wdnative_nternal._avm2_haveWorkers_2E_4258);
         if(_loc5_ == -1)
         {
            si32(_loc1_,wdnative_nternal._avm2_haveWorkers_2E_4258);
            _loc5_ = _loc1_;
         }
         if(_loc5_ != 0)
         {
            _loc4_ = casi32(wdnative._flascc_uiTickProc,_loc6_,wdnative_nternal.__ZN3AS32uiL9UIRCQTickEv);
         }
         else
         {
            _loc4_ = li32(wdnative._flascc_uiTickProc);
            if(_loc4_ == _loc6_)
            {
               si32(wdnative_nternal.__ZN3AS32uiL9UIRCQTickEv,wdnative._flascc_uiTickProc);
            }
         }
      }
      while(_loc4_ != _loc6_);
      wdnative.ESP = _loc3_;
   }
}

