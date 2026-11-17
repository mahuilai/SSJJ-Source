package wdnative
{
   import avm2.intrinsics.memory.si32;
   import wdnative_nternal.F___assert;
   import wdnative_nternal.L__2E_str359;
   import wdnative_nternal.L__2E_str56;
   import wdnative_nternal.__ZZ21getSceTriagleVerticesPviiiP11WeVertexExtE8__func__;
   
   public function _wrap_getSceTriagleVertices(param1:int, param2:int, param3:int, param4:int, param5:int) : Boolean
   {
      var _loc10_:int = 0;
      var _loc9_:int = 0;
      var _loc15_:int = 0;
      var _loc14_:int = 0;
      var _loc13_:int = 0;
      var _loc12_:int = 0;
      var _loc8_:int;
      _loc10_ = _loc8_ = wdnative.ESP;
      _loc9_ = param1;
      _loc15_ = param2;
      _loc14_ = param3;
      _loc13_ = param4;
      _loc12_ = param5;
      if(_loc12_ == 0)
      {
         _loc8_ -= 16;
         si32(wdnative_nternal.L__2E_str359,_loc8_ + 12);
         si32(91,_loc8_ + 8);
         si32(wdnative_nternal.L__2E_str56,_loc8_ + 4);
         si32(wdnative_nternal.__ZZ21getSceTriagleVerticesPviiiP11WeVertexExtE8__func__,_loc8_);
         wdnative.ESP = _loc8_;
         wdnative_nternal.F___assert();
         _loc8_ += 16;
      }
      _loc8_ -= 16;
      si32(_loc12_,_loc8_ + 8);
      si32(_loc15_,_loc8_ + 4);
      si32(_loc9_,_loc8_);
      wdnative.ESP = _loc8_;
      wdnative.F__ZN11WeSceParser11WeSceLoader9getVertexEiR11WeVertexExt();
      _loc8_ += 16;
      while(true)
      {
         var _loc11_:int = wdnative.eax;
         if(_loc11_ != 0)
         {
            _loc8_ -= 16;
            si32(_loc14_,_loc8_ + 4);
            si32(_loc9_,_loc8_);
            _loc11_ = _loc12_ + 56;
            si32(_loc11_,_loc8_ + 8);
            wdnative.ESP = _loc8_;
            wdnative.F__ZN11WeSceParser11WeSceLoader9getVertexEiR11WeVertexExt();
            _loc8_ += 16;
            _loc11_ = wdnative.eax;
            if(_loc11_ != 0)
            {
               _loc8_ -= 16;
               si32(_loc13_,_loc8_ + 4);
               si32(_loc9_,_loc8_);
               _loc11_ = _loc12_ + 112;
               si32(_loc11_,_loc8_ + 8);
               wdnative.ESP = _loc8_;
               wdnative.F__ZN11WeSceParser11WeSceLoader9getVertexEiR11WeVertexExt();
               _loc13_ = 1;
               _loc8_ += 16;
               _loc11_ = wdnative.eax;
               if(_loc11_ != 0)
               {
                  break;
               }
            }
         }
         _loc13_ = 0;
         break;
      }
      var _loc7_:Boolean;
      var _loc6_:Boolean = _loc7_ = Boolean(_loc13_);
      wdnative.ESP = _loc8_ = _loc10_;
      return _loc6_;
   }
}

